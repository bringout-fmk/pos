#include "\cl\sigma\fmk\pos\pos.ch"

*string
static cUser
*;

*string
static cPassword
*;


*string IzFmkIni_KumPath_POS_MODUL;

/*! \var *string IzFmkIni_KumPath_POS_MODUL
 *  \param HOPS - kasa u ugostiteljstvu
 *  \param TOPS - obicna kasa, trgovina
 */
 

#ifndef LIB
function Main(cKorisn, cSifra, p3, p4, p5, p6, p7)
*{
	MainPos(cKorisn, cSifra, p3, p4, p5, p6, p7)
return
*}
#endif

function MainPos(cKorisn, cSifra, p3, p4, p5, p6, p7)
*{
local cModul
local lMnuIni
local aUseri

private Izbor
private opc

public goModul
public gKonvertPath

gKonvertPath:="D"
//ovo treba sve izolovati u funkciju SetGlobal0()

StandardBoje()

#ifdef CLIP
	? "iza standard boje ..."
#endif

gInstall:=.f.
gReadonly:=.f.
gAppSrv:=.f.
gSql:="N"
m_x:=1
m_y:=1
gCekaScreenSaver := 5

lMnuIni:=.f.
if (cKorisn=="/MNU_INI") 
	lMnuIni:=.t.
endif

opc:={}

SetMnuIni(@opc, @aUseri)

Izbor:=1
do while .t.
	oPos:=TPosModNew()
	cModul:="TOPS"
	goModul:=oPos
	if lMnuIni
		gFKolor:="D"
		StandardBoje()
		CLEAR
		@ 1,60 SAY "Sigma-com software"
		@ 3,2  SAY ""
		Izbor:=Menu("pose", opc, Izbor, .f.)
		if (Izbor==0)
			oPos:oParent:=nil
			QUIT
			exit
		else
			cKorisn:=aUseri[Izbor,1]
			cSifra:=aUseri[Izbor,2]
		endif
	endif
	oPos:init("DA", cModul, D_PO_VERZIJA, D_PO_PERIOD , cKorisn, cSifra, p3,p4,p5,p6,p7)
	oPos:run()
	oPos:=nil
	if (!lMnuIni)
		exit
	endif
enddo

return
*}

function SetMnuIni(aOpc, aUseri)
*{
local i
local aMenu
local cMenuItem
local cUser
local cPassword
local cPom

aUseri:={}

for i:=1 to 50
	if (i<20)
		cPom:="menu item"+ALLTRIM(STR(i))
	else
		cPom:="-"
	endif
	cMenuItem:=IzFmkIni("POS_Menu","MI_"+ALLTRIM(STR(i)),cPom)
	if cMenuItem=="-"
		exit
	endif
	cPom:=ALLTRIM(STR(i))+"1"
	cUser:=IzFmkIni("POS_Menu","USER_"+ALLTRIM(STR(i)),cPom)
	cPassword:=IzFmkIni("POS_Menu","PASSW_"+ALLTRIM(STR(i)),cPom)
	AADD(aOpc, cMenuItem)
	AADD(aUseri, {cUser, cPassword})
next

return
*}

