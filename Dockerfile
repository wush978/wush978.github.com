FROM ruby:1.9.3-p551
MAINTAINER Wush Wu <wush978@gmail.com>

RUN gem install jekyll && \
    gem install bundle

WORKDIR /root
RUN git clone https://github.com/wush978/wush978.github.com.git -b source && \
    cd /root/wush978.github.com && \
    bundle install

