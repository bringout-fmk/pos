#include "\dev\fmk\pos\pos.ch"


/*! \fn OpenKalkDBF(cPath)
 *  \brief otvara tabelu kalk
 *  \param cPath - putanja do kalk.dbf
 */
function OpenKalkDB(cPath)
*{
// zakaci se na kalk
SELECT (F_KALK)
USE (cPath + SLASH + "kalk")
// postavi order "4"
set order to tag "4"

return
*}

/*! \fn GenSifProd(cIdRoba)
 *  \brief generisi log za sifre artikala u prodavnici
 */
function GenSifProd(cIdRoba)
*{
LogRecRoba(cIdRoba)
return
*}

/*! \fn NewSifProd(cIdRoba)
 *  \brief generisi log za sifre artikala u prodavnici
 */
function NewSifProd(cIdRoba)
*{
NewRecRoba(cIdRoba)
return
*}


/*! \fn GetRobaCnt(cIdRoba)
 *  \brief Vraca broj sifara robe u sifrarniku robe
 *  \param cIdRoba - trazeni artikal
 */
function GetRobaCnt(cIdRoba)
*{
select roba
hseek cIdRoba
nRet:=0
do while !EOF() .and. field->id == cIdRoba
	++ nRet
	skip
enddo

return nRet
*}


/*! \fn OidChk(dDatOd, dDatDo, lSve)
 *  \brief Provjera duplih OID-a
 *  \param dDatOd - datum od provjera
 *  \param dDatDo - datum do provjera
 *  \param lSve - kompletna tabela
 */
function OidChk(dDatOd, dDatDo, lSve)
*{
MsgO("Provjeravam integritet OID-a ...")

// otvori box
Box(,2,65)

// provjeri pos
O_POS
select pos
set order to tag "OID"
PosOidChk(dDatOd, dDatDo, lSve)

// provjeri doks
O_DOKS
select doks
set order to tag "OID"
DoksOidChk(dDatOd, dDatDo, lSve)

// provjeri roba
O_ROBA
select roba
set order to tag "OID"
RobaOidChk()

BoxC()
MsgC()

return
*}


/*! \fn PosOidChk()
 *  \brief Provjera duplih oid-a u tabeli POS
 *  \param dDatOd - datum od kojeg se vrsi provjera
 *  \param dDatDo - datum do kojeg se vrsi provjera
 *  \param lSve - kompletna tabela
 */
function PosOidChk(dDatOd, dDatDo, lSve)
*{
local nOid
local cFirma
local cBrDok
local dDatum
local cIdRoba
local nKolicina
local nCijena
local nCnt
local cIdVd
local lReindex

@ 1+m_x, 2+m_y SAY SPACE(65)
@ 1+m_x, 2+m_y SAY "Vrsim provjeru tabele POS..."

go top
do while !EOF()
	// uzmi glavne vrijednosti tekuceg zapisa
	nOid := field->_oid_
	cFirma := field->idpos
	cBrDok := field->brdok
	cIdVd := field->idvd
	dDatum := field->datum
	cRoba := field->idroba
	nKolicina := field->kolicina
	nCijena := field->cijena
	nCnt := 0
	
	@ 2+m_x, 2+m_y SAY SPACE(65)
	@ 2+m_x, 2+m_y SAY ALLTRIM(STR(nOid))
	
	do while !EOF() .and. field->_oid_ == nOid
		// vrsi se provjera datumskog perioda
		altd()
		if !lSve
			if (field->datum < dDatOd) .or. (field->datum > dDatDo)
				skip
				loop
			endif
		endif
		++ nCnt
		// ako je prvi zapis njega smo uzeli pa cemo ga preskociti
		if (nCnt > 1)
			if field->_oid_ == nOid
				// uporedi zapise
				if pos->(idpos + brdok + idvd + DToS(datum) + idroba + STR(kolicina) + STR(cijena)) == cFirma + cBrDok + cIdVd + DToS(dDatum) + cRoba + STR(nKolicina) + STR(nCijena)
					// dupli oid isti zapisi
					
					// dodaj u pom.tabelu sta si izbrisao
					AddToErrors("W", "OIDDEL", pos->idvd + "-" + pos->brdok + " od " + DToC(pos->datum), "POS.DBF: pobrisan OID " + ALLTRIM(STR(field->_oid_)) + "!")
					// brisi ga
					select pos
					delete
				else
					// dupli oid razliciti zapisi
					AddToErrors("C", "OIDERR", pos->idvd + "-" + pos->brdok + " od " + DToC(pos->datum), "POS.DBF: Postoji dupli OID, podaci polja nisu identicni!")
					select pos
				endif
			endif
		endif
		
		select pos		
		skip
	enddo
enddo

return 1
*}


