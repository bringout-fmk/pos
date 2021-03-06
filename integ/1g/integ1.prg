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


/*! \fn UpdInt1(lForce, lReindex)
 *  \brief Pokrecu se testovi INTEG-1
 */
function UpdInt1(lForce, lReindex)
*{
local cIdOdj:="  " // id odjeljenje
local nUkCijena:=0 // ukupno cijena
local nUkKartCnt:=0 // ukupno kartica
local nUkRobaCnt:=0 // ukupno roba cnt
local nUkFStanje:=0 // ukupno fin.stanje
local nUkKStanje:=0 // ukupno kol.stanje
local nPcStanje:=0 // pocetno stanje
local dChDate // datum provjere integriteta
local nNextId // sljedeci brojac za testove
local nFStanje // fin.stanje
local nKStanje // kol.stanje
local cIdRoba // idroba
local cIdTarifa // tarifa
local nOidRoba // _oid_ roba
local nRCjen // roba cijena
local dPLast // POS datum zadnjeg dokuemnta sa kartice

if lForce == nil
	lForce := .f.
endif

// provjeri da li treba pokretati INTEG-1
dChDate := DATE() - 1
if !lForce .and. !RunInt1Upd()
	return
endif

// ako treba reindexiraj tabele
if !lReindex
	Reindex(.t.)
	lReindex := .t.
endif

MsgO("Vrsim analizu integriteta...molimo sacekajte!")

O_ROBA
O_POS
nNextID := 0

// prvo uzmi sljedeci ID za DINTEG1
nNextID := GetNextID()

// upisi zapis u DINTEG1
AddDInteg1(nNextID, dChDate)

// prodji kroz POS
select pos
set order to tag "2"
go top

Box(,3,65)

@ 1+m_x, 2+m_y SAY "Vrsim obradu stanja artikla, na dan " + DToC(dChDate) + " br." + ALLTRIM(STR(nNextID))

do while !eof() .and. field->idodj == cIdOdj
	// setuj osnovne varijable	
	nFStanje:=0
	nKStanje:=0
  	cIdRoba:=field->IdRoba
	nRCjen:=0
	nKartCnt:=0 // broj stavki kartice
	nRobaCnt:=0 // broj sifara artikla
  	
	// pronadji robu	
	select roba
	nRobaCnt := GetRobaCnt(cIdRoba)
	select roba
	go top
	hseek cIdRoba
	nRCjen := roba->cijena1
	nOidRoba := roba->_oid_
	cIdTarifa := roba->idtarifa
	
	@ 2+m_x, 2+m_y SAY SPACE(65)
	@ 3+m_x, 2+m_y SAY SPACE(65)
	@ 2+m_x, 2+m_y SAY "Artikal: " + ALLTRIM(cIdRoba) + ", " + ALLTRIM(field->naz)
	@ 3+m_x, 2+m_y SAY "Cijena: " + ALLTRIM(STR(nRCjen))
	
	select pos
	
	do while !EOF() .and. pos->(IdOdj+IdRoba)==(cIdOdj+cIdRoba)
    		
		if ( field->datum > dChDate )
			skip
			loop
		endif

		// ako je dokument 96 - preskoci
		if field->idvd $ "96#99"
    			skip
			loop
    		endif
		
      		if field->idvd $ DOK_ULAZA
        		nKStanje += field->Kolicina
      		elseif field->idvd $ "IN"
        		nKStanje -= (field->Kolicina - field->Kol2 )
      		elseif field->idvd $ DOK_IZLAZA
        		nKStanje -= field->Kolicina
      		elseif field->IdVd == "NI"
		endif
		
		dPLast := field->datum
		
		if ( field->datum > IntegTekDat() )
			++ nKartCnt
		else
			nPcStanje := 1
		endif
		
		nUkKartCnt += nKartCnt
		nUkKStanje += nKStanje
		
		skip
	enddo
	
	nUkCijena += nRCjen
	nUkRobaCnt += nRobaCnt
	nFStanje := nKStanje * nRCjen
	nUkFStanje += nFStanje
	
	nUkKartCnt += nPcStanje // dodaj i pocetno stanje
	
	// upisi zapis u INTEG1.DBF
	AddInteg1(nNextID, cIdRoba, nOidRoba, cIdTarifa, nKStanje, nFStanje, nKartCnt + nPcStanje, nRobaCnt, nRCjen, dPLast, nil, nil, nil, nil, nil, nil, nil, nil)	
	
	select pos
enddo

// Ubaci checksum podatak u DINTEG1
UpdCSum1(nNextID)

BoxC()
MsgC()

return
*}


