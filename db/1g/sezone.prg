#include "\dev\fmk\pos\pos.ch"

static error_no 

/*
 * ----------------------------------------------------------------
 *                                     Copyright Sigma-com software 
 * ----------------------------------------------------------------
 */

// files kumulativ - tops/kum1
function a_fi_kum()
aFiles = {}
AADD(aFiles, "AKTIVNI.DBF")

AADD(aFiles, "POS.DBF")
AADD(aFiles, "POS.CDX")

AADD(aFiles, "DOKS.DBF")
AADD(aFiles, "DOKS.CDX")

AADD(aFiles, "PROMVP.DBF")
AADD(aFiles, "PROMVP.CDX")


AADD(aFiles, "SECUR.DBF")
AADD(aFiles, "SECUR.CDX")

AADD(aFiles, "MESSAGE.DBF")

AADD(aFiles, "FMK.INI")
return aFiles

// files kum1/sql
function a_fi_kum_sql()
aFiles = {}
AADD(aFiles, "SQLPAR.DBF")
return aFiles

// files privatni tops/11
function a_fi_priv()
aFiles = {}
AADD(aFiles, "GPARAMS.DBF")
AADD(aFiles, "GPARAMS.CDX")

AADD(aFiles, "PARAMS.DBF")
AADD(aFiles, "PARAMS.CDX")


AADD(aFiles, "K2C.DBF")
AADD(aFiles, "K2C.CDX")

AADD(aFiles, "MJTRUR.DBF")
AADD(aFiles, "MJTRUR.CDX")

AADD(aFiles, "_POS.DBF")
AADD(aFiles, "_POS.CDX")


AADD(aFiles, "_PRIPR.DBF")
AADD(aFiles, "_PRIPR.CDX")

AADD(aFiles, "FMK.INI")
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

AADD(aFiles, "SIROV.DBF")
AADD(aFiles, "SIROV.CDX")

AADD(aFiles, "OSOB.DBF")
AADD(aFiles, "OSOB.CDX")

AADD(aFiles, "KASE.DBF")
AADD(aFiles, "KASE.CDX")

AADD(aFiles, "DIO.DBF")
AADD(aFiles, "DIO.CDX")

AADD(aFiles, "UREDJ.DBF")
AADD(aFiles, "UREDJ.CDX")

AADD(aFiles, "ODJ.DBF")
AADD(aFiles, "ODJ.CDX")

AADD(aFiles, "RNGOST.DBF")
AADD(aFiles, "RNGOST.CDX")

AADD(aFiles, "VALUTE.DBF")
AADD(aFiles, "VALUTE.CDX")

AADD(aFiles, "VRSTEP.DBF")
AADD(aFiles, "VRSTEP.CDX")

AADD(aFiles, "FMK.INI")
return aFiles


// poziva se iz glavnog menija
function PPrenosPos()
local dLastDokDatum
local dCurDate

error_no := 0

// prenos se ne radi ako nije radno podrucje

if goModul:oDatabase:cRadimUSezona <> "RADP"
	return .t.
endif

dCurDate := DATE()
if MONTH(dCurDate) > 1 
 // ovo se radi u januaru
 return
endif 

close all
O_DOKS
//TAG "6" : "dtos(datum)", KUMPATH+"DOKS" 
SET ORDER TO TAG "6"

GO BOTTOM
dLastDokDatum := doks->datum

// baza je prazna
if EMPTY(dLastDokDatum)
  return .t.
endif

if  ( YEAR(dLastDokDatum) < YEAR(dCurDate)  )
  lSplit := .t.
else
  lSplit := .f.
endif

close

if !lSplit
  return .t.
endif

if KLevel == nil
  KLevel := "3"
endif

if (KLevel > L_UPRAVN) .or. (Pitanje(nil, "Nova je godina: " + DTOC(dCurDate) + " , izvrsiti razdvajanje sezona ?", "N") == "N")
	MsgBeep("Tekuci datum je : " + DTOC(dCurDate) + "##" + ;
                "Posljednji dokument ima datum : " + DTOC(dLastDokDatum) + ;
                "## zbog toka ne mozete nastaviti rad. ## bye bye ...")
    if (KLevel <= L_ADMIN)
      	// administrator moze uci u kasu
      	lSplit := .f.
    else
    	return .f.
    endif
