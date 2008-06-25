#include "pos.ch"

/*
 * ----------------------------------------------------------------
 *                                     Copyright Sigma-com software 
 * ----------------------------------------------------------------
 */
 

/*! \fn MMenuAdmin()
*   \brief Glavni meni nivoa administrator
*   \param gVrstaRS=="S"
*   \param gVSmjene=="D"
*/

function MMenuAdmin()
*{

local nSetPosPM
private opc := {}
private opcexe:={}
private Izbor:=1

ImportDSql()

AADD(opc, "1. izvjestaji                       ")
AADD(opcexe, {|| Izvj() })
AADD(opc, "2. pregled racuna")   
AADD(opcexe, {|| PromjeniID() })
AADD(opc, "L. lista azuriranih dokumenata")
AADD(opcexe, {|| PrepisDok()})
AADD(opc, "R. robno-materijalno poslovanje")
AADD(opcexe, {|| MenuRobMat() })
AADD(opc, "V. evidencija prometa po vrstama")
AADD(opcexe, {|| FrmPromVp()})    
AADD(opc, "K. prenos realizacije u KALK")
AADD(opcexe, {|| Real2Kalk() })
if IsPlanika()
	AADD(opc, "O. prenos reklamacija u KALK")
	AADD(opcexe, {|| Rek2Kalk() })
endif
AADD(opc, "S. sifrarnici                  ")
AADD(opcexe, {|| MenuSifre() })
AADD(opc, "P. prenos POS <-> POS")
AADD(opcexe, {|| PosDiskete() })
AADD(opc, "A. administracija pos-a")
AADD(opcexe, {|| MenuAdmin() })

if gVSmjene=="D"
	AADD(opc, "Z. zakljuci radnika")
	AADD(opcexe, {|| Zakljuci() })
	AADD(opc, "O. otvori narednu smjenu")
	AADD(opcexe, {|| OdrediSmjenu() })
endif

if gVrstaRS == "S"
	AADD(opc, "X. preuzmi podatke sa kasa")
	AADD(opcexe, {|| PrebSaKase() })
	AADD(opc, "Y. ponovo prenesi sa kasa ")
	AADD(opcexe, {|| PobPaPren() })
endif

if IsPlanika()
	AADD(opc, "M. poruke")
	AADD(opcexe, {|| Mnu_Poruke()})
endif

if IsPlNS()
	if gFissta=="D"
		AADD(opc, "F. fiskalni stampac")
		AADD(opcexe, {|| Fissta_mnu()})
	endif
	AADD(opc, "U. trgovacka knjiga")
	AADD(opcexe, {|| mnu_tk()})
endif

Menu_SC("adm")
*}


/*! \fn SetPM(nPosSetPM)
 *  \brief Postavlja oznaku prodajnog mjesta
 *  \param cPosSetPM
 *  \result Vraca ID prodajnog mjesta
 */

function SetPM(nPosSetPM)
*{

local nLen

if gIdPos=="X "
	gIdPos:=gPrevIdPos
else
        gPrevIdPos:=gIdPos
        gIdPos:="X "
endif
nLen:=LEN(opc[nPosSetPM])
opc[nPosSetPM]:=Left(opc[nPosSetPM],nLen-2)+gIdPos
PrikStatus()
return
*}



/*! \fn MenuAdmin()
 *   \brief Menij administrativnih funkcija
 *   \param gSQL=="D"
 *   \param gPosModem=="D"
 */

function MenuAdmin()
*{

private opc:={}
private opcexe:={}
private Izbor:=1


AADD(opc,"1. parametri rada programa                        ")
AADD(opcexe, {|| Parametri() })

AADD(opc,"2. instalacija db-a")
AADD(opcexe,{|| goModul:oDatabase:install()})

AADD(opc, "3. generisi doks iz POS ")    
AADD(opcexe, {|| GenDoks() })

AADD(opc, "4. brisi duple sifre")
AADD(opcexe, {|| BrisiDupleSifre()})

AADD(opc, "5. uzmi BARKOD iz sezone ")
AADD(opcexe, {|| UzmiBkIzSez()})

AADD(opc, "6. set pdv cijene na osnovu tarifa iz sezone ")
AADD(opcexe, {|| SetPdvCijene()})

if gStolovi == "D"
	AADD(opc, "7. zakljucivanje postojecih racuna ")
	AADD(opcexe, {|| zak_sve_stolove()})
endif

if gSQL=="D"
	AADD(opc,"Q. sql logovi")
        AADD(opcexe,{|| MenuSQLLogs() })
endif
if gPosModem=="D"
    	AADD(opc,"D. dialup/modem")
	AADD(opcexe, {|| MenuModem() })
endif


if KLevel<L_UPRAVN
	AADD(opc,"T. programiranje tastature ")
	AADD(opcexe,{|| ProgKeyboard() } )
endif

if gSQL=="D"
	AADD(opc,"#. bug - zakrpe")
	AADD(opcexe, {|| Zakrpe() })
	AADD(opc,"I. INTEG testovi")
	AADD(opcexe, {|| Mnu_Integ() })
endif

if (KLevel<L_UPRAVN)
	AADD(opc, "---------------------------")
	AADD(opcexe, nil)
	AADD(opc, "P. prodajno mjesto: "+gIdPos)
	nPosSetPM:=LEN(opc)
	AADD(opcexe, { || SetPm (nPosSetPM) })
endif

AADD(opc, "T. testcase OID ")
AADD(opcexe, { || PlFlexTCases() })

Menu_SC("aadm")
return .f.
*}

