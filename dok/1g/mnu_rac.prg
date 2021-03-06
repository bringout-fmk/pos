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
 

/*! \fn Narudzba()
 *  \brief
 */
 
function Narudzba()
*{

SETKXLAT("'","-") 

if gModul=="HOPS"
	NarudzbaH()
else
	NarudzbaT()
endif

set key "'" to
return
*}

/*! \fn NarudzbaH()
 *  \brief
 */
function NarudzbaH()
*{

private Opc:={}
private opcexe:={}
private Izbor

O_Nar()  

if gRadniRac=="D"
	AADD(opc,"1. dodaj na racun        ")
	AADD(opcexe, {|| DodajNaRacun() })
	AADD(opc,"2. otvori novi racun ")
	AADD(opcexe, {|| NoviRacun() })
	Izbor:=1
	Menu_SC("nar")
else
	// ne koristi radne racune - ide drito
	SELECT _PRIPR
  	if RecCount2()<>0 .and. !Empty(BrDok)
    		DodajNaRacun (_PRIPR->BrDok)
  	else
    		NoviRacun()
  	endif
endif

if gRadniRac=="D"
	// ako se koriste radni racuni, po svakom zavrsetku unosa radnih racuna
	Trebovanja()
endif

return
*}


/*! \fn NarudzbaT()
 *  \brief 
 */
function NarudzbaT()
*{
O_Nar()

SELECT _PRIPR

if reccount2()<>0 .and. !empty(BrDok)
	DodajNaRacun(_pripr->brdok)
else
	NoviRacun()
endif

set key "'" to
CLOSERET
*}


/*! \fn DodajNaRacun(cBrojRn)
 *  \brief
 *  \param cBrojRn
 */
 
function DodajNaRacun(cBrojRn)
*{
set cursor on

if cBrojRn==nil
	cBrojRn:=SPACE(6)
else
	cBrojRn:=cBrojRn
endif

if gModul=="HOPS"
	if gRadniRac=="D"
		set cursor on
    		Box(, 2, 40)
    		// unesi broj racuna
    		@ m_x+1,m_y+3 SAY "Broj radnog racuna:" GET cBrojRn VALID P_RadniRac(@cBrojRn)
    		READ
    		BoxC()
    		if LASTKEY()==K_ESC
      			return
    		endif
  	endif
endif

UnesiNarudzbu(cBrojRn,_POS->Sto)

return
*}


/*! \fn NoviRacun()
 *  \brief
 */
 
function NoviRacun()
*{

local cBrojRn
local cBr2 
local cSto:=SPACE(3)
local dx:=3

SELECT _POS
set cursor on
cBrojRn:=_POS->(NarBrDok (gIdPos, VD_RN))

if gModul="HOPS"
	if gBrojSto $ "DN"
		set cursor on
  		if gRadniRac=="D"
    			Box(,6,60)
    			@ m_x+1,m_y+4  SAY "Radni racun br. "
    			@ ROW(),COL() SAY " "+ALLTRIM(cBrojRn)+" " COLOR INVERT
  		else
    			Box(,2,60)
			dx:=1
  		endif
  		@ m_x+dx,m_y+10 SAY "Sto broj:" GET cSto VALID IIF (gBrojSto=="N", .T., ! Empty (cSto))
  		READ
  		BoxC ()
  		if LASTKEY()==K_ESC
    			return
 		endif
	endif
else
	if gStolovi == "D"
		set cursor on
		Box(, 6, 40)
			cStZak := "N"
			@ m_x+2, m_y+10 SAY "Unesi broj stola:" GET cSto VALID (!Empty(cSto) .and. VAL(cSto) > 0) PICT "999"
  			read
			if LastKey()==K_ESC
				MsgBeep("Unos stola obavezan !")
				return
			endif
			// daj mi info o trenutnom stanju stola
			nStStanje := g_stanje_stola(VAL(cSto))
			@ m_x+4, m_y+2 SAY "Prethodno stanje stola:   " + ALLTRIM(STR(nStStanje)) + " KM"
  			if nStStanje > 0
				@ m_x+6, m_y+2 SAY "Zakljuciti prethodno stanje (D/N)?" GET cStZak VALID cStZak$"DN" PICT "@!"
			endif
			read
		BoxC()
		
		if LastKey() == K_ESC
			MsgBeep("Unos novih stavki prekinut !")
			return
		endif
		
		if cStZak == "D"
			zak_sto(VAL(cSto))
		endif
		
	endif
endif 

UnesiNarudzbu(cBrojRn, cSto)

return
*}


