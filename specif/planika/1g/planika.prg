#include "\cl\sigma\fmk\pos\pos.ch"

/*
 * ----------------------------------------------------------------
 *                                     Copyright Sigma-com software 
 * ----------------------------------------------------------------
 * $Source: c:/cvsroot/cl/sigma/fmk/pos/specif/planika/1g/planika.prg,v $
 * $Author: ernad $ 
 * $Revision: 1.10 $
 * $Log: planika.prg,v $
 * Revision 1.10  2002/07/15 07:06:57  ernad
 *
 *
 * debug izvjestaj planika/specif "stanje artikala po k1" - variable not found "NIZLAZA"
 *
 * Revision 1.9  2002/07/01 13:58:56  ernad
 *
 *
 * izvjestaj StanjePm nije valjao za gVrstaRs=="S" (prebacen da je isti kao za kasu "A")
 *
 * Revision 1.8  2002/06/25 09:34:24  ernad
 *
 *
 * /cl/sigma/fmk/svi/specif.prg ... generacija integralne dokumentacije sa posebnim osvrtom na specif Parametre
 *
 * Revision 1.7  2002/06/24 16:11:53  ernad
 *
 *
 * planika - uvodjenje izvjestaja 98-reklamacija, izvjestaj planika/promet po vrstama placanja, debug
 *
 * Revision 1.6  2002/06/17 13:02:31  sasa
 * no message
 *
 * Revision 1.5  2002/06/17 11:44:44  sasa
 * no message
 *
 *
 */
 
/*! \defgroup Planika Specificne nadogradnje za korisnika Planika
 *  @{
 *  @}
 */
 
/*! \fn StanjeK1(cDat,cSmjena)
 *  \brief Pravljenje izvjestaja stanja prodajnog mjesta
 *  \param cDat
 *  \param cSmjena
 *  \ingroup Planika
 */

