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
 

/*! \fn StampaRac(cIdPos, cBrDok, lPrepis, cIdVrsteP, dDatum)
 *  \brief Stampa racuna koji tek treba da se azurira
 *  \param cIdPos  - Prodajno mjesto
 *  \param cBrDok  - Broj dokumenta u _POS.DBF
 */
 
function StampaRac(cIdPos, cBrDok, lPrepis, cIdVrsteP, dDatumRn, aVezani)
*{

local cDbf
local cIdRadnik
local aPom:={}
local cPom
private nIznos
private nSumaPor:=0

if lPrepis==NIL
	lPrepis:=.f.
endif

if cIdVrsteP==NIL
	cIdVrsteP:=""
endif

if dDatumRn==NIL
	dDatumRn:=gDatum
endif

SELECT (F_ODJ)

if !used()
	O_ODJ  
	// otvori odjeljenje radi APOTEKA....
endif

altd()


if lPrepis
	cPosDB:="POS"
else
	cPosDB:="_POS"
endif

SELECT &cPosDB

//
cCmnBrDok := cBrDok


nIznos:=0
nNeplaca:=0

for i:=1 to LEN(aVezani)

// 
dDatumRn :=aVezani[i, 4]
cBrDok := aVezani[i, 2]

Seek2(cIdPos+VD_RN+dtos(dDatumRn)+cBrDok)

if !lPrepis
	cSto:=&cPosDB->Sto
	cIdRadnik:=&cPosDB->IdRadnik
	cSmjena:=&cPosDB->Smjena
else
	altd()
	SELECT DOKS
	Seek2 (cIdPos+VD_RN+DToS(dDatumRn)+cBrDok)
	cSto      := DOKS->Sto
	cIdRadnik := DOKS->IdRadnik
	cSmjena   := DOKS->Smjena
endif

SELECT &cPosDB

altd()


if VarPopPrekoOdrIzn()
	gIsPopust:=.f.
endif

do while !eof().and. &cPosDB->(IdPos+IdVd+dtos(Datum)+BrDok)==(cIdPos+VD_RN+dtos(dDatumRn)+cBrDok)
	
	if (gRadniRac="D" .and. gVodiTreb=="D" .and. GT=OBR_NIJE)
      		// vodi se po trebovanjima, a za ovu stavku trebovanje 
		// nije izgenerisano
      		// s obzirom da se nalazimo u procesu zakljucenja, 
		//nuliramo kolicinu
      		replace kolicina with 0 // nuliraj kolicinu
  	endif
	
	nIznos += Kolicina*Cijena
	
	select odj
	seek &cPosDB->idodj
	select &cPosDB
  	
	if right(odj->naz,5)=="#1#0#"
     		nNeplaca+=Kolicina*Cijena - ncijena*Kolicina
  	elseif right(odj->naz,6)=="#1#50#"
     		nNeplaca+=Kolicina*Cijena/2 - ncijena
  	endif
	
  	if (gPopVar="P" .and. gClanPopust) 
		if !EMPTY(cPartner)
			nNeplaca+=kolicina*NCijena
		endif
	endif
	
	if (gPopVar="P" .and. !gClanPopust)
		nNeplaca+=kolicina*NCijena
	endif
	
  	SKIP
enddo

//
next
//

if gDisplay=="D"
	Send2ComPort(CHR(10)+CHR(13))
	Send2ComPort(CHR(10)+CHR(13))
	Send2ComPort(CHR(30) + "UKUPAN IZNOS RN:")
	//Send2ComPort(CHR(30))
	Send2ComPort(CHR(22))
	Send2ComPort(CHR(13))
	Send2ComPort(ALLTRIM(STR(nIznos-nNeplaca, 10, 2)))
endif

// Ispisi iznos racuna velikim slovima
PisiIznRac(nIznos-nNeplaca)

START PRINT2 CRET gLocPort,SPACE(5)

cBrDok := cCmnBrDok

if lPrepis
	cTime:=RacHeder(cIdPos,DToS(dDatumRn)+cBrDok,cSto,.t., aVezani)
else
	cTime:=RacHeder(cIdPos,DTOS(dDatumRn)+cStalRac,cSto,.f., aVezani)
endif

SELECT &cPosDB

seek cIdPos+"42"+dtos(dDatumRn)+cBrDok

aPorezi:={}
aRekPor:={}

//do while !eof().and.(IdPos+IdVd+DTOS(datum)+BrDok)==(cIdPos+VD_RN+dtos(dDatumRn)+cBrDok)


do while !eof().and.(IdPos+IdVd+DTOS(datum))==(cIdPos+VD_RN+dtos(dDatumRn))
	if ASCAN(aVezani, {|aVal| aVal[2] == &cPosDB->brdok}) == 0
		skip
		loop
	else
		cBrDok := &cPosDB->brdok
	endif
	
	cPom:=" * "
  	Scatter()
  	_Kolicina := 0
  	do while !eof().and.&cPosDB->(IdPos+IdVd+dtos(datum)+BrDok)==(cIdPos+"42"+dtos(dDatumRn)+cBrDok).and.&cPosDB->(IdRoba+IdCijena)==(_IdRoba+IdCijena).and.&cPosDB->Cijena==_Cijena
    		_Kolicina += &cPosDB->Kolicina
    		SKIP
  	enddo
  	nIznosST:=0
  	if round(_kolicina,4)<>0
		if !lPrepis
			cPom+=TRIM(_IdRoba)+" - "+TRIM(_RobaNaz)
		else
			select roba
			seek TRIM(_idRoba)
			cPom+=TRIM(_idRoba)+" - "+TRIM(roba->naz)
			select pos
		endif
		aPom:=SjeciStr(cPom,38)
		for i:=1 to len(aPom)
			? aPom[i]
		next
   		SELECT &cPosDB
		
   		nIznosSt:=_Kolicina*(_Cijena-_NCijena)
   		
		if gKolDec==N_ROUNDTO
	   		? SPACE(1)+PADR("(T" + ALLTRIM(_IdTarifa)+")",6)+STR(_Kolicina,9,N_ROUNDTO),if(!lPrepis,_Jmj,roba->jmj),"x "
		else
	   		? SPACE(1)+PADR("(T" + ALLTRIM(_IdTarifa)+")",6)+STR(_Kolicina,9,gKolDec),if(!lPrepis,_Jmj,roba->jmj),"x "
		endif
		if gCijDec==N_ROUNDTO
	   		?? PADR(ALLTRIM(STR(_Cijena,8,N_ROUNDTO)),8)+STR(nIznosSt,8,N_ROUNDTO)
		else
	   		?? PADR(ALLTRIM(STR(_Cijena,8,gCijDec)),8)+STR(nIznosSt,8,N_ROUNDTO)
		endif
  	endif
  	
	// obracun poreza
	SELECT TARIFA
  	Seek2(_IdTarifa)
		
	if glPorezNaSvakuStavku
		nPPP:=tarifa->opp
		nPPU:=tarifa->ppp
		nPP:=tarifa->zpp
	endif
	// Izracunaj MPC bez poreza
    	nMPVBP:=nIznosSt/(1+zpp/100+ppp/100)/(1+opp/100)
        
	// varijanta starog obracuna poreza
        if gStariObrPor
  		if IzFMKINI("POREZI","PPUgostKaoPPU","N")=="D"
    			nMpVBP:=nIznosSt/(1+zpp/100+ppp/100)/(1+opp/100)
    			nPPPIznos:=nMPVBP*opp/100
    			nPPIznos:=(nMPVBP+nPPPIznos)*zpp/100
  		else
    			nMpVBP:=nIznosSt/(zpp/100+(1+opp/100)*(1+ppp/100))
    			nPPPIznos:=nMPVBP*opp/100
    			nPPIznos:=nMPVBP*zpp/100
  		endif

		if glPorezNaSvakuStavku  	
			? SPACE(1) + "PPP(" + ALLTRIM(STR(nPPP)) + "%) " + ALLTRIM(STR(nPPPIznos))	
		endif

		nPPUIznos:=(nMPVBP+nPPPIznos)*ppp/100

		if glPorezNaSvakuStavku
			?? " PPU(" + ALLTRIM(STR(nPPU)) + "%) " + ALLTRIM(STR(nPPUIznos))
		endif

		nSumaPor+=nPPPiznos+nPPUiznos+nPPIznos
		nPoz:=ASCAN(aPorezi,{|x| x[1]==_IdTarifa})
  		if nPoz==0
     			AADD(aPorezi,{_IdTarifa,nPPPiznos,nPPUiznos,nPPIznos,{opp,ppp,zpp}})
  		else
     			aPorezi[nPoz][2]+=nPPPiznos
     			aPorezi[nPoz][3]+=nPPUiznos
     			aPorezi[nPoz][4]+=nPPiznos
  		endif
    	else // stara varijanta
   		SetAPorezi(@aPorezi)
		aIPor:=RacPorezeMP(aPorezi, nMPVBP, nIznosSt, 0)
		? " PPP(" + STR(nPPP,2,0) + "%)" + ALLTRIM(STR(ROUND(aIPor[1],2)))
		?? " PPU(" + STR(nPPU,2,0) + "%)" + ALLTRIM(STR(ROUND(aIPor[2],2)))
		?? " PP(" + STR(nPP,2,0) + "%)" + ALLTRIM(STR(ROUND(aIPor[3],2)))
		nSumaPor+=aIPor[1]+aIPor[2]+aIPor[3]
		nPoz:=ASCAN(aRekPor,{|x| x[1]==_IdTarifa})
  		if nPoz==0
    			AADD(aRekPor, {_idtarifa, aIPor[1], aIPor[2], aIPor[3], aIPor[1]+aIPor[2]+aIPor[3]})
  		else
     			aRekPor[nPoz][2]+=aIPor[1]
     			aRekPor[nPoz][3]+=aIPor[2]
     			aRekPor[nPoz][4]+=aIPor[3]
  		endif
	
    	endif
   	SELECT &cPosDB
enddo

SEEK cIdPos+"42"+dtos(dDatumRn)+cBrDok
do while !eof().and.&cPosDB->(IdPos+IdVd+dtos(datum)+BrDok)==(cIdPos+VD_RN+dtos(dDatumRn)+cBrDok)
	replace m1 with "S" // odstampano
  	skip
enddo
// iznos racuna
? " " + REPLICATE("=", 38)
? PADL("UKUPNO (" + gDomValuta + ")", 30),IIF(nIznos >= 0, TRANSFORM(nIznos, "****9.99"),TRANSFORM(nIznos,"99999.99"))

if nNeplaca<>0 // postoji oslobadjanje
	?
 	? " " + REPLICATE ("-", 38)
 	? PADL ("  POPUST: (" + gDomValuta + ")", 30), TRANSFORM (nNeplaca, "99999.99")
 	? " " + REPLICATE ("=", 38)
 	? PADL ("NAPLATITI (" + gDomValuta + ")", 30),IIF(nIznos-nNePlaca >= 0,TRANSFORM (nIznos-nNeplaca, "****9.99"),TRANSFORM(nIznos-nNePlaca, "99999.99"))
endif
? " " + REPLICATE ("=", 38)
if !empty(gStrValuta)
	?
  	? PADL ("UKUPNO (" + gStrValuta + ")", 30),IIF (nIznos >= 0, TRANSFORM (StrValuta(gStrValuta,doks->datum)*nIznos, "****9.99"),TRANSFORM(StrValuta(gStrValuta,doks->datum)*nIznos, "99999.99"))
  	? " " + REPLICATE ("=", 38)
endif

// porezi
// stari obracun poreza

if gStariObrPor
	? " U iznos uracunati porezi "
	if gPoreziRaster=="D"
		ASORT(aPorezi,,, {|x, y| x[1] < y[1]})
   		fPP:=.f. // ima posebnog poreza
   		for i:=1 to len(aPorezi)
     			if round(aPorezi[i,4],4)<>0
        			fPP:=.t.
        			exit
     			endif
   		next
   		? " T.br.        PPP       PPU      Iznos"
   		if fPP
      			? "               PP"
   		endif
   		nPPP:=nPPU:=0
   		nPP:=0
   		for nCnt:=1 to len(aPorezi)
      			if IzFMKIni("TOPS","NaRacunuPrikazatiProcentePoreza","D",KUMPATH)=="D"
        			? " T" + PADR(aPorezi[nCnt][1],4)
        			?? " (PPP "+STR(aPorezi[nCnt][5][1],2,0)+"%, PPU "+STR(aPorezi[nCnt][5][2],2,0)+IF(!fPP,"%)   ","%, PP "+STR(aPorezi[nCnt][5][3],2,0)+"%)")
				? SPACE(10)
      			else
        			? " T" + PADR (aPorezi[nCnt][1], 4) + "    "
      			endif
      			?? STR ( aPorezi[nCnt][2], 7, N_ROUNDTO) + "   " +STR(aPorezi[nCnt][3], 7, N_ROUNDTO) + "    " + STR(round(aPorezi[nCnt][2],N_ROUNDTO)+round(aPorezi[nCnt][3],N_ROUNDTO)+round(aPorezi[nCnt][4],N_ROUNDTO), 7, N_ROUNDTO)
      			if round(aPorezi[nCnt][4],4)<>0
        			? space(10)+STR ( aPorezi[nCnt][4], 7, N_ROUNDTO)
      			endif

      			nPPP+=round(aPorezi[nCnt][2],N_ROUNDTO)
      			nPPU+=round(aPorezi[nCnt][3],N_ROUNDTO)
      			nPP+=round(aPorezi[nCnt][4],N_ROUNDTO)
   		next
   		? " " + REPLICATE ("-", 38)
   		? " UKUPNO   " + STR(nPPP,7,N_ROUNDTO) + "   " +STR(nPPU,7,N_ROUNDTO) + "    " + STR(nPPP+nPPU+nPP,7,N_ROUNDTO)
   		if fPP
      			? "          " +STR(nPP,7,N_ROUNDTO)
   		endif
	else
		?? LTRIM (STR (nSumaPor, 8, N_ROUNDTO)), gDomValuta
	endif

else // stari obracun poreza
	if gPoreziRaster=="D"
		POSRekapTar(aRekPor)
	endif
endif

RacFuter(cIdRadnik, cSmjena)
END PRN2 13
SkloniIznRac()
return (cTime)
*}