/*! \fn PreglRadni(cBrDok)
 *  \brief
 *  \param cBrDok
 */
 
function PreglRadni(cBrDok)
*{
// koristi se gDatum - uzima se da je to datum radnog racuna SIGURNO
local nPrev:=SELECT()

SELECT _POS
Set Order To 1
cFilt1:="IdPos+IdVd+dtos(datum)+BrDok+IdRadnik=="+cm2str(gIdPos+VD_RN+dtos(gDatum)+cBrDok+gIdRadnik)
Set Filter To &cFilt1
ImeKol:={ { "Roba",         {|| IdRoba+"-"+Left (RobaNaz, 30)},},;
          { "Kolicina",     {|| STR (Kolicina, 8, 2) }, },;
          { "Cijena",       {|| STR (Cijena, 8, 2) }, },;
          { "Iznos stavke", {|| STR (Kolicina*Cijena, 12, 2) }, };
        }
Kol:={1, 2, 3, 4}
GO TOP
ObjDBedit (, 20, 70,, " Radni racun "+ AllTrim (cBrDok), "", .T.)
SET FILTER TO

SELECT _PRIPR
return
*}


// pretraga sifre po nazivu uvijek
function sif_uv_naziv(cId)
*{
local nIdLen
// prvo prekontrolisati uslove

// parametar
if gSifUvPoNaz == "N"
	return
endif
// ako je uneseno prazno
if Empty(cId)
	return
endif

// ako je unesena puna duzina polja
if LEN(ALLTRIM(cID)) == 10
	return
endif

// ako postoji tacka na kraju
if RIGHT(ALLTRIM(cID),1) == "."
	return
endif

// dodaj tacku
cId := PADR( ALLTRIM(cId) + "." , 10)

return
*}



/*! \fn PostRoba(cId,dx,dy,lFlag)
 *  \brief
 *  \param cId
 *  \param dx
 *  \param dy
 *  \param lFlag
 */
 
function PostRoba(cId,dx,dy,lFlag)
*{

local aZabrane
local i
private ImeKol
private Kol

altd()
sif_uv_naziv(@cId)

UnSetSpecNar()
SETKEY(K_PGDN, bPrevDn)
SETKEY(K_PGUP, bPrevUp)

PrevId:= GetList[1]:original        // cId
ImeKol:={ { "Sifra"  , {|| id          }, "" },;
          { "Naziv"  , {|| naz         }, "" },;
          { "J.mj."  , {|| PADC(jmj,5) }, "" },;
          { "Cijena" , {|| &("ROBA->Cijena"+gIdCijena)}, "" };
        }
if roba->(fieldpos("K7"))<>0
	AADD (ImeKol,{ padc("K7",2 ), {|| k7 }, ""   })
endif
if roba->(fieldpos("BARKOD"))<>0
    	AADD (ImeKol,{ "BARKOD" , {|| barkod }, ""   })
endif

Kol:={}
for i:=1 to LEN(ImeKol)
	AADD(Kol,i)
next

if KLEVEL == L_PRODAVAC
	aZabrane:={K_CTRL_T,K_CTRL_N,K_F4,K_F2,K_CTRL_F9}
else
  	aZabrane:={}
endif

// TODO
BarKod(@cId)

Vrati:=PostojiSifra(F_ROBA, "ID", 10, 77, "Roba(artikli)", @cId, NIL, NIL, NIL, NIL, NIL, aZabrane)

if LASTKEY()==K_ESC
	cId:=PrevID
  	Vrati:=.f.
else
	@ m_x+dx,m_y+dy SAY PADR (AllTrim (ROBA->Naz)+" ("+AllTrim (ROBA->Jmj)+")",50)
  
	if roba->tip<>"T"
    		_Cijena:=&("ROBA->Cijena"+gIdCijena)
  	endif
endif

//kontrolisi cijenu pri unosu narudzbe
if IzFmkIni('TOPS','KontrolaCijenePriUnosu','N',KUMPATH)=='D'
	if ! _Cijena<>0
    		MsgBeep('Cijena 0.00, ne mogu napraviti racun !!!')
    		Vrati:=.f.
  	endif
endif

SETKEY (K_PGDN, {|| DummyProc()})
SETKEY (K_PGUP, {|| DummyProc()})
SetSpecNar()

if gDisplay=="D"
	Send2ComPort(CHR(10)+CHR(13))
	Send2ComPort(CHR(10)+CHR(13))
	Send2ComPort(CHR(30)+"ARTIKAL: " + ALLTRIM(roba->id) + CHR(22) + CHR(13))
	Send2ComPort(ALLTRIM(roba->naz))
endif

return Vrati
*}

