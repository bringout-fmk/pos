#include "\cl\sigma\fmk\pos\pos.ch"
#include "dbstruct.ch"
#include "directry.ch"

/*
 * ----------------------------------------------------------------
 *                                     Copyright Sigma-com software 
 * ----------------------------------------------------------------
 * $Source: c:/cvsroot/cl/sigma/fmk/pos/main/1g/ut.prg,v $
 * $Author: sasavranic $ 
 * $Revision: 1.14 $
 * $Log: ut.prg,v $
 * Revision 1.14  2003/11/03 15:45:21  sasavranic
 * Ispis i dom.i str.valute na racunu
 *
 * Revision 1.13  2002/11/21 13:25:25  mirsad
 * ispravka bug-a: umjesto ZakljuciRadnika() sada se poziva Zakljuci() za zakljucenje radnika
 *
 * Revision 1.12  2002/06/24 07:01:38  ernad
 *
 *
 * meniji, u oDatabase:scan ubacen GwDiskFree ..., debug...
 *
 * Revision 1.11  2002/06/17 12:53:55  sasa
 * no message
 *
 * Revision 1.10  2002/06/15 13:18:17  sasa
 * no message
 *
 * Revision 1.9  2002/06/15 12:23:29  sasa
 * no message
 *
 * Revision 1.8  2002/06/15 08:40:38  sasa
 * no message
 *
 * Revision 1.7  2002/06/15 08:35:02  sasa
 * no message
 *
 *
 */
 

/*! \fn IncId(cId, cPadCh)
 *    \brief Inkrementira brojac dat u CHAR formi
 *
 *  \code
 *      IncID (cID, cPadCh) --> (cID+1)
 *   \endcode
 */
    

function IncID(cId,cPadCh)
*{

if cPadCh==nil
	cPadCh:=" "
else
	cPadCh:=cPadCh
endif

return (PADL(VAL(ALLTRIM(cID))+1,LEN(cID),cPadCh))
*}

/*! \fn DecId(cId,cPadCh)
 *  \brief Decrement id, kontra IncId
 */

function DecID(cId,cPadCh)
*{
if cPadCh==nil
	cPadCh:=" "
else
	cPadCh:=cPadCh
endif
return (PADL(VAL(ALLTRIM(cID))-1,LEN(cID),cPadCh) )
*}

/*! \fn FormDat1(dUlazni)
 *  \brief Formatira datum sa stoljecem
 *  \return cDatum - string koji predstavlja 4YEAR formatiran datum
 */

function FormDat1(dUlazni)
*{
local cVrati
SET CENTURY ON
cVrati:=DTOC(dUlazni)+"."
SET CENTURY OFF
return cVrati
*}

/*! \fn SetNazDVal()
 *  \brief Postavlja naziv domace valute
 *  \brief !!! ovo ipak treba da setuje i stranu valutu !!!
 */

function SetNazDVal()
*{
local lOpened
SELECT F_VALUTE
PushWA()
lOpened:=.t.
if !USED() 
	O_VALUTE
	lOpened:=.f.
endif
SET ORDER TO TAG "NAZ"       // tip
GO TOP
Seek2("D")   // trazi domacu valutu
gDomValuta:=ALLTRIM(Naz2)
// postavi odmah i stranu
go top
Seek2("P")
gStrValuta:=ALLTRIM(Naz2)

if !lOpened
	USE
end
PopWA()
return
*}



/*! \fn FormBrowse(nT,nL,nB,nR,aImeKol,aKol,aHFCS,nFreeze,bIstakni)    
 * 
 *  \brief  Formira DBbrowse objekt
 * 
 * \param nT
 * \param nL
 * \param nB
 * \param nR - koordinate
 * \param aImeKol        - niz sa definicijama kolona browsa
 * \param aKol           - niz sa indeksima kolona iz aImeKol koje se koriste
 * \param aHFCS          - niz sa (redom) heder, futer i column separatorom
 * \param nFreeze        - do koje se kolone zamrzava
 * \param bIstakni       - kodni blok za highlight kolone
 *
 * \return oBrowse
 *
 * \todo Ugasiti ovu funkciju .... preci na ObjDBEdit, ili jos bolje TDBGrid objekat ... kada se napravi
 *
 */