endif

if lSplit
 // 01.01.2006 => cSezona = "2005"
 if !ng_pocetak(STR( YEAR(DATE()) - 1 , 4))
	return .f.
 endif
endif

return .t.

// hajmo_ispocetka: ng_pocetak
// 
function ng_pocetak(cSezona)
// sve tabele moraju biti zatvorene
close all

START PRINT CRET
if !copy_2_sezona(cSezona)
        ? "ERROR : copy_2_sezona :"+ cSezona + " neuspješno zavrseno !!!"
        ++ error_no
	END PRINT
	MsgBeep("broj gresaka: " + STR(error_no, 5, 0))
	return .f.
endif

// provjeri integritet podataka izmedju RADP i cSezona
if integ_sez_radp(cSezona)
   // ako su u sezonskom podrucju podaci isti kao u radnom
   zap_all_promet(cSezona)
endif

goModul:oDatabase:saveSezona(cSezona)

goModul:oDatabase:cRadimUSezona:="RADP"
goModul:oDatabase:saveRadimUSezona("RADP")
? DATE(), TIME(), "Setujem goModul:oDatabase:saveSezona", cSezona 
? DATE(), TIME(), "Setujem goModul:oDatabase:saveRadimUSezona :", "RADP"
END PRINT

if error_no > 0
  MsgBeep("broj gresaka: " + STR(error_no, 5, 0))
endif

return .t.

function integ_sez_radp(cSezona)
local lRet

altd()
// provjeri doks
lRet := integ_doks(cSezona)
if lRet == .f.
	return lRet
endif
// provjeri pos
lRet := integ_pos(cSezona)
if lRet == .f.
	return lRet
endif
// provjeri roba
lRet := integ_roba(cSezona)
if lRet == .f.
	return lRet
endif

return .t.


function integ_doks(cSezona)
*{
local nSezRec
local nRpRec

O_DOKS
// uzmi tekuci podatak
nRpRec:=RecCount()

select (0)
use (KUMPATH+cSezona+SLASH+"DOKS") alias DOKSSZ
// uzmi podatak iz sezone
nSezRec:=RecCount()

close all

if nRpRec <> nSezRec
	MsgBeep("Checksum tabela DOKS nije ok!")
	return .f.
endif

return .t.
*}

function integ_pos(cSezona)
*{
local nSezRec
local nRpRec

O_POS
// uzmi tekuci podatak
nRpRec:=RecCount()
select (0)
use (KUMPATH+cSezona+SLASH+"POS") alias POSSZ
// uzmi podatak iz sezone
nSezRec:=RecCount()

close all

if nRpRec <> nSezRec
	MsgBeep("Checksum tabela POS nije ok!")
	return .f.
endif

return .t.
*}

function integ_roba(cSezona)
*{
local nSezRec
local nRpRec

O_ROBA
// uzmi tekuci podatak
nRpRec:=RecCount()

select (0)
use (SIFPATH+cSezona+SLASH+"ROBA") alias ROBASZ
// uzmi podatak iz sezone
nSezRec:=RecCount()

close all

if nRpRec <> nSezRec
	MsgBeep("Checksum tabela ROBA nije ok!")
	return .f.
endif

return .t.
*}

//zapuj sav promet
function zap_all_promet(cSezona)
brisi_rupe_pdv17(cSezona)
// zapuj pos
OX_POS
zap
// zapuj doks
OX_DOKS
zap
// pakuj robu
OX_ROBA
__dbpack()
return


function brisi_rupe_pdv17(cSezona)
MsgO("Brisem prazne sifre: ROBA")
O_ROBA
SET ORDER TO 0
go TOP
do while !eof()
   if empty(id) .and. empty(naz)
	DELETE
   endif
   if gPDV == "N" .and. cSezona == "2005"
   	// prelazak na PDV 01.01.2006
	replace IDTARIFA with "PDV17"
   endif
   
   SKIP
