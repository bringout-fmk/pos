#include "\cl\sigma\fmk\pos\pos.ch"

/*
 * ----------------------------------------------------------------
 *                                     Copyright Sigma-com software 
 * ----------------------------------------------------------------
 * $Source: c:/cvsroot/cl/sigma/fmk/pos/sirov/1g/sirov.prg,v $
 * $Author: sasa $ 
 * $Revision: 1.2 $
 * $Log: sirov.prg,v $
 * Revision 1.2  2002/06/17 09:35:46  sasa
 * no message
 *
 *
 */
 

/*! \fn GenUtrSir(dDatOd,dDatDo,cSmjena)
 *  \brief Generisanje utroska sirovina
 *  \param dDatOd    - datum od:
 *  \param dDatDo    - datum do:
 *  \param cSmjena   - smjena
 */
 
function GenUtrSir(dDatOD,dDatDo,cSmjena)
*{
local cIdPos
private fTekuci

if cSmjena==nil
	cSmjena:=""
	fTekuci:=.f.
else
	// generise se pri zakljucenju/ulasku u izvjestaje
  	fTekuci:=.t.
endif

if Pcount()==0
	// kad radim forsirano generisanje utroska sirovina
  	Box(,5,60)
  	dDatOd:=CTOD("")
  	dDatDo:=gDatum    // DATE()
  	cSmjena := ""
  	@ m_x+1,m_y+5 Say "Generisi za period pocevsi od:" GET dDatOd
  	@ m_x+3,m_y+5 Say "                 zakljucno sa:" GET dDatDo
  	READ
  	ESC_BCR
  	BoxC()
endif

MsgO("SACEKAJTE ... GENERISEM UTROSAK SIROVINA ...")

O_PRIPRG

if gSifK=="D"
	O_SIFK
	O_SIFV
endif

O_SAST
O_ROBA
O_SIROV
O_ODJ
O_DIO
O_DOKS
O_POS

if empty(cSmjena) // za period ponovo izgenerisi
	select DOKS
	set order to 2 // IdVd+DTOS (Datum)+Smjena
  	// prvo pobrisem stare dokumente razduzenja sirovina
  	Seek "96"+DTOS (dDatOd)
  	do while !eof() .and. DOKS->IdVd=="96" .and. DOKS->Datum<=dDatDo
    		@ m_x+1 , m_y+15 SAY "B/"+dtoc(datum)+Brdok
    		SELECT POS
    		Seek DOKS->(IdPos+IdVd+dtos(datum)+BrDok)
    		do while !eof() .and. POS->(IdPos+IdVd+dtos(datum)+BrDok)==DOKS->(IdPos+IdVd+dtos(datum)+BrDok)
      			Del_Skip()
    		enddo
    		SELECT DOKS
    		Del_Skip()
  	enddo
endif  // za period ponovo izgenerisi

RazdPoNorm(dDatOd,dDatDo,cSmjena,fTekuci)

MsgC()

CLOSERET
*}


/*! \fn RazdPoNorm(dDatOd,dDatDo,cSmjena,fTekuci)
 *  \brief
 */
 
