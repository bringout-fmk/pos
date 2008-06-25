#include "pos.ch"

/*
 * ----------------------------------------------------------------
 *                                     Copyright Sigma-com software 
 * ----------------------------------------------------------------
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

if IsPlanika()
	AADD(opc, "O. prenos reklamacija u KALK")
	AADD(opcexe, {|| Rek2Kalk() })
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
if IsPlNS()
	if gFissta=="D"
		AADD(opc, "F. fiskalni stampac")
		AADD(opcexe, {|| Fissta_mnu()})
	endif
	AADD(opc, "U. trgovacka knjiga")
	AADD(opcexe, {|| mnu_tk()})
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
