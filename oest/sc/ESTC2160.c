/*[XXX] 6/04/2014 JBG :spot:25773 Modify void main declaration to int main*/

/*==============================================================================
nom de l'application          : Create FWH files 
nom du source                 : ESTC2160.c
revision                      : 
date de creation              : 16/02/2022
auteur                        : S. Behague
references des specifications : 
squelette de base             : batch
------------------------------------------------------------------------------
description : Create FWH file in destination to ESFD1800
------------------------------------------------------------------------------
historique des modifications :
<jj/mm/aaaa>   <auteur>    <description de la modification>
 16/02/2022     SBE         Création

_________________

[001] 16/02/2022 S.Behague :spira:98141 IFRS17 FWH Bookings
[002] 10/05/2022 S.Behague :spira:104181 IFRS 17 FWH - Accruals Local generates with wrong suffixe
[003] 30/05/2022 S.Behague :spira:104651 IFRS 17 - FWH - Don't generate on specific TC FWH
[004] 05/01/2023 S.Behague :spira:108254: IFRS17 FWH : Si annulation ( mêmes données en tout point identiques), la ligne n'est pas dans RA

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
FILE       *Kp_GteIFil,               // Pointeur sur le fichier SRGTE en entree
           *Kp_Gte17GOFil,            // Pointeur sur le fichier I17G de sortie
           *Kp_Gte17POFil,            // Pointeur sur le fichier I17P de sortie
           *Kp_Gte17LOFil,            // Pointeur sur le fichier I17L de sortie
           *Kp_SubTRSFil,             // pointeur sur le fichier SUBTRS
           *Kp_SubTRSLOCKLIFESTFil;   // pointeur sur le fichier SUBTRSLOCKLIFEST

T_RUPTURE_VAR       bd_RuptGte;   // Gestion rupture fichier prevision

T_SUBTRS        SubTrsLigne;                    // Strucutre SubTrs
T_SUBTRSBLOCKLIFEST        SubTrsLockLifestLigne;          // Strucutre SubTrsLockLifest

// Fonctions de synchronisation
int n_InitGte (T_RUPTURE_VAR *pbd_Rupt);
int n_ActionLigneGte ( char **ptb_InRec_Cur);

// Fonctions utilitaires
void init_SubTrsLigne();
void init_SubTrsLockLifestLigne();

int Flag_gaap1 = 0;
int Kn_Mois;

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

    Kn_Mois = n_GetIntArgv(1);
    
    // Ouverture des fichiers
    if ( n_OpenFileAppl ("ESTC2160_O1","wt",&Kp_Gte17GOFil) == ERR )         ExitPgm ( ERR_XX , "" );
    if ( n_OpenFileAppl ("ESTC2160_O2","wt",&Kp_Gte17POFil) == ERR )         ExitPgm ( ERR_XX , "" );
    if ( n_OpenFileAppl ("ESTC2160_O3","wt",&Kp_Gte17LOFil) == ERR )         ExitPgm ( ERR_XX , "" );


    // Initialisation de la varible bd_RuptPrevision
    if ( n_InitGte(&bd_RuptGte) )                                            ExitPgm ( ERR_XX , "" );

    
    // Chargement fichier T_SUBTRS
    if ( n_OpenFileAppl ("ESTC2160_I2","rb",&Kp_SubTRSFil) == ERR )          ExitPgm ( ERR_XX , "" );
    if ( n_ChargerTsubTRS(Kp_SubTRSFil) == ERR )                             ExitPgm( ERR_XX , "" ); 

    // Chargement fichier T_SUBTRSBLOCKLIFEST
    if ( n_OpenFileAppl ("ESTC2160_I3","rb",&Kp_SubTRSLOCKLIFESTFil) == ERR )          ExitPgm ( ERR_XX , "" );
    if ( n_ChargerSUBTRSBLOCKLIFEST(Kp_SubTRSLOCKLIFESTFil) == ERR )                   ExitPgm( ERR_XX , "" ); 
    	
    // initialisation de la structure retour
    init_SubTrsLigne();
    init_SubTrsLockLifestLigne();

    // lancement du traitement du fichier
    if ( n_ProcessingRuptureVar (&bd_RuptGte) == ERR )                        ExitPgm ( ERR_XX , "" );
    
    // Fermeture des fichiers
    if (n_CloseFileAppl ("ESTC2160_I1",&(bd_RuptGte.pf_InputFil)))           ExitPgm ( ERR_XX , "" );
    if (n_CloseFileAppl ("ESTC2160_O1",&Kp_Gte17GOFil))                      ExitPgm ( ERR_XX , "" );
    if (n_CloseFileAppl ("ESTC2160_O2",&Kp_Gte17POFil))                      ExitPgm ( ERR_XX , "" );
    if (n_CloseFileAppl ("ESTC2160_O3",&Kp_Gte17LOFil))                      ExitPgm ( ERR_XX , "" );

    if ( n_EndPgm () == ERR )                                                ExitPgm ( ERR_XX , "" );

    exit(0) ;
}
/*************** Fin Main ****************/

