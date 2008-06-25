#include "pos.ch"

/* Copyright (C) 1997-2006, Sigma-com Zenica
 * 
 */

/*! \fn PosPrijava(Fx,Fy)
 *  \brief
 */
 
function PosPrijava(Fx,Fy)
*{
local nChar
local cKorSif
local nSifLen
local nPom
local cLevel
local cBrojac
local nPrevKorRec

close all



nSifLen:=6

do while .t.

  SETPOS (Fx+4, Fy+15)
  cKorSif:=UPPER(GetLozinka(nSifLen))
  
	if (cKorSif == "SIGMAX")
		gIdRadnik := "XXXX" 
		gKorIme   := "SIGMA COM SERVIS"
		gSTRAD  := "A"      
		cLevel := L_SYSTEM
		EXIT
	endif

  // obradi specijalne sifre
  HSpecSifre(cKorSif)
  if (goModul:lTerminate)
  	return
  endif
  SET CURSOR OFF
  SETCOLOR (Normal)

  if SetUser(cKorSif, nSifLen, @cLevel) == 0
  	loop
  else
  	exit
  endif

ENDDO
PrikStatus()
CLOSE ALL
return (cLevel)
*}


/*! \fn HSpecSifre(cKorSif)
 *  \brief Obrada specijalnih sifri
 *  \note handle - rukovati
 */

function HSpecSifre(cKorSif)
*{
  if trim(upper(cKorsif)) $ "X"
    	UgasitiR()
  elseif trim(upper(cKorsif)) = "I"
       	InstallOps(cKorSif)
  elseif trim(upper(cKorsif)) = "M"
     //errorlevel(57)
     goModul:quit()
  endif

return
*}


