echo "Ender version number:"
read version

find . -name '.DS_Store' -delete
mkdir output
cd input

# unsign Flappy Bird.app dir
rm -rf ./Flappy\ Bird.app/_CodeSignature
rm -f ./Flappy\ Bird.app/embedded.mobileprovision

# make the ipa
mkdir ./Payload
cp -r ./Flappy\ Bird.app ./Payload
zip -r ../output/org.brandonplank.flappybird.ipa ./Payload
rm -rf ./Payload

# make the deb
mkdir ./deb
mkdir ./deb/Applications
mkdir ./deb/DEBIAN
echo "Package: org.brandonplank.flappybird
Name: Flappy Bird
Version: $version
Architecture: iphoneos-arm
Description: A Flappy Bird clone that runs on the latest iOS!
Maintainer: Brandon Plank
Author: Brandon Plank, Thather Clough
Section: Games
SileoDepiction: https://repo.brandonplank.org/depictions/org.brandonplank.flappybird/flappybird.json
" >> ./deb/DEBIAN/control
cp -r ./Flappy\ Bird.app ./deb/Applications
cp -r ../postinst ./deb/DEBIAN
chmod 0775 ./deb/DEBIAN/postinst
dpkg-deb --build ./deb ./org.brandonplank.flappybird.deb
mv ./org.brandonplank.flappybird.deb ../output
rm -rf deb
