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


/*! \file fmk/pos/rpt/1g/rpt_part.prg
 *  \brief Stanje racuna partnera i gostiju
 */

/*! \fn StanjePartnera()
 *  \brief Stanje racuna partnera
 */
 
function StanjePartnera()
*{
local nPom
local nDuguje
local nPotrazuje
private cGost:=SPACE(8)
private cNula:="D"
private dDat:=gDatum
private dDatOd:=gDatum-30
private cSpec:="D"
private cVrstP:=SPACE(2)
private cGotZir:=SPACE(1)
private cSifraDob:=SPACE(8)

O_RNGOST

do while .t.
	if !VarEdit({ ;
	  {"Sifra partnera (prazno-svi)","cGost","IF(!EMPTY(cGost),P_Gosti(@cGost),.t.)","@!",}, ;
	  {"Prikaz partnera sa stanjem 0 (D/N)", "cNula","cNula$'DN'","@!",}, ;
	  {"Prikazati stanje od dana ", "dDatOd",".t.",,},;
	  {"Prikazati stanje do dana ", "dDat",".t.",,},;
	  {"Prikaz G/Z/sve ", "cGotZir","cGotZir$'GZ '", "@!" ,},;
	  {"Vrsta placanja (prazno-sve) ", "cVrstP",".t.",,},;
	  {"Dobavljac ", "cSifraDob", ".t.",,},;
	  {"Prikazati specifikaciju", "cSpec","cSpec$'DN'","@!",} }, 8, 5, 19, 74,'USLOVI ZA IZVJESTAJ "STANJE PARTNERA"',"B1")
		CLOSERET
	else
		exit
	endif
enddo

O_ROBA
O_POS
O_DOKS
O_RNGOST

START PRINT CRET
?? gP12cpi

ZagFirma()

? PADC("STANJE RACUNA PARTNERA NA DAN "+ FormDat1( dDat), 80)
? PADC("----------------------------------------",80)
?
? PADR("Partner",39)+" "

if gVrstaRS=="K"
	? SPACE(4)
endif

?? PADR("Dugovanje",12), PADR("Placeno",12),"   STANJE    "
? REPLICATE("-",39)+" "

if gVrstaRS=="K"
	? SPACE(4)
endif

?? REPL("-",12), REPL("-",12), REPL("-",14)

nSumaSt:=0
nSumaNije:=0
nSumaJest:=0
nBrojacPartnera:=1
nBrojacStavki:=1
altd()

SELECT DOKS

// "IdGost+Placen+DTOS (Datum)"
set order to 3        
seek cGost

do while !eof() 

	if (doks->datum<dDatOd .or. doks->datum>dDat)
		skip
		loop
	endif
	
	if empty(DOKS->IdGost)
		skip
		loop
	endif
	
	// G-gotovina Z-ziral
	if !Empty(cGotZir)
		do case
		case cGotZir == "G"
			if doks->placen <> " "
				skip
				loop
			endif
		case cGotZir == "Z"
			if doks->placen <> cGotZir
				skip
				loop
			endif
		endcase
	endif
	
	nPrviRec:=RECNO()
	fPisi:=.f.
	nPlacJest:=0
	nPlacNije:=0
	cIdGost:=DOKS->IdGost
	
	do while !eof() .and. DOKS->IdGost==cIdGost 
	
		if (doks->datum<dDatOd .or. doks->datum>dDat)
			skip
			loop
		endif
		
		if !EMPTY(cVrstP)
			if (DOKS->IdVrsteP <> cVrstP)
				skip
				loop
			endif
		endif
		
		SELECT POS
		hseek DOKS->(IdPos+IdVd+dtos(datum)+BrDok)
		nIznos:=0
		nDuguje:=0
		nPotrazuje:=0
		do while !eof().and. POS->(IdPos+IdVd+dtos(datum)+BrDok)==DOKS->(IdPos+IdVd+dtos(datum)+BrDok)
			
			// pretraga po sifri dobavljaca
			select roba
			if roba->(fieldpos("sifdob"))<>0
				hseek pos->idroba
				if roba->id == pos->idroba
					if !EMPTY(cSifraDob)
						if (roba->sifdob <> cSifraDob)
							select pos
							skip
							loop
						endif
					endif
				endif
			endif
			
			select pos
			if doks->IdVrsteP=="01"
				nPom:=pos->kolicina*pos->cijena*iif(pos->idvd=="00",-1,1)
				//placanje gotovinom povecava promet na obje strane
				nPlacJest+=nPom
				nPlacNije+=nPom
			elseif (LEFT(idroba,5)=='PLDUG')
				nPlacJest+=POS->Kolicina*POS->Cijena*iif(pos->idvd='00',-1, 1)
			else
				nIznos+=POS->Kolicina*POS->Cijena*iif(pos->idvd='00',-1,1)
				nPlacNije+=POS->Kolicina*POS->Cijena*iif(pos->idvd='00',-1,1)
			endif
			skip
		enddo
		SELECT DOKS
		skip
	enddo
	
	nStanje:=nPlacNije-nPlacJest
	
	if round(nStanje,4)<>0 .or. cNula=="D"
		
		SELECT RNGOST
		hseek cIdGost
		? REPL("-",80)
		? ALLTRIM(STR(nBrojacPartnera)) + ") " + PADR(ALLTRIM(cIdGost)+" "+RNGOST->Naz,35)+" "
		if gVrstaRS=="K"
			? SPACE(4)
		endif
		?? STR(nPlacNije,12,2), STR(nPlacJest,12,2)+" "
		?? STR(nStanje,12,2)
		nSumaSt+=nStanje
		fPisi:=.t.
		? REPL("-",80)
		++ nBrojacPartnera	
	endif
	nSumaNije+=nPlacNije
	nSumaJest+=nPlacJest
	SELECT DOKS
	if cSpec=="D" .and. fPisi
		GO nPrviRec
		nBrojacStavki:=1
		do while !eof() .and. DOKS->IdGost==cIdGost 
		
			if (doks->datum<dDatOd .or. doks->datum>dDat)
				skip
				loop
			endif
			
			if !EMPTY(cVrstP)
				if (DOKS->IdVrsteP <> cVrstP)
					skip
					loop
				endif
			endif
		
			SELECT POS
			seek DOKS->(IdPos+IdVd+dtos(datum)+BrDok)
			nDuguje:=0
			nPotrazuje:=0
			do while !eof() .and. POS->(IdPos+IdVd+dtos(datum)+BrDok)==DOKS->(IdPos+IdVd+dtos(datum)+BrDok)
				
				if doks->IdVrsteP=="01"
				
					nPom:=pos->kolicina*pos->cijena*iif(pos->idvd=="00",-1,1)
					//placanje gotovinom povecava promet na obje strane
					nDuguje+=nPom
					nPotrazuje+=nPom
				elseif (LEFT(idroba,5)=='PLDUG')
					//ako je placanje, dug je negativan
					//za poc stanje promjeni znak ????
					nPotrazuje+=POS->Kolicina*POS->Cijena*iif(pos->idvd='00',-1,1)
					
				else
					//veresija
					nDuguje+=POS->Kolicina*POS->Cijena*iif(pos->idvd='00',-1,1)
				endif
				skip
			enddo
			
			SELECT DOKS
			? ALLTRIM(STR(nBrojacStavki)) + " " + PADL(doks->idvd,4)+" "+PADR(ALLTRIM(DOKS->IdPos)+"-"+ALLTRIM(DOKS->BrDok),9), FormDat1(DOKS->Datum)
			++ nBrojacStavki
			?? " "+doks->IdVrsteP+"       "
			?? STR(nDuguje, 12, 2), STR(nPotrazuje, 12, 2)
			skip
		enddo
		?
	endif
	if !empty(cGost)
		exit
	endif
enddo

if empty(cGost)
	if gVrstaRS=="K"
		nDuz:=25
	else
		nDuz:=35+1+10+1+10
	endif
	? REPL("=",nDuz),REPL("=",14)
	? PADL("Ukupno placeno:",nDuz),STR(nSumaJest,14,2)
	? PADL("UKUPNO NEPLACENO:",nDuz),STR(nSumaNije,14,2)
	? PADL("STANJE UKUPNO:",nDuz),STR(nSumaSt,14,2)
	? REPL("=",nDuz),REPL("=",14)
endif

if gVrstaRS<>"S"
	PaperFeed()
endif

END PRINT

CLOSERET
*}


