#include "\dev\fmk\pos\pos.ch"



/*! \fn WrArtikliXml(aArtikli, cFilePath)
 *  \brief Kreira fajl ARTIKLI.XML i upisuje sadrzaj iz matrice aArtikli
 *  \param aArtikli  - matrica sa podacima o artiklima; struktura: {"idartikal","naziv","cijena","poreska stopa", "odjeljenje", "jmj"}
 *  \param cFilePath - lokacija fajla ARTIKLI.XML, mora biti lokacija interfejsa FisCTT
 */
function WrArtikliXML(aArtikli, cFilePath)
*{
local nH, cFileName

cFileName := cFilePath+'artikli.xml'
// Kreiraj file
if (nH:=fcreate(cFileName))==-1
   Beep(4)
   Msg("Greska pri kreiranju fajla: "+cFileName+" !",6)
   return
endif

fclose(nH)

// Otvori file za upis
set printer to (cFileName)
set printer on
set console off

   // Upiši zaglavlje XML file
   XMLWriteHeader('Artikli')
   // Upiši body
   lResult := XMLWriteArticles(aArtikli)
   // Upiši footer
   XMLWriteFooter()
   
// Zatvori file
set printer to
set printer off
set console on

// ako je nastupila greska izbrisi artikli.xml
if !lResult
   FERASE(cFileName)
endif

return
*}

/*! \fn XMLWriteHeader()
 *  \brief Ispisuje Header XML fajla ARTIKLI.XML, prereqiust set printer to (cFileName)
 *  \param cFile - naziv XML fajla
 */
function XMLWriteHeader(cFile)
*{
   ?? '<?xml version="1.0" standalone="no"?>'
   ? '<!DOCTYPE '+cFile+' SYSTEM "'+cFile+'.dtd">'

return
*}


/*! \fn XMLWriteArticles(aArticles)
 *  \brief upisuje body ARTIKLI.XML 
 *  \param aArtikli - matrica napunjena podacima o artiklima iz ARTIKLI.XML
 *  \return .t. ako nema greske, inace .f.
 */
function XMLWriteArticles(aArticles)
*{
local nRowCount, nRow, sXMLLine

   ? '<Artikli>'
   nRowCount = LEN(aArticles)
   FOR nRow = 1 TO nRowCount
      sXMLLine := '<Plu ' 
      
      if (CheckLength(aArticles[nRow, 2], 18))
         sXMLLine += 'Des="'+aArticles[nRow, 2]+'" '
      else
         return .f.
      endif
      
      if (CheckLength(alltrim(str(aArticles[nRow, 3])), 9))
         // provjerava broj decimala
         if (right(alltrim(str(aArticles[nRow, 3])), 3) = '.')
            sXMLLine += 'Price="'+alltrim(str(aArticles[nRow, 3]))+'" '
         else
            Beep(4)
            Msg("Neispravan broj decimala "+alltrim(str(aArticles[nRow, 3]))+", potrebno dvije decimale !",6)
            return .f.
         endif
      else
         return .f.
      endif

      if (CheckLength(aArticles[nRow, 4], 1))
         sXMLLine += 'Vat="'+aArticles[nRow, 4]+'" '
      else
         return .f.
      endif

      if (CheckLength(aArticles[nRow, 5], 9))
         sXMLLine += 'Dep="'+aArticles[nRow, 5]+'" '
      else
         return .f.
      endif

      if (CheckLength(aArticles[nRow, 6], 2))
         sXMLLine += 'Mes="'+aArticles[nRow, 6]+'">'
      else
         return .f.
      endif

      if (CheckLength(aArticles[nRow, 1], 12))
         sXMLLine += aArticles[nRow, 1]
      else
         return .f.
      endif
      sXMLLine += '</Plu>'
      ? sXMLLine
   NEXT
   ? '</Artikli>'

return .t.
*}

/*! \fn CheckLength(cString, nLength)
 *  \brief ispituje duzinu stringa cString 
 *  \param cString - string koji se ispituje
 *  \param nLength - maksimalna dužina stringa
 *  \return .t. ako je string manji ili jednak nLength, inace .f.
 */
function CheckLength(cString, nLength)
local lResult

   if (len(cString)>nLength)
      Beep(4)
      Msg("Neispravna duzina "+cString+", max("+alltrim(str(nLength))+") !",6)
      lResult := .f.
   else
      lResult := .t.
   endif
   
return lResult


/*! \fn XMLWriteFooter()
 *  \brief Ispisuje Footer XML fajlova, XML fajlovi nemaju footera pa je zato prazno
 *  \param cFile - naziv XML fajla
 */
function XMLWriteFooter(cFile)
*{

return
*}


/*! \fn WrArtRacunXml(aArtRacun, cFileName)
 *  \brief Kreira fajl ARTRACUN.XML i upisuje sadrzaj iz matrice aArtRacun
 *  \param aArtRacun  - matrica sa stavkama racuna; struktura:	{"kolicina","id artikal"}
 *  \param cFilePath - lokacija fajla ARTRACUN.XML, mora biti lokacija interfejsa FisCTT
 */
