#include "\dev\fmk\pos\pos.ch"



/*! \FILE \dev\fmk\pos\evidpl\1g\evidpl.prg
 *  \brief Manipulacija nad podacima vrsta placanja
 */




/*! \fn AzurCek(aCKData, nIznDok, cBrDok, cTimeDok)
 *  \brief Azuriranje dokumenta CEK
 *  \param aCKData - matrica sa podacima o ceku
 *  \param nIznDok - iznos dokumenta
 *  \param cBrDok - broj dokumenta
 *  \param cTimeDok - vrijeme dokumenta
 */
function AzurCek(aCKData, nIznDok, cBrDok, cTimeDok)
*{
local cKupac

// ako je prazna matrica aCKData nema se sta raditi - izadji
if LEN(aCKData)==0
	return
endif

// uzmi ime i prezime kupca
cKupac:=PADR(aCKData[1], 20)
// uzmi datum izdavanja LK
dKpLKDate:=aCKData[6]

// napuni matricu aKupData sa podacima kupca
// aCKData: od [2] do [6]
aKupData:={}
for i:=2 to 5
	AADD(aKupData, aCkData[i])
next

// napuni matricu aCek sa podacima cekova
aCek:={}
for i:=7 to LEN(aCKData) STEP 3
	AADD(aCek, {aCKData[i], aCKData[i+1], aCKData[i+2]})
next

// kreiraj hash string sa podacima kupca
cKpData:=CreateHashString(aKupData)
// napuni matricu aKpData sa cKpData, odrezi na 20 po clanu matrice 
aKpData:={}
aKpData:=StrToArray(cKpData, 20)


// Azuriraj stavku u DOKS
AzurDoksDokument(VD_CK, gIdPos, cBrDok, cTimeDok, DATE())


// Azuriraj stavke u POS
nRbr:=1 // brojac stavki
// identifikator 1: datum dokumenta, kupac naziv, iznos racuna
AzurPosDokument(VD_CK, nRbr, 1, cBrDok, gIdPos, cKupac, nIznDok, 0, 0, DATE())

// identifikator 2: podaci cekova: broj, iznos, datum
for i:=1 to LEN(aCek)
	nRbr++
	AzurPosDokument(VD_CK, nRbr, 2, cBrDok, gIdPos, aCek[i, 1], 0, aCek[i, 2], 0, aCek[i, 3])
next

// identifikator 3: podaci o kupcu
for i:=1 to LEN(aKpData)
	nRbr++
	dDate:=CToD("")
	// za prvu stavku azuriraj datum izdavanja LK
	if (i==1)
		dDate:=dKpLKDate
	endif
	AzurPosDokument(VD_CK, nRbr, 3, cBrDok, gIdPos, aKpData[i], 0, 0, 0, dDate)
next


return
*}


/*! \fn AzurSindKredit(aSKData, nIznDok, cBrDok, cTimeDok)
 *  \brief Azuriranje dokumenta Sindikalni kredit
 *  \param aSKData - matrica sa podacima o sind.kreditu
 *  \param nIznDok - iznos dokumenta
 *  \param cBrDok - broj dokumenta
 *  \param cTimeDok - vrijeme dokumenta
 */
function AzurSindKredit(aSKData, nIznDok, cBrDok, cTimeDok)
*{
local cKupac

// ako je prazna matrica aCKData nema se sta raditi - izadji
if LEN(aSKData)==0
	return
endif

// uzmi ime i prezime kupca
cKupac:=PADR(aSKData[1], 20)

// napuni matricu aKupData sa podacima kupca
// aSKData: od [2] do [4]
aKupData:={}
for i:=2 to 5
	AADD(aKupData, aSKData[i])
next

nSKIznos:=aSKData[6] // odobreni iznos kredita
nSKBrRata:=aSKData[7] // broj rata kredita

// kreiraj hash string sa podacima kupca
cKpData:=CreateHashString(aKupData)
// napuni matricu aKpData sa cKpData, odrezi na 20 po clanu matrice 
aKpData:={}
aKpData:=StrToArray(cKpData, 20)


// Azuriraj stavku u DOKS
AzurDoksDokument(VD_SK, gIdPos, cBrDok, cTimeDok, DATE())

// Azuriraj stavke u POS
nRbr:=1 // brojac stavki
// identifikator 1: datum dokumenta, kupac naziv, iznos racuna, odobreni iznos kredita, broj rata kredita
AzurPosDokument(VD_SK, nRbr, 1, cBrDok, gIdPos, cKupac, nIznDok, nSKIznos, nSKBrRata, DATE())

// identifikator 2: podaci o kupcu
for i:=1 to LEN(aKpData)
	nRbr++
	AzurPosDokument(VD_SK, nRbr, 3, cBrDok, gIdPos, aKpData[i], 0, 0, 0, DATE())
next


return
*}




