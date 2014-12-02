#!/bin/bash

build_dir=`pwd`

cd $build_dir/vagrant
librarian-chef install
vagrant up --provision && vagrant halt
