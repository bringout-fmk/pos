#include "\cl\sigma\fmk\pos\pos.ch"

/*
 * ----------------------------------------------------------------
 *                                     Copyright Sigma-com software 
 * ----------------------------------------------------------------
 * $Source: c:/cvsroot/cl/sigma/fmk/pos/main/1g/mnu_upr.prg,v $
 * $Author: sasavranic $ 
 * $Revision: 1.18 $
 * $Log: mnu_upr.prg,v $
 * Revision 1.18  2004/01/06 13:28:33  sasavranic
 * Menij poruke samo za varijantu planika=D
 *
 * Revision 1.17  2003/10/27 13:01:23  sasavranic
 * Dorade
 *
 * Revision 1.16  2003/06/10 17:35:08  sasa
 * stavljena u funkciju opcija definisanja seta cijena
 *
 * Revision 1.15  2003/04/24 14:19:07  mirsad
 * prenos tops->fakt
 *
 * Revision 1.14  2003/04/24 06:59:58  mirsad
 * prenos TOPS->FAKT
 *
 * Revision 1.13  2003/01/19 23:44:18  ernad
 * test network speed (sa), korekcija bl.lnk
 *
 * Revision 1.12  2003/01/14 17:48:39  ernad
 * tigra primpak
 *
 * Revision 1.11  2002/12/27 12:41:44  sasa
 * prebacene opcije za prenos na hh
 *
 * Revision 1.10  2002/11/21 13:25:10  mirsad
 * ispravka bug-a: umjesto ZakljuciRadnika() sada se poziva Zakljuci() za zakljucenje radnika
 *
 * Revision 1.9  2002/07/01 17:49:28  ernad
 *
 *
 * formiranje finalnih build-ova (fin, kalk, fakt, pos) pred teren planika
 *
 * Revision 1.8  2002/06/26 10:45:35  ernad
 *
 *
 * ciscenja POS, planika - uvodjenje u funkciju IsPlanika funkcije (dodana inicijalizacija
 * varijabli iz FmkSvi u main/2g/app.prg/metod setGvars
 *
 * Revision 1.7  2002/06/24 17:04:15  ernad
 *
 *
 * omoguceno da se "restartuje" program .... nakon podesenja sistemskog sata -> oApp:run() ....
 *
 * Revision 1.6  2002/06/24 16:11:53  ernad
 *
 *
 * planika - uvodjenje izvjestaja 98-reklamacija, izvjestaj planika/promet po vrstama placanja, debug
 *
 * Revision 1.5  2002/06/24 07:01:38  ernad
 *
 *
 * meniji, u oDatabase:scan ubacen GwDiskFree ..., debug...
 *
 * Revision 1.4  2002/06/15 08:35:10  sasa
 * no message
 *
 *
 */
 

/*! \fn MMenuUpravn()
*   \brief Glavni menij nivoa upravnik
*   \param gVrstaRS
*/
function MMenuUpravn()
*{
if gVrstaRS=="A"                          
	MMenuUpA()
elseif gVrstaRS=="K"
	MMenuUpK()
else
	MMenuUpS()
endif
return
*}


