#!/bin/bash

cd $(dirname $0)

if [[ $(jq -r .source.url meta.json) == http* ]]
then
  CURLOPTS='-L -c /tmp/cookies -A eps/1.2'
  curl $CURLOPTS -o official.json $(jq -r .source.json meta.json)
  jq -r '.base.componentInstances[] | select(.data.userText) | .data.userText' official.json > official.html
fi

cd ~-
