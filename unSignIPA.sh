#!/bin/bash

SCRIPTPATH="$( cd "$(dirname "$0")" ; pwd -P )"
cd $SCRIPTPATH



rm -rf flappybird.ipa

rm -rf Payload

mkdir Payload

cp -r "$( cd "$(dirname "$0")" ; pwd -P )"/deb/Applications/Flappy\ Bird.app ./Payload/Flappy\ Bird.app

rm -f flappybird.ipa
zip -r flappybird.zip ./Payload

mv flappybird.zip flappybird.ipa


rm -rf Payload
