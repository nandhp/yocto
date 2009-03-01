#!/bin/bash -ex
#
# Packaging script for Yocto. This script is all highly user-specific,
# and likely requires substantial modification for you to find it useful.
#
set -e
set -x
make clean			# Clean directory tree
make deb			# Build a deb file
make dist			# Build a tar file
# Build yocto plugin debs
[[ -d yocto-plugins ]] && (cd yocto-plugins; fakeroot debian/rules binary; fakeroot debian/rules clean || true)

# Relocate everything to deb/ directory
for x in {.,..}/yocto*.{deb,tar.gz}; do
    [[ -f $x ]] || continue
    mv $x deb/
done

# Debianize source packages
cd deb
for x in yocto-*.tar.gz; do
    [[ -f $x ]] || continue
    BASE=`basename "$x" .tar.gz`
    tar xzf $x
    [[ ../debian/control -nt $BASE/debian/control ]] || dpkg-source -b $BASE
    rm -rf $BASE
done
cd ..

# Install into repository
POOL=$HOME/public_html/debian/pool
cp -p deb/*.deb "$POOL"
for x in deb/*.dsc; do
    [[ -f $x ]] || continue
    BASE=deb/`basename "$x" .dsc`
    cp -p $x $BASE*.tar.gz "$POOL"
done
$HOME/public_html/debian/update.sh
