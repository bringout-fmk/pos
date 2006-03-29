#include "\dev\fmk\pos\pos.ch"


// sljedeci broj zakljucenja na nivou baze
function g_next_zak_br()
*{
local nArr
nArr:=SELECT()

nRet:=0

select doks
set order to tag "ZAK"
go bottom
hseek gIdPos + "42" + "XXX"
skip -1

nRet := (field->zak_br) + 1

select (nArr)

return nRet
*}

// zakljuci sto broj
function zak_sto(nStoBr)
*{
local nArr
local nNext_zak
local cNijeZaklj := "     0"
local nCnt := 0
local nTRec
local nNRec

nArr := SELECT()

// vrati sljedeci broj zakljucenja
nNext_zak := g_next_zak_br()

// postavi filter za nStoBr
select doks
set order to tag "STO"
hseek gIdPos + "42" + STR(nStoBr) + cNijeZaklj

do while !EOF() .and. doks->idpos == gIdPos .and. doks->idvd == "42" .and. doks->sto_br == nStoBr .and. doks->zak_br == 0
	++ nCnt
	nTRec := RecNo()
	skip
	nNRec := RecNo()
	
	go (nTRec)
	
	replace zak_br with nNext_zak
	
	go (nNRec)
enddo

if nCnt > 0
	show_zak_info(nNext_zak)
endif

if Pitanje(,"Stampati zbirni racun (D/N)?","N") == "D"
	print_zak_br(nNext_zak)
endif

select (nArr)

return nCnt
*}


function show_zak_info(nZakBr)
*{
local nArr
nArr := SELECT()

O_POS
select doks
set order to tag "ZAK"
hseek gIdPos + "42" + STR(nZakBr, 6)

altd()


cDokumenti := ""
nTotal := 0
nCnt := 0
nStoBr := 0
cBrDok:=""
aPom := {}

do while !EOF() .and. doks->idpos == gIdPos .and. doks->idvd == "42" .and. doks->zak_br == nZakBr
	nStoBr := doks->sto_br
	++ nCnt
	nTotal += VAL(DokIznos(.f.))
	cBrDok := ALLTRIM(doks->brdok)
	cDokumenti += cBrDok + ","
	skip
enddo

skip -1

aPom := SjeciStr(cDokumenti, 30)

cText := "Zbirni racun " + cBrDok + "-" + ALLTRIM(STR(nZakBr)) + "#"
cText += "Ukupan iznos po racunima "
for i:=1 to LEN(aPom)
	cText += ALLTRIM(aPom[i]) + "#"
next
cText += " je " + ALLTRIM(STR(nTotal)) + " KM"

MsgBeep(cText)

select (nArr)
return
*}


// printanje zbirnog racuna na osnovu broja zakljucenja
function print_zak_br(nZakBr)
*{
local nArr
nArr:=SELECT()

select doks
set order to tag "ZAK"
hseek gIdPos + "42" + STR(nZakBr,6)

aRacuni:={}

do while !EOF() .and. doks->idvd == "42" .and. doks->zak_br == nZakBr
	AADD(aRacuni, {doks->idpos, doks->brdok, doks->idvrstep, doks->datum})
	skip
enddo

skip -1

PDVStampaRac(gIdPos, doks->brdok, .t., doks->idvrstep, doks->datum, aRacuni, .f.)

return
*}


function g_otv_stolovi()
*{
local nArr
nArr:=SELECT()

O_POS
O_DOKS
select doks
set order to tag "ZAK"
go top
hseek gIdPos + "42"

nTotal := 0
nStoBr := 0
aStolovi := {}
do while !EOF() .and. doks->zak_br == 0
	nStoBr := doks->sto_br
	do while !EOF() .and. doks->zak_br == 0 .and. doks->sto_br == nStoBr
		nTotal += VAL(DokIznos(.f.))
		skip
	enddo
	AADD(aStolovi, {nStoBr, nTotal})
	nTotal := 0
enddo

select (nArr)
return aStolovi
*}


function g_zak_sto()
*{
local cStoBr:=SPACE(3)
local aStolovi := {}
local nZakBr

// daj listu otvorenih stolova
aStolovi := g_otv_stolovi()
if !pr_otv_stolovi(aStolovi)
	return
endif

// postavi upit za broj stola
Box(,3,30)
	set cursor on
	@ m_x+2, m_y+6 SAY "Unesi broj stola:" GET cStoBr VALID (!EMPTY(cStoBr) .and. VAL(cStoBr) > 0) PICT "999"
	read
BoxC()

if LastKey()==K_ESC
	MsgBeep("Prekinuta operacija zakljucenja stola !")
	return
endif

// provjeri da nije ukucan broj stola koji nema racuna
if ASCAN(aStolovi, {|aVal| aVal[1] == VAL(cStoBr)}) == 0
	MsgBeep("Za ovaj sto ne postoje otvoreni racuni !#Prekidam operaciju !")
	return
endif

zak_sto(VAL(cStoBr))

return
*}


function pr_otv_stolovi(aStol)
*{

if LEN(aStol) == 0
	MsgBeep("Nema nezakljucenih stolova !")
	return .f.
endif

START PRINT CRET

? "Lista otvorenih stolova:"
?
?
? "  Sto       Iznos"
? "----- -----------"

for i:=1 to LEN(aStol)
	? aStol[i, 1], aStol[i, 2]
next

?

FF
END PRINT

return .t.
*}


function zak_sve_stolove()
*{
local nNextZak := 0
local nArr
local cNijeZaklj := "     0"
local nNRec
nArr := SELECT()

if !SigmaSif("ZAKSVE")
	MsgBeep("Nemate pravo na koristenje ove opcije!")
	return
endif

O_DOKS
nNextZak := g_next_zak_br()

select doks
set order to tag "ZAK"
go top
seek gIdPos + "42" + cNijeZaklj

do while !EOF() .and. doks->idpos == gIdPos .and. doks->idvd == "42" .and. doks->zak_br == 0
	nStoBr := doks->sto_br
	do while !EOF() .and. doks->idpos == gIdPos .and. doks->idvd == "42" .and. doks->zak_br == 0 .and. doks->sto_br == nStoBr
		nTRec := RecNo()
		skip
		nNRec := RecNo()
		skip -1
		replace zak_br with nNextZak
		go (nNRec)
	enddo
	++ nNextZak 
enddo

MsgBeep("Izvrseno zakljucenje svih racuna !")

select (nArr)
return
*}


// info o prethodnom stanju stola nStoBr
function g_stanje_stola(nStoBr)
*{
local nArr
local cNijeZaklj := "     0"
nArr:=SELECT()
O_POS
O_DOKS
select doks
set order to tag "STO"
hseek gIdPos + "42" + STR(nStoBr) + cNijeZaklj

nStanje := 0

do while !EOF() .and. doks->idpos == gIdPos .and. doks->idvd == "42" .and. doks->sto_br == nStoBr
	if doks->zak_br == 0
		nStanje += VAL(DokIznos(.f.))
	endif
	skip
enddo

select (nArr)

return nStanje
*}

