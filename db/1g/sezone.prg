#include "\cl\sigma\fmk\pos\pos.ch"

/*
 * ----------------------------------------------------------------
 *                                     Copyright Sigma-com software 
 * ----------------------------------------------------------------
 * $Source: c:/cvsroot/cl/sigma/fmk/pos/db/1g/sezone.prg,v $
 * $Author: sasavranic $ 
 * $Revision: 1.14 $
 * $Log: sezone.prg,v $
 * Revision 1.14  2004/04/27 11:01:39  sasavranic
 * Rad sa sezonama - bugfix
 *
 * Revision 1.13  2003/05/23 13:07:46  ernad
 * tigra: spajanje sezona, PartnSt generacija otvorenih stavki
 *
 * Revision 1.12  2003/01/19 23:44:18  ernad
 * test network speed (sa), korekcija bl.lnk
 *
 * Revision 1.11  2003/01/14 15:24:41  ernad
 * debug .. tigra ... razdvajanje sezona ... mora gSQLDirekno biti "N" !!!
 *
 * Revision 1.10  2003/01/14 10:32:18  ernad
 * pripreme za tigru ...
 *
 * Revision 1.9  2002/06/30 20:28:44  ernad
 *
 *
 *
 * pos meni za odabir firme /MNU_INI
 *
 * Revision 1.8  2002/06/26 08:14:40  ernad
 *
 *
 * debug DELETE FROM PROMVP ... <<WHERE>> falilo
 *
 * Revision 1.7  2002/06/25 23:46:15  ernad
 *
 *
 * pos, prenos pocetnog stanja
 *
 * Revision 1.6  2002/06/23 11:57:23  ernad
 * ciscenja sql - planika
 *
 * Revision 1.5  2002/06/20 12:54:09  ernad
 *
 *
 * cisenje sezonsko<->radno podrucje (izbcena fja GSezona())
 *
 * Revision 1.4  2002/06/19 19:46:47  ernad
 *
 *
 * rad u sez.podr., debug., gateway
 *
 * Revision 1.3  2002/06/17 13:58:54  sasa
 * no message
 *
 * Revision 1.2  2002/06/15 12:04:51  sasa
 * no message
 *
 *
 */
 
/*! \file fmk/pos/db/1g/sezone.prg
 *  \brief Uklanjanje i spajanje sezona
 */

/*! \fn SkloniSezonu(cSezona, lInverse, lDa, lNulirati, lRs)
 *  \brief Uklanjanje sezona
 *  \param cSezona     - oznaka sezone
 *  \param lInverse   
 *  \param lDa
 *  \param lNulirati
 *  \lRs
 */
 
