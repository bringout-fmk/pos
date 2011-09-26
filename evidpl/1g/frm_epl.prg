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


/*! \fn FrmVPGetData(cIdVrstaPl, aCKData, aSKData, aGPData)
 *  \brief Centralni poziv formi za popunu podataka
 *  \param cIDVrstaP - id vrsta placanja
 *  \param aCKData - matrica podataka CEK
 *  \param aSKData - matrica podataka Sind.kredit
 *  \param aGPData - matrica podataka Gar.pismo
 */
function FrmVPGetData(cIdVrstaPl, aCKData, aSKData, aGPData)
*{

do case 
	case cIdVrstaPl=="CK"
		FormCekData(aCKData)
	case cIdVrstaPl=="SK"
		FormSindKredData(aSKData)
	case cIdVrstaPl=="GP"
		FormGarPismoData(aGPData)
endcase

return
*}

/*! \fn FormCekData(aCKData)
 *  \brief Forma za unos podataka CEK
 *  \param aCKData - matrica podataka cek
 */
function FormCekData(aCKData)
*{
local GetList:={}
local cCKBnkNaz:=SPACE(20)
local cCKBnkZrRn:=SPACE(13)
local cCKKupac:=SPACE(20)
local cCKBrLk:=SPACE(11)
local cCKSup:=SPACE(20)
local dCkLkDate:=CTOD("")
local cCKBr1:=cCKBr2:=cCKBr3:=cCKBr4:=cCKBr5:=SPACE(13)
local dCKIzd1:=dCKIzd2:=dCKIzd3:=dCKIzd4:=dCKIzd5:=CTOD("")
local nCKIzn1:=nCKIzn2:=nCKIzn3:=nCKIzn4:=nCKIzn5:=0
local cCKDN:="D"

Box(,19,60)
do while .t.
	//set cursor on
	@ 1+m_x,2+m_y SAY "Podaci kupac:" COLOR "I"
	@ 2+m_x,2+m_y SAY  REPLICATE("-", 58)
	@ 3+m_x,2+m_y SAY "        Ime i prezime:" GET cCKKupac VALID !Empty(cCKKupac) 
	@ 4+m_x,2+m_y SAY "              Broj LK:" GET cCKBrLK VALID !Empty(cCKBrLK) 
	@ 5+m_x,2+m_y SAY "                  SUP:" GET cCKSup VALID !Empty(cCKSup) 
	@ 6+m_x,2+m_y SAY "  Godina izdavanja LK:" GET dCKLKDate VALID !Empty(dCKLKDate) 
	
	@ 7+m_x,2+m_y SAY "Podaci banka:" COLOR "I" 
	@ 8+m_x,2+m_y SAY  REPLICATE("-", 58)
	@ 9+m_x,2+m_y SAY "                Naziv:" GET cCKBnkNaz VALID !Empty(cCKBnkNaz) 
	@ 10+m_x,2+m_y SAY "           Ziro racun:" GET cCKBnkZrRn VALID !Empty(cCKBnkZrRn) 
	@ 11+m_x,2+m_y SAY "Podaci CEK:" COLOR "I" 
	@ 12+m_x,2+m_y SAY  REPLICATE("-", 58)
	// cekovi
	@ 13+m_x,2+m_y SAY "1: Broj:" GET cCKBr1 
	@ 13+m_x,25+m_y SAY "Datum:" GET dCKIzd1  
	@ 13+m_x,41+m_y SAY "Iznos:" GET nCKIzn1 PICT "99999.99"  
	
	@ 14+m_x,2+m_y SAY "2: Broj:" GET cCKBr2 
	@ 14+m_x,25+m_y SAY "Datum:" GET dCKIzd2  
	@ 14+m_x,41+m_y SAY "Iznos:" GET nCKIzn2 PICT "99999.99"  
	
	@ 15+m_x,2+m_y SAY "3: Broj:" GET cCKBr3 
	@ 15+m_x,25+m_y SAY "Datum:" GET dCKIzd3  
	@ 15+m_x,41+m_y SAY "Iznos:" GET nCKIzn3 PICT "99999.99"  
	
	@ 16+m_x,2+m_y SAY "4: Broj:" GET cCKBr4 
	@ 16+m_x,25+m_y SAY "Datum:" GET dCKIzd4  
	@ 16+m_x,41+m_y SAY "Iznos:" GET nCKIzn4 PICT "99999.99"  
	
	@ 17+m_x,2+m_y SAY "5: Broj:" GET cCKBr5 
	@ 17+m_x,25+m_y SAY "Datum:" GET dCKIzd5  
	@ 17+m_x,41+m_y SAY "Iznos:" GET nCKIzn5 PICT "99999.99"  

	@ 19+m_x,2+m_y SAY "Unos ispravan (D/N)?" GET cCKDN VALID cCKDN$"DN" PICT "@!" 
	read
	
	if cCKDN=="D"
		exit
	endif
enddo
BoxC()

// napuni matricu
// [1] kupac
// [2] broj LK
// [3] sup
// [4] banka naziv
// [5] banka ziro rn.
// [6] datum izdavanja LK
// [7] broj ceka 1
// [8] iznos ceka 1
// [9] datum izdavanja ceka 1
// [10] broj ceka 2
// itd...

AADD(aCKData, ALLTRIM(cCKKupac))
AADD(aCKData, ALLTRIM(cCKBrLK))
AADD(aCKData, ALLTRIM(cCKSup))
AADD(aCKData, ALLTRIM(cCKBnkNaz))
AADD(aCKData, ALLTRIM(cCKBnkZrRn))
AADD(aCKData, dCKLKDate)

if !EMPTY(cCKBr1)
	AADD(aCKData, ALLTRIM(cCKBr1))
	AADD(aCKData, nCKIzn1)
	AADD(aCKData, dCKIzd1)
endif
if !EMPTY(cCKBr2)
	AADD(aCKData, ALLTRIM(cCKBr2))
	AADD(aCKData, nCKIzn2)
	AADD(aCKData, dCKIzd2)
endif
if !EMPTY(cCKBr3)
	AADD(aCKData, ALLTRIM(cCKBr3))
	AADD(aCKData, nCKIzn3)
	AADD(aCKData, dCKIzd3)
endif
if !EMPTY(cCKBr4)
	AADD(aCKData, ALLTRIM(cCKBr4))
	AADD(aCKData, nCKIzn4)
	AADD(aCKData, dCKIzd4)
endif
if !EMPTY(cCKBr5)
	AADD(aCKData, ALLTRIM(cCKBr5))
	AADD(aCKData, nCKIzn5)
	AADD(aCKData, dCKIzd5)
endif

return
*}