/*============================================================================================
objet :     fonction d'initialisation de la variable de gestion de rupture du fichier GTE.
retour :    0
============================================================================================*/
int n_InitGte (T_RUPTURE_VAR *pbd_Rupt)
{
    DEBUT_FCT("n_InitGte");

    memset(pbd_Rupt,0,sizeof(T_RUPTURE_VAR));

    if ( n_OpenFileAppl ("ESTC2160_I1","rt",&(pbd_Rupt->pf_InputFil)))
        RETURN_VAL (ERR);

    pbd_Rupt->n_NbRupture = 0;

    pbd_Rupt->n_ActionLigne = n_ActionLigneGte ;

    pbd_Rupt->c_Separ = '~' ;

    RETURN_VAL (0); 
}


/*==============================================================================
objet : Fonction lancee pour chaque ligne du fichier
==============================================================================*/
int n_ActionLigneGte ( char **ptb_InRec_Cur)
{
    DEBUT_FCT("n_ActionLigneGte");
    
    char sz_DETTRNCOD[6]="XXXXX";
    int  n_Block;
    char        Ksz_Mois[3];
    
		strcpy(sz_DETTRNCOD, ptb_InRec_Cur[GT_TRNCOD_CF] + 2);
		sz_DETTRNCOD[5] = '\0';
		sprintf(Ksz_Mois, "%d", Kn_Mois);
		
 		if ( n_RechSUBTRSBLOCKLIFEST(&SubTrsLockLifestLigne, sz_DETTRNCOD) != -1 )
 		{
 			n_Block=SubTrsLockLifestLigne.BLOCK_NF;
 		}

 		if ( n_FindTsubTRS(&SubTrsLigne, sz_DETTRNCOD) != -1 )
	  {
	  	if ( SubTrsLigne.TRSTYPE_CT == 4 && n_Block == 4 )
	  	{
	  		if ( atoi(ptb_InRec_Cur[GT_GAAP_NF]) == 1 )
	  		{
	  			Flag_gaap1 = 1;
	  		}
	  		if ( Flag_gaap1 == 0 && atoi(ptb_InRec_Cur[GT_GAAP_NF]) == 2)
	  		{
	  			// Si le gaap 1 n'est pas écrit, on force l'écriture du gaap 1 car il est absent du fichier d'entrée
	  			ptb_InRec_Cur[GT_GAAP_NF]="1";
	  			ptb_InRec_Cur[GT_SCOSTRMTH_NF]=Ksz_Mois;
	  			ptb_InRec_Cur[GT_SCOENDMTH_NF]=Ksz_Mois;
	  			ptb_InRec_Cur[GT_TRNCOD_CF][7]='I';
	  			n_WriteCols(Kp_Gte17GOFil, ptb_InRec_Cur, SEPARATEUR, 0);
	  			ptb_InRec_Cur[GT_TRNCOD_CF][7]='K';
	  			n_WriteCols(Kp_Gte17POFil, ptb_InRec_Cur, SEPARATEUR, 0);
	  			ptb_InRec_Cur[GT_TRNCOD_CF][7]='M';
	  			n_WriteCols(Kp_Gte17LOFil, ptb_InRec_Cur, SEPARATEUR, 0);
	  			ptb_InRec_Cur[GT_GAAP_NF]="2";
	  		}

	  		ptb_InRec_Cur[GT_SCOSTRMTH_NF]=Ksz_Mois;
	  		ptb_InRec_Cur[GT_SCOENDMTH_NF]=Ksz_Mois;
	  		ptb_InRec_Cur[GT_TRNCOD_CF][7]='I';
	  		n_WriteCols(Kp_Gte17GOFil, ptb_InRec_Cur, SEPARATEUR, 0);
	  		ptb_InRec_Cur[GT_TRNCOD_CF][7]='K';
	  		n_WriteCols(Kp_Gte17POFil, ptb_InRec_Cur, SEPARATEUR, 0);
				ptb_InRec_Cur[GT_TRNCOD_CF][7]='M';
	  		n_WriteCols(Kp_Gte17LOFil, ptb_InRec_Cur, SEPARATEUR, 0);
	  		
	  		if  ( atoi(ptb_InRec_Cur[GT_GAAP_NF]) > 1 )
	  		{
	  		  Flag_gaap1=0;
	  		}
			}
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
