#include "\dev\fmk\pos\pos.ch"


/*! \fn AzurCek(aCKData, nUkIzn, cRnBroj, cRnTime)
 *  \brief Azuriranje dokumenta CEK
 *  \param aCKData - matrica sa podacima o ceku
 */
function AzurCek(aCKData, nUkIzn, cRnBroj, cRnTime)
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
aTemp:=SjeciStr(cCkData, 20)

O_DOKS
O_POS

// prvo azuriraj pos
select doks
append blank
replace idvd with VD_CK
replace idpos with gIdPos
replace brdok with cRNBroj
replace vrijeme with cRnTime
replace datum with DATE()

// idemo na pos
for i:=0 to LEN(aTemp)
	select pos
	append blank
	replace idvd with VD_CK
	replace iddio with ALLTRIM(STR(i + 1))
	replace brdok with cRNBroj
	replace idpos with gIdPos
	if i==0
		replace cijena with nUkIzn
		replace idradnik with SUBSTR(cKupac,1, 4)
		replace idroba with SUBSTR(cKupac,4, 14)
		replace idtarifa with SUBSTR(cKupac,14, 20)
		replace datum with DATE()
	endif
	if (i > 0)
		if (i==1)
			replace datum with dLKIzd
		elseif (i==2)
			replace datum with dCKIzd
		endif
		replace idradnik with SUBSTR(aTemp[i], 1, 4)
		replace idroba with SUBSTR(aTemp[i], 4, 14)
		replace idtarifa with SUBSTR(aTemp[i], 14, 20)
	endif
next

return
*}


/*! \fn AzurGarPismo(aGPData)
 *  \brief Azuriranje dokumenta garantno pismo
 *  \param aGPData - matrica sa podacima o garantnom pismu
                  aGPData[1]=broj g.pisma
		  aGPData[2]=datum izdavanja g.pisma
		  aGPData[3]=ime i prezime kupca
 */
function AzurGarPismo(aGPData)
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
replace idvd with VD_GP
replace idpos with gIdPos
replace brdok with cStalRac 
replace datum with DATE()

// idemo na pos
for i:=1 to 2
	select pos
	append blank
	replace idvd with VD_GP
	replace idpos with gIdPos
	replace brdok with cStalRac 
	replace iddio with ALLTRIM(STR(i))
	// prvi zapis: datum dokumenta, ime i prezime kupca
	if i==1
		replace datum with DATE()
		replace idradnik with SUBSTR(cNazKupca,1, 4)
		replace idroba with SUBSTR(cNazKupca,4, 14)
		replace idtarifa with SUBSTR(cNazKupca,14, 20)
	endif
	// drugi zapis: broj gpisma i datum gpisma
	if i==2
		// datum gpisma
		replace datum with aGPData[3]
		// broj garantnog pisma
		replace idroba with aGPData[2]
	endif

next

return
*}



