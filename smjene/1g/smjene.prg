#include "\cl\sigma\fmk\pos\pos.ch"

/*
 * ----------------------------------------------------------------
 *                                     Copyright Sigma-com software 
 * ----------------------------------------------------------------
 * $Source: c:/cvsroot/cl/sigma/fmk/pos/smjene/1g/smjene.prg,v $
 * $Author: ernad $ 
 * $Revision: 1.4 $
 * $Log: smjene.prg,v $
 * Revision 1.4  2003/01/14 10:32:18  ernad
 * pripreme za tigru ...
 *
 * Revision 1.3  2002/11/21 13:27:20  mirsad
 * ispravka bug-a: varijabla Ch nedefinisana
 *
 * Revision 1.2  2002/06/17 10:55:02  sasa
 * no message
 *
 *
 */
 

/*! \fn OdrediSmjenu(lOdredi)
 *  \brief Odredjivanje smjene
 *  \param lOdredi
 */
 
function OdrediSmjenu(lOdredi)
*{
local cOK:=" "
private dDatum:=gDatum
private cSmjena:=STR(VAL(gSmjena)+1,LEN(gSmjena))
private d_Pos:=d_Doks:=CTOD("")
private s_Pos:=s_Doks:=" "

if lOdredi==nil
	lOdredi:=.t.
endif

O__POS
O_DOKS
set order to 2  // IdVd+DTOS (Datum)+Smjena
Seek VD_RN + Chr (254)
if eof() .or. DOKS->IdVd <> VD_RN
	SKIP -1
endif
// ako je slucajno mijenjan IdPos
do while !bof() .and. DOKS->IdVd==VD_RN .and. DOKS->IdPos <> gIdPos
	SKIP -1
enddo
if DOKS->IdVd == VD_RN
	d_Doks := DOKS->Datum     // posljednji datum i smjena u kojoj
	s_Doks := DOKS->Smjena    // je kasa radila, prema DOKS
endif

SELECT _POS
set order to 2
Seek "42"
if Found()
	// d_Pos := _POS->Datum
	do while !eof() .and. _POS->IdVd==VD_RN
		if _POS->m1<>"Z"
			// racun nije zakljucen, a samo mi je to interesantno
			d_Pos := _POS->Datum
			if _POS->Smjena > s_Pos
				s_Pos := _POS->Smjena
			endif
		endif
		SKIP
	enddo
endif

if d_Pos > d_Doks
	// postoji promet u _POS i to nezakljucen
	dDatum := d_Pos 
	cSmjena := s_Pos
endif

if gVSmjene=="N"
	cSmjena:="1"
  	gSmjena:=cSmjena
	gDatum := dDatum
  	PrikStatus()
  	CLOSERET
endif

Box(,8,50)
@ m_x,m_y+1 SAY " DEFINISANJE DATUMA"+IIF (gVsmjene=="D"," I SMJENE "," ") COLOR INVERT

do while !(cOK $ "Dd")
	BoxCLS()
        @ m_x+2,m_y+5 SAY " DATUM:" GET dDatum VALID DatumOK ()
	@ m_x+4,m_y+5 SAY "SMJENA:" GET cSmjena VALID cSmjena $ "123"
	set cursor on
	@ m_x+6,m_y+5 SAY "Unos u redu (D/N)" GET cOK VALID cOK $ "DN" pict "@!"
	READ
	if LASTKEY()==K_ESC
		LOOP
	endif
	if ProvKonzBaze(dDatum,cSmjena)
		EXIT
	endif
	cOK := " "
enddo
BoxC()

gSmjena:=cSmjena
gDatum := dDatum

PrikStatus()
CLOSERET
*}


/*! \fn DatumOK()
 *  \brief
 */
 
static function DatumOK()
*{

if dDatum>DATE()
	MsgBeep("Morate unijeti datum jedna ili manji od danasnjeg!")
	return (.f.)
endif

return (.t.)
*}


/*! \fn SmjenaOK()
 *  \brief
 */
 
static function SmjenaOK()
*{
if Empty(s_Pos)
	// nema prometa u _POS (nezakljucenog)
	if d_Doks == dDatum .and. cSmjena < s_Doks
		MsgBeep ("Postoje zakljuceni racuni iz smjene "+cSmjena+"!")
		if Pitanje(,"Zelite li nastaviti?", "N")=="N"
			return (.f.)
		endif
	endif
	return (.t.)
endif

if cSmjena>s_Pos
	MsgBeep ("Postoje NEZAKLJUCENI racuni iz smjene "+cSmjena+"!")
	if Pitanje(,"Zelite li nastaviti?", "N")=="N"
		return (.f.)
	endif
endif

if cSmjena<s_Pos
	MsgBeep ("Postoje NEZAKLJUCENI racuni iz starije smjene "+cSmjena+"!")
	return (.f.)
endif

return (.t.)
*}



/*! \fn ProvKonzBaze(dDatum,cSmjena)
 *  \brief Provjerava konzistentnost podataka.
 *  \brief Ako su svi racuni zakljuceni ova funkcija ZAPPuje POS. 
 *  \param dDatum
 *  \param cSmjena
 */
 
