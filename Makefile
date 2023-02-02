TARGET      = kcalc
VERSION     = 9.0.0
CC          = gcc
LUAVERSION  = 5.2.1
DEST        = /
PREFIX      = usr/
SHAREDIR    = $(DEST)${PREFIX}share
MYSHAREDIR  = $(SHAREDIR)/$(TARGET)
BINDIR      = $(DEST)/$(PREFIX)/bin/
MANDIR      = $(SHAREDIR)/man

MAINSRCS    := $(shell find src/main/src -type f -name *.c)
MAINOBJS    := $(patsubst src/main/src/%,build/main/%,$(MAINSRCS:.c=.o))
DEPS        := $(MAINSRCS:.c=.d)

INCLUDE_CFLAGS := -I src/main/include -I . -I lua-${LUAVERSION}/src
READLINE_LIBS  := -lreadline
LIBS  := ${READLINE_LIBS} -lm 

all: $(TARGET) 

CFLAGS_BASE=$(INCLUDE_CFLAGS) -MMD -DSHAREDIR=\"$(MYSHAREDIR)\" -DNAME=\"$(TARGET)\"  -DVERSION=\"$(VERSION)\"
CFLAGS=$(CFLAGS_BASE) -g -DHAVE_READLINE -O0 -Wall -Wextra $(EXTRA_CFLAGS)

build/main/%.o: src/main/src/%.c
	@mkdir -p build/main
	$(CC) $(CFLAGS) -c $< -o $@ 

$(TARGET): lua $(MAINOBJS)
	$(CC) -o $(TARGET) $(MAINOBJS) lua-$(LUAVERSION)/src/liblua.a $(LIBS)

lua: 
	CC=$(CC) make -C lua-${LUAVERSION} generic

docs:
	man2html man1/kcalc.1 | grep -v Content-type > doc/kcalc_manual.html

install:
	install -m 755 $(TARGET) $(BINDIR)
	mkdir -p $(SHAREDIR)
	install -m 755 scripts/* $(MYSHAREDIR)
	install -m 644 man1/* $(MANDIR)/man1/

-include $(DEPS)

clean:
	rm -rf build
	make -C lua-${LUAVERSION} clean
	find . -name "*.d" -exec rm {} \;