/*! \fn ZakljuciRacun()
 *  \brief
 */
 
function ZakljuciRacun()
*{

if gModul=="HOPS"
	ZakljuciRH()
else
	ZakljuciRT()
endif
return
*}



/*! \fn ZakljuciRH()
 *  \brief Zakljucenje racuna u HOPS-u
 */
 
function ZakljuciRH()
*{

private opc:={}
private opcexe:={}
private Izbor:=1

if gRadniRac=="D"
	AADD(opc,"1. sve na jedan racun         ")
	AADD(opcexe,{|| SveNaJedan()})
	if (gRnSpecOpc == "D")
		AADD(opc,"2. zakljuci dio racuna    ")
		AADD(opcexe,{|| ZakljuciDio()})
		AADD(opc,"3. razdijeli racun        ")
   		AADD(opcexe,{|| RazdijeliRacun()})
	endif
	Menu_SC("zrac")
	return .f.
else
	O__PRIPR
    	if RecCount2()==0
      		CLOSERET
    	endif
    	if gDirZaklj=="D".or.Pitanje(,"Zakljuciti racun? D/N", "D")=="D"
        	SveNaJedan(_PRIPR->BrDok)
    	endif
endif
CLOSERET
*}

/*! \fn ZakljuciRT()
 *  \brief Zakljucenje racuna u TOPS-u
 */
 
function ZakljuciRT()
*{

O__PRIPR

if RecCount2()==0
	CLOSERET
endif

if gDirZaklj=="D" .or. Pitanje(,"Zakljuciti racun? D/N", "D")=="D"
	SveNaJedan(_PRIPR->BrDok)
endif

CLOSERET
*}


/*! \fn SveNaJedan(cRacBroj)
 *  \brief Zakljucenje sve na jedan racun
 *  \param cRacBroj - broj racuna
 */
 
function SveNaJedan(cRacBroj)
*{

if cRacBroj==nil
	cRacBroj:=SPACE(6)
else
	cRacBroj:=cRacBroj
endif

O_StAzur()

private cIdGost:=SPACE(8)
private cIdVrsteP

if gEvidPl=="D"
	private aCKData:={}
	private aSKData:={}
	private aGPData:={}
endif

if gClanPopust
	// ako je rijec o clanovima pusti da izaberem vrstu placanja
	cIdVrsteP:=SPACE(2)
else
	cIdVrsteP:=gGotPlac
endif

if gUpitNP=="D"
	UpitNP(gIdPos, @cIdVrsteP, cRacBroj, @cIdGost)
endif
	
if gRadniRac=="D"
	set cursor on
  	Box(,2,40)
  	@ m_x+1,m_y+3 SAY "Broj radnog racuna:" GET cRacBroj VALID P_RadniRac (@cRacBroj)
  	READ
	ESC_BCR
  	BoxC()
endif

if (gRadniRac<>"D")

// standardni racun
if IsPlNS() 
	if gFissta=="D" 
	// provjeri o kakvom se racunu radi
		nRnType:=ChkRnType()
		// broj obrasca NI
		private cObrNiNr:=""
	
		if gnDebug == 5
			MsgBeep(STR(nRnType))
		endif
			
		if (nRnType == 0)
			MsgBeep("Na racunu se pojavljuju +/- kolicine#Racun nije azuriran!")
			CLOSERET
		endif
		
		// ako se radi o cistom racunu a postoji formiran dn.izvjestaj ne moze se izdavati FISSTA racun
		if (nRnType==1 .and. ReadLastFisRpt("1", Date()) .and. gFisRptEvid=="D")
			MsgBeep("Postoji formiran dnevni izvjestaj!#Izdavanje racuna nije moguce!")
			CLOSERET
		endif
		
		// ako se radi o cistom racunu onda izdaj rn->FISSTA
		if (nRnType==1 .or. (nRnType==-1 .and. gFisStorno=="D"))
				aArtikli:={}
	  			aArtRacun:={}
	  			nUkupno:=0 //ukupan iznos racuna
	  			FillFisMatrice(@aArtikli, @aArtRacun, @nUkupno)
	  			cVrPl:=GetCodeVrstePl(cIdVrsteP)
	  			if !FisRacun(aArtikli, aArtRacun, nUkupno, cVrPl)
	     				// Racun nije formiran
					// pitaj da li je odstampan na FISSTA
					// ako nije nemoj azurirati u tops
					if Pitanje(,"Da li odstampan racun (D/N)?", "N")=="N"
						MsgBeep("Racun nije azuriran")
	     					CLOSERET 	
	  				endif
				endif
		endif
		if (nRnType==-1 .and. gFisStorno=="N")
				cObrNiNr:=GetFormNiNr()	
		endif
	endif
endif
	
// prebaci iz prip u pos
if (LEN(aRabat) > 0)
	ReCalcRabat(cIdVrsteP)
endif

_Pripr2_Pos(cIdVrsteP)

endif

StampAzur(gIdPos, cRacBroj)
// odstampaj i azuriraj
CLOSERET

return
*}

