#include "pos.ch"


// --------------------------------------
// rekapitulacija tarifa pos
// --------------------------------------
function RekTarife(aTarife)

?
? "REKAPITULACIJA POREZA PO TARIFAMA"

nTotOsn := 0  ; nTotPPP := 0;  nTotPPU := 0; nTotPP:=0
m:= REPLICATE ("-", 6)+" "+REPLICATE ("-", 10)+" "+REPLICATE ("-", 10)+" "+;
    REPLICATE ("-", 10)
ASORT (aTarife,,, {|x, y| x[1] < y[1]})
fPP:=.f.
for nCnt:=1 to LEN(aTarife)
  if round(aTarife[nCnt][5],4)<>0
      fPP:=.t.
  endif
next
? m
? "Tarifa", PADC ("MPV B.P.", 10), PADC ("P P P", 10), PADC ("P P U", 10)
? "      ", padC ("- MPV -",10)  , padc("",9)
if fPP
   ?? padc (" P P  ",8)
endif
? m
for nCnt := 1 TO LEN(aTarife)
  ? aTarife [nCnt][1], STR (aTarife [nCnt][2], 10, 2), ;
    STR (aTarife [nCnt][3], 10, 2), STR (aTarife [nCnt][4], 10, 2)
  ? space(6), STR( round(aTarife[nCnt][2],2)+;
                   round(aTarife[nCnt][3],2)+;
                   round(aTarife[nCnt][4],2)+;
                   round(aTarife[nCnt][5],2), 10,2),;
               space(9)
  if fPP
               ?? str(aTarife [nCnt][5], 10, 2)
  endif

  nTotOsn += round(aTarife [nCnt][2],2)
  nTotPPP += round(aTarife [nCnt][3],2)
  nTotPPU += round(aTarife [nCnt][4],2)
  nTotPP +=  round(aTarife [nCnt][5],2)
next
? m
? "UKUPNO", STR (nTotOsn, 10, 2), STR (nTotPPP, 10, 2), STR (nTotPPU, 10, 2)
? SPACE(6),str(nTotOsn+nTotPPP+nTotPPU+nTotPP,10,2),space(9)
if fPP
  ?? str(nTotPP,10,2)
endif
? m
?
?

return NIL


// -----------------------------------------
// pdv rekapitulacija tarifa pos
// -----------------------------------------
function PDVRekTarife(aTarife)
local nArr
local cLine

?
? "REKAPITULACIJA POREZA PO TARIFAMA"

nTotOsn := 0
nTotPPP := 0
nTotPPU := 0
nTotPP:=0
nPDV:=0

cLine := REPLICATE("-", 12)
cLine += " "
cLine += REPLICATE("-", 12)
cLine += " "
cLine += REPLICATE("-", 12)

ASORT (aTarife,,, {|x, y| x[1] < y[1]})

? cLine

? "Tarifa (Stopa %)"
? PADC("PV bez PDV", 12), PADC("PDV", 12), padC("PV sa PDV",12)

? cLine

nArr:=SELECT()

for nCnt:=1 TO LEN(aTarife)
	
	select tarifa
	hseek aTarife[nCnt][1]
	nPDV:=tarifa->opp
		
	? aTarife[nCnt][1], "(" + STR(nPDV) + "%)"
	? STR(aTarife [nCnt][2], 12, 2), STR (aTarife [nCnt][3], 12, 2), STR( round(aTarife[nCnt][2],2)+round(aTarife[nCnt][3],2), 12,2)
	nTotOsn += round(aTarife [nCnt][2],2)
  	nTotPPP += round(aTarife [nCnt][3],2)
next

select (nArr)

? cLine
? "UKUPNO"
? STR(nTotOsn, 12, 2), STR(nTotPPP, 12, 2), STR(nTotOsn + nTotPPP, 12, 2)
? cLine
?

return NIL



