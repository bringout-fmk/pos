#include "\cl\sigma\fmk\pos\pos.ch"

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


