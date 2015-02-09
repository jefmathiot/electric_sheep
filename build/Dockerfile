FROM ubuntu:trusty
MAINTAINER ServeBox ElectricSheep.io <humans@electricsheep.io>

WORKDIR /electricsheep

RUN mkdir /electricsheep/pkg
ADD pkg/electric-sheep-ubuntu_0.2.1-1_amd64.deb /electricsheep/pkg/electric-sheep-ubuntu_0.2.1-1_amd64.deb

RUN dpkg -i /electricsheep/pkg/electric-sheep-ubuntu_0.2.1-1_amd64.deb