/*! \fn I_RnGostiju()
 *  \brief Stanje racuna gostiju
 */

function I_RnGostiju()
*{
private cGost:=SPACE(8)
private cNula:="D"
private dDat:=gDatum
private cSpec:="N"

// otvaranje potrebnih baza
///////////////////////////
// izvjestaj je korektan na serveru, odnosno na stand-alone kasi
O_POS
O_DOKS
O_RNGOST

// maska za postavljanje uslova
///////////////////////////////
do while .t.
	if !VarEdit({{"Sifra gosta/partner/sobe (prazno-svi)","cGost","IF(!EMPTY(cGost),P_Gosti(@cGost),.t.)",,},{"Prikazati goste sa stanjem 0 (D/N)", "cNula","cNula$'DN'","@!",},{"Prikazati stanje na dan ", "dDat","dDat<=gDatum",,},{"Prikazati specifikaciju", "cSpec","cSpec$'DN'","@!",} },11,5,17,74,'USLOVI ZA IZVJESTAJ "STANJE RACUNA GOSTIJU"',"B1")
		CLOSERET
	else
		exit
	endif
enddo

// pravljenje izvjestaja
////////////////////////
START PRINT CRET
?? gP12cpi
? PADC("STANJE RACUNA PARTNERA NA DAN "+FormDat1(gDatum),80)
? PADC("----------------------------------------",80)
?
//? PADR("Gost / partner / soba",35)+" "

if gVrstaRS=="K"
	? SPACE(4)
endif

?? PADR("Zaduzenje", 10),PADR("Uplaceno",10)," Stanje (D/P)"
? REPLICATE("-",35)+" "

if gVrstaRS=="K"
	? SPACE(4)
endif

?? REPL("-",10),REPL("-",10),REPL("-",14)

nSumaSt:=0
nSumaNije:=0
nSumaJest:=0
SELECT DOKS

// "IdGost+Placen+DTOS (Datum)"
set order to 3        
seek cGost

do while !eof()
	if empty(DOKS->IdGost)
		skip
		loop  
	endif
	nPrviRec:=RECNO()
	fPisi:=.f.
	
	nPlacJest:=0
	nPlacNije:=0
	cIdGost:=DOKS->IdGost
	do while !eof() .and. DOKS->IdGost==cIdGost
		SELECT POS
		seek DOKS->(IdPos+IdVd+dtos(datum)+BrDok)
		nIznos:=0
		do while !eof().and.POS->(IdPos+IdVd+dtos(datum)+BrDok)==DOKS->(IdPos+IdVd+dtos(datum)+BrDok)
			nIznos+=POS->Kolicina*POS->Cijena
			skip
		enddo
		SELECT DOKS
		if Placen==PLAC_JEST
			nPlacJest+=nIznos
		else
			nPlacNije+=nIznos
		endif
		skip
	enddo
	nStanje:=nPlacNije-nPlacJest
	if round(nStanje,4)<>0 .or. cNula=="D"
		SELECT RNGOST
		hseek cIdGost
		? PADR(ALLTRIM(cIdGost)+" "+RNGOST->Naz,35)+" "
		if gVrstaRS=="K"
			? SPACE(4)
		endif
		?? STR(nPlacNije,10,2),STR(nPlacJest,10,2)+" "
		if nStanje>0
			?? STR(nStanje,12,2),"D"
		else
			?? STR(-1*nStanje,12,2)
			if round(nStanje,4)<>0
				?? " P"
			endif
		endif
		nSumaSt+=nStanje
		fPisi:=.t.
	endif
	nSumaNije+=nPlacNije
	nSumaJest+=nPlacJest
	SELECT DOKS
	if cSpec=="D".and.fPisi
		GO nPrviRec
		do while !eof().and.DOKS->IdGost==cIdGost
			SELECT POS
			seek DOKS->(IdPos+IdVd+dtos(datum)+BrDok)
			nIznos:=0
			do while !eof().and.POS->(IdPos+IdVd+dtos(datum)+BrDok)==DOKS->(IdPos+IdVd+dtos(datum)+BrDok)
				nIznos+=POS->Kolicina*POS->Cijena
				skip
			enddo
			SELECT DOKS
			? SPACE(5)+PADR(ALLTRIM(DOKS->IdPos)+"-"+ALLTRIM(DOKS->BrDok),9),FormDat1(DOKS->Datum),STR(nIznos,8,2)
			skip
		enddo
	endif
	if !empty(cGost)
		exit
	endif
enddo

if empty(cGost)
	if gVrstaRS=="K"
		nDuz:=25
	else
		nDuz:=35+1+10+1+10
	endif
	? REPL("=",nDuz),REPL("=",14)
	? PADL("Ukupno placeno:",nDuz),STR(nSumaJest,14,2)
	? PADL("UKUPNO NEPLACENO:",nDuz),STR(nSumaNije,14,2)
	? PADL("STANJE UKUPNO:",nDuz),STR(nSumaSt,14,2)
	? REPL("=",nDuz),REPL("=",14)
endif

if gVrstaRS<>"S"
	PaperFeed()
endif

END PRINT
CLOSERET
*}