/*! \fn RacHeder(cIdPos,cDatBrDok,cSto,fPrepis, aVezani)
 */
 
function RacHeder(cIdPos,cDatBrDok,cSto,fPrepis, aVezani)
//
//                    1            2               3              4
//  aVezani : {DOKS->IdPos, DOKS->(BrDok), DOKS->IdVrsteP, DOKS->Datum})
//  fprepis - .t. - vrsi se prepis racuna

local cStr
local cTime
local nCnt
local cJedan
local dDat

cStr:=MEMOREAD(PRIVPATH+AllTrim(gRnHeder))

IF ! EMPTY (cStr)
	QQOUT (cStr)
  	?
ENDIF
 
?? PADC ("RACUN br. "+ALLTRIM (cIdPos)+"-"+ALLTRIM (substr(cDatBrDok,9)), 40)

IF fPrepis
  	if !glRetroakt
  		? PADC ("PREPIS", 40)
  	endif
  	if LEN(aVezani)>1
		? PADC("ZBIRNI", 40)
	endif
	cStr := Space(16)
  	FOR nCnt := 2 TO LEN (aVezani)
    		cJedan := ALLTRIM (aVezani [nCnt][1])+"-"+ALLTRIM (aVezani [nCnt][2])
    		IF LEN (cStr) + LEN (cJedan) < 38
      			cStr += cJedan + ", "
    		ELSE
      			cStr += CHR (13)+CHR(10)+SPACE (16)+cJedan
    		ENDIF
  	NEXT
  	IF !Empty (cStr)
    		? " Vezani racuni: " + LTrim (cStr)
  	ENDIF
  	nPrev := SELECT ()
  	SELECT DOKS
  	// HSEEK (cIdPos+VD_RN+cDatBrDok)
  	cTime := DOKS->Vrijeme
  	cDat  := DTOC (DOKS->Datum)
  	SELECT (nPrev)
