#include "\dev\fmk\pos\pos.ch"


/*! \fn AzurCek(aCKData, nIznRn, cRnBroj, cRnTime)
 *  \brief Azuriranje dokumenta CEK
 *  \param aCKData - matrica sa podacima o ceku
 */
function AzurCek(aCKData, nIznRn, cRnBroj, cRnTime)
*{
local cKupac
local dLKIzd
local dCKIzd

if LEN(aCKData)==0
	return
endif

cKupac:=PADR(aCKData[1], 20)
dLKIzd:=aCKData[7]
dCKIzd:=aCKData[8]

aCK:={}
for i:=2 to 6
	AADD(aCK, aCkData[i])
next


// kreiraj hash string
cCKData:=CreateHashString(aCK)
aTemp:={}
aTemp:=StrToArray(cCkData, 20)

O_DOKS
O_POS

// prvo azuriraj DOKS
select doks
append blank
Sql_Append()
SmReplace("idvd", VD_CK)
SmReplace("idpos", gIdPos)
SmReplace("brdok", cRNBroj)
SmReplace("vrijeme", cRnTime)
SmReplace("datum", DATE())

// idemo na POS
altd()
for i:=0 to LEN(aTemp)
	select pos
	append blank
	Sql_Append()
	
	SmReplace("idvd", VD_CK)
	SmReplace("iddio", ALLTRIM(STR(i + 1)))
	SmReplace("brdok", cRNBroj)
	SmReplace("idpos", gIdPos)
	
	if (i == 0)
		SmReplace("cijena", nIznRn)
		SmReplace("idradnik", SUBSTR(cKupac,1, 4))
		SmReplace("idroba", SUBSTR(cKupac,5, 14))
		SmReplace("idtarifa", SUBSTR(cKupac,15, 20))
		SmReplace("datum", DATE())
	endif
	
	if (i > 0)
		if (i==1)
			SmReplace("datum", dLKIzd)
		elseif (i==2)
			SmReplace("datum", dCKIzd)
		endif
		
		SmReplace("idradnik", SUBSTR(aTemp[i], 1, 4))
		SmReplace("idroba", SUBSTR(aTemp[i], 5, 14))
		SmReplace("idtarifa", SUBSTR(aTemp[i], 15, 20))
	endif
next

return
*}


/*! \fn AzurGarPismo(aGPData, cRnBroj, cRnTime)
 *  \brief Azuriranje dokumenta garantno pismo
 *  \param aGPData - matrica sa podacima o garantnom pismu
                  aGPData[1]=ime i prezime kupca
		  aGPData[2]=broj g.pisma
		  aGPData[3]=datum izdavanja g.pisma
 */
function AzurGarPismo(aGPData, cRnBroj, cRnTime)
*{

// ako nema podataka u matrici izadji
if LEN(aGPData)==0
	return
endif

O_DOKS
O_POS

cNazKupca:=PADR(aGPData[1], 20)

// prvo azuriraj pos
select doks
append blank
Sql_Append()

SmReplace("idvd", VD_GP)
SmReplace("idpos", gIdPos)
SmReplace("brdok", cRnBroj)
SmReplace("vrijeme", cRnTime)
SmReplace("datum", DATE())

// idemo na pos
for i:=1 to 2
	select pos
	append blank
	Sql_Append()
	SmReplace("idvd", VD_GP)
	SmReplace("idpos", gIdPos)
	SmReplace("brdok", cRnBroj) 
	SmReplace("iddio", ALLTRIM(STR(i)))
	// prvi zapis: datum dokumenta, ime i prezime kupca
	if i==1
		SmReplace("datum", DATE())
		SmReplace("idradnik", SUBSTR(cNazKupca,1, 4))
		SmReplace("idroba", SUBSTR(cNazKupca,4, 14))
		SmReplace("idtarifa", SUBSTR(cNazKupca,14, 20))
	endif
	// drugi zapis: broj gpisma i datum gpisma
	if i==2
		// datum gpisma
		SmReplace("datum", aGPData[3])
		// broj garantnog pisma
		SmReplace("idroba", aGPData[2])
	endif
next

return
*}



