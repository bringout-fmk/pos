#include "\cl\sigma\fmk\pos\pos.ch"

/*
 * ----------------------------------------------------------------
 *                                     Copyright Sigma-com software 
 * ----------------------------------------------------------------
 * $Source: c:/cvsroot/cl/sigma/fmk/pos/sif/1g/sif.prg,v $
 * $Author: sasavranic $ 
 * $Revision: 1.14 $
 * $Log: sif.prg,v $
 * Revision 1.14  2004/02/09 14:09:00  sasavranic
 * Apend sql loga i za sif osoblja
 *
 * Revision 1.13  2003/12/24 09:54:36  sasavranic
 * Nova varijanta poreza, uvrstene standardne funkcije za poreze iz FMK
 *
 * Revision 1.12  2003/09/01 09:02:10  sasa
 * uvedeno polje ugovor u rngost (tigra-aura)
 *
 * Revision 1.11  2003/06/16 17:30:55  sasa
 * generacija zbirnog racuna
 *
 * Revision 1.10  2003/01/19 23:44:18  ernad
 * test network speed (sa), korekcija bl.lnk
 *
 * Revision 1.9  2002/12/27 12:42:27  sasa
 * dodat unos inicijalne vrijednosti za popunjavanje polja IDN u rngost
 *
 * Revision 1.8  2002/12/26 11:54:04  sasa
 * dodato polje oznaka u rngost
 *
 * Revision 1.7  2002/12/22 20:42:18  sasa
 * dorade
 *
 * Revision 1.6  2002/06/30 20:28:44  ernad
 *
 *
 *
 * pos meni za odabir firme /MNU_INI
 *
 * Revision 1.5  2002/06/19 19:46:47  ernad
 *
 *
 * rad u sez.podr., debug., gateway
 *
 * Revision 1.4  2002/06/17 08:58:49  sasa
 * no message
 *
 *
 */
 
/*! \fn P_Kase(cId,dx,dy)
 *  \brief Otvara sifrarnik kasa ako se u uslovu za kase postavi ID koji ne postoji
 *  \param cId    - Id kase
 *  \param dx     - koordinata ispisa
 *  \param dy     - koordinata ispisa
 *  \return PostojiSifra(...)
 */
 
function P_Kase(cId,dx,dy)
*{
private ImeKol
private Kol

SELECT (F_KASE)
if !used()
	O_KASE
endif

ImeKol:={}
AADD(ImeKol,{"Sifra/ID kase",{||id},"id"})
AADD(ImeKol,{"Naziv kase",{||Naz },"Naz"})
AADD(ImeKol,{"Lokacija kumulativa",{||pPath},"pPath"})
Kol:={1,2,3}

return PostojiSifra(F_KASE,1, 10, 77, "Sifarnik kasa/prodajnih mjesta", @cId, dx, dy)
*}


/*! \fn Id2Naz()
 *  \brief
 */
 
function Id2Naz()
*{
local nSel:=SELECT()

Pushwa()
SELECT sirov
HSEEK sast->id2
popwa()

return LEFT(sirov->naz,25)
*}


/*! \fn P_RobaPOS(cId,dx,dy)
 *  \brief Dopusta unos robe s tipovima " "-obicna i "I"-inventar
 *  \param cId
 *  \param dx
 *  \param dy
 */
 
