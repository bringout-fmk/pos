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


// sljedeci broj zakljucenja na nivou baze
function g_next_zak_br()
*{
local nArr
nArr:=SELECT()

nRet:=0

select doks
set order to tag "ZAK"
go bottom
hseek gIdPos + "42" + "XXX"
skip -1

nRet := (field->zak_br) + 1

select (nArr)

return nRet
*}

// zakljuci sto broj
function zak_sto(nStoBr)
*{
local nArr
local nNext_zak
local cNijeZaklj := "     0"
local nCnt := 0
local nTRec
local nNRec

nArr := SELECT()

// vrati sljedeci broj zakljucenja
nNext_zak := g_next_zak_br()

// postavi filter za nStoBr
select doks
set order to tag "STO"
hseek gIdPos + "42" + STR(nStoBr) + cNijeZaklj

do while !EOF() .and. doks->idpos == gIdPos .and. doks->idvd == "42" .and. doks->sto_br == nStoBr .and. doks->zak_br == 0
	++ nCnt
	nTRec := RecNo()
	skip
	nNRec := RecNo()
	
	go (nTRec)
	
	replace zak_br with nNext_zak
	
	go (nNRec)
enddo

if nCnt > 0
	show_zak_info(nNext_zak)
endif

if Pitanje(,"Stampati zbirni racun (D/N)?","N") == "D"
	print_zak_br(nNext_zak)
endif

select (nArr)

return nCnt
*}

// ------------------------------
// ------------------------------
function show_zak_info(nZakBr)
*{
local nArr
nArr := SELECT()

O_POS
select doks
set order to tag "ZAK"
hseek gIdPos + "42" + STR(nZakBr, 6)

altd()


cDokumenti := ""
nTotal := 0
nCnt := 0
nStoBr := 0
cBrDok:=""
aPom := {}

do while !EOF() .and. doks->idpos == gIdPos .and. doks->idvd == "42" .and. doks->zak_br == nZakBr
	nStoBr := doks->sto_br
	++ nCnt
	nTotal += VAL(DokIznos(.f.))
	cBrDok := ALLTRIM(doks->brdok)
	cDokumenti += cBrDok + ","
	skip
enddo

skip -1

aPom := SjeciStr(cDokumenti, 30)

cText := "Zbirni racun " + cBrDok + "-" + ALLTRIM(STR(nZakBr)) + "#"
cText += "Ukupan iznos po racunima "
for i:=1 to LEN(aPom)
	cText += ALLTRIM(aPom[i]) + "#"
next
cText += " je " + ALLTRIM(STR(nTotal)) + " KM"

MsgBeep(cText)

select (nArr)
return
*}

// -------------------------------------------------------
// printanje zbirnog racuna na osnovu broja zakljucenja
// -------------------------------------------------------
function print_zak_br(nZakBr)
local nCSum
local cIdPos
local cIdVd
local cBrDok
local cTime
local cIdRoba
local cIdTarifa
local cRobaNaz
local nPPDV
local nKolicina
local nCjenBPdv
local nCjen2BPDV
local nCjen2PDV
local nCjenPDV
local nIznPop
local nUBPDV
local nUPDV
local nUTotal
local nUPopust
local nUBPdvPopust
local dDatRn
local cVrstaP
local cNazVrstaP
local cIdRadnik
local cRdnkNaz
local cBrZDok
local nArr
local cBrStola
local cVezRacuni

nArr:=SELECT()

drn_create()
drn_open()
drn_empty()

o_pregled()

select pos
SET ORDER TO TAG "1"

select doks
set order to tag "ZAK"
hseek gIdPos + "42" + STR(nZakBr, 6)

if !found()
	MsgBeep("racun ZAK.STO=" + STR(nZakBr, 6) + " ne postoji !?")
	close all
	return
endif
	
cZBrDok := ALLTRIM(doks->brdok) + "-" + ALLTRIM(STR(nZakBr,6))

nCSUm := 0
nUBPDV:=0
nUPDV:=0
nUTotal:=0
nUPopust:=0
nUBPdvPopust:=0

cVezRacuni := ""
		
