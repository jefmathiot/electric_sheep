#!/bin/bash
set -e

declare OPERATING_SYSTEMS=(centos6 ubuntu32 debian64 ubuntu64 debian32 centos7)
declare OS_CURRENTLY_BUILD=""
declare BUILD_DIR=`pwd`

if [[ -d pkg ]]; then
  rm -rf pkg/*
else
  mkdir pkg
fi

function failure() {
  if [[ -z ${OS_CURRENTLY_BUILD} ]]; then
   cat ${BUILD_DIR}/pkg/${OS_CURRENTLY_BUILD}.log
   echo Failure when building ${OS_CURRENTLY_BUILD}
  fi
}

trap failure 1 2 3 15 EXIT

ES_VERSION=$(ruby -r '../lib/electric_sheep/version.rb' -e "puts ElectricSheep::VERSION")

global_start_time=`date +%s`
for os in "${OPERATING_SYSTEMS[@]}"
do
  start_time=`date +%s`
  OS_CURRENTLY_BUILD=${os}
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
OS_CURRENTLY_BUILD=""
global_end_time=`date +%s`
echo Package built in `expr ${global_end_time} - ${global_start_time}` s.
exit 0

