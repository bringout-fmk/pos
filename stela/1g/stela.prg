#include "\cl\sigma\fmk\pos\pos.ch"

/*
 * ----------------------------------------------------------------
 *                                     Copyright Sigma-com software 
 * ----------------------------------------------------------------
 * $Source: c:/cvsroot/cl/sigma/fmk/pos/stela/1g/stela.prg,v $
 * $Author: sasavranic $ 
 * $Revision: 1.14 $
 * $Log: stela.prg,v $
 * Revision 1.14  2003/11/21 15:07:35  sasavranic
 * poruka o kreiranju arhive
 *
 * Revision 1.13  2003/11/21 14:54:48  sasavranic
 * konacno ispravljeno sortiranje racuna
 *
 * Revision 1.12  2003/09/16 08:48:30  mirsad
 * ponovo promijenio algoritam za presortiranje racuna: uveo pomocne baze precno i drecno
 *
 * Revision 1.11  2003/08/27 14:50:14  mirsad
 * 1) debug:presortiranje racuna
 *
 * Revision 1.10  2003/07/08 18:34:20  mirsad
 * 1) uveo brisanje zaklj.RN iz _pos.dbf nakon presortiranja da bih postigao prihvatljiv broj radnog RN na maski za unos racuna
 * 2) debug presortiranja: dodjeljivao brojeve obrnutim redoslijedom
 *
 * Revision 1.9  2003/07/05 11:27:43  mirsad
 * uveo uslov za prodajno mjesto pri pozivu pregleda racuna
 *
 * Revision 1.8  2003/07/04 18:14:32  mirsad
 * promjena funkcije za presortiranje brojeva racuna
 *
 * Revision 1.7  2003/06/24 13:15:09  sasa
 * no message
 *
 * Revision 1.6  2002/07/08 23:03:55  ernad
 *
 *
 * trgomarket debug dok 80, 81, izvjestaj lager lista magacin po proizv. kriteriju
 *
 * Revision 1.5  2002/06/19 19:46:47  ernad
 *
 *
 * rad u sez.podr., debug., gateway
 *
 * Revision 1.4  2002/06/19 05:53:14  ernad
 *
 *
 * ciscenja, debug
 *
 * Revision 1.3  2002/06/17 12:34:24  sasa
 * no message
 *
 *
 */
 

/*! \fn PromjeniID()
 *  \brief Promjena prodajnog mjesta racuna
 *  \brief racuni na crno idu sa IdPos -> X
 */
 
function PromjeniID()
*{
local fScope
local cFil0
local cTekIdPos:=gIdPos
private aVezani:={}
private dMinDatProm:=ctod("")

// datum kada je napravljena promjena na racunima
// unutar PRacuni, odnosno P_SRproc setuje se ovaj datum

if gSifK=="D"
	O_SIFK
	O_SIFV
endif

O_KASE
O_ROBA
O__PRIPR
O_DOKS
O_POS

if KLevel<="0".and.SigmaSif(gSTELA)
	fScope:=.f.
else
	fscope:=.t.
endif

dDatOd:=ctod("")
dDatDo:=cTod("")

qIdRoba:=SPACE(LEN(POS->idroba))

SET CURSOR ON
if IzFmkIni("PREGLEDRACUNA","MozeIZaArtikal","N",KUMPATH)=="D"
	Box(,3,72)
    	@ m_x+1,m_y+2 SAY "Racuni na kojima se nalazi artikal: (prazno-svi)" GET qIdRoba VALID EMPTY(qIdRoba).or.P_RobaPOS(@qIdRoba) PICT "@!"
    	@ m_x+2,m_y+2 SAY "Datumski period:" GET dDatOd
    	@ m_x+2,col()+2 SAY "-" GET dDatDo
	@ m_x+3,m_y+2 SAY "Prodajno mjesto:" GET gIdPos VALID P_Kase(@gIdPos)
    	read
  	BoxC()
else
  	Box(,2,60)
    	@ m_x+1,m_y+2 SAY "Datumski period:" GET dDatOd
    	@ m_x+1,col()+2 SAY "-" GET dDatDo
	@ m_x+2,m_y+2 SAY "Prodajno mjesto:" GET gIdPos VALID P_Kase(@gIdPos)
    	read
  	BoxC()
endif

cFil0:=""

if !EMPTY(dDatOd).and.!EMPTY(dDatDo)
	cFil0:="Datum>="+cm2str(dDatOD)+".and. Datum<="+cm2str(dDatDo)+".and."
endif

PRacuni(,,,fScope,cFil0,qIdRoba)  
// postavi scope: P_StalniRac(dDat,cBroj,fPrep,fScope)

CLOSE ALL
Presort2()

if gModul=="HOPS"

// samo kod HOPSa imam sirovine
Close All
if !EMPTY(dMinDatProm).and.;
   Pitanje(,"Ponovo izgenerisati utrosak sirovina?","D")=="D"
    Box(,2,60)
     dDatOd:=dMinDatProm
     dDatDo:=gdatum

     cNajstariji:=UzmiIzIni(PRIVPATH+"fmk.ini",'POS','XPM',"-", 'READ')
     if cNajstariji!="-"  .and. !empty(cNajstariji)
          dDatOd:= STOD(  left( cNajStariji ,  len(dtos(dDatOd)) )  )
     endif

     @ m_x+1,m_y+2 SAY "Period za koji se usaglasava stanje:" ;
                   GET dDAtOd VALID dDatOd <= dMinDatProm
     @ m_x+1,col()+2 SAY "-" GET dDatDo
     read
    BoxC()
    GenUtrSir (dDatOd,dDatDo)
endif

endif

gIdPos:=cTekIdPos
CLOSERET
return
*}


