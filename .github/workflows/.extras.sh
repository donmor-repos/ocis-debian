#!/bin/sh

# Get info
node_req=`jq -r '.engines.node' web/package.json | sed 's/[>,=]//g'`
pnpm_req=`jq -r '.packageManager' web/package.json`
go_req=`grep '^go [0-9.]\+$' go.mod | grep -o '[0-9.]\+'`
go_pkg=`curl -sL "https://go.dev/dl/?mode=json&include=all" | jq -r --arg major ${go_req} --arg arch ${GOHOSTARCH}  'first(.[] | select(.version | contains($major))) | .files[] | select(.os == "linux" and .arch == $arch) | .filename'`
cross_pkg=`[ ! "$GOARCH" = "$GOHOSTARCH" ] && echo gcc-${C_ARCH} binutils-${C_ARCH} libc6-dev-${D_ARCH}-cross || echo ""`
echo Required Node version: ${node_req}
echo Required Go version: ${go_req}
echo Required cross toolchain: ${cross_pkg}
# Remove old packages
sudo rm -rf /usr/local/bin/node /usr/local/bin/nodejs /usr/local/bin/npm /usr/local/bin/npx /usr/local/bin/corepack /usr/local/include/node /usr/local/lib/node_modules /usr/local/bin/go /usr/local/go /usr/local/lib/go
# Get nodejs and npm
if ! curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /usr/share/keyrings/nodesource.gpg || ! chmod 644 /usr/share/keyrings/nodesource.gpg; then exit 1; fi
cat <<EOF | sudo tee /etc/apt/sources.list.d/nodesource.sources > /dev/null
Types: deb
URIs: https://deb.nodesource.com/node_$NODE_VERSION
Suites: nodistro
Components: main
Architectures: $H_ARCH
Signed-By: /usr/share/keyrings/nodesource.gpg
EOF
echo "Package: nodejs" | sudo tee /etc/apt/preferences.d/nodejs > /dev/null
echo "Pin: origin deb.nodesource.com" | sudo tee -a /etc/apt/preferences.d/nodejs > /dev/null
echo "Pin-Priority: 600" | sudo tee -a /etc/apt/preferences.d/nodejs > /dev/null
# Get go from Google
echo Fetching ${go_pkg}...
curl -L -o /tmp/go.tar.gz https://dl.google.com/go/${go_pkg}
mkdir -p /tmp/golang-go/DEBIAN /tmp/golang-go/usr/bin /tmp/golang-go/usr/lib
tar -xzf /tmp/go.tar.gz -C /tmp/golang-go/usr/lib
ln -sf ../lib/go/bin/go /tmp/golang-go/usr/bin/go
ln -sf ../lib/go/bin/gofmt /tmp/golang-go/usr/bin/gofmt
cat <<EOF | tee /tmp/golang-go/DEBIAN/control > /dev/null
Package: golang-go
Version: 2:$go_req~1
Architecture: $H_ARCH
Maintainer: donmor <donmor3000@hotmail.com>
Description: Go programming language compiler and tools
 This package provides the official Go binary distribution for Linux/amd64.
 It is a simple repackaging of the upstream tarball.
EOF
dpkg-deb --root-owner-group --build /tmp/golang-go /tmp/golang-go.deb
# Install packages
if ! sudo apt-get update || ! sudo apt-get install --no-install-recommends build-essential debhelper nodejs=$node_req-1nodesource1 /tmp/golang-go.deb ${cross_pkg}; then exit 1; fi
echo Using Node: `which node`
echo Using Go: `which go`
# End hack
