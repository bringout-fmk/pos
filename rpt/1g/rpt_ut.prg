#include "pos.ch"


/*! \fn O_TK_DB()
 *  \brief Otvori tabele potrebne za izvjestaj Trg.knjiga
 */
function O_TK_DB()
*{
O_KASE
O_ODJ
O_DIO
O_SIFK
O_SIFV
O_ROBA
O_SIROV
O_POS
return
*}




/*! \fn ZagFirma()
 *  \brief Stampa zaglavlja sa firmom
 */
function ZagFirma()
*{
local cStr, nLines, cFajl, i, nOfset:=0

if (!EMPTY(gZagIz))
	cFajl:=PRIVPATH+AllTrim(gRnHeder)
	nLines:=BrLinFajla(cFajl)
	for i:=1 to nLines
		aPom:=SljedLin(cFajl,nOfset)
		cRed:=aPom[1]
		nOfset:=aPom[2]
		if (ALLTRIM(STR(i))$gZagIz)
			? cRed
		endif
	next
endif

return
*}