/*! \fn Presort()
 *  \brief Presortirati racune - popuni "rupe"
 */
 
function Presort()
*{
local _IdPos
local cPrviBroj
local bDatum
local nTTRec 
local nTTTRec


if gVrstaRS=="S"
	cIdPos:=SPACE(LEN(gIdPos))
  	closeret // !! nisam implementirao ne sortiranje na serveru !!
else
  	cIdPos:=gIdPos
endif

O_KASE
O_POS
O_DOKS

altd()
cNajstariji:=UzmiIzIni(PRIVPATH+"fmk.ini",'POS','XPM',"-",'READ')

if cNajstariji!="-" .and. (!IsPlanika()) .and. Pitanje(,"Izvrsiti sortiranje racuna ?","N")=="D"
	_IdPos:=cidpos
  	if gSezonaTip=="M"
    		cNewSeason:=Godina_2(gDatum)+padl(month(gDatum),2,"0")
    		bDatum:={|| Godina_2(Datum)+padl(month(Datum),2,"0")}
  	else
    		cNewSeason:=Str(Year(gDatum), 4)
    		bDatum:={||str(year(datum),4) }
  	endif

	fProlupalo:=.f.
	MsgO("Sortiram racune ...")
 	cPrvibroj:="999999"
  	SELECT DOKS 
	SET ORDER TO TAG "7"
  	seek _IdPos+VD_RN+cPrviBroj
  	// ("7", "IdPos+IdVD+BrDok", KUMPATH+"DOKS" )
  	if found()
    		fProlupalo:=.t. 
		// ovo se moze desiti samo ako je sort prekinut!
  	endif

  	set order to tag "1"
  	seek _IdPos+VD_RN+chr(250)
  	skip -1

  	// interesuje me najstariji racun
  	cNajstariji:=UzmiIzIni(PRIVPATH+"fmk.ini",'POS','XPM',"-", 'READ')
  	if cNajstariji="-" .or. cNajstariji="0000"
    		cNajstariji:="0000"
  	endif

  	if fProlupalo
     		MsgBeep("Prosli put je doslo do prekida prilikom sortiranja ???")
  	endif

  	if !fProlupalo  // prilikom proslog sortiranja doslo je do problema
    		lExit:=.f.
    		if cNewSeason!=EVAL(bDatum)
       			MsgBeep("Posljednji racun pripada sezoni "+eval(bDatum)+" ????")
       			MsgC()
       			return
    		endif
    		do while !bof().and.DOKS->IdPos==_IdPos.and.cNewSeason==eval(bDatum).and.DOKS->IdVd==VD_RN.and.DOKS->IdPos<"X".and.(dtos(doks->Datum)+doks->BrDok)>cNajStariji
      			skip -1
      			if cNewSeason<>eval(bDatum)
				exit
			endif
      			if bof() 
				lExit:=.t. 
			endif
      			nTrec:=recno()
      			@ m_x+2,m_y+15 SAY "1/"+doks->brdok
     			if doks->(idpos+idvd)==_idpos+VD_RN
        			skip
        			IF DOKS->IdPos<"X"  .and. !empty(DOKS->IdPos) .and.DOKS->IdVd==VD_RN .and. cNewSeason==eval(bDatum)
          				SELECT POS
          				Seek DOKS->(IdPos+IdVd+dtos(datum)+BrDok)  // promjeni broj
          				DO WHILE ! Eof() .and. POS->(IdPos+IdVd+dtos(datum)+BrDok)==DOKS->(IdPos+IdVd+dtos(datum)+BrDok)
            					skip
						nTTTrec:=recno()
						skip -1
            					// POS
            					replace BrDok with cPrviBroj
            					REPLSQL BrDok with cPrviBroj
            					go nTTTRec
          				enddo
          				select DOKS
          				replace BrDok with cPrviBroj
          				replSQL BrDok with cPrviBroj
          				cPrviBroj:=DecId(cPrviBroj)
        			ENDIF // IdPos<"X"
      			else
        			exit
      			endif  // slijedeci slog je prvi zapis, koji ne zelim dirati
      			go nTrec
      			if lexit 
				exit 
			endif
    		enddo
  	endif

SELECT DOKS

if cNajStariji != "0000"
	// pozicioniranje na prvi sljedeci racun
    	seek _IdPos+VD_RN+ cNajStariji
    	cPrviBroj:=SUBSTR(cNajstariji,9)
else
    	seek _IdPos+VD_RN
    	do while !eof() .and. DOKS->IdPos==_IdPos .and. cNewSeason<>eval(bDatum) .and.DOKS->IdVd=="42" .and. DOKS->IdPos<"X"
      		skip  // preskoci podatke iz stare sezone
    	enddo
    	cPrviBroj:=brdok
endif
altd()
// dosli smo na prvi slog iz tekuce sezone
i:=0
do while !eof() .and. DOKS->IdPos==_IdPos .and. DOKS->IdVd=="42" .and. DOKS->IdPos<"X"
	skip
	nTTrec:=recno() 
	skip -1
    	@ m_x+2,m_y+15 SAY "2/"+str(++i,6)+brdok
    	cOrig:=BrDok
    	if DOKS->IdPos<"X" .and. DOKS->IdVd=="42"
      		select POS
      		seek DOKS->(IdPos+IdVd+dtos(datum)+BrDok)
      		do while !eof() .and. POS->(IdPos+IdVd+dtos(datum)+BrDok)==DOKS->(IdPos+IdVd+dtos(datum)+BrDok)
        		skip
			nTTTrec:=recno()
			skip -1
        		// POS
        		replace BrDok with cPrviBroj
        		replSQL BrDok with cPrviBroj
        		go nTTTRec
      		enddo
      		select DOKS
      		replace BrDok with cPrviBroj
      		replSQL BrDok with cPrviBroj
      		cPrviBroj:=IncId(cPrviBroj)
    	endif // IdPos<"X"
    	//if cOrig="999999"   // moras izaci nakon ovog broja
    	//   exit
    	//endif
    	go nTTrec
enddo
MsgC()

cNajstariji:=UzmiIzIni(PRIVPATH+"fmk.ini",'POS','XPM',"-", 'WRITE')

endif
CLOSERET
*}