function SkloniSezonu(cSezona, lInverse, lDa, lNulirati, lRs)
*{

local cScr
save screen to cScr

if lDa==nil
	lDa:=.f.
endif
if lInverse==nil
	lInverse:=.f.
endif
if lNulirati==nil
	lNulirati:=.f.
endif
if lRs==nil
   // mrezna radna stanica , sezona je otvorena
   lRs:=.f.
endif
if lRs // radna stanica
  if file(ToUnix(PRIVPATH+cSezona+"\_PRIPR.DBF"))
      // nema se sta raditi ......., pripr.dbf u sezoni postoji !
      return
  endif
  aFilesK:={}
  aFilesS:={}
  aFilesP:={}
endif

cls

?
if lInverse
? "Prenos iz  sezonskih direktorija u radne podatke"
else
? "Prenos radnih podataka u sezonske direktorije"
endif
?
// privatne datoteke
fnul:=.f.
Skloni(PRIVPATH,"PARAMS.DBF",cSezona,lInverse,lDa,fnul)
Skloni(PRIVPATH,"K2C.DBF",cSezona,lInverse,lDa,fnul)
Skloni(PRIVPATH,"MJTRUR.DBF",cSezona,lInverse,lDa,fnul)

// radne (pomocne) datoteke
Skloni(PRIVPATH,"_POS.DBF",cSezona,lInverse,lDa,fnul)
Skloni(PRIVPATH,"_PRIPR.DBF", cSezona,lInverse,lDa,fnul)
Skloni(PRIVPATH,"PRIPRZ.DBF", cSezona,lInverse,lDa,fnul)
Skloni(PRIVPATH,"PRIPRG.DBF", cSezona,lInverse,lDa,fnul)
Skloni(PRIVPATH,"FMK.INI", cSezona,lInverse,lDa,fnul)


if lRs
// mrezna radna stanica!!! , baci samo privatne direktorije
?
?
?
Beep(4)
? "pritisni nesto za nastavak.."

restore screen from cScr
return
endif

// datoteke prometa
//
if lNulirati
	fnul:=.t.
else
	fnul:=.f.
endif
Skloni(KUMPATH,"DOKS.DBF",cSezona,lInverse,lDa,fnul)
Skloni(KUMPATH,"POS.DBF",cSezona,lInverse,lDa,fnul)
Skloni(KUMPATH,"PROMVP.DBF",cSezona,lInverse,lDa,fnul)
Skloni(KUMPATH,"FMK.INI",cSezona,lInverse,lDa,fnul)
Skloni(KUMPATH,"SECUR.DBF",cSezona,lInverse,lDa,fnul)

//sifrarnici
fnul:=.f.
Skloni(SIFPATH,"ROBA.dbf", cSezona,lInverse,lDa,fnul)
Skloni(SIFPATH,"ROBA.ftp", cSezona,lInverse,lDa,fnul)
Skloni(SIFPATH,"SIROV.dbf", cSezona,lInverse,lDa,fnul)
Skloni(SIFPATH,"SAST.dbf", cSezona,lInverse,lDa,fnul)
Skloni(SIFPATH,"STRAD.dbf", cSezona,lInverse,lDa,fnul)
Skloni(SIFPATH,"OSOB.dbf", cSezona,lInverse,lDa,fnul)
Skloni(SIFPATH,"TARIFA.dbf", cSezona,lInverse,lDa,fnul)
Skloni(SIFPATH,"VALUTE.dbf", cSezona,lInverse,lDa,fnul)
Skloni(SIFPATH,"VRSTEP.dbf",cSezona,lInverse,lDa,fnul)
Skloni(SIFPATH,"KASE.dbf",cSezona,lInverse,lDa,fnul)
Skloni(SIFPATH,"ODJ.dbf",cSezona,lInverse,lDa,fnul)
Skloni(SIFPATH,"DIO.dbf",cSezona,lInverse,lDa,fnul)
Skloni(SIFPATH,"RNGOST.dbf",cSezona,lInverse,lDa,fnul)
Skloni(SIFPATH,"UREDJ.dbf",cSezona,lInverse,lDa,fnul)
if gSifK=="D"
	Skloni(SIFPATH,"SIFK.dbf",cSezona,lInverse,lDa,fnul)
	Skloni(SIFPATH,"SIFV.dbf",cSezona,lInverse,lDa,fnul)
endif
Skloni(SIFPATH,"FMK.INI",cSezona,lInverse,lDa,fnul)

?
?
?
Beep(4)
? "pritisni nesto za nastavak.."

restore screen from cScr

return
*}


/*! \fn PPrenosPOS()
 *  \brief
 */
 
function PPrenosPOS()
*{
gSezona:="    "

goModul:oDatabase:loadSezonaRadimUSezona()

if gSezonaTip=="M"
	cNewSeason:=Godina_2(gDatum)+padl(month(gDatum),2,"0")
else
	cNewSeason:=STR(YEAR(gDatum),4)
endif

gSezona:=goModul:oDatabase:cSezona

if EMPTY(gSezona)
  	goModul:oDatabase:saveSezona(cNewSeason)
  	// popuni sa novom sezonom prazno
endif

if gRadnoPodr<>"RADP" .and. gVrstaRs<>"K"
  	goModul:oDatabase:radiUSezonskomPodrucju()
elseif gRadnoPodr<>"RADP" .and. gVrstaRS=="K"
  	// obicnu kasu uvijek vratim na radno podrucje, kako god bilo ranije
  	goModul:oDatabase:cRadimUSezona:="RADP"
  	goModul:oDatabase:saveRadimUSezona("RADP")
endif

if (goModul:oDatabase:cRadimUSezona=="RADP")
    	ArhSigma()
    	if (goModul:oDatabase:cSezona<>cNewSeason .and.  Postojipromet() .and. DAY(date())>10  .and. gSamoProdaja=="N")
    
      		// ne prelazi u novu sezonu sve dok ne prodje 10 - ti u mjesecu
      		if gVrstaRS<>"K"  // neka K tip kase suti
        		MsgBeep("Prema satu racunara tekuca sezona je "+cNewSeason + "##Ukoliko je ovo prvo pokretanje programa u #novoj sezoni na sljedece pitanje odgovorite sa 'D' .", 0)
      		endif

      		if Pitanje(,"Izvrsiti pohranjivanje i spajanje podataka prethodnih sezona?","N")=="D"
        		ZaSvakiSlucaj()
        		private aFilesP:={}
        		private aFilesS:={}
        		private aFilesK:={}
        		close all
        		if !PocSkSez()
          			goModul:quit()
        		endif
        		SkloniSezonu(goModul:oDatabase:cSezona,.f.,.f.,.f.)    // ne nuliraj datoteke prometa
        
        		cOldSezona:=goModul:oDatabase:cSezona
        		KrajskSez(cOldSezona)
        
        		Spoji(cOldSezona, cNewSeason)
        
			goModul:oDatabase:saveSezona(cNewSeason)
        
        		if gVrstaRS<>"K"
          			MsgBeep("Promet protekle sezone je izbrisan iz radnih podataka.#Ovi podaci nalaze se pohranjeni u sezonskom podrucju.#Generisani su kumulativi prometa i pocetna stanja",0)
        		endif
        
        		MsgO ("Vrsi se REINDEKSIRANJE i PAKOVANJE baze podataka!!!# Sacekajte ...")
          		Reindex (.t.)
          		Pakuj(.t.)
        		MsgC()
        		release cOldSezona
      		endif
    	endif
endif

Release cNewSeason

if gModul=="HOPS"
	ReindPosPripr()
endif

return
*}



