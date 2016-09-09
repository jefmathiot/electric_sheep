FROM ubuntu:16.04
MAINTAINER ServeBox / ElectricSheep.IO <humans@electricsheep.io>

RUN apt-get update  && apt-get install -y \
  gnupg

ADD pkg/electric-sheep-docker.deb /tmp/electric-sheep-docker.deb
RUN dpkg -i /tmp/electric-sheep-docker.deb

WORKDIR /electric_sheep

ENTRYPOINT ["electric_sheep"]
