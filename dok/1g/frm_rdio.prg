#include "\cl\sigma\fmk\pos\pos.ch"

/*
 * ----------------------------------------------------------------
 *                                     Copyright Sigma-com software 
 * ----------------------------------------------------------------
 * $Source: c:/cvsroot/cl/sigma/fmk/pos/dok/1g/frm_rdio.prg,v $
 * $Author: sasa $ 
 * $Revision: 1.3 $
 * $Log: frm_rdio.prg,v $
 * Revision 1.3  2002/06/15 08:17:46  sasa
 * no message
 *
 *
 */
 

/*! \fn RazdRac(cRadRac,fZakPol,nKoliko,cAuto,cZagl)
 *  \brief Dijeljenje radnog racuna!
 *  \param cRadRac
 *  \param fZakPol -> ako je .t. zakljuci i polazni racun
 *  \param nKoliko
 *  \param cAuto
 *  \param cZagl
 *  \return
 */

function RazdRac(cRadRac,fZakPol,nKoliko,cAuto,cZagl)
*{

local aRacPriv:={}
local nKol
local nCnt
local nRRPrec
local nSumaDijelova
local aConds
local aProcs
local nAutoDio
private oTB
private ImeKol
private Kol

Box(,20,77,,{"<Enter>-Unos/izmjena", "</>-Iznos polaznog","<+>-Iznos dijela","<Z> - Zakljuci"})
// priprema niza s definicijom baze, te nizova za browse
ImeKol:={{"Naziv robe",{|| PADR (AllTrim (IdRoba)+"-"+RobaNaz, 30)}},{ "Cijena",{|| Str (Cijena, 7, 2)}},{ "Na racunu",  {|| OrigKol }}}

if !fZakPol
	AADD(ImeKol, {"Za zakljuciti", {|| Kol2}})
else
	AADD (ImeKol, {"Dio 2", {|| Kol2}})
endif

Kol:={1, 2, 3, 4}

for nCnt:=3 to nKoliko
	cBrKol := ALLTRIM (STR (nCnt))
    	AADD (ImeKol, {"Dio "+cBrKol, &("{|| Kol"+cBrKol+"}")})
    	AADD (Kol, nCnt+2)
next

SELECT RAZDR
Zapp()

SELECT _POS
Seek gIdPos+VD_RN+dtos(gDatum)+cRadRac
while !eof() .and. _POS->(IdPos+IdVd+dtos(gDatum)+BrDok)==(gIdPos+VD_RN+dtos(gDatum)+cRadRac)
	SELECT RAZDR
    	APPEND BLANK // _POS
   	REPLACE IdRoba WITH _POS->IdRoba, RobaNaz WITH _POS->RobaNaz,Cijena WITH _POS->Cijena
    	SELECT _POS
    	cIdRoba:=_POS->IdRoba
    	nKolRoba:=0
    	while !eof().and._POS->(IdPos+IdVd+dtos(Datum)+BrDok+IdRoba)==(gIdPos+VD_RN+dtos(gDatum)+cRadRac+cIdRoba)
      		nKolRoba += _POS->Kolicina
      		SKIP
    	enddo
    	SELECT RAZDR
    	nAutoSuma := 0
    	if cAuto=="D"
      		nAutoDio:=Round(nKolRoba/nKoliko,N_ROUNDTO)
      		for nCnt:=2 to nKoliko
			REPLACE &("Kol"+LTRIM (STR (nCnt, 2))) WITH nAutoDio
        		nAutoSuma+=ROUND(&("Kol"+LTRIM (STR (nCnt, 2))), N_ROUNDTO)
      		next
    	endif
    	REPLACE OrigKol WITH (nKolRoba-nAutoSuma)
    	SELECT _POS
END

SELECT RAZDR
GO TOP
@ m_x,m_y+1 SAY PADC (cZagl, 78) COLOR INVERT
oTB:=FormBrowse(m_x+2, m_y+1,m_x+19,m_y+77,ImeKol,Kol,{ "Í", "Ä", "³"}, 3)
aConds:={{|Ch| Ch=K_ENTER.or.((ASC("0")<= Ch).and.(Ch <= ASC ("9"))).or.Ch=ASC(".")},{|Ch| Ch==ASC("/")},{|Ch| Ch == ASC ("+")},{|Ch| Ch == ASC ("Z") .OR. Ch == ASC ("z")}}
aProcs:={{|| RazdRacEdit ()},{|| IznDio (3)},{|| IznDio (oTB:colpos)},{|| DE_ABORT}}

ShowBrowse( oTB, aConds, aProcs )
BoxC()
// ako je ponisti
if LASTKEY()==K_ESC
	RETURN
endif

// prvo odredi brojeve (radne) za racune na koje se dijeli ovaj
// naravno, osim onog od kog se krenulo
SELECT _POS
cNarBrDok := NarBrDok (gIdPos, VD_RN)
AADD (aRacPriv, cNarBrDok)
for nCnt := 3 to nKoliko
	cNarBrDok := IncID (cNarBrDok)
    	AADD (aRacPriv, cNarBrDok)
next

// rasutaj stavke (kolicine) u _POS
SELECT RAZDR
GoTop2()
while !eof()
	SELECT _POS
    	Seek gIdPos+VD_RN+dtos(gDatum)+cRadRac+RAZDR->IdRoba
    	nRRPrec := RECNO()
    	Scatter()	// pokupi sto je svima isto
    	for nCnt := 2 to nKoliko
      		nKol := &("RAZDR->Kol" + LTRIM (STR (nCnt, 2)))
      		if nKol > 0
        		APPEND BLANK  // _POS
			_BrDok:=aRacPriv[nCnt-1]
			_Kolicina := nKol
			Gather()
      		endif
    	next
    	GO (nRRPrec)
    	lFlag:=.f.
    	nKolRoba:=0
    	do while !eof() .and._POS->(IdPos+IdVd+dtos(datum)+BrDok+IdRoba)==(gIdPos+"42"+dtos(gDatum)+cRadRac+RAZDR->IdRoba)
      		if RAZDR->OrigKol==0
        		Del_Skip()
      		else
        		if lFlag
          			Del_Skip()
        		else
          			if nKolRoba+_POS->Kolicina > RAZDR->OrigKol
            				REPLACE Kolicina WITH RAZDR->OrigKol-nKolRoba
            				lFlag:=.t.
          			else
            				nKolRoba += _POS->Kolicina
          			endif
          			SKIP
        		endif
      		endif
    	enddo
    	SELECT RAZDR
    	Del_Skip ()
end

// stampaj racune
SELECT DOKS
cStalRac := NarBrDok (gIdPos, VD_RN)

if fZakPol
	cTime:=StampaRac(gIdPos, cRadRac)
    	if !EMPTY(cTime)
      		AzurRacuna (gIdPos, cStalRac, cRadRac, cTime)
    	else
      		SkloniIznRac()
      		MsgBeep ("Radni racun <" + ALLTRIM (cRadRac) + "> nije zakljucen!#" + "Ponovite proceduru zakljucenja kasnije!", 20)
      		return
    	endif
else
	DecID(cStalRac)
endif

for nCnt:=2 to nKoliko
	// odredjivanje stvarnog broja racuna (iz RACUNI) u cBrojRn
    	cStalRac := IncID (cStalRac)
    	cTime := StampaRac (gIdPos, aRacPriv [nCnt-1])
    	if !EMPTY (cTime)
      		AzurRacuna (gIdPos, cStalRac, aRacPriv[nCnt-1], cTime)
    	else
      		SkloniIznRac()
      		MsgBeep ("Radni racun <" + ALLTRIM (aRacPriv[nCnt-1]) + "> nije zakljucen!#" +"Ponovite proceduru zakljucenja kasnije!", 20)
      		return
    	endif
next
CLOSERET
*}