/*! \fn PromBrRN()
 *  \brief Promjena broja racuna
 */
 
function PromBrRN()
*{
if !(IdPos=="X " .and. pitanje(,"Promjena broja racuna?","N")=="D" )
	return DE_CONT
endif
select DOKS
cBrojR:=DOKS->BrDok
cNBrojR:=cBrojR
cIdPos:=DOKS->IdPos
cDatum:=dtos(doks->datum)

if empty(dMinDatProm)
        dMinDatProm:=DOKS->datum
else
        dMinDatProm:=min(dMinDatProm,DOKS->datum)
endif

Box(,1,60)
        set cursor on
        @ m_x+1,m_y+2 SAY "Broj:" GET cNBrojR valid cNBrojR<>cBrojR
        read
Boxc()
nTTR:=recno()
seek cIdPos+VD_RN+cDatum+cNBrojR
if found()
         MsgBeep("Racun vec postoji")
         return DE_CONT
endif

if lastkey()==K_ESC
         return DE_CONT
endif


go nTTR
select DOKS    // racuni
replace BrDok with cNbrojR     // brojrn

select POS; set order to 1
Seek cIdPos+VD_RN+cDatum+cBrojR
while !eof() .and. POS->(IdPos+IdVd+dtos(datum)+BrDok)==(cIdPos+VD_RN+cDatum+cBrojR)
        skip; nTTR:=recno(); skip -1
        replace BrDok with cNBrojR   // brojrn
        go nTTR
enddo

return DE_REFRESH
*}


