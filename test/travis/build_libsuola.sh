set -e
set -v
cd "$TRAVIS_BUILD_DIR"
mkdir build
cd build
PKG_CONFIG_PATH="$HOME/cache/libsodium/stable/lib/pkgconfig" cmake -DOPENSSL_ROOT_DIR="$HOME/cache/openssl/$OPENSSL_VERSION" ..
make
