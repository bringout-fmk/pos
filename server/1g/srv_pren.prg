#include "\dev\fmk\pos\pos.ch"
#include "directry.ch"

/*
 * ----------------------------------------------------------------
 *                                     Copyright Sigma-com software 
 * ----------------------------------------------------------------
 */
 
/*! \fn PrebNaServer()
 *  \brief Prebacivanje kumulativnih datoteka na server
 */
 
function PrebNaServer()
*{
return
*}


/*! \fn PrebSaKase()
 *  \brief Prebacivanje kumulativnih datoteka sa kase. Pokrece se sa servera.
 */
 
function PrebSaKase()
*{
return
*}

static function IsDoksExist(gKasaPath)
*{
return .t.
*}

static function PrenosPos()
*{
return
*}

static function PrenosDoks()
*{
return
*}

/*! \fn PobPaPren()
 *  \brief Brise markere na kasama da je prenos izvrsen za dDat
 */
 
function PobPaPren()
*{
return
*}



/*! \fn AzurSifIzFmk(cLocation, lAddNewCode)
 *  \brief Importuje sifranik FMK
 *  \param cLocation - lokacija sifrarnika
 *  \param lAddNewCode - dodaj novu sifru ako je nema
 */
function AzurSifIzFmk(cLocation, lAddNewCode, cSite)
*{
local cDir

if (lAddNewCode == NIL)
	lAddNewCode:=.t.
endif
if (cSite == NIL)
	cSite:=""
endif

if !gAppSrv
	MsgO("Sifranik FMK -> POS")
else
	gSqlSite:=VAL(cSite)
	gSqlUser:=1
	? "Sifranik FMK -> POS"
endif

if (cLocation == NIL) .or. (cLocation == "") 
	cDir:=TRIM(gFmkSif)
else
	cDir:=cLocation
endif

AddBS(@cDir)

use (cDir + "ROBA") alias ROBAFMK new

O_ROBA
select ROBAFMK
go top

do while !eof()
	if gAppSrv
		MsgO("Scan ROBAFMK: " + ALLTRIM(STR(RecCount())) + " - " + ALLTRIM(STR(RecNo())) )
	endif
	select roba
	go top
  	seek robafmk->id
  	if !Found()
   		if lAddNewCode
			append blank
   			Sql_Append()
			SmReplace("id", robafmk->id)
		else
			select robafmk
			skip
			loop
		endif
  	endif
	SmReplace("naz", robafmk->naz, .t.)
	SmReplace("idtarifa", robafmk->idtarifa, .t.)
	SmReplace("cijena1", robafmk->mpc, .t.)
	SmReplace("jmj", robafmk->jmj, .t.)
        if roba->(fieldpos("K1"))<>0  .and. robafmk->(fieldpos("K1"))<>0
        	SmReplace("K1", robafmk->k1, .t.)
		SmReplace("K2", robafmk->k2, .t.)
        endif
        if roba->(fieldpos("K7"))<>0  .and. robafmk->(fieldpos("K7"))<>0
        	SmReplace("K7", robafmk->k7, .t.)
		SmReplace("K8", robafmk->k8, .t.)
		SmReplace("K9", robafmk->k9, .t.)
        endif
        if roba->(fieldpos("BARKOD"))<>0 .and. robafmk->(fieldpos("BARKOD"))<>0
        	SmReplace("BARKOD", robafmk->BARKOD, .t.)
        endif
        if roba->(fieldpos("N1"))<>0 .and. robafmk->(fieldpos("N1"))<>0
        	SmReplace("N1", robafmk->N1, .t.)
		SmReplace("N2", robafmk->N2, .t.)
        endif
  	select robafmk
  	skip
enddo

select robafmk
use
select roba
use

if !gAppSrv
	MsgC()
endif

return
*}