do while !EOF() .and. doks->idvd == "42" .and. doks->zak_br == nZakBr

	cIdPos := doks->idpos
	cIdVD := doks->idvd
	cBrDok := doks->brdok
	dDatRn := doks->datum
	
	cBrStola := ALLTRIM(STR(doks->sto_br))
	cIdRadnik := doks->idRadnik
	cSmjena := doks->smjena
	cTime := doks->vrijeme
	cVrstaP := doks->idvrstep
	
	cVezRacuni += ALLTRIM(cBrDok) + ","
	
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
	

	select pos
	hseek doks->(cIdPos+cIdVd+DTOS(dDatRn)+cBrDok)
	// -------- vrti kroz pos -------------------------
	do while !eof() .and. (pos->idpos == cIdpos) .and. (pos->idvd == cIdVd) .and.  (pos->datum == dDatRn) .and. (pos->brdok == cBrDok)

		nCjenBPDV := 0
		nCjenPDV := 0
		nKolicina := 0
 		nPopust := 0
		nCjen2BPDV := 0
		nCjen2PDV := 0
 		nPDV := 0
		nIznPop := 0


		cIdRoba := pos->idroba
		cIdTarifa := pos->idtarifa

		select roba
		hseek cIdRoba
		cJmj := roba->jmj
		cRobaNaz := roba->naz	
		
		// seek-uj tarifu
		select tarifa
		hseek cIdTarifa
		nPPDV := tarifa->opp


		nKolicina := pos->kolicina
 		nCjenPDV :=  pos->cijena
		dDatDok := pos->datum

		nCjenBPDV := nCjenPDV / ( 1 + nPPDV/100)	
		do case
			case gPopVar="P" .and. gClanPopust 
				if !EMPTY(cPartner)
					nIznPop := pos->ncijena
				endif
			case gPopVar="P" .and. !gClanPopust
				nIznPop := pos->ncijena
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
		nUkupno :=  (nKolicina * nCjenPDV) - (nKolicina * nIznPop)
		// izracunaj ukupnu vrijednost pdv-a
		nVPDV := ((nKolicina * nCjenBPDV) - (nKolicina * (nIznPop / (1 + nPPDV/100)))) * (nPPDV/100)

		// ukupno bez pdv-a
		nUBPDV += nKolicina * nCjenBPDV
		// ukupno pdv
		nUPDV += nVPDV
		// total racuna
		nUTotal += nUkupno

		if Round(nCjen2BPDV, 2)<>0
			// ukupno popust
			nUPopust += (nCjenBPDV - nCjen2BPDV) * nKolicina
		endif
		
		// ukupno bez pdv-a - popust
		nUBPDVPopust := nUBPDV - nUPopust


		++ nCSum

		// dodaj stavku u rn.dbf
		add_rn( cZBrDok, STR(nCSum, 3), "", cIdRoba, cRobaNaz, cJmj, nKolicina, Round(nCjenPDV,3), Round(nCjenBPDV,3), Round(nCjen2PDV,3), Round(nCjen2BPDV,3), Round(nPopust,2), Round(nPPDV,2), Round(nVPDV,3), Round(nUkupno,3), 0, 0)
		SELECT POS
		skip
	enddo
	// --- zavrsio sa prolaskom kroz pos stavke --
		
	select doks
	skip
enddo


// dodaj zapis u drn.dbf
add_drn( cZBrDok, dDatRn, nil, nil, cTime, ;
         Round(nUBPDV,2), Round(nUPopust,2), Round(nUBPDVPopust,2), ;
	 Round(nUPDV,2), Round(nUTotal,2), ;
	 nCSum, 0, 0, 0)
	
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

if gStolovi == "D"
	// broj stola
	add_drntext("R11", cBrStola)
	// vezni racuni
	add_drntext("R12", cVezRacuni)
endif

// Broj linija potrebnih da se ocjepi traka
add_drntext("P12", ALLTRIM(STR(nFeedLines)))
// sekv.za otvaranje ladice
add_drntext("P13", gOtvorStr)
// sekv.za cjepanje trake
add_drntext("P14", gSjeciStr)

// napuni podatke o maticnoj firmi - zaglavlje
firma_params_fill()

select dokspf
set order to tag "1"
hseek cIdPos + VD_RN + DToS(dDatRn) + cBrDok

add_drntext("K01", dokspf->knaz)
add_drntext("K02", dokspf->kadr)
add_drntext("K03", dokspf->kidbr)
// dodaj D01 - A - azuriran dokument
add_drntext("D01", "A")

// ispisi racun
rb_print(.t.)

close all
return


