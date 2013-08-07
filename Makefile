#
# Makefile for totd
#
# <$Id: Makefile.in,v 3.43 2005/01/31 11:55:14 dillema Exp $>
#

CC = gcc

# These use the standard autoconf variables, which by default are
# rooted in /usr/local

prefix=/usr/local
exec_prefix=${prefix}

INSTALLDIR = ${exec_prefix}/sbin
INSTALLLIB = ${exec_prefix}/lib
INSTALLMAN = ${prefix}/man
TOT_CONFIG_FILE=${prefix}/etc/totd.conf

INSTALL = /usr/bin/install

CFLAGS  = -g -O2 -DHAVE_CONFIG_H  -Wall -DTOTCONF=\"$(TOT_CONFIG_FILE)\" -DDarwin -DSCOPED_REWRITE -DUSE_INET4 -DUSE_INET6  $(INCLUDEPATH)

# When debugging is enabled by --enable-malloc-debug flag to the configure
# script, the # substitution will contain the empty string, thus
# enabling the dbmalloc lines.  When the flag is not specified, the
# # will contain the string "#", thus commenting out the lines
# and disabling dbmalloc.

#LIBDEBUG = -ldbmalloc
#DEBUGINCLUDE= -I/usr/local/debug_include
#CFLAGS+= -DDBMALLOC

#LIBSWILL= -L./ -lswill
#SWILLINCLUDE= -I./SWILL-0.1/Include
#CFLAGS+= -DSWILL

# Similar as above for TCP debugging
#CFLAGS+= -DDBTCP

LDFLAGS =  
LDADD =  $(LIBDEBUG) $(LIBSWILL)
CFLAGS +=   $(DEBUGINCLUDE) $(SWILLINCLUDE)

PROG = totd
MAN = totd.8
SRCS =  request.c response.c context.c ne_mesg.c conv_trick.c ev_tcp.c forward.c queue.c \
	read_config.c tcp_request.c tcp_response.c ev_dup.c list.c res_record.c udp_request.c \
	ev_timeout.c udp_response.c ev_signal.c ev_udp_in.c ne_io.c conv_scoped.c conv_stf.c \
	strlcpy.c strlcat.c daemon.c inet_aton.c html.c
INCLUDES = config.h macros.h protos.h totd.h tot_constants.h tot_types.h
#INCLUDES+= ./SWILL-0.1/Include/swill.h

OBJS+=$(SRCS:.c=.o)

SRCS+=  ${PROG}.c

all: $(PROG)

${PROG}:	${OBJS} ${INCLUDES} # libswill.a
	        ${CC} ${LDFLAGS} -o ${PROG} ${OBJS} ${LDADD}

libswill.a:	
	-(cd SWILL-0.1/ && ./configure --prefix=/usr/local --enable-ip6 && make static)
	-cp SWILL-0.1/Source/SWILL/libswill.a ./
	-ranlib libswill.a

install: $(PROG)
	$(INSTALL) -c -s -m 0555 -o root -g wheel $(PROG) $(INSTALLDIR)
	$(INSTALL) -c -m 0444 -o root -g wheel $(MAN) $(INSTALLMAN)/man8

lint:
	lint ${SRCS}

depend:
	@(mkdep ${SRCS} || makedepend ${SRCS}) 2>/dev/null

clean:	
	-rm -f core *.core *~ $(PROG) $(OBJS) # libswill.a
#	-(cd SWILL-0.1; make clean)
	

distclean: clean
	rm -f config.cache config.status config.log .depend config.h
	cp Makefile.dummy Makefile

cvs: distclean
	cvs2cl -W 10000 -r -t -b -P
	cvs commit -m "End of my working day"

