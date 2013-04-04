#!/bin/sh

if [ $# -ne 1 ]; then
	echo 1>&2 Usage: ./build.sh branch
	exit 0
fi

# remove any existing exports
rm -rf Prism-Extras

# checkout the latest code from trunk
git clone git@github.com:prism/Prism-Extras.git
cd Prism-Extras

# checkout the proper branch
git checkout --track -b $1 origin/$1

# get the git revision number
gitvers=`git describe`

cd web-ui

# add in revision
sed -e "s/nightly/$gitvers/g" config.sample.php > config-new.php
mv config-new.php config.sample.php

cd ..

# make the jar
zip -r Prism-WebUI-$gitvers.zip web-ui

# send file to amazon bucket
s3cmd put --acl-public Prism-WebUI-$gitvers.zip s3://botsko/Prism/Prism-WebUI-$gitvers.zip

# Remove the files
cd ..
rm -rf Prism-Extras

echo "BUILD COMPLETE"