/*! \fn AzurGarPismo(aGPData, nIznDok, cBrDok, cTimeDok)
 *  \brief Azuriranje dokumenta garantno pismo
 *  \param aGPData - matrica sa podacima o garantnom pismu
                  aGPData[1]=ime i prezime kupca
		  aGPData[2]=broj g.pisma
		  aGPData[3]=datum izdavanja g.pisma
 *  \param nIznDok - iznos dokumenta
 *  \param cBrDok - broj dokumenta
 *  \param cTimeDok - vrijeme dokumenta
 */
function AzurGarPismo(aGPData, nIznDok, cBrDok, cTimeDok)
*{
// ako nema podataka u matrici nema se sta raditi - izadji
if LEN(aGPData)==0
	return
endif

cKupac:=PADR(aGPData[1], 20)

// Azuriraj DOKS
AzurDoksDokument(VD_GP, gIdPos, cBrDok, cTimeDok, DATE())

// Azuriranje u POS
// identifikator 1: kupac, datum dokumenta
AzurPosDokument(VD_GP, 1, 1, cBrDok, gIdPos, cKupac, nIznDok, 0, 0, DATE())
// identifikator 2: broj g.pisma i datum g.pisma 
AzurPosDokument(VD_GP, 2, 2, cBrDok, gIdPos, aGPData[2], 0, 0, 0, aGPData[3])

return
*}


/*! \fn AzurPosDokument(cIdVd, nRbrSt, nIdent, cBrDok, cIdPos, cBody, nIznos1, nIznos2, nKolicina, dDatum)
 *  \brief Azuriranje stavke u POS sa zadatim parametrima
 *  \param cIdVd - vrsta dokumenta, upisuje se u polje IDVD
 *  \param nRbRSt - redni broj stavke (1, 2, 3...), upisuje se u polje IDDIO
 *  \param nIdent - identifikator vrijednosti, upisuje se u polje IDODJ
 *  \param cBrDok - broj dokumenta, upisuje se u polje BRDOK
 *  \param cBody - string koji se upisuje u POS->"idradnik+idroba+idtarifa"
 *  \param nIznos1 - iznos koji se upisuje u polje CIJENA
 *  \param nIznos2 - iznos koji se upisuje u polje NCIJENA
 *  \param nKolicina - kolicina koja se upisuje u polje KOLICINA
 *  \param dDatum - datum koji se upisuje u polje DATUM
 */
function AzurPosDokument(cIdVd, nRBRSt, nIdent, cBrDok, cIdPos, cBody, nIznos1, nIznos2, nKolicina, dDatum)
*{
altd()


O_POS
select pos
append blank
Sql_Append()

SmReplace("idvd", cIdVd)
SmReplace("iddio", STR(nRBRSt, 2))
SmReplace("idodj", STR(nIdent, 2))
SmReplace("brdok", cBrDok)
SmReplace("idpos", cIdPos)
SmReplace("idradnik", SUBSTR(cBody, 1, 4))
SmReplace("idroba", SUBSTR(cBody, 5, 10))
SmReplace("idtarifa", SUBSTR(cBody, 15, 6))
SmReplace("datum", dDatum)
SmReplace("kolicina", nKolicina)
SmReplace("cijena", nIznos1)
SmReplace("ncijena", nIznos2)

return
*}



/*! \fn AzurDoksDokument(cIdVd, cIdPos, cBrDok, cTimeDok, dDateDok)
 *  \brief Azuriranje stavke u tabelu DOKS, prema zadatim argumentima
 *  \param cIdVd - id vrsta dokumenta, upisuje se u polje IDVD
 *  \param cIdPos - id pos, upisuje se u polje IDPOS
 *  \param cBrDok - broj dokumenta, upisuje se u polje BRDOK
 *  \param cTimeDok - vrijeme dokumenta, upisuje se u polje VRIJEME
 *  \param dDateDok - datum dokumenta, upisuje se u polje DATUM
 */