function WrArtRacunXML(aArtRacun, cFilePath)
*{
local nH, cFileName

cFileName := cFilePath+'artracun.xml'
// Kreiraj file
if (nH:=fcreate(cFileName))==-1
   Beep(4)
   Msg("Greska pri kreiranju fajla: "+cFileName+" !",6)
   return
endif

fclose(nH)

// Otvori file za upis
set printer to (cFileName)
set printer on
set console off

   // Upiši zaglavlje XML file
   XMLWriteHeader('ArtRacun')
   // Upiši body
   lResult := XMLWriteCheck(aArtRacun)
   // Upiši footer
   XMLWriteFooter('ArtRacun')
   
// Zatvori file
set printer to
set printer off
set console on

// ako je nastupila greska izbrisi artracun.xml
if !lResult
   FERASE(cFileName)
endif

return
*}

/*! \fn XMLWriteCheck(aArtCheck)
 *  \brief upisuje body ARTRACUN.XML 
 *  \param aArtCheck - matrica napunjena podacima o racunima iz ARTRACUN.XML
 *  \return .t. ako nema greske, inace .f.
 */
function XMLWriteCheck(aArtCheck)
*{
local nRowCount, nRow, sXMLLine

   ? '<ArtRacun>'
   nRowCount = LEN(aArtCheck)
   FOR nRow = 1 TO nRowCount
      sXMLLine := '<Plu ' 

      if (CheckLength(alltrim(str(aArtCheck[nRow, 1])), 8))
         // provjerava broj decimala
         if (right(alltrim(str(aArtCheck[nRow, 1])), 3) = '.')
            sXMLLine += 'kol="'+alltrim(str(aArtCheck[nRow, 1]))+'">'
         else
            Beep(4)
            Msg("Neispravan broj decimala "+alltrim(str(aArtCheck[nRow, 1]))+", potrebno dvije decimale !",6)
            return .f.
         endif
      else
         return .f.
      endif

      if (CheckLength(aArtCheck[nRow, 2], 12))
         sXMLLine += aArtCheck[nRow, 2]
      else
         return .f.
      endif
      sXMLLine += '</Plu>'
      ? sXMLLine
   NEXT
   ? '</ArtRacun>'

return .t.
*}

/*! \fn WrPlacanjaXml(nIznos, cTipPlacanja, cFileName)
 *  \brief Kreira fajl PLACANJA.XML i popunjava ga sa stavkama nIznos i cTipPlacanja
 *  \param nIznos  - ukupan iznos racuna
 *  \param cTipPlacanja - tip placanja (1, 2 ili 3)
 *  \param cFilePath - lokacija fajla PLACANJA.XML, mora biti lokacija interfejsa FisCTT
 */
function WrPlacanjaXML(nIznos, cTipPlacanja, cFilePath)
*{
local nH, cFileName, lResult

lResult := .t.
cFileName := cFilePath+'placanja.xml'
// Kreiraj file
if (nH:=fcreate(cFileName))==-1
   Beep(4)
   Msg("Greska pri kreiranju fajla: "+cFileName+" !",6)
   return
endif

fclose(nH)

// Otvori file za upis
set printer to (cFileName)
set printer on
set console off

   // Upiši zaglavlje XML file
   XMLWriteHeader('Placanja')
   // Upiši body
   ? '<Placanja>'
   if ((nIznos <> nil) .and. (cTipPlacanja <> nil))
      sXMLLine := '<Vrsta '
      if (CheckLength(alltrim(str(nIznos)), 9))
         // provjerava broj decimala
         if (right(alltrim(str(nIznos)), 3) = '.')
            sXMLLine += 'kol="'+alltrim(str(nIznos))+'">'
         else
            Beep(4)
            Msg("Neispravan broj decimala "+alltrim(str(nIznos))+", potrebno dvije decimale !",6)
            lResult := .f.
         endif
      else
         lResult := .f.
      endif

      if (CheckLength(alltrim(cTipPlacanja), 1))
         sXMLLine += alltrim(cTipPlacanja)
      else
         lResult := .f.
      endif
      sXMLLine += '</Vrsta>'
      ? sXMLLine
   endif
   ? '</Placanja>'
   
   // Upiši footer
   XMLWriteFooter('Placanja')
   
// Zatvori file
set printer to
set printer off
set console on

// ako je nastupila greska izbrisi artracun.xml
if !lResult
   FERASE(cFileName)
endif

return
*}


/*! \fn RdArtikliXml(cFilePath)
 *  \brief Vrsi iscitavanje podataka cFilePath + "ARTIKLI.XML" u matricu
 *  \param cFilePath - lokacija fajla ARTIKLI.XML
 *  \return aArtikli - matrica napunjena podacima o artiklima iz ARTIKLI.XML 
 */
