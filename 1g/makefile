VERZIJA=CDX
MODUL=TOPS

PRGS=/cl/sigma/fmk/pos/main/1g/e.prg
CS=
ASMS=

include /cl/sigma/Makefile_clipper

FMKLIBS=fmk_roba$(LIBEXT) fmk_svi$(LIBEXT) sc1g_arh$(LIBEXT) sc1g_ba$(LIBEXT) sc1g_cui$(LIBEXT) sc1g_db$(LIBEXT) sc1g_os$(LIBEXT) sc1g_ost$(LIBEXT) sc1g_par$(LIBEXT) sc1g_pr$(LIBEXT) sc1g_sif$(LIBEXT) sc1g_sql$(LIBEXT) sc1g_ut$(LIBEXT) sc2g_app$(LIBEXT) sc2g_db$(LIBEXT) sc2g_cui$(LIBEXT) sc1g_key$(LIBEXT) fmk_sec$(LIBEXT) fmk_evn$(LIBEXT) fmk_mes$(LIBEXT) ka_s1pf$(LIBEXT)

MODLIBS=pos_1m$(LIBEXT) pos_2m$(LIBEXT) pos_1db$(LIBEXT) pos_1dok$(LIBEXT) pos_1kal$(LIBEXT) pos_1prn$(LIBEXT) pos_1rd$(LIBEXT) pos_1rf$(LIBEXT) pos_1rpt$(LIBEXT) pos_1sif$(LIBEXT) pos_1sir$(LIBEXT) pos_1smj$(LIBEXT) pos_1sql$(LIBEXT) pos_1srv$(LIBEXT) pos_1ste$(LIBEXT) pos_s1ex$(LIBEXT) pos_s1pf$(LIBEXT) pos_s1tg$(LIBEXT) pos_2db$(LIBEXT) pos_1rbt$(LIBEXT)


#FMKLIBS=$(LIBDIR)sc1g_db$(LIBEXT) $(LIBDIR)sc2g_db$(LIBEXT)

#PREF2=/clip/
PREF2=lib $(LIB_DOS_DEST)
FMKLIBCMD=$(addprefix $(PREF2), $(MODLIBS) $(FMKLIBS))

SVI1A=$(addprefix $(PREF2), $(FMKLIBS) )
POS1A=$(addprefix $(PREF2), $(MODLIBS) )



OBJS=$(OBJPRGS) $(OBJCS) $(OBJASMS)

all:    mod 

MODUL2=HOPS

ifdef CLIP

LIBDIR=/clip/lib/

PREF2=/clip/lib/
FMKLIBCMD=$(addprefix $(PREF2), $(MODLIBS) $(FMKLIBS) )

#FMKLIBCMD=/clip/fmk.a /clip/pos.a
mod: $(OBJS)
	clip --output=e.exe -e  $(CLIPPERFLAGS) /cl/sigma/fmk/pos/main/1g/e.prg  $(FMKLIBCMD)
	cp e.exe $(EXEDEST)/$(MODUL)_clip.exe

else

mod: $(OBJS)
	echo Prilikom kompilacije obj se napravi u tekucem direktoriju
	echo a blinker opet trazi obj fajl u orig direktoriju
	cp e.obj /cl/sigma/fmk/pos/main/1g/
	/cl/sigma/form_blinker_lnk.sh $(LINKCMD)
	/cl/sigma/form_blinker_lnk_2.sh $(FMKLIBCMD)
	$(LINKEREXE) @_bl_.lnk @_bl_2_.lnk $(DEBUGLINK) @H:\\CLIPPER\\$(VERZIJA)\\BL.LNK output e.exe
	cp e.exe $(EXEDEST)/$(MODUL).EXE
	cp e.exe $(EXEDEST)/$(MODUL2).EXE

endif

zip:
	rm -f /z/fmk/$(MODUL).zip
	/cl/sigma/zip.sh z:\\fmk\\$(MODUL).zip ..\\chs\\\*.chs \\cl\\sigma\\fmk\\roba\\\*.chs  $(EXEDOSDEST)\\$(MODUL).EXE 
	rm -f /z/fmk/$(MODUL2).zip
	/cl/sigma/zip.sh z:\\fmk\\$(MODUL2).zip ..\\chs\\\*.chs \\cl\\sigma\\fmk\\roba\\\*.chs  $(EXEDOSDEST)\\$(MODUL2).EXE 



clean:
	rm -f *.obj *.OBJ
	rm -f $(OBJS) I$(MODULH).OBJ *.bak *.BAK


sfx:
	/cygdrive/p/bat/SFXMA.BAT tops