/*! \fn UpdCSum1(nId)
 *  \brief Dodaj checksum zapis u DINTEG1
 *  \param nId - id testa
 */
function UpdCSum1(nId)
*{
local nCSum1:=0
local nCSum2:=0
local nCnt:=0

O_DINTEG1
O_INTEG1

select dinteg1
set order to tag "2"

hseek nId
// pronadji id testa
if Found()
	select integ1
	set order to tag "2"
	hseek nId
	do while !EOF() .and. field->id == nId
		nCSum1 -= integ1->stanjef 
		nCSum2 += integ1->stanjek
		++nCnt
		skip
	enddo
	select dinteg1	
	SmReplace("chkok", "U")
	SmReplace("csum1", nCSum1)
	SmReplace("csum2", nCSum2)
	SmReplace("csum3", nCnt)
endif

return
*}


/*! \fn GetCSum1(nIntID)
 *  \brief Vrati ispravnost checksum-a za integ1
 *  \param nIntID - integ1 id test
 */
function GetCSum1(nIntID)
*{
local nCSum1:=0
local nCSum2:=0
local nCnt:=0

O_INTEG1
select integ1
set order to tag "2"
hseek nIntId

do while !EOF() .and. integ1->id == nIntId
	nCSum1 -= integ1->stanjef 
	nCSum2 += integ1->stanjek
	++nCnt
	skip
enddo
	
// provjeri sada sa DINTEG-om
if (dinteg1->csum3 <> nCnt)
	MsgBeep("INTEG1 TOPS-P/K, ne odgovara broj zapisa!")
	return .f.
endif
if (dinteg1->csum1 <> nCSum1)
	return .f.
endif
if (dinteg1->csum2 <> nCSum2)
	return .f.
endif

return .t.
*}


/*! \fn Int1ChkOK(nId)
 *  \brief Upisuje da je check procedura zavrsena
 */
function Int1ChkOK(nId)
*{
O_DINTEG1
select dinteg1
set order to tag "2"
hseek nId
// prodanadji id testa
if Found()
	replace field->chkok with "Z"
endif

return
*}

/*! \fn ChkInt1(lForce, lReindex)
 *  \brief Provjeri test INTEG-1
 *  \param lForce - forsirano
 *  \param lReindex - reindexirati tabele
 */
