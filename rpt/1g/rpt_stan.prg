#include "\cl\sigma\fmk\pos\pos.ch"

/*
 * ----------------------------------------------------------------
 *                                     Copyright Sigma-com software 
 * ----------------------------------------------------------------
 * $Source: c:/cvsroot/cl/sigma/fmk/pos/rpt/1g/rpt_stan.prg,v $
 * $Author: mirsad $ 
 * $Revision: 1.9 $
 * $Log: rpt_stan.prg,v $
 * Revision 1.9  2003/06/28 15:05:36  mirsad
 * omogucen ispis naziva firme na izvjestajima
 *
 * Revision 1.8  2002/08/05 11:03:58  ernad
 *
 *
 * Fin/SQLLog funkcije, debug bug RJ/KUMPATH
 *
 * Revision 1.7  2002/07/01 13:58:56  ernad
 *
 *
 * izvjestaj StanjePm nije valjao za gVrstaRs=="S" (prebacen da je isti kao za kasu "A")
 *
 * Revision 1.6  2002/06/30 20:28:44  ernad
 *
 *
 *
 * pos meni za odabir firme /MNU_INI
 *
 * Revision 1.5  2002/06/24 16:11:53  ernad
 *
 *
 * planika - uvodjenje izvjestaja 98-reklamacija, izvjestaj planika/promet po vrstama placanja, debug
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

/*! \file fmk/pos/rpt/1g/rpt_stan.prg
 *  \brief Izvjestaj: stanje odjeljenja/dijela objekta
 */

/*! \fn Stanje(cDat,cSmjena)
 *  \param cDat
 *  \param cSmjena
 *  \brief Izvjestaj: stanje odjeljenja/dijela objekta
 */