ELSE
	cTime := LEFT (TIME(), 5)
  	cDat := DTOC (gDatum)
ENDIF

if gModul=="HOPS"
	cStoStr := "Sto: " + cSto
else
  	cStoStr := SPACE (8)
endif

? " " + cDat + "." + SPACE (8) + cStoStr + SPACE (8) + cTime
? " " + REPLICATE ("-", 38)

RETURN (cTime)
*}

/*! \fn RacFuter(cIdRadnik,cSmjena)
 */
 
function RacFuter(cIdRadnik,cSmjena)
*{
LOCAL cStr

? " " + REPLICATE ("-", 38)
SELECT OSOB
set order to tag "NAZ"
HSEEK cIdRadnik
? " " + PADR (ALLTRIM (OSOB->Naz), 29), "Smjena " + cSmjena
cStr := MEMOREAD (PRIVPATH+AllTrim (gRnFuter))
IF !EMPTY(cStr)
	QOUT(cStr)
ENDIF
PaperFeed ()
gOtvorStr()
RETURN
*}



function StampaPrep(cIdPos, cDatBrDok, aVezani, ;
	fEkran, lViseRn, lOnlyFill)

local cDbf
local cIdRadnik
local nCnt
local aPom:={}
local cPom

//
//                    1            2               3              4
//  aVezani : {DOKS->IdPos, DOKS->(BrDok), DOKS->IdVrsteP, DOKS->Datum})
//
// Napomena: cDatBrDok sadrzi DTOS(DATUM)+BRDOK  !!

