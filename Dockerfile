
FROM riccardoblb/base:amd64

LABEL maintainer="Riccardo Balbo <riccardo0blb@gmail.com>"

ARG NGINX_URL="https://nginx.org/download/nginx-1.12.2.tar.gz"
ARG NGINX_HASH="305f379da1d5fb5aefa79e45c829852ca6983c7cd2a79328f8e084a324cf0416"

ARG NGINX_LUA_URL="https://github.com/openresty/lua-nginx-module/archive/v0.10.11.tar.gz"
ARG NGINX_LUA_HASH="c0fb91fcfd1c6e7dec34ca64826ef81ffebafdef6174d254467636f380566626"

ARG NGINX_DEVEL_KIT_URL="https://github.com/simpl/ngx_devel_kit/archive/v0.3.0.tar.gz"
ARG NGINX_DEVEL_KIT_HASH="88e05a99a8a7419066f5ae75966fb1efc409bad4522d14986da074554ae61619"

ARG LUAJIT_URL="https://luajit.org/download/LuaJIT-2.0.5.tar.gz"
ARG LUAJIT_HASH="874b1f8297c697821f561f9b73b57ffd419ed8f4278c82e05b48806d30c1e979"

ARG LUAROCKS_URL="https://github.com/luarocks/luarocks/archive/v2.4.3.tar.gz"
ARG LUAROCKS_HASH="ea1881d6954f2a98c34f93674571c8f0cbdbc28dedb3fa3cb56b6a91886d1a99"

COPY install.sh /install.sh
RUN chmod +x /install.sh
RUN apk add --update  wget \
ca-certificates \
openssl \
pcre \
zlib \
&& apk add --virtual .build-deps  \
linux-headers \
build-base \
openssl-dev \
pcre-dev \
zlib-dev \
libxml2-dev \
libxslt-dev \
gd-dev \
geoip-dev  \
&& apk add --no-cache \
        gd \
        geoip \
        libgcc \
        libxslt \
zlib \
&& addgroup -g 1000 -S nginx \
&& adduser -u  1000 -S -D -G nginx  nginx \
        && /install.sh \
&& apk del .build-deps \
&& rm /install.sh \
&&  ln -sf /dev/stdout /var/log/nginx/access.log \
&& ln -sf /dev/stderr /var/log/nginx/error.log

EXPOSE 80
EXPOSE 443

STOPSIGNAL SIGTERM

CMD ["nginx", "-g", "daemon off;"]