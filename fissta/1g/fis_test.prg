#include "\dev\fmk\pos\pos.ch"


/*! \fn Fis_test_main()
 *  \brief glavna testna funkcija koja poziva sve test caseove
 */
 
function Fis_test_main()
*{

aInput:={}
lFisArtikli:=FisTestWriteArtikliXml(aInput, cOutputFile)

if lFisArtikli
	? "Test OK"
endif





return
*}


/*! \fn FisTestWriteArtikliXml(aInput, cOutPutFile)
 *  \brief testiranje ispravnosti kreiranog fajla ARTIKLI.XML
 *  \param aInput - matrica sa ulaznim podacima
 *  \param cOutPutFile - definisani ARTIKLI.XML fajl za kontrolu
 */
function FisTestWriteArtikliXml(aInput, cOutPutFile)
*{

? "Test ispravnosti kreiranja fajla ARTIKLI.XML"

WriteArtikliXML(aInput)
// uporedi kreirani fajl sa cOutPutFile
lReturn:=ReadError()

return lReturn
*}


