#include "\cl\sigma\fmk\pos\pos.ch"

/*
 * ----------------------------------------------------------------
 *                                     Copyright Sigma-com software 
 * ----------------------------------------------------------------
 * $Source: c:/cvsroot/cl/sigma/fmk/pos/razoff/1g/posdisk.prg,v $
 */ 


/*! \fn PosDiskete()
 */

function PosDiskete()
*{
private opc:={}
private opcexe:={}
private Izbor:=1

AADD(opc,"1. prenos dokumenata   =>        ")
AADD(opcexe,{|| PrenosDiskete()})
AADD(opc,"2. prijem dokumenata   <= ")
AADD(opcexe,{|| PovratDiskete()})
AADD(opc,"3. podesavanje prenosa i prijema")
AADD(opcexe,{|| PodesavanjePrenosa()})
Menu_SC("posd")
closeret
return
*}



/*! \fn PrenosDiskete()
 *  \brief Prenos na diskete
 */
 
function PrenosDiskete()
*{
local nRec
private cLokPrenosa:="A:\"
private cFajlZaPredaju:="POS"
private cFajlZaPrijem:="POS"
private cUslovTipDok:="42;"
private cSpecUslov:=""
private cSinSFormula:="99"
private cKonvFirma:=""
private cKonvBrDok:=""
altd()
PodesavanjePrenosa(.t.)

if Pitanje(,"Zelite li izvrsiti prenos podataka na diskete ?","N")=="N"
	closeret
endif

if Pitanje(,"Nulirati datoteke prenosa prije nastavka ?","D")=="D"
	O_POS
  	copy structure extended to (PRIVPATH+"struct")
  	use
  	create (PRIVPATH+"_POSP") from (PRIVPATH+"struct")
	
	O_DOKS
	copy structure extended to (PRIVPATH+"struct")
  	use
  	create (PRIVPATH+"_DOKSP") from (PRIVPATH+"struct")
	
	O_ROBA
  	copy structure extended to (PRIVPATH+"struct")
  	use
  	create (PRIVPATH+"_ROBA") from (PRIVPATH+"struct")
  	if Izfmkini('Svi','Sifk','N')=="D"
    		O_SIFK
    		copy structure extended to (PRIVPATH+"struct")
    		use
    		create (PRIVPATH+"_SIFK") from (PRIVPATH+"struct")
		
		O_SIFV
    		copy structure extended to (PRIVPATH+"struct")
		use
    		create (PRIVPATH+"_SIFV") from (PRIVPATH+"struct")
	endif
	close all

	O__POSP  // otvara se bez indeksa	
	O__DOKSP
	O__ROBA

  	select _posp
	zap
  	select _roba
	zap
	select _doksp
	zap

  	close all
endif

fSifk:=.f.
if Izfmkini('Svi','Sifk','N')=="D"
	fSifk:=.t.
endif

O_DOKS
O__DOKSP
O__POSP
O_POS

SELECT POS
set order to tag "1"

cIdPos:=gIdPos
cIdVD:=SPACE(2)
cBrDok:=SPACE(8)

private qqBrDok:=SPACE(80)
private qqIdVD:=PadR(cUslovTipDok,80)
private qqSpecUslov:=PadR(cSpecUslov,80)
private dDatOd:=CTOD("")
private dDatDo:=DATE()

if !Empty(cIdVD)
	qqIdVD:=PadR(cIdVD+";",80)
endif

Box(,4,70)
	do while .t.
  		@ m_x+1,  m_y+2  SAY  "Vrste dokumenata    "  GEt qqIdVD pict "@S40"
  		@ m_x+2,  m_y+2  SAY  "Brojevi dokumenata  "  GEt qqBrDok pict "@S40"
  		@ m_x+3,  m_y+2  SAY  "Spec.dodatni uslov  "  GEt qqSpecUslov pict "@S40"
 		@ m_x+4,  m_y+2  SAY  "Obuvaceni period od:" GET dDatOd
  		@ m_x+4,col()+2  SAY  "do:" GET dDatDo
  		READ
  		private aUsl1:=Parsiraj(qqBrDok,"BrDok","C")
  		private aUsl3:=Parsiraj(qqIdVD,"IdVD","C")
  		if (aUsl1<>nil .and. aUsl3<>nil)
    			exit
  		endif
 	enddo
BoxC()

qqSpecUslov:=TRIM(qqSpecUslov)

if Pitanje(,"Prenijeti u datoteku prenosa sa ovim kriterijom ?","D")=="D"
	select pos
  	if !fLock()
		Msg("POS je zauzeta ",3)
		closeret
	endif
	private cFilt1:=""
  	cFilt1:="IdPos="+Cm2Str(cIdPos)+".and."+aUsl1+".and."+aUsl3
	if !empty(dDatOd) .or. !empty(dDatDo)
    		cFilt1 += ".and. Datum>="+cm2str(dDatOd)+".and. Datum<="+cm2str(dDatDo)
  	endif
  	if !EMPTY(qqSpecUslov)
    		cFilt1+=".and.("+qqSpecUslov+")"
  	endif

  	cFilt1:=STRTRAN(cFilt1,".t..and.","")
  	cFilt1:=STRTRAN(cFilt1,".t..and.","")
	
	if !(cFilt1==".t.")
    		set filter to &(cFilt1)
  	endif

  	go top
	if eof()
		MsgBeep("Nema dokumenata!")
		CLOSERET
	endif

  	MsgO("Prolaz kroz POS...")
  	StartPrint(.t.)
  	? "POS - U DATOTECI ZA PRENOS SU SLJEDECI DOKUMENTI:"
  	?
	? "IDPOS  ³  TIP  ³  BROJ   ³   DATUM "
     	? "-----------------------------------"
  	do while !eof()
    		select pos
    		
		Scatter()
    		
		select _posp
    		append ncnl
		Gather2()
    		
		select pos

    		skip 1
		cSIdPos:=idpos
		cSIDVD:=idvd
		cSBrDok:=brdok
		dSDatum:=datum

		skip -1
    		if cSIdPos+cSIdVD+DToS(dSDatum)+cSBrDok!=idpos+idvd+DToS(datum)+brdok
     			? "  "+idpos+" ³  "+idvd+" ³  "+idpos+"-"+ALLTRIM(brdok)+" ³  "+DTOC(datum)
    		endif
    		skip
  	enddo
	
	select doks
	if !(cFilt1==".t.")
		set filter to &(cFilt1)
	endif
	go top
	do while !eof()
    		select doks
    		Scatter()
    		select _doksp
    		append ncnl
		Gather2()
		select doks
    		skip
  	enddo
	
	EndPrint()
	MsgC()

else
	close all
  	return
endif
close all

O_ROBA

if fSifK
	O_SIFK
  	O_SIFV
endif

O__ROBA

INDEX ON id TO "_ROBATMP"  // index radi trazenja
select _roba
//append from roba  !! ? kupi i sto treba i sto ne treba

MsgO("Osvjezavam datoteku _Roba ... ")

O__POSP

select _posp
go top
// uzmi samo artikle koji su se pojavili u dokumentima !!!!

do while !eof()
	select _roba
  	// nafiluj tabelu _ROBA sa siframa iz dokumenta
  	seek _posp->idroba
  	if !found()
    		select roba
    		seek _posp->idroba
    		if found()
     			scatter()
     			// dodaj u _roba
     			select _roba
     			append blank
     			Gather()
    		endif
    		if fsifk
      			SifkFill(PRIVPATH+"_SIFK",PRIVPATH+"_SIFV","ROBA",_posp->idroba)
    		endif
  	endif

  	select _posp
  	skip
enddo

MsgC()

close all

FILECOPY(PRIVPATH+"OUTF.TXT", PRIVPATH+"_POS.TXT")
aFajlovi:={PRIVPATH+"_pos.txt", PRIVPATH+"_doksp.*", PRIVPATH+"_posp.*", PRIVPATH+"_roba.*", PRIVPATH+"_SIF?.*"}
Zipuj(aFajlovi,cFajlZaPredaju,cLokPrenosa)
return
*}