function RdArtikliXml(cFilePath)
*{
// aArtikli = {"id artikla", "naziv", "cijena", "poreska stopa", "odjeljenje", "jmj"}

local cFileName, cXML

aArtikli = {}
cFileName := cFilePath+'artikli.xml'
cXML := FILESTR(cFileName)

nStart := at('<Plu', cXML)
while (nStart>0)
   nEnd     := at('</Plu>', cXML)+6
   cXMLLine := substr(cXML, nStart, (nEnd-nStart))

   nStartField := at('">', cXMLLine)+2
   nEndField   := at('</Plu>', cXMLLine)
   cID         := substr(cXMLLine, nStartField, nEndField-nStartField)
   
   nStartField := at('Des="', cXMLLine)+5
   nEndField   := at('" Price="', cXMLLine)
   cName       := substr(cXMLLine, nStartField, nEndField-nStartField)

   nStartField := at('Price="', cXMLLine)+7
   nEndField   := at('" Vat="', cXMLLine)
   cPrice      := substr(cXMLLine, nStartField, nEndField-nStartField)

   nStartField := at('Vat="', cXMLLine)+5
   nEndField   := at('" Dep="', cXMLLine)
   cVat        := substr(cXMLLine, nStartField, nEndField-nStartField)

   nStartField := at('Dep="', cXMLLine)+5
   nEndField   := at('" Mes="', cXMLLine)
   cDep        := substr(cXMLLine, nStartField, nEndField-nStartField)

   nStartField := at('Mes="', cXMLLine)+5
   nEndField   := at('">', cXMLLine)
   cMes        := substr(cXMLLine, nStartField, nEndField-nStartField)

   AADD(aArtikli, {cID, cName, val(cPrice), cVat, cDep, cMes})

   cXML   := substr(cXML, nEnd)
   nStart := at('<Plu', cXML)

end

return aArtikli
*}


/*! \fn RdArtRacunXml(cFilePath)
 *  \brief Vrsi iscitavanje podataka cFilePath + "ARTRACUN.XML" u matricu
 *  \param cFilePath - lokacija fajla ARTRACUN.XML
 *  \return aArtikli - matrica napunjena podacima iz ARTRACUN.XML 
 */
function RdArtRacunXml(cFilePath)
*{
// aArtRacun = {"kolicina", "id artikla"}
local cFileName, cXML

   aArtRacun:={}
   cFileName := cFilePath+'artracun.xml'

   cXML := FILESTR(cFileName)

   nStart := at('<Plu', cXML)
   while (nStart>0)
      nEnd     := at('</Plu>', cXML)+6
      cXMLLine := substr(cXML, nStart, (nEnd-nStart))

      nStartField := at('">', cXMLLine)+2
      nEndField   := at('</Plu>', cXMLLine)
      cID         := substr(cXMLLine, nStartField, nEndField-nStartField)
   
      nStartField := at('kol="', cXMLLine)+5
      nEndField   := at('">', cXMLLine)
      cKol        := substr(cXMLLine, nStartField, nEndField-nStartField)

      AADD(aArtRacun, {val(cKol), cID})

      cXML   := substr(cXML, nEnd)
      nStart := at('<Plu', cXML)
   end
   
return aArtRacun
*}


/*! \fn RdPlacanjaXml(cFilePath)
 *  \brief Vrsi iscitavanje podataka cFilePath + "PLACANJA.XML" u matricu
 *  \param cFilePath - lokacija fajla PLACANJA.XML
 *  \return aArtikli - matrica napunjena podacima iz PLACANJA.XML 
 */ 
function RdPlacanjaXml(cFilePath)
*{
// aPlacanja = {"iznos", "tip placanja"}
local cFileName, cXML

   aPlacanja:={}
   cFileName := cFilePath+'placanja.xml'
   
   cXML := FILESTR(cFileName)
   
   nStart := at('<Vrsta', cXML)
   while (nStart>0)
      nEnd     := at('</Vrsta>', cXML)+8
      cXMLLine := substr(cXML, nStart, (nEnd-nStart))
   
      nStartField := at('">', cXMLLine)+2
      nEndField   := at('</Vrsta>', cXMLLine)
      cID         := substr(cXMLLine, nStartField, nEndField-nStartField)
      
      nStartField := at('kol="', cXMLLine)+5
      nEndField   := at('">', cXMLLine)
      cKol        := substr(cXMLLine, nStartField, nEndField-nStartField)
   
      AADD(aPlacanja, {val(cKol), cID})
   
      cXML   := substr(cXML, nEnd)
      nStart := at('<Plu', cXML)
   end
   
return aPlacanja
*}


/*! \fn WrMainInCode(cCode, cFilePath)
 *  \brief Upisuje u fajl mainin.dat kod - cCode, 
     Napomena:
      - ako fajl mainin.dat ne postoji kreira ga i upisuje cCode
      - ako fajl mainin.dat postoji, brise sve iz njega i upisuje cCode
 *  \param cCode - kod
 *  \param cFilePath - lokacija fajla mainin.dat, mora biti lokacija interfejsa FisCTT
 */
function WrMainInCode(cCode, cFilePath)
*{
   local nH, cFileName
   cFileName := cFilePath + 'mainin.dat'
   
   WrFileCode(cCode, cFileName)

return
*}