function FormBrowse(nT,nL,nB,nR,aImeKol,aKol,aHFCS,nFreeze,bIstakni)
*{
local oBrowse     // browse object
local oColumn     // column object
local k
local i

oBrowse:=TBrowseDB(nT,nL,nB,nR)

// Dodavanje kolona  za stampanje
for k:=1 to LEN(aKol)
	i:=ASCAN(aKol,k)
  	if i<>0
     		oColumn:=TBColumnNew(aImeKol[i,1], aImeKol[i,2])
		if bIstakni<>nil
        		oColumn:colorBlock := {|| IIF (EVAL (bIstakni), {5,2}, {1,2})}
     		endif
		if aHFCS[1]<>nil
        		oColumn:headSep := aHFCS [1]
     		endif
     		if aHFCS[2]<>nil
        		oColumn:footSep := aHFCS [2]
     		endif
     		if aHFCS[3]<>nil
        		oColumn:colSep := aHFCS [3]
     		endif
     		oBrowse:addColumn (oColumn)
  	endif
next

if nFreeze==nil
	oBrowse:Freeze := 1
else
   	oBrowse:Freeze := nFreeze
endif

return (oBrowse)
*}


/*! \fn ShowBrowse(oBrowse,aConds,aProcs)
 *  \brief Browsanje tabele
 *  \param oBrowse
 *  \param aConds   - blokovi kojima se kao parametar prosljedjuje pritisnuta tipka 
 *  \param aProcs   - blokovi koji se izvrsavaju ako njima odgovarajuci blokovi iz aConds vrate .t.
 */
 

*function ShowBrowse(oBrowse,aConds,aProcs)
*{ 

function ShowBrowse
parameters oBrowse, aConds, aProcs
local nCnt
local lFlag
local nArrLen
local nRez:=DE_CONT
private cCH

nArrLen := LEN (aConds)
DO WHILE nRez <> DE_ABORT

   if nRez==DE_REFRESH     // obnovi
      oBrowse:Refreshall()
   endif

   IF oBrowse:colPos <= oBrowse:freeze
      oBrowse:colPos := oBrowse:freeze + 1
   ENDIF

   cCH := 0
   DO WHILE ! oBrowse:stable .AND. (cCH = 0)
      oBrowse:Stabilize()
      cCH := INKEY ()
   ENDDO

   IF oBrowse:stable
      IF oBrowse:hitTop .OR. oBrowse:hitBottom
         Beep (1)
      ENDIF
      cCH := INKEY (0)
   ENDIF

   lFlag := .T.
   FOR nCnt := 1 TO nArrLen
       IF EVAL (aConds [nCnt], cCH)
          nRez := EVAL (aProcs [nCnt])
          lFlag := .F.
          EXIT
       ENDIF
   NEXT

   IF ! lFlag;  LOOP; ENDIF

   DO CASE
     CASE cCH = K_ESC
          // gibaj napolje
          EXIT

     CASE cCH == K_DOWN
          oBrowse:down()
     CASE cCH == K_PGDN
          oBrowse:pageDown()
     CASE cCH == K_CTRL_PGDN
          oBrowse:goBottom()
     CASE cCH == K_UP
          oBrowse:up()
     CASE cCH == K_PGUP
          oBrowse:pageUp()
     CASE cCH == K_CTRL_PGUP
          oBrowse:goTop()
     CASE cCH == K_RIGHT
          oBrowse:right()
     CASE cCH == K_LEFT
          oBrowse:left()
     CASE cCH == K_HOME
          oBrowse:home()
     CASE cCH == K_END
          oBrowse:end()
     CASE cCH == K_CTRL_LEFT
          oBrowse:panLeft()
     CASE cCH == K_CTRL_RIGHT
          oBrowse:panRight()
     CASE cCH == K_CTRL_HOME
          oBrowse:panHome()
     CASE cCH == K_CTRL_END
          oBrowse:panEnd()
   ENDCASE
ENDDO
return
*}



/*! \fn PisiIznRac(nIznos)
 *  \brief Ispisuje iznos racuna velikim slovima
 */