* function StanjeK1(cDat,cSmjena)
*{

function StanjeK1
parameters cDat,cSmjena

local nStanje
local nSign:=1
local cSt
local nVrijednost
local nCijena:=0
local cRSdbf
local cVrstaRs

private cIdDio:=SPACE(2)
private cIdOdj:=SPACE(2)
private cRoba:=SPACE(60)
private cLM:=""
private nSir:=40
private nRob:=29
private cNule:="N"
private cUkupno:="N"
private cMink:="N"
private cZaduzuje:="R"

if pcount()==0
	fZaklj:=.f.
	private cDat:=gDatum
	private cSmjena:=" "
else
	fZaklj:=.t.
endif

cVrstaRs:="A"

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
  	aUsl1:={}
else
	// maska za postavljanje uslova
    	cIdodj:="R "
  	cIdPos:=gIdPos
  	aNiz:={}
  	if cVrstaRs<>"K"
    		AADD(aNiz,{"Prodajno mjesto (prazno-svi)","cIdPos","cidpos='X'.or.empty(cIdPos).or. P_Kase(@cIdPos)","@!",})
  	endif
  	if gVodiOdj=="D"
   		AADD(aNiz,{"Roba/Sirovine","cIdOdj", "cidodj $ 'R S '","@!",})
  	endif
  	AADD(aNiz,{"Artikli  (prazno-svi)","cRoba",,"@!S30",})
  	AADD(aNiz,{"Izvjestaj se pravi za datum","cDat",,,})
  	if gVSmjene=="D"
    		AADD(aNiz,{"Smjena","cSmjena",,,})
  	endif
  	AADD(aNiz,{"Stampati artikle sa stanjem 0", "cNule","cNule$'DN'","@!",})
  	AADD(aNiz,{"Prikaz kolone ukupno D/N ", "cUkupno","cUkupno$'DN'","@!",})
  	AADD(aNiz,{"Prikaz samo kriticnih zaliha (D/N/O) ?", "cMinK","cMinK$'DNO'","@!",})
  	while .t.
    		if !VarEdit(aNiz,10,5,13+LEN(aNiz),74,'USLOVI ZA IZVJESTAJ "STANJE ODJELJENJA"',"B1")
      			CLOSERET
    		endif
    		aUsl1:=Parsiraj(cRoba,"IdRoba","C")
    		if aUsl1<>nil
      			exit
    		else
      			Msg("Kriterij za artikal nije korektno postavljen!")
    		endif
  	enddo
endif

if cMink=="O"
	cNule:="D"
endif

cU:=R_U 
cI:=R_I
cRSdbf:="ROBA"

if cIdOdj="S "
	cZaduzuje:="S"
  	cU:=S_U 
	cI:=S_I
	cRSdbf:="SIROV"
endif

if cVrstaRs=="S"
	cLM:=SPACE(5)
	nSir:=80 
	nRob:=40
endif


SELECT pos

cFilt:=""
cFilt:="IDPOS=='"+cIdPos+"'"

if LEN(aUsl1)>0
	if EMPTY(cFilt)
    		cFilt:=aUsl1
  	else
    		cFilt+=".and."+aUsl1
  	endif
endif

index on IdPos+Robak1()+idroba+DTOS(Datum) to (KUMPATH+"k1pos") for &cFilt
go top


// pravljenje izvjestaja

if !fZaklj
	Zagl(cIdOdj, cDat, cVrstaRs)
endif

Podvuci(cVrstaRs)

nVrijednost:=0
nKolicina:=0

do while !eof()
	cK1:=Robak1()
	nK1:=0
	nKK1:=0
	do while !eof().and.RobaK1()=ck1
 		cIdRoba := POS->IdRoba
 		// pocetno stanje - stanje do
 		nSlogova:=0
 		nStanje := 0
 		nPstanje := 0
 		nUlaz := nIzlaz := 0
 		do while !eof().and.RobaK1()=ck1.and.POS->IdRoba==cIdRoba.and.(POS->Datum<cDat.or.(!Empty(cSmjena).and.POS->Datum==cDat.and.POS->Smjena<cSmjena))
   			if !Empty(cIdDio).and.POS->IdDio<>cIdDio
     				SKIP
				LOOP
   			endif
   			if (Klevel>"0".and.pos->idpos="X").or.(!empty(cIdPos).and.pos->IdPos<>cIdPos)
     				SKIP
				LOOP
   			endif
   			if cZaduzuje=="S".and.pos->idvd$"42#01"
       				skip
				loop
				// racuni za sirovine - zdravo
   			endif
   			if cZaduzuje=="R".and.pos->idvd=="96"
      				skip
				loop
				// otpremnice za robu - zdravo
   			endif
			++nSlogova
   			if POS->idvd $ DOK_ULAZA
     				nPstanje+=POS->Kolicina
   			elseif POS->idvd $ "IN#NI#"+DOK_IZLAZA
     				do case
       					case POS->IdVd == "IN"
         					nPstanje-=(POS->Kolicina-POS->Kol2)
       					case POS->IdVd == VD_NIV
						nPstanje-=0
       					otherwise 
         					nPstanje-=POS->Kolicina

     				endcase
   			endif
   			SKIP
 		enddo

  		// realizacija specificiranog datuma/smjene
 
 		do while !eof().and.POS->IdRoba==cIdRoba .and. Robak1()=ck1 .and.(POS->Datum == cDat .or.(!Empty (cSmjena) .and. POS->Datum==cDat .and. POS->Smjena<cSmjena))

   			if !Empty(cIdDio).and.POS->IdDio<>cIdDio
     				SKIP
				LOOP
   			endif
   			if cZaduzuje=="S".and.pos->idvd $ "42#01"
       				skip
				loop // racuni za sirovine - zdravo
   			endif
   			if cZaduzuje=="R" .and. pos->idvd=="96"
      				skip
				loop   // otpremnice za robu - zdravo
   			endif
   			if (Klevel>"0".and.pos->idpos="X").or.(!empty(cIdPos) .and. pos->IdPos <> cIdPos)
     				skip
				loop
   			endif
   			++nSlogova
   			IF POS->idvd $ DOK_ULAZA
     				nUlaz += POS->Kolicina
   			ELSEIF POS->idvd $  "IN#NI#"+DOK_IZLAZA
     				DO Case
       					Case POS->IdVd == "IN"
         					nIzlaz+=(POS->Kolicina-POS->Kol2)
       					Case POS->IdVd == VD_NIV
						nIzlaz+=0
       					Otherwise  
						// 42#01
         					nIzlaz+=POS->Kolicina
     				EndCase
   			ENDIF
   			SKIP
 		enddo
 		// stampaj
  		nStanje := nPstanje + nUlaz - nIzlaz
 		if Round(nStanje, 4)<>0 .or. cNule=="D" .and. !(nPstanje==0.and.nUlaz==0.and.nIzlaz==0)
   			SELECT (cRSdbf)
			HSEEK cIdRoba
   			if (fieldpos("MINK"))<>0
      				nMink:=roba->mink
   			else
      				nMink:=0
   			endif
   			if ((cMink<>"D" .and. (cNule=="D" .or. round(nStanje,4)<>0)).or.(cMink=="D" .and. nMink<>0 .and. (nStanje-nMink)<0)).and.!(cMink=="O" .and. nMink==0 .and. round(nStanje,4)==0)
     				nCijena1:=cijena1
     				? cLM+cIdRoba,PADR (Naz, nRob) + " "
          			// VRIJEDNOST = TRENUTNA CIJENA U SIFRARNIKU * STANJE KOMADA
     				nVrijednost+=nStanje * nCijena1
     				nK1+=nStanje*nCijena1
     				SELECT POS
     				if cVrstaRs<>"S"
       					?
     				endif
     				?? STR (nPstanje, 9, 3)
     				if Round(nUlaz, 4) <> 0
       					?? " "+STR (nUlaz, 9, 3)
     				else
       					?? SPACE (10)
     				endif
     				if Round(nIzlaz, 4) <> 0
       					?? " "+STR (nIzlaz, 9, 3)
     				else
       					?? SPACE (10)
     				endif
     				?? " "+STR (nStanje, 10, 3)
     				if cVrstaRs=="S" .or. cUkupno=="D"
       					?? " " + STR (nStanje*nCijena1, 15, 3)
     				endif
     				if cMink<>"N" .and. nMink>0
       					? PADR(IF(cMink=="O".and.nMink<>0.and.(nStanje-nMink)<0,"*KRITICNO STANJE !*",""),19)
       					?? "  min.kolic:"+STR(nMink,9,3)
     				endif
     				? padl("    cijena/iznos:",16), str(nCijena1,10,2), str(nCijena1*nStanje,12,2)
   			endif
 		endif
 		SELECT POS

 		// Odvrti viska slogove
 		do while !eof() .and. POS->IdRoba==cIdRoba  // preko zadanog datuma
   			SKIP
 		enddo
 		if !((cRSDBF)->k2='X')
    			nKK1+=nStanje
 		endif
	enddo  // ck1

	Podvuci(cVrstaRs)
  	? padr("Grupa:"+cK1,24),str(nK1,15,3)
  	? padl("kolicina:",24),str(nKK1,15,0)
	Podvuci(cVrstaRs)
  	nKolicina+=nKK1
enddo

if cVrstaRs <> "S"
	Podvuci(cVrstaRs)
  	? "Ukupno stanje zaduzenja:", STR (nVrijednost, 15, 3)
  	? padl("kolicina:",24),str(nKolicina,15,0)
	Podvuci(cVrstaRs)
endif

if fZaklj
	END PRINT
endif

if cVrstaRs <> "S"
	PaperFeed()
endif
if !fZaklj
  	END PRINT
endif
CLOSERET
*}



/*! \fn RobaK1()
 *  \brief Vrati vrijednost polja roba k1 
 */
 
function RobaK1()
*{
select roba
hseek pos->idroba
select pos
return roba->k1
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
