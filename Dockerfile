FROM centos:centos7

RUN yum install -y \
    git wget make gcc zlib-devel openssl-devel sqlite sqlite-devel mysql-devel \
    readline-devel libffi-devel libxml2-devel libxslt-devel

RUN wget https://cache.ruby-lang.org/pub/ruby/2.4/ruby-2.4.9.tar.gz
RUN tar zxvf ruby-2.4.9.tar.gz
WORKDIR ruby-2.4.9
RUN ./configure
RUN make
RUN make install

RUN yum install -y bind which

RUN rndc-confgen -a -r /dev/urandom
RUN chown named. /etc/rndc.key
RUN echo 'include "/etc/rndc.key";' >> /etc/named.conf
RUN echo 'controls { inet 127.0.0.1 allow { localhost; } keys { rndc-key; }; };' >> /etc/named.conf

WORKDIR /usr/src/app

RUN gem install bundler

COPY . .

# throw errors if Gemfile has been modified since Gemfile.lock
RUN bundle config --global frozen 1

RUN bundle install

# run specs with docker container
# docker build -t addzone .
# docker run addzone /bin/bash -c '/usr/sbin/named -u named && bundle exec rake'