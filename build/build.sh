#!/bin/bash
set -e

declare OPERATING_SYSTEMS=""
declare BUILD_DIR=`pwd`

if [[ -d pkg ]]; then
  rm -rf pkg/*
else
  mkdir pkg
fi

if [[ $# -gt 0 ]]; then
  OPERATING_SYSTEMS=( "$@" )
else
  OPERATING_SYSTEMS=(centos6 ubuntu32 debian64-jessie debian64-wheezy ubuntu64 debian32-jessie debian32-wheezy deb centos7)
fi


function failure() {
  if [[ ! -z ${OS_CURRENTLY_BUILD} ]]; then
   cat ${BUILD_DIR}/pkg/${OS_CURRENTLY_BUILD}.log
   echo Failure when building ${OS_CURRENTLY_BUILD}
  fi
}

trap failure 0 1 2 3 13 15

ES_VERSION=$(ruby -r '../lib/electric_sheep/version.rb' -e "puts ElectricSheep::VERSION")

global_start_time=`date +%s`
for os in "${OPERATING_SYSTEMS[@]}"
do
  start_time=`date +%s`
  declare OS_CURRENTLY_BUILD=${os}
  echo "Building Electric Sheep for ${os}"
  cd ${BUILD_DIR}/docker/${os}
  docker build -t "omnibus:${os}" . > ${BUILD_DIR}/pkg/${os}.log
  docker run -ti \
    -v ${BUILD_DIR}/..:/root/project \
    -e USER=$USER \
    -e USERID=$UID \
    "omnibus:${os}" \
    -c "cd build && bundle install && bundle exec omnibus build electric_sheep" >> ${BUILD_DIR}/pkg/${os}.log
  end_time=`date +%s`
  echo Package built in `expr ${end_time} - ${start_time}` s.
done

declare OS_CURRENTLY_BUILD=""
global_end_time=`date +%s`
echo Package built in `expr ${global_end_time} - ${global_start_time}` s.
exit 0

