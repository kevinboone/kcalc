APP=kcalc

APPNAME=$(APP)
TARGETS=$(APP)

ifndef CC 
CC=gcc
endif

UNAME := $(shell uname -o)

CFLAGS_BASE=-Wall -O3 -I lua-5.2.1/src 

PLATFORM=unix
ifeq ($(UNAME),Msys)
  PLATFORM=win32
endif

ifeq ($(PLATFORM),win32)
  CFLAGS=$(CFLAGS_BASE)
  PLATOBJS=res.o
else
  CFLAGS=$(CFLAGS_BASE) -DHAVE_READLINE -fpie -fpic
  RLLIBS=-lreadline -lncurses
  #RLLIBS=libreadline.a -lncurses 
  BINDIR=/usr/bin
  MANDIR=/usr/share/man/man1
  SHAREDIR=/usr/share/kcalc
endif


all: $(TARGETS) 
include dependencies.mak

MAJOR_VERSION=8
MINOR_VERSION=0
VERSION=$(MAJOR_VERSION).$(MINOR_VERSION)


.SUFFIXES: .o .c

KLIB_OBJS=klib_error.o klib_object.o klib_string.o klib_log.o klib_buffer.o klib_wstring.o klib_convertutf.o klib_getopt.o klib_getoptspec.o klib_list.o klib_path.o

CORE_OBJS=main.o 


OBJS=$(CORE_OBJS) $(LUA_OBJS) $(KLIB_OBJS) $(PLATOBJS)

# Static-link version for KBOX
#$(APP): lua $(OBJS) 
#	$(CC) -s -static -o $(APP) $(OBJS) lua-5.2.1/src/liblua.a -lm -lreadline -lncurses 

$(APP): lua $(OBJS) $(UIOBJS) 
	$(CC) -pie -s -o $(APP) $(OBJS) $(UIOBJS) lua-5.2.1/src/liblua.a $(RLLIBS) -lm

lua:
	CC=$(CC) make -C lua-5.2.1 generic

res.o: res.rc
	windres res.rc -o res.o

.c.o:
	$(CC) $(CFLAGS) $(INCLUDES) -DMAJOR_VERSION=\"$(MAJOR_VERSION)\" -DMINOR_VERSION=\"$(MINOR_VERSION)\" -DVERSION=\"$(VERSION)\" -DAPPNAME=\"$(APPNAME)\" -c $*.c -o $*.o 

clean:
	rm -f $(APP) $(APP).exe $(GUIAPP) $(GUIAPP).exe *.o dump *.stackdump 
	rm -rf out 
	make -C lua-5.2.1 clean


srcdist: clean
	(cd ..; tar cvfz /tmp/$(APPNAME)-$(VERSION).tar.gz kcalc8)


web: srcdist
	./makeman.pl > kcalc.man.html
	cp /tmp/$(APPNAME)-$(VERSION).tar.gz /home/kevin/docs/kzone5/target/
	cp kcalc.man.html /home/kevin/docs/kzone5/target/
	cp README_kcalc.html /home/kevin/docs/kzone5/source
	cp kcalc_faq.html /home/kevin/docs/kzone5/source

winbuild: all
	mkdir -p out/binaries
	mkdir -p out/$(PLATFORM)
	cp -p kcalc out/$(PLATFORM)
	cp -pr scripts out/$(PLATFORM)
	(cd out/$(PLATFORM); tar cfz ../binaries/kcalc-8.0-$(PLATFORM)-binaries.tar.gz .)

linbuild: all
	mkdir -p out/binaries
	mkdir -p out/$(PLATFORM)/usr/share/kcalc/
	mkdir -p out/$(PLATFORM)/usr/bin
	mkdir -p out/$(PLATFORM)/usr/share/man/man1
	cp man1/kcalc.1 out/$(PLATFORM)/usr/share/man/man1
	cp  kcalc.sh out/$(PLATFORM)/usr/bin/kcalc
	cp  kcalc out/$(PLATFORM)/usr/share/kcalc/
	chmod 755 out/$(PLATFORM)/usr/bin/kcalc
	cp -vaux scripts out/$(PLATFORM)/usr/share/kcalc
	(cd out/$(PLATFORM); tar cfz ../binaries/kcalc-8.0-$(PLATFORM)-binaries.tar.gz .)


linstall: all linbuild
	tar xvfz out/binaries/kcalc-8.0-$(PLATFORM)-binaries.tar.gz -C $(DESTDIR) 

winstall: all winbuild
	echo "No automated installation for windows platform"

ifeq ($(PLATFORM),win32)
install: winstall
else
install: linstall
endif

ifeq ($(PLATFORM),win32)
build: winbuild
else
build: linbuild
endif


