# syntax=docker/dockerfile:experimental
FROM openresty/openresty

WORKDIR /usr/src
ADD ./gateway ./

WORKDIR /usr/src/gateway

CMD openresty -p `pwd` -c conf/nginx.conf -g 'daemon off;'

EXPOSE 10000