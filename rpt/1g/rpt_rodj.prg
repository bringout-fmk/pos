#include "\cl\sigma\fmk\pos\pos.ch"

/*
 * ----------------------------------------------------------------
 *                                     Copyright Sigma-com software 
 * ----------------------------------------------------------------
 * $Source: c:/cvsroot/cl/sigma/fmk/pos/rpt/1g/rpt_rodj.prg,v $
 * $Author: mirsad $ 
 * $Revision: 1.6 $
 * $Log: rpt_rodj.prg,v $
 * Revision 1.6  2003/06/28 15:05:36  mirsad
 * omogucen ispis naziva firme na izvjestajima
 *
 * Revision 1.5  2003/04/24 20:45:02  mirsad
 * prenos TOPS->FAKT
 *
 * Revision 1.4  2002/06/17 13:18:22  mirsad
 * dokumentovanje f-ja (priprema za doxy)
 *
 * Revision 1.3  2002/06/17 11:45:25  mirsad
 * dokumentovanje f-ja (priprema za doxy)
 *
 * Revision 1.2  2002/06/14 14:02:43  mirsad
 * prirpeme za doxy dokumenter
 *
 *
 */

/*! \file fmk/pos/rpt/1g/rpt_rodj.prg
 *  \brief Izvjestaj: realizacija odjeljenja
 */

/*! \fn RealOdj()
 *  \brief Izvjestaj: realizacija odjeljenja
 */