function P_RobaPOS(cId,dx,dy)
*{
local aZabrane
private ImeKol
private Kol:={}

ImeKol:={}

AADD(ImeKol, { padr("Sifra",10),  {|| id },     "id"   , {|| .t.}, {|| vpsifra(wId)} })
AADD(ImeKol, { padr("Naziv",40), {|| naz},     "naz"      })

AADD(ImeKol, { padr("JMJ",3),    {|| jmj},     "jmj"    })
AADD(ImeKol, { padr("Cijena(1)",10 ), {|| transform(cijena1,"999999.999")}, "cijena1"   })
AADD(ImeKol, { padr("Cijena(2)",10 ), {|| transform(cijena2,"999999.999")}, "cijena2"   })
AADD(ImeKol, { "Tarifa",{|| IdTarifa}, "IdTarifa", {|| .t. }, {|| P_Tarifa(@wIdTarifa)}   })
if gVodiOdj=="D"
	AADD(ImeKol, { "Odjeljenje",{|| idodj}, "idodj", {|| .t. }, {|| P_Odj(@widodj) }   })
endif
AADD(ImeKol, { "Tip",{|| " "+Tip+" "}, "Tip", {|| .t.}, {|| .t.} })
AADD(ImeKol, { "Djeljiv",{|| " "+Djeljiv+" "}, "Djeljiv", {|| .t.}, {|| EMPTY (wDjeljiv) .or. wDjeljiv $ "DN"} })

if roba->(fieldpos("BARKOD"))<>0
	AADD(ImeKol, { padr("BARKOD",13),  {|| barkod },     "barkod"    , {|| .t.},  {|| P_BarKod(wBarKod)}  })
endif

if roba->(fieldpos("K1"))<>0
	AADD (ImeKol,{ padc("K1",4 ), {|| k1 }, "k1"   })
	AADD (ImeKol,{ padc("K2",4 ), {|| k2 }, "k2"   })
endif
if roba->(fieldpos("mink"))<>0
	AADD (ImeKol,{ padc("MINK",10 ), {|| transform(MINK,"999999.99")}, "MINK"   })
endif

if roba->(fieldpos("N2"))<>0
	AADD (ImeKol,{ padc("N1",10 ), {|| transform(N1,"999999.99")}, "N1"   })
  	AADD (ImeKol,{ padc("N2",10 ), {|| transform(N2,"999999.99")}, "N2"   })
endif

if roba->(fieldpos("K7"))<>0
    	AADD (ImeKol,{ padc("K7",2 ), {|| k7 }, "k7"   })
    	AADD (ImeKol,{ padc("K8",2 ), {|| k8 }, "k8"   })
    	AADD (ImeKol,{ padc("K9",3 ), {|| k9 }, "k9"   })
endif

for i:=1 to LEN(ImeKol)
	AADD(Kol,i)
next


if gSifK="D"
	PushWa()
	select sifk
	set order to tag "ID"
	seek "ROBA"
	do while !eof() .and. ID="ROBA"
 		AADD (ImeKol, {  IzSifKNaz("ROBA",SIFK->Oznaka) })
 		AADD (ImeKol[Len(ImeKol)], &( "{|| padr(ToStr(IzSifk('ROBA','" + sifk->oznaka + "')),10) }" ) )
 		AADD (ImeKol[Len(ImeKol)], "SIFK->"+SIFK->Oznaka )
 		if sifk->edkolona > 0
   			for ii:=4 to 9
    				AADD( ImeKol[Len(ImeKol)], NIL  )
   			next
   			AADD( ImeKol[Len(ImeKol)], sifk->edkolona  )
 		else
   			for ii:=4 to 10
    				AADD( ImeKol[Len(ImeKol)], NIL  )
   			next
 		endif
 		// postavi picture za brojeve
 		if sifk->Tip="N"
   			if decimal > 0
     				ImeKol[Len(ImeKol),7]:=replicate("9", sifk->duzina-sifk->decimal-1 )+"."+replicate("9",sifk->decimal)
   			else
     				ImeKol[Len(ImeKol),7]:=replicate("9", sifk->duzina )
   			endif
 		endif

 		AADD(Kol,iif( sifk->UBrowsu='1',++i, 0) )
 		skip
	enddo
	PopWa()
endif

if KLevel="3"
	aZabrane:={K_CTRL_T,K_CTRL_N,K_F4,K_F2,K_CTRL_F9}
elseif KLevel="2" .or.  (klevel=="1" .and. gSifUpravn=="N")
  	aZabrane:={K_CTRL_T,K_F4,K_F2,K_CTRL_F9}
else
  	aZabrane:={}
endif

if IzFmkIni('CROBA','GledajTops','N',KUMPATH)=='N'
	return PostojiSifra(F_ROBA,I_ID,15,77,"Sifrarnik robe/artikala",@cId,dx,dy,nil,nil,nil, aZabrane)
else
  	return PostojiSifra(F_ROBA,I_ID,15,77,"Sifrarnik robe/artikala",@cId,dx,dy,{|Ch| RobaBlok(Ch)},,,aZabrane)
endif

return
*}


/*! \fn RobaBlok(ch)
 *  \brief
 *  \param ch
 */
 