/*! \fn RdMainInCode(cFilePath)
 *  \brief Cita kod iz fajl-a mainin.dat
 *  \param cFilePath - lokacija fajla "mainin.dat"
 *  \return cCode - proèitani kod
*/
function RdMainInCode(cFilePath)
*{
   local cFileName, cCode
   cFileName := cFilePath + 'mainin.dat'

   cCode:= RdFileCode(cFileName)

return cCode
*}


/*! \fn WrMainOutCode(cFilePath, cTestCode)
 *  \brief Upisuje u mainout.dat uvijek kod "999"
     Napomena:
      - ako fajl mainout.dat ne postoji, kreira se i upisuje se kod "999"
      - ako fajl mainout.dat postoji, brise njegov sadrzaj i upisuje kod "999"
 *  \param cFilePath - lokacija fajla mainout.dat, mora biti lokacija interfejsa FisCTT
 *  \param cTestCode - koristi se kao testni kod, po def.ovog parametra nema
 */
function WrMainOutCode(cFilePath, cTestCode)
*{
   // uvijek u mainout.dat upisi kod "999"
   local nH, cFileName
   cFileName := cFilePath + 'mainout.dat'

   cCode:="999"
   
   if cTestCode <> nil
   	cCode:=cTestCode
   endif
   
   WrFileCode(cCode, cFileName)

return
*}

/*! \fn RdMainOutCode(cFilePath)
 *  \brief Cita iz fajla mainout.dat posljednju gresku - ako postoji, ako je kod "0" onda nema greske.
 *  \param cFilePath - lokacija fajla mainout.dat
 */
function RdMainOutCode(cFilePath)
*{
   local cFileName, cCode
   cFileName := cFilePath + 'mainout.dat'

   cCode:= RdFileCode(cFileName)

return cCode
*}

/*! \fn WrFileCode(cCode, cFileName)
 *  \brief Upisuje u fajl cFileName - cCode, 
     Napomena:
      - ako fajl cFileName ne postoji kreira ga i upisuje cCode
 *  \param cCode - kod
 *  \param cFileName - naziv fajla sa kompletnim path-om
 */
function WrFileCode(cCode, cFileName)
*{
local nH
   
// kreiraj fajl ponovo, tako da smo sigurni da je prazan
if file(cFileName)
	ferase(cFileName)
endif
   
if (nH:=fcreate(cFileName))==-1
	Beep(4)
      	Msg("Greska pri kreiranju fajla: "+cFileName+" !",6)
      	return
endif
fclose(nH)

// Otvori file za upis
set printer to (cFileName)
set printer on
set console off

// Upisi cCode
// kada probam upisati sa ? - doda jednu praznu liniju viska

?? ALLTRIM(cCode)
      
// Zatvori file
set printer to
set printer off
set console on


return
*}


/*! \fn RdFileCode(cFileName)
 *  \brief Cita kod iz fajl-a cFileName
 *  \param cFileName - naziv fajla sa kompletnim path-om
 *  \return - sadržaj iz cFileName
 */
function RdFileCode(cFileName)
*{
   local cCode
   cCode:=''

   cCode := alltrim(FILESTR(cFileName))

return cCode
*}



/*! \fn StartFisCTTInterface(bSilent)
 *  \brief Starta FisCTT interfejs
 *  \param bSilent - .t. - startaj FisCTT bez pitanja, .f. - postavi pitanje
 */
function StartFisCTTInterface(bSilent)
*{

cPath:=gFisCTTPath

if bSilent == nil
	bSilent:=.t.
endif

if !bSilent .and. Pitanje(,"Startati FisCTT interfejs (D/N)?", "D")=="N"
	return
endif

cPath:=ALLTRIM(cPath)

if RIGHT(cPath, 1) <> SLASH
	cPath += SLASH
endif

if !DirExists(cPath)
	MsgBeep("Ne postoji direktorij: " + cPath + "# Prekidam operaciju!")
	return
endif

// Prije pokretanja interfejsa postavi kod za inicijalizaciju
WrMainInCode("0", cPath)

MsgO("Pokrecem FisCTT interfejs...")

cKomLin:="start " + cPath + "fiscal28.jar"

// pokreni komandu
run &cKomLin

// sacekaj da se interfejs pokrene
sleep(gFisTimeOut + 5)

MsgC()

if RdMainInCode(cPath)=="9"
	if !bSilent
		MsgBeep("Interfejs pokrenut ...")
	endif
else
	if !bSilent
		MsgBeep("Problem sa pokretanjem FisCTT")
	endif
endif


return
*}

