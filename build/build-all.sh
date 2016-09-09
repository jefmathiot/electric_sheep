#!/bin/bash
set -e

declare -A platforms
platforms['i686']='i386'
platforms['x86_64']='amd64'

json_val () {
    local json=$1
    local prop=$2
    temp=`echo $json | sed 's/\\\\\//\//g' | sed 's/[{}]//g' | \
      awk -v k="text" '{n=split($0,a,","); for (i=1; i<=n; i++) print a[i]}' | \
      sed 's/\"\:\"/\|/g' | sed 's/[\,]/ /g' | sed 's/\"//g' | grep -w $prop| \
      cut -d":" -f2| sed -e 's/^ *//g' -e 's/ *$//g'`
    echo ${temp##*|}
}

BUILD_DIR=`pwd`
rm -rf pkg/*

ES_VERSION=$(ruby -r '../lib/electric_sheep/version.rb' -e "puts ElectricSheep::VERSION")

cd "$BUILD_DIR/vagrant"
vagrant up --provision && vagrant halt

cd "$BUILD_DIR"

for f in pkg/*.deb.metadata.json
do
  content=$(cat $f)
  platform=$(json_val "$content" 'platform')
  arch=${platforms[$(json_val "$content" 'arch')]}
  deb=$(json_val "$content" 'basename')
  sha1=$(json_val "$content" 'sha1')
  package="electric-sheep-$platform-${ES_VERSION}_$arch.deb"

  mv "pkg/$deb" "pkg/$package"
  size=$(du -hs -0 "pkg/$package" | cut -f1)
  echo "$platform-$arch sha1: $sha1"

  # Package used by the Docker build
  if [ "$platform" = 'ubuntu' ] && [ "$arch" = 'amd64' ]
    then
      cp "pkg/$package" 'pkg/electric-sheep-docker.deb'
  fi
  echo "$platform $arch $package $size $sha1" >> pkg/summary.txt
done

docker build --no-cache -t servebox/electric_sheep .
docker tag servebox/electric_sheep:latest servebox/electric_sheep:${ES_VERSION}
