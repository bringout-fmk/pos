#include "\dev\fmk\pos\pos.ch"


/*! \fn RekOpis()
 *  \brief Reklamacija dodatni podaci
 */
function RekOpis()
*{
if Pitanje(,"Unjeti opis reklamacije?", "D") == "N"
	return
endif

// uzmi podatke o reklamaciji
GetRekOpis()

return
*}


/*! \fn GetRekOpis()
 *  \brief Daj dodatne podatke o reklamaciji 
 */
function GetRekOpis()
*{
private GetList:={}

cRekOp1:=SPACE(20)
cRekOp2:=SPACE(4)
cRekOp3:=SPACE(40)
cRekOp4:="R"

Box(,5, 60)
	@ 1+m_x, 2+m_y SAY "REKLAMACIJA: DODATNI PODACI" COLOR "I"
	@ 2+m_x, 2+m_y SAY "Ime kupca  " GET cRekOp1 VALID !Empty(cRekOp1)
	@ 3+m_x, 2+m_y SAY "Broj cipele" GET cRekOp2 VALID !Empty(cRekOp2)
	@ 4+m_x, 2+m_y SAY "Opis greske" GET cRekOp3
	@ 5+m_x, 2+m_y SAY "Rekl. u (P)ripremi/(R)ealizovana" GET cRekOp4 VALID cRekOp4 $ "RP" PICT "@!"
	read
BoxC()

return
*}


/*! \fn AzurRekOpis(cBrDok, cIdVd)
 *  \brief Azuriranje opisa reklamacije
 *  \param cBrDok - broj dokumenta
 *  \param cIdVd - id vrsta dokumenta
 */
function AzurRekOpis(cBrDok, cIdVd)
*{
// pri uslov za ispitivanje
if !IsPlanika() .and. cIdVd<>VD_REK
	return
endif
// drugi uslov za ispitivanje
if (cRekOp1 == nil .or. cRekOp2 == nil .or. cRekOp3 == nil)
	return
endif

// azuriraj dodatne podatke o reklamaciji
// DOKS
AzurDoksDokument(VD_ROP, gIdPos, cBrDok, , DATE())

// POS
// 1. ime i prezime (idradnik+idtarifa+idroba) + broj cipele (iznos)
AzurPosDokument(VD_ROP, 1, 1, cBrDok, gIdPos, ALLTRIM(cRekOp1), VAL(ALLTRIM(cRekOp2)), 0, 0, DATE())
// 2. opis greske

cRekOp3 := ALLTRIM(cRekOp3)
AzurPosDokument(VD_ROP, 2, 2, cBrDok, gIdPos, SUBSTR(cRekOp3, 1, 20), 0, 0, 0, Date())
if (LEN(cRekOp3)>20)
	AzurPosDokument(VD_ROP, 3, 2, cBrDok, gIdPos, SUBSTR(cRekOp3, 21, 20), 0, 0, 0, Date())
endif

return
*}


/*! \fn StDokROP(lPregled)
 *  \brief Stampa dokumenta "99" Reklamacija Ostali Podaci
 *  \param lPregled - .t. stampa iz pregleda (pojavljuje se header)
 */
function StDokROP(lPregled)
*{
local nArr
nArr:=SELECT()

if (lPregled==nil)
	lPregled:=.f.
endif

// Selektuj stavke dokumenta
select pos
// idpos+idvd+brdok+DTOS(_DATAZ_)+iddio+idodj
set order to tag "7"
hseek doks->(IdPos + VD_ROP + BrDok + DTOS(_DATAZ_) + " 1" + " 1")

cBrDok:=pos->brdok
cIdPos:=pos->idpos

// ako nisam nista nasao - izadji
if (doks->idvd <> pos->idvd .and. doks->brdok <> pos->brdok .and. doks->datum <> pos->datum)
	set order to tag "1"
	select (nArr)
	return
endif

cROPKupac:=""
cROPBrCip:=""
cROPOpis:=""
altd()
do while !EOF() .and. pos->brdok==cBrDok .and. pos->idpos==cIdPos .and. pos->idvd==VD_ROP .and. doks->datum==pos->datum
	do case
		case (ALLTRIM(pos->idodj)=="1")
			cROPKupac:=ALLTRIM(pos->idradnik + pos->idroba + pos->idtarifa)
			cROPBrCip:=ALLTRIM(STR(pos->cijena, 4, 0))
		case (ALLTRIM(pos->idodj)=="2")
			cROPOpis+=(pos->idradnik + pos->idroba + pos->idtarifa)
	endcase
	skip
enddo

set order to tag "1"
select (nArr)

if lPregled
	START PRINT CRET
endif

ROP_Header(cIdPos, cBrDok)
ROP_Row("Ime kupca  :", cROPKupac)
ROP_Row("Broj cipele:", cROPBrCip)
ROP_Row("Opis greske:", cROPOpis)

if lPregled
	FF
	END PRINT
endif

return
*}

/*! \fn ROP_Header(cIdPos, cBrDok)
 *  \brief Ispis headera izvjestaja
 *  \param cIdPos - id pos
 *  \param cBrDok - broj dokumenta
 */
static function ROP_Header(cIdPos, cBrDok)
*{
? "---------------------------"
? "REKLAMACIJA: dodatni podaci"
? "---------------------------"
? "Vezni dokument: " + ALLTRIM(VD_REK) + "-" + ALLTRIM(cBrDok)
?
return
*}


/*! \fn ROP_Row(cOpis, cVrijednost)
 *  \brief Ispis stavke izvjestaja
 *  \param cOpis - opis stavke
 *  \param cVrijednost - vrijednost stavke
 */
static function ROP_Row(cOpis, cVrijednost)
*{
? cOpis
?? SPACE(3)

aPom := SjeciStr(cVrijednost, 20)
for i:=1 to len(aPom)
	if i == 1
		?? aPom[i]
	else
		? SPACE(LEN(cOpis) + 3) + aPom[i]
	endif
next
   		
return
*}