function RealOdj()
*{
LOCAL   nSir:=IIF (gVrstaRS=="S", 80, 40)
PRIVATE cIdOdj := SPACE(2), cPrikRobe := "D"
PRIVATE cSmjena:=SPACE(1), cIdPos:=gIdPos, cIdDio := gIdDio
PRIVATE dDat0:=gDatum, dDat1:=gDatum, aNiz, cRoba := SPACE (60)

  O_DIO;  O_ODJ
if gSifk=="D"
 O_SIFK;O_SIFV
endif
  O_KASE; O_ROBA
  O_POS ; O_DOKS

  aDbf := {}
  AADD (aDbf, {"IdOdj"   , "C",  2, 0})
  AADD (aDbf, {"IdDio"   , "C",  2, 0})
  AADD (aDbf, {"IdPos"   , "C",  2, 0})
  AADD (aDbf, {"IdRoba"  , "C",  8, 0})
  AADD (aDbf, {"IdCijena", "C",  1, 0})
  AADD (aDbf, {"Kolicina", "N", 15, 3})
  AADD (aDbf, {"Iznos",    "N", 20, 5})
  AADD (aDbf, {"Iznos2",    "N", 20, 5})
  AADD (aDbf, {"Iznos3",    "N", 20, 5})
  NaprPom (aDbf)
  USEX (PRIVPATH+"POM") NEW
  INDEX ON IdOdj+IdDio+IdPos+IdRoba+IdCijena TAG ("1") TO (PRIVPATH+"POM")
  INDEX ON IdOdj+IdDio+IdRoba+IdCijena TAG ("2") TO (PRIVPATH+"POM")
  index ON BRISANO TAG "BRISAN"    //TO (PRIVPATH+"ZAKSM")
  set order to 1

  aNiz := {}
  cIdPos := gIdPos
  IF gVrstaRS <> "K"
    AADD (aNiz, {"Prod. mjesto (prazno-sve)", "cIdPos", "cidpos='X' .or. empty(cIdPos).or.P_Kase(@cIdPos)","@!",})
    if gModul=="HOPS"
      cIdDio := SPACE (LEN (cIdDio))
      AADD (aNiz, {"Dio objekta (prazno-svi)", "cIdDio", "empty(cIdDio).or.P_Dio(@cIdDio)","@!",})
    endif
  ELSE
    cIdPos := gIdPos
    cIdDio := gIdDio
  ENDIF
  if gvodiodj=="D"
    AADD (aNiz, {"Odjeljenje (prazno-sva)", "cIdOdj", "empty(cIdOdj) .or. P_Odj(@cIdOdj)","@!",})
  endif
  AADD (aNiz, {"Roba (prazno-sve)","cRoba",,"@!S30",})
  AADD (aNiz, {"Izvjestaj se pravi od datuma","dDat0",,,})
  AADD (aNiz, {"                   do datuma","dDat1",,,})
  AADD(aNiz,  {"Prikazi robe D/N",            "cPrikRobe","cPrikRobe$'DN'","@!",})
  DO WHILE .t.
    IF !VarEdit( aNiz, 10,5,20,74,;
               'USLOVI ZA IZVJESTAJ "REALIZACIJA ODJELJENJA"',;
               "B1")
      CLOSERET
    ENDIF
    aUsl1:=Parsiraj(cRoba,"idroba")
    if aUsl1<>NIL.and.dDat0<=dDat1
      exit
    elseif aUsl1==NIL
      Msg("Kriterij za robu nije korektno postavljen!")
    else
      Msg("'Datum do' ne smije biti stariji nego 'datum od'!")
    endif
  ENDDO

  // pravljenje izvjestaja
  START PRINT CRET

  ZagFirma()

  P_10CPI
  ?
  ? PADC("REALIZACIJA ODJELJENJA",nSir)
  ? PADC ("NA DAN "+FormDat1(DATE()), nSir)
  ? PADC("-------------------------------------",nSir)
  ? "PROD.MJESTO: "+cidpos+"-"+IF(EMPTY(cIdPos),"SVA",Ocitaj (F_KASE, cIdPos,"Naz"))
  if gvodiodj=="D"
   ? "ODJELJENJA : "+IF(EMPTY(cIdOdj),"SVA",Ocitaj (F_ODJ, cIdOdj,"Naz"))
  endif
if gModul=="HOPS"
  ? "DIO OBJEKTA: "+IF(EMPTY(cIdDIO),"SVI",Ocitaj (F_DIO, cIdDIO,"Naz"))
endif 
  ? "PERIOD     : "+FormDat1(dDat0)+" - "+FormDat1(dDat1)

  SELECT DOKS
  set order to 2    // "DOKSi2", "IdVd+DTOS (Datum)+Smjena"

  OdjIzvuci (VD_PRR)
  OdjIzvuci (VD_RN)

  // stampa izvjestaja
  SELECT POM
  set order to 1
  GO TOP
  nTotal := 0
  nTotal2 := 0
  nTotal3 := 0

  nTotOdj := 0
  nTotOdj2 := 0
  nTotOdj3 := 0

  nTotPos := 0
  nTotPos2 := 0
  nTotPos3 := 0

  DO WHILE !EOF()
    SELECT ODJ
    HSEEK POM->IdOdj
    ?
    ? POM->IdOdj, ODJ->Naz
    ? REPL ("-", 40)
    SELECT POM
    _IdOdj := POM->IdOdj
    nTotOdj := 0
    nTotOdj2 := 0
    nTotOdj3 := 0
    do WHILE !Eof() .and. POM->IdOdj==_IdOdj
      _IdDio := POM->IdDio
      IF ! EMPTY (_IdDio)
        SELECT DIO
        HSEEK _IdDio
        ? SPACE (5) + DIO->Naz
        ? SPACE (5) + REPL ("-", 35)
        SELECT POM
      ENDIF
      nTotDio := 0
      nTotDio2 := 0
      nTotDio3 := 0
      do WHILE !EOF() .and. POM->(IdOdj+IdDio)==(_IdOdj+_IdDio)
        _IdPos := POM->IdPos
        SELECT KASE
        HSEEK _IdPos
        ? space(1)+_idpos+":", + KASE->Naz
        SELECT POM
        nTotPos := 0
        nTotPos2 := 0
        nTotPos3 := 0
        DO  WHILE !Eof() .and. POM->(IdOdj+IdDio+IdPos)==(_IdOdj+_IdDio+_IdPos)
          nTotPos += POM->Iznos
          nTotPos2 += POM->Iznos2
          nTotPos3 += POM->Iznos3
          SKIP
        ENDDO
        ?? STR (nTotPos, 20, 2)
        nTotDio += nTotPos
        nTotDio2 += nTotPos2
        nTotDio3 += nTotPos3
      END
      IF ! Empty (_idDio)
        ? SPACE (5)+REPL ("-", 35)
        ? SPACE (5)+PADL ("UKUPNO", 15)+STR (nTotDio, 20, 2)
      ENDIF
      nTotOdj += nTotDio
      nTotOdj2 += nTotDio2
      nTotOdj3 += nTotDio3
    END
    ? REPL ("-", 40)
    ? PADC ("UKUPNO ODJELJENJE", 20) + STR (nTotOdj, 20, 2)
    if nTotodj2<>0
      ? PADL ("PARTICIPACIJA:", 20), STR (nTotOdj2, 20, 2)
    endif
    if nTotOdj3<>0
      ? PADL (NenapPop(), 20), STR (nTotOdj3, 20, 2)
      ? PADL ("UKUPNO NAPLATA:", 20), STR (nTotOdj-nTotOdj3+nTotOdj2, 20, 2)
    endif
    ? REPL ("-", 40)
    nTotal += nTotOdj
    nTotal2 += nTotOdj2
    nTotal3 += nTotOdj3
  END
  IF empty (cIdOdj)
    ? REPL ("=", 40)
    ? PADC ("SVA ODJELJENJA", 20) + STR (nTotal, 20, 2)
    if nTotal2<>0
      ? PADL ("PARTICIPACIJA:", 20), STR (nTotal2, 20, 2)
    endif
    if nTotal3<>0
      ? PADL (NenapPop(), 20), STR (nTotal3, 20, 2)
      ? PADL ("UKUPNO NAPLATA:", 20), STR (nTotal-nTotal3+nTotal2, 20, 2)
    endif
    ? REPL ("=", 40)
  ENDIF

  IF cPrikRobe == "D"
    nTotal := 0
    nTotal2 := 0
    nTotal3 := 0
    SELECT POM
    set order to 2
    go top
    do WHILE !eof()
      _IdOdj := POM->IdOdj
      SELECT ODJ
      HSEEK _IdOdj
      ? ODJ->Naz
      ? REPL ("-", 40)
      SELECT POM
      nTotOdj := 0
      nTotOdj2 := 0
      nTotOdj3 := 0
      do WHILE !EOF() .and. POM->IdOdj==_IdOdj
        _IdDio := POM->IdDio
        IF !Empty (_IdDio)
          SELECT DIO; HSEEK (_IdDio)
          ? SPACE (5) + DIO->Naz
          ? SPACE (5) + REPL ("-", 35)
          SELECT POM
        ENDIF
        nTotDio := 0
        nTotDio2 := 0
        nTotDio3 := 0
        do WHILE !Eof() .and. POM->(IdOdj+IdDio)==(_IdOdj+_IdDio)
          _IdRoba := POM->IdRoba
          SELECT ROBA
          HSEEK _IdRoba
          ? SPACE (5) + _IdRoba, LEFT (ROBA->Naz, 26)
          SELECT POM
          do WHILE !Eof() .and. ;
                POM->(IdOdj+IdDio+IdRoba)==(_IdOdj+_IdDio+_IdRoba)
            _idCijena := POM->IdCijena
            nKol := 0
            nIzn := 0
            nIzn2 := 0
            nIzn3 := 0
            DO WHILE !Eof() .and. ;
                  POM->(IdOdj+IdDio+IdRoba+IdCijena)==(_IdOdj+_IdDio+_IdRoba+_IdCijena)
              nKol += POM->Kolicina
              nIzn += POM->Iznos
              nIzn2+= POM->Iznos2
              nIzn3+= POM->Iznos3
              Skip
            EndDO
            ? SPACE (10)+_IdCijena, STR (nKol, 12, 3), STR (nIzn, 15, 2)
            nTotDio += nIzn
            nTotDio2 += nIzn2
          END
        END
        IF ! Empty (_IdDio)
          ? SPACE (5) + PADC ("UKUPNO", 19), STR (nTotDio, 15, 2)
        ENDIF
        nTotOdj += nTotDio
        nTotOdj2 += nTotDio2
      END
      ? REPL ("-", 40)
      ? PADC ("UKUPNO ODJELJENJE", 25)+ STR (nTotOdj, 15, 2)
      if nTotOdj2<>0
        ? PADL ("PARTICIPACIJA:", 20), STR (nTotOdj2, 15, 2)
      endif
      if nTotOdj3<>0
        ? PADL (NenapPop(), 20), STR (nTotOdj3, 15, 2)
        ? PADL ("UKUPNO NAPLATA:", 20), STR (nTotOdj-nTotOdj3+nTotOdj2, 15, 2)
      endif
      ? REPL ("-", 40)
      nTotal += nTotOdj
      nTotal2 += nTotOdj2
      nTotal3 += nTotOdj3
    END
    IF Empty (cIdDio)
      ? REPL ("=", 40)
      ? PADC ("SVA ODJELJENJA", 25)+ STR (nTotal, 15, 2)
      if nTotal2<>0
        ? PADL ("PARTICIPACIJA:", 20), STR (nTotal2, 15, 2)
      endif
      if nTotal3<>0
        ? PADL (NenapPop(), 20), STR (nTotal3, 15, 2)
        ? PADL ("UKUPNO NAPLATA:", 20), STR (nTotal-nTotal3+nTotal2, 15, 2)
      endif
      ? REPL ("=", 40)
    EndIF
  ENDIF
  END PRINT
CLOSERET
*}