/*! \fn PromIdPMVP()
 *  \brief
 */
 
function PromIdPMVP()
*{    
if KLevel<="0" .and. !SigmaSif(gStela)
       MsgBeep("Ne cackaj")
       return DE_CONT
endif

if Pitanje(,"Promjeniti id prod mjesta za vremenski period?","N")=="N"
       return DE_CONT
endif

dDat:=gDatum-1   // jucerasnji datum
cVrijOd:="17:00"
cVrijDo:="23:59"
cNBroj:=space(6)
Box(,3,60)
      set cursor on
      @ m_x+1,m_y+2 SAY "Skloni na X za datum:" get dDat
      @ m_x+3,m_y+2 SAY "za racune u vremenu:" GET cVrijOd
      @ m_x+3,col()+2 SAY "do" GET cVrijDo valid cVrijDo>=cVrijOd
      read
BoxC()
if lastkey()==K_ESC; return DE_CONT; endif
select DOKS; set order to 1
// "1", "IdPos+IdVd+dtos(datum)+BrDok"
set scope to
seek gIdPos+"42"+dtos(dDat)  //postavi scope
do while !eof() .and. gIdPos+"42"+dtos(dDat)==doks->(idpos+idvd+dtos(datum))
     
     if  !(Vrijeme>=cVrijOd .and. Vrijeme<=cVrijDo)
       skip; loop
     endif

     cBrojR:=DOKS->BrDok; cIdPos:=DOKS->IdPos; cDatum:=dtos(DOKS->datum)
     dDatum:=doks->datum

     cPMjesto:="X "
     cPMjesto2:=gIdPos

     nTrec:=recno(); skip; nTrec2:=recno()

     //"1", "IdPos+IdVd+dtos(datum)+BrDok", KUMPATH+"DOKS")
     seek cPmjesto+"42"+cDatum+cBrojR
     cNBroj:=""
     if found() // vec postoji racun
       cNBroj:=cBrojR
       for ii:=0 to 60
        seek cPmjesto+"42"+cDatum+padl(alltrim(cBrojR)+chr(65+ii),6)
        if !found()
            cNBroj:=padl(alltrim(cBrojR)+chr(65+ii),6)
            exit
        endif
       next
       go nTRec   // DOKS
       replace IdPos with cPMjesto, BrDok with cNBroj
     else
       go nTRec
       replace IdPos with cPMjesto   //DOKS
     endif
     SELECT POS
     seek cPmjesto2+"42"+cDatum+cBrojR
     do while !eof() .and. POS->(IdPos+IdVd+dtos(datum)+BrDok)==(cPMjesto2+"42"+cDatum+cbrojr)
       skip; nTTR:=recno(); skip -1
       replace IdPos with cPMjesto
       if !empty(cNBroj)
         replace BrDok with cNBroj
       endif
       go nTTR
     enddo
     select DOKS
     go nTrec2

enddo
set scope to
 
return DE_REFRESH
*}


/*! \fn PromIdPM()
 *  \brief Promjena oznake prodajnog mjesta
 */
 
