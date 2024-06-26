FROM rockylinux:8

RUN dnf -y module enable ruby:3.1 \
    && dnf -y install \
    ruby ruby-devel rubygem-bundler git \
    bind which \
    && dnf clean all

RUN rndc-confgen -a -r /dev/urandom
RUN chown named. /etc/rndc.key
RUN echo 'include "/etc/rndc.key";' >> /etc/named.conf
RUN echo 'controls { inet 127.0.0.1 allow { localhost; } keys { rndc-key; }; };' >> /etc/named.conf

WORKDIR /app

#RUN gem install bundler

RUN mkdir -p lib/addzone/

COPY Gemfile addzone.gemspec ./
COPY lib/addzone/version.rb lib/addzone/version.rb

RUN bundle install

COPY . .

CMD ["/usr/sbin/named", "-g", "-u", "named"]