function PisiIznRac(nIznos)
*{
LOCAL cIzn, nCnt, Char, NextY, nPrevRow := ROW(), nPrevCol := COL()
SETPOS (0,0)

Box (, 9, 77)
cIzn := ALLTRIM (TRANSFORM (nIznos, "9999999.99"))
@ m_x,m_y+28 SAY "  IZNOS RACUNA JE  " COLOR INVERT
NextY := m_y + 76
FOR nCnt := LEN (cIzn) TO 1 STEP -1
   Char := SUBSTR (cIzn, nCnt, 1)
   DO CASE
      CASE Char = "1"
         NextY -= 6
         @ m_x+2, NextY SAY " лл"
         @ m_x+3, NextY SAY "  л"
         @ m_x+4, NextY SAY "  л"
         @ m_x+5, NextY SAY "  л"
         @ m_x+6, NextY SAY "  л"
         @ m_x+7, NextY SAY "  л"
         @ m_x+8, NextY SAY "  л"
         @ m_x+9, NextY SAY "ллллл"
      CASE Char = "2"
         NextY -= 8
         @ m_x+2, NextY SAY "ллллллл"
         @ m_x+3, NextY SAY "      л"
         @ m_x+4, NextY SAY "      л"
         @ m_x+5, NextY SAY "ллллллл"
         @ m_x+6, NextY SAY "л"
         @ m_x+7, NextY SAY "л"
         @ m_x+8, NextY SAY "л     л"
         @ m_x+9, NextY SAY "ллллллл"
      CASE Char = "3"
         NextY -= 8
         @ m_x+2, NextY SAY " лллллл"
         @ m_x+3, NextY SAY "      л"
         @ m_x+4, NextY SAY "      л"
         @ m_x+5, NextY SAY "  лллл"
         @ m_x+6, NextY SAY "      л"
         @ m_x+7, NextY SAY "      л"
         @ m_x+8, NextY SAY "      л"
         @ m_x+9, NextY SAY "ллллллл"
      CASE Char = "4"
         NextY -= 8
         @ m_x+2, NextY SAY "л"
         @ m_x+3, NextY SAY "л"
         @ m_x+4, NextY SAY "л     л"
         @ m_x+5, NextY SAY "л     л"
         @ m_x+6, NextY SAY "ллллллл"
         @ m_x+7, NextY SAY "      л"
         @ m_x+8, NextY SAY "      л"
         @ m_x+9, NextY SAY "      л"
      CASE Char = "5"
         NextY -= 8
         @ m_x+2, NextY SAY "ллллллл"
         @ m_x+3, NextY SAY "л"
         @ m_x+4, NextY SAY "л"
         @ m_x+5, NextY SAY "ллллллл"
         @ m_x+6, NextY SAY "      л"
         @ m_x+7, NextY SAY "      л"
         @ m_x+8, NextY SAY "л     л"
         @ m_x+9, NextY SAY "ллллллл"
      CASE Char = "6"
         NextY -= 8
         @ m_x+2, NextY SAY "ллллллл"
         @ m_x+3, NextY SAY "л"
         @ m_x+4, NextY SAY "л"
         @ m_x+5, NextY SAY "ллллллл"
         @ m_x+6, NextY SAY "л     л"
         @ m_x+7, NextY SAY "л     л"
         @ m_x+8, NextY SAY "л     л"
         @ m_x+9, NextY SAY "ллллллл"
      CASE Char = "7"
         NextY -= 8
         @ m_x+2, NextY SAY "ллллллл"
         @ m_x+3, NextY SAY "      л"
         @ m_x+4, NextY SAY "     л"
         @ m_x+5, NextY SAY "    л"
         @ m_x+6, NextY SAY "   л"
         @ m_x+7, NextY SAY "  л"
         @ m_x+8, NextY SAY " л"
         @ m_x+9, NextY SAY "л"
      CASE Char = "8"
         NextY -= 8
         @ m_x+2, NextY SAY "ллллллл"
         @ m_x+3, NextY SAY "л     л"
         @ m_x+4, NextY SAY "л     л"
         @ m_x+5, NextY SAY " ллллл "
         @ m_x+6, NextY SAY "л     л"
         @ m_x+7, NextY SAY "л     л"
         @ m_x+8, NextY SAY "л     л"
         @ m_x+9, NextY SAY "ллллллл"
      CASE Char = "9"
         NextY -= 8
         @ m_x+2, NextY SAY "ллллллл"
         @ m_x+3, NextY SAY "л     л"
         @ m_x+4, NextY SAY "л     л"
         @ m_x+5, NextY SAY "ллллллл"
         @ m_x+6, NextY SAY "      л"
         @ m_x+7, NextY SAY "      л"
         @ m_x+8, NextY SAY "л     л"
         @ m_x+9, NextY SAY "ллллллл"
      CASE Char = "0"
         NextY -= 8
         @ m_x+2, NextY SAY " ллллл "
         @ m_x+3, NextY SAY "л     л"
         @ m_x+4, NextY SAY "л     л"
         @ m_x+5, NextY SAY "л     л"
         @ m_x+6, NextY SAY "л     л"
         @ m_x+7, NextY SAY "л     л"
         @ m_x+8, NextY SAY "л     л"
         @ m_x+9, NextY SAY " ллллл"
      CASE Char = "."
         NextY -= 4
         @ m_x+9, NextY SAY "ллл"
      CASE Char = "-"
         NextY -= 6
         @ m_x+5, NextY SAY "ллллл"
   ENDCASE
NEXT
SETPOS (nPrevRow, nPrevCol)
return
*}

