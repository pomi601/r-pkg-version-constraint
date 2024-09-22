#!/usr/bin/env bash

set -euo pipefail

scriptdir="$(realpath $(dirname "${BASH_SOURCE[0]}"))"
libdir="$scriptdir/lib"

## clean built packages in repo1, repo2, repo3
cd repos/repo1/src/contrib
rm -f pomi.*
cd "$scriptdir"
cd repos/repo2/src/contrib
rm -f pomi.*
cd "$scriptdir"
cd repos/repo3/src/contrib
cd "$scriptdir"

## clean libdir
if [ -d "$libdir" ]; then rm -r "$libdir"; fi
mkdir -p "$libdir"

## make base v1 and add to repo1
tmpdir=$(mktemp -d)
cd "$tmpdir"
R CMD build "$scriptdir/pkgs/base/v1"
mv * "$scriptdir/repos/repo1/src/contrib/"
cd "$scriptdir"
rm -r "$tmpdir"

## make base v2 and add to repo2
tmpdir=$(mktemp -d)
cd "$tmpdir"
R CMD build "$scriptdir/pkgs/base/v2"
mv * "$scriptdir/repos/repo2/src/contrib/"
cd "$scriptdir"
rm -r "$tmpdir"

## make derived and add to repo3
tmpdir=$(mktemp -d)
cd "$tmpdir"
R CMD build "$scriptdir/pkgs/derived"
cp * "$scriptdir/repos/repo3/src/contrib/"
cd "$scriptdir"
rm -r "$tmpdir"

## select repos to operate with: repo1 (base 1.0) and repo3 (derived)
repos="c(\"file://$scriptdir/repos/repo1\",\"file://$scriptdir/repos/repo3\")"

## shows both base 1.0 and derived available
echo "checking available packages at repos = $repos"
Rscript -e "available.packages(repos = $repos)"

echo "checking base"
R_LIBS_USER=$libdir R CMD check "$scriptdir/pkgs/base/v1"

echo "installing base"
R_LIBS_USER=$libdir Rscript -e "install.packages('pomi.test.base', repos = $repos)"

echo "checking derived - EXPECT FAIL"
R_LIBS_USER=$libdir R CMD check "$scriptdir/pkgs/derived"

echo "install derived - EXPECT FAIL"
R_LIBS_USER=$libdir Rscript -e "AP <- available.packages(repos = $repos); install.packages('pomi.test.derived', available = AP, verbose = TRUE)"
