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

static LEN_TRAKA := 40
static LEN_RAZMAK := 1
static PIC_UKUPNO := "9999999.99"


/*! \fn RealKase(fZaklj,dDat0,dDat1,cVarijanta)
 *  \param fZaklj - True - izvjestaj se formira prilikom zakljucivanja radnika; False - uobicajen poziv (obicni izvjestaj)
 *  \param dDat0
 *  \param dDat1
 *  \param cVarijanta - "0" - tekuci izvjestaj, "2" - vrsi se rekapitulacija kod
 *  \brief Izvjestaj: realizacija kase/prodajnog mjesta
 */

*function RealKase(fZaklj,dDat0,dDat1,cVarijanta)
*{
function RealKase
parameters fZaklj,dDat0,dDat1,cVarijanta
local aPorezi := {}

private cIdOdj:=SPACE(2)
private cRadnici:=SPACE(60)
private cVrsteP:=SPACE(60)
private cSmjena:=SPACE(1)
private cIdPos:=gIdPos
private cRD
private cIdDio:=gIdDio
private aNiz
private aUsl1:={}
private aUsl2:={}
private fPrik:="O"
private cFilter:=".t."
private cSifraDob:=SPACE(8)
private cPartId:=SPACE(8)

if fZaklj==nil
	fZaklj:=.f.
endif

set cursor on

cK1:="N"

if fZaklj
	cPVrstePl:="D"
endif

if (dDat0==nil)  
	dDat0:=gDatum
	dDat1:=gDatum
endif

if (cVarijanta==nil)
	cVarijanta:="0"
elseif (cVarijanta=="2")
	cVarijanta:="0"
	cK1:="D"
endif


ODbRpt()

SELECT osob
SET ORDER TO TAG "NAZ"

TblCrePom()

// TblCrePom prilikom kreiranja indeksa zatvori sve tabele
ODbRpt()

cPVrstePl:="N"
cAPrometa:="N"
cVrijOd:="00:00"
cVrijDo:="23:59"
cGotZir:=" "

if fZaklj
	cK1:="N"
	cIdPos:=gIdPos
	dDat0:=dDat1:=gDatum
	cSmjena:=gSmjena
	cRD:="R"
	cVrijOd:="00:00"
	cVrijDo:="23:59"
	aUsl1:=".t."
	aUsl2:=".t."
else
	
	if FrmRptVars(@cK1, @cIdPos, @dDat0, @dDat1, @cSmjena, @cRD, @cVrijOd, @cVrijDo, @aUsl1, @aUsl2, @cVrsteP, @cAPrometa, @cGotZir, @cSifraDob, @cPartId)==0
		return 0
	endif

endif

if fZaklj
	START PRINT2 CRET gLocPort,.f.
	ZagFirma()
	ZaglZ(dDat0, dDat1, cIdPos, cSmjena, cIdDio, cRadnici, cVrsteP, cIdOdj)
else
	START PRINT CRET
	ZagFirma()
	Zagl(dDat0, dDat1, cIdPos, cSmjena, cIdDio, cRadnici, cVrsteP, cIdOdj, cGotZir)
endif // fZaklj

O_DOKS
SetFilter(@cFilter, aUsl1, aUsl2, cVrijOd, cVrijDo, cGotZir, cPartId)

// fZaklj - zakljucenje smjene
if !fZaklj  
	KasaIzvuci("01", cSifraDob)
endif

KasaIzvuci("42", cSifraDob)

private nTotal:=0

//Participacija
private nTotal2:=0

//Nenaplaceno ili Popust (zavisno od varijante)
private nTotal3:=0

if (cRD $ "RB")
	SELECT POM
	SET ORDER TO 1
	if (fPrik $ "PO")
		RealPoRadn(fPrik, @nTotal2, @nTotal3)
	endif
endif   


if (cRD $ "OB") 
	// prikaz realizacije po odjeljenjima
	RealPoOdj( fPrik, @nTotal2, @nTotal3, @aPorezi )
endif 

if !fZaklj

	//Porezi po tarifama
	if IsPDV()
		PDVPorPoTar(dDat0, dDat1, cIdPos, nil, cIdodj)
	else
		PorPoTar(dDat0, dDat1, cIdPos, nil, cIdodj)
	endif

	if ROUND(ABS(nTotal2)+ABS(nTotal3),4)<>0

		ODbRpt()

		if IsPDV()
			PDVPorPoTar(dDat0,dDat1,cIdPos,"3")  // STA JE OVO? => APOTEKE!!
		else
			PorPoTar(dDat0,dDat1,cIdPos,"3")  // STA JE OVO? => APOTEKE!!
		endif	
	endif
endif

if fZaklj
	PaperFeed()
	END PRN2
else
	END PRINT
endif

close all

return .t.
*}