private nIznos:=0
private nSumaPor:=0
private aPorezi:={}

if fEkran==NIL
	fEkran:=.f.
else
	fEkran:=.t.
endif

if lOnlyFill == nil
	lOnlyFill := .f.
endif

if lViseRn == nil
	lViseRn := .f.
endif

altd()

select doks
set order to tag "1"

Seek2(cIdPos + VD_RN + cDatBrDok)

nTRk:=RecNo()

cSto:=DOKS->Sto
cIdRadnik:=DOKS->IdRadnik
cSmjena:=DOKS->Smjena

if gBrojSto=="D" .and. !glUgostOpc
	cZakljucen:=DOKS->zakljucen
endif

select pos

nIznos := 0
nNeplaca:=0

for nCnt:=1 to LEN(aVezani)
	select doks
	seek (aVezani[nCnt][1]+VD_RN+dtos(aVezani[nCnt][4])+aVezani[nCnt][2])
	select pos
	seek (aVezani[nCnt][1]+VD_RN+dtos(aVezani[nCnt][4])+aVezani[nCnt][2])
  	do while !EOF() .and. pos->(IdPos+IdVd+dtos(datum)+BrDok)==(aVezani[nCnt][1]+VD_RN+dtos(aVezani[nCnt][4])+aVezani[nCnt][2])
    		if gBrojSto == "D"
			//
		endif
		
		nIznos+=pos->(kolicina*cijena)
    		select odj
		seek pos->idodj
		select POS
    		if right(odj->naz,5)=="#1#0#"
       			nNeplaca+=pos->(Kolicina*Cijena - ncijena*Kolicina)
    		elseif right(odj->naz,6)=="#1#50#"
       			nNeplaca+=pos->(Kolicina*Cijena/2 - ncijena)
    		endif
    		if gPopVar="P"
			nNeplaca+=pos->(kolicina*ncijena)
		endif
    		skip
  	enddo
next

// Varijanta ugostiteljstvo
// Iskoristena funkcija StampaRac()
// Mislim da ovo i jeste najbolja varijanta, razlika je samo u _POS i POS

select doks
go nTrk
select pos

if !gStariObrPor
	if IsPDV()
		PDVStampaRac( cIdPos, doks->brdok, .t., doks->idvrstep, doks->datum, aVezani, lViseRn, lOnlyFill )
	else
		StampaRac(cIdPos, doks->brdok, .t., doks->idvrstep, doks->datum, aVezani)
	endif
	
	return
endif

// TODO: ovu funkciju izbaciti
// napraviti sve kroz StampaRac() kao sto je slucaj sa novim obracunom poreza
// Ostavljeno trenutno samo u ovoj varijanti (Ugostiteljstvo)

if fEkran
	if !lViseOdjednom
  		START PRINT CRET
  	endif
else
  	PisiIznRac(nIznos-nNeplaca)
  	START PRINT2 CRET gLocPort, SPACE (5)
endif

RacHeder (cIdPos, cDatBrDok, cSto, .T., aVezani)

