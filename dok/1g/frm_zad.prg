#include "\cl\sigma\fmk\pos\pos.ch"


/*
 * ----------------------------------------------------------------
 *                                     Copyright Sigma-com software 
 * ----------------------------------------------------------------
 * $Source: c:/cvsroot/cl/sigma/fmk/pos/dok/1g/frm_zad.prg,v $
 * $Author: ernad $ 
 * $Revision: 1.12 $
 * $Log: frm_zad.prg,v $
 * Revision 1.12  2003/01/19 23:44:18  ernad
 * test network speed (sa), korekcija bl.lnk
 *
 * Revision 1.11  2002/07/12 14:07:44  ernad
 *
 *
 * todo FmkIni
 *
 * Revision 1.10  2002/07/06 08:13:34  ernad
 *
 *
 * - uveden parametar PrivPath/POS/Slave koji se stavi D za kasu kod koje ne zelimo ScanDb
 * Takodje je za gVrstaRs="S" ukinuto scaniranje baza
 *
 * - debug ispravke racuna (ukinute funkcije PostaviSpec, SiniSpec, zamjenjene sa SetSpec*, UnSetSpec*)
 *
 * Revision 1.9  2002/07/01 13:58:56  ernad
 *
 *
 * izvjestaj StanjePm nije valjao za gVrstaRs=="S" (prebacen da je isti kao za kasu "A")
 *
 * Revision 1.8  2002/06/24 16:11:53  ernad
 *
 *
 * planika - uvodjenje izvjestaja 98-reklamacija, izvjestaj planika/promet po vrstama placanja, debug
 *
 * Revision 1.7  2002/06/17 13:07:21  sasa
 * no message
 *
 * Revision 1.6  2002/06/15 13:18:31  sasa
 * no message
 *
 * Revision 1.5  2002/06/15 10:26:12  sasa
 * no message
 *
 * Revision 1.4  2002/06/15 08:17:46  sasa
 * no message
 *
 *
 */
 
*string IzFmkIni_ExePath_SifRoba_DuzSifra;

/*! \ingroup ini
 *  \fn *string IzFmkIni_ExePath_SifRoba_DuzSifra
 *  \brief Velicina sifre koju program "prima"
 *  \param 10 - default vrijednost
 *  \param 13 - postavit na ovu vrijednost kada radimo sa bar kodovima
 *  \todo  Prebaciti u KUMPATH
 */


/*! \fn Zaduzenje(cIdVd)
 *  \brief Dokument zaduzenja
 *
 *  cIdVD -  16 ulaz
 *           95 otpis
 *           IN inventura
 *           NI nivelacija
 *           96 razduzenje sirovina - ako se radi o proizvodnji
 *           PD - predispozicija
 *
 *  Zaduzenje odjeljenje/punktova robama/sirovinama
 *	     lForsSir .T. - radi se o forsiranom zaduzenju odjeljenja
 *                           sirovinama
 */

