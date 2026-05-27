/*[XXX] 6/04/2014 JBG :spot:25773 Modify void main declaration to int main*/

/*==============================================================================
nom de l'application          : Delete FWH from DLVGTAA
nom du source                 : ESTC2161.c
revision                      : 
date de creation              : 04/10/2022
auteur                        : S. Behague
references des specifications : 
squelette de base             : batch
------------------------------------------------------------------------------
description : Delete FWH from DLVGTAA
------------------------------------------------------------------------------
historique des modifications :
<jj/mm/aaaa>   <auteur>    <description de la modification>
 04/10/2022     SBE         Création

_________________

[001] 04/10/2022 S.Behague :spira:106396 IFRS 17 FWH - Beginning accruals missing after complete account - Copy

==============================================================================*/

/*--------------------------------------------------*/
/* inclusion des interfaces des composants importes */
/*--------------------------------------------------*/
#include <utctlib.h>
#include <struct.h>
#include <estserv.h>

/*---------------------------------------*/
/* inclusion de l'interface du composant */
/*---------------------------------------*/

/*---------------------------------------------*/
/* definition des constantes et macros privees */
/*---------------------------------------------*/

/*----------------------*/
/* variables de travail */
/*----------------------*/
FILE       *Kp_GtaIFil,               // Pointeur sur le fichier DLGVTAA en entree
           *Kp_GtaOFil,            // Pointeur sur le fichier GTAA de sortie
           *Kp_GtaExcluOFil,            // Pointeur sur le fichier GTAA de sortie
           *Kp_SubTRSFil,             // pointeur sur le fichier SUBTRS
           *Kp_SubTRSLOCKLIFESTFil;   // pointeur sur le fichier SUBTRSLOCKLIFEST

T_RUPTURE_VAR       bd_RuptGta;   // Gestion rupture fichier prevision

T_SUBTRS        SubTrsLigne;                    // Strucutre SubTrs
T_SUBTRSBLOCKLIFEST        SubTrsLockLifestLigne;          // Strucutre SubTrsLockLifest

// Fonctions de synchronisation
int n_InitGta (T_RUPTURE_VAR *pbd_Rupt);
int n_ActionLigneGta ( char **ptb_InRec_Cur);

// Fonctions utilitaires
void init_SubTrsLigne();
void init_SubTrsLockLifestLigne();
int NbLigne=1;
int Flag_gaap1 = 0;

/*==============================================================================
objet :     point d'entree du programme
retour :    En cas de probleme, la sortie s'effectue par la fonction ExitPgm().
            Sinon, par l'appel systeme exit()
==============================================================================*/
int main(int argc ,char *argv[])
{
    // Initialisation des signaux
    InitSig () ;
    
    if ( n_BeginPgm (argc  ,argv) == ERR )                                   ExitPgm ( ERR_XX , "" );
    
    // Ouverture des fichiers
    if ( n_OpenFileAppl ("ESTC2161_O1","wt",&Kp_GtaOFil) == ERR )         ExitPgm ( ERR_XX , "" );
    
    if ( n_OpenFileAppl ("ESTC2161_O2","wt",&Kp_GtaExcluOFil) == ERR )         ExitPgm ( ERR_XX , "" );

    // Initialisation de la varible bd_RuptPrevision
    if ( n_InitGta(&bd_RuptGta) )                                            ExitPgm ( ERR_XX , "" );

    
    // Chargement fichier T_SUBTRS
    if ( n_OpenFileAppl ("ESTC2161_I2","rb",&Kp_SubTRSFil) == ERR )          ExitPgm ( ERR_XX , "" );
    if ( n_ChargerTsubTRS(Kp_SubTRSFil) == ERR )                             ExitPgm( ERR_XX , "" ); 

    // Chargement fichier T_SUBTRSBLOCKLIFEST
    if ( n_OpenFileAppl ("ESTC2161_I3","rb",&Kp_SubTRSLOCKLIFESTFil) == ERR )          ExitPgm ( ERR_XX , "" );
    if ( n_ChargerSUBTRSBLOCKLIFEST(Kp_SubTRSLOCKLIFESTFil) == ERR )                   ExitPgm( ERR_XX , "" ); 
    	
    // initialisation de la structure retour
    init_SubTrsLigne();
    init_SubTrsLockLifestLigne();

    // lancement du traitement du fichier
    if ( n_ProcessingRuptureVar (&bd_RuptGta) == ERR )                        ExitPgm ( ERR_XX , "" );
    
    // Fermeture des fichiers
    if (n_CloseFileAppl ("ESTC2161_I1",&(bd_RuptGta.pf_InputFil)))           ExitPgm ( ERR_XX , "" );
    if (n_CloseFileAppl ("ESTC2161_O1",&Kp_GtaOFil))                      ExitPgm ( ERR_XX , "" );
    if (n_CloseFileAppl ("ESTC2161_O2",&Kp_GtaExcluOFil))                      ExitPgm ( ERR_XX , "" );

    if ( n_EndPgm () == ERR )                                                ExitPgm ( ERR_XX , "" );

    exit(0) ;
}
/*************** Fin Main ****************/

