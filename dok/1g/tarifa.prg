#include "\cl\sigma\fmk\pos\pos.ch"

/*
 * ----------------------------------------------------------------
 *                                     Copyright Sigma-com software 
 * ----------------------------------------------------------------
 * $Source: c:/cvsroot/cl/sigma/fmk/pos/dok/1g/tarifa.prg,v $
 * $Author: sasa $ 
 * $Revision: 1.4 $
 * $Log: tarifa.prg,v $
 * Revision 1.4  2003/07/25 15:56:22  sasa
 * ispadanje programa, nisu bile otvorene tabele ROBA i TARIFA
 *
 * Revision 1.3  2002/11/21 10:10:45  mirsad
 * debugiranje - pri štampi ruèno unešenog zaduženja ispadao zbog nedefinisane var. nPPP
 *
 * Revision 1.2  2002/06/15 08:17:46  sasa
 * no message
 *
 *
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

