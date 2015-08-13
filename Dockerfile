FROM gliderlabs/alpine:3.2
ENV NODE_VERSION=0.12.7
RUN set -ex \
    && apk update \
    && apk add openssl-dev gnupg make gcc g++ python linux-headers libgcc libstdc++ \
    && for key in \
           7937DFD2AB06298B2293C3187D33FF9D0246406D \
           114F43EE0176B71C7BC219DD50A3051F888C628D \
       ; do \
           gpg --keyserver ha.pool.sks-keyservers.net --recv-keys "$key"; \
       done \
    && mkdir /build \
    && cd /build \
    && wget https://nodejs.org/dist/v$NODE_VERSION/node-v$NODE_VERSION.tar.gz \
    && wget https://nodejs.org/dist/v$NODE_VERSION/SHASUMS256.txt.asc \
    && gpg --verify SHASUMS256.txt.asc \
    && grep " node-v$NODE_VERSION.tar.gz\$" SHASUMS256.txt.asc | sha256sum -c - \
    && tar -xvz < node-v$NODE_VERSION.tar.gz \
    && cd node-v$NODE_VERSION \
    && ./configure --prefix=/usr --fully-static \
    && make -j$(grep -c ^processor /proc/cpuinfo 2>/dev/null || 1) \
    && make install \
    && strip /usr/bin/node \
    && cd / \
    && apk del openssl-dev gnupg make gcc g++ python linux-headers \
    && rm -rf /build /root/.gpg