/*! \fn FormSindKredData(aSKData)
 *  \brief Forma za unos podataka SIN.KRED
 *  \param aSKData - matrica podataka sind.kredit
 */
function FormSindKredData(aSKData)
*{
local GetList:={}
local cSKFirma:=SPACE(20) // firma
local cSKFIdBr:=SPACE(20) // id broj kupca u firmi
local cSKBrLK:=SPACE(11)  // kupac, br LK
local cSKKupac:=SPACE(20) // ime i prezime kupca
local cSKJMBG:=SPACE(13)  // kupac JMBG
local nSKOdIzn:=0         // odobreni iznos kredita
local nSKBrRata:=6        // broj rata kredita   
local cSKDN:="N"

Box(,13,60)
do while .t.
	set cursor on
	@ 1+m_x,2+m_y SAY "Podaci kupac:" COLOR "I"
	@ 2+m_x,2+m_y SAY  REPLICATE("-", 58)
	@ 3+m_x,2+m_y SAY "          Ime i prezime:" GET cSKKupac VALID !Empty(cSKKupac) 
	@ 4+m_x,2+m_y SAY "                Broj LK:" GET cSKBrLk VALID !Empty(cSKBrLK) 
	@ 5+m_x,2+m_y SAY "                   JMBG:" GET cSkJMBG VALID !Empty(cSKJMBG) 
	@ 6+m_x,2+m_y SAY "                  Firma:" GET cSkFirma VALID !Empty(cSKFirma) 
	@ 7+m_x,2+m_y SAY "         Id broj(firma):" GET cSkFIdBr VALID !Empty(cSKFIdBr) 
	@ 8+m_x,2+m_y SAY "Podaci kredit:" COLOR "I"
	@ 9+m_x,2+m_y SAY  REPLICATE("-", 58)

	@ 10+m_x,2+m_y SAY "  Odobren iznos kredita:" GET nSKOdIzn VALID !Empty(nSKOdIzn) PICT "999999.99" 
	@ 11+m_x,2+m_y SAY "      Odobren broj rata:" GET nSKBrRata VALID !Empty(nSKBrRata) PICT "999" 
	
	
	@ 13+m_x,2+m_y SAY "Unos ispravan (D/N)?" GET cSKDN PICT "@!" VALID cSKDn$"DN" 
	read
	
	if cSKDN=="D"
		exit
	endif
enddo
BoxC()

// napuni matricu podacima
// [1] kupac
// [2] broj lk
// [3] jmbg
// [4] firma
// [5] firma id broj
// [6] odobren iznos kredita
// [7] broj rata kredita
AADD(aSKData, ALLTRIM(cSKKupac))
AADD(aSKData, ALLTRIM(cSKBrLK))
AADD(aSKData, ALLTRIM(cSKJMBG))
AADD(aSKData, ALLTRIM(cSKFirma))
AADD(aSKData, ALLTRIM(cSKFIdBr))
AADD(aSKData, nSkOdIzn)
AADD(aSKData, nSkBrRata)

return
*}


/*! \fn FormGarPismoData(aGPData)
 *  \brief Forma za unos podataka GAR.PISMO
 *  \param aGPData - matrica podataka gar.pismo
 */
function FormGarPismoData(aGPData)
*{
local GetList:={}
local cGpBroj:=SPACE(10) // broj g.pisma
local dGpDate:=DATE()    // datum g.pisma
local cGpKupac:=SPACE(20) // ime i prezime kupca
local cGpDN:="N"

Box(,7,60)
do while .t.
	set cursor on
	@ 1+m_x,2+m_y SAY "Podaci garantno pismo:" COLOR "I" 
	@ 2+m_x,2+m_y SAY  REPLICATE("-", 58)
	@ 3+m_x,2+m_y SAY "Kupac: ime i prezime:" GET cGpKupac VALID !Empty(cGpKupac) 
	@ 4+m_x,2+m_y SAY "             Broj gp:" GET cGpBroj VALID !Empty(cGpBroj) 
	@ 5+m_x,2+m_y SAY "  Datum izdavanja gp:" GET dGpDate VALID !Empty(dGpDate) 
	
	@ 7+m_x,2+m_y SAY "Unos ispravan (D/N)?" GET cGpDN PICT "@!" VALID cGpDn$"DN" 
	read
	
	if cGpDN=="D"
		exit
	endif
enddo
BoxC()

// napuni matricu podacima
// [1] kupac
// [2] broj gp
// [3] datum izdavanja
AADD(aGPData, ALLTRIM(cGpKupac))
AADD(aGPData, ALLTRIM(cGpBroj))
AADD(aGPData, dGpDate)

return
*}