/*! \fn SkloniIznosRac()
    \brief Pravo korisna funkcija ... ?!?
*/

function SkloniIznRac()
*{
BoxC()
return
*}

/*! \fn DummyProc()
 *  \brief
 */
 
function DummyProc()
*{
 return NIL
*}


/*! \fn PromIdCijena()
 *  \brief Promjena seta cijena
 *  \todo Ovu funkciju treba ugasiti, zajedno sa konceptom vise setova cijena, to treba generalno revidirati jer prakticno niko i ne koristi, a knjigovodstveno je sporno
 */

function PromIdCijena()
*{

LOCAL i:=0,j:=LEN(SC_Opisi)
LOCAL cbsstara:=ShemaBoja("B1")
 Prozor1(5,1,6+j+2,78,"SETOVI CIJENA",cbnaslova,,cbokvira,cbteksta,0)
 FOR i:=1 TO j
  @ 6+i,2 SAY IF(VAL(gIdCijena)==i,"->","  ")+;
              STR(i,3)+". "+PADR(SC_Opisi[i],40)+;
              IF(VAL(gIdCijena)==i," <- tekuci set","")
 NEXT
 VarEdit({{"Oznaka seta cijena","gIdCijena","VAL(gIdCijena)>0.and.VAL(gIdCijena)<=LEN(SC_Opisi)",,}},;
             6+j+3,1,6+j+7,78,"IZBOR SETA CIJENA","B1")
 Prozor0()
 ShemaBoja(cbsstara)
 PrikStatus()
return
*}


/*! \fn PortZaMT(cIdDio,cIdOdj)
 *  \brief 
 *  \param cIdDio
 *  \param cIdOdj
 */
 
function PortZaMT(cIdDio,cIdOdj)
*{

LOCAL nObl:=SELECT(),cVrati:=gLocPort    // default port je gLocPort
  SELECT F_UREDJ; PushWA()
  IF ! USED()
    O_UREDJ
  ENDIF
  SELECT F_MJTRUR; PushWA()
  IF ! USED()
    O_MJTRUR
  ENDIF
  GO TOP; HSEEK cIdDio+cIdOdj
  IF FOUND()
    SELECT F_UREDJ
    GO TOP; HSEEK MJTRUR->iduredjaj
    cVrati:=ALLTRIM(port)
  ENDIF
  SELECT F_MJTRUR; PopWA()
  SELECT F_UREDJ; PopWA()
  SELECT (nObl)
return cVrati
*}



/*! \fn Zakljuci()
 *  \brief Zakljuci radnika
 */
 
