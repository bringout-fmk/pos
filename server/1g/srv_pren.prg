#include "\cl\sigma\fmk\pos\pos.ch"
#include "directry.ch"

/*
 * ----------------------------------------------------------------
 *                                     Copyright Sigma-com software 
 * ----------------------------------------------------------------
 * $Source: c:/cvsroot/cl/sigma/fmk/pos/server/1g/srv_pren.prg,v $
 * $Author: mirsad $ 
 * $Revision: 1.5 $
 * $Log: srv_pren.prg,v $
 * Revision 1.5  2002/11/21 13:26:49  mirsad
 * ispravka bug-a: ukinuli rad tijela f-je PrebNaServer()
 *
 * Revision 1.4  2002/07/06 11:06:42  ernad
 *
 *
 * gVrstaRs="S" debug, dodan opcija u meni "osvjezi sifrarnik robe iz fmk"
 *
 * Revision 1.3  2002/06/30 20:28:44  ernad
 *
 *
 *
 * pos meni za odabir firme /MNU_INI
 *
 * Revision 1.2  2002/06/17 07:56:45  sasa
 * no message
 *
 *
 */
 
/*! \fn PrebNaServer()
 *  \brief Prebacivanje kumulativnih datoteka na server
 */
 
function PrebNaServer()
*{
private gServKumPath
private cServPath
private lProso    

//ovo izbacujemo .... (koristio samo h.metalurg)
return

if (gVrstaRs=="S")
	return 0
endif

CLOSE ALL

MsgO("Prebacujem promet ... Sacekajte trenutak!",10)

// jesmo li na mrezi ili nismo
SAVE SCREEN TO cScr
CLS
// osvjezi mapiranje mreze - servera!!!!!!!!!
run logser.bat           
restore screen from cScr

/*
if FILE(gServerPath+"KORISN.DBF")
	SELECT 107
	USE (gServerPath+"KORISN") ALIAS KORISN_S
  	GO TOP
  	lProso:=.t.
  	// imam uvijek samo jedan slog u KORISN dbf-ovima
  	cServPath:=ALLTRIM(KORISN_S->DirRad)
  	cServPath:=RIGHT(cServPath, LEN (cServPath)-RAT (SLASH, cServPath))
  	gServKumPath:=gServerPath + cServPath + SLASH
  	SELECT 107
	USE
else
	MsgBeep("Server trenutno nije dostupan!!!#Prebacivanje nije moguce!!!")
  	MsgC()
  	CLOSERET
endif
*/

O_POS_S
O_POS
SELECT POS
//"3", prebacen
SET ORDER TO 3
SEEK OBR_NIJE
do while (!EOF() .and. field->prebacen==OBR_NIJE)
	Scatter()
	SELECT POS_S
	//ako se prebacivanje vrsi dva ili vise puta, da ne udupla zapise
	HSEEK _IdPos+_IdVd+dtos(_datum)+_BrDok+_IdRoba+_IdCijena
	if !FOUND()
		APPEND BLANK
	endif
	Gather()
	SELECT POS
	SKIP 1
	nTRec:=recno()
	SKIP -1 // radi indexa
	REPLACE Prebacen WITH OBR_JEST
	go nTrec
end
CLOSE ALL

O_DOKS_S
O_DOKS
SELECT DOKS
set order to 5         
// tag je na  prebacen
SEEK OBR_NIJE
do while (!EOF() .and. field->prebacen==OBR_NIJE)
	Scatter()
	SELECT DOKS_S
	HSEEK _IdPos+_IdVd+dtos(_datum)+_BrDok
	if !Found()
		APPEND BLANK
	endif
	Gather()
	SELECT DOKS
	SKIP 1
	nTRec:=recno()
	SKIP -1
	REPLACE Prebacen WITH OBR_JEST
	go nTrec
end
CLOSE ALL

MsgC()

CLOSERET
return
*}


/*! \fn PrebSaKase()
 *  \brief Prebacivanje kumulativnih datoteka sa kase. Pokrece se sa servera.
 */
 
function PrebSaKase()
*{
local cKumPath
local SaveServerPath:=gServerPath

gServerPath:=PRIVPATH

CLOSE ALL

if !empty(gFmksif)
	if Pitanje(,"Azurirati nove sifre iz FMK -> POS ?","N")=="D"
		AzurSifIzFmk()
	endif
endif

cKumPath:=UPPER(KUMPATH)
AddBs(@cKumPath)

O_KASE
GO TOP
do while !eof()
	//ovo nije pPath, nego Kumpath, ali je greskom uvedeno to polje
	gKasaPath:=ALLTRIM(kase->pPath)
  	AddBs(@gKasaPath)
	
	altd()
	if (UPPER(gKasaPath)==cKumPath)
		// ne moze se promet prenositi u samog sebe !
		// kum1 -> kum1
		SKIP
		loop
	endif

  	if (!IsDoksExist(gKasaPath))
		SKIP
		loop
	endif
  	
    	Beep(1)
  	
	PrenosPos()
	PrenosDoks()
	
  	SELECT KASE
  	SKIP
enddo
gServerPath:=SaveServerPath
CLOSERET
*}

static function IsDoksExist(gKasaPath)
*{
local nHPom

nHPom:=FOPEN(gKasaPath+"DOKS.DBF") 
FCLOSE(nHPom)
if (nHpom==-1)
	Beep(4)
	Msg("Kasa "+kase->naz+" nije trenutno dostupna",20)
	return .f.
endif
return .t.
*}

