#include "\cl\sigma\fmk\pos\pos.ch"

/*
 * ----------------------------------------------------------------
 *                                     Copyright Sigma-com software 
 * ----------------------------------------------------------------
 * $Source: c:/cvsroot/cl/sigma/fmk/pos/main/1g/mnu_adm.prg,v $
 * $Author: sasavranic $ 
 * $Revision: 1.26 $
 * $Log: mnu_adm.prg,v $
 * Revision 1.26  2004/01/06 13:28:33  sasavranic
 * Menij poruke samo za varijantu planika=D
 *
 * Revision 1.25  2004/01/05 14:19:47  sasavranic
 * Brisane duplih sifara
 *
 * Revision 1.24  2003/10/27 13:01:23  sasavranic
 * Dorade
 *
 * Revision 1.23  2003/07/22 15:08:05  sasa
 * prenos pos<->pos
 *
 * Revision 1.22  2003/06/16 17:30:36  sasa
 * generacija zbirnog racuna
 *
 * Revision 1.21  2003/04/24 14:19:07  mirsad
 * prenos tops->fakt
 *
 * Revision 1.20  2003/04/24 06:59:58  mirsad
 * prenos TOPS->FAKT
 *
 * Revision 1.19  2003/01/29 15:35:03  ernad
 * tigra - PartnSt
 *
 * Revision 1.18  2002/12/27 12:41:44  sasa
 * prebacene opcije za prenos na hh
 *
 * Revision 1.17  2002/12/22 20:41:41  sasa
 * dorade
 *
 * Revision 1.16  2002/11/21 13:24:47  mirsad
 * ispravka bug-a: umjesto ZakljuciRadnika() sada se poziva Zakljuci() za zakljucenje radnika
 *
 * Revision 1.15  2002/07/06 11:06:42  ernad
 *
 *
 * gVrstaRs="S" debug, dodan opcija u meni "osvjezi sifrarnik robe iz fmk"
 *
 * Revision 1.14  2002/07/01 17:49:28  ernad
 *
 *
 * formiranje finalnih build-ova (fin, kalk, fakt, pos) pred teren planika
 *
 * Revision 1.13  2002/06/24 17:04:15  ernad
 *
 *
 * omoguceno da se "restartuje" program .... nakon podesenja sistemskog sata -> oApp:run() ....
 *
 * Revision 1.12  2002/06/24 16:11:53  ernad
 *
 *
 * planika - uvodjenje izvjestaja 98-reklamacija, izvjestaj planika/promet po vrstama placanja, debug
 *
 * Revision 1.11  2002/06/24 10:08:22  ernad
 *
 *
 * ciscenje ...
 *
 * Revision 1.10  2002/06/24 07:01:38  ernad
 *
 *
 * meniji, u oDatabase:scan ubacen GwDiskFree ..., debug...
 *
 * Revision 1.9  2002/06/21 02:28:36  ernad
 * interni sql parser - init, testiranje pos-sql
 *
 * Revision 1.8  2002/06/19 19:46:47  ernad
 *
 *
 * rad u sez.podr., debug., gateway
 *
 * Revision 1.7  2002/06/15 08:35:10  sasa
 * no message
 *
 *
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
AADD(opc,"L. lista azuriranih dokumenata")
AADD(opcexe, {|| PrepisDok()})
AADD(opc, "R. robno-materijalno poslovanje")
AADD(opcexe, {|| MenuRobMat() })
AADD(opc, "V. evidencija prometa po vrstama")
AADD(opcexe, {|| FrmPromVp()})    
AADD(opc, "K. prenos realizacije u KALK")
AADD(opcexe, {|| Real2Kalk() })
if IsTigra()
	AADD(opc, "H. prenos TOPS -> HH")
	AADD(opcexe, {|| MnuPrenosHH()})
	AADD(opc, "F. prenos realizacije u FAKT")
	AADD(opcexe, {|| Real2Fakt() })
	AADD(opc, "G. prenos stanja robe u FAKT")
	AADD(opcexe, {|| Stanje2Fakt() })
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
AADD(opc, "T. postavi datum i vrijeme kase")
AADD(opcexe, {|| PDatMMenu()})

if IsPlanika()
	AADD(opc, "M. poruke")
	AADD(opcexe, {|| Mnu_Poruke()})
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

AADD(opc,"1. parametri rada programa            ")
AADD(opcexe, {|| Parametri() })

AADD(opc,"2. instalacija db-a")
AADD(opcexe,{|| goModul:oDatabase:install()})

AADD(opc, "3. generisi doks iz POS ")    
AADD(opcexe, {|| GenDoks() })

AADD(opc, "4. brisi duple sifre")
AADD(opcexe, {|| BrisiDupleSifre()})

if (gVrstaRs=="S")
	AADD(opc, "S. azuriraj sifrarnik iz fmk")
	AADD(opcexe, {|| AzurSifIzFmk() })
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
endif

if (KLevel<L_UPRAVN)
	AADD(opc, "---------------------------")
	AADD(opcexe, nil)
	AADD(opc, "P. prodajno mjesto: "+gIdPos)
	nPosSetPM:=LEN(opc)
	AADD(opcexe, { || SetPm (nPosSetPM) })
endif

Menu_SC("aadm")
return .f.
*}