/*! \fn FrmRptVars(cK1, cIdPos, dDat0, dDat1, cSmjena, cRD, cVrijOd, cVrijDo, aUsl1, aUsl2, cVrsteP, cAPrometa)
 *  \brief Uzmi varijable potrebne za izvjestaj
 *  \return 0 - nije uzeo, 1 - uzeo uspjesno
 */
function FrmRptVars(cK1, cIdPos, dDat0, dDat1, cSmjena, cRD, cVrijOd, cVrijDo, aUsl1, aUsl2, cVrsteP, cAPrometa, cGotZir, cSifraDob, cPartId)
*{
local aNiz

aNiz:={}
cIdPos:=gIdPos

if gVrstaRS<>"K"
	AADD(aNiz,{"Prod. mjesto (prazno-sve)","cIdPos","cidpos='X'.or.EMPTY(cIdPos) .or. P_Kase(@cIdPos)","@!",})
endif

AADD(aNiz,{"Radnici (prazno-svi)","cRadnici",,"@!S30",})
AADD(aNiz,{"Vrste placanja (prazno-sve)","cVrsteP",,"@!S30",})


if gVodiOdj=="D"
	AADD(aNiz,{"Odjeljenje (prazno-sva)","cIdOdj","EMPTY(cIdOdj).or.P_Odj(@cIdOdj)","@!",})
endif

if gModul=="HOPS"
	AADD(aNiz,{"Dio objekta (prazno-svi)","cIdDio","EMPTY(cIdDio).or.P_Dio(@cIdDio)","@!",})
endif

AADD(aNiz,{"Izvjestaj se pravi od datuma","dDat0",,,})
AADD(aNiz,{"                   do datuma","dDat1",,,})
AADD(aNiz,{"Smjena (prazno-sve)","cSmjena",,,})
fPrik:="O"
AADD(aNiz,{"Prikazati Pazar/Robe/Oboje (P/R/O)?","fPrik","fPrik$'PRO'","@!",})
cRD := "R"

if cK1=="D"
	cRd:="O"
else
	AADD(aNiz,{"Po Radnicima/Odjeljenjima/oBoje (R/O/B)?","cRD","cRD$'ROB'","@!",})
endif

AADD(aNiz,{"Prikazati pregled po vrstama placanja ?","cPVrstePl","cPVrstePl$'DN'","@!",})
AADD(aNiz,{"Vrijeme od","cVrijOd",,"99:99",})
AADD(aNiz,{"Vrijeme do","cVrijDo","cVrijDo>=cVrijOd","99:99",})

if gPVrsteP
	AADD(aNiz,{"Izvrsiti azuriranje tabele prometa prodavnice (D/N)","cAPrometa","cAPrometa$'DN'","@!",})
endif

AADD(aNiz,{"Dobavljac (prazno-svi)","cSifraDob",".t.",,})
AADD(aNiz,{"Partner (prazno-svi)","cPartId",".t.",,})

do while .t.
	if cVarijanta<>"1"  // onda nema read-a
		if !VarEdit(aNiz,6,5,24,74,"USLOVI ZA IZVJESTAJ: REALIZACIJA KASE-PRODAJNOG MJESTA","B1")
			CLOSE ALL 
			return 0
		endif
	endif
	aUsl1:=Parsiraj(cRadnici,"IdRadnik")
	aUsl2:=Parsiraj(cVrsteP,"IdVrsteP")
	if aUsl1<>nil .and. aUsl2<>nil .and. dDat0<=dDat1
		exit
	elseif aUsl1==nil
		Msg("Kriterij za radnike nije korektno postavljen!")
	elseif aUsl2==nil
		Msg("Kriterij za vrste placanja nije korektno postavljen!")
	else
		Msg("'Datum do' ne smije biti stariji od 'datum od'!")
	endif

enddo

return 1
*}