/*! \fn DioIzvuci(cIdVd)
 *  \brief Punjenje pomocne baze realizacijom dijelova odjeljenja
 */
 
function DioIzvuci(cIdVd)
*{
  if cGotZir==nil
  	cGotZir:=" "
  endif
  Seek cIdVd+DTOS (dDat0)
  DO While ! Eof() .and. DOKS->IdVd==cIdVd .and. DOKS->Datum <= dDat1
    IF (Klevel>"0" .and. doks->idpos="X") .or. ;
       (DOKS->IdPos="X" .and. AllTrim (cIdPos)<>"X") .or.;
       (! Empty (cIdPos) .and. DOKS->IdPos<>cIdPos) .or.;
       !empty(cGotZir).and.(cGotZir=="Z".and.DOKS->placen<>"Z".or.cGotZir<>"Z".and.DOKS->placen=="Z")
      Skip; Loop
    EndIF
    Scatter()
    
    SELECT POS
    Seek DOKS->(IdPos+IdVd+dtos(datum)+BrDok)
    DO While ! Eof() .and. POS->(IdPos+IdVd+dtos(datum)+BrDok)==DOKS->(IdPos+IdVd+dtos(datum)+BrDok)
      IF (!Empty (cIdOdj) .and. POS->IdOdj<>cIdOdj) .or.;
         (!Empty (cIdDio) .and. POS->IdDio<>cIdDio) .or.;
         !Tacno (aUsl1)
        Skip; Loop
      EndIF

      select roba; hseek pos->idroba
      select odj; hseek roba->idodj
      nNeplaca:=0
      if right(odj->naz,5)=="#1#0#"  // proba!!!
       nNeplaca:=pos->(Kolicina*Cijena)
      elseif right(odj->naz,6)=="#1#50#"
       nNeplaca:=pos->(Kolicina*Cijena)/2
      endif
      if gPopVar="P"; nNeplaca+=pos->(kolicina*NCijena); endif

      Scatter()
      SELECT POM; APPEND BLANK
      _Iznos := POS->Kolicina*POS->Cijena
      _Iznos2 := POS->(ncijena*kolicina)
      if gPopVar=="A"
        _iznos3 := nNeplaca
      endif
      Gather()
      SELECT POS
      Skip
    EndDO
    SELECT DOKS
    Skip
  EndDO
RETURN
*}


