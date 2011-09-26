/* 
 * This file is part of the bring.out FMK, a free and open source 
 * accounting software suite,
 * Copyright (c) 1996-2011 by bring.out doo Sarajevo.
 * It is licensed to you under the Common Public Attribution License
 * version 1.0, the full text of which (including FMK specific Exhibits)
 * is available in the file LICENSE_CPAL_bring.out_FMK.md located at the 
 * root directory of this source code archive.
 * By using this software, you agree to be bound by its terms.
 */


#include "pos.ch"

function Zakrpe()
*{

private Opc:={}
private opcexe:={}
private Izbor:=1

AADD(opc,"1. doks ///                                          ")
AADD(opcexe, {|| Zakrpa1()})
AADD(opc,"2. postavi tarife u prometu kao u sifrarniku robe ")
AADD(opcexe, {|| KorekTar()})
AADD(opc,"3. cijene kasa <> cijene u fmk ")
AADD(opcexe, {|| SynchroCijene()})

Menu_SC("zakr")
CLOSERET
*}

function Zakrpa1()
*{
if !SigmaSif("BUG1DOKS")
  return
endif

if Pitanje(,"Izbrisati DOKS - radnika '////'","N")=="D"
   O_DOKS
   set order to 0
   go top
   nCnt:=0
   do while !eof()
       if IdRadnik='////'
	    nCnt++
	    delete
	endif
	skip
   enddo
   MsgBeep("Izbrisano "+str(nCnt)+" slogova")

endif
return nil
*}


function SynchroCijene()
*{
local lCekaj

CLOSE ALL
O_ROBA

MsgBeep("Sinhroniziraj cijene FMK roba i POS roba ...")


SET CURSOR ON
#ifdef PROBA
cLokacija:=ToUnix("K:\PLANIKA\var\data1\sigma\SIF\ROBA")
#else
cLokacija:=ToUnix("I:/SIGMA/SIF/ROBA")
#endif

cLokacija:=PADR(cLokacija,40)
Box(,2,60)
@ m_x+1,m_y+2 SAY "Fmk sif."  GET cLokacija
READ
BoxC()

cLokacija:=ALLTRIM(cLokacija)

lCekaj:=.t.
if (LASTKEY()==K_ESC)
	return
endif

SELECT 0
USE (cLokacija) ALIAS robaFmk
SET ORDER TO TAG "ID"

SELECT roba
GO TOP
nCnt:=0
do while !eof()
	SELECT robaFmk
	SEEK roba->id
	if FOUND()
		if ROUND(roba->cijena1, 2)<>ROUND(robaFmk->mpc, 2) 
			SELECT roba
			if lCekaj
				MsgBeep(roba->id+"##roba->cijena="+STR(roba->cijena1, 6, 2)+" => fmk->mpc="+STR(robaFmk->mpc, 6, 2))
				if (LASTKEY()==K_ESC)
					lCekaj:=.f.
				endif
			endif
			SmReplace("cijena1", robaFmk->mpc)
			++nCnt
		endif
	endif
	SELECT roba
	skip
enddo

MsgBeep("Izvrsio sam "+STR(nCnt,4)+" promjena ")

SELECT robaFmk
USE

return
*}