function RobaBlok(Ch)
*{
local nArr:=SELECT()
local cSif:=ROBA->id

if IzFmkIni('CROBA','GledajTops','N',KUMPATH)=='D'
	if UPPER(CHR(Ch))=="C"
      		cIdRoba:=ID
      		seek cSif
      		TB:Stabilize()  // problem sa "S" - exlusive, htc

      		CRobaNDan(cIdRoba)

      		cSQL:="select  stanjem,stanjev,ulazm,ulazv,realm,realv from croba where idrobafmk="+sqlvalue(cIdroba)
      		aRez:=sqlselect("c:\sigma\sql","sc",cSQL,{"N","N","N","N","N","N"})
      		if aRez[1,1]='ERR'.or.aRez[1,2]=0
       			_Stanjem:=0
       			_Stanjev:=0
       			_Ulazm:=0
       			_Ulazv:=0
       			_Realm:=0
       			_Realv:=0
      		else
       			_Stanjem:=aRez[2,1]
       			_Stanjev:=aRez[2,2]
       			_Ulazm:=aRez[2,3]
       			_Ulazv:=aRez[2,4]
       			_Realm:=aRez[2,5]
       			_Realv:=aRez[2,6]
      		endif

      		Box(,15,75)
      			@ m_x+ 1,m_y+2 SAY "Artikal : "+cSif+"-"+TRIM(ROBA->NAZ) COLOR INVERT
      			@ m_x+ 3,m_y+2 SAY "Pocetno stanje MP: "+STR(_StanjeM)
      			@ m_x+ 4,m_y+2 SAY "Ulaz           MP: "+STR(_UlazM)
      			@ m_x+ 5,m_y+2 SAY "Realizacija    MP: "+STR(_RealM)
      			@ m_x+ 6,m_y+2 SAY "-------------------------------------"
      			@ m_x+ 7,m_y+2 SAY "STANJE         MP: "+STR(_StanjeM+_UlazM-_RealM)
      			@ m_x+ 8,m_y+2 SAY "-------------------------------------"
      			@ m_x+ 9,m_y+2 SAY "Pocetno stanje VP: "+STR(_StanjeV)
      			@ m_x+10,m_y+2 SAY "Ulaz           VP: "+STR(_UlazV)
      			@ m_x+11,m_y+2 SAY "Realizacija    VP: "+STR(_RealV)
      			@ m_x+12,m_y+2 SAY "-------------------------------------"
      			@ m_x+13,m_y+2 SAY "STANJE         VP: "+STR(_StanjeV+_UlazV-_RealV)
      			@ m_x+14,m_y+2 SAY "-------------------------------------"
      			@ m_x+15,m_y+2 SAY "STANJE      MP+VP: "+STR(_StanjeM+_UlazM-_RealM+_StanjeV+_UlazV-_RealV)
      			INKEY(0)
      		BoxC()
      		return 6  // DE_CONT2
  	 endif
endif
RETURN DE_CONT
*}



/*! \fn LMarg()
 *  \brief
 */
 
function LMarg()
*{
return "   "
*}


/*! \fn P_Sirov(cId,dx,dy)
 *  \brief
 *  \param cId
 *  \param dx
 *  \param dy
 */
 
function P_Sirov(cId,dx,dy)
*{
private ImeKol
private Kol:={}

ImeKol:={{padr("Sifra",10),{|| id },"id",{||.t.},{||VPSifra(wId)}},{padr("Naziv",40),{|| naz},"naz"},{ padr("JMJ",3),{|| jmj},"jmj"},{"Tarifa",{|| IdTarifa},"IdTarifa",{|| .t. },{|| P_Tarifa(@wIdTarifa)}},{"Odjeljenje",{|| idodj},"IdOdj",{||.t.},{||Empty(wIdOdj).or.P_Odj(@widodj)}}}

for i:=1 to LEN(ImeKol)
	AADD(Kol,i)
next

if gSifK="D"
	PushWa()
	select sifk
	set order to tag "ID"
	seek "SIROV"
	do while !eof() .and. ID="SIROV"
		AADD (ImeKol, {  IzSifKNaz("SIROV",SIFK->Oznaka) })
 		AADD (ImeKol[Len(ImeKol)], &( "{|| padr(ToStr(IzSifk('SIROV','" + sifk->oznaka + "')),10) }" ) )
 		AADD (ImeKol[Len(ImeKol)], "SIFK->"+SIFK->Oznaka )
 		if sifk->edkolona > 0
   			for ii:=4 to 9
    				AADD( ImeKol[Len(ImeKol)], NIL  )
   			next
   			AADD( ImeKol[Len(ImeKol)], sifk->edkolona  )
 		else
   			for ii:=4 to 10
    				AADD( ImeKol[Len(ImeKol)], NIL  )
   			next
 		endif
 		// postavi picture za brojeve
 		if sifk->Tip="N"
   			if decimal > 0
     				ImeKol[Len(ImeKol),7]:=replicate("9", sifk->duzina-sifk->decimal-1 )+"."+replicate("9",sifk->decimal)
   			else
     				ImeKol[Len(ImeKol),7]:=replicate("9", sifk->duzina )
   			endif
 		endif

 		AADD(Kol,iif( sifk->UBrowsu='1',++i, 0) )

 		skip
	enddo
	PopWa()
endif

return PostojiSifra(F_SIROV,I_ID,15,77,"Sifrarnik sirovina",@cId,dx,dy,)
*}