function PromIdPM()
*{
MsgBeep("Prije pokretanja ove opcije obavezno##napraviti arhivu podataka !!!")

if Pitanje(,"Promjeniti id prod mjesta ?","N")=="N"
	return DE_CONT
endif
nSljedR:=1

cNBroj:=space(6)
select DOKS; set order to 1
skip ; nSljedR:= recno(); skip -1  // zapamti sljedeci racun

set scope to  // ukini scope da se moze seekovati
cBrojR:=DOKS->BrDok; cIdPos:=DOKS->IdPos; cDatum:=dtos(DOKS->datum)
dDatum:=doks->datum

if empty(dMinDatProm)
	dMinDatProm:=DOKS->datum
else
	dMinDatProm:=min(dMinDatProm,DOKS->datum)
endif

if cIdPos<>"X "
	cPMjesto:="X "
	cPMjesto2:=DOKS->IdPos
else
	cPMjesto:=gIdPos
	cPMjesto2:="X "
endif
nTrec:=recno()

//CREATE_INDEX ("1", "IdPos+IdVd+dtos(datum)+BrDok", KUMPATH+"DOKS")
Seek cPmjesto+"42"+cDatum+cBrojR
if found()
	set cursor on
	MsgBeep("Racun vec postoji na prodajnom mjestu")
	Box(,2,50)
 		@ m_x+2,m_y+2 SAY "Novi broj:" GET cNBroj  valid !empty(cNBroj)
	read
	BoxC()
	
	if lastkey()==K_ESC; return DE_CONT; endif

	cNBroj:=padl(alltrim(cNBroj), 6)
	Seek cPmjesto+VD_RN+cDatum+cNBroj
	if found()
  		MsgBeep("I ovaj broj postoji")
  		RETURN DE_REFRESH
	else
  		go nTRec
  		if IdPos<"X"  // prodajno mjesto je regularno
   			cZadnji:=UzmiIzIni(PRIVPATH+"fmk.ini",'POS','XPM',"-", 'READ')
   			if cZadnji="-" .or. (dtos(datum)+brdok)<cZadnji // ako je stariji
				UzmiIzIni(PRIVPATH+"fmk.ini",'POS','XPM',dtos(datum)+brdok,'WRITE')
  			endif
		endif
  		replace IdPos with cPMjesto, BrDok with cNBroj
	endif
else
	go nTrec

	if IdPos<"X"  // prodajno mjesto je regularno
   		cZadnji:=UzmiIzIni(PRIVPATH+"fmk.ini",'POS','XPM',"-", 'READ')
   		if cZadnji="-" .or. (dtos(datum)+brdok)<cZadnji // ako je stariji
			UzmiIzIni(PRIVPATH+"fmk.ini",'POS','XPM',dtos(datum)+brdok,'WRITE')
   		endif
	endif

	replace IdPos with cPMjesto
endif

SELECT POS
seek cPmjesto2+VD_RN+cDatum+cBrojR
while !eof() .and. POS->(IdPos+IdVd+dtos(datum)+BrDok)==(cPMjesto2+VD_RN+cDatum+cbrojr)
	skip; nTTR:=recno(); skip -1
	replace IdPos with cPMjesto
	if !empty(cNBroj)
  		replace BrDok with cNBroj
	endif
	go nTTR
enddo
select DOKS
go nSljedR  // pozicioniraj se na normalno mjesto

return (DE_REFRESH)
*}


/*! \fn BrisiRNVP()
 *  \brief Nesto se brise...
 */
 
function BrisiRNVP()
*{
if Pitanje(,"Potpuno - fizicki izbrisati racune za period ?","N")=="N"
	return DE_CONT
endif

dDatOd:=dDatDo:=date()
Box(,2,60)
        set cursor on
        @ m_x+1,m_y+2 SAY "Period " GET dDatOd
        @ m_x+1,col()+2 SAY "-" GET dDatDo
        read
Boxc()
if lastkey()==K_ESC
	return DE_CONT
endif


if empty(dMinDatProm)
        dMinDatProm:=DOKS->datum
else
        dMinDatProm:=min(dMinDatProm,DOKS->datum)
endif

select DOKS      // racuni
cFilt1:="DATUM>="+cm2str(dDatOd)+".and.DATUM<="+cm2str(dDatDo)+".and.IDVD=='42'"
set filter to &cFilt1
go top
do while !eof()
        select DOKS    // racuni
        skip; nTTRac:=recno(); skip -1

        cBrojR:=BrDok          // broj
        cIdPos:=IdPos
        cDatum:=dtos(datum)

        delete
        sql_azur(.t.)
        sql_delete()

        SELECT POS
        seek cIdPos+"42"+cDatum+cBrojR
        while !eof() .and. POS->(IdPos+IdVd+dtos(Datum)+BrDok)==(cIdPos+"42"+cDatum+cBrojR)
           skip; nTTR:=recno(); skip -1
           delete
           sql_azur(.t.)
           sql_delete()

           go nTTR
        enddo

        select DOKS
        go nTTRac
enddo
select DOKS
set filter to
go top
return DE_REFRESH
*}