*function Zaduzenje(cIdVd)
*{

function Zaduzenje
parameters cIdVd

local cOdg
local PrevDn
local PrevUp
local nSign
if gSamoProdaja=="D" .and. (cIdVd<>VD_REK)
	MsgBeep("Ne mozete vrsiti zaduzenja !")
   	return
endif
private ImeKol:={}
private Kol:={}
private oBrowse
private cBrojZad
private cIdOdj
private cRsDbf
private bRSblok
private cIdVd
private cRobSir:=" "
private dDatRada:=DATE()
private cBrDok:=nil

// koristim ga kod sirovinskog zaduzenja odjeljenja
// ma kako se ono vodilo

if cIdVd==nil
	cIdVd:="16"
else
   	cIdVd:=cIdVd
endif

ImeKol := { { "Sifra",    {|| idroba},      "idroba" }, ;
            { "Naziv",    {|| RobaNaz  },   "RobaNaz" },;
            { "JMJ",      {|| JMJ},         "JMJ"       },;
            { "Kolicina", {|| kolicina   }, "Kolicina"  },;
            { "Cijena",   {|| Cijena},      "Cijena"    } ;
          }
Kol:={1, 2, 3, 4, 5}

OpenZad()

Box(, 6, 60)
cIdOdj:=SPACE(2)
cIdDio:=SPACE(2)
cRazlog:=SPACE(40)
cIdOdj2:=SPACE(2)
cIdPos:=gIdPos

SET CURSOR ON

if gVrstaRS=="S"
	@ m_x+1,m_y+3 SAY "Prodajno mjesto:" GET cIdPos pict "@!" valid cIdPos<="X ".and. !EMPTY(cIdPos)
endif

if gvodiodj=="D"
	@ m_x+3,m_y+3 SAY   " Odjeljenje:" GET cIdOdj VALID P_Odj (@cIdOdj, 3, 28)
  	if cIdVD=="PD"
    		@ m_x+4,m_y+3 SAY " Prenos na :" GET cIdOdj2 VALID P_Odj (@cIdOdj2, 4, 28)
  	endif
endif

if gModul=="HOPS"
	if gPostDO=="D"
    		@ m_x+5,m_y+3 SAY "Dio objekta:" GET cIdDio VALID P_Dio (@cIdDio, 3, 28)
  	endif
endif

@ m_x+6,m_y+3 SAY " Datum dok:" GET dDatRada PICT "@D" VALID dDatRada<=DATE()
READ
ESC_BCR
BoxC()

SELECT ODJ
cRSDbf:="ROBA"
if ODJ->Zaduzuje=="S" .or. cRobSir=="S"
	cRSdbf:="SIROV"
	bRSblok:={|x,y| P_Sirov (@_IdRoba, x, y)}
  	cUI_I:=S_I 
	cUI_U:=S_U
else
  	cRSdbf:="ROBA"
  	bRSblok:={|x,y| Barkod(@_IdRoba), P_RobaPOS (@_IdRoba, x, y)}
  	cUI_I:=R_I
	cUI_U:=R_U
endif

SELECT PRIPRZ
if RecCount2()>0
	//ako je sta bilo ostalo, spasi i oslobodi pripremu
  	SELECT _POS
  	AppFrom("PRIPRZ",.f.)
endif

SELECT priprz
Zapp()
__dbPack()

// vrati ili pobrisi ono sto je poceo raditi ili prekini s radom
if !VratiPripr(cIdVd, gIdRadnik, cIdOdj, cIdDio)
	CLOSERET
endif

fSadAz:=.f.
if (cIdVd<>VD_REK) .and. Kalk2Pos(@cIdVd, @cBrDok, @cRsDBF)
	if priprz->(RecCount2())>0
    		if cBrDok<>nil.and.Pitanje(,"Odstampati prenesni dokument na stampac ?","D")=="D"
        		if cIdVd$"16#96#95#98"
          			StampZaduz(cIdVd, cBrDok)
        		elseif cIdVd$"IN#NI"
          			StampaInv()
        		endif

        		if Pitanje(,"Ako je sve u redu, zelite li staviti na stanje dokument ?"," ")=="D"
          			fSadAz:=.t.
        		endif
    		endif
  	endif
endif

if cIdVD=="NI"
	// cidodj, ciddio - prosljedjujem ove priv varijable u InventNivel
  	close all
  	InventNivel(.f.,.t.,fSadaz,dDatRada)  
	// drugi parametar - poziv iz zaduzenja
        // treci odmah podatke azurirati
  	return
elseif cIdVD=="IN"
  	close all
  	InventNivel(.t.,.t.,fSadAz,dDatRada)
  	return
endif

select (F_PRIPRZ)

if !used()
	return
endif

if !fSadAz
	// browsanje dokumenta ...........
	SELECT PRIPRZ
	SET ORDER TO
	go  top
	Box (,20,77,,{"<*> - Ispravka stavke ","Storno - negativna kolicina"})
	@ m_x,m_y+4 SAY PADC( "PRIPREMA "+NaslovDok(cIdVd)+" NA ODJELJENJE "+ALLTRIM(ODJ->Naz)+IIF(!Empty(cIdDio), "-"+DIO->Naz,""), 70) COLOR Invert

	oBrowse:=FormBrowse( m_x+6, m_y+1, m_x+19, m_y+77, ImeKol, Kol,{ "Í", "Ä", "³"}, 0)
	oBrowse:autolite:=.f.

	PrevDn:=SETKEY(K_PGDN,{|| DummyProc()})
	PrevUp:=SETKEY(K_PGUP,{|| DummyProc()})
	SetSpecZad()

	SELECT PRIPRZ
	Scatter()
	_IdPos:=cIdPos
	_IdVrsteP:=cIdOdj2
	// vrste placanja su iskoristene za idodj2
	_IdOdj:=cIdOdj
	_IdDio:=cIdDio
	_IdVd:=cIdVd
	_BrDok:=SPACE(LEN(DOKS->BrDok))
	_Datum:=dDatRada
	_Smjena:=gSmjena
	_IdRadnik:=gIdRadnik
	_IdCijena:="1"
	// ne interesuje me set cijena
	_Prebacen:=OBR_NIJE
	_MU_I:=cUI_U
	// ulaz
	if cIdVd==VD_OTP
  		_MU_I:=cUI_I
		// kad je otpis imam izlaz
	endif

	SET CURSOR ON
	do while .t.
  		do while !oBrowse:Stabilize() .and. ((Ch:=INKEY())==0)
			Ol_Yield()
  		enddo
  		_idroba:=SPACE (LEN (_idroba))
  		_Kolicina:= 0
  		_cijena:=0
  		_ncijena:=0
  		_marza2:=0
  		_TMarza2:="%"
  		fMarza:=" "
		@ m_x+2,m_y+25 SAY SPACE(40)
		cDSFINI:=IzFMKIni('SifRoba','DuzSifra','10')

		@ m_x+2,m_y+5 SAY " Artikal:" GET _idroba pict "@!S"+cDSFINI when {|| _idroba:=padr(_idroba,VAL(cDSFINI)),.t.} VALID EVAL (bRSblok, 2, 25).and.(gDupliArt=="D" .or. ZadProvDuple(_idroba))
		@ m_x+4,m_y+5 SAY "Kolicina:" GET _Kolicina PICTURE "999999.999" WHEN{|| OsvPrikaz(),ShowGets(),.t.} VALID ZadKolOK(_Kolicina)


  		if gZadCij=="D"
    			@ m_x+ 3,m_y+35  SAY "N.cijena:" GET _ncijena PICT "99999.9999"
    			@ m_x+ 3,m_y+56  SAY "Marza:" GET _TMarza2  VALID _Tmarza2 $ "%AU" PICTURE "@!"
    			@ m_x+ 3,col()+2 GET _Marza2 PICTURE "9999.99"

    			if IzFMKIni("POREZI","PPUgostKaoPPU","N")=="D"
      				@ m_x+ 3,col()+1 GET fMarza pict "@!" VALID {|| _marza2:=iif(_cijena<>0 .and. empty(fMarza), 0, _marza2),Marza2(fmarza),_cijena:=iif(_cijena==0,_cijena:=_ncijena*(1+TARIFA->Opp/100)*(1+TARIFA->PPP/100+tarifa->zpp/100),_cijena),fmarza:=" ",.t.}
    			else
      				@ m_x+3,col()+1 GET fMarza pict "@!" VALID {|| _marza2:=iif(_cijena<>0 .and. empty(fMarza), 0, _marza2),Marza2(fmarza),_cijena:=iif(_cijena==0,_cijena:=_nCijena*(tarifa->zpp/100+(1+TARIFA->Opp/100)*(1+TARIFA->PPP/100)),_cijena),fMarza:=" ",.t.}
    			endif
    			@ m_x+ 4,m_y+35 SAY "MPC SA POREZOM:" GET _cijena  PICT "99999.999" valid {|| _marza2:=0, Marza2(), ShowGets(), .t.}
  		endif

  		READ
  		if (LASTKEY()==K_ESC)
    			EXIT
  		else
    			StUSif()
    			select PRIPRZ
    			append blank
    			SELECT (cRSdbf)
    			_RobaNaz:=_field->Naz
			_Jmj:=_field->Jmj
    			_IdTarifa:=_field->IdTarifa
			_Cijena:=if(EMPTY(_cijena),_field->Cijena1,_cijena)
    			SELECT PRIPRZ
    			Gather() // PRIPRZ
    			// reci mu da ide na kraj
    			oBrowse:goBottom()
    			oBrowse:refreshAll()
    			oBrowse:dehilite()
  		endif
	enddo
	SETKEY(K_PGUP,PrevUp)
	SETKEY(K_PGDN,PrevDn)
	UnSetSpecZad()

	// kraj browsanja
	BoxC()
	
endif // fSadAz

//parametri croba
fCroba:=(IzFmkIni('CROBA','GledajTops','N',KUMPATH)=='D')

if fCROBA
	nH:=0
  	// zapocni sql
  	cSQLFile:='c:\sigma\sql'
  	ASQLCRoba(@nH,cSQLFile)
endif

SELECT PRIPRZ      
// ZADRP
if RecCount2()>0
	SELECT DOKS
  	set order to 1
  	cBrDok:=NarBrDok(cIdPos,iif(cIdvd=="PD","16",cIdVd)," ",dDatRada)
  	SELECT PRIPRZ
  	Beep(4)
  	if !fSadAz.and.Pitanje(,"Zelite li odstampati dokument ?","D")=="D"
        	StampZaduz(cIdVd,cBrDok)
  	endif
  	if fSadAz.or.Pitanje(,"Zelite li staviti dokument na stanje? (D/N)", "D")=="D"
    		AzurPriprZ(cBrDok,cIdVD)
  	else
    		SELECT _POS
    		AppFrom("PRIPRZ",.f.)
    		SELECT PRIPRZ
    		Zapp()
    		__dbPack()
    		MsgBeep("Dokument nije stavljen na stanje!#"+"Ostavljen je za doradu!",20)
  	endif
endif
CLOSERET
*}


