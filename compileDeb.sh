find . -name '.DS_Store' -delete
dpkg-deb --build ./deb ./org.brandonplank.flapp_1.7_iphoneos-arm.deb