/*! \fn StampAzur(cIdPos,cRadRac)
 *  \brief
 *  \param cIdPos
 *  \param cRadRac
 */
 
function StampAzur(cIdPos, cRadRac)

local cTime
local nFis_err := 0
private cPartner

SELECT DOKS
cStalRac:=NarBrDok(cIdPos,VD_RN)

// radi mreze rezervisem DOKS !
append blank
replace idpos with gidpos, idvd with VD_RN, Brdok with cStalRac,idradnik with "////", datum with gdatum
// namjerno divlji radnik!!!!  ////

aVezani:={}
AADD(aVezani, {doks->idpos, cRadRac, cIdVrsteP, doks->datum})

sql_azur(.t.)
sql_append()
replsql idpos with gidpos, idvd with VD_RN, Brdok with cStalRac,idradnik with "////", datum with gdatum

cPartner := cIdGost

if IsPlNs() .and. gFissta=="D"
	cIdGost := cObrNiNr
endif

if IsPDV()
	cTime:=PDVStampaRac(cIdPos, cRadRac, .f., cIdVrsteP, nil, aVezani)
	
	
else
	cTime:=StampaRac(cIdPos,cRadRac,.f.,cIdVrsteP, nil, aVezani)
endif

if (!EMPTY(cTime))
	
	AzurRacuna(cIdPos, cStalRac, cRadRac, cTime, cIdVrsteP, cIdGost)
	
	// azuriranje podataka o kupcu
	if IsPDV()
		AzurKupData(cIdPos)
	endif

	// prikaz info-a o racunu
	if gRnInfo == "D"
		// prikazi info o racunu nakon stampe
		_sh_rn_info( cStalRac )
	endif

	// fiskalizacija, ispisi racun
	if gFc_use == "D"
		
		// stampa fiskalnog racuna, vraca ERR
		nErr := fisc_rn( cIdPos, gDatum, cStalRac )
		
		// da li je nestalo trake ?
		// -20 signira na nestanak trake !
		if nErr = -20
			if Pitanje(,"Da li je nestalo trake (D/N)?", "N") == ;
				"N"
				// setuj kao da je greska
				nErr := 20
			endif
		endif

		// ako postoji ERR vrati racun
		if nErr > 0 .and. gFC_error == "D"
			// vrati racun u pripremu...
			povrat_rn( cStalRac, gDatum )
		endif

	endif

endif

