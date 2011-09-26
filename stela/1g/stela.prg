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

O_SIFK
O_SIFV
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
//Presort2()
RnPresort(dDatOd)

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
 *  \brief Brisanje racuna za period
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


// kreiranje tabela pomocnih doks_st i pos_st
function cre_pdtbl_st()
*{

close all
FErase(PRIVPATH + "POS_ST.DBF")
FErase(PRIVPATH + "POS_ST.CDX")
FErase(PRIVPATH + "DOKS_ST.DBF")
FErase(PRIVPATH + "DOKS_ST.CDX")

O_POS
select pos
copy structure to (PRIVPATH+"struct")
create (PRIVPATH + "pos_st") from (PRIVPATH + "struct")

O_DOKS
select doks
copy structure to (PRIVPATH+"struct")
create (PRIVPATH + "doks_st") from (PRIVPATH + "struct")

create_index("1","idpos+idvd+DToS(datum)+brdok", PRIVPATH+"pos_st")
create_index("1","idpos+idvd+DToS(datum)+brdok", PRIVPATH+"doks_st")

return
*}

// brisanje pomocnih tabela pos_st i doks_st
function brisi_pd_st()
*{
close all

FErase(PRIVPATH + "DOKS_ST.DBF")
FErase(PRIVPATH + "DOKS_ST.CDX")
FErase(PRIVPATH + "POS_ST.DBF")
FErase(PRIVPATH + "POS_ST.CDX")

return .t.
*}


// nova funkcija presortiranja racuna
function RnPresort(dDatOd)
*{
local _IdPos
local bDatum

cNajstariji:=UzmiIzIni(PRIVPATH+"fmk.ini",'POS','XPM',"-",'READ')

if cNajstariji == "-"
	// nemas sta sortirati
	return
endif

if Empty(dDatOd)
	MsgBeep("Datum ne smije biti prazan !!!!")
	return
endif

if gVrstaRS=="S"
	cIdPos:=SPACE(LEN(gIdPos))
	closeret // !! nisam implementirao ne sortiranje na serveru !!
else
	cIdPos:=gIdPos
endif

// kreiraj pomocne tabele
cre_pdtbl_st()

O_KASE
O_POS
O_DOKS

select 0
usex (PRIVPATH+"POS_ST.DBF") alias POS_ST
select 0
usex (PRIVPATH+"DOKS_ST.DBF") alias DOKS_ST

if cNajstariji != "-" .and. (!IsPlanika()) .and. Pitanje(,"Izvrsiti sortiranje racuna ?","N")=="D"

	_IdPos:=cIdPos

	// postavi filter na period od datod >= pa do kraja tabele za "42"
	cFilter:="idpos ==" + Cm2Str(_idPos) + " .and. idvd ==" + Cm2Str(VD_RN)
	// dodaj godinu
	cFilter+=" .and. DToS(datum) >= " + Cm2Str(DToS(dDatOd))

	// otvori box
	Box(,5,60)
	
	@ 1+m_x, 2+m_y SAY "Sortiranje racuna u toku..." COLOR "I"
	@ 2+m_x, 2+m_y SAY "Sort od datuma " + DToC(dDatOd)

	select pos
	set filter to &cFilter
	set order to tag "1"
	go top
	
	select doks 
	set filter to &cFilter
	set order to tag "1"
	go top

	// brojac sklanjanja u pomocne tabele
	nSkCnt := 0
	
	do while !EOF() .and. DOKS->IdPos == _IdPos .and. DOKS->IdVd == VD_RN .and. DOKS->IdPos < "X"

		++ nSkCnt
		@ m_x+3,m_y+2 SAY "Sklanjam rn.br: 42-" + ALLTRIM(doks->brdok)
		@ m_x+4,m_y+2 SAY "Obradio: " + ALLTRIM(STR(nSkCnt))
		
		select doks
		Scatter()
		select doks_st
		append blank
		Gather()
					
		select pos
		hseek DOKS->(IdPos+IdVd+dtos(datum)+BrDok)  
		do while !EOF() .and. POS->(IdPos+IdVd+dtos(datum)+BrDok) == DOKS->(IdPos+IdVd+dtos(datum)+BrDok)
						
			Scatter()
			select pos_st
			append blank
			Gather()
					
			select pos
			skip
		enddo
				
		select doks
		skip	
		
	enddo
	
	// ako je doks_st prazna nemam sta raditi
	select doks_st
	if RecCount() == 0
		// nemam sta raditi izadji
		return
	endif

	// ako je pak puna tabela brisi dokumente za period koji zelimo srediti
	
	@ 3+m_x, 2+m_y SAY SPACE(60)
	@ 4+m_x, 2+m_y SAY SPACE(60)
	
	@ 3+m_x, 2+m_y SAY "Brisem stavke u POS i DOKS..."
	
	filt_br_doks()
	filt_br_pos()
	
	// ukini filtere
	select pos
	set filter to
	select doks
	set filter to
	
	@ 3+m_x, 2+m_y SAY SPACE(60)
	@ 4+m_x, 2+m_y SAY SPACE(60)

	// nadji novi broj dokumenta
	cNBrDok := NarBrDok(gIdPos, VD_RN)
	
	// prebaci stavke iz pos_st i doks_st
	
	@ 3+m_x, 2+m_y SAY "Generisem novi sort racuna..."
	
	select doks_st
	set order to tag "1"
	go top

	do while !EOF()
		
		@ 4+m_x, 2+m_y SAY "Racun broj: 42-" + ALLTRIM(cNBrDok)
		// uzmi postojeci broj radi seek-a na pos_st
		cStBroj := doks_st->brdok
		cIdFir := doks_st->idpos
		dDDok := doks_st->datum
		
		Scatter()
		_brdok := cNBrDok
		select doks
		append blank
		Gather()
		
		// predji na pos
		select pos_st
		set order to tag "1"
		hseek  cIdFir + VD_RN + DTOS(dDDok) + cStBroj
		
		do while !EOF() .and. pos_st->(idpos+idvd+DToS(datum)+brdok) == cIdFir + VD_RN + DToS(dDDok) + cStBroj
			
			Scatter()
			_brdok := cNBrDok
			select pos
			append blank
			Gather()
			
			select pos_st
			skip
		enddo
	
		select doks
		cNBrDok := NarBrDok(gIdPos, VD_RN)
		
		select doks_st
		skip
	enddo

	BoxC()

	__dbpack()

	// upisi u INI XPM=- / gotova operacija
	
	cNajstariji:=UzmiIzIni(PRIVPATH+"fmk.ini",'POS','XPM',"-", 'WRITE')

	if !brisi_pd_st()
		MsgBeep("Nisam izbrisao pomocne tabele !!!")
	endif

endif

CLOSERET
return
*}


// brisi doks po filteru
function filt_br_doks()
*{
select doks
go top
do while !EOF()
	delete
	skip
enddo
return
*}

// brisi pos po filteru
function filt_br_pos()
*{
select pos
go top
do while !EOF()
	delete
	skip
enddo
return
*}