function ProvKonzBaze(dDatum, cSmjena)
*{
local dPrevDat
local cPrevSmj
local aRadnici:={}
local n

if Empty(d_POS)
	// nema nezakljucenog prometa u _POS
	? dDatum, d_Doks, cSmjena, s_Doks
	if (dDatum < d_DOKS) .or. (dDatum==d_DOKS) .and. (cSmjena < s_DOKS)
		MsgBeep ("Postoji zakljucen promet na#datum "+FormDat1 (d_DOKS)+" u smjeni "+s_DOKS)
		if Klevel > L_SYSTEM
			MsgBeep ("Vracate se na unos!!!")
			return (.f.)
		else
			MsgBeep ("Rad nastavlja SISTEM ADMINISTRATOR!!!")
		endif
	endif
	if !(d_DOKS==dDatum .and. s_DOKS==cSmjena)
		SELECT _POS
		ZAP
	endif
	return .t.
endif

if d_POS==dDatum
	// ima nezakljucenog prometa
	if cSmjena < s_Pos
		MsgBeep ("Postoje NEZAKLJUCENI racuni iz starije smjene "+cSmjena+"!#"+"Vracate se na unos!!!")
		CLOSE ALL
		return (.f.)
	endif
	if gVsmjene=="D"
		MsgBeep ("POTREBNO JE UNIJETI RACUNE KOJE STE IZDAVALI#"+"BEZ UNOSA U KASU", 20)
	endif
	CLOSE ALL
	return (.t.)
endif

if gVsmjene=="N"
	select _POS
	ZAP
	return .t.
endif

if Pitanje(,"Izvrsiti vanredno zakljucenje kase?","N")=="N"
	MsgBeep ("Vracate se na definisanje datuma i smjene...", 30)
	return .f.
endif

// uzmi datum i smjenu iz _POS
dPrevDat:=d_POS
cPrevSmj:=s_POS

// azuriraj nezakljucene
CLOSE ALL
O_StAzur()

cVrijeme  := LEFT (TIME (), 5)
cIdVrsteP := gGotPlac

SELECT _POS
Set order to 1
SEEK gIdPos
do while !eof() .and. _POS->(IdPos+IdVd)==(gIdPos+VD_RN)
	cRadRac := _POS->BrDok
	Scatter ()
	SELECT DOKS
	cBrDok := _BrDok := NarBrDok (gIdPos, VD_RN)
	_Vrijeme  := cVrijeme
	_IdVrsteP := cIdVrsteP
	_IdOdj    := SPACE (LEN (_IdOdj))
	_M1       := OBR_NIJE
	Append Blank
	sql_append()
	Gather()
	GathSQL()
	SELECT _POS
	while !eof() .and. _POS->(IdPos+IdVd+BrDok)==(gIdPos+VD_RN+cRadRac)
		if _POS->m1=="Z"
			SKIP
			LOOP
		endif
		nRec := RECNO()
		Scatter ()
		_Kolicina := 0
		do while !eof() .and. _POS->(IdPos+IdVd+BrDok)==(gIdPos+VD_RN+cRadRac).and._POS->(IdRoba+IdCijena)==(_IdRoba+_IdCijena) .and. ;
  _POS->Cijena==_Cijena
			if _POS->m1=="Z"
				SKIP
				LOOP
			endif
			_Kolicina += _POS->Kolicina
			SKIP
		enddo
		_Prebacen := OBR_NIJE
		SELECT POS
		_BrDok    := cBrDok
		_Vrijeme  := cVrijeme
		_IdVrsteP := cIdVrsteP
		Append Blank
		sql_append()
		Gather()
		GathSql()
		SELECT _POS
		GO nRec
		do While ! Eof() .and. _POS->(IdPos+IdVd+BrDok)==(gIdPos+VD_RN+cRadRac).and._POS->(IdRoba+IdCijena)==(_IdRoba+_IdCijena) .and. ;
  			_POS->Cijena==_Cijena
			if _POS->m1=="Z"
				SKIP
				LOOP
			endif
			REPLACE m1 WITH "Z"
			SKIP
		enddo
	enddo
enddo

SELECT _POS
SEEK gIdPos+VD_RN
do while !eof() .and. _POS->(IdPos+IdVd)==(gIdPos+VD_RN)
	Del_Skip()
enddo

// prvo izvadim sve radnike koji su radili u predmetnoj smjeni
SELECT DOKS
set order to 2
Seek VD_RN+DTOS (dPrevDat)
do while !eof() .and. DOKS->IdVd=="42" .and. DOKS->Datum==dPrevDat
	n:=ASCAN (aRadnici, DOKS->IdRadnik)
	if n==0
		AADD (aRadnici, DOKS->IdRadnik)
	endif
	SKIP
enddo

// podesim datum i smjenu
SavegDatum:=gDatum 
SavegSmjena:=gSmjena
gDatum:=dPrevDat
gSmjena:=cPrevSmj
SavegIdRadnik:=gIdRadnik

// realizacija radnika, pojedinacno, i kase (finansijski)
for n:=1 to LEN(aRadnici)
	gIdRadnik:=aRadnici[n]
	RealRadnik(.t., "P", .t.)
next
gIdRadnik:=SavegIdRadnik
RealKase(.t.)

// vrati datum i smjenu
gDatum  := SavegDatum
gSmjena := SavegSmjena

CLOSE ALL

PrebNaServer()

return .t.
*}


