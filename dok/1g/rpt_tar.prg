#include "\cl\sigma\fmk\pos\pos.ch"

/*
 * ----------------------------------------------------------------
 *                                     Copyright Sigma-com software 
 * ----------------------------------------------------------------
 * $Source: c:/cvsroot/cl/sigma/fmk/pos/dok/1g/rpt_tar.prg,v $
 * $Author: sasa $ 
 * $Revision: 1.2 $
 * $Log: rpt_tar.prg,v $
 * Revision 1.2  2002/06/15 08:17:46  sasa
 * no message
 *
 *
 */
 
/*! \fn RekTarife(aTarife)
 */
 
function RekTarife(aTarife)
*{

?
?
? "REKAPITULACIJA POREZA PO TARIFAMA"
? "---------------------------------"
nTotOsn := 0  ; nTotPPP := 0;  nTotPPU := 0; nTotPP:=0
m:= REPLICATE ("-", 6)+" "+REPLICATE ("-", 10)+" "+REPLICATE ("-", 8)+" "+;
    REPLICATE ("-", 8)
ASORT (aTarife,,, {|x, y| x[1] < y[1]})
fPP:=.f.
for nCnt:=1 to LEN(aTarife)
  if round(aTarife[nCnt][5],4)<>0
      fPP:=.t.
  endif
next
? m
? "Tarifa", PADC ("MPV B.P.", 10), PADC ("P P P", 8), PADC ("P P U", 8)
? "      ", padC ("- MPV -",10)  , padc("",9)
if fPP
   ?? padc (" P P  ",8)
endif
? m
for nCnt := 1 TO LEN(aTarife)
  ? aTarife [nCnt][1], STR (aTarife [nCnt][2], 10, 2), ;
    STR (aTarife [nCnt][3], 8, 2), STR (aTarife [nCnt][4], 8, 2)
  ? space(6), STR( round(aTarife[nCnt][2],2)+;
                   round(aTarife[nCnt][3],2)+;
                   round(aTarife[nCnt][4],2)+;
                   round(aTarife[nCnt][5],2), 10,2),;
               space(9)
  if fPP
               ?? str(aTarife [nCnt][5], 8, 2)
  endif

  nTotOsn += round(aTarife [nCnt][2],2)
  nTotPPP += round(aTarife [nCnt][3],2)
  nTotPPU += round(aTarife [nCnt][4],2)
  nTotPP +=  round(aTarife [nCnt][5],2)
next
? m
? "UKUPNO", STR (nTotOsn, 10, 2), STR (nTotPPP, 8, 2), STR (nTotPPU, 8, 2)
? SPACE(6),str(nTotOsn+nTotPPP+nTotPPU+nTotPP,10,2),space(9)
if fPP
  ?? str(nTotPP,8,2)
endif
? m
?
?
return NIL
*}