/*! \fn P_Tarifa(cId,dx,dy)
 *  \brief
 *  \param cId
 *  \param dx
 *  \param dy
 */
 
function P_Tarifa2(cId,dx,dy)
*{
local aZabrane
private ImeKol
private Kol:={}

ImeKol:={{"ID ",{|| id },"id",{|| .t.},{|| vpsifra(wId)}},{PADC("Naziv",10),{|| left(naz,10)},"naz"},{"PPP ",{|| opp},"opp"},{"PPU ",{|| ppp},"ppp"},{"PP  ",{|| zpp},"zpp"},{"P.na Marzu",{|| vpp},"vpp"}}

for i:=1 to LEN(ImeKol)
	AADD(Kol,i)
next

if KLevel="3"
	aZabrane:={K_CTRL_T,K_CTRL_N,K_F4,K_F2,K_CTRL_F9}
elseif KLevel="2"  .or. (klevel=="1" .and. gSifUpravn=="N")
  	aZabrane:={K_CTRL_T,K_F4,K_F2,K_CTRL_F9}
else
  	aZabrane:={}
endif
return PostojiSifra(F_TARIFA,I_ID,10,55,"Sifrarnik tarifnih grupa",@cid,dx,dy,;
                      NIL, NIL, NIL, aZabrane)

*}


/*! \fn P_Odj(cId,dx,dy)
 *  \brief
 *  \param cId
 *  \param dx
 *  \param dy
 */
 
function P_Odj(cId,dx,dy)
*{
private ImeKol
private Kol:={}

ImeKol:={{"ID ",{|| id },"id",{|| .t.},{|| vpsifra(wId)}},{PADC("Naziv",25),{|| naz},"naz"},{"Konto u KALK",{|| IdKonto},"IdKonto"}}

if gModul=="HOPS"
	AADD (ImeKol, { "Zaduzuje R/S",{|| PADC (ZADUZuje, 12)}, "Zaduzuje", {|| .T.}, {|| wZaduzuje $ "RS"} })
endif

for i:=1 to LEN(ImeKol)
	AADD(Kol,i)
next
return PostojiSifra(F_ODJ,I_ID,10,40,"Sifarnik odjeljenja", @cId,dx,dy)
*}


/*! \fn P_Dio(cId,dx,dy)
 *  \brief
 *  \param cId
 *  \param dx
 *  \param dy
 */
 
function P_Dio(cId,dx,dy)
*{
private ImeKol
private Kol:={}

ImeKol:={{"ID ",{|| id },"id",{|| .t.},{|| vpsifra(wId)}},{PADC("Naziv",25),{|| naz},"naz"}}

for i:=1 to LEN(ImeKol)
	AADD(Kol,i)
next
return PostojiSifra(F_DIO,I_ID,10,55,"Sifrarnik dijelova objekta",@cid,dx,dy)
*}


/*! \fn P_StRad(cId,dx,dy)
 *  \brief
 */
 
function P_StRad(cId,dx,dy)
*{
private ImeKol
private Kol:={}

ImeKol:={ { "ID ",  {|| id },       "id"  , {|| .t.}, {|| vpsifra(wId)}      },;
          { PADC("Naziv",15), {|| naz},       "naz"       },;
          { "Prioritet"     , {|| PADC(prioritet,9)}, "prioritet", {|| .T.}, {|| ("0" <= wPrioritet) .AND. (wPrioritet <= "3")} } ;
        }

for i:=1 to LEN(ImeKol)
	AADD(Kol,i)
next
return PostojiSifra(F_STRAD,I_ID,10,55,"Sifrarnik statusa radnika",@cid,dx,dy)
*}



/*! \fn P_VrsteP(cId,dx,dy)
 *  \brief
 */
 