/*! \fn PovratDiskete()
 *  \brief Povrat podataka 
 */
function PovratDiskete()
*{
local nRec
local cDiff:=""
private cLokPrenosa:="A:\"
private cFajlZaPredaju:="POS"
private cFajlZaPrijem:="POS"
private cUslovTipDok:="42;"
private cSpecUslov:=""
private cSinSFormula:="99"
private cKonvFirma:=""
private cKonvBrDok:=""

PodesavanjePrenosa(.t.)

fSifk:=.f.
if Izfmkini('Svi','Sifk','N')=="D"
	fSifk:=.t.
endif

if Klevel<>"0"
	Beep(2)
    	Msg("Nemate pristupa ovoj opciji !",4)
    	closeret
endif

if !Unzipuj(cFajlZaPrijem,,cLokPrenosa)   // raspakuje u PRIVPATH
	closeret
endif

close all

if LastKey()==K_ESC
	return
endif

save screen to cs

VidiFajl(PRIVPATH+"_POS.TXT")

if Pitanje(,"Zelite li preuzeti prikazane dokumente? (D/N)"," ")=="N"
	restore screen from cs
  	RETURN
endif

restore screen from cs

O_DOKS
O__DOKSP
O__POSP
O_POS

select _posp
set order to 0

if !Empty(cKonvFirma+cKonvBrDok)
	aKBrDok:=TokUNiz(cKonvBrDok)
  	aKFirma:=TokUNiz(cKonvFirma)
  	go top
  	do while !EOF()
    		nPosKBrDok:=ASCAN(aKBrDok ,{|x| x[1]==idvd})
    		if nPosKBrDok>0
      			cPom777:=aKBrDok[nPosKBrDok,2]
      			replace brdok WITH &cPom777
    		endif
    		nPosKFirma := ASCAN( aKFirma , {|x| x[1]==idpos} )
    		if nPosKFirma>0
      			replace idfirma WITH aKFirma[nPosKFirma,2]
    		endif
    		skip 1
  	enddo
endif

cIdFirma:=gIdPos
cIdTipdok:=SPACE(2)
cBrDok:=SPACE(8)

MsgO("Prenos POSP -> POS")

select pos
append from _posp
select doks
append from _doksp

MsgC()

cDN1:=Pitanje(,"ROBA - DODATI nepostojece sifre ?","D")
cDN2:=Pitanje(,"ROBA - ZAMIJENITI postojece sifre ?","D")
cDN3:="N"      // ROBA - osvjeziti bar-kodove ?

lOsvNazRobe:=.t.

if cDN1=="D"
	close all
	O_ROBA
	if fSifK
   		O_SIFK
		O_SIFV
	endif
	O__ROBA
	set order to 0
	go top
	Box(,1,60)
		// prolazimo kroz _ROBA
		cRFajl:=PRIVPATH+"POS.RF"
		UpisiURF("IZVJESTAJ O PROMJENAMA NA SIFRARNIKU ROBE:",cRFajl,.t.,.t.)
		UpisiURF("------------------------------------------",cRFajl,.t.,.f.)
		do while !eof()
  			@ m_x+1,m_y+2 SAY id
			?? "-",naz
  			select roba
			scatter()
  			select _roba
  			scatter()
  			select roba
			hseek _id
  			if !found()
    				UpisiURF("ROBA: dodajem "+_id+"-"+_naz,cRFajl,.t.,.f.)
    				append blank
    				gather()
    				if fSifk
      					SifKOsv(PRIVPATH+"_SIFK",PRIVPATH+"_SIFV","ROBA",_id)
    				endif
  			else
    				if cDN2=="D"  // zamjeniti postojece sifre
      					cDiff:=""
      					if DiffMFV(,@cDiff)
        					UpisiURF("ROBA: osvjezavam "+_id+"-"+_naz+cDiff,cRFajl,.t.,.f.)
      					endif
      					gather()
      					if fSifK
        					SifKOsv(PRIVPATH+"_SIFK",PRIVPATH+"_SIFV","ROBA",_id)
      					endif
    				else
      					if cDN3=="D"
        					Scatter()
        					if _barkod <>_roba->barkod
          						UpisiURF("ROBA: osvjezavam "+_id+"-"+_naz,cRFajl,.t.,.f.)
          						UpisiURF("     BARKOD: bilo="+TRANS(_barkod,"")+", sada="+TRANS(_ROBA->barkod,""),cRFajl,.t.,.f.)
        					endif
        					_barkod := _ROBA->barkod
        					Gather()
      					endif
      					if lOsvNazRobe
        					Scatter()
        					if _naz <> _roba->naz
          						UpisiURF("ROBA: osvjezavam "+_id+"-"+_naz,cRFajl,.t.,.f.)
          						UpisiURF("     NAZIV: bilo="+TRANS(_naz,"")+", sada="+TRANS(_ROBA->naz,""),cRFajl,.t.,.f.)
        					endif
        					_naz := _ROBA->naz
        					Gather()
      					endif
    				endif
  			endif
  			select _roba
  			skip
		enddo
	BoxC()
endif // cnd1

save screen to cs
VidiFajl(cRFajl)
restore screen from cs

closeret
return
*}


