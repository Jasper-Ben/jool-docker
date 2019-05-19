FROM alpine:latest as BUILD

LABEL maintainer="Jasper Orschulko <jasper@fancydomain.eu>"

ARG JOOL_VER=3.5.7

RUN set -ex \
    && apk --no-cache add \
        wget \
        ca-certificates \
        gcc \
        build-base \
        libnl3-dev \
        autoconf \
        automake \
        bash \
        linux-headers \
        argp-standalone \
    && update-ca-certificates \
    && wget https://github.com/NICMx/Jool/archive/v${JOOL_VER}.tar.gz -O /jool.tar.gz \
    && mkdir /jool \
    && tar -xvf /jool.tar.gz -C /jool --strip-components=1 \
    && cd /jool/usr \
    && ./autogen.sh \
    && ./configure LIBNLGENL3_CFLAGS=-I/usr/include/libnl3 LIBNLGENL3_LIBS="-lnl-genl-3 -lnl-3" \
    && make -j$(nproc) \
    && make install


FROM alpine:latest

LABEL maintainer="Jasper Orschulko <jasper@fancydomain.eu>"

RUN set -ex \
    && apk --no-cache add \
        libnl3 libnl3-dev
        
#RUN apt-get update \
#    && apt-get install libnl-3-200 libnl-genl-3

COPY --from=build /usr/local/bin/jool_siit /usr/bin/jool_siit
COPY --from=build /usr/local/share/man/man8/jool_siit.8 /usr/share/man/man8/jool_siit.8
COPY --from=build /usr/local/bin/joold /usr/bin/joold

COPY netsocket.json /root/netsocket.json
