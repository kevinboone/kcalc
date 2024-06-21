TARGET      := kcalc
VERSION     := 9.0.0
CC          := gcc
LUAVERSION  = 5.2.1
DESTDIR     ?= /
PREFIX      := /usr/
SHAREDIR    = ${PREFIX}/share
MYSHAREDIR  = $(SHAREDIR)/$(TARGET)
BINDIR      = $(PREFIX)/bin/
MANDIR      = $(SHAREDIR)/man
EXTRA_CFLAGS ?=
EXTRA_LDLAGS ?=
LDFLAGS     := -s $(EXTRA_LDFLAGS)

MAINSRCS    := $(shell find src/main/src -type f -name *.c)
MAINOBJS    := $(patsubst src/main/src/%,build/main/%,$(MAINSRCS:.c=.o))
DEPS        := $(MAINSRCS:.c=.d)

INCLUDE_CFLAGS := -I src/main/include -I . -I lua-${LUAVERSION}/src
READLINE_LIBS  := -lreadline
LIBS  := ${READLINE_LIBS} -lm 

all: $(TARGET) 

CFLAGS_BASE=$(INCLUDE_CFLAGS) -MMD -DSHAREDIR=\"$(MYSHAREDIR)\" -DNAME=\"$(TARGET)\"  -DVERSION=\"$(VERSION)\"
CFLAGS=$(CFLAGS_BASE) -g -DHAVE_READLINE -O0 -Wall -Wno-unused-result -Wextra $(EXTRA_CFLAGS)

build/main/%.o: src/main/src/%.c
	@mkdir -p build/main
	$(CC) $(CFLAGS) -c $< -o $@ 

$(TARGET): lua $(MAINOBJS)
	$(CC) $(LDFLAGS) -o $(TARGET) $(MAINOBJS) lua-$(LUAVERSION)/src/liblua.a $(LIBS)

lua: 
	CC=$(CC) make -C lua-${LUAVERSION} generic

docs:
	man2html man1/kcalc.1 | grep -v Content-type > doc/kcalc_manual.html

install:
	mkdir -p $(DESTDIR)/$(BINDIR) $(DESTDIR)/$(MANDIR)/man1
	mkdir -p $(DESTDIR)/$(SHAREDIR) $(DESTDIR)/$(MYSHAREDIR)
	install -m 755 $(TARGET) $(DESTDIR)/$(BINDIR)
	install -m 755 scripts/* $(DESTDIR)/$(MYSHAREDIR)
	install -m 644 man1/* $(DESTDIR)/$(MANDIR)/man1/

-include $(DEPS)

clean:
	rm -rf build
	make -C lua-${LUAVERSION} clean
	find . -name "*.d" -exec rm {} \;

