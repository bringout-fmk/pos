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
 * $Source: c:/cvsroot/cl/sigma/fmk/pos/dok/1g/rpt_pocs.prg,v $
 * $Author: sasa $ 
 * $Revision: 1.2 $
 * $Log: rpt_pocs.prg,v $
 * Revision 1.2  2002/06/15 08:17:46  sasa
 * no message
 *
 *
 */
 
/*! \fn PrepisPCS()
 */
 
function PrepisPCS()
*{
LOCAL nSir := 80, nRobaSir := 30, cLm := SPACE (5), cPicKol := "999999.999"
  START PRINT CRET
  IF gVrstaRS == "S"
    P_INI
    P_10CPI
  Else
    nSir := 40
    nRobaSir := 18
    cLM := ""
    cPicKol := "9999.999"
  EndIF

  ? PADC ("POCETNO STANJE " +;
          IIF (Empty (DOKS->IdPos), "", ALLTRIM (DOKS->IdPos)+"-")+;
          ALLTRIM (DOKS->BrDok), nSir)

  SELECT POS
  HSEEK DOKS->(IdPos+IdVd+dtos(datum)+BrDok)

  ? PADC (FormDat1 (DOKS->Datum) +;
          IIF (!Empty (DOKS->Smjena), " Smjena: "+DOKS->Smjena, ""), nSir)
  ?

  if !empty(doks->idgost)
   ?
   ? "Partner: ",doks->idgost
   ?
  endif

  ? cLM
  IF gVrstaRS == "S"
    ?? "Sifra    Naziv                          JMJ Cijena  Kolicina   ODJ"
    m := cLM+"-------- ------------------------------ --- ------- ---------- ---"
    IF gPostDO == "D"
      m += " ---"
    EndIF
  Else
    ?? "Sifra    Naziv              JMJ Kolicina"
    m := cLM+"-------- ------------------ --- --------"
  EndIF
  IF gPostDO == "D"
    ?? " DIO"
  EndIF
  ? m

/****
Sifra    Naziv                          JMJ Cijena  Kolicina   ODJ DIO
-------- ------------------------------ --- ------- ---------- --- ---
01234567 012345678901234567890123456789     9999.99 999999.999
                                            999,999,999,999.99
Sifra    Naziv              JMJ Kolicina
         ODJ DIO
-------- ------------------ --- --------
01234567 012345678901234567 012 9999.999
         01  01
                            9,999,999.99
****/

  nFin := 0
  SELECT POS
  While ! Eof() .and. POS->(IdPos+IdVd+dtos(datum)+BrDok)==DOKS->(IdPos+IdVd+dtos(datum)+BrDok)
    IF gVrstaRS == "S" .and. Prow() > 63-gPstranica
      FF
    EndIF
    ? cLM
    ?? IdRoba, ""
    IF POS->MU_I $ S_U+S_I  // ??????? sirovine ?????
      SELECT SIROV
    else
      SELECT ROBA
    EndIF
    HSEEK POS->IdRoba
    ?? PADR (_field->Naz, nRobaSir), _field->Jmj, ""
    SELECT POS
    IF gVrstaRS == "S"
     ?? TRANS (POS->Cijena, "9999.99"), ""
    EndIF
    ?? TRANS (POS->Kolicina, cPicKol)
    IF gVrstaRS <> "S"
      ? cLM+SPACE (LEN (POS->IdRoba))
    EndIF
    ?? " "+POS->IdOdj, " "+POS->IdDio
    nFin += POS->(Kolicina * Cijena)
    SKIP
  ENDDO
  IF gVrstaRS == "S" .and. Prow() > 63-gPstranica - 7
    FF
  EndIF
  ? m
  ? cLM
  ?? PADL ("IZNOS DOKUMENTA ("+TRIM (gDomValuta)+")", ;
           IIF (gVrstaRS=="S", 13,10)+nRobaSir), ;
     TRANS (nFin, IIF (gVrstaRS=="S", "999,999,999,999.99", "9,999,999.99"))
  ? m
  IF gVrstaRS == "S"
    FF
  Else
    PaperFeed()
  EndIF
  END PRINT
  SELECT DOKS
RETURN
*}

