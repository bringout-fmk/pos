#include "\dev\fmk\pos\pos.ch"


/*! \fn Fis_test_main()
 *  \brief glavna testna funkcija koja poziva sve test caseove
 */
 
function Fis_test_main()
*{

aInput:={}
// aInput: id artikla (oid), naziv, cijena, por.stopa, odjeljenje, jmj
AADD(aInput, {"100000000010", "EFFEGI 2340", 1000.00, "3", "1", "6"})
AADD(aInput, {"100000000251", "KLOMPE Z.BIJELE", 890.50, "3", "1", "6"})
AADD(aInput, {"100000003120", "ILLUMINATI 22/33", 2780.00, "3", "1", "6"})
AADD(aInput, {"100000006129", "PLACENTE 2350/80", 3020.40, "3", "1", "6"})

cOutPutFile:="h:\dev\fmk\pos\fissta\1g\testxml\art01.xml"

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


