#include "\dev\fmk\pos\pos.ch"


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
local cCKBrLk:=SPACE(13)
local cCKSup:=SPACE(20)
local dCkLkDate:=DATE()
local cCKBr:=SPACE(10)
local dCKIzd:=DATE()
local cCKDN:="N"

Box(,18,60)
do while .t.
	set cursor on
	@ 1+m_x,2+m_y SAY "Podaci kupac:" 
	@ 2+m_x,2+m_y SAY  REPLICATE("-", 58)
	@ 3+m_x,2+m_y SAY "        Ime i prezime:" GET cCKKupac VALID !Empty(cCKKupac) 
	@ 4+m_x,2+m_y SAY "              Broj LK:" GET cCKBrLK VALID !Empty(cCKBrLK) 
	@ 5+m_x,2+m_y SAY "                  SUP:" GET cCKSup VALID !Empty(cCKSup) 
	@ 6+m_x,2+m_y SAY "  Godina izdavanja LK:" GET dCKLKDate VALID !Empty(dCKLKDate) 
	
	@ 8+m_x,2+m_y SAY "Podaci banka:" 
	@ 9+m_x,2+m_y SAY  REPLICATE("-", 58)
	@ 10+m_x,2+m_y SAY "                Naziv:" GET cCKBnkNaz VALID !Empty(cCKBnkNaz) 
	@ 11+m_x,2+m_y SAY "           Ziro racun:" GET cCKBnkZrRn VALID !Empty(cCKBnkZrRn) 
	@ 13+m_x,2+m_y SAY "Podaci CEK:" 
	@ 14+m_x,2+m_y SAY  REPLICATE("-", 58)
	@ 15+m_x,2+m_y SAY "            Broj ceka:" GET cCKBr VALID !Empty(cCKBr) 
	@ 16+m_x,2+m_y SAY "      Datum izdavanja:" GET dCKIzd VALID !Empty(dCKIzd) 
	
	@ 18+m_x,2+m_y SAY "Unos ispravan (D/N)?" GET cCKDN VALID cCKDN$"DN" PICT "@!" 
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
// [6] broj ceka
// [7] datum izdavanja LK
// [8] datum izdavanja ceka

AADD(aCKData, ALLTRIM(cCKKupac))
AADD(aCKData, ALLTRIM(cCKBrLK))
AADD(aCKData, ALLTRIM(cCKSup))
AADD(aCKData, ALLTRIM(cCKBnkNaz))
AADD(aCKData, ALLTRIM(cCKBnkZrRn))
AADD(aCKData, ALLTRIM(cCKBr))
AADD(aCKData, dCKLKDate)
AADD(aCKData, dCKIzd)

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
local cSKBrLK:=SPACE(10)  // kupac, br LK
local cSKKupac:=SPACE(20) // ime i prezime kupca
local cSKJMBG:=SPACE(13)  // kupac JMBG
local nSKOdIzn:=0         // odobreni iznos kredita
local nSKBrRata:=6        // broj rata kredita   
local cSKDN:="N"

Box(,13,60)
do while .t.
	set cursor on
	@ 1+m_x,2+m_y SAY "Podaci kupac:" 
	@ 2+m_x,2+m_y SAY  REPLICATE("-", 58)
	@ 3+m_x,2+m_y SAY "          Ime i prezime:" GET cSKKupac VALID !Empty(cSKKupac) 
	@ 4+m_x,2+m_y SAY "                Broj LK:" GET cSKBrLk VALID !Empty(cSKBrLK) 
	@ 5+m_x,2+m_y SAY "                   JMBG:" GET cSkJMBG VALID !Empty(cSKJMBG) 
	@ 6+m_x,2+m_y SAY "                  Firma:" GET cSkFirma VALID !Empty(cSKFirma) 
	@ 8+m_x,2+m_y SAY "Podaci kredit:" 
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
// [5] odobren iznos kredita
// [6] broj rata kredita
AADD(aSKData, ALLTRIM(cSKKupac))
AADD(aSKData, ALLTRIM(cSKBrLK))
AADD(aSKData, ALLTRIM(cSKJMBG))
AADD(aSKData, ALLTRIM(cSKFirma))
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
	@ 1+m_x,2+m_y SAY "Podaci garantno pismo:" 
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