SELECT POM
GO TOP
DO WHILE ! EOF()
  cPom:=" * "
  SELECT ROBA
  HSEEK POM->IdRoba

  cPom+=trim(POM->IdRoba)+" - "+TRIM(roba->Naz)
  aPom:=SjeciStr(cPom,38)
  for i:=1 to len(aPom)
  	? aPom[i]
  next

  _idTarifa := roba->IdTarifa
  cJmj := roba->JMJ

  SELECT POM
  nIznosSt := POM->(Kolicina * (Cijena-NCijena))
  // uzeti u obzir popust !!!!

  if gKolDec==N_ROUNDTO
  	? SPACE (1)+PADR ("(T" + ALLTRIM (_IdTarifa) + ")", 6)+STR (POM->Kolicina, 9, N_ROUNDTO), cJmj, "x "
  else
  	? SPACE (1)+PADR ("(T" + ALLTRIM (_IdTarifa) + ")", 6)+STR (POM->Kolicina, 9, gKolDec), cJmj, "x "
  endif

  if gCijDec==N_ROUNDTO
  	?? PADR (ALLTRIM (STR (POM->Cijena, 8, N_ROUNDTO)), 8) + STR (nIznosSt, 8, N_ROUNDTO)
  else
  	?? PADR (ALLTRIM (STR (POM->Cijena, 8, gCijDec)), 8) + STR (nIznosSt, 8, N_ROUNDTO)
  endif

  // obracun poreza
  SELECT TARIFA
  Seek2 (_IdTarifa)

  if glPorezNaSvakuStavku
  	nPPP:=tarifa->opp
  	nPPU:=tarifa->ppp
  endif

  IF IzFMKINI("POREZI","PPUgostKaoPPU","N")=="D"
    nMpVBP:=nIznosSt/(1+zpp/100+ppp/100)/(1+opp/100)
    nPPPIznos:=nMPVBP*opp/100
    nPPIznos:=(nMPVBP+nPPPIznos)*zpp/100
  ELSE
    nMpVBP:=nIznosSt/(zpp/100+(1+opp/100)*(1+ppp/100))
    nPPPIznos:=nMPVBP*opp/100
    nPPIznos:=nMPVBP*zpp/100
  ENDIF

  if glPorezNaSvakuStavku  	
  	? SPACE(1) + "PPP(" + ALLTRIM(STR(nPPP)) + "%) " + ALLTRIM(STR(nPPPIznos))	
  endif

  nPPUIznos:=(nMPVBP+nPPPIznos)*ppp/100

  if glPorezNaSvakuStavku
  	?? " PPU(" + ALLTRIM(STR(nPPU)) + "%) " + ALLTRIM(STR(nPPUIznos))
  endif

  nSumaPor += nPPPiznos + nPPUiznos + nPPIznos

  nPoz := ASCAN (aPorezi, {|x| x[1] == _IdTarifa})
  	if nPoz==0
     		AADD(aPorezi,{_IdTarifa,nPPPiznos,nPPUiznos,nPPIznos,{opp,ppp,zpp}})
  	else
     		aPorezi[nPoz][2]+=nPPPiznos
     		aPorezi[nPoz][3]+=nPPUiznos
     		aPorezi[nPoz][4]+=nPPiznos
  	endif

  SELECT POM
  SKIP
ENDDO
// iznos racuna
? " " + REPLICATE ("=", 38)
? PADL ("UKUPNO (" + gDomValuta + ")", 30), ;
  IIF (nIznos >= 0, TRANSFORM (nIznos, "****9.99"), ;
                    TRANSFORM (nIznos, "99999.99"))


if nNeplaca<>0 // postoji oslobadjanje
 ?
 ? " " + REPLICATE ("-", 38)
 ? PADL ("  POPUST: (" + gDomValuta + ")", 30), TRANSFORM (nNeplaca, "99999.99")
 ? " " + REPLICATE ("=", 38)
 ? PADL ("NAPLATITI (" + gDomValuta + ")", 30), ;
  IIF (nIznos-nNePlaca >= 0, TRANSFORM (nIznos-nNeplaca, "****9.99"), ;
                    TRANSFORM (nIznos-nNePlaca, "99999.99"))
endif

? " " + REPLICATE ("=", 38)
if !empty(gStrValuta)
  ?
  ? PADL ("UKUPNO (" + gStrValuta + ")", 30), ;
   IIF (nIznos >= 0, TRANSFORM (StrValuta(gStrValuta,doks->datum)*nIznos, "****9.99"), ;
                     TRANSFORM (StrValuta(gStrValuta,doks->datum)*nIznos, "99999.99"))
  ? " " + REPLICATE ("=", 38)
endif

// porezi
? " U iznos uracunati porezi "
IF gPoreziRaster == "D"
   ASORT (aPorezi,,, {|x, y| x[1] < y[1]})
   fPP:=.f. // ima posebnog poreza
   for i:=1 to len (aPorezi)
     if round(aPorezi[i,4],4)<>0
        fPP:=.t.
        exit
     endif
   next
   ? " T.br.        PPP       PPU      Iznos"
   if fPP
      ? "               PP"
   endif
   nPPP:=nPPU:=0
   nPP:=0
   FOR nCnt := 1 TO LEN (aPorezi)
      		if IzFMKIni("TOPS","NaRacunuPrikazatiProcentePoreza","D",KUMPATH)=="D"
        		? " T" + PADR(aPorezi[nCnt][1],4)
        		?? " (PPP "+STR(aPorezi[nCnt][5][1],2,0)+"%, PPU "+STR(aPorezi[nCnt][5][2],2,0)+IF(!fPP,"%)   ","%, PP "+STR(aPorezi[nCnt][5][3],2,0)+"%)")
        		? SPACE(10)
      		else
		        ? " T" + PADR (aPorezi[nCnt][1], 4) + "    "
		endif	
      ?? STR ( aPorezi[nCnt][2], 7, N_ROUNDTO) + "   " + ;
        STR ( aPorezi[nCnt][3], 7, N_ROUNDTO) + "    " + ;
        STR ( round(aPorezi[nCnt][2],N_ROUNDTO)+;
              round(aPorezi[nCnt][3],N_ROUNDTO)+;
              round(aPorezi[nCnt][4],N_ROUNDTO), 7, N_ROUNDTO)
      if round(aPorezi[nCnt][4],4)<>0
        ? space(10)+STR ( aPorezi[nCnt][4], 7, N_ROUNDTO)
      endif
      nPPP+=round(aPorezi[nCnt][2],N_ROUNDTO)
      nPPU+=round(aPorezi[nCnt][3],N_ROUNDTO)
      nPP +=round(aPorezi[nCnt][4],N_ROUNDTO)
   NEXT
   ? " " + REPLICATE ("-", 38)
   ? " UKUPNO   " + ;
     STR ( nPPP            , 7, N_ROUNDTO) + "   " + ;
     STR ( nPPU            , 7, N_ROUNDTO) + "    " + ;
     STR ( nPPP+nPPU+nPP   , 7, N_ROUNDTO)
   if fPP
      ? "          " + ;
       STR ( nPP             , 7, N_ROUNDTO)
   endif