function P_VRSTEP(cId,dx,dy)
*{

private ImeKol
private Kol:={}

ImeKol:={ { "ID ",  {|| id },       "id"  , {|| .t.}, {|| vpsifra(wId)}      },;
          { PADC("Naziv",20), {|| naz},      "naz"       };
        }

for i:=1 to LEN(ImeKol)
	AADD(Kol,i)
next
return PostojiSifra(F_VRSTEP,I_ID,10,55,"Sifrarnik vrsta placanja",@cid,dx,dy)
*}


/*! \fn P_Gosti(cId,dx,dy)
 *  \brief
 */
 
function P_Gosti(cId,dx,dy)
*{

local aZabrane
private ImeKol
private Kol:={}

if gModul=="TOPS"
	ImeKol:={{"ID ",{|| id },"id",{|| .t.},{|| vpsifra(wId)}},{PADC("Naziv",30),{|| naz},LEFT("naz",30)},{"Tip",{|| tip},"tip",{|| wTip:=iif(empty(wTip),"P",wTip),.T.},{|| wTip$"SP"}},{"Aktivan",{|| PADC(IIF(Status=="D","DA","NE"),7)},"Status",{|| wStatus:=iif(empty(wStatus),"D",wStatus), .t.},{|| wStatus $ "DN"}}}
	
	if IsTigra()
		AADD(ImeKol,{"Ugovor",{|| ugovor},"ugovor"})
		AADD(ImeKol,{"IDN",{|| idn},"idn",{|| IncIDN(@wIDN),.f.},{||.t.},,"999999"})
		AADD(ImeKol,{"IDFMK",{|| idfmk},"idfmk"})
		AADD(ImeKol,{"OZNAKA",{|| oznaka},"oznaka"})
		AADD(ImeKol,{"HH",{|| hh},"hh"})
	endif
else
	ImeKol:={{"ID ",{|| id },"id",{|| .t.},{|| vpsifra(wId)}},{ PADC("Naziv",30),{|| naz},LEFT("naz",30)},{"Tip",{|| tip},"tip",{|| wTip:=iif(empty(wTip),"P",wTip),.T.},{|| wTip$"SP"}},{"Vrsta placanja",{|| IdVrsteP},"IdVrsteP",{|| .T.},{|| P_VRSTEP(@wIdVrsteP)}},{"Aktivan",{|| PADC(IIF(Status=="D","DA","NE"),7)},"Status",{|| wStatus:=iif(empty(wStatus),"D",wStatus), .T.},{|| wStatus $ "DN"}}}
endif

for i:=1 to LEN(ImeKol)
	AADD(Kol,i)
next

if KLevel="3"
	aZabrane:={K_CTRL_T,K_CTRL_N,K_F4,K_F2,K_CTRL_F9}
elseif KLevel="2"
  	aZabrane:={K_CTRL_T,K_F4,K_F2,K_CTRL_F9}
else
  	aZabrane:={}
endif

if gModul="TOPS"
	if IsTigra()
		return PostojiSifra(F_RNGOST,I_ID,10,75,"Sifrarnik partnera",@cid,dx,dy,{|Ch| PopuniIDN(Ch)},nil,nil,aZabrane)
	else
		return PostojiSifra(F_RNGOST,I_ID,10,75,"Sifrarnik partnera",@cid,dx,dy,nil,nil,nil,aZabrane)
	endif
else 
	return PostojiSifra(F_RNGOST,I_ID,10,75,"Sifrarnik partnera/soba",@cid,dx,dy,NIL, NIL, NIL, aZabrane)
endif 
*}


function PopuniIDN(Ch)
*{
nBrojac:=0
nIDN:=1
nRecNo:=RecNo()
if (Ch==K_CTRL_G .and. Pitanje(,"Popuniti polja IDN za postojece partnere?","N")=="D")
      	TB:Stabilize()  
	Box(,1,30)
		@ m_x+1,m_y+2 SAY "Pocetna vrijednost:" GET nIDN PICT "999999"
		read
	BoxC()	
	do while !eof()
		if field->idn<>0
			skip
			loop
		else
			replace idn with nIDN
			++nIDN
			++nBrojac
			skip
		endif
	enddo
	MsgBeep("Popunjena polja idn za postojece partnere.##Broj polja:"+ALLTRIM(STR(nBrojac)))
endif
go nRecNo
return DE_CONT
*}

static function IncIDN(wId)
*{
local nRet:=.t.

if ((Ch==K_CTRL_N) .or. (Ch==K_F4))
	if (LastKey()==K_ESC)
		return nRet:=.f.
	endif
	nRecNo:=RecNo()
	set order to tag "IDN"
	wId:=LastIDN(nRecNo)+1
	set order to
	AEVAL(GetList,{|o| o:display()})
endif
return nRet
*}