/*! \fn Spoji(cStaraSez,cNovaSez)
 *  \brief starasezona, novasezona - formiraj pocetna stanja
 *  \param cStaraSez
 *  \param cNovaSez
 */
function Spoji(cStaraSez, cNovaSez)
*{
local lSuccess:=.f.
local nGod
local nMj
local lSpajanjeRazdCijene

private cFilt1

// posto smo promjenili indeks tag "3" ...
goModul:oDatabase:kreiraj(F_PRIPRG)

O_PRIPRG
O_ODJ

O_PROMVP
OX_POS        
OX_DOKS

lSpajanjeRazdCijene:= ( IsTigra() .or. IzFmkIni('TOPS','SpajanjeRazdCijene','N', KUMPATH)=='D')

if (gSezonaTip=="M")
  	// ako je danasnja (novaz) sezona 0206 -> dDat=CTOD("01.06.02")
	dDat:=CTOD ("01."+RIGHT(cNovaSez, 2)+"."+LEFT(cNovaSez, 2))
else
  	// NOT Y2K kompatibilno !!!! - nakon set centuri jeste
  	dDat := CTOD ("01.01."+RIGHT(cNovaSez, 2))
endif

//"6", "dtos(datum)
SELECT DOKS


// u pos, doks uopste ne gledam dokumente koji se nalaze u novoj sezoni
cFilt1:="DATUM<"+cm2Str(dDat)
SET FILTER TO &cFilt1
SELECT POS
SET FILTER TO &cFilt1


FillPriprG(dDat, lSpajanjeRazdCijene)
PobrisiStareDok(dDat)

SELECT DOKS
// "1", "IdPos+IdVd+dtos(datum)+BrDok"
SET ORDER TO 1

GW_HANDLE:=0
if goModul:lSqlDirektno
	cAkcija:="L"
else
	cAkcija:="P"
endif


Priprg2Kumulativ()

CLOSERET
return
*}


static function FillPriprG(dDat, lSpajanjeRazdCijene)
*{

MsgO("formiram pripremnu tabelu pos -> priprg")
SELECT priprg
ZAP

// "3": "IdVd+IdPos+IdVrsteP+IdGost+Placen+IdDio+IdOdj+IdRoba+..."
SET ORDER TO 3

Scatter()

SELECT POS
set order to 1
GO TOP

do while !EOF()

     	// nivelacija nas ne interesuju, ne uticu na kolicinu
	if POS->idVd=="NI"
    		SKIP
    		loop   
 	 endif

  	cIdPos:=POS->IdPos
  	cIdVd:=POS->IdVd
  	cBrDok:=POS->BrDok
  	cDatum:=DTOS(pos->datum)

	SELECT DOKS
	HSEEK cIdPos+cIdVd+cDatum+cBrDok
	
	// inicijaliziraj ono sto nema u POS
	Scatter()  

	SELECT POS
	do while !EOF() .and. POS->(IdPos+IdVd+dtos(datum)+BrDok)==(cIdPos+cIdVd+cDatum+cBrDok)

		Scatter()
		if YEAR(datum)<YEAR(dDat)  
	      		// stara godina
			SetSGKolicina(@_kolicina)
	      		// sve dokumente iz prosle godine staviti u dokument 00-dokument pocetnog stanja
			_idvd:="00"
			_placen:="9" 
	      		_datum:=CTOD("31.12."+ALLTRIM(STR(YEAR(dDat)-1)))
	      		_idVrsteP:=space(len(_idVrsteP))
		else
	       		// tekuca godina
	       		if idvd $ "00#01"
		  		// izgenerisane dokumente ne diraj
		  		SKIP
		  		loop 
	      		endif

	       		_BrDok := SPACE (LEN (_BrDok))
	       		// datum je zadnji dan u proslom mjesecu
			_Datum := dDat-1
			SetTGKolIdVdDatumMui(@_kolicina, @_kol2, @_IdVd, @_MU_I, @_Placen)
		 
		endif

		SELECT priprg

		_IdDio:=SPACE(LEN(_iddio))
		_IdRadnik := SPACE(LEN(_IdRadnik))
		
		if lSpajanjeRazdCijene
			HSEEK _IdVd+_IdPos+_IdVrsteP+_IdGost+_Placen+_IdDio+_IdOdj+_IdRoba+STR(_Cijena,10,2)
			
		else	
			HSEEK _IdVd+_IdPos+_IdVrsteP+_IdGost+_Placen+_IdDio+_IdOdj+_IdRoba
		endif

		if !FOUND()
			AppBlank2 (.f., .f.)
		else
			_Kolicina:=priprg->kolicina+_Kolicina
		endif

		if cIdPos<>_idPos
			MsgBeep("Greska! Izvrsite reindeksiranje pa ponovite spajanje sezona!")
			goModul:quit()
		endif

		Gather2()
		SELECT pos
		SKIP
	  enddo
enddo
MsgC()

return
*}

