#!/bin/bash

BUILD_DIR=`pwd`

ES_VERSION=$(ruby -r '../lib/electric_sheep/version.rb' -e "puts ElectricSheep::VERSION")

cd $BUILD_DIR/vagrant
vagrant up --provision && vagrant halt

cd $BUILD_DIR
rm -f pkg/electric-sheep-docker.deb
cp pkg/electric-sheep-ubuntu_${ES_VERSION}-1_amd64.deb pkg/electric-sheep-docker.deb
docker build --no-cache -t servebox/electric_sheep .
docker tag servebox/electric_sheep:latest servebox/electric_sheep:${ES_VERSION}