/*! \fn RazdRacEdit()
 *  \brief
 */
function RazdRacEdit()
*{

local cGetVar
local nPrevKol
local nKol

if cCH<>K_ENTER
	KEYBOARD(CHR(cCH))
endif

nPrevCurs:=SETCURSOR(1)
cGetVar:="Kol" + AllTRIM (STR (oBrowse:colPos-2))
nPrevKol:=nGetKol:=&cGetVar.

set cursor on
@ ROW(),COL() GET nGetKol COLOR INVERT VALID RazdKolOK (nGetKol, nPrevKol)
READ

if LASTKEY()<>K_ESC .and. nGetKol<>nPrevKol
	REPLACE &cGetVar. WITH nGetKol,OrigKol WITH OrigKol-(nGetKol-nPrevKol)
endif

SETCURSOR (nPrevCurs)
oBrowse:refreshCurrent()
RETURN (DE_CONT)
*}

/*! \fn RazdKolOK(nNova,nStara)
 *  \brief
 *  \param nNova
 *  \param nStara
 */
 
function RazdKolOK(nNova,nStara)
*{

if nNova==nStara
	return (.t.)
endif

if (nNova-nStara)>RAZDR->OrigKol
	MsgBeep("Ne mozete prebaciti toliku kolicinu na ovaj racun!!!", 15)
    	return (.f.)
endif
return (.t.)
*}


/*! \fn IznDio(nCol)
 *  \brief
 *  \param nCol
 */
 
function IznDio(nCol)
*{

local nSuma:=0
local nPrev
local Lx
local Ly
private cPolje:="RAZDR->ORIGKOL"

if nCol>3
	cPolje:="RAZDR->KOL"+ALLTRIM(STR(nCol-2))
endif

SELECT RAZDR
nPrev:=RECNO()
GO TOP
while !eof()
	nSuma+=Cijena*&(cPolje)
    	SKIP
enddo

Lx:=ROW()
Ly:=COL()
MsgBeep ("Iznos dijela racuna je "+STR(nSuma,10,2))
SETPOS (Lx,Ly)
GO nPrev
return DE_CONT
*}