static function Zagl(dDat0, dDat1, cIdPos, cSmjena, cIdDio, cRadnici, cVrsteP, cIdOdj,cGotZir)
*{

?? gP12CPI

if glRetroakt
	? PADC("REALIZACIJA NA DAN "+FormDat1(dDat1), LEN_TRAKA)
else
	? PADC("REALIZACIJA NA DAN "+FormDat1(gDatum), LEN_TRAKA)
endif

? PADC("-------------------------------------", LEN_TRAKA)

O_KASE

if EMPTY(cIdPos)
	if ( grbReduk < 2 )
		? "PRODAJNO MJESTO: SVA"
	endif
else
	? "PRODAJNO MJESTO: "+cIdPos+"-"+Ocitaj(F_KASE,cIdPos,"NAZ")
endif

if EMPTY(cIdDio)
	if ( grbReduk < 2 )
		? "DIO OBJEKTA:  SVI"
	endif
else
	? "DIO OBJEKTA: "+Ocitaj(F_DIO,cIdDio,"NAZ")		
endif

if EMPTY(cRadnici)
	if ( grbReduk < 2 )
		? "RADNIK     :  SVI"
	endif
else
	? "RADNIK     : "+cRadnici+"-"+RTRIM(Ocitaj(F_OSOB,cRadnici,"NAZ"))
endif

if EMPTY(cVrsteP)
	if ( grbReduk < 2 ) 
		? "VR.PLACANJA: SVE"
	endif
else
	? "VR.PLACANJA: "+RTRIM(cVrsteP)
endif

if EMPTY(cGotZir)
	if ( grbReduk < 2 )
		? "PLACANJE: gotovinsko i ziralno"
	endif
else
	? "PLACANJE: "+IF(cGotZir<>"Z","gotovinsko","ziralno")
endif

if gVodiOdj=="D"
	if EMPTY(cIdOdj)
		if ( grbReduk < 2 )
			? "ODJELJENJE : SVA"
		endif
	else
		? "ODJELJENJE : "+Ocitaj(F_ODJ,cIdOdj,"NAZ")
	endif
endif

? "PERIOD     : "+FormDat1(dDat0)+" - "+FormDat1(dDat1)

if EMPTY(cSmjena)
	if ( grbReduk < 2 )
		? "SMJENA     : SVE"
	endif
else
	? "SMJENA     : "+cSmjena
endif

return
*}


static function SetFilter(cFilter, aUsl1, aUsl2, cVrijOd, cVrijDo, cGotZir, cPartId)
*{

SELECT DOKS
SET ORDER TO TAG "2"  // "2" - "IdVd+DTOS (Datum)+Smjena"

if aUsl1<>".t."
	cFilter+=".and."+aUsl1
endif

if aUsl2<>".t."
	cFilter+=".and."+aUsl2
endif

if !(cVrijOd=="00:00" .and. cVrijDo=="23:59")
	cFilter+=".and. Vrijeme>='"+cVrijOd+"'.and. Vrijeme<='"+cVrijDo+"'"
endif

if !empty(cGotZir)
	if cGotZir=="Z"
		cFilter+=".and. placen=='Z'"
	else
		cFilter+=".and. placen<>'Z'"
	endif
endif

if !Empty(cPartId)
	cFilter+=".and. idgost==" + Cm2Str(cPartId)
endif

if !(cFilter==".t.")
	SET FILTER TO &cFilter
endif

return
*}

static function ZaglZ(dDat0, dDat1, cIdPos, cSmjena, cIdDio, cRadnici, cVrsteP, cIdOdj)
*{
?
?? PADC("ZAKLJUCENJE KASE", LEN_TRAKA)
? PADC(gPosNaz)

if !EMPTY(gIdDio)
	? PADC(gDioNaz, LEN_TRAKA)
endif

if gVSmjene=="D"
	? PADC(FormDat1(gDatum)+" Smjena: "+gSmjena, LEN_TRAKA)
else
	? PADC(FormDat1(gDatum), LEN_TRAKA)
endif
?
return
*}



/*! \fn RekVrstePl()
 *  \brief Rekapitulacija realizacije kase po vrstama placanja
 */
 
