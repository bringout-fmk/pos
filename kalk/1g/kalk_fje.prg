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

/*
 * ----------------------------------------------------------------
 *                                     Copyright Sigma-com software 
 * ----------------------------------------------------------------
 * $Source: c:/cvsroot/cl/sigma/fmk/pos/kalk/1g/kalk_fje.prg,v $
 * $Author: sasa $ 
 * $Revision: 1.2 $
 * $Log: kalk_fje.prg,v $
 * Revision 1.2  2002/06/15 12:23:22  sasa
 * no message
 *
 *
 */
 

// Ove funkcije prirodno pripadaju KALK-ku ali su pridodate u TOPS ...


/*! \fn Marza2(fMarza)
 *  \brief
 *  \param fMarza
 */
 
function Marza2(fMarza)
*{
local nPrevMP:=0
local nPPP
local nMPBP:=0

if fMarza==nil
	fMarza:=" "
endif

nPPP:=1

//IF( roba->tip == "K" , 1/(1+tarifa->opp/100) , 1 )

if _nCijena==0 
	_nCijena:=_cijena
endif

if IzFMKINI("POREZI","PPUgostKaoPPU","N")=="D"
	nMPBP:=_cijena/(1+tarifa->zpp/100+tarifa->ppp/100)/(1+tarifa->opp/100)
else
	nMPBP:=_cijena/(tarifa->zpp/100+(1+TARIFA->opp/100)*(1+TARIFA->PPP/100))
endif

if _Marza2==0 .and. empty(fmarza)
	nMarza2:=nMPBP-_ncijena*nPPP-nPrevMP
  	if _TMarza2=="%"
    		_Marza2 := IF( round(_ncijena,5)<>0 , 100*(nmpbp/(_ncijena*nPPP+nPrevMP)-1) , 0 )
  	elseif _TMarza2=="A"
    		_Marza2:=nMarza2
  	elseif _TMarza2=="U"
    		_Marza2:=nMarza2*(_Kolicina)
  	endif
elseif _cijena==0 .or. !empty(fMarza)
	if _TMarza2=="%"
     		nMarza2:=_Marza2/100*(_ncijena*nPPP+nPrevMP)
  	elseif _TMarza2=="A"
     		nMarza2:=_Marza2
  	elseif _TMarza2=="U"
     		nMarza2:=_Marza2/(_Kolicina)
  	endif
  	_cijena:=round(nMarza2+_ncijena,2)
  	if !empty(fMarza)
    		//if roba->tip=="V"
    		//  _cijena:=round(_cijena*(1+TARIFA->PPP/100),2)
    		//else
    		if IzFMKINI("POREZI","PPUgostKaoPPU","N")=="D"
      			_cijena:=round(_cijena*(1+TARIFA->opp/100)*(1+TARIFA->PPP/100+tarifa->zpp/100),1)
    		else
      			_cijena:=round(_cijena*(tarifa->zpp/100+(1+TARIFA->opp/100)*(1+TARIFA->PPP/100)),1)
    		endif
    		//endif
  	endif
else
	nMarza2:=nMPBP-_ncijena*nPPP-nPrevMP
endif
AEVAL(GetList,{|o| o:display()})
*}


