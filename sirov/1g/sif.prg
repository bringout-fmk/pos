#include "\cl\sigma\fmk\pos\pos.ch"

/*
 * ----------------------------------------------------------------
 *                                     Copyright Sigma-com software 
 * ----------------------------------------------------------------
 * $Source: c:/cvsroot/cl/sigma/fmk/pos/sirov/1g/sif.prg,v $
 * $Author: sasa $ 
 * $Revision: 1.2 $
 * $Log: sif.prg,v $
 * Revision 1.2  2002/06/17 09:15:23  sasa
 * no message
 *
 *
 */
 

/*! \fn P_Sirov2(cIdRoba)
 *  \brief
 *  \param cIdRoba
 */
 
function P_Sirov2(cIdRoba)
*{

P_Sirov(@cIdRoba)
_cijena:=sirov->cijena1
_ncijena:=_cijena
_robanaz:=SIROV->Naz
_jmj:=SIROV->Jmj
return .t.
*}


/*! \fn P_Sast(cId,dx,dy)
 *  \brief
 *  \param cId
 *  \param dx
 *  \param dy
 */
 
function P_Sast(cId,dx,dy)
*{
private ImeKol
private Kol

ImeKol:={ }
Kol:={}

ImeKol:={ { padr("Sifra",10),  {|| id },     "id"   , {|| .t.}, {|| vpsifra(wId),VIdSast(wId)} },;
          { padr("Naziv",40), {|| naz},     "naz"      },;
          { padr("JMJ",3),    {|| jmj},     "jmj"    },;
          { padr("Cijena(1)",10 ), {|| transform(cijena1,"999999.999")}, "cijena1"   },;
          { padr("Cijena(2)",10 ), {|| transform(cijena2,"999999.999")}, "cijena2"   },;
          { "Tarifa",{|| IdTarifa}, "IdTarifa", {|| .t. }, {|| P_Tarifa(@wIdTarifa)}   },;
          { "Odjeljenje",{|| idodj}, "idodj", {|| .t. }, {|| Empty(wIdOdj).or.P_Odj(@widodj) }   } ;
        }


for i:=1 to LEN(ImeKol)
	AADD(Kol,i)
next
return PostojiSifra(F_ROBA,1,17,77,"Pregleda got. proizvoda: <ENTER> Unos norme, <Ctrl-F4> Kopiraj normu",@cid,dx,dy,{|Ch| SastBlok(Ch)})

return
*}


/*! \fn SastBlok(Ch2)
 *  \brief
 *  \param Ch2
 */
 