function RekVrstePl()
*{
// Rekapitulacija vrsta placanja

local nTotal
local nTotal2
local nTotal3
local nTotPos
local nTotPos2
local nTotPos3
local nTotVP
local nTotVP2
local nTotVP3

?
? PADC("REKAPITULACIJA PO VRSTAMA PLACANJA", LEN_TRAKA)
? PADC("------------------------------------", LEN_TRAKA)
?
? SPACE(5)+PADR("Naziv vrste p.",20),PADC("Iznos",14)
? SPACE(5)+REPLICATE("-",20),REPLICATE("-",14)

nTotal:=0
nTotal2:=0
nTotal3:=0

SELECT POM
SET ORDER TO 4
GO TOP

do while !eof()
	_IdPos:=pom->IdPos
	if EMPTY(cIdPos)
		SELECT kase
		HSEEK _IdPos
		?
		? REPLICATE("-", LEN_TRAKA)
		? SPACE(1)+_IdPos+":",+kase->Naz
		? REPLICATE("-", LEN_TRAKA)
	endif
	
	nTotPos:=0
	nTotPos2:=0
	nTotPos3:=0
	
	do while !eof().and.pom->IdPos==_IdPos
		nTotVP:=0
		nTotVP2:=0
		nTotVP3:=0
		_IdVrsteP:=pom->IdVrsteP
		SELECT vrstep
		HSEEK _IdVrsteP
		? SPACE(5)+vrstep->Naz
		SELECT pom
			do while !eof().and.pom->(IdPos+IdVrsteP)==(_IdPos+_IdVrsteP)
				nTotVP+=pom->Iznos
				nTotVP2+=pom->Iznos2
				nTotVP3+=pom->Iznos3
				SKIP
			enddo
			?? STR(nTotVP,14,2)
			nTotPos+=nTotVP
			nTotPos2+=nTotVP2
			nTotPos3+=nTotVP3
	enddo
	TotalKasa(_IdPos, nTotPos, nTotPos2, nTotPos3, 0, "N", "-")
	
	nTotal+=nTotPos
	nTotal2+=nTotPos2
	nTotal3+=nTotPos3
enddo

if empty(cIdPos)
	? REPL ("=", LEN_TRAKA)
	? PADC ("SVE KASE", 20) + STR (nTotal, 20, 2)
	? REPL ("=", LEN_TRAKA)
endif

return
*}



/*! \fn TblCrePom()
 *  \brief Kreiranje pomocne tabele za izvjestaj realizacije kase
 */

static function TblCrePom()
*{
local aDbf := {}
local cPomDbf

AADD(aDbf,{"IdPos"    ,"C",  2, 0})
AADD(aDbf,{"IdRadnik" ,"C",  4, 0})
AADD(aDbf,{"IdVrsteP" ,"C",  2, 0})
AADD(aDbf,{"IdOdj"    ,"C",  2, 0})
AADD(aDbf,{"IdRoba"   ,"C", 10, 0})
AADD(aDbf,{"IdCijena" ,"C",  1, 0})
AADD(aDbf,{"Kolicina" ,"N", 12, 3})
AADD(aDbf,{"Iznos"    ,"N", 20, 5})
AADD(aDbf,{"Iznos2"   ,"N", 20, 5})
AADD(aDbf,{"Iznos3"   ,"N", 20, 5})
AADD(aDbf,{"K1"       ,"C",  4, 0})
AADD(aDbf,{"K2"       ,"C",  4, 0})

NaprPom(aDbf)

cPomDbf:=ToUnix(PRIVPATH+"pom.dbf")
CREATE_INDEX("1" ,"IdPos+IdRadnik+IdVrsteP+IdOdj+IdRoba+IdCijena",cPomDbf,.t.)
CREATE_INDEX("2" ,"IdPos+IdOdj+IdRoba+IdCijena"                  ,cPomDbf,.f.)
CREATE_INDEX("3" ,"IdPos+IdRoba+IdCijena"                        ,cPomDbf,.f.)
CREATE_INDEX("4" ,"IdPos+IdVrsteP"                               ,cPomDbf,.f.)
CREATE_INDEX("K1","IdPos+K1+idroba"                              ,cPomDbf,.f.)

use (cPomDbf) new
set order to 1

return
*}

/*! \fn RealPoRadn()
 *  \brief Prikaz realizacije po radnicima
 */