*function Stanje(cDat,cSmjena)
*{
function Stanje
parameters cDat, cSmjena

local nStanje
local nSign := 1
local cSt
local nVrijednost
local nCijena := 0
local cRSdbf
local cVrstaRs

private cIdDio := SPACE (2)
private cIdOdj := SPACE (2)
private cRoba:=SPACE(60)
private cLM:=""
private nSir := 40
private nRob := 29
private cNule:="N"


fZaklj := IIF (pcount()==0, .F., .T.)
IF !fZaklj
  PRIVATE cDat:=gDatum, cSmjena := " "
EndIF

cVrstaRs:=gVrstaRs

// ovo je zakrpa .... ali da proradi
if (gModul=="TOPS" .and. cVrstaRs=="S")
	cVrstaRs:="A"
endif

O_KASE
O_ODJ
O_DIO

if gSifK=="D"
 O_SIFK
 O_SIFV
endif

O_ROBA
O_SIROV
O_POS

cIdPos:=gIdPos

if fZaklj
  // kod zakljucenja smjene
  aUsl1 := ".t."
  if gModul=="HOPS"
    cIdDio := gIdDio
  endif 

else

// maska za postavljanje uslova
///////////////////////////////
if (gColleg=="D" .and. Klevel=="0")
	cIdPos:=space(2)
else
	cIdPos := gIdPos
endif

aNiz := {}
IF cVrstaRs<>"K"
    AADD (aNiz, { "Prodajno mjesto (prazno-svi)", "cIdPos", "cidpos='X'.or.empty(cIdPos).or. P_Kase(@cIdPos)","@!",})
ENDIF

if gvodiodj=="D"
    AADD(aNiz,{"Odjeljenje (prazno-sva)","cIdOdj", "Empty (cIdOdj).or.P_Odj(@cIdOdj)","@!",})
endif
  
if gModul=="HOPS"
    IF gPostDO=="D"
      AADD (aNiz, {"Dio objekta","cIdDio", "Empty (cIdDio).or.P_Dio(@cIdDio)","@!",})
    EndIF
endif

AADD (aNiz, {"Artikli  (prazno-svi)","cRoba",,"@!S30",})
AADD (aNiz, {"Izvjestaj se pravi za datum","cDat",,,})

IF gVSmjene=="D"
    AADD (aNiz, {"Smjena","cSmjena",,,})
endif

AADD (aNiz, {"Stampati artikle sa stanjem 0", "cNule","cNule$'DN'","@!",})
do while .t.
    IF !VarEdit(aNiz,10,5,21,74,'USLOVI ZA IZVJESTAJ "STANJE ODJELJENJA"',"B1")
      CLOSERET
    ENDIF
    aUsl1:=Parsiraj(cRoba,"IdRoba","C")
    if aUsl1<>NIL
      exit
    else
      Msg("Kriterij za artikal nije korektno postavljen!")
    endif
EndDO

EndIF

private cZaduzuje:="R"
IF !Empty (cIdOdj)
  SELECT ODJ
  HSEEK cIdOdj
  IF Zaduzuje == "S"
    cU := S_U
    cI := S_I
    cRSdbf := "SIROV"
    cZaduzuje:="S"
  Else
    cU := R_U
    cI := R_I
    cRSdbf := "ROBA"
    cZaduzuje:="R"
  EndIF
EndIF
IF cVrstaRs=="S"
  cLM := SPACE (5)
  nSir := 80
  nRob := 40
EndIF

// pravljenje izvjestaja
////////////////////////
IF ! fZaklj
  Zagl(cIdOdj, cDat, cVrstaRs)
EndIF
IF !empty(cIdOdj)
  Podvuci(cVrstaRs)
EndIF

SELECT POS
set order to 2   // ("2", "IdOdj+idroba+DTOS(Datum)", KUMPATH+"POS")
IF !(aUsl1==".t.")
  SET FILTER TO &aUsl1
ENDIF

seek cIdOdj
EOF CRET

xIdOdj := "??"
do while !eof()
  IF !empty(cIdOdj) .and. POS->IdOdj<>cIdOdj
    Exit
  endif
  nStanje := 0
  nVrijednost := 0
  _IdOdj := POS->IdOdj
  IF empty(cIdOdj) .and. _IdOdj<>xIdOdj
    IF fZaklj
      Zagl(_IdOdj, nil, cVrstaRs)
    EndIF
    Podvuci(cVrstaRs)
    xIdOdj := _IdOdj
    SELECT ODJ
    HSEEK _IdOdj
    ? cLM+Id+"-"+Naz
    Podvuci(cVrstaRs)
    IF Zaduzuje == "S"
      cZaduzuje:="S"
      cU := S_U
      cI := S_I
      cRSdbf := "SIROV"
    Else
      cZaduzuje:="R"
      cU := R_U
      cI := R_I
      cRSdbf := "ROBA"
    EndIF
    SELECT POS
  EndIF

  do while !Eof() .and. POS->IdOdj==_IdOdj
    nStanje := 0
    nVrijednost := 0
    nPstanje := 0
    nUlaz := nIzlaz := 0
    cIdRoba := POS->IdRoba
    //
    //pocetno stanje - stanje do
    //
    do While !Eof() .and. POS->IdOdj==_IdOdj .and. POS->IdRoba==cIdRoba.and.(POS->Datum < cDat.or.(!Empty (cSmjena) .and. POS->Datum==cDat .and. POS->Smjena<cSmjena))
      IF !Empty (cIdDio) .and. POS->IdDio <> cIdDio
        SKIP
	LOOP
      EndIF
      IF (Klevel>"0".and.pos->idpos="X").or.(!empty(cIdPos).and.IdPos<>cIdPos)
//         (POS->IdPos="X" .and. AllTrim (cIdPos)<>"X") .or. ;   // ?MS
        skip
	loop
      EndIF
      if (cZaduzuje=="R".and.pos->idvd=="96").or.(cZaduzuje=="S".and.pos->idvd $ "42#01")
         skip
	 loop  //preskoci
      endif
      //
      if POS->idvd $ "16#00"
        nPstanje += POS->Kolicina
        nVrijednost += POS->Kolicina * POS->Cijena
      elseif POS->idvd $ "IN#NI"+DOK_IZLAZA
        do case
          case POS->IdVd == "IN"
            nPstanje -= (POS->Kolicina-POS->Kol2)
            nVrijednost -= (POS->Kol2-POS->Kolicina) * POS->Cijena
          case POS->IdVd == "NI"
            // ne mijenja kolicinu
            nVrijednost := POS->Kolicina * POS->Cijena
          otherwise
              nPstanje -= POS->Kolicina
              nVrijednost -= POS->Kolicina * POS->Cijena
        endCase
      endif
      SKIP
    EndDO
    //
    //utrosak specificiranog datuma/smjene
    //
    DO While !eof() .and. POS->IdOdj==_IdOdj .and. POS->IdRoba==cIdRoba .and. (POS->Datum==cDat .or. (!empty(cSmjena) .and. POS->Datum==cDat .and. POS->Smjena<cSmjena))
      IF !empty(cIdDio).and.POS->IdDio<>cIdDio
        SKIP
	LOOP
      EndIF
      IF (Klevel>"0".and.pos->idpos="X").or.(!empty(cIdPos).and.IdPos<>cIdPos)
//         (POS->IdPos="X" .and. AllTrim (cIdPos)<>"X") .or. ;  // ?MS
        skip
	loop
      EndIF
      //

      if cZaduzuje=="S" .and. pos->idvd $ "42#01"
		skip
		loop  // racuni za sirovine - zdravo
      endif
      if cZaduzuje=="R" .and. pos->idvd=="96"
		skip
		loop   // otpremnice za robu - zdravo
      endif

      IF POS->idvd $ "16#00"
        nUlaz += POS->Kolicina
        nVrijednost += POS->Kolicina * POS->Cijena
      ELSEIF POS->idvd $  "IN#NI#"+DOK_IZLAZA
        DO Case
          case POS->IdVd == "IN"
            nIzlaz += (POS->Kolicina-POS->Kol2)
            nVrijednost -= (POS->Kol2-POS->Kolicina) * POS->Cijena
          case POS->IdVd == "NI"
            // ne mijenja kolicinu
            nVrijednost := POS->Kolicina * POS->Cijena
          otherwise
            nIzlaz += POS->Kolicina
            nVrijednost -= POS->Kolicina * POS->Cijena
        endCase
      ENDIF
      SKIP
    enddo
    //
    //stampaj
    //
    nStanje := nPstanje + nUlaz - nIzlaz
    IF Round(nStanje, 4)<>0 .or. cNule=="D"
      SELECT (cRSdbf)
      HSEEK cIdRoba
      ? cLM+cIdRoba,PADR (Naz, nRob) + " "
      //
      SELECT POS
      IF cVrstaRs<>"S"
        ?
      EndIF
      ?? STR (nPstanje, 9, 3)
      IF Round (nUlaz, 4) <> 0
        ?? " "+STR (nUlaz, 9, 3)
      ELSE
        ?? SPACE (10)
      ENDIF
      IF Round (nIzlaz, 4) <> 0
        ?? " "+STR (nIzlaz, 9, 3)
      ELSE
        ?? SPACE (10)
      ENDIF
      ?? " "+STR (nStanje, 10, 3)
      IF cVrstaRs=="S"
        ?? " " + STR (nVrijednost, 15, 3)
      EndIF
    EndIF

    do while (!EOF() .and. POS->IdOdj==_IdOdj .and. POS->IdRoba==cIdRoba)
      SKIP
    enddo
  enddo

  IF fZaklj
    PaperFeed()
    END PRINT
  EndIF
enddo

IF !fZaklj
 IF cVrstaRs <> "S"
   PaperFeed ()
  EndIF
  END PRINT
EndIF
CLOSERET

return
*}