/*! \fn OsvPrikaz()
 *  \brief 
 */
function OsvPrikaz()
*{

if gZadCij=="D"
	nArr:=SELECT()
    	SELECT (F_TARIFA)
    	if !USED()
		O_TARIFA
	endif
    	SEEK ROBA->idtarifa
	SELECT (nArr)
    	@ m_x+ 5,  m_y+2 SAY "PPP (%):"
	@ row(),col()+2 SAY TARIFA->OPP PICTURE "99.99"
    	@ m_x+ 5,col()+8 SAY "PPU (%):"
	@ row(),col()+2 SAY TARIFA->PPP PICTURE "99.99"
    	@ m_x+ 5,col()+8 SAY "PP (%):" 
	@ row(),col()+2 SAY TARIFA->ZPP PICTURE "99.99"
    	_cijena:=&("ROBA->cijena"+gIdCijena)
endif
return
*}

/*! \fn StUSif()
 *  \brief 
 */
function StUSif()
*{

if gZadCij=="D"
	if _cijena<>&("ROBA->cijena"+gIdCijena).and.Pitanje(,"Staviti u sifrarnik novu cijenu? (D/N)","D")=="D"
      		nArr:=SELECT()
      		SELECT (F_ROBA)
      		Scatter("s")
		&("scijena"+gIdCijena):=_cijena
		Gather("s")
      		sql_azur(.t.)
      		GathSQL("s")
      		SELECT (nArr)
    	endif
endif
return
*}