/*============================================================================================
objet :     fonction d'initialisation de la variable de gestion de rupture du fichier Gta.
retour :    0
============================================================================================*/
int n_InitGta (T_RUPTURE_VAR *pbd_Rupt)
{
    DEBUT_FCT("n_InitGta");

    memset(pbd_Rupt,0,sizeof(T_RUPTURE_VAR));

    if ( n_OpenFileAppl ("ESTC2161_I1","rt",&(pbd_Rupt->pf_InputFil)))
        RETURN_VAL (ERR);

    pbd_Rupt->n_NbRupture = 0;

    pbd_Rupt->n_ActionLigne = n_ActionLigneGta ;

    pbd_Rupt->c_Separ = '~' ;

    RETURN_VAL (0); 
}


/*==============================================================================
objet : Fonction lancee pour chaque ligne du fichier
==============================================================================*/
int n_ActionLigneGta ( char **ptb_InRec_Cur)
{
    DEBUT_FCT("n_ActionLigneGta");
    
    char sz_DETTRNCOD[6]="XXXXX";
    int  n_Block;
    

		strcpy(sz_DETTRNCOD, ptb_InRec_Cur[GT_TRNCOD_CF] + 2);
		sz_DETTRNCOD[5] = '\0';
		
 		if ( n_RechSUBTRSBLOCKLIFEST(&SubTrsLockLifestLigne, sz_DETTRNCOD) != -1 )
 		{
 			n_Block=SubTrsLockLifestLigne.BLOCK_NF;
 		}

 		if ( n_FindTsubTRS(&SubTrsLigne, sz_DETTRNCOD) != -1 )
	  {
	  	NbLigne+=1;
	  	if ( (SubTrsLigne.TRSTYPE_CT == 4 && n_Block == 4 && ptb_InRec_Cur[GT_TRNCOD_CF][7] != '0') )
	  	{
  			n_WriteCols(Kp_GtaExcluOFil, ptb_InRec_Cur, SEPARATEUR, 0);
			}
			else
			{
				n_WriteCols(Kp_GtaOFil, ptb_InRec_Cur, SEPARATEUR, 0);
			}
		}
		else
		{
			n_WriteCols(Kp_GtaOFil, ptb_InRec_Cur, SEPARATEUR, 0);
		}
		
    RETURN_VAL(0);
}


/*==========================================================================
     Objet :    Initialisation de la structure TRS

     Nom:       init_SubTrsLigne

     Parametres:
               

     Retour:    0
===========================================================================*/
void init_SubTrsLigne()
{
          strcpy(SubTrsLigne.DETTRNCOD_CF, "");
          strcpy(SubTrsLigne.SUBTRS_GL,"");
          strcpy(SubTrsLigne.SUBTRS_GS,"");
          strcpy(SubTrsLigne.SUBTRSEXP_D,""); 
          strcpy(SubTrsLigne.SUBTRSINC_D,"");
          SubTrsLigne.CMT_NT =0;
          SubTrsLigne.TRSINPUTTYPE_CT = 0;
          SubTrsLigne.TRSNATURE_CT = 0 ;
          strcpy(SubTrsLigne.LOGSIG_CT,"");
          strcpy(SubTrsLigne.LOB_CF,"");
          SubTrsLigne.TRSTYPE_CT = 0; 
          SubTrsLigne.TRSPURERETRO_B = 0;
          SubTrsLigne.DACTYPE_B   = 0;
          SubTrsLigne.COMPLEMENT_B = 0;
          SubTrsLigne.NEWBALSHEETPROPAG_B = 0;
          SubTrsLigne.CELLPROTECEXC_B = 0;
}

/*==========================================================================
     Objet :    Initialisation de la structure TRS

     Nom:       init_SubTrsLigne

     Parametres:
               

     Retour:    0
===========================================================================*/
void init_SubTrsLockLifestLigne()
{
      SubTrsLockLifestLigne.BLOCK_NF=0;
      strcpy(SubTrsLockLifestLigne.DETTRNCOD_CF,"");
      SubTrsLockLifestLigne.RANKORDER_NT=0;
      strcpy(SubTrsLockLifestLigne.LSTUPD_D,"");
      strcpy(SubTrsLockLifestLigne.LSTUPDUSR_CF,"");
}