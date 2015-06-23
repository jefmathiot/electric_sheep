#!/bin/bash
set -e

BUILD_DIR=`pwd`
rm -rf pkg/*

ES_VERSION=$(ruby -r '../lib/electric_sheep/version.rb' -e "puts ElectricSheep::VERSION")

cd $BUILD_DIR/vagrant
vagrant up --provision && vagrant halt

cd $BUILD_DIR
package=$(ls pkg/electric-sheep-ubuntu_${ES_VERSION}*_amd64.deb)
cp $package pkg/electric-sheep-docker.deb
docker build --no-cache -t servebox/electric_sheep .
docker tag servebox/electric_sheep:latest servebox/electric_sheep:${ES_VERSION}