static function LastIDN(nRecNo)
*{
go bottom
nLastID:=field->idn
go nRecNo
return nLastID
*}




/*! \fn P_Osob(cId, dx, dy)
 *  \brief
 */
 
function P_Osob(cId, dx, dy)
*{
private ImeKol
private Kol:={}

ImeKol:={ { "ID ",          {|| id },    "id", {|| .t.}, {|| vpsifra(wId)} },;
          { PADC("Naziv",40), {|| naz},  "naz"    },;
          { "Korisn.sifra", {|| korsif}, "korsif" },;
          { "Status",       {|| status}, "status" };
        }

for i:=1 to LEN(ImeKol)
	AADD(Kol,i)
next

return PostojiSifra(F_OSOB, I_ID2, 10, 55, "Sifrarnik osoblja", @cid, dx, dy, {|| EdOsob()})
return
*}


/*! \fn P_Valuta(cId, dx, dy)
 *  \brief 
 */
 
function P_Valuta(cId, dx, dy)
*{
private ImeKol
private Kol

ImeKol:={ { "ID "       , {|| id }   , "id"        , {|| .t.}, {|| vpsifra(wId)}},;
          { "Naziv"     , {|| naz}   , "naz"       },;
          { "Skrac."    , {|| naz2}  , "naz2"      },;
          { "Datum"     , {|| datum} , "datum"     },;
          { "Kurs1"     , {|| kurs1} , "kurs1"     },;
          { "Kurs2"     , {|| kurs2} , "kurs2"     },;
          { "Kurs3"     , {|| kurs3} , "kurs3"     },;
          { "Tip(D/P/O)", {|| tip}   , "tip"       ,{|| .t.},{|| wtip$"DPO"}};
        }
Kol:={1,2,3,4,5,6,7,8}

return PostojiSifra(F_VALUTE, 1, 10, 77, "Sifrarnik valuta", @cid, dx, dy)
*}


/*! \fn P_Uredj(cId, dx, dy)
 *  \brief
 */
 
function P_Uredj(cId, dx, dy)
*{
private ImeKol
private Kol:={}

ImeKol:={ { "ID ",  {|| id },       "id"  , {|| .t.}, {|| vpsifra(wId)}      },;
          { PADC("Naziv",30), {|| naz},      "naz"       },;
          { "Port", {|| port},      "port"       };
        }

for i:=1 to LEN(ImeKol)
	AADD(Kol,i)
next

return PostojiSifra(F_UREDJ,I_ID,10,55,"Sifrarnik uredjaja",@cid,dx,dy)
*}



/*! \fn P_MJTRUR(cId,dx,dy)
 *  \brief
 */
 
function P_MJTRUR(cId,dx,dy)
*{
private ImeKol
private Kol:={}

ImeKol:={{ "Uredjaj",     {|| iduredjaj }, "IdUredjaj", {|| .t.}, {|| P_Uredj(wIdUredjaj)}},;
	 { "Odjeljenje",  {|| IdOdj },     "IdOdj"    , {|| .t.}, {|| P_Odj(wIdOdj)}},;
	 { "Dio objekta", {|| IdDio },     "IdDio"    , {|| .t.}, {|| P_Dio(wIdDio)}} ;
        }

for i:=1 to LEN(ImeKol)
	AADD(Kol,i)
next
return PostojiSifra(F_MJTRUR, I_ID, 10, 55, "Sifrarnik parova uredjaj-odjeljenje", @cid, dx, dy)
*}


/*! \fn P_RobaIz(cId,dx,dy)
 *  \brief
 */
 
function P_RobaIz(cId,dx,dy)
*{
private ImeKol
private Kol:={}

ImeKol:={{"IdRoba",      {|| IdRoba }, "IdRoba", {|| .t.}, {|| P_Roba(wIdRoba)}},;
         {"Dio objekta", {|| IdDio },  "IdDio",  {|| .t.}, {|| P_Dio(wIdDio)}} ;
        }

for i:=1 to LEN(ImeKol)
	AADD(Kol,i)
next

return PostojiSifra(F_ROBAIZ,I_ID,10,55,"Sifrarnik iznimki kod izuzimanja robe",@cid,dx,dy)
*}


/*! \fn EdOsob()
 *  \brief
 */
 
