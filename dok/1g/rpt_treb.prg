#include "\cl\sigma\fmk\pos\pos.ch"

/*
 * ----------------------------------------------------------------
 *                                     Copyright Sigma-com software 
 * ----------------------------------------------------------------
 * $Source: c:/cvsroot/cl/sigma/fmk/pos/dok/1g/rpt_treb.prg,v $
 * $Author: sasavranic $ 
 * $Revision: 1.3 $
 * $Log: rpt_treb.prg,v $
 * Revision 1.3  2003/12/27 09:00:24  sasavranic
 * Korekcije ispisa trebovanja
 *
 * Revision 1.2  2002/06/15 08:17:46  sasa
 * no message
 *
 *
 */
 
/*! \fn Trebovanja()
 *  \brief Na osnovu sadrzaja _POS ispise trebovanja, ako se ona vode
 */
 
function Trebovanja()
*{
local cNaz
local cJmj

if gVodiTreb=="N"
	return
endif

select _pos
set order to 3   // "IdVd+IdRadnik+GT+IdDio+IdOdj+IdRoba"
seek "42" + gIdRadnik + OBR_NIJE

if gRadniRac=="N"  // gledaj samo kada nisu radni racuni
	if !(_pos->M1 $ "ZS")  // zakljucen ili odstampan!!
  		return
 	endif
endif

MsgO ("GENERISANJE  TREBOVANJA ...")

do while !EOF() .and. _POS->(IdVd+IdRadnik+GT)==("42"+gIdRadnik+OBR_NIJE)
	if !SPrint2(PortZaMT(_POS->IdDio, _POS->IdOdj))
 		MsgBeep ("Stampanje trebovanja nije uspjelo!!!#Ono ce biti odstampano nakon unosa sljedece narudzbe!!!!")
 		MsgC()
 		return
	endif
	select _pos
	Scatter()
	nMTslog:=RECNO()
	?
	?? PADC("TREBOVANJE", 40)
	cTxt:=""
	select odj
	hseek _IdOdj
	if Found()
		cTxt:=ALLTRIM(odj->Naz)
	endif
	select dio
	hseek _IdDio
	if Found()
		cTxt+="-"+ALLTRIM(dio->Naz)
	endif
	? PADC(cTxt, 40)
	? "Kasa: "+_IdPos,space(3),iif(gColleg=="D",day(_datum),FormDat1(_Datum)),"",iif(gColleg=="D","",left(time(),5)),PADL ("Smjena:"+_Smjena, 9)

	? PADC (ALLTRIM(gKorIme), 40)
	?
	? "Sifra/                JMJ  Kolic."
	? "(Naziv)"
	? "----------------------------------"

	select _pos
	do while !EOF() .and. _POS->(IdVd+IdRadnik+GT+IdDio+IdOdj)==(VD_RN+gIdRadnik+OBR_NIJE+_IdDio+_IdOdj)
		cNaz:=_POS->RobaNaz
 		cJmj:=_POS->Jmj
 		cIdRoba  := _POS->IdRoba
 		nKolRobe := 0
		do while !EOF() .and. _POS->(IdVd+IdRadnik+GT+IdDio+IdOdj+IdRoba)==("42"+gIdRadnik+OBR_NIJE+_IdDio+_IdOdj+cIdRoba)
   			// smjesti (dodaj) ovu stavku na trebovanje
   			if gRadniRac=="N" // samo ako nisu radni racuni
    				if !(_pos->m1 $ "ZS")  // zakljucen ili odstampan!!
      					skip
					loop
    				endif
   			endif
   			if _idpos<>gidpos .or. _datum<>gDatum
    				// neznam kako, ali se mozda nadje
    				// Seek2 (cIdPos+"42"+dtos(gDatum)+cRadRac)
    				skip
				loop
   			endif
   			nKolRobe+=_POS->Kolicina
   			SKIP
 		enddo
 		if LEN(TRIM(cIdRoba))>8
			cRazmak:=SPACE(5)
		else
			cRazmak:=SPACE(10)
		endif
		? cIdRoba, cRazmak, cJmj, STR(nKolRobe, 7, 2)
		? "(" + ALLTRIM(cNaz) + ")"
	enddo
	
	// zavrsili smo s jednim mjestom trebovanja
	// posto smo odstampali trebovanje, mogu ga ukloniti
	// moram se vratiti na pocetni slog
	
	SELECT _POS
	GO nMTslog
	do while !eof() .AND. _POS->(IdVd+IdRadnik+GT+IdDio+IdOdj)==("42"+gIdRadnik+OBR_NIJE+_IdDio+_IdOdj)
  		SKIP
		nNarRec:=RECNO()
		SKIP -1
  		REPLACE GT WITH OBR_JEST
  		GO nNarRec
	enddo
	? "----------------------------------"
	PaperFeed()
	END PRN2
enddo   // ! EOF() .and. _POS->(IdVd+IdRadnik+GT)==(VD_RN+gIdRadnik+OBR_NIJE)
MsgC()
return
*}