ELSE
   ?? LTRIM (STR (nSumaPor, 8, N_ROUNDTO)), gDomValuta
ENDIF


RacFuter(cIdRadnik,cSmjena)

if fEkran
	if !lViseOdjednom
		END PRINT
	endif
else
  	END PRN2 13
  	SkloniIznRac()
endif

SELECT DOKS

return


// -------------------------------------------------
// prikaz informacija o racunu
// -------------------------------------------------
function _sh_rn_info( cBrRn )

MsgBeep("Formiran je racun broj: " + cBrRN )

return



/*! \fn StampaRekap(cIdRadnik, cBrojStola)
 *  \brief Stampa rekapitulacije racuna
 */
 
function StampaRekap(cIdRadnik, cBrojStola, dDatumOd, dDatumDo)
*{
local nRecNoTrenutni
local nRecNoNext
private aGrupni

cZakljucen:="N"

select doks
set order to tag 8
go top
seek gIdPos + cIdRadnik + cZakljucen

aGrupni:={}

nTek:=0
nCnt:=0

do while !EOF() .and. field->idpos==gIdPos .and. field->idradnik==cIdRadnik .and. field->datum<=dDatumDo .and. field->datum>=dDatumOd 
	
	if field->zakljucen <> "N"
		skip
		loop
	endif
	
	if (field->sto<>cBrojStola)
		skip
		loop
	endif
	// markiraj ga kao zakljucen sa Z
	if (field->zakljucen=="N")
		
		++nCnt
		
		if nTek==0
			nTek := RecNo()
		endif
		
		AADD(aGrupni, {doks->idpos, doks->brdok, doks->idvrstep, doks->datum})
		
		nTRec:=RecNo()
		skip
		nNNRec:=RecNo()
		skip -1
		replace field->zakljucen with "Z"
		
		go nNNRec	
	endif
enddo

go nTek

if nCnt==0
	MsgBeep("Ne postoje otvoreni racuni za stol br." + cBrojStola)
	return
endif

StampaPrep(gIdPos, DTOS(aGrupni[1, 4]) + aGrupni[1, 2], aGrupni, .f., .f.)

return
*}


function StampaNezakljRN(cIdRadnik, dDatumOd, dDatumDo)
*{

START PRINT CRET

cZaklj:="N"

select doks
set order to tag 8
go top

seek gIdPos + cIdRadnik + cZaklj

? SPACE(2),  Date()
? SPACE(2) + "Nezakljuceni racuni:"
? SPACE(2) + "----------------------"
?
? SPACE(2) + "Rn.Br.       Sto"
? SPACE(2) + "----------------"


do while !EOF() .and. field->idpos==gIdPos .and. field->idradnik==cIdRadnik .and. field->datum<=dDatumDo .and. field->datum>=dDatumOd
	if field->zakljucen <> "N"
		skip
		loop
	endif
	cBrDok:=doks->brdok
	cIdPos:=doks->idpos
	cBrojStola:=doks->sto

	? SPACE(2) + ALLTRIM(cIdPos) + "-" + ALLTRIM(cBrDok) + "  -> " + ALLTRIM(cBrojStola) 	
	skip
enddo

FF
END PRINT

select doks
set order to tag "1"

return
*}


function SetujZakljuceno()
*{
local nCounter

if !SigmaSif("RNZAK")
	MsgBeep("Nemate ovlastenja za koristenje opcije!!!")
	return
endif

if Pitanje(,"Setovati sve racune na zakljuceno (D/N) ?","N")=="N"
	return
endif

if Pitanje(,"Sto posto sigurni da zelite (D/N) ?","N")=="N"
	return
endif

select doks
set order to tag 0
go top

nCounter:=0

do while !EOF()
	replace field->zakljucen with "Z"
	++ nCounter
	skip
enddo

MsgBeep("Setovano ukupno " + ALLTRIM(STR(nCounter)) + " racuna!!!")

return
*}


function gvars_fill()
*{
// snimanje defaultnih postavki

// prikaz cijene sa pdv, bez pdv
add_drntext("P20", ALLTRIM(STR(grbCjen)) )
// stampa id robe na racunu
add_drntext("P21", grbStId )
// redukcija trake
add_drntext("P22", ALLTRIM(STR(grbReduk)) )

return
*}

function firma_params_fill()
*{
// podaci firme
add_drntext("I01", gFirNaziv)
add_drntext("I02", gFirAdres)
add_drntext("I03", gFirIdBroj)
add_drntext("I04", gFirPM)
add_drntext("I05", gFirTel)

return
*}