function ChkInt1(lForce, lReindex)
*{
local lOidChk := .f.
local lEtySif := .f.
local nTest:=0 // id test integ1
local dChkDate := DATE() - 1 // datum provjere
local lChkOk // da li je update u DINTEG1 - OK
local cKFirma:="" // kalk id firma
local cKPKonto:="" // kalk konto prodavnice
local cKKPath:="" // kalk putanja do kalk.dbf
local dPLast // POS kartica datum zadnjeg dokumenta
local dKLast // KALK kartica datum zadnjeg dokumenta
local cIdOdj:="  "
local nUkKStanje:=0
local nUkFStanje:=0
local nUkKartCnt:=0
local nUkRobaCnt:=0
local nUkCijena:=0
local nPcStanje:=0
local nFStanje
local nKStanje
local cIdRoba
local cIdTarifa
local nOidRoba
local nKartCnt
local nRobaCnt
local nRCjen
local cMsg
local cPLVd
local cKLU_I
local nKKStanje
local nKFStanje
local nKKartCnt

if ( lForce == nil )
	lForce := .f.
endif

// ova operacija se vrsi samo u knjigovodstvu
if gSamoProdaja == "D"
	return 0
endif

// da li treba provjeravati integritet i koji je test u pitanju
if !RunInt1Chk(@nTest, @dChkDate, @lChkOk, @lForce)
	if lForce == .f. 
		return 0
	elseif lChkOk == .f.
		// nije update dobar - prekini
		return 0
	endif
endif

// ako treba reindexiraj tabele
if !lReindex
	Reindex(.t.)
	lReindex := .t.
endif

// uzmi kalk varijable
GetKalkVars(@cKFirma, @cKPKonto, @cKKPath)

O_ROBA
O_DOKS
O_POS
O_ERRORS
O_INTEG1
// otvori i kalk
OpenKalkDB(cKKPath)

// prodji kroz POS
select pos
set order to tag "2"
go top

Box(,2,65)

@ 1+m_x, 2+m_y SAY "Vrsim provjeru integriteta stanja, na dan " + DToC(dChkDate) + " br." + ALLTRIM(STR(nTest)) + " K" + ALLTRIM(cKPKonto) 

do while !eof() .and. field->idodj == cIdOdj
	// setuj osnovne varijable	
	nFStanje:=0
	nKStanje:=0
  	nRCjen:=0
	nKartCnt:=0 // broj stavki kartice
	nRobaCnt:=0 // broj sifara artikla
 	lEtySif := .f. 
  	cIdRoba:=field->IdRoba
	
	if ALLTRIM(cIdRoba) == ""
		lEtySif := .t.
		//delete
		skip
		loop
	endif
	
	select integ1
	set order to tag "1"
	hseek STR(nTest) + cIdRoba
	
	if (integ1->idroba <> cIdRoba)
		lOidChk := .t.
	endif
	
	// pronadji robu	
	select roba
	nRobaCnt := GetRobaCnt(cIdRoba)
	
	hseek cIdRoba
	nRCjen := field->cijena1
	nOidRoba := field->_oid_
	cIdTarifa := field->idtarifa
	
	@ 2+m_x, 2+m_y SAY SPACE(65)
	@ 2+m_x, 2+m_y SAY "Artikal: " + ALLTRIM(cIdRoba) + ", " + ALLTRIM(field->naz)
	
	select pos
	
	do while !EOF() .and. pos->(IdOdj+IdRoba)==(cIdOdj+cIdRoba)
    		// datumska provjera
		if ( field->datum > dChkDate )
			skip
			loop
		endif

		// ispitaj da li postoji doks master record za ovaj dokument
		select doks
		set order to tag "1"
		hseek pos->idpos + pos->idvd + DTOS(pos->datum) + pos->brdok
		
		if !Found()
			AddToErrors("C", "DOKSERR", pos->idvd + "-" + ALLTRIM(pos->brdok) + "-" + DToC(pos->datum), "Za ovaj dokument ne postoji DOKS master zapis!" )
		endif
		
		select pos

		// ako je dokument 96 - preskoci
		if field->idvd $ "96#99"
    			skip
			loop
    		endif
		
      		if field->idvd $ DOK_ULAZA
        		nKStanje += field->Kolicina
			
      		elseif field->idvd $ "IN"
        		nKStanje -= (field->Kolicina - field->Kol2 )
			
      		elseif field->idvd $ DOK_IZLAZA
        		nKStanje -= field->Kolicina
			
      		elseif field->IdVd == "NI"
		endif
		
		if ( field->datum > IntegTekDat() )
			++ nKartCnt
		else
			nPcStanje := 1
		endif
		
		nUkKartCnt += nKartCnt
		nUkKStanje += nKStanje
		
		dPLast := field->datum
		cPLVd := field->idvd
		
		skip
	enddo
	
	// upisi u integ1 dat2 = dPLast
	select integ1
	if integ1->idroba == cIdRoba
		replace field->dat2 with dPLast
		replace field->c1 with cPLVd
	endif
	
	nUkCijena += nRCjen
	nUkRobaCnt += nRobaCnt
	nUkKartCnt += nPcStanje // dodaj i dok.pocetnog stanja
	nFStanje := nKStanje * nRCjen
	nUkFStanje += nFStanje

	
	nKKStanje:=0
	nKFStanje:=0
	nKKartCnt:=0

	select kalk	
	hseek cKFirma + cKPKonto + cIdRoba
	cKRoba:=kalk->idroba
	
	do while !EOF() .and. kalk->(idfirma+pkonto+idroba) == cKFirma + cKPKonto + cKRoba
		if ( kalk->datdok > dChkDate )
			skip
			loop
		endif
		// ulazni dokumenti
		if kalk->pu_i == "1"
			nKKStanje += kalk->kolicina - kalk->gkolicina - kalk->gkolicin2
			nKFStanje += kalk->mpcsapp * kalk->kolicina
		endif
		// izlazni dokumenti
		if kalk->pu_i == "5"
			nKKStanje -= kalk->kolicina
			nKFStanje -= kalk->kolicina * kalk->mpcsapp
		endif
		// ovo ne znam sta je ???
		if kalk->pu_i == "I"
			nKKStanje -= kalk->gkolicin2
			nKFStanje -= kalk->mpcsapp * kalk->gkolicin2
		endif
		// nivelacija
		if kalk->pu_i == "3"
			nKFStanje += kalk->mpcsapp * kalk->kolicina
		endif
			
		++ nKKartCnt

		dKLast := kalk->datdok
		dKLU_I := kalk->pu_i
		
		skip
	enddo

	
	altd()

	if (ROUND(nKKStanje, 4) == 0 .and. integ1->dat1 < IntegTekDat() )
		AddToErrors("P", cIdRoba, "", "KALK stanje 0, zadnji TOPS dokument postoji na datum " + ShowDatum(integ1->dat1))
	
	endif

	if !lEtySif .and. (ROUND(nKStanje, 4) <> 0)
		// koja je poruka za gresku "C" ili "P"
		cMsg := DatChk1(integ1->dat1, integ1->dat2, dKLast, dChkDate, cKLU_I, cPLVd)
	else
		cMsg := "P"
	endif
	
	// provjera prema INTEG1
	do case
		// provjeri OID
		case !lEtySif .and. integ1->oidroba <> nOidRoba
			AddToErrors("C", cIdRoba, "", "Greska u OID-u: (TOPSP)=" + ALLTRIM(STR(integ1->oidroba)) + ", (TOPSK)=" + ALLTRIM(STR(nOidRoba)))
			// pokreni update sifre iz TOPS-K
			if !SetGenSif1()
				GenSifProd(cIdRoba)
				// dodaj obavjestenje da si generisao log
				AddToErrors("W", cIdRoba, "", "Generisan sql log za TOPS-P, OK")
			endif
			select pos
			
		// provjeri TARIFA
		case !lEtySif .and. integ1->idtarifa <> cIdTarifa
			AddToErrors("C", cIdRoba, "", "Greska u tarifi: (TOPSP)=" + integ1->idtarifa + ", (TOPSK)=" + cIdTarifa )
			// pokreni update sifre iz TOPS-K
			if !SetGenSif1()
				GenSifProd(cIdRoba)
				// dodaj obavjestenje da si generisao log
				AddToErrors("W", cIdRoba, "", "Generisan sql log za TOPS-P, OK")
			endif
			select pos
			
		// provjeri STANJE artikla kolicinski
		case ROUND(integ1->stanjek,3) <> ROUND(nKStanje,3)
			AddToErrors("C", cIdRoba, "", "Greska, kol.stanje: (TOPSP)=" + ALLTRIM(STR(integ1->stanjek)) + ", (TOPSK)=" + ALLTRIM(STR(nKStanje)) + " TOPSPDAT=" + ShowDatum(integ1->dat1) + " TOPSKDAT=" + ShowDatum(integ1->dat2))

		// provjeri stanje artikla finansijski
		case ROUND(integ1->stanjef,3) <> ROUND(nFStanje,2)
			AddToErrors("C", cIdRoba, "", "Greska, fin.stanje: (TOPSP)=" + ALLTRIM(STR(integ1->stanjef)) + ", (TOPSK)=" + ALLTRIM(STR(nFStanje)) + " TOPSPDAT=" + ShowDatum(integ1->dat1) + " TOPSKDAT=" + ShowDatum(integ1->dat2))
		
		// provjeri broj stavki kartice
		case integ1->kartcnt <> nKartCnt + nPcStanje
			AddToErrors("C", cIdRoba, "", "Greska u broju stavki kartice: (TOPSP)=" + ALLTRIM(STR(integ1->kartcnt)) + ", (TOPSK)=" + ALLTRIM(STR(nKartCnt)) )
	
		// provjeri broj istih artikala u sifrarniku artikala
		case integ1->sifrobacnt > 1 .or. nRobaCnt > 1
			AddToErrors("W", cIdRoba, "", "Postoje duple sifre: (TOPSP)=" + ALLTRIM(STR(integ1->sifrobacnt)) + ", (TOPSK)=" + ALLTRIM(STR(nRobaCnt)) )
			// generisi i sifru za prodavnicu
			if !SetGenSif1()
				GenSifProd(cIdRoba)
				AddToErrors("W", cIdRoba, "", "Generisan sql log za TOPS-P, OK")
			endif
			select pos	
		// provjeri cijenu artikla
		case integ1->robacijena <> nRCjen
			AddToErrors("C", cIdRoba, "", "Greska u cijeni artikla: (TOPSP)=" + ALLTRIM(STR(integ1->robacijena)) + ", (TOPSK)=" + ALLTRIM(STR(nRCjen)) )
	
		// provjera kartica kalk
		case (nKKStanje <> 0 .and. nKKartCnt > 0) .and. nKKartCnt <> (nKartCnt + nPcStanje)
			AddToErrors("P", cIdRoba, "", "Greska u broju stavki kartice: (TOPSK)=" + ALLTRIM(STR(nKartCnt + nPcStanje)) + ", (KALK)=" + ALLTRIM(STR(nKKartCnt)) )
		
		// provjera stanja artikla kalk-tops
		case (ROUND(nKKStanje,3) <> ROUND(nKStanje,3))
			AddToErrors(cMsg, cIdRoba, "", "TOPS->KALK: kol.stanje: (TOPSK)=" + ALLTRIM(STR(nKStanje)) + ", (KALK)=" + ALLTRIM(STR(nKKStanje)) + " TOPSDAT=" + ShowDatum(integ1->dat2) + " KALKDAT=" + ShowDatum(dKLast))
			
	
		// provjera stanja artikla kalk-tops
		case (ROUND(nKFStanje,3) <> ROUND(nFStanje,3))
			AddToErrors(cMsg, cIdRoba, "", "TOPS->KALK: fin.stanje: (TOPSK)=" + ALLTRIM(STR(nFStanje)) + ", (KALK)=" + ALLTRIM(STR(nKFStanje)) + " TOPSDAT=" + ShowDatum(integ1->dat2) + " KALKDAT=" + ShowDatum(dKLast) )
		
			
	endcase
	
	lEtySif:=.f.
	
	select pos
enddo

// upisi da sam zavrsio provjeru
if !lForce
	Int1ChkOK(nTest)
endif

if lForce
	// ako je forsirano pokretanje opcije pokreni i test KALK->TOPS
	Int1KalkTops(nTest, dChkDate)
endif

BoxC()
MsgC()

return 1
*}