function EdOsob()
*{
local System:=(KLevel<L_UPRAVN)
local nVrati:=DE_CONT

do case
	case Ch==K_CTRL_N
		if gSamoProdaja=="D"
         		MsgBeep("SamoProdaja=D#Nemate ovlastenje za ovu opciju !")
         		nVrati:=DE_CONT
      		else
      			if System
         			Scatter()
         			_korsif:=space(6)
         			if GetOsob(.t.)<>K_ESC
           				// azuriranje OSOB.DBF
           				_korsif:=CryptSC(_korsif)
           				APPEND BLANK
					sql_append()
           				Gather()
           				GathSql()
					sql_azur(.t.)
					nVrati:=DE_REFRESH
         			endif
      			endif
      		endif
  	case Ch==K_F2
      		if gSamoProdaja=="D"
             		MsgBeep("SamoProdaja=D#Nemate ovlastenje za ovu opciju !")
             		nVrati:=DE_CONT
      		else
      			if System
          			Scatter()
          			_korsif:=CryptSC(_korsif)
          			if GetOsob(.f.)<>K_ESC
            				// azuriranje OSOB.DBF
            				_korsif:=CryptSC(_korsif)
            				Gather()
					GathSql()
					sql_azur(.t.)
            				nVrati:=DE_REFRESH
          			endif
      			endif
      		endif
  	case Ch==K_CTRL_T
     		if gSamoProdaja=="D"
         		MsgBeep("Nemate ovlastenje za ovu opciju !")
         		nVrati:=DE_CONT
     		else
     			if System
      				if Pitanje(,"Izbrisati korisnika "+ trim(naz) +":"+CryptSC(korsif)+" D/N ?","N")=="D"
       					// azuriranje OSOB.DBF
         				SELECT osob
         				DELETE
         				sql_delete()
         				nVrati:=DE_REFRESH
      				endif
     			endif
     		endif
  	case Ch==K_ESC .or. Ch==K_ENTER
     		nVrati:=DE_ABORT
endcase

if ch==K_ALT_R .or. ch==K_ALT_S .or. ch==K_CTRL_N .or. ch==K_F2 .or. ch==K_F4 .or. ch==K_CTRL_A .or. ch==K_CTRL_T .or. ch==K_ENTER
	ch:=0
endif
return nVrati
*}



/*! \fn GetOsob(fNovi)
 *  \brief
 *  \param fNovi
 */
 
function GetOsob(fNovi)
*{
local cLevel

Box("",4,60,.f.,"Unos novog korisnika,sifre")
SET CURSOR ON
if fNovi.or.KLevel=="0"
	@ m_x+1,m_y+2 SAY "Sifra radnika (ID)." GET _id VALID vpsifra(_id)
else
	@ m_x+1,m_y+2 SAY "Sifra radnika (ID). "+_id
endif
@ m_x+2,m_y+2 SAY "Ime radnika........" GET _naz
read

SELECT strad
HSEEK gStRad
cLevel:=strad->prioritet

SELECT strad
HSEEK _status
select osob

// level tekuceg korisnika > level
if (cLevel>strad->prioritet)  
	MsgBeep("Ne mozete mjenjati sifru")
else
	@ m_x+3,m_y+2 SAY "Sifra.............." GET _korsif PICTURE "@!" VALID vpsifra2(_korsif,_id)
 	@ m_x+4,m_y+2 SAY "Status............." GET _status VALID P_STRAD(@_status)
endif

READ
BoxC()
return lastkey()
*}


/*! \fn VPSifra2(cSifra,cIme)
 *  \brief
 *  \param cSifra
 *  \param cIme
 */
 
static function VPSifra2(cSifra,cIme)
*{
local lRet:=.t.
local nObl:=SELECT()

if EMPTY(cSifra)
	Beep (3)
   	return (.f.)
endif

O_KORISN
GO TOP
do while !eof()
	if (korisn->sif==CryptSC(cSifra).and. korisn->ime!=cIme)
    		BEEP(3)
    		lRet:=.f.
    		EXIT
  	endif
  	SKIP 1
enddo
USE
SELECT (nObl)
return lRet
*}



/*! \fn PomMenu1(aNiz)
 *  \brief
 *  \param aNiz
 */
 
function PomMenu1(aNiz)
*{
local xP:=ROW()
local yP:=COL()
local xN
local yN
local dP:=LEN(aNiz)+1
local sP:=0

AEVAL(aNiz,{|x| IF(LEN(x[1]+x[2])>sP,sP:=LEN(x[1]+x[2]),)})
sP+=3
xN:=IF(xP>11,xP-dP,xP+1)
yN:=IF(yP>39,yP-sP,yP+1)
Prozor1(xN,yN,xN+dP,yN+sP-1,"POMOC")

for i:=1 to dP-1
	@ xN+i,yN+1 SAY PADR(aNiz[i,1]+"-"+aNiz[i,2],sP-2)
next

@ xP,yP SAY ""

return
*}



