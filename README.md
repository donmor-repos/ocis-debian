# ocis-debian

[![Debian Build Bot](https://github.com/donmor/ocis-debian/actions/workflows/dpkg-buildpackage.yml/badge.svg?event=release)](https://github.com/donmor/ocis-debian/actions/workflows/dpkg-buildpackage.yml)

(Unofficial) Debian packaging scripts for [ownCloud Infinite Scale](https://github.com/owncloud/ocis).

You may want to pin to specific stable versions (e.g. 7.1.x).

Provided packages:
- `ocis` (+dbgsym)
- `ocis-common`

## Quick configuration
Install [`donmor-repos-keyring`](https://donmor-repos.github.io/pub/donmor-repos-keyring_0.0.1_all.deb) and [`ocis-debian-repo`](https://donmor-repos.github.io/pub/ocis-debian-repo_0.0.1_all.deb), then run `apt-get update`.

## Manual configuration
#### Add keyring:
``` bash
curl -sLOJR --output-dir /usr/share/keyrings https://donmor-repos.github.io/pub/donmor-repos-keyring.gpg
```
#### Add `ocis-debian`:
``` bash
tee /etc/apt/sources.list.d/ocis.sources <<EOF
Types: deb deb-src
URIs: https://github.com/donmor-repos/ocis-debian/releases/latest/download
Suites: /
Signed-By: /usr/share/keyrings/donmor-repos-keyring.gpg
EOF
apt-get update
```
