VERZIJA=CDX
MODUL=pos_1m

include /cl/sigma/Makefile_clipper

SRCDOSROOT=h:\\cl\\sigma\\fmk\\pos\\main\\1g\\

PRGS=app_srv.prg dummy.prg mnu_adm.prg mnu_prod.prg mnu_upr.prg params.prg prijava.prg ut.prg zakrpe.prg

CS=
ASMS=

OBJS=$(OBJPRGS) $(OBJCS) $(OBJASMS)

ifdef CLIP

all: $(OBJS)
	clip_makeslib $(MODUL)$(LIBEXT) $(LIBCMD)
	cp $(MODUL).dll* $(LIB_DEST)

else
all: $(OBJS)
	rm -f $(MODUL)$(LIBEXT) 
	$(LIBEXE) $(MODUL)$(LIBEXT) $(LIBCMD) $(LIBSUFFIX)
	cp $(MODUL)$(LIBEXT) $(LIB_DEST)
endif

clean:
	rm -f *~
	rm -f *.xref
	rm -f *.xrefs
	rm -f *.html
	rm -f *.OBJ *.obj *.o
	rm -f xref_files
	rm -f $(OBJS) *.bak *.BAK


