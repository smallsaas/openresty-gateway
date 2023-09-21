FROM openresty/openresty:1.21.4.2-bullseye-fat

WORKDIR /usr/local
RUN apt-get update -y
RUN apt-get install -y build-essential libreadline-dev liblua5.3-dev lua5.3 procps unzip vim curl net-tools 

# manual build base luarocks tool
WORKDIR /opt
#ADD ./packages . 
ADD http://luarocks.github.io/luarocks/releases/luarocks-3.3.1.tar.gz .
RUN tar -zxvf luarocks-3.3.1.tar.gz
RUN mv luarocks-3.3.1 /usr/local

# changed the folder into luarocks 
WORKDIR /usr/local/luarocks-3.3.1
RUN ./configure --with-lua-include=/usr/include
RUN make
RUN make install

WORKDIR /usr/local/openresty
# create lua module folder
RUN mkdir lua_modules
# install lua-resty-jwt dependency
RUN luarocks install --tree lua_modules lua-resty-jwt 

WORKDIR /usr/local/openresty/nginx
# update user root
COPY ./nginx.conf conf/nginx.conf 
CMD openresty -p `pwd` -c conf/nginx.conf -g 'daemon off;'

EXPOSE 80

