VERZIJA=CDX
MODUL=pos_1dok

include /cl/sigma/Makefile_clipper

SRCDOSROOT=h:\\cl\\sigma\\fmk\\pos\\dok\\1g\\

PRGS=frm_nar.prg frm_rac.prg frm_rrac.prg frm_zad.prg rpt_inni.prg rpt_pocs.prg rpt_raz.prg rpt_rn.prg rpt_treb.prg rpt_zad.prg frm_inni.prg mnu_rac.prg mnu_robm.prg rpt_tar.prg tarifa.prg frm_rdio.prg frm_dok.prg

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