/*! \fn FillFisMatrice(aArtikli, aArtRacun, nUkupno)
 *  \brief Puni matrice ARTIKLI.XML i ARTRACUN.XML podacima iz pripreme
 *  \param @aArtikli matrica artikala 
 *  \param @aArtRacun matrica racuna
 *  \param @nUkupno ukupan iznos racuna
*/
function FillFisMatrice(aArtikli, aArtRacun, nUkupno)
*{
local nArr:= SELECT()

O__PRIPR

select _pripr
go top

do while !eof() //.and. field->idvd=="42"
	cID:=GetArtCodeFromRoba(_pripr->idroba)
      	cNaziv      := left(alltrim(_pripr->robanaz),18) 
      	nCijena1    := val(str(_pripr->Cijena,9,2))
      	cPorez      := GetCodeTarifa(alltrim(_pripr->idtarifa)) 
      	cDepartment := '1'
      	cJedMjere   := GetCodeForArticleUnit(alltrim(_pripr->jmj)) 
      	nKolicina   := val(str(_pripr->kolicina,8,2))
      
      	AADD(aArtikli, {cID, cNaziv, nCijena1, cPorez, cDepartment, cJedMjere})
      	AADD(aArtRacun, {nKolicina, cID})
      	nUkupno += nCijena1 * nKolicina
      	skip
enddo

nUkupno:=VAL(STR(nUkupno, 9, 2))

SELECT (nArr)

return
*}


/*! \fn ChkRnType()
 *  \brief Provjerava o kakvom se tipu racuna radi
 *  \return nRet -
 *                 -1: cisti storno (sve kolicine -)
 *                  0: miksani racun (kolicine +/-)
 *                  1: cist racun (sve kolicine +)
 */
function ChkRnType()
*{
local nArr
nArr:=SELECT()

nRet:=0

O__PRIPR
go top

nZbirKol:=0
nZbirABS:=0

do while !EOF()
	nZbirKol+=field->kolicina
	nZbirABS+=ABS(field->kolicina)
	skip
enddo

if (nZbirKol == nZbirABS)
	nRet := 1
elseif (nZbirKol == -nZbirABS)
	nRet := -1
else
	nRet :=0
endif

select (nArr)

return nRet 
*}



/*! \fn GetArtCodeFromRoba(cIDRoba)
 *  \brief Vraca roba._oid_ za roba.idroba
 *  \param cIDRoba - id robe (roba->idroba)
 */
function GetArtCodeFromRoba(cIDRoba)
*{
   cCode:=""
   nWorkArea:= SELECT()
   O_ROBA
   select roba
   set order to tag "ID"
   
   HSEEK alltrim(cIDRoba)
	cCode := alltrim(STR(roba->_oid_))
   SELECT (nWorkArea)

return cCode
*}

/*! \fn GetCodeForArticleUnit(cUnit)
 *  \brief Vraca FISSTA "kod" JMJ na osnovu opisa roba->jmj
 *  \param cUnit - jedinica mjere (roba->jmj), npr "PAR"
 */
function GetCodeForArticleUnit(cUnit)
*{
cCode:=""

do case
	case cUnit=="KOM"
		cCode:="1"
	case cUnit=="KG"
		cCode:="2"
	case cUnit=="M"
		cCode:="3"
	case cUnit=="L"
		cCode:="4"
	case cUnit=="G"
		cCode:="5"
	case cUnit=="PAR"
		cCode:="6"
endcase

return cCode
*}


/*! \fn GetCodeVrstePl(cIdVrstaPl)
 *  \brief Vraca FISSTA kodove za pojedine tops->vrsta placanja
 *  \param cIdVrstaPl - id vrsta placanja, npr "01"
 */
function GetCodeVrstePl(cIdVrstaPl)
*{
cCode:=""

do case
	// 01 - gotovina
	case cIdVrstaPl=="01"
		cCode:="1"
	// CK - cek
	case cIdVrstaPl=="CK"
		cCode:="2"
	// KK - kreditna kartica
	case cIdVrstaPl=="KK"
		cCode:="3"
	// sve ove vrste placanja idu kao CEK (2)	
	// GP - garantno pismo
	case cIdVrstaPl=="GP"
		cCode:="2"
	// SK - sindikalni kredit
	case cIdVrstaPl=="SK"
		cCode:="2"
	// ZR - ziro racun
	case cIdVrstaPl=="ZR"
		cCode:="2"
endcase

return cCode
*}



/*! \fn GetCodeTarifa(cIdTarifa)
 *  \brief Vraca FISSTA kodove tarifa na osnovu TOPS->idtarifa
 *  \param cIdTarifa - TOPS->id tarifa
 */
function GetCodeTarifa(cIdTarifa)
*{
// standardni set tarifa u TOPS-u / planikaNS
// 1 - PPP 20%
// 0 - PPP 0% (mada se i ne koristi)

cCode:=""
do case
	// 0 - por 0%
	case cIdTarifa=="0"
		cCode:="0"
	// 1 - por 20%
	case cIdTarifa=="1"
		cCode:="2"
endcase

return cCode
*}



/*! \fn GetErrFromCode(cCode)
 *  \brief Vraca opis greske na osnovu koda cCode
 *  \param cCode - "kod" greske
 */
