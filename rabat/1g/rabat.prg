#include "\cl\sigma\fmk\pos\pos.ch"


/*! \fn FrmGetRabat(aRabat, nCijena)
 *  \brief Puni matricu aRabat popustima, u zavisnosti od varijante
 *  \param aRabat - matrica rabata: type array
 	{idroba, nPopVar1, nPopVar2, nPopVar3, nPopVar4, nPopVar5, nPopVar6}
 *  \param nCijena - cijena artikla
 */
function FrmGetRabat(aRabat, nCijena)
*{
// prodji kroz svaku varijantu popusta i napuni matricu aRabat{}

// 1. varijanta
// Popust zadavanjem nove cijene
GetPopZadavanjemNoveCijene(aRabat, nCijena)

// 2. varijanta
// Generalni popust za sve artikle
GetPopGeneral(aRabat, nCijena)

// 3. varijanta
// Popust na osnovu polja "roba->N2"
GetPopFromN2(aRabat, nCijena)

// 4. varijanta
// Popust preko odredjenog iznosa
GetPopPrekoOdrIznosa(aRabat, nCijena)

// 5. varijanta
// Popust za clanove
GetPopClanovi(aRabat, nCijena)

// 6. varijanta
// Popust zadavanjem procenta
GetPopProc(aRabat, nCijena)

return
*}


/*! \fn GetPopZadavanjemNoveCijene(aRabat, nCijena)
 *  \brief Popust zadavanjem nove cijene
 *  \param aRabat
 *  \param nCijena
 */
function GetPopZadavanjemNoveCijene(aRabat, nCijena)
*{
local nNovaCijena:=0

if (gPopZCj=="D" .and. roba->tip<>"T")  
	// u zavisnosti od set-a cijena koji se koristi
	// &("roba->cijena" + gIdCijena) == roba->cijena1
	nNovaCijena:=round(&("roba->cijena" + gIdCijena) - nCijena, gPopDec)
	AddToArrRabat(aRabat, roba->id, nNovaCijena)
endif

return
*}

/*! \fn GetPopGeneral(aRabat, nCijena)
 *  \brief Generalni popust za sve artikle
 *  \param aRabat
 *  \param nCijena
 */
function GetPopGeneral(aRabat, nCijena)
*{
local nNovaCijena:=0

if (!EMPTY(gPopust) .and. gPopust<>99 .and. gPopust<>0)
	if Pitanje(,"Generalni popust " + ALLTRIM(STR(gPopust)) + "% :: uracunati ?" ,"D")=="D"
		nNovaCijena:=Round(nCijena*(gPopust)/100, gPopDec)
		AddToArrRabat(aRabat, roba->id, nil, nNovaCijena)
	endif
endif

return
*}


/*! \fn GetPopFromN2(aRabat, nCijena)
 *  \brief Popust na osnovu polja "roba->N2", gPopust=99 - gledaj sifrarnik
 *  \param aRabat
 *  \param nCijena
 */
function GetPopFromN2(aRabat, nCijena)
*{
local nNovaCijena:=0

if (!EMPTY(gPopust) .and. gPopust==99)
	if Pitanje(,"Uracunati popust od " + ALLTRIM(STR(roba->n2)) + "% ?" ,"D")=="D"
		nNovaCijena:=Round(nCijena*(roba->n2)/100, gPopDec)
		AddToArrRabat(aRabat, roba->id, nil, nil, nNovaCijena)
	endif
endif

return
*}


/*! \fn GetPopPrekoOdrIznosa(aRabat, nCijena)
 *  \brief Varijanta popusta preko odredjenog iznosa
 *  \param aRabat
 *  \param nCijena
 */
function GetPopPrekoOdrIznosa(aRabat, nCijena)
*{
local nNovaCijena:=0

if VarPopPrekoOdrIzn()
	nNovaCijena=Round(nCijena*gPopIznP/100, gPopDec)
	AddToArrRabat(aRabat, roba->id, nil, nil, nil, nNovaCijena)
endif

return
*}


/*! \fn GetPopClanovi(aRabat, nCijena)
 *  \brief Popust za clanove
 *  \param aRabat
 *  \param nCijena
 */
function GetPopClanovi(aRabat, nCijena)
*{
local nNovaCijena:=0

if (gUpitNP=="D" .and. gClanPopust)
	nNovaCijena=Round(nCijena*roba->n1/100, gPopDec)
	AddToArrRabat(aRabat, roba->id, nil, nil, nil, nil, nNovaCijena)
endif

return
*}

/*! \fn GetPopProcent(aRabat, nCijena)
 *  \brief Popust zadavanjem procenta
 *  \param aRabat
 *  \param nCijena
 */
function GetPopProcent(aRabat, nCijena)
*{
local nNovaCijena:=0

if gPopProc=="D"
	nPopProc:=FrmGetPopProc()
	nNovaCijena=Round(nCijena*nPopProc/100, gPopDec)
	AddToArrRabat(aRabat, roba->id, nil, nil, nil, nil, nil, nNovaCijena)
endif

return
*}