function RazdPoNorm(dDatOd,dDatDo,cSmjena,fTekuci)
*{
local i:=1
local cVrsta
local fNaso

// ispraznim pripremu
SELECT PRIPRG
Zapp()

Scatter()

SELECT DOKS
Set order to 2

for i:=1 to 2
	if i==1
 		cVrsta:="42"
	else
 		cVrsta:="01"
	endif
	Seek cVrsta+DTOS (dDatOd)
	do while !eof() .and. DOKS->IdVd==cVrsta .and. DOKS->Datum<=dDatDo
  		if fTekuci .and. (DOKS->Smjena<>cSmjena .or. DOKS->M1==OBR_JEST)
    			Skip
			Loop
  		endif
		SELECT POS
  		Seek DOKS->(IdPos+IdVd+dtos(datum)+BrDok)
  		@ m_x+1 , m_y+15 SAY "G/"+dtoc(datum)+Brdok
  		do while !eof() .and. POS->(IdPos+IdVd+dtos(datum)+BrDok)==DOKS->(IdPos+IdVd+dtos(datum)+BrDok)
    			if POS->M1==OBR_JEST
      				Skip
				Loop
    			endif
    			Scatter()     // uzmi podatke o promjeni
    			SELECT SAST
    			Seek _idroba
    			if FOUND()  // idemo po sastavnici
      				do while !eof() .and. SAST->Id==_idroba
        				SELECT SIROV
					HSEEK SAST->Id2
        				if FOUND ()
          					_Cijena := SIROV->Cijena1
        				else
          					_Cijena := 0
        				endif
        				SELECT PRIPRG
        				HSEEK _IdPos+_IdOdj+_IdDio+SAST->Id2+DTOS(_Datum)+_Smjena
        				if !FOUND ()
          					APPEND BLANK // priprg
          					_IdVd:="96"
						_MU_I:=S_I
          					_BrDok:=SPACE(LEN(_BrDok))
          					_IdRadnik:=SPACE(LEN(_IdRadnik))
          					Gather()  // priprg
          					// priprg
          					REPLACE IdRoba WITH SAST->Id2,Kolicina WITH _Kolicina * SAST->Kolicina
        				else
          					REPLACE Kolicina WITH Kolicina + _Kolicina*SAST->Kolicina
        				endif
        				SELECT SAST
					SKIP
      				enddo
    			else // u sastavnici nema robe
      				SELECT PRIPRG 
				HSEEK _IdPos+_IdOdj+_IdDio+_IdRoba+DTOS(_Datum)+_Smjena
      				if !FOUND ()
        				APPEND BLANK
        				_IdVd:="96"
					_MU_I:=S_I
        				_BrDok:=SPACE(LEN(_BrDok))
        				_IdRadnik:=SPACE(LEN(_IdRadnik))
        				Gather() // priprg
      				else
        				// priprg
        				REPLACE Kolicina WITH _Kolicina + Kolicina
      				endif
    			endif
    			SELECT POS
			SKIP
  		enddo // POS
  		SELECT DOKS
  		SKIP
	enddo

next // i

// prebaci dokumente razduzenja u DOKS/POS

SELECT DOKS
Set order to 2
select POS
set order to 1
SELECT PRIPRG
set order to 2
GO TOP
while !eof()
	cIdPos := PRIPRG->IdPos
  	do while !eof() .and. PRIPRG->IdPos==cIdPos
    		xDatum := PRIPRG->Datum
    		do while !Eof() .and. PRIPRG->IdPos==cIdPos .and. PRIPRG->Datum==xDatum
      			xSmjena := PRIPRG->Smjena
      			Scatter()
      			SELECT DOKS
      			Seek "96"+DTOS (xDatum)+xSmjena
      			if !Found()
        			set order to 1
        			cBrDok := _BrDok := NarBrDok (cIdPos, VD_RZS)
        			Set order to 2
        			Append Blank
        			sql_append()
        			Gather()
        			sql_azur(.t.)
        			GathSQL()
      			else
        			cBrDok := ""
        			do while !Eof() .and. DOKS->IdVd=="96" .and. DOKS->Datum==xDatum.and. DOKS->Smjena==xSmjena
          				if DOKS->IdPos==cIdPos
            					cBrDok := DOKS->BrDok
            					EXIT
          				endif
          				SKIP
        			enddo
        			if Empty(cBrDok)  
					// ne postoji RZS za cIdPos
          				set order to 1
          				cBrDok := _BrDok := NarBrDok (cIdPos, VD_RZS)
          				Set order to 2
          				Append Blank
          				sql_append()
          				Gather()
          				sql_azur(.t.)
          				GathSQL()
        			endif
      			endif
      			SELECT PRIPRG    // xDatum je priprg->datum
      			do while !eof() .and. PRIPRG->IdPos==cIdPos .and. PRIPRG->Datum==xDatum.and.PRIPRG->Smjena==xSmjena
        			Scatter()
        			_BrDok := cBrDok
        			_Prebacen := OBR_NIJE
        			fNaso := .f.
        			SELECT POS
        			Seek cIdPos+"96"+dtos(xDatum)+cBrDok+_IdRoba
        			do while !Eof() .and.POS->(IdPos+IdVd+dtos(datum)+BrDok+IdRoba)==cIdPos+VD_RZS+dtos(xDatum)+cBrDok+_IdRoba
          				if POS->Cijena==PRIPRG->Cijena .and.POS->IdCijena==PRIPRG->IdCijena .and. pos->idodj==priprg->idodj
            					fNaso := .t.
            					Exit
          				endif
          				Skip
        			enddo
        			if fNaso
          				// POS
          				REPLACE Kolicina WITH Kolicina+_Kolicina
          				REPLSQL Kolicina WITH Kolicina+_Kolicina
        			else
          				Append Blank
          				sql_append()
          				_BrDok := cBrDok
          				Gather()
          				sql_azur(.t.)
          				GathSQL()
        			endif
        			SELECT PRIPRG
        			SKIP
      			enddo
    		enddo
  	enddo
enddo

// oznaci da si obradio racune

for i:=1 to 2
	if i==1
 		cVrsta:="42"
	else
 		cVrsta:="01"
	endif
	SELECT DOKS
	Set order to 2
	Seek cVrsta+DTOS (dDatOd)
	do while !Eof() .and. DOKS->IdVd==cVrsta .and. DOKS->Datum <= dDatDo
  		if fTekuci .and. (DOKS->Smjena<>cSmjena .or. DOKS->M1==OBR_JEST)
    			Skip
			Loop
  		endif
  		// doks
  		REPLACE M1 WITH OBR_JEST
  		REPLSQL M1 WITH OBR_JEST
  		Skip
	enddo
next //i

SELECT PRIPRG
Zapp()
__dbPack()
return
*}




