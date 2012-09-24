
PROGS= aftershow aftershow_pipe

AFTERSHOW_OBJS= aftershow.o xmlutil.o xutil.o

AFTERSHOW_PIPE_OBJS= aftershow_pipe.o xutil.o

CC		= gcc
CCFLAGS         = -O3 -DNO_DEBUG_OUTPUT -fPIC -Wall
# -march=pentiumpro -mcpu=pentiumpro
EXTRA_DEFINES	= 

RANLIB		= ranlib
AR		= ar clq
CP		= /bin/cp
MV		= /bin/mv
RM		= /bin/rm
RMF		= /bin/rm -f
MKDIR		= /bin/mkdir
FIND		= /usr/bin/find
XARGS		= /usr/bin/xargs
LDCONFIG	= ldconfig

INSTALL		= /usr/bin/install -c
INSTALL_PROGRAM	= /usr/bin/install -c -m 755
INSTALL_DATA	= /usr/bin/install -c -m 644

INCS_X		= 
INCS_PRIVATE    = 
INCLUDES	= $(INCS_X) $(INCS_PRIVATE) -I..

USER_LD_FLAGS	= 
LIBS_X		= 
LIBS_XEXTS	=
LIBS_AFTERIMAGE = -L../ -lAfterImage -L/opt/local/lib -lfreetype -lz -lbz2  -lz -lm
LIBRARIES	= $(USER_LD_FLAGS) $(LIBS_AFTERIMAGE) $(LIBS_X) $(LIBS_XEXTS)

prefix          = /usr/local
exec_prefix     = /usr/local
LIBDIR		= $(DESTDIR)/usr/local/lib
BIN_DIR		= $(DESTDIR)${exec_prefix}/bin
MAN_DIR		= $(DESTDIR)/usr/local/man/man1
AFTER_DIR	= @with_afterdir@

# need this for dependancies :
LIBAFTERIMAGE_PATH =..
LIB_STATIC      = $(LIBAFTERIMAGE_PATH)/libAfterImage.a
LIB_SHARED      = $(LIBAFTERIMAGE_PATH)/libAfterImage.so


all:    $(PROGS)

install.bin:	$(PROGS)
		@echo "installing libAfterImage apps using command - "; \
		if [ ! -d $(BIN_DIR) ] ; then 	$(MKDIR) -p $(BIN_DIR); fi; \
		echo "    \"$(INSTALL_PROGRAM) <app> $(BIN_DIR)\" :"; \
		for p in $(PROGS); do \
			echo -n "$$p "; \
	  		$(INSTALL_PROGRAM) $$p $(BIN_DIR); \
		done; \
		echo ""; echo "Done."; \

install.man:
		@if [ ! -d $(MAN_DIR) ] ; then 	$(MKDIR) -p $(MAN_DIR); fi; \
		for f in *.man; do \
		  echo $(INSTALL_DATA) $$f $(MAN_DIR)/`basename $$f`.1x; \
		  $(INSTALL_DATA) $$f $(MAN_DIR)/`basename $$f`.1x; \
		done

uninstall.bin:
		@for p in $(PROGS); do \
			echo "$(RMF) $(BIN_DIR)/$$p"; \
			$(RMF) $(BIN_DIR)/$$p; \
		done

uninstall.man:
		$(RMF) $(AFTER_MAN_DIR)/$(PROGS).1x

clean:
		$(RMF) $(PROGS) *.o *~ *% *.bak \#* core

distclean:
		$(RMF) $(PROGS) *.o *~ *% *.bak \#* *.orig core Makefile

indent:
		@SRCS=`find . -name "*.c"`; \
		if test "x$$SRCS" == "x"; then exit; fi; \
		for i in $$SRCS; do \
		  if (indent -di14 -ts4 -i4 -l100 -lc80 -bad -nbbb -bli0 -c48 -cd48 -ce -cli1 -ncs -nbs -nbbo -hnl < $$i > /tmp/$$i); then \
		    echo "indent $$i"; \
		    mv /tmp/$$i $$i; \
		  fi; \
		done

deps:
		@echo -n > .depend ; \
		buf="" ; \
		for f in `find . -name "*.h"` ; do \
		  if test "x$$buf" != "x"; then \
		      echo $$buf >>.depend ; \
		      echo "" >>.depend ; \
		  fi; \
		  buf="$$f:"; \
		  for d in `grep "#include \"" <$$f | awk -F \" '{print $$2}'`; do \
		      if test "x$$buf" != "x"; then \
		         echo $$buf \\ >>.depend ; \
		      fi; \
		      echo -n "		" >>.depend ; \
		      buf="$$d "; \
		  done; \
		done; \
		if test "x$$buf" != "x"; then \
		  echo $$buf >>.depend ; \
		  buf="" ; \
		  echo "" >>.depend ; \
		fi ; \
		for file in `find . -name "*.c"` ; do \
		  if test "x$$buf" != "x"; then \
		      echo $$buf >>.depend ; \
		      echo >>.depend ; \
		  fi; \
		  buf="."`echo $$file | awk -F . '{print $$2}'`".o:" ; \
		  for d in `grep "#include \"" < $$file | awk -F \" '{print $$2}'`; do \
		      if test "x$$buf" != "x"; then \
		         echo $$buf \\ >>.depend ; \
		      fi; \
		      echo -n "		" >>.depend ; \
		      buf="$$d "; \
		  done; \
		done; \
		if test "x$$buf" != "x"; then \
		  echo $$buf >>.depend ; \
		fi