/*! \fn DoksOidChk(dDatOd, dDatDo, lSve)
 *  \brief Provjera duplih oida u tabeli DOKS
 *  \param dDatOd - datum od provjera
 *  \param dDatDo - datum do provjera
 *  \param lAll - kompletna tabela
 */
function DoksOidChk(dDatOd, dDatDo, lSve)
*{
local nOid
local cFirma
local cBrDok
local dDatum
local cIdVd
local nCnt

@ 1+m_x, 2+m_y SAY SPACE(65)
@ 1+m_x, 2+m_y SAY "Vrsim provjeru tabele DOKS ..."

go top
do while !EOF()
	// uzmi glavne vrijednosti tekuceg zapisa
	nOid := field->_oid_
	cFirma := field->idpos
	cBrDok := field->brdok
	dDatum := field->datum
	cIdVd := field->idvd
	nCnt := 0
	
	@ 2+m_x, 2+m_y SAY SPACE(65)
	@ 2+m_x, 2+m_y SAY ALLTRIM(STR(nOid))

	do while !EOF() .and. field->_oid_ == nOid
		// vrsi se provjera datumskog perioda
		if !lSve
			if (field->datum < dDatOd) .or. (field->datum > dDatDo)
				skip
				loop
			endif
		endif
		
		++ nCnt
		// ako je prvi zapis njega smo uzeli pa cemo ga preskociti
		if (nCnt > 1)
			if field->_oid_ == nOid
				// uporedi zapise
				if doks->(idpos + brdok + DToS(datum) + idvd) == cFirma + cBrDok + DToS(dDatum) + cIdVd
					// dupli oid isti zapisi
				
					// dodaj u pom.tabelu sta si izbrisao
					AddToErrors("W", "OIDDEL", doks->idvd + "-" + doks->brdok + " od " + DToC(doks->datum), "DOKS.DBF: pobrisan OID " + ALLTRIM(STR(field->_oid_)) + "!")
					// brisi ga
					select doks
					delete
				else
					// dupli oid razliciti zapisi
					AddToErrors("C", "OIDERR", doks->idvd + "-" + doks->brdok + " od " + DToC(doks->datum), "DOKS.DBF: Postoji dupli OID, podaci polja nisu identicni!")
					select doks
				endif
			endif
		endif
		
		select doks
		skip
	enddo
enddo

return 1
*}


/*! \fn RobaOidChk()
 *  \brief Provjera duplih oid-a u tabeli ROBA
 */
function RobaOidChk()
*{
local nOid
local cIdRoba
local cRobaNaz
local nCijena1
local cTarifa
local nCnt

@ 1+m_x, 2+m_y SAY SPACE(65)
@ 1+m_x, 2+m_y SAY "Vrsim provjeru tabele ROBA ..."

go top
do while !EOF()
	// uzmi glavne vrijednosti tekuceg zapisa
	nOid := field->_oid_
	cIdRoba := field->id
	cRobaNaz := field->naz
	nCijena1 := field->cijena1
	cTarifa := field->idtarifa
	nCnt := 0
	
	@ 2+m_x, 2+m_y SAY SPACE(65)
	@ 2+m_x, 2+m_y SAY ALLTRIM(STR(nOid))

	do while !EOF() .and. field->_oid_ == nOid
		++ nCnt
		// ako je prvi zapis njega smo uzeli pa cemo ga preskociti
		if (nCnt > 1)
			if field->_oid_ == nOid
				// uporedi zapise
				if roba->(id + naz + idtarifa + STR(cijena1)) == cIdRoba + cRobaNaz + cTarifa + STR(nCijena1)
					// dupli oid isti zapisi
					// dodaj u pom.tabelu sta si izbrisao
					AddToErrors("W", "OIDDEL", roba->id + "-" + roba->naz, "ROBA.DBF: Pobrisan oid " + ALLTRIM(STR(field->_oid_))+ "!")
					// brisi ga
					select roba
					delete
				else
					// dupli oid razliciti zapisi
					AddToErrors("C", "OIDERR", roba->id + "-" + roba->naz, "ROBA.DBF: Postoji dupli OID, podaci polja nisu identicni!")
					select roba
				endif
			endif
		endif
		
		select roba
		skip
	enddo
enddo

return 1
*}





