#include "\cl\sigma\fmk\pos\pos.ch"

/*
 * ----------------------------------------------------------------
 *                                     Copyright Sigma-com software 
 * ----------------------------------------------------------------
 * $Source: c:/cvsroot/cl/sigma/fmk/pos/rpt/1g/rpt_ldok.prg,v $
 * $Author: sasavranic $ 
 * $Revision: 1.4 $
 * $Log: rpt_ldok.prg,v $
 * Revision 1.4  2004/06/08 07:32:34  sasavranic
 * Unificirane funkcije rabata
 *
 * Revision 1.3  2003/06/28 15:05:36  mirsad
 * omogucen ispis naziva firme na izvjestajima
 *
 * Revision 1.2  2002/06/14 14:02:43  mirsad
 * prirpeme za doxy dokumenter
 *
 *
 */


/*! \file fmk/pos/rpt/1g/rpt_ldok.prg
 *  \brief Stampa dokumenata
 */

/*! \fn StDoks()
 *  \brief Stampa dokumenata
 */

function StDoks()
*{
local cIdVd
local dDatOd:=CTOD("")
local dDatDo:=gDatum
local cIdRadnik
local cDoks
local nBH:=8
local nR:=5
local cIdPos:=gIdPos
local cLM:=""
local nRW:=13
local nSir

set cursor on

if gVrstaRS=="S"
	nBH:=10
	nR:=7
	cLM:=SPACE(5)
	cIdPos:=SPACE(LEN(KASE->Id))
	nRW:=30
	nSir:=80
else
	cIdPos:=gIdPos
endif

if gVrstaRS=="K"
	cDoks:=VD_RN+"#"+VD_RZS   // samo ovo moze postojati
else
	cDoks:=VD_RN+"#"+VD_ZAD+"#"+"IN"+"#"+VD_NIV+"#"+VD_RZS
endif

cIdRadnik:=SPACE(LEN(OSOB->Id))
cIdVd:=SPACE(LEN(DOKS->IdVd))

set cursor on
Box(,10,77)

if gVrstaRS<>"K"
	@ m_x+1,m_y+2 SAY " Prodajno mjesto (prazno sva)" GET cIdPos PICT "@!" VALID empty(cIdPos).or.P_Kase(@cIdPos,1,37)
endif

@ m_x+2,m_y+2 SAY "          Radnik (prazno svi)" GET cIdRadnik PICT "@!" VALID empty(cIdRadnik).or.P_Osob(@cIdRadnik,2,37)
@ m_x+3,m_y+2 SAY "Vrste dokumenata (prazno svi)" GET cIdVd PICT "@!" VALID empty(cIdVd).or.cIdVd$cDoks
@ m_x+4,m_y+2 SAY "            Pocevsi od datuma" GET dDatOd PICT "@D" VALID dDatOd<=gDatum.and.dDatOd<=dDatDo
@ m_x+5,m_y+2 SAY "                 Zakljucno sa" GET dDatDo PICT "@D" VALID dDatDo<=gDatum.and.dDatOd<=dDatDo
read
ESC_BCR

BoxC()

SELECT DOKS
cFilt1:="DATUM>="+cm2str(dDatOd)+".and.DATUM<="+cm2str(dDatDo)
set filter to &cFilt1
seek cIdPos+cIdVd

EOF CRET

START PRINT CRET

ZagFirma()
?

if gVrstaRS<>"S"
	? PADC("KASA "+gIdPos,40)
else
	P_10CPI
endif

? PADC("STAMPA LISTE DOKUMENATA",nSir)
? PADC("NA DAN "+FormDat1 (gDatum),nSir)
? PADC("-------------------------",nSir)
? PADC("Za period od "+FormDat1(dDatOd)+" do "+FormDat1(dDatDo),nSir)
?

if gVrstaRS=="S"
	P_12CPI
endif

? cLM+"VD",PADR("Broj",9)

if gVrstaRS=="S"
	?? " "+PADC("Datum",11),"Smjena"
endif

?? " "+PADR("Radnik",nRW),"BrS"," Iznos"
? cLM+"--",REPL("-", 9)

if gVrstaRS=="S"
	?? " "+REPL("-",11),REPL("-",6)
endif

?? " "+REPL("-",nRW),"---",REPL("-",10)

if !empty(cIdVd)
	nSuma:=0
endif

do while !eof()

	if (!empty(cIdVd).and.DOKS->IdVd<>cIdVd).or.(!empty(cIdRadnik).and.DOKS->IdRadnik<>cIdRadnik)
		skip
		loop
	endif

	? cLM
	?? DOKS->IdVd,PADR(ALLTRIM(DOKS->IdPos)+"-"+ALLTRIM(DOKS->BrDok),9)

	if gVrstaRS=="S"
		?? " "+FormDat1(DOKS->Datum),PADC(DOKS->Smjena,6)
	endif

	SELECT OSOB
	HSEEK DOKS->IdRadnik
	?? " "+LEFT(OSOB->Naz,nRW)
	nBrStav:=0
	nIznos:=0
	SELECT POS
	seek DOKS->(IdPos+IdVd+dtos(datum)+BrDok)

	do while !eof().and.POS->(IdPos+IdVd+dtos(datum)+BrDok)==DOKS->(IdPos+IdVd+dtos(datum)+BrDok)
		nBrStav++
		nIznos+=POS->kolicina*POS->cijena
		skip
	enddo

	?? " "+STR(nBrStav,3),STR(nIznos,8,2)

	if !empty(cIdVd)
		nSuma+=nIznos
	endif

	SELECT DOKS
	skip
enddo

if !empty(cIdVd)
	? cLM+"--",REPL ("-",9)

	if gVrstaRS=="S"
		?? " "+REPL("-",11),REPL("-",6)
	endif

	?? " "+REPL("-",nRW),"---",REPL("-",8)

	if gVrstaRS=="S"
		? cLM+PADL("U K U P N O  ("+gDomValuta+")",3+9+19+1+nRW),STR(nSuma,12,2)
	else
		? cLM+PADL("U K U P N O  ("+gDomValuta+")",3+9+0+1+nRW),STR(nSuma,12,2)
	endif
endif

END PRINT
return
*}