/*! \fn KL_PRacuna()
 *  \brief Korisnicka Lozinka Pregleda Racuna
 */
function KL_PRacuna()
*{
Box("#PR", 4, 34, .f.)
	@ m_x+2,m_y+2 SAY "Stara lozinka..."
    	@ m_x+4,m_y+2 SAY "Nova lozinka...."
    	nSifLen := 6
    	do while .t.
      		SET CURSOR ON
      		cKorSif:=SPACE(nSifLen)
      		cKorSifN:=SPACE(nSifLen)
      		@ m_x+2,m_y+19 GET cKorSif PICTURE "@!" COLOR Nevid
      		@ m_x+2, col() SAY "<" COLOR "R/W"
      		@ m_x+2, col()-len(cKorSif)-2 SAY ">" COLOR "R/W"
      		@ m_x+4, col()+6 SAY " "
      		@ m_x+4, col()-len(cKorSifN)-2 SAY " "
        	READ
        	if LASTKEY()==K_ESC
			EXIT
		endif
      		@ m_x+4,m_y+19 GET cKorSifN PICTURE "@!" COLOR Nevid
      		@ m_x+4, col() SAY "<" COLOR "R/W"
      		@ m_x+4, col()-len(cKorSifN)-2 SAY ">" COLOR "R/W"
      		@ m_x+2, col()+6 SAY " "
     		@ m_x+2, col()-len(cKorSif)-2 SAY " "
        	READ
        	if LASTKEY()==K_ESC
			EXIT
		endif
      		nMax:=MAX(LEN(cKorSif),LEN(gStela))
      		if PADR(cKorSif,nMax)==PADR(gStela,nMax) .and. !EMPTY(cKorSifN)
        		UzmiIzIni(KUMPATH+"FMK.INI","KL","PregledRacuna",;
                  	CryptSC(TRIM(cKorSifN)),"WRITE")
        		gStela:=CryptSC(IzFmkIni("KL","PregledRacuna",CryptSC("STELA"),KUMPATH))
        		MsgBeep("Sifra promijenjena!")
      		endif
    	enddo
    	SET CURSOR OFF
    	SETCOLOR (Normal)
BoxC()
return
*}



/*! \fn Presort2()
 *  \brief Presortirati racune - popuni "rupe"
 */
 
