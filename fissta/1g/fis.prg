#include "\dev\fmk\pos\pos.ch"



/*! \fn WriteArtikliXml(aArtikli, cFileName)
 *  \brief Kreira fajl ARTIKLI.XML i upisuje sadrzaj iz matrice aArtikli
 *  \param aArtikli  - matrica sa podacima o artiklima; struktura: 			{"idartikal","naziv","cijena","poreska stopa", "odjeljenje", "jmj"}
 *  \param cFileName - putanja ime izlaznog fajla
 */
function WriteArtikliXML(aArtikli, cFileName)
*{
   local nH

   * Kreiraj file
   if (nH:=fcreate(cFileName))==-1
      Beep(4)
      Msg("Fajl "+cFileName+" se vec koristi !",6)
      return
   endif
   fclose(nH)

   * Otvori file za upis
   set printer to (cFileName)
   set printer on
   set console off

   * Upiši zaglavlje XML file
   XMLWriteHeader()
   
   * Upiši body
   XMLWriteArticles(aArtikli)
   
   * Upiši footer
   XMLWriteFooter()
   
   * Zatvori file
   set printer to
   set printer off
   set console on

return
*}

function XMLWriteHeader()
*{
   ?? '<?xml version="1.0" standalone="no"?>'
   ? '<!DOCTYPE Artikli SYSTEM "Artikli.dtd">'

return
*}

function XMLWriteArticles(aArticles)
*{
local nRowCount, nRow

   ? '<Artikli>'
   nRowCount = LEN(aArticles)
   FOR nRow = 1 TO nRowCount
      sXMLLine := '<Plu ' 
      sXMLLine += 'Des="'+aArticles[nRow, 2]+'" '
      sXMLLine += 'Price="'+alltrim(str(aArticles[nRow, 3]))+'" '
      sXMLLine += 'Vat="'+aArticles[nRow, 4]+'" '
      sXMLLine += 'Dep="'+aArticles[nRow, 5]+'" '
      sXMLLine += 'Mes="'+aArticles[nRow, 6]+'">'
      sXMLLine += aArticles[nRow, 1]
      sXMLLine += '</Plu>'
      ? sXMLLine
   NEXT
   ? '</Artikli>'

return
*}

function XMLWriteFooter()
*{

return
*}



/*! \fn WriteArtRacunXml(aArtRacun, cFileName)
 *  \brief Kreira fajl ARTRACUN.XML i upisuje sadrzaj iz matrice aArtRacun
 *  \param aArtRacun  - matrica sa stavkama racuna; struktura:	{"kolicina","id artikal"}
 *  \param cFileName - putanja i ime izlaznog fajla
 */
function WriteArtRacunXML(aArtRacun, cFileName)
*{



return
*}


/*! \fn WritePlacanjaXml(nIznos, cTipPlacanja, cFileName)
 *  \brief Kreira fajl PLACANJA.XML i popunjava ga sa stavkama nIznos i cTipPlacanja
 *  \param nIznos  - ukupan iznos racuna
 *  \param cTipPlacanja - tip placanja (1, 2 ili 3)
 *  \param cFileName - putanja i ime izlaznog fajla
 */
function WritePlacanjaXML(nIznos, cTipPlacanja, cFileName)
*{



return
*}


/*! \fn ReadArtikliXml(cFilePath)
 *  \brief Vrsi iscitavanje podataka cFilePath + "ARTIKLI.XML" u matricu
 *  \param cFilePath - lokacija fajla ARTIKLI.XML
 *  \return aArtikli - matrica napunjena podacima o artiklima iz ARTIKLI.XML 
 */
 
function ReadArtikliXml(cFilePath)
*{
// aArtikli = {"id artikla", "naziv", "cijena", "poreska stopa", "odjeljenje", "jmj"}

return aArtikli
*}



/*! \fn WriteMainInCode(cCode, cFilePath)
 *  \brief Upisuje u fajl mainin.dat kod - cCode, 
     Napomena:
      - ako fajl mainin.dat ne postoji kreira ga i upisuje cCode
      - ako fajl mainin.dat postoji, brise sve iz njega i upisuje cCode
 *  \param cCode - kod
 *  \param cFilePath - lokacija fajla mainin.dat, mora biti lokacija interfejsa FisCTT
 */
function WriteMainInCode(cCode, cFilePath)
*{
if !File(cFilePath + "mainin.dat")
	// kreiraj fajl
endif

return
*}


/*! \fn ReadMainInCode(cFilePath)
 *  \brief Cita kod iz fajl-a mainin.dat
 *  \param cFilePath - lokacija fajla "mainin.dat"
 */
function ReadMainInCode(cFilePath)
*{
cCode:=""

return cCode
*}


/*! \fn WriteMainOutCode(cFilePath)
 *  \brief Upisuje u mainout.dat uvijek kod "999"
     Napomena:
      - ako fajl mainout.dat ne postoji, kreira se i upisuje se kod "999"
      - ako fajl mainout.dat postoji, brise njegov sadrzaj i upisuje kod "999"
 *  \param cFilePath - lokacija fajla mainout.dat, mora biti lokacija interfejsa FisCTT
 */
function WriteMainOutCode(cFilePath)
*{
// uvijek u mainout.dat upisi kod "999"
if !File(cFilePath + "mainout.dat")
	// kreiraj cFilePath + "mainout.dat"
endif


return
*}

/*! \fn ReadMainOutCode(cFilePath)
 *  \brief Cita iz fajla mainout.dat posljednju gresku - ako postoji, ako je kod "0" onda nema greske.
 *  \param cFilePath - lokacija fajla mainout.dat
 */
function ReadMainOutCode(cFilePath)
*{
cCode:=""

return cCode
*}