/*! \fn SetSpecZad()
 *  \brief pridruzi "*" - ispravka zaduzenja
 */
 
function SetSpecZad()
*{
bPrevZv:=SETKEY(ASC("*"), {|| IspraviZaduzenje()})
return .t.
*}


/*! \fn UnSetSpecZad()
 *  \brief vrati tipci "*" prijasnje znacenje
 */
 
function UnSetSpecZad()
*{
SETKEY(ASC("*"),{|| bPrevZv})
return .f.
*}


/*! \fn ZadKolOK(nKol)
 *  \brief
 *  \param nKol
 *  \return
 */

function ZadKolOK(nKol)
*{

if LASTKEY()=K_UP
	return .t.
endif
if nKol=0
	MsgBeep("Kolicina mora biti razlicita od nule!#Ponovite unos!", 20)
     	return (.f.)
endif
return (.t.)
*}


/*! \fn ZadProvDuple(cSif)
 *  \brief Provjera postojanja sifre u zaduzenju
 *  \param cSif
 *  \return
 */
function ZadProvDuple(cSif)
*{

local lFlag:=.t.

SELECT PRIPRZ
SET ORDER TO 1
nPrevRec:=RECNO()
Seek cSif
if FOUND()
	MsgBeep("Na zaduzenju se vec nalazi isti artikal!#"+"U slucaju potrebe ispravite stavku zaduzenja!", 20)
    	lFlag:=.f.
endif
SET ORDER TO
GO (nPrevRec)
return (lFlag)
*}


