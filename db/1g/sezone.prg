#include "\dev\fmk\pos\pos.ch"

/*
 * ----------------------------------------------------------------
 *                                     Copyright Sigma-com software 
 * ----------------------------------------------------------------
 */

// files kumulativ - tops/kum1
function a_fi_kum()
aFiles = {}
AADD(aFiles, "POS.DBF")
AADD(aFiles, "POS.CDX")

AADD(aFiles, "DOKS.DBF")
AADD(aFiles, "DOKS.CDX")

AADD(aFiles, "PROMVP.DBF")
AADD(aFiles, "PROMVP.CDX")

AADD(aFiles, "MESSAGE.DBF")
AADD(aFiles, "PROMVP.CDX")
return aFiles

// files kum1/sql
function a_fi_kum_sql()
aFiles = {}
AADD(aFiles, "POS.DBF")
return aFiles

// files privatni tops/11
function a_fi_priv()
aFiles = {}
AADD(aFiles, "GPARAMS.DBF")
AADD(aFiles, "GPARAMS.CDX")

AADD(aFiles, "K2C.DBF")
AADD(aFiles, "K2C.CDX")

AADD(aFiles, "MJTRUR.DBF")
AADD(aFiles, "MJTRUR.CDX")

AADD(aFiles, "_POS.DBF")
AADD(aFiles, "_POS.CDX")


AADD(aFiles, "_PRIPR.DBF")
AADD(aFiles, "_PRIPR.CDX")

return aFiles

// files tops/sif
function a_fi_sif()
aFiles = {}
AADD(aFiles, "ROBA.DBF")
AADD(aFiles, "ROBA.CDX")

AADD(aFiles, "SAST.DBF")
AADD(aFiles, "SAST.CDX")

AADD(aFiles, "SIFK.DBF")
AADD(aFiles, "SIFK.CDX")

AADD(aFiles, "SIFV.DBF")
AADD(aFiles, "SIFV.CDX")

AADD(aFiles, "TARIFA.DBF")
AADD(aFiles, "TARIFA.CDX")

AADD(aFiles, "STRAD.DBF")
AADD(aFiles, "STRAD.CDX")

AADD(aFiles, "OSOB.DBF")
AADD(aFiles, "OSOB.CDX")

AADD(aFiles, "KASE.DBF")
AADD(aFiles, "KASE.CDX")

AADD(aFiles, "ODJ.DBF")
AADD(aFiles, "ODJ.CDX")

AADD(aFiles, "RNGOST.DBF")
AADD(aFiles, "RNGOST.CDX")

AADD(aFiles, "VALUTE.DBF")
AADD(aFiles, "VALUTE.CDX")

AADD(aFiles, "VRSTEP.DBF")
AADD(aFiles, "VRSTEP.CDX")

return aFiles

// hajmo_ispocetka: ng_pocetak
// 
function ng_pocetak(cSezona)

// sve tabele moraju biti zatvorene
close all

copy_2_sezona(cSezona)

// provjeri integritet podataka izmedju RADP i cSezona
integ_sez_tek_godina()

zap_all_promet()

END PRINT
return



//zapuj sav promet
function zap_all_promet()

brisi_rupe()

// zapuj pos
OX_POS
zap

// zapuj doks
OX_DOKS
zap

OX_ROBA
_dbpack()

return


function brisi_rupe()

MsgO("Brisem prazne sifre: ROBA")
O_ROBA
SET ORDER TO 0
go TOP
do while !eof()
   if empty(id) .and. empty(naz)
	DELETE
   endif
enddo

close all
return


// copy sve u sezonske direktorije
function copy_2_sezona(cSezona)

START PRINT CRET

// pripremi sezonski direktorij
if !cre_sez_dirs(cSezona)  
  MessageBeep("Sezonski direktoriji se ne mogu formirati !?")
  END PRINT
endif


goModul:oDatabase:cRadimUSezona:="RADP"
goModul:oDatabase:radiUSezonskomPodrucju() 

MsgBeep(KUMPATH + "##" + PRIVPATH + "##" + SIFPATH)

// kreiram sezonske direktorije
cre_sez_dirs(cSezona)

// kopiramo fajlove iz RADP u sezon dir
cp_sif(cSezona)
cp_kum(cSezona)
cp_kum_sql(cSezona)
cp_priv(cSezona)



return


// napravi sezonske direktorije
function cre_sez_dirs(cSezona)

lOk := cre_ren_if_exist(KUMPATH, cSezona)
lOk := lOk .and. cre_ren_if_exist(PRIVPATH, cSezona)
lOK := lOk .and. cre_ren_if_exist(SIFPATH, cSezona)
lOk := lOK .and. cre_ren_if_exist(KUMPATH + "\SQL", cSezona)

return lOk


// npr rename_if_exist( 'c:\tops\kum1\', '2005')
// napravi c:\tops\kum1\2005.1
static function cre_ren_exist(cDir, cPodDir)

if FILE(cDir + cPodDir)

 // ako postoji /2005 i /2005.1, i /2005.2 on ce /2005 preimenovati u /2005.3
 for i:=1 to 50
   cAlter = ALLTRIM(STR(i, 5, 0))
   if !FILE(cDir + cPodDir + "." +  cAlter)
      FRENAME( cDir + cPodDir, cDir + cPodDir + "." + cAlter )
      exit
   endif
 next
 if (i == 50)
   ? "error: Nesto nije u redu  zar postoji 50 poddira od " + cDir + cPodDir + " ?!"
 endif

endif

DirMake(cDir + cPodDir)

if FILE(cDir + cPodDir)
  ? "Sezonski direktorij kreiran :" + cDir + cPodDir
  return .t.
else
  return .f.
endif



// kumulativ
// tops\KUM1
function cp_kum(cSezona)

aFiles := a_fi_kum()

for i:=1 to len(aFiles)
  cp_file(KUMPATH + aFiles[i], KUMPATH + cSezona + "\" + aFiles[i] )
next

return

// privatni
// tops\11
function cp_priv()

aFiles := a_fi_priv()

for i:=1 to len(aFiles)
  cp_file(PRIVPATH + aFiles[i], PRIVPATH + cSezona + "\" + aFiles[i] )
next

return

// sifrarnici
// tops\SIF\
function cp_sif()

aFiles := a_fi_sif()

for i:=1 to len(aFiles)
  cp_file(SIFPATH + aFiles[i], SIFPATH + cSezona + "\" + aFiles[i] )
next

return

// sql parametri
// tops\KUM1\SQL
function cp_kum_sql()
aFiles := a_fi_kum_sql()
for i:=1 to len(aFiles)
  cp_file(KUMPATH + "SQL\" + aFiles[i], KUMPATH +  "SQL\" + cSezona + "\" + aFiles[i] )
next
return 


function cp_file(cOld, cNew)
? DATE(), TIME(), ": cp_file:" , cOld, "->", cNew
MsgO( "cp_file:" + cOld + "->" + cNew )
FCOPY(cOld, cNew)
MsgC()
return