function Presort2()
*{
local _IdPos
local cPrviBroj
local bDatum
local nTTRec 
local nTTTRec
local lImaNezakRN

if gVrstaRS=="S"
	cIdPos:=SPACE(LEN(gIdPos))
	closeret // !! nisam implementirao ne sortiranje na serveru !!
else
	cIdPos:=gIdPos
endif

O_KASE
O_POS
O_DOKS

//local aRecNo:={}
aDbf:={ {"brdok","C",len(doks->brdok),0}, {"drn","N",8,0}, {"brst","N",4,0} }
NaprPom(aDbf,"DRECNO")
aDbf:={ {"prn","N",8,0} }
NaprPom(aDbf,"PRECNO")
select 0
usex (PRIVPATH+"DRECNO.DBF") alias DRECNO
select 0
usex (PRIVPATH+"PRECNO.DBF") alias PRECNO

cNajstariji:=UzmiIzIni(PRIVPATH+"fmk.ini",'POS','XPM',"-",'READ')

if cNajStariji!="-"
	MsgBeep("Prije pokretanja ove opcije napravite##arhivu podataka, ako niste napravili arhivu##na sljedece pitanje odgovorite sa N.")
endif

if cNajstariji!="-" .and. (!IsPlanika()) .and. Pitanje(,"Izvrsiti sortiranje racuna ?","N")=="D"

	_IdPos:=cidpos

	if gSezonaTip=="M"
		cNewSeason:=Godina_2(gDatum)+padl(month(gDatum),2,"0")
		bDatum:={|| Godina_2(Datum)+padl(month(Datum),2,"0")}
	else
		cNewSeason:=Str(Year(gDatum), 4)
		bDatum:={||str(year(datum),4) }
	endif

	fProlupalo:=.f.

	MsgO("Sortiram racune ...")

	cPrvibroj:="999999"

	SELECT DOKS 
	SET ORDER TO TAG "7"
	seek _IdPos+VD_RN+cPrviBroj
	// ("7", "IdPos+IdVD+BrDok", KUMPATH+"DOKS" )

	if found()
		fProlupalo:=.t. 
		// ovo se moze desiti samo ako je sort prekinut!
	endif

	set order to tag "1"
	seek _IdPos+VD_RN+chr(250)
	skip -1
	// DOKS pozicioniran na posljednjem racunu

	if fProlupalo
		MsgBeep("Prosli put je doslo do prekida prilikom sortiranja ???")
	endif

	if !fProlupalo  // prilikom proslog sortiranja doslo je do problema

		lExit:=.f.

		if cNewSeason!=EVAL(bDatum)
			MsgBeep("Posljednji racun pripada sezoni "+eval(bDatum)+" ????")
			MsgC()
			return
		endif

		do while !bof().and.DOKS->IdPos==_IdPos.and.cNewSeason==eval(bDatum).and.DOKS->IdVd==VD_RN.and.DOKS->IdPos<"X"

			skip -1
			if bof() 
				lExit:=.t. // nema vise starijih racuna
			endif

			@ m_x+2,m_y+15 SAY "1/"+doks->brdok
			if doks->(idpos+idvd)==_idpos+VD_RN
				if !lExit
					skip 1
				endif
				IF DOKS->IdPos<"X"  .and. !empty(DOKS->IdPos) .and.DOKS->IdVd==VD_RN .and. cNewSeason==eval(bDatum)
					select drecno
					append blank
					replace brdok with doks->brDok, drn with doks->(recno())
					select pos
					seek DOKS->(IdPos+IdVd+dtos(datum)+BrDok)  // promjeni broj
					nStavka:=0

					do while ! eof() .and. POS->(IdPos+IdVd+dtos(datum)+BrDok)==DOKS->(IdPos+IdVd+dtos(datum)+BrDok)
						// POS
						//AADD(aRecNo[LEN(aRecNo),2],RECNO())
						select precno
						append blank
						++nStavka
						replace prn with pos->(recno())
						select pos
						skip 1
					enddo

					select drecno
					replace brst with nStavka
					select DOKS
				ENDIF // IdPos<"X"
			else
				exit
			endif

			skip -1

			if lexit 
				exit 
			endif
		enddo
	endif

	select doks

#ifdef PROBA
	altd()
#endif

	cNoviBroj:=PADL("1",LEN(doks->brDok))
	altd()
	select precno
	go bottom

	select drecno
	if reccount()>0
		go bottom
		do while !bof()
			if drecno->brdok<>cNoviBroj
				select doks
				go (drecno->drn)
				replace brDok with cNoviBroj
				replSQL brDok with cNoviBroj
				// ovo nista nevalja
				
				for j:=1 to drecno->brst
					select pos
					go (precno->prn)
					replace brDok with cNoviBroj
					replSQL brDok with cNoviBroj
					
					select precno
					skip 1
				next
				select precno
				go nTRecNo
			endif
			cNoviBroj:=IncId(cNoviBroj)
			select drecno
			skip -1
			// uzmi vrijednost koliko skipova treba
			nSkip:=drecno->brst
			select precno
			skip -nSkip
			nTRecNo:=RecNo()
			
		enddo
	endif

	MsgC()

	cNajstariji:=UzmiIzIni(PRIVPATH+"fmk.ini",'POS','XPM',"-", 'WRITE')

	O__POS
	go top
	lImaNezakRN:=.f.
	do while !eof()
		if m1<>"Z"
			lImaNezakRN:=.t.
			skip 1
			loop
		endif
		skip 1
		nRec:=RECNO()
		skip -1
		delete
		go (nRec)
	enddo

	__dbpack()
	if lImaNezakRN
		MsgBeep("Ima nezakljucenih racuna! Obradite ih!")
	endif

endif
CLOSERET
return
*}