function SastBlok(Ch2)
*{
local nUl
local nIzl
local nRezerv
local nRevers
local fOtv:=.f.
local nIOrd
local nFRec
local aStanje

if Ch2==K_ENTER // pregled sastavnice
	nTRobaRec:=recno()
 	private cIdTek:=id
 	select sast
 	set order to tag id
 	set scope to cidTEk
 	private ImeKol:={;
          { "Id2"       , {|| id2 }  , "id2", {|| .t.}, {|| wid:=cIdTek, p_sirov(@wid2)} },;
          { "Naziv"  , {|| id2naz()} ,"" },;
          { "kolicina"  , {|| kolicina}  , "kolicina"      };
        }
 	private Kol:={1,2,3}
 	PostojiSifra(F_SAST,1,10,70,cIDTEK+"-"+roba->naz,,,,,,,,.f.)
 	//clear typeahead
 	//keyboard K_DOWN
 	Ch:=K_DOWN
 	set scope to
 	// samo lista robe

 	select roba
 	set order to tag "ID"
 	go nTrobaRec
 	return DE_REFRESH
elseif Ch2=K_CTRL_F4
  	nTRobaRec:=recno()
  	if Pitanje(,"Formirati novi normativ po uzoru na postojeci","N")=="D"
     		cNoviProizvod:=SPACE(10)
     		cIdTek:=id
     		Box(,2,60)
       			@m_x+1,m_y+2 SAY "Proizvod:" GET cNoviProizvod pict "@!" valid cNoviProizvod<>cIdTek .and. p_RobaPOS(@cNoviProizvod)
       			read
     		BoxC()
     		if LASTKEY()<>K_ESC
      			select sast
			set order to tag id
      			seek cidtek
      			do while !eof() .and. id==cIdTek
        			nTRec:=recno()
        			scatter()
        			_id:=cNoviProizvod
        			append blank
				Gather()
        			go nTrec
				skip
      			enddo
      			select roba
      			set order to tag "ID"
     		endif
  	endif
  	go nTrobaRec
  	return DE_REFRESH

elseif Ch=K_CTRL_T
	if Pitanje(,"Izbrisati definisani normativ za ovaj proizvod ?","D")=="D"
       		select sast
		set order to tag id
       		seek roba->id   // brisi u sastavnici
       		do while !eof() .and. id==roba->id
          		skip
			nTRec:=recno()
			skip -1
          		delete
          		go nTrec
       		enddo
       		select roba
  	endif
  	return DE_CONT

elseif Ch=K_F10  // ostale opcije
	private opc[3]
       	opc[1]:="1. zamjena sirovine u svim sastavnicama                 "
       	opc[2]:="2. promjena ucesca pojedine sirovine u svim sastavnicama"
       	opc[3]:="3. promjena jedinice mjere za sirovinu"
       	h[1]:=h[2]:=""
       	private am_x:=m_x,am_y:=m_y
       	private Izbor:=1
       	do while .t.
        	Izbor:=menu("o_sast",opc,Izbor,.f.)
          	do case
            		case Izbor==0
                		EXIT
            		case izbor == 1
                		cOldS:=space(10)
                		cNewS:=space(10)
                		nKolic:=0
                		Box(,6,70)
                		@ m_x+1,m_y+2 SAY "'Stara' sirovina :" GET cOldS pict "@!" valid P_Sirov(@cOldS)
                		@ m_x+2,m_y+2 SAY "'Nova'  sirovina :" GET cNewS pict "@!" valid cNews<>cOldS .and. P_Sirov(@cNewS)
                		@ m_x+4,m_y+2 SAY "Kolicina u normama (0 - zamjeni bez obzira na kolicinu)" GET nKolic pict "999999.99999"
                		read
                		BoxC()
                		if LASTKEY()<>K_ESC
                			select sast
					set order to
                			go top
                			do while !eof()
                				if id2==cOldS
                					if nKolic=0 .or. round(nKolic-kolicina,5)=0
                       						replace id2 with cNewS
                					endif
                				endif
                				skip
                			enddo
                			set order to tag ID
                		endif
            		case izbor == 2
                		cOldS:=space(10)
                		cNewS:=space(10)
                		nKolic:=0
                		nKolic2:=0
                		Box(,6,65)
                  		@ m_x+1,m_y+2 SAY "Sirovina :" GET cOldS pict "@!" valid P_Sirov(@cOldS)
                  		@ m_x+4,m_y+2 SAY "postojeca kolicina u normama " GET nKolic pict "999999.99999"
                  		@ m_x+5,m_y+2 SAY "nova kolicina u normama      " GET nKolic2 pict "999999.99999"   valid nKolic<>nKolic2
                  		read
                		BoxC()
                		if LASTKEY()<>K_ESC
                  			select sast
					set order to
                  			go top
                  			do while !eof()
                    				if id2==cOldS
                       					if round(nKolic-kolicina,5)=0
                        					replace kolicina with nKolic2
                       					endif
                    				endif
                    				skip
                  			enddo
                  			set order to tag ID
                		endif
            		case izbor == 3
                		cOldS:=space(10)
                		cNewS:=space(10)
                		nKolic:=0
                		nKolic2:=0
                		cDN="N"
                		Box(,6,65)
                  		@ m_x+1,m_y+2 SAY "Sirovina :" GET cOldS pict "@!" valid P_Sirov(@cOldS)
                  		@ m_x+4,m_y+2 SAY "pomnoziti kolicine u normama sa" GET nKolic pict "999999.99999"
                  		@ m_x+5,m_y+2 SAY "Nastaviti D/N ? " GET cDN pict "@!"   valid cDN$"DN"
                  		read
                		BoxC()
                		if LASTKEY()<>K_ESC
                  			select sast
					set order to
                  			go top
                  			do while !eof()
                    				if id2==cOldS
                       					replace kolicina with nKolic*kolicina
                    				endif
                    				skip
                  			enddo
                  			set order to tag ID
                		endif
          	endcase
       	enddo
       	m_x:=am_x; m_y:=am_y
	return DE_CONT
endif

return DE_CONT
*}



/*! \fn VIdSast(wId)
 *  \brief
 *  \param wId
 */
 
function VIdSast(wId)
*{
if wId<>roba->id
	if Pitanje(,"Promjeniti sifru za ovaj normativ ?","N")=="D"
        	select sast
		set order to tag id
        	seek wId // nova sifra
        	if found()
           		MsgBeep("Vec postoji proizvod sa sifrom "+wId)
           		select roba
           		return .f.
        	endif
        	seek roba->id   // brisi u sastavnici
        	do while !eof() .and. id==roba->id
           		skip
			nTRec:=recno()
			skip -1
           		replace id with wId
           		go nTrec
        	enddo
        	select roba
        	return .t.
   	else
     		return .f.
   	endif
endif
return .t.
*}