/*! \fn ShowDatum(dDate)
 *  \brief Prikazi datum
 *  \param dDate - datum
 */
function ShowDatum(dDate)
*{
local cRet:=""
if (dDate == nil)
	return cRet
endif
cRet:=DToC(dDate)
return cRet
*}

/*! \fn DatChk1(dTopsP, dTopsK, dKalk, dChk, cLKU_I, cLPVd)
 *  \brief Provjerava ispravnost na osnovu datuma
 *  \param dTopsP - datum tops-p
 *  \param dTopsK - datum tops-k
 *  \param dKalk - datum kalk
 *  \param dChk - datum provjere
 *  \param cLKU_I - zadnji dokument u kalk - kalk.pu_i
 *  \param cLPVd - zadnji dokument u TOPS - tip dokumenta
 *  \ret "C" or "P"
 */
function DatChk1(dTopsP, dTopsK, dKalk, dChk, cLKU_I, cLPVd)
*{
local dTmp

// ako ne postoji datum kalk-a
if (dKalk == nil)
	return "C"
endif

dTmp := dChk - 2

do case
	// datum tops-p i tops-k se ne slazu
	case dTopsP <> dTopsK
		return "C"
	// datum kalk >= provjera - 2 i tip dokumenta je zaduzenje
	case (dKalk >= dTmp) .and. (cLKU_I == "1")
		return "P"
	// datum topsk >= provjera - 2 i tip dokumenta izlaz
	case (dTopsK >= dTmp) .and. (cLPVd $ DOK_IZLAZA)
		return "P"
endcase

// sve ostalo je "C"
return "C"
*}