function GetErrFromCode(cCode)
*{

cErr:=""

do case
	case cCode == "-37"
		cErr:="-37: U stampacu nema racuna"	
	case cCode == "-36"
		cErr:="-36: Nedostaje baza artikala - komanda 1"
	case cCode == "-35"
		cErr:="-35: Nepravilna vrijednost COM porta"
	case cCode == "-34"
		cErr:="-34: Nepravilan format vrijednosti placanja"
	case cCode == "-33"
		cErr:="-33: Nepravilan format vrste placanja"
	case cCode == "-32"
		cErr:="-32: Niste definisali ni jedno placanje"
	case cCode == "-31"
		cErr:="-31: Prevelik broj stavki placanja#za jedan artikal"
	case cCode == "-30"
		cErr:="-30: Prevelik broj artikala za jedan racun"
	case cCode == "-29"
		cErr:="-29: Nepravilno formiran racun"
	case cCode == "-28"
		cErr:="-28: Ne postoji definicija artikla"
	case cCode == "-27"
		cErr:="-27: Nepravilan format XML fajla"
	case cCode == "-26"
		cErr:="-26: Ne postoji fajl#izbrisan ili koruptovan"
	case cCode == "-25"
		cErr:="-25: Nepravilno formirani podaci"
	case cCode == "-23"
		cErr:="-23: Ne moze se stornirati racun, mora se ponistiti"
	case cCode == "-22"
		cErr:="-22: Postoji zapocet racun, operacija odbijena"
	case cCode == "-21"
		cErr:="-21: Greska u uredjaju"
	case cCode == "-6"
		cErr:="-6: Ne podrzavanje javax.comm paketa"
	case cCode == "-5"
		cErr:="-5: Nemogucnost komunikacije sa portom"
	case cCode == "-4"
		cErr:="-4: Zauzet port"
	case cCode == "-3"
		cErr:="-3: Ne postoji port"
	case cCode == "-2"
		cErr:="-2: Ne inicijalizovan port"
	case cCode == "-1"
		cErr:="-1: No connection"
	case cCode == "1"
		cErr:="1: Nemogucnost izvrsenja operacije"
	case cCode == "2"
		cErr:="2: Nije definisan artikal"
	case cCode == "3"
		cErr:="3: Vrijednost KOLICINA * CIJENA#je prevelika za racun"
	case cCode == "8"
		cErr:="8: Nepravilno unjeta vrijednost"
	case cCode == "20"
		cErr:="20: Podignuta glava stampaca"
	case cCode == "22"
		cErr:="22: Nema papira"
	case cCode == "47"
		cErr:="47: Nedostaje poreska stopa"
	case cCode == "50"
		cErr:="50: Nedovoljno na lageru"
	case cCode == "99"
		cErr:="99: Neobradjena greska: pozovite nas"
	case cCode == "100"
		cErr:="100: Nepravilan BARKOD"
	case cCode == "101"
		cErr:="101: Nepravilno formiran naziv artikla"
	case cCode == "102"
		cErr:="102: Nepravilno formirana cijena"
	case cCode == "103"
		cErr:="103: Nepravilno formirana poreska stopa"
	case cCode == "104"
		cErr:="104: Nepravilno formirano odjeljenje"
	case cCode == "105"
		cErr:="105: Nepravilno formirana jedinica mjere"
	case cCode == "106"
		cErr:="106: Nepravilan format kolicine"
	case cCode == "108"
		cErr:="108: Dosegnut max.broj programiranih artikala"
	case cCode == "109"
		cErr:="109: Greska pri brisanju"
	case cCode == "110"
		cErr:="110: Za izvrsenje operacije mora se uraditi#dnevni izvjestaj"
	case cCode == "112"
		cErr:="112: Greska na stampacu, podignuta glava#nema papira..."
endcase


return cErr
*}



/*! \fn CheckFisCTTStarted(bSilent)
 *  \brief Centralna funkcija za provjeru FisCTT, da li je vec pokrenut?
 *  \param bSilent - tihi rezim, nema pitanja i poruka
 */

function CheckFisCTTStarted(bSilent)
*{

if bSilent == nil
	bSilent:=.f.
endif

bFisStarted:=.t.

bFisStarted:=IsFisCTTStarted()
if !bFisStarted
	StartFisCTTInterface(bSilent)
else
	if !bSilent
		MsgBeep("FisCTT vec pokrenut !")
	endif
endif

return
*}



/*! \fn IsFisCTTStarted()
 *  \brief Provjerava da li je FisCTT startovan
 */
function IsFisCTTStarted()
*{

MsgO("Provjeravam FisCTT...")

cPath:=gFisCTTPath
bRet:=.t.
// testiraj interfejs
// upisi u out "999"
WrMainOutCode(cPath)
WrMainInCode("0_1", cPath)
Sleep(gFisTimeOut + 2)

cReadCode:=RdMainOutCode(cPath)

if cReadCode != "0"
	bRet:=.f.
endif

MsgC()

return bRet
*}


/*! \fn IsFisError()
 *  \brief Provjerava da li postoji greska poslije zadavanja komande i obradjuje je 
 */
