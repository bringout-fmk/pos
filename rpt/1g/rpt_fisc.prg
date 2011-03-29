#include "pos.ch"


// ---------------------------------------------
// menu fiskalni izvjestaji
// ---------------------------------------------
function mnu_f_rpt()
private izbor := 1
private opc := {}
private opcexe := {}

do case 

  // za FPRINT uredjaje (NSC)
  case ALLTRIM(gFc_type) == "FPRINT"

    AADD(opc,"------ izvjestaji -----------------------")
    AADD(opcexe,{|| .f. })
    AADD(opc,"1. dnevni fiskalni izvjestaj           ")
    AADD(opcexe,{|| fp_daily_rpt( ALLTRIM(gFC_path), ALLTRIM(gFC_name) ) })
    AADD(opc,"2. fiskalni izvjestaj za period ")
    AADD(opcexe,{|| fp_per_rpt( ALLTRIM(gFc_path), ALLTRIM(gFc_name) ) })
    AADD(opc,"------ ostale komande --------------------")
    AADD(opcexe,{|| .f. })
    AADD(opc,"5. unos pologa u uredjaj       ")
    AADD(opcexe,{|| fp_polog( ALLTRIM(gFC_path), ALLTRIM(gFC_name) ) })
    AADD(opc,"6. stampanje duplikata       ")
    AADD(opcexe,{|| fp_double( ALLTRIM(gFC_path), ALLTRIM(gFC_name) ) })
    AADD(opc,"7. zatvori racun (cmd 56)       ")
    AADD(opcexe,{|| fp_close( ALLTRIM(gFC_path), ALLTRIM(gFC_name) ) })
    AADD(opc,"8. zatvori nasilno racun (cmd 301) ")
    AADD(opcexe,{|| fp_void( ALLTRIM(gFc_path), ALLTRIM(gFc_name) ) })
    AADD(opc,"9. proizvoljna komanda ")
    AADD(opcexe,{|| fp_man_cmd( ALLTRIM(gFc_path), ALLTRIM(gFc_name) ) })

  // za HCP uredjaje
  case ALLTRIM(gFc_type) == "HCP" 
    
    AADD(opc,"------ izvjestaji -----------------------")
    AADD(opcexe,{|| .f. })
    AADD(opc,"1. dnevni fiskalni izvjestaj (Z rep.)    ")
    AADD(opcexe,{|| hcp_z_rpt( ALLTRIM(gFC_path), ALLTRIM(gFC_name), ;
    			gFc_error ) })
    AADD(opc,"2. presjek stanja (X rep.)    ")
    AADD(opcexe,{|| hcp_x_rpt( ALLTRIM(gFC_path), ALLTRIM(gFC_name), ;
    			gFc_error ) })
    AADD(opc,"------ ostale komande --------------------")
    AADD(opcexe,{|| .f. })
    AADD(opc,"5. kopija racuna    ")
    AADD(opcexe,{|| hcp_rn_copy( ALLTRIM(gFC_path), ALLTRIM(gFC_name), ;
    			gFc_error ) })
    AADD(opc,"6. polog u uredjaj    ")
    AADD(opcexe,{|| hcp_polog( ALLTRIM(gFC_path), ALLTRIM(gFC_name), ;
    			gFc_error ) })
    AADD(opc,"7. posalji cmd.ok    ")
    AADD(opcexe,{|| hcp_s_cmd( ALLTRIM(gFC_path) ) })

    // za TREMOL uredjaje
  case ALLTRIM(gFc_type) == "TREMOL" 
    
    AADD(opc,"------ izvjestaji -----------------------")
    AADD(opcexe,{|| .f. })
    
    AADD(opc,"1. dnevni fiskalni izvjestaj (Z rep.)    ")
    AADD(opcexe,{|| trm_z_rpt( ALLTRIM(gFC_path), ALLTRIM(gFC_name), ;
    			gFc_error ) })
    
    AADD(opc,"2. izvjestaj po artiklima (Z rep.)    ")
    AADD(opcexe,{|| trm_z_item( ALLTRIM(gFC_path), ALLTRIM(gFC_name), ;
    			gFc_error ) })
   
    AADD(opc,"3. presjek stanja (X rep.)    ")
    AADD(opcexe,{|| trm_x_rpt( ALLTRIM(gFC_path), ALLTRIM(gFC_name), ;
    			gFc_error ) })
 
    AADD(opc,"4. izvjestaj po artiklima (X rep.)    ")
    AADD(opcexe,{|| trm_x_item( ALLTRIM(gFC_path), ALLTRIM(gFC_name), ;
    			gFc_error ) })
   
    AADD(opc,"------ ostale komande --------------------")
    AADD(opcexe,{|| .f. })

    AADD(opc,"5. kopija racuna    ")
    AADD(opcexe,{|| trm_rn_copy( ALLTRIM(gFC_path), ALLTRIM(gFC_name), ;
    			gFc_error ) })
    AADD(opc,"6. reset artikala    ")
    AADD(opcexe,{|| fc_trm_rplu( ALLTRIM(gFC_path), ALLTRIM(gFC_name), ;
    			gFc_error ) })
    AADD(opc,"7. polog u uredjaj    ")
    AADD(opcexe,{|| trm_polog( ALLTRIM(gFC_path), ALLTRIM(gFC_name), ;
    			gFc_error ) })


  // ostali uredjaji
  otherwise
   
   AADD(opc," ---- nema dostupnih opcija ------ ")
   AADD(opcexe,{|| .f. })

endcase

Menu_SC("izvf")

return