static function RealPoRadn()
*{
?
? "SIFRA PREZIME I IME RADNIKA"
? "-----",REPLICATE("-", 34)
nTotal:=0
nTotal2:=0
nTotal3:=0

SELECT pom
GO TOP
do while !eof()
	nTotPos:=0
	nTotPos2:=0
	nTotPos3:=0
	_IdPos:=pom->IdPos
	do while !eof() .and. pom->IdPos==_IdPos
		nTotRadn:=0
		nTotRadn2:=0
		nTotRadn3:=0
		_IdRadnik:=pom->IdRadnik
		SELECT osob
		set order to tag "NAZ"
		HSEEK _IdRadnik
		SELECT pom
		? IdRadnik+"  "+PADR(osob->Naz,34)
		? REPLICATE("-",5),REPLICATE("-",34)
		do while !eof() .and. pom->(IdPos+IdRadnik)==(_IdPos+_IdRadnik)
			nTotVP:=0
			nTotVP2:=0
			nTotVP3:=0
			_IdVrsteP:=pom->IdVrsteP
			SELECT vrstep
			HSEEK _IdVrsteP
			SELECT pom
			? SPACE(6)+PADR(vrstep->Naz,20)
			do while !Eof() .and. pom->(IdPos+IdRadnik+IdVrsteP)==(_IdPos+_IdRadnik+_IdVrsteP)
				nTotVP+=pom->Iznos
				nTotVP2+=pom->Iznos2
				nTotVP3+=pom->Iznos3
				SKIP
			enddo
			?? STR(nTotVP,14,2)
			nTotRadn+=nTotVP
			nTotRadn2+=nTotVP2
			nTotRadn3+=nTotVP3
		enddo // radnik
		? SPACE(6)+REPLICATE("-",34)
		? SPACE(6)+PADL("UKUPNO",20)+STR(nTotRadn,14,2)
		if nTotRadn2<>0
			? SPACE(6)+PADL("PARTICIPACIJA:",20)+STR(nTotRadn2,14,2)
		endif
       		if nTotRadn3<>0
       			? SPACE(6)+PADL(NenapPop(),20)+STR(nTotRadn3,14,2)
       			? SPACE(6)+PADL("UKUPNO NAPLATA:",20)+STR(nTotRadn-nTotRadn3+nTotRadn2,14,2)
       		endif
       		? SPACE(6)+REPLICATE("-",34)
       		nTotPos+=nTotRadn
       		nTotPos2+=nTotRadn2
       		nTotPos3+=nTotRadn3
	enddo  // kasa
	? REPLICATE("-",40)
	? PADC("UKUPNO KASA "+_IdPos,20)+STR(nTotPos,20,2)
	if nTotPos2<>0
       		? PADL("PARTICIPACIJA:", 20)+STR(nTotPos2,20,2)
	endif
	if nTotPos3<>0
       		? PADL(NenapPop(),20)+STR(nTotPos3,20,2)
       		? PADL("UKUPNO NAPLATA:",20)+STR(nTotPos-nTotPos3+nTotPos2,20,2)
	endif
	? REPLICATE("-",40)
	nTotal+=nTotPos
	nTotal2+=nTotPos2
	nTotal3+=nTotPos3
enddo // ! pom->eof()
if EMPTY(cIdPos)
	? REPLICATE("=",40)
	? PADC("SVE KASE",20)+STR(nTotal,20,2)
	? REPLICATE("=",40)
endif
    		
// idemo skupno sa vrstama placanja
if cPVrstePl=="D"
	RekVrstePl()
endif 
 
if !fZaklj.and.fPrik$"RO"
// ako je zakljucenje NE realizacija po robama
	
	set_zagl()
	
	nTotal:=0
	nTotal2:=0
	nTotal3:=0
	
	SELECT POM
	set order to 3
	go top
	do while !eof()
		nTotPos:=0
		nTotPos2:=0
		nTotPos3:=0
		_IdPos:=POM->IdPos
		if empty(cIdPos)
			SELECT KASE
			hseek _IdPos
			? REPL ("-", LEN_TRAKA)
			? space(1)+_idpos+":", + KASE->Naz
			? REPL ("-", LEN_TRAKA)
		endif
		SELECT POM
		
		do while !eof() .and. pom->idPos==_IdPos
			SELECT ROBA
			HSEEK pom->idRoba
		
			altd()
			cStr1 := ""
			
			if grbStId == "D"
				cStr1 += ALLTRIM(pom->idroba) + " "
			endif
			
			cStr1 += ALLTRIM(roba->naz)
			cStr1 += " (" + ALLTRIM(roba->jmj) + ") "
			nLen1 := LEN(cStr1)
			
			SELECT POM
			
			_IdRoba:=POM->idRoba
			nRobaIzn:=0
			nRobaKol:=0
			nSetova:=0
			nRobaIzn2:=0
			nRobaIzn3:=0
			do while !eof() .and. POM->(IdPos+IdRoba)==(_IdPos+_IdRoba)
				nKol:=0
				nIzn:=0
				nIzn2:=0
				nIzn3:=0
				_IdCijena:=POM->IdCijena
				do while !eof() .and. POM->(IdPos+IdRoba+IdCijena)==(_IdPos+_IdRoba+_IdCijena)
					nKol+=POM->Kolicina
					nIzn+=POM->Iznos
					nIzn2+=POM->Iznos2
					nIzn3+=POM->Iznos3
					
					skip
				
				enddo
				
				cStr2 := ""
				cStr2 += show_number(nKol, nil, -8)
				nLen2 := LEN(cStr2)
				
				cStr3 := show_number(nIzn, PIC_UKUPNO)
				nLen3 := LEN(cStr3)
				
				aReal := SjeciStr(cStr1, LEN_TRAKA)
				
				for i:=1 to LEN(aReal)
					? RTRIM(aReal[i])
					nLenRow := LEN(RTRIM(aReal[i]))
				next
				
				if  nLen2 + 1 + nLen3 > LEN_TRAKA - nLenRow
					? PADL(cStr2 + SPACE(LEN_RAZMAK) + cStr3, LEN_TRAKA)
				else
					?? PADL(cStr2 + SPACE(LEN_RAZMAK) + cStr3, LEN_TRAKA - nLenRow)
				endif
				
				if glPorNaSvStRKas
					PrikaziPorez(nIzn,roba->idTarifa)
				endif

				nRobaIzn+=nIzn
				nRobaIzn2+=nIzn2
				nRobaIzn3+=nIzn3
				nRobaKol+=nKol
				nSetova++
				SELECT POM
			enddo
			if nSetova>1
				? PADL("Ukupno roba ",16),STR(nRobaKol,10,3)
				?? TRANSFORM(nRobaIzn,"999,999,999.99")
			endif
			nTotPos+=nRobaIzn
			nTotPos2+=nRobaIzn2
			nTotPos3+=nRobaIzn3
		enddo

		TotalKasa(_IdPos, nTotPos, nTotPos2, nTotPos3, 0, "N", "-")
		nTotal+=nTotPos
		nTotal2+=nTotPos2
		nTotal3+=nTotPos3
	enddo
	if empty(cIdPos)
		? REPL("-",LEN_TRAKA)
		? PADC("SVE KASE UKUPNO:",25),TRANSFORM(nTotal,"999,999,999.99")
		? REPL("-",LEN_TRAKA)
	endif
endif
return
*}