function IsFisError()
*{
local bRead:=.f.
local cLastErr:=""

bRet:=.f.

do while !bRead
	Sleep(gFisTimeOut)
	cLastErr:=RdMainOutCode(gFisCTTPath)
	if gnDebug==5
		MsgBeep("Zadnja greska: " + cLastErr)
	endif
	
	if cLastErr<>"999"
		bRead:=.t.
	endif
enddo

if (cLastErr <> "0")
        if gnDebug == 5
        	MsgBeep("Obradi gresku: " + cLastErr)	
	endif
	// ako postoji greska, obradi gresku
	cErrDescr:=GetErrFromCode(cLastErr)
	MsgBeep(cErrDescr)
	
	if cLastErr == "2"
		bRet:=.t.
		// put some code here
		// CorrectErr2()
	elseif cLastErr == "3"
		bRet:=.t.
		// put some code here
		// CorrectErr3()
	else
		// zavrsi funkciju
		bErr:=.t.
		return bErr
	endif
endif

return bRet
*}



/*! \fn RunFisCommand(cCode)
 *  \brief Zadaje komandu interfejsu
 *  \param cCode - "kod" komande
 */

function RunFisCommand(cCode)
*{

cCode:=ALLTRIM(cCode)

// upisuju se kodovi od "0" do "9"

if (LEN(cCode) > 2)
	MsgBeep("Greska: neispravna duzina kod-a!")
	return
endif

// setuj uvijek OUT na "999"
WrMainOutCode(gFisCTTPath)

// upisi u IN kod cCode 
WrMainInCode(cCode, gFisCTTPath)

if gnDebug==5
	MsgBeep("Upisana komanda: " + cCode)
endif

return
*}



/*! \fn FisRacun(aArtikli, aArtRacun, nIznos, cTipPlacanja)
 *  \brief Glavna funkcija za stampu FISSTA racuna
 *  \param aArtikli - matrica sa artiklima
 *  \param aArtRacun - matrica sa stavkama racuna
 *  \param nIznos - ukupan iznos racuna
 *  \param cTipPlacanja - tip placanja (1, 2 ili 3)
 */

function FisRacun(aArtikli, aArtRacun, nIznos, cTipPlacanja)
*{

MsgO("Izdavanje racuna na FISSTA u toku...")

bFisRnOk:=.t.

// provjeri prvo da li je interfejs startan
//CheckFisCTTStarted(.t.)

// upisi stavke u ARTIKLI.XML
WrArtikliXml(aArtikli, gFisCTTPath)
// upisi stavke u ARTRACUN.XML
WrArtRacunXml(aArtRacun, gFisCTTPath)
// upisi stavke u PLACANJA.XML
WrPlacanjaXml(nIznos, cTipPlacanja, gFisCTTPath)

// sada smo spremni za izdavanje racuna

// pokreni komandu 1: artikli.xml => PC
RunFisCommand("1")

if gnDebug == 5
	MsgBeep("proslijedio komandu 1")
endif

// provjeri da li postoji greska i prekini izdavanje racuna
if IsFisError()
	bFisRnOk:=.f.
	MsgC()
	return bFisRnOk
endif

// pokreni komandu 8: artikli.xml PC => FISSTA
RunFisCommand("8")

if gnDebug == 5
	MsgBeep("proslijedio komandu 8")
endif

if IsFisError()
	bFisRnOk:=.f.
	MsgC()
	return bFisRnOk
endif

// pokreni komandu 2: izdaj racun
RunFisCommand("2")

if gnDebug == 5
	MsgBeep("proslijedio komandu 2")
endif

if IsFisError()
	bFisRnOk:=.f.
	MsgC()
	return bFisRnOk
endif

MsgC()

return bFisRnOk
*}



/*! \fn FisNivelacija(aArtikli)
 *  \brief Glavna funkcija za nivelaciju cijena
 *  \param aArtikli - matrica sa artiklima
 */

function FisNivelacija(aArtikli)
*{

MsgO("Vrsim nivelaciju cijena u FISSTA ...")

bErr:=.f.

// provjeri prvo da li je interfejs startan
CheckFisCTTStarted()

// upisi stavke u ARTIKLI.XML
WrArtikliXml(aArtikli, gFisCTTPath)

// sada smo spremni za nivelaciju

// pokreni komandu 1: artikli.xml => PC
RunFisCommand("1")

if IsFisError()
	bErr:=.t.
	MsgC()
	return bErr
endif

// pokreni komandu 8: artikli.xml PC => FISSTA
RunFisCommand("8")

if IsFisError()
	bErr:=.t.
	MsgC()
	return bErr
endif

MsgC()

return bErr
*}



/*! \fn FisRptDnevni()
 *  \brief Fiskalni dnevni izvjestaj
 */

function FisRptDnevni()
*{

MsgO("Formiranje dnevnog izvjestaja u toku...")

bRptOk:=.t.

// sasa, ovo iskljucujemo
// provjeri prvo da li je interfejs startan
//CheckFisCTTStarted(.t.)

// pokreni komandu 3: dnevni izvjestaj 
RunFisCommand("3")

if IsFisError()
	bRptOk:=.f.
endif

MsgC()

return bRptOk
*}