/*! \fn P_Barkod(cBK)
 *  \brief
 *  \param cBK
 */
 
function P_Barkod(cBK)
*{
local fRet:=.f.
local nRec:=recno()

PushWa()
set order to tag "BARKOD"
seek cBK
if !empty(cBK) .and. found() .and. nRec<>RECNO()
	MsgBeep("Isti barkod pridruzen je sifri: "+id+" ??!")
       	PopWa()
       	return .f.
endif

// trazi alternativne sifre
if !empty(cBK)
	cID:=""
   	ImaUSifV("ROBA","BARK", cBK, @cId)
   	if !empty(cID)
     		select roba
		set order to tag "ID"
		seek cId  // nasao sam sifru !!
     		MsgBeep("Isti barkod pridruzen je sifri: "+id+" ??!")
     		PopWa()
     		return .f.
   	endif
endif

PopWa()
return .t.
*}


/*! \fn P_Roba2(cIdRoba)
 *  \brief
 *  \param cIdRoba
 */
 
function P_Roba2(cIdRoba)
*{
P_robaPOS(@cIdRoba)

if !EMPTY(ROBA->IdOdj).and.ROBA->IdOdj<>cIdOdj
	MsgBeep("Artikal ne pripada ovom odjeljenju!")
    	return .f.
endif

_cijena:=roba->cijena1
_ncijena:=_cijena
_robanaz:=ROBA->Naz
_jmj:=ROBA->Jmj

return .t.
*}

function ISast()
*{
qqProiz:=SPACE(60)
cBrisi:="N"
do while .t.
	Box(,3,60)
 		@ m_x+1,m_y+2 SAY "Proizvodi :" GET qqProiz  pict "@!S30"
 		@ m_x+3,m_y+2 SAY "Brisanje prekinutih sastavnica :" GET cBrisi  pict "@!" valid cBrisi $ "DN"
 		read
	BoxC()

private aUsl1:=Parsiraj(qqProiz,"Id")
if aUsl1<>NIL; exit; endif
enddo

select sast
START PRINT CRET

if aUsl1==".t."
    set filter to
else
    set filter to &aUsl1
endif


m:="--------------------------------------------------------------------------------------------"
nCol1:=60
P_12CPI
nStr:=0

if cBrisi=="D"
  select sast; set order to; go top
  do while !eof()
     skip; nTrec:=recno(); skip -1
     select roba; hseek sast->id  // nema "svog proizvoda"
     if !found()
       select sast; delete
     endif
     select sast
     go nTRec
  enddo
  select sast; set order to tag "ID"; go top
endif

?
? "PREDUZECE: _____________________________"
?
? "Pregled sastavnica-normativa za proizvode na dan",date()
?
? padl("Strana:"+str(++nStr,2),80)
?
go top
do WHILE !EOF()
  cId:=id
  select roba; hseek sast->id; select sast
  if prow()>60; FF; ? padl("Strana:"+str(++nStr,2),80); ?;endif
  ?
  ? LMARG()+m
  ? LMARG()+roba->id, trim(roba->naz)+" ("+trim(roba->jmj)+")"
  @ prow(),60 SAY roba->cijena1 pict "999999.99"
  ?? "", gDomValuta
  ? LMARG()+m
  //? "                                                              Kolicina       NV         MPV"
  nRbr:=0
  nNC:=0
  nVPC:=0
  do WHILE cid==id .and. !eof()
      if prow()>56; FF; ? padl("Strana:"+str(++nStr,2),80);?; endif
      select sirov; hseek sast->id2; select sast
      ? LMARG()+str(++nrbr,5)+"."
      @ prow(),pcol()+1 SAY sirov->id
      @ prow(),pcol()+1 SAY padr(trim(sirov->naz)+" ("+trim(sirov->jmj)+")",40)
      @ prow(),pcol()+1 SAY kolicina pict "999999.9999"
      nCol1:=pcol()+1
      @ prow(),pcol()+1 SAY "__________"
      @ prow(),pcol()+1 SAY "__________"
      skip
  enddo
  ? lmarg()+m
enddo

FF
END PRINT

select roba
set filter to
select sirov
set filter to
select sast
set filter to

return
*}