/*! \fn SetSGKolicina(_kolicina)
 *  \brief Odredi kolicinu za dokumente u staroj godini 
 */
static function SetSGKolicina(_kolicina)
*{

do case 
	case pos->idvd $ "NI"
		_kolicina:=0
	case pos->idvd $ "16#00"
		_kolicina:= pos->kolicina
	case pos->IdVd == "IN"
		_kolicina:= -(pos->kolicina - pos->kol2)
	case pos->idVd $ "42#01"
		if gModul=="HOPS"
			SELECT ODJ
			HSEEK POS->IdOdj
			if odj->Zaduzuje == "R"
				_kolicina:= -pos->kolicina
			else
				_kolicina:=0
			endif
		else
			_kolicina:= -POS->Kolicina
		endif
	otherwise
		// 96, 98
	    	_kolicina:= -pos->kolicina
	
end case

return
*}

/*! \fn SetTGKolIdVdDatumMui(_kolicina, _IdVd, _Datum, _MU_I) 
 *  \brief Odredi varijable koje cemo smjestiti u tabelu priprg - dokumenti iz tekuce godine
 */
static function SetTGKolIdVdDatumMui(_kolicina, _kol2, _IdVd, _MU_I, _placen)
*{

// mislim da polje mu_i nigdje ne koristimo ... ovo se moze izbaciti
if POS->IdVd $ "42"  
	
	// ovdje se radi o dokumentu koji sadrzi kumulativnu realizaciju
	_IdVd := "01"
	_MU_I := R_I
	
elseif POS->IdVd $ "96"  
	
	// ovdje se radi o izlaz, otpis
	_IdVd := "96"
	_MU_I := R_I

elseif POS->idVd $ "95#98"  
	_IdVd := "00"
	_kolicina:=-_kolicina
	_MU_I := R_U
	
elseif pos->idVd $ "16"
	_IdVd:="00"
	_kolicina:=_kolicina
	_MU_I:=R_U

elseif pos->idVd == "IN"
	_Kolicina:= - (_Kolicina-_Kol2 )
	_IdVd:="00"
	_MU_I:=R_U

else
	// iako mislim da sam sve obuhvatio ...
	_IdVd := "00"
	if gModul=="HOPS"
		SELECT ODJ
		HSEEK POS->IdOdj
		if ODJ->Zaduzuje == "S"
			_MU_I := S_U
		else
			_MU_I := R_U
		endif
	endif
endif

_Kol2:=0
_Placen:=SPACE(LEN(_Placen))

return
*}

