TARGET = postrm
VERSION = 0.1
CC = xcrun -sdk iphoneos clang -framework Foundation -arch armv7 -arch arm64 -arch arm64e -miphoneos-version-min=10.0
LDID = ldid
GO_EASY_ON_ME=1
.PHONY: all clean

all: clean postinst
	mv postrm ../

postinst: clean
	$(CC) main.m -o postrm
	strip postrm
	$(LDID) -Sentitlements.xml postrm

clean:
	rm -rf .theos
