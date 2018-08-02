
FROM riccardoblb/base:amd64

LABEL maintainer="Riccardo Balbo <riccardo0blb@gmail.com>"

ARG NGINX_URL="https://nginx.org/download/nginx-1.14.0.tar.gz"
ARG NGINX_HASH="5d15becbf69aba1fe33f8d416d97edd95ea8919ea9ac519eff9bafebb6022cb5"

ARG NGINX_LUA_URL="https://github.com/openresty/lua-nginx-module/archive/v0.10.13.tar.gz"
ARG NGINX_LUA_HASH="ecea8c3d7f69dd48c6132498ddefb5d83ba9f387fa3d4da14e2abeacdfc8a3ee"

ARG NGINX_DEVEL_KIT_URL="https://github.com/simplresty/ngx_devel_kit/archive/v0.3.1rc1.tar.gz"
ARG NGINX_DEVEL_KIT_HASH="49f50d4cd62b166bc1aaf712febec5e028d9f187cedbc27a610dfd01bdde2d36"

ARG LUAJIT_URL="https://luajit.org/download/LuaJIT-2.0.5.tar.gz"
ARG LUAJIT_HASH="874b1f8297c697821f561f9b73b57ffd419ed8f4278c82e05b48806d30c1e979"

ARG LUAROCKS_URL="https://github.com/luarocks/luarocks/archive/v3.0.0.tar.gz"
ARG LUAROCKS_HASH="faa5f54bf72b2250100c337fbd16b92a59a0f8411f31769297f16fbafd6663fe"

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