/*! \fn AddToArrRabat(aRabat, cIdRoba, nPopVar1, nPopVar2, nPopVar3, nPopVar4, nPopVar5, nPopVar6)
 *  \brief Puni matricu aRabat{} vrijednostima popusta nPopVarN
 *  \param aRabat - matrica
 *  \param cIdRoba - id artikla
 *  \param nPopVar1 - iznos popusta zadavanja nove cijene
 *  \param nPopVar2 - iznos generalnog popusta
 *  \param nPopVar3 - iznos popusta na osnovu polja N2
 *  \param nPopVar4 - iznos popusta preko odredjenog iznosa
 *  \param nPopVar5 - iznos popusta za clanove
 *  \param nPopVar6 - iznos popusta zadavanjem procenta
 */
function AddToArrRabat(aRabat, cIdRoba, nPopVar1, nPopVar2, nPopVar3, nPopVar4, nPopVar5, nPopVar6)
*{

// ako je neki od parametara nPopVar(N)==NIL setuj na 0
if nPopVar1==NIL
	nPopVar1:=0
endif
if nPopVar2==NIL
	nPopVar2:=0
endif
if nPopVar3==NIL
	nPopVar3:=0
endif
if nPopVar4==NIL
	nPopVar4:=0
endif
if nPopVar5==NIL
	nPopVar5:=0
endif
if nPopVar6==NIL
	nPopVar6:=0
endif

if (LEN(aRabat) > 0)
	// posto vec nesto ima u matrici prvo pretrazi...
	nPosition:=ASCAN(aRabat, {|aValue| aValue[1]==cIdRoba})
	if nPosition <> 0
		if aRabat[nPosition, 2] == 0
			aRabat[nPosition, 2] := nPopVar1
		endif
		if aRabat[nPosition, 3] == 0
			aRabat[nPosition, 3] := nPopVar2
		endif
		if aRabat[nPosition, 4] == 0
			aRabat[nPosition, 4] := nPopVar3
		endif
		if aRabat[nPosition, 5] == 0
			aRabat[nPosition, 5] := nPopVar4	
		endif
		if aRabat[nPosition, 6] == 0
			aRabat[nPosition, 6] := nPopVar5	
		endif
		if aRabat[nPosition, 7] == 0
			aRabat[nPosition, 7] := nPopVar6
		endif
	else
		AADD(aRabat, {cIdRoba, nPopVar1, nPopVar2, nPopVar3, nPopVar4, nPopVar5, nPopVar6})
	endif
else
	AADD(aRabat, {cIdRoba, nPopVar1, nPopVar2, nPopVar3, nPopVar4, nPopVar5, nPopVar6})
endif

return
*}


/*! \fn RptArrRabat(aRabat)
 *  \brief Stampa matricu aRabat, sluzi samo za testiranje!!!
 *  \param aRabat
 */
function RptArrRabat(aRabat)
*{
START PRINT CRET

? "Test :: matrica rabata"
? "-------------------------------------------------"
?

for i:=1 to LEN(aRabat)
	? aRabat[i, 1], aRabat[i, 2], aRabat[i, 3],;
	  aRabat[i, 4], aRabat[i, 5], aRabat[i, 6], aRabat[i, 7]	
next
?
?

END PRINT

return
*}


/*! \fn CalcArrRabat(aRabat, lPopVar1, lPopVar2, lPopVar3, lPopVar4, lPopVar5, lPopVar6)
 *  \brief Kalkulise kompletan iznos rabata za sve stavke
 *  \param aRabat - matrica rabata
 *  \param lPopVar1 - .t. racunaj 1 varijantu
 *  \param lPopVar2 - .t. racunaj 2 varijantu
 *  \param lPopVar3 - .t. racunaj 3 varijantu
 *  \param lPopVar4 - .t. racunaj 4 varijantu
 *  \param lPopVar5 - .t. racunaj 5 varijantu
 *  \param lPopVar6 - .t. racunaj 6 varijantu
 */
function CalcArrRabat(aRabat, lPopVar1, lPopVar2, lPopVar3, lPopVar4, lPopVar5, lPopVar6)
*{
local nIznos:=0


for i:=1 to LEN(aRabat)
	if lPopVar1
		nIznos += aRabat[i, 2]
	endif
	if lPopVar2
		nIznos += aRabat[i, 3]
	endif
	if lPopVar3
		nIznos += aRabat[i, 4]
	endif
	if lPopVar4
		nIznos += aRabat[i, 5]
	endif
	if lPopVar5
		nIznos += aRabat[i, 6]
	endif
	if lPopVar6
		nIznos += aRabat[i, 7]
	endif
next

return nIznos
*}


