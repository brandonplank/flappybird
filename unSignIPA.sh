#!/bin/bash

SCRIPTPATH="$( cd "$(dirname "$0")" ; pwd -P )"
cd $SCRIPTPATH



rm -rf flappybird.ipa

rm -rf Payload

mkdir Payload

cp -r "$( cd "$(dirname "$0")" ; pwd -P )"/deb/Applications/Flappy\ Bird.app ./Payload/Flappy\ Bird.app

find . -name '.DS_Store' -delete
find . -name '_CodeSignature' -delete

find . -name 'embedded.mobileprovision' -delete

rm -f ./Payload/Flappy\ Bird.app/embedded.mobileprovision
rm -rf ./Payload/Flappy\ Bird.app/_CodeSignature

touch ./Payload/Flappy\ Bird.app/embedded.mobileprovision
mkdir ./Payload/Flappy\ Bird.app/_CodeSignature

rm -f flappybird.ipa
zip -r flappybird.ipa ./Payload/


zip -r flappybird.ipa ./Payload/

rm -rf Payload
