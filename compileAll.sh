find . -name '.DS_Store' -delete
sh unSignIPA.sh
dpkg-deb --build ./deb ./org.brandonplank.flappybird_1.8.deb