static function set_zagl()
local cLinija

cLinija := REPLICATE("-", LEN_TRAKA)

?

if ( grbReduk < 2 )
	? cLinija
endif

? PADC("REALIZACIJA PO ROBAMA", LEN_TRAKA)

if ( grbReduk < 2 )
	? cLinija
endif

?

cStr1:=""

if grbStId == "D"
	cStr1 += "Sifra, naziv, jmj, kolicina"
else
	cStr1 += "Naziv, jmj, kolicina"
endif

cHead := cStr1 + PADL("vrijednost", LEN_TRAKA - LEN(cStr1))

? cHead

? cLinija

return


// dodaj u matricu sa porezima stavku
static function _a_to_porezi( aPorezi, cTarifa, nStopa, nIznSaPDV )
local nScan
local nOsnovica
local nPorez

// porezna matrica
// aPorezi = { idtarifa, uk_sa_pdv, osnovica, pdv }

// izracunaj porez
if nStopa <> 0
	nOsnovica := ROUND( nIznSaPDV / ( 1 + ( nStopa / 100) ), 2 )
	nPorez := ROUND( nOsnovica * ( nStopa / 100 ), 2 )
else
	nOsnovica := nIznSaPDV
	nPorez := 0
endif

// potrazi ga u matrici pa dodaj ili saberi

nScan := ASCAN( aPorezi, {|xVar| xVar[1] == cTarifa })

if nScan <> 0

	// dodaj na ukupni iznos sa PDV
	aPorezi[ nScan, 2 ] := ( aPorezi[ nScan, 2 ] + nIznSaPDV )
	// dodaj na ukupnu osnovicu
	aPorezi[ nScan, 3 ] := ( aPorezi[ nScan, 3 ] + nOsnovica )
	// dodaj na ukupni porez
	aPorezi[ nScan, 4 ] := ( aPorezi[ nScan, 4 ] + nPorez )
else
		
	AADD( aPorezi, { cTarifa, cIznSaPDV, nOsnovica, nPorez } )

endif

return




/*! \fn RealPoOdj(fPrik, nTotal2, nTotal3)
 *  \brief Prikaz realizacije po odjeljenjima
 */

static function RealPoOdj(fPrik, nTotal2, nTotal3, aPorezi )
local nTStopa

// porezna matrica
aPorezi := {}

