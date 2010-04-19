#include "pos.ch"
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
local cDir
local nMPC1
local nMPC2

if (lAddNewCode == NIL)
	lAddNewCode:=.t.
endif
if (cSite == NIL)
	cSite:=""
endif

Box(,5,60)
	
	nMPC1 := 1
	nMPC2 := 3

	@ m_x + 1, m_y + 2 SAY "setovanje cijena ****"
	
	@ m_x + 3, m_y + 2 SAY "Cijena 1 iz MPC" GET nMPC1 
	@ m_x + 4, m_y + 2 SAY "Cijena 2 iz MPC" GET nMPC2
	
	read
BoxC()


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

if !gAppSrv
	Box(,2,70)
	@ 1+m_x, 2+m_y SAY "Scan FMKROBA u toku..."
endif

do while !eof()
	select roba
	go top
  	seek robafmk->id
	@ 2+m_x, 2+m_y SAY "Dodajem artikal " + ALLTRIM(robafmk->id)
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
	
	// koju cijenu1 ubaciti ?
	if nMPC1 = 1 
		SmReplace("cijena1", robafmk->mpc, .t.)
	elseif nMPC1 = 2
		SmReplace("cijena1", robafmk->mpc2, .t.)
	elseif nMPC1 = 3
		SmReplace("cijena1", robafmk->mpc3, .t.)
	else
		SmReplace("cijena1", robafmk->mpc, .t.)
	endif
	
	// koju cijenu2 ubaciti ?
	if nMPC2 = 1
		SmReplace("cijena2", robafmk->mpc, .t.)
	elseif nMPC2 = 2
		SmReplace("cijena2", robafmk->mpc2, .t.)
	elseif nMPC2 = 3
		SmReplace("cijena2", robafmk->mpc3, .t.)
	else
		SmReplace("cijena2", robafmk->mpc, .t.)
	endif
	
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
	BoxC()
endif

if !gAppSrv
	MsgC()
endif

return
*}