/*! \fn Int1KalkTops(nTest, dChkDate)
 *  \brief Testiranje podataka od strane KALK-a prema TOPS-u
 *  \param nTest - id testa iz integ1
 *  \param dChkDate - datum do kojeg se provjerava stanje
 */
function Int1KalkTops(nTest, dChkDate)
*{
local cFirma
local cKonto
local cRoba
local nKStK
local nKStF
local cPath
local dKLast // datum zadnje kalkulacije za karticu 
local cKLU_I

GetKalkVars(@cFirma, @cKonto, @cPath)

select kalk
set order to tag "4"
hseek cFirma + cKonto

@ 1+m_x, 2+m_y SAY SPACE(65)
@ 1+m_x, 2+m_y SAY "Provjera integriteta na osnovu KALK-a..."
	
do while !EOF() .and. kalk->(idfirma+pkonto)==cFirma+cKonto
	
	cRoba := kalk->idroba
	
	if !(field->pu_i $ "1#3#5#I") .or. Empty(ALLTRIM(cRoba))
		skip
		loop
	endif
	
	nKStK := 0
	nKStF := 0
	
	select integ1
	set order to tag "1"
	hseek STR(nTest) + cRoba

	@ 2+m_x, 2+m_y SAY SPACE(65)
	@ 2+m_x, 2+m_y SAY cRoba
		
	if !Found() .and. kalk->idvd <> "19"
		AddToErrors("P", cRoba, kalk->idfirma+"-"+kalk->idvd+"-"+ALLTRIM(kalk->brdok), "Roba ne postoji u sifrarniku kase!")
	endif
		
	select kalk	
		
	do while !EOF() .and. kalk->(idfirma+pkonto+idroba)==cFirma+cKonto+cRoba
		if ( kalk->datdok > dChkDate )
			skip
			loop
		endif
		// ulazni dokumenti
		if kalk->pu_i == "1"
			nKStK += kalk->kolicina - kalk->gkolicina - kalk->gkolicin2
			nKStF += kalk->mpcsapp * kalk->kolicina
		endif
		// izlazni dokumenti
		if kalk->pu_i == "5"
			nKStK -= kalk->kolicina
			nKStF -= kalk->kolicina * kalk->mpcsapp
		endif
		// ovo ne znam sta je ???
		if kalk->pu_i == "I"
			nKStK -= kalk->gkolicin2
			nKStF -= kalk->mpcsapp * kalk->gkolicin2
		endif
		// nivelacija
		if kalk->pu_i == "3"
			nKStF += kalk->mpcsapp * kalk->kolicina
		endif
		
		dKLast := kalk->datdok
			
		skip
	enddo

	// provjeri integritet sa INTEG1
	// koja ce biti poruka za razlike
	cMsg := DatChk1(integ1->dat1, integ1->dat2, dKLast, dChkDate, cKLU_I, ALLTRIM(integ1->c1))
	
	do case
		// stanje kalk -> kasa
		case ROUND(integ1->stanjek,3) <> ROUND(nKStK,3)
			AddToErrors(cMsg, cRoba, "","KALK->TOPS: kol.stanje, (KALK)=" + ALLTRIM(STR(ROUND(nKStK,3))) + " (TOPSP)=" + ALLTRIM(STR(ROUND(integ1->stanjek,3))) + " KALKDAT=" + ShowDatum(dKLast) + " TOPSDAT=" + ShowDatum(integ1->dat2) )
		case ROUND(integ1->stanjef,3) <> ROUND(nKStF,3)
			AddToErrors(cMsg, cRoba, "", "KALK->TOPS: fin.stanje, (KALK)=" + ALLTRIM(STR(ROUND(nKStF,3))) + " (TOPSP)=" + ALLTRIM(STR(ROUND(integ1->stanjef,3))) + " KALKDAT=" + ShowDatum(dKLast) + " TOPSDAT=" + ShowDatum(integ1->dat2))
	endcase
	select kalk
enddo

return
*}