function Zakljuci()
*{
LOCAL lFlag, cRacStr, cRed
PRIVATE oBrowse, nOtv:=0, nZaklj:=0


DBZakljuci()

IF ZAKSM->(RecCount2()) > 0
  SELECT ZAKSM
  //Browsanje tabele  
  GO TOP
  ImeKol:={ { "Sifra",         {|| IdRadnik}},;
            { "Prezime i ime", {|| NazRadn }},;
            { "Zakljuceno",    {|| Zaklj }},;
            { "Otvoreno"  ,    {|| Otv   }} ;
          }
  Kol:={1,2,3,4}
  ObjDBedit ( , 10, 77, {|Ch| ZakljRadnik (Ch) }, ;
              "  ZAKLJUCENJE RADNIKA  ", "", .F., ;
              "<Z> - Zakljuci")
  IF ZAKSM->(RecCount2()) > 0
    // zakljucen je samo dio radnika - vrati se nazad
    CLOSERET 0
  ENDIF
  // svi radnici su zakljuceni, idi na zakljucenje kase
  IF Pitanje (, "Svi radnici su zakljuceni! Stampati pazar smjene?", "D")=="N"
    CLOSERET 0
  EndIF
ELSE
  IF Pitanje ("zsm", "Nema nezakljucenih radnika! Stampati pazar smjene? (D/N)", "D")=="N"
    CLOSERET 0
  ENDIF
ENDIF

Close All
IF !RealKase (.T.)
  MsgBeep ("#Stampanje pazara smjene nije uspjelo!#")
  CLOSERET 0
EndIF

if gModul=="HOPS"
  // generisi utrosak sirovina za smjenu
  GenUtrSir (gDatum, gDatum, gSmjena)
endif

// knjiga sanka ili trgovacka knjiga se mogu dobiti na izvjestajima
IF gStamStaPun=="D" .and. gVrstaRS=="A"
  Stanje (gDatum, gSmjena)
EndIF

// prebacivanje kumulativnih datoteka na server
PrebNaServer()
CLOSE ALL

NovaSmjGas ()
return (-1)
*}


/*! \fn ProgKeyboard()
*
*   \brief Programiranje tastature
*
*/
function ProgKeyboard()
*{

local nKey1
local nKey2
local idroba
local fIzm
local nIzb
local aOpc[3]

aOpc:={"Izmjeni","Ukini","Ostavi"}

if gSifK=="D"
	O_SIFK
	O_SIFV
endif

O_ROBA
O_K2C

Box(,10,75)
do while .t.
	@ m_x+1,m_y+3 SAY "Pritisnite tipku koju zelite programirati --> "
  	nKey1:=INKEY(0)
  	if nKey1==K_ESC
     		EXIT
  	endif
  	if nKey1==K_ENTER
    		MsgBeep("Ovu tipku ne mozete programirati")
    		BoxCls()
    		LOOP
  	endif
  	@ m_x+3,m_y+3 SAY "          Ponovite pritisak na istu tipku --> "
  	nKey2:=INKEY(0)
  	if nKey2==K_ESC
     		EXIT
  	endif
  	if nKey1==K_ENTER
    		MsgBeep("Ovu tipku ne mozete programirati")
    		BoxCls()
    		LOOP
  	endif
  	if nKey1<>nKey2
    		Msg ("Pritisnute razlicite tipke! Ponovite proceduru", 10)
    		BoxCLS ()
    		LOOP
  	endif
  	fIzm:=.f.
  	SELECT K2C
	set order to 1
  	SEEK STR(nKey1,4)
  	if FOUND ()
    		Beep(3)
    		nIzb:=KudaDalje("Tipka je vec programirana!!!", aOpc)
    		do case
      			case nIzb==0 .or. nIzb==3
        			LOOP
      			case nIzb==1
        			fIzm:=.t.
      			case nIzb==2
        			DELETE
        			LOOP
    		endcase
  	endif

  	Scatter() // iz K2C
  	@ m_x+5,m_y+3 SAY "Sifra robe koja se pridruzuje tipki:"
  	@ m_x+6,m_y+13 GET _idroba VALID P_RobaPOS(@_idroba,6,25).AND.NijeDuplo(_idroba, nKey1)
  	READ
  	if LASTKEY()=K_ESC
     		EXIT
  	endif

  	SELECT K2C
  	if !fIzm
    		APPEND BLANK
    		_KeyCode:=nKey1
  	endif
  	Gather()
  	BoxCLS()
end
BoxC()
CLOSERET
return
*}