if (fPrik $ "PO")
	// daj mi pazar
	?
	if cK1=="D"
		? PADC("PROMET PO GRUPAMA",LEN_TRAKA)
	else
		? PADC("PROMET PO ODJELJENJIMA",LEN_TRAKA)
	endif
	? PADC("------------------------------------",LEN_TRAKA)
	?
	? "Sifra Naziv odjeljenja          IZNOS"
	? "----- ----------------------- ----------"
	// 0123456789012345678901234567890123456789
	nTotal:=0
	nTotal2:=0
	nTotal3:=0
	SELECT POM
	set order to 2
	go top
	while !eof()
		_IdPos:=pom->IdPos
		if empty(cIdPos)
			SELECT kase
			hseek _IdPos
			? REPL("-",LEN_TRAKA)
			? space(1)+_idpos+":", KASE->Naz
			? REPL("-",LEN_TRAKA)
			SELECT POM
		endif
		nTotPos:=0
		nTotPos2:=0
		nTotPos3:=0
		do while (!EOF() .and. pom->IdPos==_IdPos)
			nTotOdj:=0
			nTotOdj2:=0
			nTotOdj3:=0
			_IdOdj:=POM->IdOdj
			SELECT odj
			HSEEK _IdOdj
			? PADL(ALLTRIM(_IdOdj),5),PADR(odj->naz,22)+" "
			SELECT POM
			do while !eof() .and. pom->(IdPos+IdOdj)==(_IdPos+_IdOdj)
				nTotOdj+=pom->Iznos
				nTotOdj2+=pom->Iznos2
				nTotOdj3+=pom->Iznos3
				skip
			enddo
			?? TRANSFORM(nTotOdj,"999,999.99")
			nTotPos+=nTotOdj
			nTotPos2+=nTotOdj2
			nTotPos3+=nTotOdj3
		enddo
		TotalKasa(_IdPos, nTotPos, nTotPos2, nTotPos3, 0, "N", "-")
		nTotal+=nTotPos
		nTotal2+=nTotPos2
		nTotal3+=nTotPos3
	enddo
	if empty(cIdPos)
		? REPL("=",LEN_TRAKA)
		? PADC("SVE KASE UKUPNO", 25)+TRANSFORM(nTotal,"999,999,999.99")
		? REPL("=",LEN_TRAKA)
	endif
endif

if (fPrik $ "RO").or.cK1=="D"
	// realizacija kase, po odjeljenjima, ROBNO
	nTotal := 0
	SELECT POM
	if cK1=="D"
		set order to TAG "K1"   // IdPos+IdOdj+IdRoba+IdCijena
	else
		set order to 2   // IdPos+IdOdj+IdRoba+IdCijena
	endif
	go top
	do while !EOF()
		_IdPos := POM->IdPos
		if empty(cIdPos)
			SELECT KASE
			HSEEK _IdPos
			? REPL("-",LEN_TRAKA)
			? space(1)+_idpos+":", KASE->Naz
			? REPL("-",LEN_TRAKA)
			SELECT POM
		endif
		nTotPos:=0
		nTotPos2:=0
		nTotPos3:=0
		nTotPosK:=0
		do while !eof() .and. pom->IdPos==_IdPos
			if cK1=="D"
				_IdOdj:=pom->k1
				bOdj:={|| pom->k1}
			else
				_IdOdj := POM->IdOdj
				SELECT ODJ
				HSEEK _IdOdj
				bOdj:={|| pom->idodj}
				? " ", _IdOdj, ODJ->Naz
			endif
			? REPLICATE ("-", LEN_TRAKA)
			? "SIFRA    NAZIV", Space (19), "(JMJ)"
			? SPACE(10)+"Set c.  Kolicina    Vrijednost"
			? REPLICATE("-", LEN_TRAKA)
			nTotOdj:=0
			nTotOdj2:=0
			nTotOdj3:=0
			nTotOdjK:=0
			SELECT POM
			do while !eof() .and. POM->(IdPos)+eval(bOdj)==(_IdPos+_IdOdj)
				_IdRoba:=POM->IdRoba
				
				SELECT ROBA
				HSEEK _IdRoba
				
				SELECT tarifa
				HSEEK roba->idtarifa
				
				nTStopa := tarifa->opp
				
				SELECT ROBA
				
				? _IdRoba, LEFT(ROBA->Naz,25), "("+ROBA->Jmj+")"
				
				if cK1=="D"
					_K2:=roba->k2
					if roba->tip $ "TU"  // usluge ili tarife
						_K2:="X"
					endif
				else
					_K2:=""
				endif
				SELECT POM
				nRobaIzn:=0
				nRobaIzn2:=0
				nRobaIzn3:=0
				nRobaKol:=0
				nSetova:=0
				do while !eof() .and. pom->idPos+EVAL(bOdj)+pom->IdRoba==(_IdPos+_IdOdj+_IdRoba)
					_IdCijena:=POM->IdCijena
					nKol:=0
					nIzn:=0
					nIzn2:=0
					nIzn3:=0
					do while !eof() .and. pom->IdPos+eval(bOdj)+pom->(IdRoba+IdCijena)==(_IdPos+_IdOdj+_IdRoba+_IdCijena)
						nKol+=POM->Kolicina
						nIzn+=POM->Iznos
						nIzn2+=POM->Iznos2
						nIzn3+=POM->Iznos3
						skip
					enddo
					? SPACE(10)+PADC(_IdCijena,6)+STR(nKol,10,3)+TRANSFORM(nIzn,"999,999,999.99")
					nRobaIzn+=nIzn
					nRobaKol+=nKol
					nRobaIzn2+=nIzn2
					nRobaIzn3+=nIzn3
						
					// dodaj u poreznu matricu
					_a_to_porezi( @aPorezi, tarifa->id, nTStopa, nIzn )

					nSetova++
					SELECT POM
				enddo
				if nSetova>1
					? PADL("Ukupno roba ",15),STR(nRobaKol,10,3)+TRANSFORM(nRobaIzn,"999,999,999.99")
				endif
				nTotOdj+=nRobaIzn
				nTotOdj2+=nRobaIzn2
				nTotOdj3+=nRobaIzn3
				if !(_K2="X")
					nTotOdjk+=nRobaKol
				endif
			enddo
			? REPL("-",LEN_TRAKA)
			if cK1=="D"
				? PADC("UKUPNO "+_idodj,16)
				?? STR(nTotOdjk,10,2)
			else
				? PADC("UKUPNO ODJELJENJE",26)
			endif
			?? TRANSFORM(nTotOdj,"999,999,999.99")
			? REPL("-",LEN_TRAKA)
			?
			nTotPos+=nTotOdj
			nTotPosK+=nTotOdjk
		enddo

		TotalKasa(_IdPos, nTotPos, nTotPos2, nTotPos3, nTotPosk, cK1, "=")
		nTotal+=nTotPos
		nTotal2+=nTotPos2
		nTotal3+=nTotPos3
	enddo
	if empty(cIdPos)
		? REPL("*",LEN_TRAKA)
		? PADC("SVE KASE UKUPNO",25), TRANSFORM(nTotal,"999,999,999.99")
		? REPL("*",LEN_TRAKA)
	endif
