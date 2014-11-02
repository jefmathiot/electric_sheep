#!/bin/bash

build_dir=`pwd`

function build {
    cd $build_dir/vagrant/$1
    librarian-chef install
    vagrant up --provision && vagrant halt
}

rm -rf ./pkg
build ubuntu32
build ubuntu64