// nema vremena, to je znak da nema racuna
if EMPTY( cTime )
  	
	if gFC_use == "N"
		SkloniIznRac()
	endif
	
	MsgBeep("Radni racun <" + ALLTRIM (cRadRac) + "> nije zakljucen!#" + "ponovite proceduru stampanja !!!", 20)
  	
	// ako nisam uspio azurirati racun izbrisi iz doks
	select (F_DOKS)
	if !USED()
  		O_DOKS
	endif

	SELECT doks
	SEEK gIdPos+"42"+DTOS(gDatum)+cStalRac
	
	if (doks->idRadnik=="////")   
		// divlji radnik
      		delete  
		// DOKS
      		sql_delete()
	endif

endif

return


/*! \fn UpitNP(cIdPos, cIdVrsteP, cRadRac, cIdGost)
 *  \brief 
 *  \param cIdPos
 *  \param cIdVrsteP
 *  \param cRadRac
 */
 
function UpitNP(cIdPos, cIdVrsteP, cRadRac, cIdGost)
*{
local lGetPartner

SELECT _POS
seek cIdPos+"42"+DTOS(gDatum)+cRadRac

Box(,4,60)

// vecina korisnika ne treba unos partnera
lGetPartner:= .f.


cDn:="D"
do while .t.
	set cursor on
	
   	@ m_x+1,m_y+2 SAY "Nacin placanja " GET cIdVrsteP pict "@!" valid p_Vrstep(@cIdVrstep)
   	read
	 
	if gFc_use == "D"
		lGetPartner:=.t.
	else
	   if cIdVrstep<>gGotPlac .and. IzFMKINI("POS","PartnerPlacanje","N")=="D"
		lGetPartner:=.t.
	   endif  	
	endif
	
	// ako se koristi varijanta evidentiranja podataka o vp pozovi formu
	if gEvidPl=="D"
		FrmVPGetData(cIdVrsteP, aCKData, aSKData, aGPData)
	endif
	
	if lGetPartner
    		@ m_x+2,m_y+2 SAY "Partner:" GET cIdGost PICT "@!" VALID P_Gosti (@cIdGost)
    		read
   	else
    		cIdGost:=space(8)
   	endif
	
   	@ m_x+4,m_y+2 SAY "Ispravno D/N:" GET cDN PICT "@!" valid cDn $"DN"
   	read
   	if (cDN=="D")
		exit
	endif
enddo
BoxC()
return
*}


/*! \fn ZakljuciDio()
 *  \brief
 */
function ZakljuciDio()
*{

local cRacBroj:=SPACE(6)

// Zakljucuje dio racuna (ostatak ostaje aktivan)
O__POS

set cursor on
Box (, 1, 50)
// unesi broj racuna
@ m_x+1,m_y+3 SAY "Zakljuci dio radnog racuna broj:" GET cRacBroj VALID P_RadniRac (@cRacBroj)
READ
ESC_BCR
BoxC()

O_StAzur()
O_RAZDR
RazdRac(cRacBroj, .f., 2, "N", "ZAKLJUCENJE DIJELA RACUNA")
CLOSERET
*}


/*! \fn RazdijeliRacun()
 *  \brief Razdijeli radni racun na vise djelova
 */
 
function RazdijeliRacun()
*{

local cOK:=" "
local cAuto:="D"
local cRacBroj:=SPACE(6)
local nKoliko:=0

O__POS

set cursor on
Box(,8,55)
while cOK<>"D"
	@ m_x+1,m_y+3 SAY "          Razdijeli radni racun broj:" GET cRacBroj VALID P_RadniRac (@cRacBroj)
    	@ m_x+3,m_y+3 SAY "        Ukupno je potrebno napraviti:" GET nKoliko PICT "99" VALID nKoliko > 1 .AND. nKoliko <= 10
    	@ m_x+4,m_y+3 SAY "  (ukljucujuci i ovaj prvi)"
    	@ m_x+6,m_y+3 SAY "Automatski razdijeli kolicine? (D/N):" GET cAuto PICT "@!" VALID cAuto $ "DN"
    	@ m_x+8,m_y+3 SAY "                  Unos u redu? (D/N):" GET cOK PICT "@!" VALID cOK $ "DN"
    	READ
    	ESC_BCR
end
BoxC()

O_StAzur()
O_RAZDR
RazdRac(cRacBroj, .t., nKoliko, cAuto, "RAZDIOBA RACUNA")
CLOSERET
return
*}


/*! \fn RobaNaziv(cSifra)
 *  \brief
 *  \param cSifra
 */
 
