#!/usr/bin/env bash

# The version to build, like "7.8.2"
version=$1
temp_dir=tmp

if [ -z "$version" ]; then
  echo "No version provided"
else
  rm -rf $temp_dir
  mkdir $temp_dir
  curl --fail -o $temp_dir/jwplayer.zip "https://ssl.p.jwpcdn.com/player/download/jwplayer-${version}.zip"
  if [ "$?" != "0" ]; then
    echo "Failed to download jwplayer"
  else
    unzip -d $temp_dir $temp_dir/jwplayer.zip
    if [ "$?" != "0" ]; then
      echo "Failed to extract files"
    else
      rm -rf dist
      mv $temp_dir/jwplayer-* dist

      # update version number
      sed -i '' "s#\"version\":[ ]*\".*\"#\"version\": \"$version\"#" package.json
      sed -i '' "s#length<2);var #length<1);var #" dist/jwplayer.js
      sed -i '' "s#length>2||2===#length>1||1===#" dist/jwplayer.js
      sed -i '' "/\!.&&2===/s/2/1/g" dist/jwplayer.js

      # publish to npmjs.org
      npm version --access=public
    fi
  fi
fi