/*! \fn MMenuUpA()
*   \brief Glavni menij nivoa upravnika (vrsta kase "A")
*/
function MMenuUpA()
*{

private opc:={}
private opcexe:={}
private Izbor:=1

// Vrsta kase "A" - samostalna kasa

AADD(opc, "1. izvjestaji                        ")
AADD(opcexe, {|| Izvj() })    
AADD(opc,"L. lista azuriranih dokumenata")
AADD(opcexe, {|| PrepisDok()})

AADD(opc, "V. evidencija prometa po vrstama")
AADD(opcexe, {|| FrmPromVp()})    

AADD(opc, "R. prenos realizacije u KALK")
AADD(opcexe, {|| Real2Kalk() })

if IsTigra()
	AADD(opc, "H. prenos tops -> hh partnst")
	AADD(opcexe, {|| MnuPrenosHH()})
	
	AADD(opc, "F. prenos realizacije u FAKT")
	AADD(opcexe, {|| Real2Fakt()})

	AADD(opc, "G. prenos stanja robe u FAKT")
	AADD(opcexe, {|| Stanje2Fakt()})
endif

AADD(opc, "D. unos dokumenata")
AADD(opcexe, {|| MnuDok()})    

AADD(opc, "R. robno-materijalno poslovanje")
AADD(opcexe, {|| MenuRobMat() })

if (gVSmjene=="D")
	AADD(opc, "Z. zakljuci radnika")
	AADD(opcexe, {|| Zakljuci() })
	AADD(opc, "X. otvori narednu smjenu")
	AADD(opcexe, {|| OtvoriSmjenu() })
endif

AADD(opc, "--------------")
AADD(opcexe, nil)
AADD(opc, "S. sifrarnici")
AADD(opcexe, {|| MenuSifre() })
AADD(opc, "W. administracija pos-a")
AADD(opcexe, {|| MenuAdmin() })
AADD(opc, "P. promjena seta cijena")
AADD(opcexe, {|| PromIDCijena()})
AADD(opc, "T. postavi datum i vrijeme kase")
AADD(opcexe, {|| PDatMMenu()})
if IsPlanika()
	AADD(opc, "M. poruke")
	AADD(opcexe, {|| Mnu_Poruke()})
endif
Menu_SC("upra")

closeret
return .f.
*}

function PDatMMenu()
*{
local lPostavljeno

if !SigmaSif("SSAT")
	MsgBeep("&S& pogresna lozinka ! &SAT&")
	return 0
endif
lPostavljeno:=PostaviDat()
if lPostavljeno
	goModul:run()
	return 0
endif
return 0
*}

/*! \fn MMenuUpK()
*   \brief Glavni menij nivoa upravnik (vrsta kase "K")
*/
function MMenuUpK()
*{
private opc:={}
private opcexe:={}
private Izbor:=1

// Vrsta kase "K" - radna stanica

AADD(opc, "1. izvjestaji             ")
AADD(opcexe,{|| Izvj()})
AADD(opc, "2. zakljuci radnika")
AADD(opcexe,{|| Zakljuci()})
AADD(opc, "3. otvori narednu smjenu")
AADD(opcexe,{|| OtvoriSmjenu()})
AADD(opc, "--------------------------")
AADD(opcexe,nil)
AADD(opc, "S. sifrarnici")
AADD(opcexe,{|| MenuSifre()})
AADD(opc, "A. administracija pos-a")
AADD(opcexe, {|| MenuAdmin() })

Menu_SC("uprk")
return .f.
*}



/*! \fn MMenuUpS()
*   \brief Glavni menij nivoa upravnik (vrsta kase "S")
*/
function MMenuUpS()
*{
private opc:={}
private opcexe:={}
private Izbor:=1

// Vrsta kase "S" - server kasa

AADD(opc, "1. izvjestaji             ")
AADD(opcexe,{|| Izvj()})
AADD(opc, "2. unos dokumenata")
AADD(opcexe,{|| MnuDok()})
AADD(opc, "S. sifrarnici")
AADD(opcexe,{|| MenuSifre()})

Menu_SC("uprs")
closeret
return .f.
*}


function MnuDok()
*{
private Izbor
private opc:={}
private opcexe:={}

Izbor:=1

AADD(opc, "Z. zaduzenje                       ")
AADD(opcexe, {|| Zaduzenje() })

if !IsPlanika()
	// planika ne koristi ove stavke
	AADD(opc, "I. inventura")
	AADD(opcexe, {|| InventNivel(.t.) })
	AADD(opc, "N. nivelacija")
	AADD(opcexe, {|| InventNivel(.f.)})
	AADD(opc, "P. predispozicija")
	AADD(opcexe, {|| Zaduzenje("PD") })
endif

if gModul=="HOPS"
	AADD(opc, "O. otpis")
	AADD(opcexe, {|| Zaduzenje(VD_OTP) })
endif
AADD(opc, "R. reklamacija-povrat u magacin")
AADD(opcexe, {|| Zaduzenje(VD_REK) })

Menu_SC("pzdo")
return
*}
