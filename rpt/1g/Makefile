VERZIJA=CDX
MODUL=pos_1rpt

include /cl/sigma/Makefile_clipper

SRCDOSROOT=h:\\cl\\sigma\\fmk\\pos\\rpt\\1g\\


PRGS=rpt_dkum.prg rpt_kart.prg rpt_ldok.prg rpt_part.prg rpt_por.prg rpt_pvpl.prg rpt_rkas.prg rpt_rodj.prg rpt_rrad.prg rpt_stan.prg rpt_stpm.prg rpt_top.prg mnu_real.prg mnu_izvj.prg 
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
	rm -f *.OBJ *.obj
	rm -f xref_files
	rm -f $(OBJS) *.bak *.BAK


