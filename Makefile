VERSION = $(shell git describe --tags)
PREFIX = /opt/termite
#PREFIX = /usr/local
GTK = gtk+-3.0
VTE = vte-2.91
TERMINFO = ${PREFIX}/share/terminfo

CXXFLAGS := -std=c++11 -O3 \
	    -Wall -Wextra -pedantic \
	    -Winit-self \
	    -Wshadow \
	    -Wformat=2 \
	    -Wmissing-declarations \
	    -Wstrict-overflow=5 \
	    -Wcast-align \
	    -Wconversion \
	    -Wunused-macros \
	    -Wwrite-strings \
	    -DNDEBUG \
	    -D_POSIX_C_SOURCE=200809L \
	    -DTERMITE_VERSION=\"${VERSION}\" \
	    -I/usr/local/include/vte-2.91/ -I/usr/include/glib-2.0 -I/usr/lib64/glib-2.0/include -I/usr/include/pango-1.0 -I/usr/include/gtk-3.0 -I/usr/include/cairo -I/usr/include/pixman-1 -I/usr/include/freetype2 -I/usr/include/libpng16 -I/usr/include/libdrm -I/usr/include/harfbuzz -I/usr/include/gdk-pixbuf-2.0 -I/usr/include/gio-unix-2.0/ -I/usr/include/atk-1.0 -I/usr/include/at-spi2-atk/2.0 -I/usr/include/at-spi-2.0 -I/usr/include/dbus-1.0 -I/usr/lib64/dbus-1.0/include -pthread -I/usr/include/p11-kit-1
	    # ${shell pkg-config --cflags ${GTK} ${VTE}} \
	    ${CXXFLAGS}

ifeq (${CXX}, g++)
	CXXFLAGS += -Wno-missing-field-initializers
endif

ifeq (${CXX}, clang++)
	CXXFLAGS += -Wimplicit-fallthrough
endif

LDFLAGS := -s -Wl,--as-needed ${LDFLAGS}
LDLIBS := -lvte-2.91 -lgtk-3 -lgdk-3 -lpangocairo-1.0 -lpango-1.0 -latk-1.0 -lcairo-gobject -lcairo -lgdk_pixbuf-2.0 -lgio-2.0 -lgobject-2.0 -lglib-2.0 -lz -lpcre2-8 -lgnutls

#LDLIBS := ${shell pkg-config --libs ${GTK} ${VTE}}

termite: termite.cc url_regex.hh util/clamp.hh util/maybe.hh util/memory.hh
	${CXX} ${CXXFLAGS} ${LDFLAGS} $< ${LDLIBS} -o $@

install: termite termite.desktop termite.terminfo
	mkdir -p ${DESTDIR}${TERMINFO}
	install -Dm755 termite ${DESTDIR}${PREFIX}/bin/termite
	install -Dm644 config ${DESTDIR}/etc/xdg/termite/config
	install -Dm644 termite.desktop ${DESTDIR}${PREFIX}/share/applications/termite.desktop
	install -Dm644 man/termite.1 ${DESTDIR}${PREFIX}/share/man/man1/termite.1
	install -Dm644 man/termite.config.5 ${DESTDIR}${PREFIX}/share/man/man5/termite.config.5
	tic -x -o ${DESTDIR}${TERMINFO} termite.terminfo

uninstall:
	rm -f ${DESTDIR}${PREFIX}/bin/termite

clean:
	rm termite

.PHONY: clean install uninstall
