#!/bin/bash

cd vagrant
vagrant up --provision && vagrant halt

cd ..

docker build --no-cache=true .
