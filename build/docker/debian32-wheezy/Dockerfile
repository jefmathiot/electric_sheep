FROM ehartmann/debian32:wheezy
MAINTAINER ServeBox / ElectricSheep.IO <humans@electricsheep.io>

# Install the packages
RUN apt-get update -y && \
    apt-get install -y gnupg ruby git ruby-dev build-essential autoconf zlib1g-dev libc6-dev

# Prepare the project directory
RUN echo 'gem: --no-rdoc --no-ri' >> "$HOME/.gemrc"
RUN mkdir project

RUN gem install bundler

RUN git config --global user.email "humans@electricsheep.io" && \
    git config --global user.name "Electric Sheep IO"

WORKDIR /root/project
ENTRYPOINT ["/bin/bash"]
