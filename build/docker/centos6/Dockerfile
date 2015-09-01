FROM centos:centos6
MAINTAINER ServeBox / ElectricSheep.IO <humans@electricsheep.io>

# Install the packages
RUN yum install -y epel-release && \
    yum groupinstall -y 'Development Tools' && \
    yum install -y yum-utils git rpm-build wget tar \
          gcc make automake autoconf readline-devel curl-devel libyaml libyaml-devel \
          readline-devel ncurses-devel glibc-devel gdbm-devel tcl-devel openssl-devel db4-devel \
          fakeroot openssl-devel zlib-devel libffi-devel && \
    cd /tmp && \
    yum install -y https://github.com/feedforce/ruby-rpm/releases/download/2.2.3/ruby-2.2.3-1.el6.x86_64.rpm && \
    yum update -y

# Prepare the project directory
RUN echo 'gem: --no-rdoc --no-ri' >> "$HOME/.gemrc"
RUN mkdir project

RUN gem install bundler

RUN git config --global user.email "humans@electricsheep.io" && \
    git config --global user.name "Electric Sheep IO"

WORKDIR /root/project
ENTRYPOINT ["/bin/bash"]