function AzurDoksDokument(cIdVd, cIdPos, cBrDok, cTimeDok, dDateDok)
*{

O_DOKS
select doks
append blank
Sql_Append()
SmReplace("idvd", cIdVd)
SmReplace("idpos", cIdPos)
SmReplace("brdok", cBrDok)
if (cTimeDok <> nil)
	SmReplace("vrijeme", cTimeDok)
endif
SmReplace("datum", dDateDok)

return
*}


/*! \fn StDokCK()
 *  \brief Stampa dokumenta CEK - "90"
 */
function StDokCK()
*{
local nArr
nArr:=SELECT()

// Selektuj stavke dokumenta
select pos
// idpos+idvd+brdok+DTOS(_DATAZ_)+iddio+idodj
set order to tag "7"
hseek doks->(IdPos+IdVd+BrDok+DTOS(_DATAZ_))

cBrDok:=pos->brdok
cIdPos:=pos->idpos

cKupac:=""
aCek:={}
aKpData:={}
cKpData:=""
cBody:=""
dDokDate:=DATE()
nDokIznos:=0
dKpLKDate:=CToD("")

// Uzmi podatke

do while !EOF() .and. pos->brdok==cBrDok .and. pos->idpos==cIdPos
	if (pos->brdok<>cBrDok)
		skip
		loop
	endif
	
	cBody:=(pos->idradnik + pos->idroba + pos->idtarifa)
	// identifikator 1: iznos veznog racuna, 
	//                  ime kupca, datum veznog dokumenta 
	if ALLTRIM(pos->idodj)=="1"
		cKupac:=cBody
		dDokDate:=pos->datum
		nDokIznos:=pos->cijena
	endif
	
	// identifikator 2, podaci o ceku
	if ALLTRIM(pos->idodj)=="2"
		AADD(aCek, {ALLTRIM(cBody), pos->ncijena, pos->datum})
	endif
	
	// identifikator 3, podaci o kupcu
	if ALLTRIM(pos->idodj)=="3"
		if !Empty(pos->datum)
			dKpLKDate:=pos->datum
		endif
		cKpData+=cBody
	endif

	skip
enddo

// dodaj matricu o podacima kupca
if Empty(cKpData)
	cKpData:="No data#No data#No data#No data"
endif

aKpData:=ReadHashString(ALLTRIM(cKpData))

START PRINT CRET

? REPLICATE("-", 45)
? "Stampa dokumenta CEK na dan,", DATE()
? REPLICATE("-", 45)
?
? "Dokument broj: ", VD_CK + "-" + ALLTRIM(cBrDok), dDokDate
? "  Vezni racun: ", VD_RN + "-" + ALLTRIM(cBrDok), dDokDate
? " Iznos racuna: ", nDokIznos
?
? "Podaci o ceku: "
? "----------------------------------------------"
? "Rbr. * Broj ceka      *  Datum  *   Iznos    *" 
? "----------------------------------------------"

for i:=1 to LEN(aCek)
	? SPACE(2)
	?? STR(i,1) + "."
	?? SPACE(2)
	?? PADR(aCek[i, 1], 15)
	?? SPACE(2)
	?? DToC(aCek[i, 3])
	?? SPACE(2)
	?? aCek[i, 2]
next
?
? "Podaci o kupcu:"
? "-------------------------------------------"
? "      Ime i prezime: " + TRIM(cKupac)
? "   Broj licne karte: " + aKpData[1]
? "                SUP: " + aKpData[2]
? " Datum izdavanja lk: " + DToC(dKpLKDate)
? "        Naziv banke: " + aKpData[3]
? "      Ziro rn.banke: " + aKpData[4]
?

FF
END PRINT

SELECT (nArr)

return
*}


/*! \fn StDokGP()
 *  \brief Stampa dokumenta GARANTNO PISMO
 */