/*! \fn RealDio(cPrikRobe)
 *  \param cPrikRobe
 *  \brief Priprema i prikaz realizacije dijela objekta
 */

*function RealDio(cPrikRobe)
*{
function RealDio
PARAMETERS cPrikRobe
PRIVATE cIdDio := SPACE(2)
PRIVATE cSmjena:=SPACE(1), cIdPos:=gIdPos, cIdOdj := SPACE (2)
PRIVATE dDat0:=gDatum, dDat1:=gDatum, aNiz, cRoba := SPACE (60)
PRIVATE cIdRadnik := SPACE (4), cIdVrsteP := SPACE (2), cGotZir:=" "

cPrikRobe := IIF (cPrikRobe==NIL, "N", cPrikRobe)

O_DIO
O_ODJ
O_OSOB
Set order to tag ("NAZ")
O_VRSTEP
O_KASE

if gSifK=="D"
	O_SIFK
	O_SIFV
endif

O_ROBA
O_POS
O_DOKS

  aDbf := {}
  AADD (aDbf, {"IdDio"   , "C",  2, 0})
  AADD (aDbf, {"IdOdj"   , "C",  2, 0})
  AADD (aDbf, {"IdPos"   , "C",  2, 0})
  AADD (aDbf, {"IdRadnik", "C",  4, 0})
  AADD (aDbf, {"IdVrsteP", "C",  2, 0})
  AADD (aDbf, {"IdRoba"  , "C", 10, 0})
  AADD (aDbf, {"IdCijena", "C",  1, 0})
  AADD (aDbf, {"Kolicina", "N", 15, 3})
  AADD (aDbf, {"Iznos",    "N", 20, 5})
  AADD (aDbf, {"Iznos2",    "N", 20, 5})
  AADD (aDbf, {"Iznos3",    "N", 20, 5})
  NaprPom (aDbf)
  USEX (PRIVPATH+"POM") NEW
  INDEX ON IdDio+IdPos+IdVrsteP TAG ("1") TO (PRIVPATH+"POM")
  INDEX ON IdDio+IdRadnik+IdVrsteP TAG ("2") TO (PRIVPATH+"POM")
  INDEX ON IdDio+IdVrsteP TAG ("3") TO (PRIVPATH+"POM")
  INDEX ON IdDio+IdOdj TAG ("4") TO (PRIVPATH+"POM")
  INDEX ON IdDio+IdRoba+IdCijena TAG ("5") TO (PRIVPATH+"POM")
  index ON BRISANO TAG "BRISAN"
  set order to 1

  aNiz := {}
  cIdPos := gIdPos
  IF gVrstaRS <> "K"
    AADD (aNiz, {"Prod. mjesto (prazno-sve)", "cIdPos", "cidpos='X' .or. empty(cIdPos).or.P_Kase(@cIdPos)","@!",})
  ELSE
    cIdPos := gIdPos
  ENDIF
  AADD (aNiz, {"Dio objekta (prazno-svi)", "cIdDio", "Empty (cIdDio).or.P_Dio(@cIdDio)","@!",})
  if gvodiodj=="D"
   AADD (aNiz, {"Odjeljenje (prazno-sva)", "cIdOdj", "Empty (cIdOdj).or.P_Odj(@cIdOdj)","@!",})
  endif
  AADD (aNiz, {"Radnik (prazno-svi)", "cIdRadnik", "Empty (cIdRadnik).or.P_Osob(@cIdRadnik)","@!",})
  AADD (aNiz, {"Vrste placanja(prazno-sve)", "cIdVrsteP", "Empty (cIdVrsteP).or.P_Osob(@cIdVrsteP)","@!",})
  if IsTigra()
  	AADD (aNiz, {"Placanje (G-gotovinsko,Z-ziralno,prazno-sve)", "cGotZir", "cGotZir$'GZ '","@!",})
  endif
  AADD (aNiz, {"Roba (prazno-sve)","cRoba",,"@!S30",})
  AADD (aNiz, {"Izvjestaj se pravi od datuma","dDat0",,,})
  AADD (aNiz, {"                   do datuma","dDat1",,,})
  AADD(aNiz,  {"Prikazi robe D/N",            "cPrikRobe",,"@!",})
  DO WHILE .t.
    IF !VarEdit( aNiz, 9,5,21,74,;
               'USLOVI ZA IZVJESTAJ "REALIZACIJA DIJELA OBJEKTA"',;
               "B1")
      CLOSERET
    ENDIF
    aUsl1:=Parsiraj(cRoba,"idroba")
    if aUsl1<>NIL.and.dDat0<=dDat1
      exit
    elseif aUsl1==NIL
      Msg("Kriterij za robu nije korektno postavljen!")
    else
      Msg("'Datum do' ne smije biti stariji nego 'datum od'!")
    endif
  ENDDO

  // pravljenje izvjestaja
  SELECT DOKS
  set order to 2    // "DOKSi2", "IdVd+DTOS (Datum)+Smjena"

  EOF CRET

  START PRINT CRET
  ZagFirma()
  ?
  ? PADC("REALIZACIJA DIJELA OBJEKTA",40)
  ? PADC ("NA DAN "+FormDat1(DATE()), 40)
  ? PADC("-------------------------------------",40)
  ? "PROD.MJESTO: "+cidpos+"-"+IF(EMPTY(cIdPos),"SVA",Ocitaj (F_KASE, cIdPos,"Naz"))
  if gvodiodj=="D"
    ? "ODJELJENJA : "+IF(EMPTY(cIdOdj),"SVA",Ocitaj (F_ODJ, cIdOdj,"Naz"))
  endif
  ? "RADNIK     : "+IF(EMPTY(cIdRadnik),"svi",;
                       cIdRadnik+"-"+RTRIM(Ocitaj(F_OSOB,cIdRadnik,"naz")))
  ? "VR.PLACANJA: "+IF(EMPTY(cIdVrsteP),"sve",RTRIM(cIdVrsteP))
  if IsTigra()
  	? "PLACANJE   : "+IF(cGotZir=="Z","ziralno",IF(empty(cGotZir),"gotovinsko i ziralno","gotovinsko"))
  endif
  ? "PERIOD     : "+FormDat1(dDat0)+" - "+FormDat1(dDat1)

  DioIzvuci (VD_PRR)
  DioIzvuci (VD_RN)

  // stampa izvjestaja
  //////////////////////
  // 1) Rekapitulacija po kasama i vrstama placanja
  ?
  ? PADC ("REKAPITULACIJA PO KASAMA", 40)
  ? PADC ("--------------------------", 40)
  ?
  nTotal := 0
  nTotal2 := 0
  nTotal3 := 0
  SELECT POM
  set order to 1
  Go Top
  do While !Eof()
    _IdDio := POM->IdDio
    IF Empty (cIdDio)
      SELECT DIO
      HSEEK (_IdDio)
      ? REPL ("-", 40)
      ? DIO->Naz
      ? REPL ("-", 40)
      SELECT POM
    EndIF
    nTotDio := 0
    nTotDio2 := 0
    nTotDio3 := 0
    do While !Eof() .and. POM->IdDio==_IdDio
      _IdPos := POM->IdPos
      SELECT KASE
      HSEEK _IdPos
      ? space(1)+_idpos+":", + KASE->Naz
      ? SPACE (5) + REPL ("-", 35)
      SELECT POM
      nTotPos := 0
      nTotPos2 := 0
      nTotPos3 := 0
      do While !Eof() .and. POM->(IdDio+IdPos)==(_IdDio+_IdPos)
        nTotVP := 0
        nTotVP2 := 0
        nTotVP3 := 0
        _IdVrsteP := POM->IdVrsteP
        SELECT VRSTEP
        HSEEK _IdVrsteP
        ? SPACE (5) + PADR (VRSTEP->Naz, 20)
        SELECT POM
        do While !Eof() .and. POM->(IdDio+IdPos+IdVrsteP)==(_IdDio+_IdPos+_IdVrsteP)
          nTotVP += POM->Iznos
          nTotVP2 += POM->Iznos2
          nTotVP3 += POM->Iznos3
          SKIP
        EndDO
        ?? STR (nTotVP, 15, 2)
        nTotPos += nTotVP
        nTotPos2 += nTotVP2
        nTotPos3 += nTotVP3
      EndDO
      ? SPACE (5)+REPL ("-", 35)
      ? SPACE (5)+PADR ("UKUPNO KASA "+_idpos, 20)+STR (nTotPos, 15, 2)
      ? SPACE (5)+REPL ("-", 35)
      if nTotPos2<>0
        ? PADL ("PARTICIPACIJA:", 20), STR (nTotPos2, 15, 2)
      endif
      if nTotPos3<>0
        ? PADL (NenapPop(), 20), STR (nTotPos3, 15, 2)
        ? PADL ("UKUPNO NAPLATA:", 20), STR (nTotPos-nTotPos3+nTotPos2, 15, 2)
      endif

      nTotDio += nTotPos
      nTotDio2 += nTotPos2
      nTotDio3 += nTotPos3
    EndDO
    ? REPL ("-", 40)
    ? PADC ("UKUPNO DIO OBJEKTA", 25)+STR (nTotDio, 15, 2)
    ? REPL ("-", 40)
    nTotal += nTotDio
    nTotal2 += nTotDio2
    nTotal2 += nTotDio3
  EndDO
  IF Empty (cIdDio)
    ? REPL ("=", 40)
    ? PADC ("UKUPNO OBJEKAT", 25)+STR (nTotal, 15, 2)
    if nTotal2<>0
        ? PADL ("PARTICIPACIJA:", 25), STR (nTotal2, 15, 2)
    endif
    if nTotPos3<>0
        ? PADL (NenapPop(), 25), STR (nTotal3, 15, 2)
        ? PADL ("UKUPNO NAPLATA:", 25), STR (nTotal-nTotal3+nTotal2, 15, 2)
    endif
    ? REPL ("=", 40)
  EndIF

  // 2) Rekapitulacija po radnicima i vrstama placanja
  ?
  ? PADC ("REKAPITULACIJA PO RADNICIMA", 40)
  ? PADC ("--------------------------", 40)
  ?
  nTotal := 0
  nTotal2 := 0
  nTotal3 := 0
  SELECT POM
  set order to 2
  Go Top
  do While !Eof()
    _IdDio := POM->IdDio
    IF Empty (cIdDio)
      SELECT DIO
      HSEEK (_IdDio)
      ? REPL ("-", 40)
      ? DIO->Naz
      ? REPL ("-", 40)
      SELECT POM
    EndIF
    nTotDio := 0
    nTotDio2 := 0
    nTotDio3 := 0
    DO While !Eof() .and. POM->IdDio==_IdDio
      _IdRadnik := POM->IdRadnik
      SELECT OSOB
      HSEEK _IdRadnik
      ? SPACE (5) + OSOB->Naz
      ? SPACE (5) + REPL ("-", 35)
      SELECT POM
      nTotRadnik := 0
      nTotRadn2 := 0
      nTotRadn3 := 0
      DO While !Eof() .and. POM->(IdDio+IdRadnik)==(_IdDio+_IdRadnik)
        nTotVP := 0
        nTotVP2 := 0
        nTotVP3 := 0
        _IdVrsteP := POM->IdVrsteP
        SELECT VRSTEP
        HSEEK _IdVrsteP
        ? SPACE (5) + PADR (VRSTEP->Naz, 20)
        SELECT POM
        DO While !Eof() .and. ;
              POM->(IdDio+IdRadnik+IdVrsteP)==(_IdDio+_IdRadnik+_IdVrsteP)
          nTotVP += POM->Iznos
          nTotVP2 += POM->Iznos2
          nTotVP3 += POM->Iznos3
          SKIP
        EndDO
        ?? STR (nTotVP, 15, 2)
        nTotRadnik += nTotVP
        nTotRadn2 += nTotVP2
        nTotRadn3 += nTotVP3
      EndDO
      ? SPACE (5)+REPL ("-", 35)
      ? SPACE (5)+PADR ("UKUPNO RADNIK", 20)+STR (nTotRadnik, 15, 2)
      ? SPACE (5)+REPL ("-", 35)
      nTotDio += nTotRadnik
      nTotDio2 += nTotRadn2
      nTotDio3 += nTotRadn3
    EndDO
    ? REPL ("-", 40)
    ? PADC ("UKUPNO DIO OBJEKTA", 25)+STR (nTotDio, 15, 2)
    ? REPL ("-", 40)
    nTotal += nTotDio
    nTotal2 += nTotDio2
    nTotal3 += nTotDio3
  EndDO
  IF Empty (cIdDio)
    ? REPL ("=", 40)
    ? PADC ("UKUPNO OBJEKAT", 25)+STR (nTotal, 15, 2)
    if nTotal2<>0
        ? PADL ("PARTICIPACIJA:", 25)+STR (nTotal2, 15, 2)
    endif
    if nTotal3<>0
        ? PADL (NenapPop(), 25)+STR (nTotal3, 15, 2)
        ? PADL ("UKUPNO NAPLATA:", 25), STR (nTotal-nTotal3+nTotal2, 15, 2)
    endif
    ? REPL ("=", 40)
  EndIF

  // 3) Rekapitulacija po vrstama placanja
  ?
  ? PADC ("REKAPITULACIJA PO VRSTAMA PLACANJA", 40)
  ? PADC ("--------------------------", 40)
  ?
  nTotal := 0
  nTotal2 := 0
  nTotal3 := 0
  SELECT POM
  set order to 3
  Go Top
  do While !Eof()
    _IdDio := POM->IdDio
    IF Empty (cIdDio)
      SELECT DIO
      HSEEK (_IdDio)
      ? REPL ("-", 40)
      ? DIO->Naz
      ? REPL ("-", 40)
      SELECT POM
    EndIF
    nTotDio := 0
    nTotDio2 := 0
    nTotDio3 := 0
    do While !Eof() .and. POM->IdDio==_IdDio
      _IdVrsteP := POM->IdVrsteP
      SELECT VRSTEP
      HSEEK _IdVrsteP
      ? SPACE (5) + PADR (VrsteP->Naz, 20)
      SELECT POM
      nTotVrsteP := 0
      nTotVrste2 := 0
      nTotVrste3 := 0
      do While !Eof() .and. POM->(IdDio+IdVrsteP)==(_IdDio+_IdVrsteP)
        nTotVrsteP += POM->Iznos
        nTotVrste2 += POM->Iznos2
        nTotVrste3 += POM->Iznos3
        SKIP
      EndDO
      ?? STR (nTotVrsteP, 15, 2)
      nTotDio += nTotVrsteP
      nTotDio2 += nTotVrste2
      nTotDio3 += nTotVrste3
    EndDO
    ? REPL ("-", 40)
    ? PADC ("UKUPNO DIO OBJEKTA", 25)+STR (nTotDio, 15, 2)
    ? REPL ("-", 40)
    nTotal += nTotDio
    nTotal2 += nTotDio2
    nTotal3 += nTotDio3
  EndDO
  IF Empty (cIdDio)
    ? REPL ("=", 40)
    ? PADC ("UKUPNO OBJEKAT", 25)+STR (nTotal, 15, 2)
    if nTotal2<>0
        ? PADL ("PARTICIPACIJA:", 25)+STR (nTotal2, 15, 2)
    endif
    if nTotal3<>0
        ? PADL (NenapPop(), 25)+STR (nTotal3, 15, 2)
        ? PADL ("UKUPNO NAPLATA:", 25), STR (nTotal-nTotal3+nTotal2, 15, 2)
    endif
    ? REPL ("=", 40)
  EndIF

  // 4) Rekapitulacija po odjeljenjima
  ?
  ? PADC ("REKAPITULACIJA PO ODJELJENJIMA", 40)
  ? PADC ("--------------------------", 40)
  ?
  nTotal := 0
  SELECT POM
  set order to 4
  Go Top
  do while !Eof()
    _IdDio := POM->IdDio
    IF Empty (cIdDio)
      SELECT DIO
      HSEEK (_IdDio)
      ? REPL ("-", 40)
      ? DIO->Naz
      ? REPL ("-", 40)
      SELECT POM
    EndIF
    nTotDio := 0
    do While !Eof() .and. POM->IdDio==_IdDio
      _IdOdj := POM->IdOdj
      SELECT ODJ
      HSEEK _IdOdj
      ? SPACE (5) + PADR (ODJ->Naz, 20)
      SELECT POM
      nTotOdj := 0
      do While !Eof() .and. POM->(IdDio+IdOdj)==(_IdDio+_IdOdj)
        nTotOdj += POM->Iznos
        SKIP
      EndDO
      ?? STR (nTotOdj, 15, 2)
      nTotDio += nTotOdj
    EndDO
    ? REPL ("-", 40)
    ? PADC ("UKUPNO DIO OBJEKTA", 25)+STR (nTotDio, 15, 2)
    ? REPL ("-", 40)
    nTotal += nTotDio
  EndDO
  IF Empty (cIdDio)
    ? REPL ("=", 40)
    ? PADC ("UKUPNO OBJEKAT", 25)+STR (nTotal, 15, 2)
    if nTotal2<>0
        ? PADL ("PARTICIPACIJA:", 25)+STR (nTotal2, 15, 2)
    endif
    if nTotal3<>0
        ? PADL (NenapPop(), 25)+STR (nTotal3, 15, 2)
        ? PADL ("UKUPNO NAPLATA:", 25), STR (nTotal-nTotal3+nTotal2, 15, 2)
    endif
    ? REPL ("=", 40)
  EndIF

  // 5) Rekapitulacija po robama
  IF cPrikRobe == "D"
    ?
    ? PADC ("REKAPITULACIJA PO ODJELJENJIMA", 40)
    ? PADC ("--------------------------", 40)
    ?
    SELECT POM
    set order to 5
    go top
    WHILE ! eof()
      _IdDio := POM->IdDio
      IF Empty (cIdDio)
        SELECT DIO
        HSEEK _IdDio
        ? DIO->Naz
        ? REPL ("-", 40)
        SELECT POM
      EndIF
      nTotDio := 0
      nTotDio2 := 0
      nTotDio3 := 0
      do WHILE !EOF() .and. POM->IdDio==_IdDio
        _IdRoba := POM->IdRoba
        SELECT ROBA
        HSEEK _IdRoba
        ? SPACE (5) + _IdRoba, LEFT (ROBA->Naz, 28), "("+ROBA->Jmj+")"
        SELECT POM
        nRobaKol := 0
        nRobaIzn := 0
        nSetova  := 0
        do WHILE !Eof() .and. POM->(IdDio+IdRoba)==(_IdDio+_IdRoba)
          _IdCijena := POM->IdCijena
          nKol := 0
          nIzn := 0
          nIzn2 := 0
          nIzn3 := 0
          do While !Eof() .and. ;
                POM->(IdDio+IdRoba+IdCijena)==(_IdDio+_IdRoba+_IdCijena)
            nKol += POM->Kolicina
            nIzn += POM->Iznos
            nIzn2 += POM->Iznos2
            nIzn3 += POM->Iznos3
            Skip
          EndDO
          ? SPACE (10)+_IdCijena, STR (nKol, 12, 3), STR (nIzn, 15, 2)
          nSetova ++
          nRobaKol += nKol
          nRobaIzn += nIzn
          nRobaIzn2 += nIzn2
          nRobaIzn3 += nIzn3
          SELECT POM
        END
        nTotDio += nRobaIzn
        nTotDio2 += nRobaIzn2
        nTotDio3 += nRobaIzn3
        IF nSetova > 1
          ? PADL ("Ukupno roba:", 16), Str (nRobaKol, 12, 3), ;
            STR (nRobaIzn, 15, 2)
        EndIF
      END
      ? REPL ("=", 40)
      ? PADC ("UKUPNO DIO OBJEKTA", 24), Str (nTotDio, 15, 2)
      ? REPL ("=", 40)
      nTotal += nTotDio
      nTotal2 += nTotDio2
      nTotal3 += nTotDio3
    END
    IF Empty (cIdDio)
      ? REPL ("*", 40)
      ? PADC ("UKUPNO OBJEKAT", 24), Str (nTotDio, 15, 2)
      if nTotDio2<>0
       ? PADL ("PARTICIPACIJA:", 29), STR (nTotDio2, 10, 2)
      endif
      if nTotDio3<>0
       ? PADL (NenapPop(), 29), STR (nTotDio3, 10, 2)
       ? PADL ("UKUPNO NAPLATA:", 29), STR (nTotDio-nTotDio3+nTotDio2, 10, 2)
      endif
      ? REPL ("*", 40)
    EndIF
  ENDIF
  END PRINT
CLOSERET
*}