/*! \fn ZakljRadnik()
 *  \brief Zakljucenje radnika
 */
 
function ZakljRadnik(Ch)
*{
local cIdSave

// M->Ch je iz OBJDB
if Ch<>nil .and. M->Ch==0
	return (DE_CONT)
endif
if LASTKEY()==K_ESC
	return (DE_ABORT)
endif
if UPPER(CHR(LASTKEY())) == "Z"
	if ROUND (ZAKSM->Otv, 4) <> 0
    		MsgBeep ("#Zakljucenje radnika nije moguce!#"+"Postoje nezakljuceni racuni!!!#")
    		return (DE_CONT)
  	endif
    	Beep (3)
  	if !Pitanje(,"Zelite li zakljuciti radnika (D/N)?", " ")=="D"
    		MsgBeep ("Radnik nije zakljucen!")
    		return (DE_CONT)
  	endif
    	cIdSave := gIdRadnik
  	gIdRadnik := ZAKSM->IdRadnik
  	if !RealRadnik(.t.,"P",.t.)
    		// nije uspio stampati pazar radnika, pa ga sad ne mogu ni zakljuciti
    		MsgBeep("Nije uspjelo stampanje pazara!#Radnik nije zakljucen!")
    		gIdRadnik := cIdSave
    		SELECT ZAKSM
    		return (DE_CONT)
  	endif
  	UkloniRadne(ZAKSM->IdRadnik)
  	gIdRadnik := cIdSave
  	SELECT ZAKSM
  	DELETE
	__dbPACK()
  	return (DE_REFRESH)
endif
return (DE_CONT)
*}



/*! \fn NovaSmjGas()
 *  \brief
 */
 
function NovaSmjGas()
*{
local aOpcn[2]
local nIzb
local cOK:=" "

aOpcn [1] := "Otvori novu smjenu"
aOpcn [2] := "Gasenje kase      "

do while .t.
	nIzb:=KudaDalje ("ODABERITE NAREDNU AKCIJU", aOpcn)
  	if nIzb == 1
    		if gDatum==Date()
      			gSmjena := STR (VAL (gSmjena)+1, 1)
    		else
      			// radio je staru smjenu, pa nek unese smjenu danasnjeg dana
      			gDatum := DATE ()
      			MsgBeep("#Zavrsili ste neregularno okoncanu smjenu!#"+"Unesite smjenu koju radite na danasnji dan!#", 30)
      			Box(,5,30)
      			while cOK<>"D"
        			cOK:=" "
        			@ m_x+1,m_y+1 SAY " Datum" GET gDatum WHEN .F.
        			@ m_x+3,m_y+1 SAY "Smjena" GET gSmjena VALID gSmjena $ "123"
        			@ m_x+5,m_y+1 SAY "Unos u redu (D/N)" GET cOK PICT "@!" VALID cOK $ "DN"
        			READ
      			enddo
      			BoxC()
    		endif
    		Exit
  	elseif nIzb==2
    		goModul:quit()
  	endif
enddo
PrikStatus()
return
*}


/*! \fn OtvoriSmjenu()
 *  \brief Otvaranje smjene
 */
 
function OtvoriSmjenu()
*{
local fImaNezak:=.f.

if gVSmjene=="N"
	MsgBeep("Promet kase se ne vodi po smjenama!")
  	return
endif

// potrazi ima li nezakljucenih radnika i obavjesti

O__POS
Seek gIdPos+VD_RN

if FOUND()
	fImaNezak:=.t.
  	MsgBeep ("Postoje nezakljuceni radnici!!!")
  	if Pitanje(,"Zelite li nastaviti s otvaranjem smjene!", " ")=="N"
    		CLOSERET
  	endif
endif

if fImaNezak
	MsgBeep("Kada zakljucite nezakljucene radnike,#"+"Pazar smjene uradite u opciji#"+"IZVJESTAJI / REALIZACIJA / KASE#"+"zadajuci smjenu ciji pazar nije odstampan!")
else
	// odstampam ubiljezeni pazar smjene
  	Close All
  	if !RealKase(.t.)
    		MsgBeep ("#Stampanje pazara smjene nije uspjelo!#")
    		CLOSERET 0
  	endif
  	if gModul=="HOPS"
    		// generisi utrosak sirovina za smjenu
    		GenUtrSir(gDatum,gDatum,gSmjena)
  	endif
endif

gSmjena:=STR(VAL(gSmjena)+1,LEN(gSmjena))
MsgBeep("Otvorena je smjena "+gSmjena)
CLOSERET
*}