/*! \fn Podvuci(cVrstaRs)
 *  \brief Podvlaci red u izvjestaju stanje odjeljenja/dijela objekta
 */
 
static function Podvuci(cVrstaRs)
*{
IF cVrstaRs=="S"
  ? cLM+REPL ("-", 10), REPL ("-", nRob) + " "
Else
  ?
EndIF
?? REPL ("-",9), REPL ("-",9), REPL ("-",9), REPL ("-",10)
IF cVrstaRs == "S"
  ?? " "+REPLICATE ("-", 15)
ENDIF
return
*}


/*! \fn Zagl(cIdOdj, dDat, cVrstaRs)
 *  \brief Ispis zaglavlja izvjestaja stanje odjeljenja/dijela objekta
 */

static function Zagl(cIdOdj, dDat, cVrstaRs)
*{

if (dDat==nil)
  dDat:=gDatum
endif

START PRINT CRET

ZagFirma()

P_10CPI
? PADC("STANJE ODJELJENJA NA DAN "+FormDat1(dDat),nSir)
? PADC("-----------------------------------",nSir)

IF cVrstaRs <> "K"
  ? cLM+"Prod. mjesto:"+IIF (Empty(cIdPos),"SVE",Ocitaj(F_KASE,cIdPos,"Naz"))
ENDIF
if gvodiodj=="D"
  ? cLM+"Odjeljenje : "+ cIdOdj+"-"+RTRIM(Ocitaj(F_ODJ, cIdOdj,"naz"))
endif
if gModul=="HOPS"
  IF gPostDO == "D"
    ? cLM+"Dio objekta: "+ IIF (Empty(cIdDio), "SVI", cIdDio+"-"+RTRIM(Ocitaj(F_DIO, cIdDio,"naz")))
  EndIF
endif 
? cLM+"Artikal    : "+IF(EMPTY(cRoba),"SVI",RTRIM(cRoba))
?
IF cVrstaRs=="S"
  P_COND
EndIF
? cLM+PADR ("Sifra", 10), PADR ("Naziv artikla", nRob) + " "
IF cVrstaRs<>"S"
  ? cLM
EndIF
?? "P.stanje ", PADC ("Ulaz", 9), PADC ("Izlaz", 9), PADC ("Stanje", 10)
IF cVrstaRs == "S"
   ?? " " + PADC ("Vrijednost", 15)
Else
   ? cLM
ENDIF
return
*}