/*! \fn OdjIzvuci(cIdVd)
 *  \brief Punjenje pomocne baze realizacijom odjeljenja
 */
 
function OdjIzvuci(cIdVd)
*{
SELECT DOKS
Seek cIdVd+DTOS(dDat0)
do While !Eof() .and. DOKS->IdVd==cIdVd .and. DOKS->Datum<=dDat1
  IF (Klevel>"0" .and. doks->idpos="X") .or. ;
     (DOKS->IdPos="X" .and. AllTrim (cIdPos)<>"X") .or. ;
     (! Empty (cIdPos) .and. DOKS->IdPos<>cIdPos)
    Skip; Loop
  EndIF

  SELECT POS
  Seek DOKS->(IdPos+IdVd+dtos(datum)+BrDok)
  do While !Eof() .and. POS->(IdPos+IdVd+dtos(datum)+BrDok)==DOKS->(IdPos+IdVd+dtos(datum)+BrDok)
    IF (!Empty (cIdOdj) .and. POS->IdOdj<>cIdOdj) .or.;
       (!Empty (cIdDio) .and. POS->IdDio<>cIdDio) .or.;
       !Tacno (aUsl1)
      Skip; Loop
    EndIF

    select roba; hseek pos->idroba
    select odj; hseek roba->idodj
    nNeplaca:=0
    if right(odj->naz,5)=="#1#0#"  // proba!!!
     nNeplaca:=pos->(Kolicina*Cijena)
    elseif right(odj->naz,6)=="#1#50#"
     nNeplaca:=pos->(Kolicina*Cijena)/2
    endif
    if gPopVar="P"; nNeplaca+=pos->(Kolicina*NCijena); endif

    SELECT POM; Hseek POS->(IdOdj+IdDio+IdPos+IdRoba+IdCijena)
    IF Found()
      Replace Kolicina WITH Kolicina+POS->Kolicina, ;
              Iznos    WITH Iznos+POS->Kolicina*POS->Cijena,;
              iznos3   with nNeplaca
      if gPopVar=="A"
             replace Iznos2   with pos->(ncijena)
      endif

    Else
      APPEND BLANK
      Replace IdOdj  WITH POS->IdOdj,   IdDio    WITH POS->IdDio, ;
              IdRoba WITH POS->IdRoba,  IdCijena WITH POS->IdCijena, ;
              IdPos  WITH DOKS->IdPos,  Kolicina WITH POS->Kolicina,;
              Iznos  WITH POS->Kolicina*POS->Cijena ,;
              iznos3 with iznos3+nNeplaca
      if gPopVar=="A"
              replace iznos2 with iznos2+pos->(ncijena)
      endif
    EndIF
    SELECT POS
    Skip
  EndDO
  SELECT DOKS;  Skip
EndDO
RETURN
*}