/*! \fn NijeDuplo(cIdRoba,nKey)
*   \brief Provjerava da li se pokusava staviti jedna roba na vise tipki 
*   \param cIdRoba - Id robe
*   \param nKey    - tipka
*   \return lFlag==.t. ili .f.
*/
function NijeDuplo(cIdRoba,nKey)
*{

local lFlag:=.t.
SELECT K2C
set order to 2
nCurrRec:=RECNO()
HSEEK cIdRoba
if FOUND().and.RECNO()<>nCurrRec
	Beep(2)
  	Msg("Roba je vec pridruzena drugoj tipki!", 15)
  	lFlag := .f.
endif
GO(nCurrRec)
return (lFlag)
*}


/*! \fn NazivRobe(cIdRoba)
 *  \brief
 *  \param cIdRoba
 */
 
function NazivRobe(cIdRoba)
*{
local nCurr:=SELECT()

SELECT ROBA
HSEEK cIdRoba
SELECT nCurr
return (ROBA->Naz)
*}


/*! \fn Godina_2(dDatum)
 *  \brief
 *  \param dDatum
 */
 
function Godina_2(dDatum)
*{
//
// 01.01.99 -> "99"
// 01.01.00 -> "00"
return padl(alltrim(str(year(dDatum)%100,2,0)),2,"0")
*}


/*! \fn NenapPop()
 *  \brief
 */
 
function NenapPop()
*{
return iif(gPopVar="A","NENAPLACENO:","     POPUST:")
*}


/*! \fn InstallOps(cKorSif)
 *  \brief
 *  \param cKorSif
 */
 
function InstallOps(cKorSif)
*{
if cKorsif="I"
          cKom:=cKom:="I"+gModul+" "+imekorisn+" "+CryptSC(sifrakorisn)
endif
if cKorsif="IM"
          cKom+="  /M"
endif
if cKorsif="II"
          cKom+="  /I"
endif
if cKorsif="IR"
          cKom+="  /R"
endif
if cKorsif="IP"
          cKom+="  /P"
endif
if cKorsif="IB"
          cKom+="  /B"
endif
if cKorsif="I"
          RunInstall(cKom)
endif

return
*}

/*! \fn SetUser(cKorSif,nSifLen,cLevel)
 *  \brief
 *  \param cKorSif
 *  \param nSifLen
 *  \param cLevel
 */
 
function SetUser(cKorSif,nSifLen,cLevel)
*{

O_KORISN
O_STRAD
O_OSOB

cKorSif:=CryptSC(PADR(UPPER(TRIM(cKorSif)),nSifLen))
SELECT OSOB
Seek2(cKorSif)

if FOUND()
    gIdRadnik := ID     ; gKorIme   := Naz
    gSTRAD  := ALLTRIM (Status)
    SELECT STRAD
    Seek2 (OSOB->Status)
    IF FOUND ()
      cLevel := Prioritet
    ELSE
      cLevel := L_PRODAVAC ; gSTRAD := "K"
    ENDIF
    SELECT OSOB
    return 1
else
    MsgBeep ("Unijeta je nepostojeca lozinka!")
    SELECT OSOB
    return 0
endif

return 0
*}

/*! \fn PrikStatus()
 *  \brief
 */
 
function PrikStatus()
*{

 @ 1, 0 SAY "RADI:"+PADR(LTRIM(gKorIme),31)+" SMJENA:"+gSmjena+" CIJENE:"+gIdCijena+" DATUM:"+DTOC(gDatum)+IF(gVrstaRS=="S","   SERVER  "," KASA-PM:"+gIdPos)
 IF gIdPos=="X "
   @ 23, 0 SAY PADC("$$$ --- PRODAJNO MJESTO X ! --- $$$",80,"Б")
 ELSE
   @ 23, 0 SAY REPLICATE("Б",80)
 ENDIF

@ 22,1 SAY PADC ( Razrijedi (gKorIme), 78) COLOR INVERT
return
*}

/*! \fn SetBoje(gVrstaRS)
 *  \brief
 *  \param gVrstaRS
 */
 
function SetBoje(gVrstaRS)
*{

// postavljanje boja (samo C/B kombinacija dolazi u obzir, ako nije server)
IF gVrstaRS <> "S"
  Invert := "N/W,W/N,,,W/N"
  Normal := "W/N,N/W,,,N/W"
  Blink  := "N****/W,W/N,,,W/N"
  Nevid  := "W/W,N/N"
ENDIF
return
*}


