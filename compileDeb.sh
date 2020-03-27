find . -name '.DS_Store' -delete
dpkg-deb --build ./deb ./org.brandonplank.flappybird_1.8.deb