/*! \fn IspraviZaduzenje()
 *  \brief Ispravka zaduzenja od strane korisnika
 */
function IspraviZaduzenje()
*{

local cGetId
local nGetKol
local aConds
local aProcs

UnSetSpecZad()
cGetId:=_idroba
nGetKol:=_Kolicina

OpcTipke({"<Enter>-Ispravi stavku","<B>-Brisi stavku","<Esc>-Zavrsi"})

oBrowse:autolite:=.t.
oBrowse:configure()
aConds:={ {|Ch| Ch == ASC ("b") .OR. Ch == ASC ("B")},{|Ch| Ch == K_ENTER}}
aProcs:={ {|| BrisStavZaduz ()}, {|| EditStavZaduz ()}}
ShowBrowse(oBrowse, aConds, aProcs)
oBrowse:autolite:=.f.
oBrowse:dehilite()
oBrowse:stabilize()

// vrati stari meni
Prozor0()
// vrati sto je bilo u GET-u
_idroba:=cGetId
_Kolicina:=nGetKol
SetSpecZad()
return
*}


/*! \fn BrisStavZaduz()
 *  \brief Brise stavku zaduzenja
 */

function BrisStavZaduz()
*{

SELECT PRIPRZ
if RecCount2()==0
	MsgBeep("Zaduzenje nema nijednu stavku!#Brisanje nije moguce!", 20)
     	return (DE_CONT)
endif
Beep(2)
DELETE
oBrowse:refreshAll()
return (DE_CONT)
*}



/*! \fn EditStavZaduz()
 *  \brief Vrsi editovanje stavke zaduzenja i to samo artikla ili samo kolicine
 */
function  EditStavZaduz()
*{

local PrevRoba
local nARTKOL:=2
local nKOLKOL:=4
private GetList:={}
  
if RecCount2()==0
	MsgBeep("Zaduzenje nema nijednu stavku!#Ispravka nije moguca!", 20)
     	return (DE_CONT)
endif
// uradi edit samo vrijednosti u tekucoj koloni

PrevRoba:=_IdRoba:=PRIPRZ->idroba
_Kolicina:=PRIPRZ->Kolicina
Box(, 3, 60)
@ m_x+1,m_y+3 SAY "Novi artikal:" GET _idroba PICTURE "@K" VALID EVAL (bRSblok, 1, 27) .AND.(_IdRoba==PrevRoba.or.ZadProvDuple (_idroba))
@ m_x+2,m_y+3 SAY "Nova kolicina:" GET _Kolicina VALID ZadKolOK (_Kolicina)
read

if LASTKEY()<>K_ESC
	if _idroba<>PrevRoba
      		// priprz
      		REPLACE RobaNaz WITH &cRSdbf.->Naz,Jmj WITH &cRSdbf.->Jmj,Cijena WITH &cRSdbf.->Cijena,IdRoba WITH _IdRoba
    	endif
    	// priprz
    	REPLACE Kolicina WITH _Kolicina
endif

BoxC()
oBrowse:refreshCurrent()
return (DE_CONT)
*}

function NaslovDok(cIdVd)
*{
do case
	case cIdVd=="16"
		return "ZADUZENJE"
	case cIdVd=="PD"
		return "PREDISPOZICIJA"
	case cIdVd=="95"
		return "OTPIS"
	case cIdVd=="98"
		return "REKLAMACIJA"
	otherwise
		return "????"
endcase

return
*}