// -------------------------------
// -------------------------------
function g_otv_stolovi()
*{
local nArr
nArr:=SELECT()

O_POS
O_DOKS
select doks
set order to tag "ZAK"
go top
hseek gIdPos + "42"

nTotal := 0
nStoBr := 0
aStolovi := {}
do while !EOF() .and. doks->zak_br == 0
	nStoBr := doks->sto_br
	do while !EOF() .and. doks->zak_br == 0 .and. doks->sto_br == nStoBr
		nTotal += VAL(DokIznos(.f.))
		skip
	enddo
	AADD(aStolovi, {nStoBr, nTotal})
	nTotal := 0
enddo

select (nArr)
return aStolovi
*}

// ---------------------------
// ---------------------------
function g_zak_sto()
*{
local nSelected := 0
local nStoBr:=0
local aStolovi := {}
local nZakBr

// daj listu otvorenih stolova
aStolovi := g_otv_stolovi()

nSelected := mnu_otv_stolovi(aStolovi) 

if ( nSelected == nil .or. nSelected == 0 )
	return .f.
endif

// ovo je sto odabran u meniju
nStoBr := aStolovi[nSelected, 1]


// postavi upit za broj stola
Box(, 3, 30)
	set cursor on
	@ m_x+2, m_y+6 SAY "Unesi broj stola:" GET nStoBr ;
	     VALID (nStoBr > 0) ;
	     PICT "999"
	read
BoxC()

if LastKey()==K_ESC
	MsgBeep("Prekinuta operacija zakljucenja stola !")
	return
endif

// provjeri da nije ukucan broj stola koji nema racuna
if ASCAN(aStolovi, {|aVal| aVal[1] == nStoBr}) == 0
	MsgBeep("Za ovaj sto ne postoje otvoreni racuni !#Prekidam operaciju !")
	return
endif

zak_sto(nStoBr)

return
*}

// --------------------------------
// --------------------------------
function pr_otv_stolovi(aStol)
*{

if LEN(aStol) == 0
	MsgBeep("Nema nezakljucenih stolova !")
	return .f.
endif

START PRINT CRET

? "Lista otvorenih stolova:"
?
?
? "  Sto       Iznos"
? "----- -----------"

for i:=1 to LEN(aStol)
	? aStol[i, 1], aStol[i, 2]
next

?

FF
END PRINT

return .t.
*}


// --------------------------------
// --------------------------------
function mnu_otv_stolovi(aStol)
local i
local nSelected
private Opc:={}
private opcexe:={}
private Izbor

if LEN(aStol) == 0
	MsgBeep("Nema nezakljucenih stolova !")
	return 0
endif


for i:=1 to LEN(aStol)
	cPom := STR(aStol[i,1],3) + " - stanje : " + STR(aStol[i,2], 7, 2)
	cPom := PADR(cPom, 30)
	
	AADD(opc, cPom )
	AADD(opcexe, {|| nSelected:=Izbor, Izbor:=0  } )
next

Izbor := 1
// 0 - ako se kaze <ESC>
Menu_SC("o_s")


return nSelected


// --------------------------------
// --------------------------------
function zak_sve_stolove()
*{
local nNextZak := 0
local nArr
local cNijeZaklj := "     0"
local nNRec
nArr := SELECT()

if !SigmaSif("ZAKSVE")
	MsgBeep("Nemate pravo na koristenje ove opcije!")
	return
endif

O_DOKS
nNextZak := g_next_zak_br()

select doks
set order to tag "ZAK"
go top
seek gIdPos + "42" + cNijeZaklj

do while !EOF() .and. doks->idpos == gIdPos .and. doks->idvd == "42" .and. doks->zak_br == 0
	nStoBr := doks->sto_br
	do while !EOF() .and. doks->idpos == gIdPos .and. doks->idvd == "42" .and. doks->zak_br == 0 .and. doks->sto_br == nStoBr
		nTRec := RecNo()
		skip
		nNRec := RecNo()
		skip -1
		replace zak_br with nNextZak
		go (nNRec)
	enddo
	++ nNextZak 
enddo

MsgBeep("Izvrseno zakljucenje svih racuna !")

select (nArr)
return
*}


// info o prethodnom stanju stola nStoBr
function g_stanje_stola(nStoBr)
*{
local nArr
local cNijeZaklj := "     0"
nArr:=SELECT()
O_POS
O_DOKS
select doks
set order to tag "STO"
hseek gIdPos + "42" + STR(nStoBr) + cNijeZaklj

nStanje := 0

do while !EOF() .and. doks->idpos == gIdPos .and. doks->idvd == "42" .and. doks->sto_br == nStoBr
	if doks->zak_br == 0
		nStanje += VAL(DokIznos(.f.))
	endif
	skip
enddo

select (nArr)

return nStanje
*}