/*! \fn RunInt1Upd()
 *  \brief Provjerava da li treba pokrenuti INTEG-1
 */
function RunInt1Upd()
*{
local dChkDate

if MONTH(DATE()) == 1 .and. DAY(DATE()) < 6
	return .f.
endif

O_DINTEG1
set order to tag "2"
go bottom

// koliko dana unazad treba cekati
nDays:=20

// ako je proslo nDays od proteklog testiranja pokreni test
dChkDate := DATE()-nDays

if ( field->datum < dChkDate )
	return .t.
endif

return .f.
*}


/*! \fn RunInt1Chk(nTest, lChkOk, lForce)
 *  \brief Provjerava da li treba pokrenuti provjeru integriteta u knjigovodstvu
 *  \param nTest - id integ1
 *  \param dDate - datum provjere
 *  \param lChkOk - da li je odradjen update 
 */
function RunInt1Chk(nTest, dDate, lChkOk, lForce)
*{
local dChkDate

O_DINTEG1
set order to tag "2"
go bottom

dChkDate := DATE()

// ako nije forsirano provjeri datum
if !lForce
	if ( field->datum == dChkDate )
		if (field->chkok == "Z")
			lChkOk := .f.
			return .f.
		endif
		if (field->chkok <> "U")
			lChkOk := .f.
			return .f.
		endif
	else
		lChkOk := .f.
		return .f.
	endif
endif

// dodijeli parametre
nTest := field->id
dDate := field->chkdat
// provjeri checksum
if !GetCSum1(nTest)
	MsgBeep("Checksum nije OK!!!")	
	lChkOk := .f.
	return .f.
endif

lChkOk := .t.
return .t.
*}