function StDokGP()
*{
local nArr
nArr:=SELECT()

// Selektuj stavke dokumenta
select pos
// idpos+idvd+brdok+DTOS(_DATAZ_)+iddio+idodj
set order to tag "7"
hseek doks->(IdPos+IdVd+BrDok+DTOS(_DATAZ_))

cBrDok:=pos->brdok
cIdPos:=pos->idpos

cKupac:=""
dDokDate:=DATE()
nDokIznos:=0
cGPBroj:=""
dGPDate:=DATE()

// Uzmi podatke
do while !EOF() .and. pos->brdok==cBrDok .and. pos->idpos==cIdPos
	if (pos->brdok<>cBrDok)
		skip
		loop
	endif
	cBody:=(pos->idradnik + pos->idroba + pos->idtarifa)
	// identifikator 1: iznos veznog racuna, 
	//                  ime kupca, datum veznog dokumenta 
	if ALLTRIM(pos->idodj)=="1"
		cKupac:=cBody
		dDokDate:=pos->datum
		nDokIznos:=pos->cijena
	endif
	
	// identifikator 2, podaci o garantnom pismu
	if ALLTRIM(pos->idodj)=="2"
		cGPBroj:=ALLTRIM(cBody)
		dGPDate:=pos->datum
	endif

	skip
enddo

START PRINT CRET

? REPLICATE("-", 45)
? "Stampa dokumenta GARANTNO PISMO na dan,", DATE()
? REPLICATE("-", 45)
?
? "Dokument broj: ", VD_GP + "-" + ALLTRIM(cBrDok), dDokDate
? "  Vezni racun: ", VD_RN + "-" + ALLTRIM(cBrDok), dDokDate
? " Iznos racuna: ", nDokIznos
?
? "Podaci o garantom pismu "
? "----------------------------"
? "           Broj: " + ALLTRIM(cGPBroj)  
? "Datum izdavanja: ", dGPDate
?
? "Podaci o kupcu:"
? "----------------------------"
? "  Ime i prezime: " + TRIM(cKupac)
?

FF
END PRINT

SELECT (nArr)

return
*}


/*! \fn StDokSK()
 *  \brief Stampa dokumenta SINDIKALNI KREDIT
 */
function StDokSK()
*{
local nArr
nArr:=SELECT()

// Selektuj stavke dokumenta
select pos
// idpos+idvd+brdok+DTOS(_dataz_)+iddio+idodj
set order to tag "7"
hseek doks->(IdPos+IdVd+BrDok+DTOS(_DATAZ_))

cBrDok:=pos->brdok
cIdPos:=pos->idpos

cKupac:=""
aKpData:={}
cKpData:=""
cBody:=""
dDokDate:=DATE()
nDokIznos:=0
nSKIznos:=0
nSKRate:=0

// Uzmi podatke
do while !EOF() .and. pos->brdok==cBrDok .and. pos->idpos==cIdPos
	if (pos->brdok<>cBrDok)
		skip
		loop
	endif
	
	cBody:=(pos->idradnik + pos->idroba + pos->idtarifa)
	// identifikator 1: iznos veznog racuna, 
	//                  ime kupca, datum veznog dokumenta, 
	//                  odobreni iznos kredita, broj rata 
	if ALLTRIM(pos->idodj)=="1"
		cKupac:=cBody
		dDokDate:=pos->datum
		nDokIznos:=pos->cijena
		nSKIznos:=pos->ncijena
		nSKRate:=INT(pos->kolicina)
	endif
	
	// identifikator 3, podaci o kupcu
	if ALLTRIM(pos->idodj)=="3"
		cKpData+=cBody
	endif

	skip
enddo

// dodaj matricu o podacima kupca
aKpData:=ReadHashString(ALLTRIM(cKpData))

START PRINT CRET

? REPLICATE("-", 50)
? "Stampa dokumenta SINDIKALNI KREDIT na dan,", DATE()
? REPLICATE("-", 50)
?
? "Dokument broj: ", VD_SK + "-" + ALLTRIM(cBrDok), dDokDate
? "  Vezni racun: ", VD_RN + "-" + ALLTRIM(cBrDok), dDokDate
? " Iznos racuna: ", STR(nDokIznos, 8, 2)
?
? "Podaci o kreditu: "
? "--------------------------------------------"
? "     Odobreni iznos: ", STR(nSKIznos, 8, 2)
? "          Broj rata: ", STR(nSKRate, 2) 
?
? "Podaci o kupcu:"
? "--------------------------------------------"
? "      Ime i prezime: " + TRIM(cKupac)
? "   Broj licne karte: " + aKpData[1]
? "               JMBG: " + aKpData[2]
? "              Firma: " + aKpData[3]
? "    ID broj (firma): " + aKpData[4]
?

FF
END PRINT

SELECT (nArr)


return
*}