endif
return
*}

static function TotalKasa(cIdPos, nTotPos, nTotPos2, nTotPos3, nTotPosk, cK1, cPodvuci)
*{

? REPL(cPodvuci, LEN_TRAKA)
if cK1=="D"
	? PADC("UKUPNO KASA "+_idpos, 16),STR(nTotPosK,10,2)
	?? TRANSFORM(nTotPos,"999,999,999.99")
else
	? PADC("UKUPNO KASA "+_idpos, 25), TRANSFORM(nTotPos,"999,999,999.99")
endif
if nTotPos2<>0
	? PADL("PARTICIPACIJA:",25)+STR(nTotPos2,15,2)
endif
if nTotPos3<>0
	? PADL(NenapPop(),25)+STR(nTotPos3,15,2)
	? PADL("UKUPNO NAPLATA:",25)+STR(nTotPos-nTotPos3+nTotPos2,15,2)
endif
? REPL(cPodvuci, LEN_TRAKA)
?

return
*}



static function PrikaziPorez(nIznosSt,cIdTarifa)
*{
local nArr
local nMpVBP, nPPPIznos, nPPIznos, nPPUIznos, nPPP, nPPU
nArr:=SELECT()

// obracun poreza
SELECT (F_TARIFA)
if !used()
	O_TARIFA
endif
Seek2(cIdTarifa)

nPPP:=tarifa->opp
nPPU:=tarifa->ppp

if IzFMKINI("POREZI","PPUgostKaoPPU","N")=="D"
	nMpVBP:=nIznosSt/(1+zpp/100+ppp/100)/(1+opp/100)
	nPPPIznos:=nMPVBP*opp/100
	nPPIznos:=(nMPVBP+nPPPIznos)*zpp/100
else
	nMpVBP:=nIznosSt/(zpp/100+(1+opp/100)*(1+ppp/100))
	nPPPIznos:=nMPVBP*opp/100
	nPPIznos:=nMPVBP*zpp/100
endif

? SPACE(1) + "PPP(" + ALLTRIM(STR(nPPP)) + "%) " + ALLTRIM(STR(nPPPIznos))	

nPPUIznos:=(nMPVBP+nPPPIznos)*ppp/100

?? " PPU(" + ALLTRIM(STR(nPPU)) + "%) " + ALLTRIM(STR(nPPUIznos))

select (nArr)
return
*}