static function PobrisiStareDok(dDat)
*{

MsgO("Brisem stare dokumente - doks")
SELECT F_DOKS
if !USED()
	O_DOKS
endif
SELECT DOKS
set order to 0
GO TOP
do while !eof()
	// podaci iz stare godine
	if year(datum)<year(dDat) 
		delete // sve brisi
	else
		if !(idvd $ "00#01")
			dbdelete2()
		endif
	endif
	skip
enddo

cSql:="delete from DOKS WHERE YEAR(Datum)<"+SQLValue(year(dDat))+" "+;
      " or ( Datum<"+SQLValue(dDat)+" and Idvd <> '00' and IdVd <> '01' )"

if goModul:lSqlDirektno
	GwDirektno(cSql)
else
	Gw(cSql)
endif

MsgC()


MsgO("Brisem stare dokumente - pos")
SELECT F_POS
if !USED()
	O_POS
endif
SELECT POS
set order to 0
GO TOP
do while !eof()
	if YEAR(field->datum)<YEAR(dDat)  
	// podaci iz stare godine
		DELETE 
	else
		if !(idvd $ "00#01")
			DELETE
			//dbdelete2()
		endif
	endif
	skip
enddo

cSQL:="delete from POS WHERE YEAR(Datum)<"+SQLValue(year(dDat))+" "+;
      " or ( Datum<"+SQLValue(dDat)+" and Idvd <> '00' and IdVd <> '01') "
 
if goModul:lSqlDirektno
	GwDirektno(cSql)
else
	Gw(cSql)
endif
     
MsgC()

MsgO("Brisem stare dokumente - promvp")
SELECT PROMVP
set order to 0
GO TOP
do while !EOF()
	// izbrisi sve stavke u promvp starije od 30 dana
	if (field->datum < (gDatum-30) ) 
		delete
	endif
	skip
enddo

cSql:="delete from PROMVP WHERE Datum<"+SQLValue(gDatum-30)
 
if goModul:lSqlDirektno
	GwDirektno(cSql)
else
	Gw(cSql)
endif
     
MsgC()

return
*}

static function _NarBrDok(cIdPos, cIdVd, dDatum)
*{
local cBrDok

Scatter()
SELECT doks
PushWa()
SET FILTER TO
cBrdok:=NarBrdok(cIdpos,cIdVD, " ",dDatum)
PopWa()

return cBrDok
*}


static function DodajUDok(cAkcija)
*{

AppBlank2(.f., .f.)
sql_append(0, cAkcija )
Gather2()
sql_azur(.f.)

if (gSQL != "D")
	return
endif

if goModul:lSqlDirektno
	GathSQL("_",.f.,0, "L")
else    
	if Len(GW_STRING())>6000
		cAkcija:="Z"
	else
		cAkcija:="D"
	endif
	
	GathSQL("_",.f.,0, cAkcija)
	if cAkcija=="Z"
		cAkcija:="P"
	endif
endif

return
*}

static function DodajUPos(cIdVd, cIdPos, cBrDok, cIdVrsteP, cIdGost, cAkcija)
*{

//local cPlacen
	    
SELECT priprg

//cPlacen := priprg->placen
//izbacio sam sumiranje po polju placen ... ne treba mi to, ne znam zasto je to trebalo ? vjerovatno kada se radilo za hotel ...

do while !EOF() .and. priprg->(idVd+idPos+idVrsteP+idGost)==(cIdVd+cIdPos+cIdVrsteP+cIdGost)

	if (priprg->kolicina==0)
		SKIP
		loop
	endif
	
	Scatter()
	_BrDok:=cBrDok
	
	SELECT pos
	AppBlank2 (.f., .f.)
	if goModul:lSqlDirektno
		sql_append(0, "L")
	else
	/*
		sql_append(0, cAkcija)
	*/
	endif
	// ne zakljucavaj
	sql_azur(.f.)
	Gather2()
	      
	if goModul:lSqlDirektno
		GathSql("_",.f.,0,"L")
	else
	/*
		//ugasicemo u novim verzijama ovaj dio
		if Len(GW_STRING())>6000
			cAkcija:="Z"
		else
			cAkcija:="D"
		endif
		GathSql("_",.f.,0,cAkcija)
		if cAkcija=="Z"
			cAkcija:="P"
		endif
	*/
	endif

	SELECT priprg
	SKIP

enddo 

return
*}

static function Priprg2Kumulativ(cAkcija)
*{

MsgO("priprg -> pos, doks")
SELECT priprg
SET ORDER TO 3
GO TOP
do while !EOF()
	cIdVd:=priprg->idVd
	cIdPos:=priprg->idPos
	cIdVrsteP:=priprg->idVrsteP
	cIdGost:=priprg->idGost
	do while !EOF() .and. priprg->(IdVd+IdPos+IdVrsteP+IdGost)==(cIdVd+cIdPos+cIdVrsteP+cIdGost)
			
		_BrDok:=_NarBrDok(cIdPos, cIdVd, priprg->datum)
		DodajUDok(cAkcija)
		DodajUPos(cIdVd, cIdPos, _BrDok, cIdVrsteP, cIdGost, cAkcija)
		    
       enddo
enddo   

if !goModul:lSqlDirektno
	if cAkcija<>"Z"
		Gw("", 0, "Z" )
	endif
endif
MsgC()

return
*}
