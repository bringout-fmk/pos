/* 
 * This file is part of the bring.out FMK, a free and open source 
 * accounting software suite,
 * Copyright (c) 1996-2011 by bring.out doo Sarajevo.
 * It is licensed to you under the Common Public Attribution License
 * version 1.0, the full text of which (including FMK specific Exhibits)
 * is available in the file LICENSE_CPAL_bring.out_FMK.md located at the 
 * root directory of this source code archive.
 * By using this software, you agree to be bound by its terms.
 */


#include "pos.ch"


/*
 * ----------------------------------------------------------------
 *                                     Copyright Sigma-com software 
 * ----------------------------------------------------------------
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

// dodatni podaci o reklamaciji
if (IsPlanika() .and. cIdVd == VD_REK)
	private cRekOp1
	private cRekOp2
	private cRekOp3
	// postavi odmah da je "R" - realizovana radi odustajanja
	private cRekOp4:="R"
endif

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

fSadAz := .f.

if (cIdVd<>VD_REK) .and. Kalk2Pos(@cIdVd, @cBrDok, @cRsDBF)
	if priprz->(RecCount2()) > 0
    		if cBrDok<>nil .and. Pitanje(,"Odstampati prenesni dokument na stampac ?","N")=="D"
        		if cIdVd $ "16#96#95#98"
          			StampZaduz(cIdVd, cBrDok)
        		elseif cIdVd $ "IN#NI"
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
  	InventNivel(.f., .t., fSadaz, dDatRada)  
	// drugi parametar - poziv iz zaduzenja
        // treci odmah podatke azurirati
  	return
elseif cIdVD=="IN"
  	close all
  	InventNivel(.t., .t., fSadAz, dDatRada)
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

	oBrowse:=FormBrowse( m_x+6, m_y+1, m_x+19, m_y+77, ImeKol, Kol,{ "�", "�", "�"}, 0)
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
		
		if gDuzSifre <> nil .and. gDuzSifre > 0
			cDSFINI := ALLTRIM(STR(gDuzSifre))
		else
			cDSFINI:=IzFMKIni('SifRoba','DuzSifra','10')
		endif

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
    			if (gnDebug == 5)
				MsgBeep("Pozivam prvo promjenu cijene u sifrarniku!")
			endif
			StUSif()
    			select PRIPRZ
    			append blank
    			SELECT (cRSdbf)
    			_RobaNaz:=_field->Naz
			_Jmj:=_field->Jmj
    			_IdTarifa:=_field->IdTarifa
			_Cijena:=if(EMPTY(_cijena),_field->Cijena1,_cijena)
    			if ROBA->(FIELDPOS("BARKOD"))<>0
				_barkod := _field->barkod
			endif
			
			_n1 := _field->n1
			_n2 := _field->n2
			_k1 := _field->k1
			_k2 := _field->k2
			
			if ROBA->(FIELDPOS("K7")) <> 0
				_k7 := _field->k7
				_k9 := _field->k9
			endif
			
			if ROBA->(FIELDPOS("KATBR")) <> 0
				_katbr := _field->katbr
			endif
			
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

SELECT PRIPRZ      
// ZADRP
if RecCount2()>0
	SELECT DOKS
  	set order to 1
  	cBrDok:=NarBrDok(cIdPos,iif(cIdvd=="PD","16",cIdVd)," ",dDatRada)
  	SELECT PRIPRZ
  	// reklamacije dodatni opis
	if (IsPlanika() .and. cIdVd==VD_REK)
		RekOpis()
	endif
  	Beep(4)
	if !fSadAz.and.Pitanje(,"Zelite li odstampati dokument ?","N")=="D"
        	StampZaduz(cIdVd, cBrDok)
  	endif
  	if fSadAz.or.Pitanje(,"Zelite li staviti dokument na stanje? (D/N)", "D")=="D"
    		AzurPriprZ(cBrDok, cIdVD)
		// azuriraj i dodatne podatke o reklamaciji
  		if (IsPlanika() .and. cIdVd==VD_REK)
			AzurRekOpis(cBrDok, cIdVD)
		endif
		// azuriranje doksrc
		p_to_doksrc()
	else
    		SELECT _POS
    		AppFrom("PRIPRZ",.f.)
    		SELECT PRIPRZ
    		Zapp()
		if gSamoProdaja=="N"
			if is_doksrc()
				O_P_DOKSRC
				select p_doksrc
				zap
			endif
		endif
    		select priprz
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
if (gnDebug == 5)
	MsgBeep("Mjenjam cijenu u sifrarniku")
endif

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

