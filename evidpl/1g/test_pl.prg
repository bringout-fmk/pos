#include "\dev\fmk\pos\pos.ch"

// ______TO DO______
// ova 3 test case-a prebaciti u /sclib/ut/1g/test_str.prg
// ovo su testovi sa stringovima...
// u /APPSRV dodati switch /STRUT za test case sa stringovima



function Test_EvidPl()
*{

// TEST kreiranja hash stringa
TestCreHashStr()

Inkey(0)
CLEAR SCREEN

// TEST citanja hash stringa
TestRdHashStr()

Inkey(0)
CLEAR SCREEN

TestStr2Niz()

Inkey(0)
CLEAR SCREEN


return
*}

/*! \fn TestCreHashStrRW()
 *  \brief Test case kreiranja hash stringa
 */
function TestCreHashStr()
*{
? REPLICATE("-", 70)
? "TEST CASE: kreiranje hash string..."
? REPLICATE("-", 70)

aColl:={}
AADD(aColl, "JOVAN JOVANOVIC")
AADD(aColl, "IK BANKA")
AADD(aColl, "1032444233211")
AADD(aColl, "SUP BEOGRAD")

cRes:="JOVAN JOVANOVIC#IK BANKA#1032444233211#SUP BEOGRAD"


cHStr:=""
cHStr:=CreateHashString(aColl)

if (cHStr==cRes)
	? "Test case: [OK]"
else
	? "Test case: [FALSE]"
	? "Originalni hash string: " + cRes
	? "Generisani hash string: " + cHStr
endif

?
? "TEST CASE zavrsen ..."


return
*}


/*! \fn TestRdHashStr()
 *  \brief Test case citanja hash stringa
 */
function TestRdHashStr()
*{

? REPLICATE("-", 70)
? "TEST CASE: citanje hash string..."
? REPLICATE("-", 70)

aResColl:={}
aGenColl:={}
AADD(aResColl, "JOVAN JOVANOVIC")
AADD(aResColl, "IK BANKA")
AADD(aResColl, "1032444233211")
AADD(aResColl, "SUP BEOGRAD")

cHStr:="JOVAN JOVANOVIC#IK BANKA#1032444233211#SUP BEOGRAD"
aGenColl:=ReadHashString(cHStr)

?
? "Uporedjujem duzine matrica: "

if LEN(aResColl) == LEN(aGenColl)
	?? " [OK]"
else
	?? " [FALSE]"
	? "Originalna matrica: " + STR(LEN(aResColl))
	? "Generisana matrica: " + STR(LEN(aGenColl))
endif

?
? "Uporedjujem elemente matrica: "

nCnt:=0
altd()
for i:=1 to LEN(aResColl)
	if aResColl[i] <> aGenColl[i]
	 	nCnt ++
		? "Razlika u elementu " + ALLTRIM(STR(i))
	endif
next

if nCnt == 0
	?? "  [OK]"
endif

?
? "TEST CASE zavrsen ..."

return
*}


function TestStr2Niz()
*{

? REPLICATE("-", 70)
? "TEST CASE: STR 2 NIZ"
? REPLICATE("-", 70)

cStr:="12345678901234567890" + REPLICATE("A", 20) + REPLICATE("B", 20) + REPLICATE("C", 10)
aTmp:={}
aTmp:=StrToNiz(cStr, 20)
aRes:={}
AADD(aRes, "12345678901234567890")
AADD(aRes, "AAAAAAAAAAAAAAAAAAAA")
AADD(aRes, "BBBBBBBBBBBBBBBBBBBB")
AADD(aRes, "CCCCCCCCCC")

if LEN(aRes) <> LEN(aTmp)
	? "Nije ista duzina matrica"
endif

for i:=1 to LEN(aRes)
	if aTmp[i] <> aRes[i]
		? "Generisano: " + aTmp[i]
		? "Originalno: " + aRes[i]
	else
		? "Elementi OK"
	endif
next


return
*}