enddo
MsgC()

// stavi u RADP PDV17 tarifu
if gPDV == "N" .and. cSezona == "2005"
O_TARIFA
set order to tag "ID"
seek "PDV17"
if !found()
	APPEND BLANK
	replace id with "PDV17",;
	    opp with 17
endif		
endif

close all
return


// copy sve u sezonske direktorije
function copy_2_sezona(cSezona)

// pripremi sezonski direktorij
if !cre_sez_dirs(cSezona)  
  MsgBeep("Sezonski direktoriji se ne mogu formirati !?")
  return .f.
endif


goModul:oDatabase:cRadimUSezona:="RADP"
goModul:oDatabase:radiUSezonskomPodrucju() 

//MsgBeep(KUMPATH + "##" + PRIVPATH + "##" + SIFPATH)

// kreiram sezonske direktorije
cre_sez_dirs(cSezona)

// kopiramo fajlove iz RADP u sezon dir
cp_sif(cSezona)
cp_kum(cSezona)
cp_kum_sql(cSezona)
cp_priv(cSezona)



return .t.


// napravi sezonske direktorije
function cre_sez_dirs(cSezona)

lOk := cre_ren_dir(KUMPATH, cSezona)
lOk := lOk .and. cre_ren_dir(PRIVPATH, cSezona)
lOK := lOk .and. cre_ren_dir(SIFPATH, cSezona)
// kreiraj i tops/kum1/2005/sql
lOk := lOK .and. cre_ren_dir(KUMPATH + cSezona + "\", "SQL")

return lOk


// npr rename_if_exist( 'c:\tops\kum1\', '2005')
// napravi c:\tops\kum1\2005.1
static function cre_ren_dir(cDir, cPodDir)

if PostDir(cDir + cPodDir)

 // ako postoji /2005 i /2005.1, i /2005.2 on ce /2005 preimenovati u /2005.3
 for i:=1 to 50
   cAlter = ALLTRIM(STR(i, 5, 0))
   if !PostDir(cDir + cPodDir + "_" +  cAlter)
      FRENAME( cDir + cPodDir, cDir + cPodDir + "_" + cAlter )
      exit
   endif
 next
 if (i == 50)
   ? DATE(), TIME(), "error: Nesto nije u redu  zar postoji 50 poddira od " + cDir + cPodDir + " ?!"
 endif

endif

DirMake(cDir + cPodDir)

if PostDir(cDir + cPodDir)
  ?  DATE(), TIME(), "Sezonski direktorij kreiran :" + cDir + cPodDir
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
function cp_priv(cSezona)

aFiles := a_fi_priv()

for i:=1 to len(aFiles)
  cp_file(PRIVPATH + aFiles[i], PRIVPATH + cSezona + "\" + aFiles[i] )
next

return

// sifrarnici
// tops\SIF\
function cp_sif(cSezona)

aFiles := a_fi_sif()

for i:=1 to len(aFiles)
  cp_file(SIFPATH + aFiles[i], SIFPATH + cSezona + "\" + aFiles[i] )
next

return

// sql parametri
// tops\KUM1\SQL
function cp_kum_sql(cSezona)
aFiles := a_fi_kum_sql()
for i:=1 to len(aFiles)
  cp_file(KUMPATH + "SQL\" + aFiles[i], KUMPATH +  + cSezona + "\SQL\" + aFiles[i] )
next
return 


function cp_file(cOld, cNew)
local objLocal, bLastHandler

? DATE(), TIME(), ": cp_file:" , cOld, "->", cNew
MsgO( "cp_file:" + cOld + "->" + cNew )

bLastHandler := ERRORBLOCK( {|objErr| MyHandler(objErr, .t.)})
BEGIN SEQUENCE
  COPY FILE (cOld) TO (cNew)
RECOVER USING objLocal
  ? "Error cp_file: ", cOld, " -> ", cNew
  ++ error_no
END SEQUENCE

MsgC()

ErrorBlock(bLastHandler)
return


static function  MyHandler( objError, lLocalHandler)

if lLocalHandler
  BREAK objError
endif


return nil