aftershow: $(AFTERSHOW_OBJS) $(LIB_STATIC)
		$(CC) $(AFTERSHOW_OBJS) $(LIBRARIES) $(EXTRA_LIBRARIES) -o aftershow


aftershow_pipe: $(AFTERSHOW_PIPE_OBJS) $(LIB_STATIC)
		$(CC) $(AFTERSHOW_PIPE_OBJS) $(LIBRARIES) $(EXTRA_LIBRARIES) -o aftershow_pipe


.c.o:
		$(CC) $(CCFLAGS) $(EXTRA_DEFINES) $(INCLUDES) $(EXTRA_INCLUDES) -c $*.c

.c.s:
		$(CC) $(CCFLAGS) $(EXTRA_DEFINES) $(INCLUDES) $(EXTRA_INCLUDES) -S $*.c

.lo:	$*.c


install:	install.bin

uninstall:	uninstall.bin

include .depend


LIBAFTERIMAGE_OBJS = \
		$(LIBAFTERIMAGE_PATH)/asimage.c \
		$(LIBAFTERIMAGE_PATH)/ascmap.c \
		$(LIBAFTERIMAGE_PATH)/asfont.c \
		$(LIBAFTERIMAGE_PATH)/asimagexml.c \
		$(LIBAFTERIMAGE_PATH)/asstorage.c \
		$(LIBAFTERIMAGE_PATH)/asvisual.c \
		$(LIBAFTERIMAGE_PATH)/blender.c \
		$(LIBAFTERIMAGE_PATH)/bmp.c \
		$(LIBAFTERIMAGE_PATH)/char2uni.c \
		$(LIBAFTERIMAGE_PATH)/draw.c \
		$(LIBAFTERIMAGE_PATH)/export.c \
		$(LIBAFTERIMAGE_PATH)/imencdec.c \
		$(LIBAFTERIMAGE_PATH)/import.c \
		$(LIBAFTERIMAGE_PATH)/pixmap.c \
		$(LIBAFTERIMAGE_PATH)/transform.c \
		$(LIBAFTERIMAGE_PATH)/ungif.c \
		$(LIBAFTERIMAGE_PATH)/xcf.c \
		$(LIBAFTERIMAGE_PATH)/ximage.c \
		$(LIBAFTERIMAGE_PATH)/xpm.c

LIBAFTERIMAGE_INCS = \
		$(LIBAFTERIMAGE_PATH)/afterimage.h \
		$(LIBAFTERIMAGE_PATH)/config.h \
		$(LIBAFTERIMAGE_PATH)/afterbase.h \
		$(LIBAFTERIMAGE_PATH)/ascmap.h \
		$(LIBAFTERIMAGE_PATH)/asfont.h \
		$(LIBAFTERIMAGE_PATH)/asim_afterbase.h \
		$(LIBAFTERIMAGE_PATH)/asimage.h \
		$(LIBAFTERIMAGE_PATH)/asimagexml.h \
		$(LIBAFTERIMAGE_PATH)/asstorage.h \
		$(LIBAFTERIMAGE_PATH)/asvisual.h \
		$(LIBAFTERIMAGE_PATH)/blender.h \
		$(LIBAFTERIMAGE_PATH)/bmp.h \
		$(LIBAFTERIMAGE_PATH)/char2uni.h \
		$(LIBAFTERIMAGE_PATH)/draw.h \
		$(LIBAFTERIMAGE_PATH)/export.h \
		$(LIBAFTERIMAGE_PATH)/imencdec.h \
		$(LIBAFTERIMAGE_PATH)/import.h \
		$(LIBAFTERIMAGE_PATH)/pixmap.h \
		$(LIBAFTERIMAGE_PATH)/transform.h \
		$(LIBAFTERIMAGE_PATH)/ungif.h \
		$(LIBAFTERIMAGE_PATH)/xcf.h \
		$(LIBAFTERIMAGE_PATH)/ximage.h \
		$(LIBAFTERIMAGE_PATH)/xpm.h \
		$(LIBAFTERIMAGE_PATH)/xwrap.h

$(LIBAFTERIMAGE_PATH)/libAfterImage.a: $(LIBAFTERIMAGE_OBJS) $(LIBAFTERIMAGE_INCS)
		cd $(LIBAFTERIMAGE_PATH)/; ${MAKE} libAfterImage.a

$(LIBAFTERIMAGE_PATH)/libAfterImage.so: $(LIBAFTERIMAGE_OBJS) $(LIBAFTERIMAGE_INCS)
		cd $(LIBAFTERIMAGE_PATH)/; ${MAKE} libAfterImage.so