/*! \fn GetNextID()
 *  \brief Vraca sljedeci broj DINTEG1.ID
 */
static function GetNextId()
*{
O_DINTEG1
nID:=DInt1NextID()
return nID
*}


/*! \fn AddDInteg1(nIntegID, dCDate)
 *  \brief Dodaj zapis u tabelu DINTEG1.DBF
 *  \param nIntegID - id u tabeli DINTEG1
 *  \param dCDate - datum do kojeg treba vrsiti provjeru
 */
function AddDInteg1(nIntegID, dCDate)
*{
O_DINTEG1
select dinteg1
append blank
Sql_Append()

SmReplace("datum", DATE())
SmReplace("vrijeme", TIME())
SmReplace("id", nIntegId)
SmReplace("chkdat", DATE()-1)

return
*}

/*! \fn AddInteg1(nIntegID)
 *  \brief Upisi zapis u tabelu INTEG1.DBF
 *  \param nIntegID - ID - veza sa tabelom DINTEG1
 */
function AddInteg1(nIntegID, cRoba, nOidRoba, cIdTarifa, nStanjeK, nStanjeF, nKartCnt, nRobaCnt, nCijena, dDat1, dDat2, dDat3, nN1, nN2, nN3, cC1, cC2, cC3)	
*{
O_INTEG1
select integ1
append blank
Sql_Append()

SmReplace("id", nIntegId)
SmReplace("idroba", cRoba)
SmReplace("oidroba", nOidRoba)
SmReplace("idtarifa", cIdTarifa)
SmReplace("stanjek", nStanjeK)
SmReplace("stanjef", nStanjeF)
SmReplace("kartcnt", nKartCnt)
SmReplace("sifrobacnt", nRobaCnt)
SmReplace("robacijena", nCijena)

if nN1 <> nil
	SmReplace("N1", nN1)
endif
if nN2 <> nil
	SmReplace("N2", nN2)
endif
if nN3 <> nil
	SmReplace("N3", nN3)
endif
if cC1 <> nil
	SmReplace("C1", cC1)
endif
if cC2 <> nil
	SmReplace("C2", cC2)
endif
if cC3 <> nil
	SmReplace("C3", cC3)
endif
if dDat1 <> nil
	SmReplace("DAT1", dDat1)
endif
if dDat2 <> nil
	SmReplace("DAT2", dDat2)
endif
if dDat3 <> nil
	SmReplace("DAT3", dDat3)
endif

return
*}