function fill_rb_traka(cIdPos, cBrDok, dDatRn, lPrepis, aRacuni, cTime)
*{
local cPosDB
local dDatumRn
local cSto
local cIdRadnik
local cSmjena
local cIdRoba
local cIdTarifa
local cRobaNaz
local nRbr
// rn vars
local nCjenBPDV
local nCjenPDV
local nKolicina
local nPopust
local nCjen2BPDV
local nCjen2PDV
local nVPDV
local nPPDV
local nUkupno
local cJmj
// drn vars
local nUBPDV
local nUPDV
local nUPopust
local nUBPDVPopust
local nUTotal
local nCSum
local cRdnkNaz := ""
local aPPs
local cBrStola
local nZakBr:=0
local nFZaokr := 0

drn_create()
drn_open()
drn_empty()

O_Nar()
O_ROBA
O_OSOB
O_POS
O_VRSTEP
O_DOKS
O_DOKSPF
O_TARIFA
O__POS


firma_params_fill()
gvars_fill()

cPosDB := "_POS"

if lPrepis
	cPosDB := "POS"
endif

select &cPosDB

// checksum
nCSum := 0

altd()

// matrica aRacuni moze da sadrzi vise racuna, u svakom slucaju sadrzi 1 racun
// aRacuni : {DOKS->IdPos, DOKS->(BrDok), DOKS->IdVrsteP, DOKS->Datum})

nUkupno := 0
nUkStavka := 0
nUBPDV := 0
nUPDV := 0
nUPopust := 0
nUBPDVPopust := 0
nUTotal := 0

for i:=1 to LEN(aRacuni)

	dDatRn := aRacuni[i, 4]
	cBrDok := aRacuni[i, 2]
	
	if lPrepis
		cStalRac := cBrDok
	endif

	Seek2(cIdPos + VD_RN + DToS(dDatRn) + cBrDok)

	if !lPrepis
		cSto := &cPosDB->sto
		cIdRadnik := &cPosDB->idradnik
		cSmjena := &cPosDB->smjena
		cTime := LEFT(TIME(), 5)
		cVrstaP := &cPosDB->idvrstep
		if gStolovi == "D"
			cBrStola := ALLTRIM(STR(&cPosDB->sto_br))
		endif
	else
		// nadji parametre kupca
		select dokspf
		set order to tag "1"
		hseek cIdPos + VD_RN + DToS(dDatRn) + cBrDok
		// nadji doks master record
		select doks
		Seek2(cIdPos + VD_RN + DToS(dDatRn) + cBrDok)
		cSto := doks->sto
		cIdRadnik := doks->idRadnik
		cSmjena := doks->smjena
		cTime := doks->vrijeme
		cVrstaP := doks->idvrstep
		if gStolovi == "D"
			cBrStola := ALLTRIM(STR(doks->sto_br))
		endif
	endif
	
	select osob
	set order to tag "NAZ"
	hseek cIdRadnik
	cRdnkNaz := osob->naz
	
	select vrstep
	set order to tag "ID"
	hseek cVrstaP
	
	if !Found()
		cNazVrstaP := "GOTOVINA"
	else
		cNazVrstaP := ALLTRIM(vrstep->naz)
	endif
	
	select &cPosDB

	if glUgost
           // nStopaPP1, nUkPP1, nStopaPP2, nUkPP2 ....
	   aStPP:={}
	   aUkPP:={}
	endif
		
	do while !eof() .and. &cPosDB->(idpos + idvd + DToS(datum) + brdok) == (cIdPos + VD_RN + DToS(dDatRn) + cBrDok)
			
		nCjenBPDV := 0
		nCjenPDV := 0
		nKolicina := 0
 		nPopust := 0
		nCjen2BPDV := 0
		nCjen2PDV := 0
 		nPDV := 0
		nIznPop := 0
			
		// trebovanja - da li ovo i dalje treba
		if gRadniRac="D" .and. gVodiTreb=="D" 
		    if !lPrepis .and. GT=OBR_NIJE
      			// vodi se po trebovanjima, a za ovu stavku trebovanje 
			// nije izgenerisano
      			// s obzirom da se nalazimo u procesu zakljucenja, 
			//nuliramo kolicinu
      			replace kolicina with 0 // nuliraj kolicinu
		    endif
  		endif
		
		cIdRoba := field->idroba
		cIdTarifa := field->idtarifa
		
		select roba
		hseek cIdRoba
		cJmj := roba->jmj
		cRobaNaz := ALLTRIM(roba->naz)
	
		if IsPlanika() .and. gRobaVelicina == "D"
			if &cPosDB->(FieldPos("velicina")) <> 0
				nVelicina := &cPosDB->velicina
				if nVelicina <> 0
					cRobaNaz += " Br: " + ALLTRIM(show_number(&cPosDb->velicina, nil, -5))
				endif
			endif
		endif
	
		// seek-uj tarifu
		select tarifa
		hseek cIdTarifa
		nPPDV := tarifa->opp

		if glUgost
			nStPP := tarifa->zpp
		else
			nStPP := 0
		endif

		select &cPosDB

		nKolicina := kolicina
 		nCjenPDV :=  cijena
		nCjenBPDV := nCjenPDV / ( 1 + (nPPDV + nStPP)/100)	


		if glUgost
		        // kantonalni porez na potrosnju
		        // stopa poreza na potr <> 0
			if ROUND(nStPP,0) <> 0
			   nPos := ASCAN(aStPP, ROUND(nStPP, 0))
			   if (nPos == 0)
			        AADD(aStPP, ROUND(nStPP, 0) )
				AADD(aUkPP, 0 )
				nPos := LEN (aStPP)
			   endif
			   aUkPP[nPos] += nStPP / 100 * nCjenBPDV * nKolicina
		        endif
		endif

		// popust - ovo treba jos dobro pregledati
		do case
			case gPopVar="P" .and. gClanPopust 
				if !EMPTY(cPartner)
					nIznPop := field->ncijena
				endif
			case gPopVar="P" .and. !gClanPopust
				nIznPop := field->ncijena
		endcase

		nPopust := 0
		
		if Round(nIznPop, 4) <> 0
		
			// cjena 2 : cjena sa pdv - iznos popusta
			nCjen2PDV := nCjenPDV - nIznPop
			
			// cjena 2 : cjena bez pdv - iznos popusta bez pdv
			nCjen2BPDV := nCjenBPDV - (nIznPop / (1 + nPPDV/100))
			
			// procenat popusta
			nPopust := ((nIznPop / (1 + nPPDV/100)) / nCjenBPDV) * 100
			
		endif
		
		// izracunaj ukupno za stavku
		nUkupno := (nKolicina * nCjenPDV) - (nKolicina * nIznPop)
		
		// izracunaj ukupnu vrijednost pdv-a
		nVPDV := ((nKolicina * nCjenBPDV) - (nKolicina * (nIznPop / (1 + nPPDV/100)))) * (nPPDV/100)

		// ukupno bez pdv-a
		nUBPDV += nKolicina * nCjenBPDV
		// ukupno pdv
		nUPDV += nVPDV
		// total racuna
		nUTotal += nUkupno

		if Round(nCjen2BPDV,2)<>0
			// ukupno popust
			nUPopust += (nCjenBPDV - nCjen2BPDV) * nKolicina
		endif
		
		// ukupno bez pdv-a - popust
		nUBPDVPopust := nUBPDV - nUPopust

		if grbCjen == 2
			nUkStavka := nUkupno
		else
			nUkStavka := nUBPDVPopust
		endif
		
		++ nCSum

		// dodaj stavku u rn.dbf
		add_rn( cStalRac, STR(nCSum, 3), "", cIdRoba, cRobaNaz, cJmj, nKolicina, Round(nCjenPDV,3), Round(nCjenBPDV,3), Round(nCjen2PDV,3), Round(nCjen2BPDV,3), Round(nPopust,2), Round(nPPDV,2), Round(nVPDV,3), Round(nUkStavka,3), 0, 0)

		select &cPosDB
  		skip
	enddo

next

if glUgost
	aPPs := { aStPP, aUkPP }
else
	aPPs := nil
endif

// zaokruzenje
//nFZaokr := zaokr_5pf( nUTotal )

// dodaj zapis u drn.dbf
add_drn( cStalRac, dDatRn, nil, nil, cTime, Round(nUBPDV,2), Round(nUPopust,2), Round(nUBPDVPopust,2), Round(nUPDV,2), Round(nUTotal - nFZaokr,2), nCSum, 0, nFZaokr, 0)
	
// mjesto nastanka racuna
add_drntext("R01", gRnMjesto)
// dodaj naziv radnika
add_drntext("R02", cRdnkNaz)
// dodaj podatak o smjeni
add_drntext("R03", cSmjena)
// vrsta placanja
add_drntext("R05", cNazVrstaP)
// dodatni text na racunu 3 linije
add_drntext("R06", gRnPTxt1)
add_drntext("R07", gRnPTxt2)
add_drntext("R08", gRnPTxt3)
// Broj linija potrebnih da se ocjepi traka
add_drntext("P12", ALLTRIM(STR(nFeedLines)))
// sekv.za otvaranje ladice
add_drntext("P13", gOtvorStr)
// sekv.za cjepanje trake
add_drntext("P14", gSjeciStr)

if gStolovi == "D"
	add_drntext("R11", cBrStola)
endif

// ako je prepis
if lPrepis
	// podaci o kupcu
	add_drntext("K01", dokspf->knaz)
	add_drntext("K02", dokspf->kadr)
	add_drntext("K03", dokspf->kidbr)
	add_drntext("D01", "A")
else
	// dodaj D01 - P - priprema
	add_drntext("D01", "P")
endif

return
*}



function PDVStampaRac( cIdPos, cBrDok, lPrepis, ;
		cIdVrsteP, dDatumRn, aRacuni, ;
		lViseRn, lOnlyFill)

local cTime

if (lOnlyFill == nil)
	lOnlyFill := .f.
endif

if (lPrepis == nil)
	lPrepis := .f.
endif

altd()

if (cIdVrsteP == nil)
	cIdVrsteP := ""
endif

if (dDatumRn == nil)
	dDatumRn := gDatum
endif

// napuni tabele podacima
fill_rb_traka(cIdPos, cBrDok, dDatumRn, lPrepis, aRacuni, @cTime)

lStartPrint := .t.

if lViseRn == .t.
	lStartPrint := .f.
endif

// ako je samo punjenje tabela - ovdje se zaustavi
if lOnlyFill
	return 
endif

if gFc_use == "D" .and. gFc_txrn == "N"
	// fiskalni racun - ne stampati !
else
	// ispisi racun
	rb_print(lStartPrint)
endif

return cTime