static function PrenosPos()
*{
MsgO("Prenos  POS sa Kase "+kase->naz)
O_POS
O_POS_K
SET ORDER TO TAG "3"
SEEK OBR_NIJE
// nije obradjen
do while (!EOF() .and. field->prebacen==OBR_NIJE) 
	Scatter()
	SELECT POS
	Append Blank
	Gather()
	SELECT POS_K
	SKIP 1
	nTRec:=recno()
	SKIP -1
	REPLACE Prebacen WITH OBR_JEST
	GO nTRec
enddo
MsgC()

SELECT POS
USE
SELECT POS_K
USE


return
*}

static function PrenosDoks()
*{

MsgO("Prenos DOKS sa Kase "+kase->naz)
O_DOKS
O_DOKS_K
set order to 5
SEEK OBR_NIJE
do while (!eof() .and. field->prebacen==OBR_NIJE)
	Scatter()
	SELECT DOKS
	Append Blank
	Gather()
	SELECT DOKS_K
	SKIP 1
	nTRec:=recno()
	SKIP -1 // radi indexa
	REPLACE Prebacen WITH OBR_JEST
	GO nTRec
enddo
SELECT DOKS
USE
SELECT DOKS_K
USE
MsgC()

return
*}


/*! \fn PobPaPren()
 *  \brief Brise markere na kasama da je prenos izvrsen za dDat
 */
 
function PobPaPren()
*{
local dDat:=date()
local SaveServerPath:=gServerPath

gServerPath:=PRIVPATH

if !empty(gFmksif)
	AzurSifIzFmk()
endif

Box(,2,50)
	@ m_x+1,m_y+2 SAY "Prenos ponoviti za dan: " get dDat
  	read
BoxC()

CLOSE ALL

if Pitanje(,"Sigurno zelite nastaviti ?","N")=="N"
	return
endif

O_POS
//CREATE_INDEX ("4", "dtos(datum)", KUMPATH+"POS")
set order to 4  
seek dtos(dDat)
// brisi za taj datum sa servera
do while !eof() .and. dDat==Datum 
	skip 1
	nTRec:=recno()
	skip -1 // radi indexa
  	delete
   	GO nTRec
enddo
O_DOKS
// CREATE_INDEX ("6", "dtos(datum)", KUMPATH+"DOKS" )
set order to 6  
seek dtos(dDat)
// brisi za taj datum sa servera
do while !eof() .and. dDat==Datum 
	skip 1
	nTRec:=recno()
	skip -1 // radi indexa
   	delete
   	GO nTRec
enddo

O_KASE
GO TOP
do while !eof()
	gKasaPath:=ALLTRIM(KASE->pPath)
  	if Right(gKasaPath, 1) <> SLASH
    		gKasaPath += SLASH
  	endif
  	nHPom:=fOpen(gKasaPath+"DOKS.DBF" ) // kasa je tu
  	fClose(nHPom)
  	if nHpom==-1
    		Beep(4)
    		Msg("Kasa "+kase->naz+" nije trenutno dostupna",20)
    		skip
		loop
  	endif
  	
	Beep(1)
  	MsgO("Prenos sa Kase "+kase->naz)

  	O_POS_K  // pos - kase
  	set order to 4
  	Seek dtos(dDat)
  	do while !eof() .and. dDat==Datum
    		Scatter()
    		SELECT POS
    		Append Blank
    		Gather()
    		SELECT POS_K
    		skip 1
		nTRec:=recno()
		skip -1 // radi indexa
    		REPLACE Prebacen WITH OBR_JEST
    		GO nTRec
  	enddo
  	use

  	O_DOKS_K
  	set order to 6
  	Seek dtos(dDat)
  	while !eof() .and. dDat==Datum
    		Scatter()
    		SELECT DOKS
    		Append Blank
    		Gather()
    		SELECT DOKS_K
    		skip 1
		nTRec:=recno()
		skip -1 // radi indexa
    		REPLACE Prebacen WITH OBR_JEST
    		GO nTRec
  	enddo
  	use

  	MsgC()

  	SELECT KASE
  	skip
enddo
gServerPath:=SaveServerPath
CLOSERET
*}


/*! \fn AzurSifIzFmk()
 *  \brief
 */
function AzurSifIzFmk()
*{
local cDir

MsgO("Sifranik FMK -> POS")

cDir:=trim(gFmkSif)
AddBs(@cDir)
use (cDir+"ROBA") alias ROBAFMK new
O_ROBA
select ROBAFMK
go top
do while !eof()
	select roba
  	seek robafmk->id
  	if !found()
   		append blank
   		replace id with robafmk->id
  	endif

  	replace naz with robafmk->naz, idtarifa with robafmk->idtarifa, cijena1 with robafmk->mpc,jmj with robafmk->jmj

        if roba->(fieldpos("K1"))<>0  .and. robafmk->(fieldpos("K1"))<>0
        	replace K1 with robafmk->k1, K2 with robafmk->k2
        endif

        if roba->(fieldpos("K7"))<>0  .and. robafmk->(fieldpos("K7"))<>0
        	replace K7 with robafmk->k7, K8 with robafmk->k8, k9 with robafmk->k9
        endif

        if roba->(fieldpos("BARKOD"))<>0 .and. robafmk->(fieldpos("BARKOD"))<>0
        	replace BARKOD with robafmk->BARKOD
        endif

        if roba->(fieldpos("N1"))<>0 .and. robafmk->(fieldpos("N1"))<>0
        	replace N1 with robafmk->N1, N2 with robafmk->N2
        endif

  	select robafmk
  	skip
enddo

select robafmk
use
select roba
use

MsgC()
return
*}