function RobaNaziv(cSifra)
*{
local nARRR:=select()

select roba
hseek cSifra
select(nArrr)

return roba->naz
*}


/*! \fn PromNacPlac()
 *  \brief Promjena nacina placanja (i partnera) za odredjeni racun
 */
 
function PromNacPlac()
*{

local cRacun:=SPACE(9)
local cIdVrsPla:=gGotPlac
local cPartner:=SPACE(8)
local cDN:=" "
local cIdPOS
private aVezani:={}

O_RNGOST
O_VRSTEP
O_ROBA
O__PRIPR
O__POS
O_POS
O_DOKS
Box (, 7, 70)
// prebaci se na posljednji racun da ti je lakse
IF gVrstaRS<>"S"
  SELECT DOKS
  Seek (gIdPos+VD_RN+Chr (250))
  IF DOKS->IdVd <> VD_RN
    Skip -1
  EndIF
  do while !Bof() .and. DOKS->(IdPos+IdVd)==(gIdPos+VD_RN) .and. DOKS->IdRadnik <> gIdRadnik
    Skip -1
  EndDO
  IF !Bof() .and. DOKS->(IdPos+IdVd)==(gIdPos+VD_RN) .and. DOKS->IdRadnik==gIdRadnik
    cRacun := PADR (AllTrim (gIdPos)+"-"+AllTrim (DOKS->BrDok), ;
                    Len (cRacun))
  EndIF
Endif
dDat:=gDatum

set cursor on
@ m_x+1,m_y+4 SAY "Datum:" Get dDat
@ m_x+2,m_y+4 SAY "Racun:" GET cRacun VALID PRacuni (@dDat,@cRacun) ;
                        .and. Pisi_NPG();
                        .AND. RacNijeZaklj (cRacun);
                        .AND. RacNijePlac (@cIdVrspla,@cPartner)
  @ m_x+3,m_y+7 SAY "Nacin placanja:" GET cIdVrsPla ;
                  VALID P_VrsteP (@cIdVrsPla, 3, 26) pict "@!"
  read
  ESC_BCR
  
if (cIdVrsPla<>gGotPlac)
  @ m_x+5,m_y+9 SAY "Partner:" GET cPartner PICT "@!" ;
                  VALID P_Gosti (@cPartner, 5, 26)
  READ
  ESC_BCR
else
  cPartner:=""
endif
// vec je DOKS nastiman u BrowseSRn
SELECT DOKS

SmReplace("idVrsteP", cIdVrsPla)
SmReplace("idGost", cPartner)

BoxC()

CLOSERET
*}


/*! \fn RacNijeZaklj()
 *  \brief
 */
 
function RacNijeZaklj()
*{
IF (gVrstaRS == "S" .and. kLevel < L_UPRAVN)
  RETURN .t.
EndIF
IF (DOKS->Datum==gDatum)
  RETURN .t.
EndIF
MsgBeep ("Promjena nacina placanja nije moguca!")
return .f.
*}


/*! \fn RacNijePlac(cIdVrsPla,cPartner)
 *  \brief
 *  \param cIdVrsPla
 *  \param cPartner
 */
function RacNijePlac(cIdVrsPla,cPartner)
*{

//      Provjerava da li je racun pribiljezen kao placen
//      Ako jest, tad promjena nacina placanja nema smisla

IF DOKS->Placen == "D"
  MsgBeep ("Racun je vec placen!#Promjena nacina placanja nije dopustena!")
  RETURN (.F.)
else
  cIdVrsPla:=DOKS->idvrstep
  cPartner:= DOKS->idgost
ENDIF
return (.t.)
*}




/*! \fn Pisi_NPG()
 *  \brief Ispisuje nazive vrste placanja
 */
 
function Pisi_NPG()
*{

PushWA()
SELECT VRSTEP
Seek2 (DOKS->IdVrsteP)
IF FOUND ()
  @ m_x+3,m_y+26 SAY Naz
ENDIF
SELECT RNGOST
Seek2 (DOKS->IdGost)
IF FOUND ()
  @ m_x+5,m_y+31 SAY LEFT (Naz, 30)
ENDIF
PopWA ()
return (.t.)
*}