/*! \fn CalcRabatForArticle(aRabat, cIdRoba, lPopVar1, lPopVar2, lPopVar3, lPopVar4, lPopVar5, lPopVar6)
 *  \brief Kalkulise rabat za samo jedan artikal
 *  \param aRabat
 *  \param cIdRoba
 *  \param lPopVar1
 *  \param lPopVar2
 *  \param lPopVar3
 *  \param lPopVar4
 *  \param lPopVar5
 *  \param lPopVar6
 */
function CalcRabatForArticle(aRabat, cIdRoba, lPopVar1, lPopVar2, lPopVar3, lPopVar4, lPopVar5, lPopVar6)
*{
local nIznos:=0
local nPosition:=0

nPosition:=ASCAN(aRabat, {|Value| Value[1]==cIdRoba})

if nPosition <> 0
	if lPopVar1
		nIznos := aRabat[nPosition, 2]
	endif
	if lPopVar2
		nIznos += aRabat[nPosition, 3]
	endif
	if lPopVar3
		nIznos += aRabat[nPosition, 4]
	endif
	if lPopVar4
		nIznos += aRabat[nPosition, 5]
	endif
	if lPopVar5
		nIznos += aRabat[nPosition, 6]
	endif
	if lPopVar6
		nIznos += aRabat[nPosition, 7]
	endif
endif

return nIznos
*}


/*! \fn IsPopPrekoOdrIzn(nTotal)
 *  \brief Provjerava da li je tacnan uslov za popust preko odredjenog iznosa
 *  \param nTotal - ukupan iznos racuna
 */
function IsPopPrekoOdrIzn(nTotal)
*{
local lReslut:=.f.

// iznos moze biti 100 i -100, ako je storno
if ABS(nTotal) > gPopIzn
	lResult:=.t.
else
	lResult:=.f.
endif

return lResult
*}



/*! \fn VarPopPrekoOdrIzn()
 *  \brief Provjerava da li se uzima u obzir varijanta popusta preko odredjenog iznosa
 */
function VarPopPrekoOdrIzn()
*{
local lResult:=.f.

if (gPopIzn>0 .and. gPopIznP>0)
	lResult:=.t.
else
	lResult:=.f.
endif

return lResult
*}


/*! \fn FrmGetPopProc()
 *  \brief Prikaz forme za unos procenta popusta
 */
function FrmGetPopProc()
*{
local GetList:={}
local nPopProc:=0

Box(,1,23)
	@ m_x+1, m_y+2 SAY "Popust (%)" GET nPopProc PICT "999.99"
	read
BoxC()

return nPopProc
*}


/*! \fn ShowRabatOnForm(nx, ny)
 *  \brief Prikazuje iznos rabata na formi unosa
 *  \param nx
 *  \param ny
 */
function ShowRabatOnForm(nx, ny)
*{
local nCijena:=0
local nPopust:=0

nCijena := _cijena
nPopust := CalcRabatForArticle(aRabat, _idRoba, .t., .t., .t., .t., .t., .t.)
_ncijena := nPopust

if (nPopust <> 0)
	@ nx, ny SAY "Popust :"
  	@ nx, col()+1 SAY _nCijena pict "99999.999"
  	@ nx+1, ny SAY  "Cij-Pop:"
  	@ nx+1, col()+1 SAY _Cijena-_nCijena pict "99999.999"
else
  	@ nx, ny SAY space(20)
  	@ nx+1, ny SAY space(20)
endif

return
*}


/*! \fn RecalcRabat()
 *  \brief Rekalkulise vrijednost rabata prije azuriranja i stampanja racuna. Ovo je neophodno radi varijante popusta preko odredjenog iznosa.
 */
function RecalcRabat(cIdVrsteP)
*{
local nNIznos:=0
local nIznNar:=0
local nPopust:=0

if cIdVrsteP==NIL
	cIdVrsteP:=""
endif

// prvo vidi koliki je iznos racuna
select _pripr
go top
do while !EOF()
	nIznNar+=cijena*kolicina
	nPopust+=ncijena*kolicina
	skip
enddo

go top
do while !eof()
	if VarPopPrekoOdrIzn()
		altd()
		if !IsPopPrekoOdrIzn(nIznNar-nPopust) .or. (IsPopPrekoOdrIzn(nIznNar-nPopust) .and. cIdVrsteP<>"01")
			if LEN(aRabat)>0
				nNIznos:=CalcRabatForArticle(aRabat, idroba, .t., .t., .t., .f., .t., .t.)
			else
				nNIznos:=0
			endif
			Scatter()
  			_ncijena:=nNIznos
			Gather()
		endif
		skip
	else
		skip
		loop
	endif
enddo

return
*}


/*! \fn Scan_PriprForRabat(aRabat)
 *  \brief Ako ima nezakljucenih racuna u _PRIPR napuni matricu aRabat
 *  \param aRabat - matrica rabata
 */
function Scan_PriprForRabat(aRabat)
*{
select _pripr
if (RecCount() > 0)
	do while !EOF()
		FrmGetRabat(aRabat, field->cijena)
		skip
	enddo

endif

return
*}
