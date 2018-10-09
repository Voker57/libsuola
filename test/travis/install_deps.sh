set -e

upgrade_system() {
	set -v
	set -e
	VERSION="$1"
	ARCHIVES="
deb http://fi.archive.ubuntu.com/ubuntu/ $VERSION main 
###### Ubuntu Update Repos
deb http://fi.archive.ubuntu.com/ubuntu/ $VERSION-security main 
deb http://fi.archive.ubuntu.com/ubuntu/ $VERSION-updates main 
deb http://fi.archive.ubuntu.com/ubuntu/ $VERSION-backports main "
	echo "$ARCHIVES" | sudo tee "/etc/apt/sources.list.d/$VERSION.list"
	sudo apt-get update
	sudo apt-get install dpkg # To install new package format
	sudo apt-get install libssl-dev
}

install_openssl() {
	set -v
	set -e
	VERSION="$1"
	if [ "$VERSION" == native ]
	then
		export OSSL_ROOT="/usr"
		return 0
	fi
	export OSSL_ROOT="$HOME/cache/openssl/$VERSION"
	if [ -e "$OSSL_ROOT" ]
	then
		return 0
	fi
	
	mkdir -p "$HOME/src"
	cd "$HOME/src"
	test -d openssl && rm -rf openssl || :
	git clone --depth=5 https://github.com/openssl/openssl.git --branch "$VERSION"
	cd openssl
	
# 	cd openssl
# 	git checkout "$VERSION"
	./config -d shared --prefix="$OSSL_ROOT" --openssldir="$OSSL_ROOT/ssl" -Wl,-rpath="$OSSL_ROOT/lib"
	make -j2
	make install
}

install_libsodium() {
	set -v
	set -e
# 	VERSION="$1"
	
	VERSION=stable
	LIB_ROOT="$HOME/cache/libsodium/$VERSION"
	if [ -e "$LIB_ROOT" ]
	then
		return 0
	fi
	mkdir -p "$HOME/src"
	cd "$HOME/src"
	test -d libsodium && rm -rf libsodium || :
	git clone --depth=5 https://github.com/jedisct1/libsodium --branch stable
	cd libsodium
# 	git checkout "$VERSION"
	./configure --prefix="$LIB_ROOT"
	make -j2
	make install
}

set -v

upgrade_system "$UPGRADE"
install_openssl "$OPENSSL_VERSION"
install_libsodium stable