/*! \fn RacObilj()
 *  \brief
 */
 
function RacObilj()
*{
IF ASCAN (aVezani, {|x| x[1]+dtos(x[4])+x[2]==DOKS->(IdPos+dtos(datum)+BrDok)}) > 0
    RETURN .T.
ENDIF
RETURN .F.
*}


function PreglNezakljRN()
*{
O_StAzur()

dDatOd:=Date()
dDatDo:=Date()

Box (,1,60)
	set cursor on
	@ m_x+1,m_y+2 SAY "Od datuma:" GET dDatOd
	@ m_x+1,m_y+22 SAY "Do datuma:" GET dDatDo
	read
	ESC_BCR
BoxC()

if Pitanje(,"Pregledati nezakljucene racune (D/N) ?","D")=="D"
	StampaNezakljRN(gIdRadnik,dDatOd,dDatDo)
endif
return
*}


/*! \fn RekapViseRacuna()
 *  \brief Stampanje rekapitulacije vise racuna po broju stola
 */
 
function RekapViseRacuna()
*{
cBrojStola:=SPACE(3)

O__PRIPR
O_StAzur()

dDatOd:=Date()
dDatDo:=Date()

Box (,2,60)
	set cursor on
	@ m_x+1,m_y+2 SAY "Od datuma:" GET dDatOd
	@ m_x+1,m_y+22 SAY "Do datuma:" GET dDatDo
	@ m_x+2,m_y+2 SAY "Broj stola:" GET cBrojStola VALID !Empty(cBrojStola)
	read
	ESC_BCR
BoxC()

if Pitanje(,"Odstampati zbirni racun (D/N) ?","D")=="D"
	StampaRekapitulacije(gIdRadnik, cBrojStola, dDatOd, dDatDo, .t.)
endif

return
*}



/*! \fn PrepisRacuna()
 *  \brief Vrsi se prepis vec zakljucenog racuna, odnosno spajanje vise racuna
 */
 
function PrepisRacuna()
*{
local cPolRacun:=SPACE(9)
local cIdPos:=SPACE(LEN(gIdPos))
local nPoz
private aVezani:={}
private dDatum
private cVrijeme

O__PRIPR
O_StAzur()
Box (, 3, 60)

dDat:=gDatum

if (klevel<>L_PRODAVAC)
  @ m_x+1,m_y+4 SAY "Datum:" GET dDat
endif

set cursor on
@ m_x+2,m_y+4 SAY "Racun:" GET cPolRacun VALID PRacuni (@dDat,@cPolRacun, .T.)
READ; ESC_BCR
BoxC()

IF LEN (aVezani) > 0
  ASORT (aVezani,,, {|x, y| x[1]+dtos(x[4])+x[2] < y[1]+dtos(y[4])+y[2]})
  cIdPos := aVezani [1][1]
  cPolRacun := dtos(aVezani[1,4])+aVezani [1][2]
ELSE
  nPoz := AT ("-", cPolRacun)
  if npoz<>0
    cIdPos := PADR (AllTrim (LEFT (cPolRacun, nPoz-1)), LEN (gIdPos))
  else
    cIdPos:=gIdPos
  endif
  cPolRacun := PADL (AllTrim (SUBSTR (cPolRacun, nPoz+1)), 6)
  aVezani:={{cIdPos, cPolRacun,"",dDat}}
  cPolRacun:=dtos(dDat)+cPolRacun
  // stampaprep sadrzi 2-param kao dtos(datum)+brdok
ENDIF

StampaPrep (cIdPos, cPolRacun, aVezani)
CLOSERET
return
*}


/*! \fn StrValuta(cNaz2, dDat)
 *  \brief Iznos u stranoj valuti 
 *  \code
 *  primjer: strvaluta("KN  ", CTOD("01.01.98")))
 * \endcode
 */
 
function StrValuta(cNaz2, dDat)
*{


local nTekSel

nTekSel:=select()
select valute
set order to tag "NAZ2"
cNaz2:=padr(cNaz2,4)
seek padr(cnaz2,4)+dtos(dDat)
if valute->naz2<>cnaz2
   skip -1
endif
select (nTekSel)
if valute->naz2<>cnaz2
   return 0
else
   return valute->kurs1
endif
*}