/*! \fn PodesavanjePrenosa(lIni)
 *  \brief Podesavanje parametara prenosa
 */
 
function PodesavanjePrenosa(lIni)
*{
local GetList:={}

if lIni==nil
	lIni:=.f.
endif

O_PARAMS
private cSection:="3"
private cHistory:=" "
private aHistory:={}

if !lIni
	private cLokPrenosa:="A:\"
    	private cFajlZaPredaju:="POS"
    	private cFajlZaPrijem:="POS"
    	private cUslovTipDok:="1;"
    	private cSpecUslov:=""
    	private cSinSFormula:="99"
    	private cKonvFirma:=""
    	private cKonvBrDok:=""
endif

RPar("y1",@cLokPrenosa)
RPar("y2",@cFajlZaPredaju)
RPar("y3",@cFajlZaPrijem)
RPar("y4",@cUslovTipDok)
RPar("y5",@cSpecUslov)
RPar("y6",@cSinSFormula)
RPar("y7",@cKonvFirma)
RPar("y8",@cKonvBrDok)

if !lIni
	cLokPrenosa:=PADR(cLokPrenosa,80)
    	cFajlZaPredaju:=PADR(cFajlZaPredaju,80)
    	cFajlZaPrijem:=PADR(cFajlZaPrijem,80)
    	cUslovTipDok:=PADR(cUslovTipDok,80)
    	cSpecUslov:=PADR(cSpecUslov,80)
    	cSinSFormula:=PADR( cSinSFormula,80)
    	cKonvFirma:=PADR(cKonvFirma,80)
    	cKonvBrDok:=PADR(cKonvBrDok,80)
	Box(,13,75)
     		@ m_X+ 0,m_y+ 4 SAY "PODESAVANJE PARAMETARA ZA PRENOS I PRIJEM PODATAKA PUTEM DISKETA"
     		@ m_X+ 2,m_y+ 2 SAY "Lokacija za prenos            " GET cLokPrenosa    PICT "@!S30"
     		@ m_X+ 3,m_y+ 2 SAY "Naziv fajla za predaju        " GET cFajlZaPredaju PICT "@!S30"
     		@ m_X+ 4,m_y+ 2 SAY "Naziv fajla za prijem         " GET cFajlZaPrijem  PICT "@!S30"
     		@ m_X+ 5,m_y+ 2 SAY "Standardno koristeni uslov za "
     		@ m_X+ 6,m_y+ 2 SAY "tip dokumenata koji se prenose" GET cUslovTipDok  PICT "@!S30"
     		@ m_X+ 7,m_y+ 2 SAY "Specificni dodatni uslov      " GET cSpecUslov  PICT "@!S30"
     		@ m_X+ 8,m_y+ 2 SAY "Formula za duzinu sintet.sifre" GET cSinSFormula PICT "@!S30"
     		@ m_X+ 9,m_y+ 2 SAY "ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ"
     		@ m_X+10,m_y+ 2 SAY "Konverzije pri prijemu dokumenata:"
     		@ m_X+11,m_y+ 2 SAY "Oznaka firme (F1.F2;F3.F4 ...)  " GET cKonvFirma  PICT "@!S30"
     		@ m_X+12,m_y+ 2 SAY "Br.dokumenta (VD1.F1;VD2.F2 ...)" GET cKonvBrDok  PICT "@!S30"
     		read
    	BoxC()

	cLokPrenosa:=TRIM(cLokPrenosa)
    	cFajlZaPredaju:=TRIM(cFajlZaPredaju)
    	cFajlZaPrijem:=TRIM(cFajlZaPrijem)
    	cUslovTipDok:=TRIM(cUslovTipDok)
    	cSpecUslov:=TRIM(cSpecUslov)
    	cSinSFormula:=TRIM(cSinSFormula)
    	cKonvFirma:=TRIM(cKonvFirma)
    	cKonvBrDok:=TRIM(cKonvBrDok)

	if LASTKEY()!=K_ESC
      		WPar("y1",cLokPrenosa)
      		WPar("y2",cFajlZaPredaju)
      		WPar("y3",cFajlZaPrijem)
      		WPar("y4",cUslovTipDok)
      		WPar("y5",cSpecUslov)
      		WPar("y6",cSinSFormula)
      		WPar("y7",cKonvFirma)
      		WPar("y8",cKonvBrDok)
    	endif

endif
use
return
*}

