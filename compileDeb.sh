find . -name '.DS_Store' -delete
dpkg-deb --build ./deb ./flappybird.deb
