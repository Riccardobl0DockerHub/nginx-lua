#!/bin/sh
set -e

rm -f nginx.tar.gz
rm -f nginx_lua.tar.gz
rm -f nginx_devel.tar.gz
rm -f luajit.tar.gz

wget  "${NGINX_URL}" -O nginx.tar.gz

wget "${NGINX_LUA_URL}" -O  nginx_lua.tar.gz

wget "${NGINX_DEVEL_KIT_URL}" -O nginx_devel.tar.gz

wget "${LUAJIT_URL}" -O luajit.tar.gz

wget ${LUAROCKS_URL} -O luarocks.tar.gz 

nginx_hash=`sha256sum nginx.tar.gz| cut -d ' ' -f 1` 
echo "Nginx: $nginx_hash"
nginx_lua_hash=`sha256sum nginx_lua.tar.gz| cut -d ' ' -f 1` 
echo "Nginx Lua: $nginx_lua_hash"
nginx_devel_hash=`sha256sum nginx_devel.tar.gz| cut -d ' ' -f 1` 
echo "Nginx Devel: $nginx_devel_hash"
luajit_hash=`sha256sum luajit.tar.gz| cut -d ' ' -f 1` 
echo "LuaJit: $luajit_hash"
luarocks_hash=`sha256sum luarocks.tar.gz| cut -d ' ' -f 1` 
echo "Luarocks: $luarocks_hash"

if [ "$luarocks_hash" != "${LUAROCKS_HASH}" -o "$nginx_hash" != "${NGINX_HASH}" -o  "$nginx_lua_hash" != "${NGINX_LUA_HASH}"  -o  "$nginx_devel_hash" != "${NGINX_DEVEL_KIT_HASH}"  -o "$luajit_hash" != "${LUAJIT_HASH}"   ];
then
    rm -Rf nginx*.tar.gz
    echo "Hashes do not match."
    echo "$nginx_hash ${NGINX_HASH}"
    echo " $nginx_lua_hash ${NGINX_LUA_HASH}"
    echo " $nginx_devel_hash ${NGINX_DEVEL_KIT_HASH}"
    echo " $luajit_hash ${LUAJIT_HASH}"  
	echo " $luarocks_hash ${LUAROCKS_HASH}"  
     exit 1
fi

tar -xzf nginx.tar.gz

tar -xzf nginx_lua.tar.gz

tar -xzf nginx_devel.tar.gz

tar -xzf luajit.tar.gz

tar -xzf luarocks.tar.gz


rm -Rf nginx*.tar.gz
rm -Rf luajit.tar.gz
rm -Rf luarocks.tar.gz

export LUAJIT_LIB=/usr/local/lib/
export LUAJIT_INC=/usr/local/include/luajit-2.0

cd LuaJIT-*
make
make install
cd ..
rm -Rf LuaJIT-*

cd luarocks-*
./configure --lua-suffix=jit --with-lua=/usr/local \
 --with-lua-lib=$LUAJIT_LIB \
 --with-lua-include=$LUAJIT_INC
make build
make install
cd ..
rm -Rf luarocks-*

mv ngx_devel_kit-* nginx_devel
mv lua-nginx-module-* lua-nginx
cd nginx-*



./configure \
--with-http_ssl_module \
--with-http_dav_module \
--sbin-path=/usr/sbin/nginx \
--conf-path=/etc/nginx/nginx.conf \
--pid-path=/var/run/nginx.pid  \
--lock-path=/var/lock/nginx.lock \
--http-log-path=/var/log/nginx/access.log  \
--error-log-path=/var/log/nginx/error.log  \
--with-http_ssl_module \
		--with-http_realip_module \
		--with-http_addition_module \
		--with-http_sub_module \
		--with-http_dav_module \
		--with-http_flv_module \
		--with-http_mp4_module \
		--with-http_gunzip_module \
		--with-http_gzip_static_module \
		--with-http_random_index_module \
		--with-http_secure_link_module \
		--with-http_stub_status_module \
		--with-http_auth_request_module \
		--with-http_xslt_module=dynamic \
		--with-http_image_filter_module=dynamic \
		--with-http_geoip_module=dynamic \
		--with-threads \
		--with-stream \
		--with-stream_ssl_module \
		--with-stream_ssl_preread_module \
		--with-stream_realip_module \
		--with-stream_geoip_module=dynamic \
		--with-http_slice_module \
		--with-mail \
		--with-mail_ssl_module \
		--with-compat \
		--with-file-aio \
		--with-http_v2_module \
--add-module=../nginx_devel \
--add-module=../lua-nginx


make -j2
make install
cd ..


unset LUAJIT_LIB
unset LUAJIT_INC


rm -Rf  nginx_devel
rm -Rf lua-nginx
rm -Rf nginx-*
rm -Rf luarocks-*