/*! \fn UpisiURF(cTekst,cFajl,lNoviRed,lNoviFajl)
 *  \brief Upisi u report fajl
 *  \param cTekst    - tekst
 *  \param cFajl     - ime fajla
 *  \param lNoviRed  - da li prelaziti u novi red
 *  \param lNoviFajl - da li snimati u novi fajl
 */
 
function UpisiURF(cTekst,cFajl,lNoviRed,lNoviFajl)
*{
StrFile(IF(lNoviRed,CHR(13)+CHR(10),"") + cTekst, cFajl, !lNoviFajl)
return
*}

/*! \fn DiffMFV(cZn,cDiff)
 *  \brief differences: memo vs field variable
 *  \param cZn 
 *  \param cdiff
 */
 
function DiffMFV(cZN,cDiff)
*{
local lVrati:=.f.
local i
local aStruct

if cZn==NIL
	cZn:="_"
endif

aStruct:=DBSTRUCT()

FOR i:=1 TO LEN(aStruct)
	cImeP:=aStruct[i,1]
    	IF !(cImeP=="BRISANO")
     		cVar:=cZn+cImeP
      		IF "U"$TYPE(cVar)
			MsgBeep("Greska:neuskladjene strukture baza!#"+;
				"Pozovite servis SIGMA-COM-a!#"+;
				"Funkcija: GATHER(), Alias: "+ALIAS()+", Polje: "+cImeP)
      		ELSE
			IF field->&cImeP <> &cVar
	  			lVrati:=.t.
          			cDiff+=(CHR(13)+CHR(10))+"     "
          			cDiff+=cImeP+": bilo="+TRANS(field->&cImeP,"")+", sada="+TRANS(&cVar,"")
			ENDIF
      		ENDIF
    	ENDIF
NEXT
return lVrati
*}


