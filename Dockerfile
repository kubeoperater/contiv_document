FROM ubuntu:16.04
COPY . /sources
WORKDIR /sources/websrc
RUN sed -i 's/archive.ubuntu.com/mirrors.163.com/g' /etc/apt/sources.list && apt-get update && apt-get install -y git-core openssh-client curl wget \
 build-essential openssl libreadline6 libreadline6-dev curl zlib1g zlib1g-dev \
 libssl-dev libyaml-dev libsqlite3-dev sqlite3 libxml2-dev libxslt-dev \
 autoconf libc6-dev ncurses-dev automake libtool bison pkg-config nodejs \
 gawk libgmp-dev libgdbm-dev libffi-dev gnupg2  build-essential patch ruby-dev zlib1g-dev liblzma-dev && \
curl -sSL https://rvm.io/pkuczynski.asc | gpg2 --import - &&  \
curl -L https://get.rvm.io | bash -s stable  && \
/bin/bash -l -c "rvm requirements" && \
echo "gem: --no-document" >~/.gemrc && \
/bin/bash -l -c "rvm install 2.3.0" && \ 
/bin/bash -l -c "gem install psych -v 2.2.4" && \
/bin/bash -l -c "gem install bundler -v 1.17.3" && \
/bin/bash -l -c "gem install sassc -v 2.4.0" && \
cd /sources/websrc && bash -l -c "bundle update" && bash -l -c "bundle exec middleman build "
EXPOSE 35729
EXPOSE 4567
ENTRYPOINT [ "bash", "-x", "/sources/websrc/start.sh" ] 