/*! \fn FisRptPeriod()
 *  \brief Fiskalni izvjestaj za period - presjek stanja
 */

function FisRptPeriod()
*{

MsgO("Formiranje izvjestaja za period u toku ...")

bRptOk:=.t.

// sasa, ovo iskljucujemo
// provjeri prvo da li je interfejs startan
//CheckFisCTTStarted(.t.)

// pokreni komandu 4: izvjestaj za period 
RunFisCommand("4")

if IsFisError()
	bRptOk:=.f.
endif

MsgC()

return bRptOk
*}



/*! \fn FormRptDnevni()
 *  \brief Formiranje dnevnog izvjestaja 
 */
 
function FormRptDnevni()
*{

// provjeri prvo da li uopste postoji promet na dan DATE()
if !PostojiDokument("42", DATE())
	MsgBeep("Za dan " + DToC(DATE()) + " nema racuna#Izvjestaj nije moguc.")
	return
endif

// provjeri da li je izvjestaj vec radjen
if gFisRptEvid=="D" .and. ReadLastFisRpt("1", DATE())
	MsgBeep("Dnevni izvjestaj vec formiran!#Prekidam operaciju.")
	return
endif

// postavi konacni upit
if Pitanje(,"Formirati dnevni izvjestaj (D/N)?", "D") == "N"
	return
endif

// stampaj izvjestaj
if !FisRptDnevni()
	MsgBeep("Greska pri formiranju dnevnog izvjestaja")
	return
endif

// evidentiraj izvjestaj
if gFisRptEvid=="D"
	WriteLastFisRpt("1", DATE(), TIME())
endif

return
*}


/*! \fn FormRptPeriod()
 *  \brief Formiranje izvjestaja za period 
 */
 
function FormRptPeriod()
*{

// provjeri prvo da li uopste postoji promet na dan DATE()
if !PostojiDokument("42", DATE())
	MsgBeep("Za dan " + DToC(DATE()) + " nema racuna#Izvjestaj nije moguc.")
	return
endif

// provjeri da li je izvjestaj vec formiran
if gFisRptEvid=="D" .and. ReadLastFisRpt("2", DATE())
	MsgBeep("Izvjestaj za period vec formiran!#Prekidam operaciju.")
	return
endif

// postavi konacan upit
if Pitanje(,"Formirati izvjestaj za period (D/N)?", "D") == "N"
	return
endif

// stampaj izvjestaj
if !FisRptPeriod()
	MsgBeep("Greska pri formiranju izvjestaja za period")
	return
endif

// evidentiraj izvjestaj
WriteLastFisRpt("2", DATE(), TIME())

return
*}


/*! \fn WriteLastFisRpt(cRptId, dDate, cTime)
 *  \brief Evidentira formiranje fisk.izvjestaja
 *  \param cRptId - id izvjestaja 
 *  \param dDate - datum formiranja
 *  \param cTime - vrijeme formiranja
 */
 
function WriteLastFisRpt(cRptId, dDate, cTime)
*{
// prvo zapamti zadnje podrucje
local nArr
nArr:=SELECT()

O_DOKS
select doks

bRptExists:=ReadLastFisRpt(cRptId, dDate)

if !bRptExists
	MsgO("Evidentiram dnevni izvjestaj")
	append blank
	
	cTipDok:="77"
	
	if cRptId=="2"
		cTipDok:="78"	
	endif
	
	replace field->idvd with cTipDok 
	replace field->datum with dDate
	replace field->vrijeme with cTime
	replace field->sto with cRptId
	MsgC()
endif

// vrati se na prethodno podrucje
select (nArr)

return
*}


/*! \fn ReadLastFisRpt(cRptId, dDate)
 *  \brief Procitaj 
 *  \param cRptId - id izvjestaja
 *  \param dDate - datum koji pretrazujemo
 */
function ReadLastFisRpt(cRptId, dDate)
*{
local nArr
nArr:=SELECT()

// ako se radi o cRptId=1
cTipDok:="77"
// ako se radi o cRptId=2
if cRptId=="2"
	cTipDok:="78"
endif

O_DOKS
select doks
set order to tag "2" // idvd + DTOS(datum) + smjena
seek cTipDok + DToS(dDate)

bRet:=.f.

if Found()
	//if ALLTRIM(field->sto) == cRptId
	bRet:=.t.
	//endif
endif

set order to tag "1"

select (nArr)

return bRet
*}


/*! \fn GetFormNiNr()
 *  \brief Postavlja upit za broj obrasca NI te vraca taj broj
 *  \return nNiNr - broj obrasca NI
 */
function GetFormNiNr()
*{
local GetList:={}
local cNiNr:=SPACE(8)

Box(,1,40)
	@ m_x+1, m_y+2 SAY "Unesite broj obrasca NI: " GET cNiNr VALID !Empty(cNiNr)
	read
BoxC()

return cNiNr
*}



