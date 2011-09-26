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
#include "\dev\fmk\pos\specif\tigra\1g\tigra.ch"

/*! \fn MnuStanjePartnera()
 *  \brief Menij izvjestaja stanja partnera - otvorene stavke
 */
function MnuStanjePartnera()
*{
O_RNGOST
select rngost

cIDPartn:=SPACE(8)
Box(,2,40)
	@ m_x+1,m_y+2 SAY "Stanje partnera - otvorene stavke"
	@ m_x+2,m_y+2 SAY "Partner (prazno-svi):" GET cIDPartn VALID Empty(cIDPartn) .or. P_Gosti(@cIDPartn)
	read
BoxC()

if LastKey()==K_ESC
	return
endif

StPartOStav(cIDPartn)

return
*}

/*! \fn StPartOStav(cIdPartner)
 *  \brief Glavna funkcija izvjestaja
 *  \param cIdPartner - id partnera (rngost - id)
 */
function StPartOStav(cIdPartner)
*{
local nStanje
local nStanjeP
private nIDN
private cNazPartn

cLinija1:=" -------- ---------- ----------------------"
//           ID    OZNAKA    NAZIV                         DATUM    BRDOK    D/P    IZNOS
cLinija2:=" ------ --------- -------- --- ---------"


CLOSE ALL

O_OSTAV_P
O_PARTN_P
SET ORDER TO TAG "ID"

START PRINT CRET

select ostav_p

StPartZagl(cLinija1, cLinija2)

nStanje:=0

cFilter:=".t."
if !Empty(cIdPartner)
	O_RNGOST
	select rngost
	hseek cIdPartner
	nID:=field->idn
	select ostav_p
	cFilter+=" .and. Id="+(ALLTRIM(STR(nID)))
	set filter to &cFilter
else
	set filter to
endif


go top

nStanje:=0
do while !eof()

	nIDN:=ostav_p->id
	
	select partn_p
	hseek nIDN
	cIdPartn:=partn_p->oznaka
	cNazPartn:=partn_p->naz
	nStanjeP:=0	
	select ostav_p
	
	? SPACE(1)
	?? STR(nIdn) + SPACE(2)
	?? cIdPartn + SPACE(2)
	?? cNazPartn + SPACE(1)
	? cLinija1

	do while !eof() .and. (nIdn==ostav_p->Id)
		// Odstampaj
	
		? " " + DTOC(STOD(ostav_p->datum))+SPACE(1) 
		?? ostav_p->brdok
		?? ostav_p->vrsta + SPACE(2)
		
		DO CASE
		case ostav_p->vrsta=="D"
			nStanjeP = nStanjeP + ostav_p->iznos
		case ostav_p->vrsta=="P"
			nStanjeP = nStanjeP - ostav_p->iznos
		otherwise
			nStanjeP += 0
		ENDCASE
	
		?? STR(ostav_p->iznos)
		
		skip
	enddo
	
	? cLinija1
	? " Ukupno: " + SPACE(1) + STR(nStanjeP)
	? cLinija1
	nStanje = nStanje + nStanjeP
enddo

?
?
? cLinija1
? " Ukupno: " + SPACE(1) + STR(nStanje)
? cLinija1

END PRINT

return
*}


/*! \fn StPartZagl(cLinija1,cLinija2)
 *  \brief Zaglavlje izvjestaja
 *  \param cLinija1 - linija na zaglavlju
 *  \param cLinija2 - linija na zaglavlju
 */
function StPartZagl(cLinija1, cLinija2)
*{
? cLinija1
? " Stanje partnera - otvorene stavke:"
? cLinija1
? " Izvjestaj se pravi za: " + DToC(Date())
? cLinija2
? "   ID      DATUM    BRDOK   D/P    IZNOS"
? cLinija2

return
*}

