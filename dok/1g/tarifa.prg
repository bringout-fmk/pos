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
 */
 
/*! \fn WhileaTarife(cIdRoba,nIzn,aTarife,nPPP,nPPU,nOsn,nPP)
 *  \param cIdRoba
 *  \param nIzn
 *  \param aTarife
 */
 
function WhileaTarife(cIdRoba,nIzn,aTarife,nPPP,nPPU,nOsn,nPP)
*{

nArr:=SELECT()

O_ROBA
O_TARIFA

SELECT (F_ROBA)
SEEK cIdRoba

SELECT (F_TARIFA)
SEEK ROBA->idtarifa
SELECT (nArr)

IF IzFMKINI("POREZI","PPUgostKaoPPU","N")=="D"
  nOsn:=nIzn/(1+tarifa->zpp/100+tarifa->ppp/100)/(1+tarifa->opp/100)
  nPPP:=nOsn*tarifa->opp/100
  nPP :=(nOsn+nPPP)*tarifa->zpp/100
ELSE
  nOsn:=nIzn/(tarifa->zpp/100+(1+tarifa->opp/100)*(1+tarifa->ppp/100))
  nPPP:=nOsn*tarifa->opp/100
  nPP :=nOsn*tarifa->zpp/100
ENDIF

nPPU:=(nOsn+nPPP)*tarifa->ppp/100

nPoz := ASCAN (aTarife, {|x| x[1]==ROBA->IdTarifa})
IF nPoz==0
  AADD (aTarife, {ROBA->IdTarifa, nOsn, nPPP, nPPU, nPP})
Else
  aTarife [nPoz][2] += nOsn
  aTarife [nPoz][3] += nPPP
  aTarife [nPoz][4] += nPPU
  aTarife [nPoz][5] += nPP
EndIF

return nil
*}


/*! \fn WhilePTarife(cIdRoba,cIdTarifa,nIzn,aTarife,nPPP,nPPU,nOsn,nPP)
 *  \param cIdRoba
 *  \param nIzn
 *  \param aTarife
 */
 
function WhilePTarife(cIdRoba,cIdTarifa,nIzn,aTarife,nPPP,nPPU,nOsn,nPP)
*{

nArr:=SELECT()

O_TARIFA

SELECT (F_TARIFA)
SEEK cIdTarifa
SELECT (nArr)

IF IzFMKINI("POREZI","PPUgostKaoPPU","N")=="D"
  nOsn:=nIzn/(1+tarifa->zpp/100+tarifa->ppp/100)/(1+tarifa->opp/100)
  nPPP:=nOsn*tarifa->opp/100
  nPP :=(nOsn+nPPP)*tarifa->zpp/100
ELSE
  nOsn:=nIzn/(tarifa->zpp/100+(1+tarifa->opp/100)*(1+tarifa->ppp/100))
  nPPP:=nOsn*tarifa->opp/100
  nPP :=nOsn*tarifa->zpp/100
ENDIF

nPPU:=(nOsn+nPPP)*tarifa->ppp/100

nPoz := ASCAN (aTarife, {|x| x[1]==cIdTarifa})
IF nPoz==0
  AADD (aTarife, {cIdTarifa, nOsn, nPPP, nPPU, nPP})
Else
  aTarife [nPoz][2] += nOsn
  aTarife [nPoz][3] += nPPP
  aTarife [nPoz][4] += nPPU
  aTarife [nPoz][5] += nPP
EndIF

return nil
*}


