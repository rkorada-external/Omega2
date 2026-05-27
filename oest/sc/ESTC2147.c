/*[XXX] 6/04/2014 JBG :spot:25773 Modify void main declaration to int main*/

/*==============================================================================
nom de l'application          :
nom du source                 : ESTC2147.c
revision                      :
date de creation              : 11/1997
auteur                        : Kuhna
references des specifications : #################
squelette de base             : batch
------------------------------------------------------------------------------
description : Pour chaque ligne du fichier des placements, lancement de
              la synchro avec le fichier des versements sur CASEX retro.
              Pour chaque ligne en synchro, ecrire une ligne au format
              du fichier des placements comprenant :
                Provenant des placements :
                        - Ctrt section exercice retro, code placement
                        - Taux de surcom (OVRCOM_R)
                        - Part cedee definive (RETSIGSHA_R)

                Provenant des versements :
                        - Filiale Etablissement
                        - Ctrt Section exercice N° ordre Acceptation
                        - devise de representation (RETPCPCUR_CF)
                             (mis dans CUR_CF)
                        - part versee (CESSH_R)
                        - lob (LOB_CF)

                Numero avenant acceptation et retro sont mis a 0.
                Numero ordre ex retro est a 1.


------------------------------------------------------------------------------
historique des modifications :
   <jj/mm/aaaa>   <auteur>    <description de la modification>

    16/01/1998   C.Soulier    La constante PLA_NBCOL (=31, cf struct.h),
                              est remplacee par PLA_NBFIELDS (=30), pour
                              que le champ PLA_RTOCTY_CF (utilise uniquement
                              par stat/reporting) soit elimine dans le fichier
                              en sortie de ce programme

    18/02/2003   J. Ribot     ajout champs PLA_CONRETCTR_b
                      ===>   en colonne 30 et le champs PLA_RTOCTY_CF a ete repousse en colonne 31
                             (voir commentaires ci-dessus)

    27/08/2003   J. Ribot modification de la syncro pour gestion des pools
                          plusieurs acceptations dans plusieurs placements
                                                    placement ==> pere
                                                    versement ==> fils

       ajout table en memoire pour stockage placement pour ecrire en sortie
              autant de lignes par versement que de placements correspondants

   19/09/2005 J Ribot  ajout colonne PLCSTS_CT  (SPOT 1167)

    27/03/2008   J. Ribot    SPOT 15219  ASE15 : recompilation des programmes C
    10/11/2015   R.BEN EZZINE :spot:29579 Impact Retro EST
    26/03/2018   MZM spira:57929 Gestion du PLAement sans versement ajout de la fonction Pere sans fils: Mettre le TAux à zero 
    06/04/2018   HH Huynh :spira 62073: ajout des champs BLCSHTSTR_D et BLCSHTEND_D avec Modif CES_ en CES1_
                
= =============================================================================*/


/*--------------------------------------------------*/
/* inclusion des interfaces des composants importes */
/*--------------------------------------------------*/
#include <utctlib.h>
#include <stdarg.h>
#include <struct.h>

/*---------------------------------------*/
/* inclusion de l'interface du composant */
/*---------------------------------------*/

/*---------------------------------------------*/
/* definition des constantes et macros privees */
/*---------------------------------------------*/
//#define PLA1_NBFIELDS 40

/*----------------------------------*/               

/* Structure de stockage du fichier de placements */
struct {
char							sz_PLA_RETCTR_NF  [10];
char							sz_PLA_RETEND_NT  [4];
char							sz_PLA_RETSEC_NF  [4];
char							sz_PLA_RTY_NF     [5];
char							sz_PLA_RETUW_NT   [4];
char							sz_PLA_PLC_NT     [11];
char							sz_PLA_OVRCOM_R   [16];
char							sz_PLA_RETSIGSHA_R[16];
char                            sz_PLA_PLCSTS_CT   [3];
char                            sz_PLA_OVRBASIS_NT [3];
} T_PLACMT[1000];
/* Structure de stockage du fichier de placements  extension */
struct {
	char BLCSHTSTR_D[9] ;
	char BLCSHTEND_D[9] ;
} T_PLACMT_EXT ;
/*----------------------*/
/* variables de travail */
/*----------------------*/

FILE  	           *Kp_OutputFil;  /*pointeur sur le fichier de sortie */
T_RUPTURE_VAR      bd_RuptPlc;     /*variable de gestion de la rupture sur
                                     le fichier des versements*/
T_RUPTURE_SYNC_VAR bd_RuptVer;     /*variable de gestion de la synchro sur
                                     contrat/Exercice Rétro entre le fic
                                     des versements et le fic des placements*/

int n_InitVer(T_RUPTURE_SYNC_VAR *pbd_Rupt);
int n_ActionLignePla(char **ptb_InRecOwner,char **pbd_InRecChild);
int n_ConditionSyncVer(char **ptb_InRecOwner,char **pbd_InRecChild);

int n_InitPlc(T_RUPTURE_VAR  *pbd_Rupt);
int n_ActionLignePlc(char **pbd_InRec_Cur);


int n_IsR1Plc(char **ptb_InRec, char **ptb_InRec_Cur);
int n_ActionFirstRuptPlc(char **ptb_InRec_Cur);

int n_ActionPlacPereSansFils(char **ptb_InRec) ;  //*pere sans fils*//


/*int n_ActionLastRuptPlc(char **ptb_InRec_Cur); */

int             Kn_NbLigPlacmt;           /* Nombre de lignes dans le fichier placement en memoire */

int n_ProcessingRuptureSyncVar(
  T_RUPTURE_SYNC_VAR  *pbd_Rupt,
  char  	      **ptb_InRecOwner);

int n_ProcessingRuptureVar(
  T_RUPTURE_VAR       *pbd_Rupt);

char  *Ktb_PlacSave[36] ;
int cptPereSansFils=0;
/*==============================================================================
objet :
 point d'entree du programme

retour :
   En cas de probleme, la sortie s'effectue par la fonction ExitPgm().
   Sinon, par l'appel systeme exit()
==============================================================================*/
int main(int argc,char *argv[])
{
				/* Initialisation des signaux */
  InitSig ();

  if (n_BeginPgm (argc,argv) == ERR)
    ExitPgm(ERR_XX ,"");

				/* Ouverture du fichier de sortie */
  if (n_OpenFileAppl ("ESTC2147_O1","wt",&Kp_OutputFil) == ERR)
    ExitPgm(ERR_XX ,"");

				/* Initialisation var bd_RuptPlc */
  if (n_InitPlc(&bd_RuptPlc) == ERR)
    ExitPgm(ERR_XX ,"");

				/* Initialisation var bd_RuptVer */
  if (n_InitVer(&bd_RuptVer) == ERR)
    ExitPgm(ERR_XX ,"");




				/* Lancement traitement fic des versements */
  if (n_ProcessingRuptureVar(&bd_RuptPlc) == ERR)
    ExitPgm(ERR_XX,"");

				/* Fermeture des fichiers */
  if (n_CloseFileAppl("ESTC2147_I1",&(bd_RuptPlc.pf_InputFil)) == ERR)
    ExitPgm(ERR_XX,"");

  if (n_CloseFileAppl("ESTC2147_I2",&(bd_RuptVer.pf_InputFil)) == ERR)
    ExitPgm(ERR_XX,"");

  if (n_CloseFileAppl("ESTC2147_O1",&Kp_OutputFil) == ERR)
    ExitPgm(ERR_XX,"");

  if (n_EndPgm() == ERR)
    ExitPgm ( ERR_XX , "" );

  exit(OK);
}

/*==============================================================================
objet :
        fonction de test de rupture niveau 1 sur
                Contrat/Section/Exercice de retrocession

retour :
        0   ---> Pas de rupture
        1   ---> rupture
==============================================================================*/
int n_IsR1Plc(char **ptb_InRec,char **ptb_InRec_Cur)
{
        DEBUT_FCT("n_IsR1Plc");

        if (strcmp(ptb_InRec[PLA1_RETCTR_NF],ptb_InRec_Cur[PLA1_RETCTR_NF])!=0)
                RETURN_VAL(1);
        if (strcmp(ptb_InRec[PLA1_RETSEC_NF],ptb_InRec_Cur[PLA1_RETSEC_NF])!=0)
                RETURN_VAL(1);
        if (strcmp(ptb_InRec[PLA1_RTY_NF],ptb_InRec_Cur[PLA1_RTY_NF])!=0)
                RETURN_VAL(1);
        RETURN_VAL (0);
}

/*==============================================================================
objet :
        Fonction lancee a chaque rupture derniere
==============================================================================*/
int n_ActionLastRuptPlc (char **ptb_InRec_Cur)
{
    DEBUT_FCT("n_ActionLastRuptPlc");

  				/* Synchro du fic placement pour chaque ligne */

  n_ProcessingRuptureSyncVar(&bd_RuptVer,ptb_InRec_Cur);

   RETURN_VAL(0);
}


/*==============================================================================
objet :
	fonction d'initialisation de la variable de gestion de rupture
        du fichier des versements.

retour :
	0K
==============================================================================*/
int n_InitPlc(T_RUPTURE_VAR  *pbd_Rupt)
{
  memset(pbd_Rupt,0,sizeof(T_RUPTURE_VAR));

				/* Ouverture du fic des versements */
  if (n_OpenFileAppl("ESTC2147_I1","rt",&(pbd_Rupt->pf_InputFil)) == ERR)
    return ERR;

  pbd_Rupt->n_NbRupture = 1;
        pbd_Rupt->n_ConditionRupture[0] = n_IsR1Plc;
        pbd_Rupt->n_ActionFirst[0] = n_ActionFirstRuptPlc;
        pbd_Rupt->n_ActionLast[0]  = n_ActionLastRuptPlc;


  pbd_Rupt->n_ActionLigne = n_ActionLignePlc;
  
   

  pbd_Rupt->c_Separ = SEPARATEUR;

  return OK;
}


/*==============================================================================
objet :
	fonction lancee pour chaque ligne

retour :
	OK ---> traitement correctement effectue
	ERR --> probleme rencontre
===========================================================================*/
int n_ActionLignePlc(char **ptb_InRec_Cur)
{

    DEBUT_FCT("n_ActionLignePlc");


	strcpy(T_PLACMT[Kn_NbLigPlacmt].sz_PLA_RETCTR_NF  ,ptb_InRec_Cur[PLA1_RETCTR_NF  ]);
	strcpy(T_PLACMT[Kn_NbLigPlacmt].sz_PLA_RETEND_NT  ,ptb_InRec_Cur[PLA1_RETEND_NT  ]);
	strcpy(T_PLACMT[Kn_NbLigPlacmt].sz_PLA_RETSEC_NF  ,ptb_InRec_Cur[PLA1_RETSEC_NF  ]);
	strcpy(T_PLACMT[Kn_NbLigPlacmt].sz_PLA_RTY_NF     ,ptb_InRec_Cur[PLA1_RTY_NF     ]);
	strcpy(T_PLACMT[Kn_NbLigPlacmt].sz_PLA_RETUW_NT   ,ptb_InRec_Cur[PLA1_RETUW_NT   ]);
	strcpy(T_PLACMT[Kn_NbLigPlacmt].sz_PLA_PLC_NT     ,ptb_InRec_Cur[PLA1_PLC_NT     ]);
	strcpy(T_PLACMT[Kn_NbLigPlacmt].sz_PLA_OVRCOM_R   ,ptb_InRec_Cur[PLA1_OVRCOM_R   ]);
	strcpy(T_PLACMT[Kn_NbLigPlacmt].sz_PLA_RETSIGSHA_R,ptb_InRec_Cur[PLA1_RETSIGSHA_R]);
  strcpy(T_PLACMT[Kn_NbLigPlacmt].sz_PLA_PLCSTS_CT  ,ptb_InRec_Cur[PLA1_PLCSTS_CT]);
  strcpy(T_PLACMT[Kn_NbLigPlacmt].sz_PLA_OVRBASIS_NT   ,ptb_InRec_Cur[PLA1_OVRBASIS_NT]);
    Kn_NbLigPlacmt++;
  				/* Synchro du fic placement pour chaque ligne */

/*  n_ProcessingRuptureSyncVar(&bd_RuptVer,ptb_InRec_Cur); */

     

  return OK;
}

/*==============================================================================
objet :
        Fonction lancee a chaque rupture premiere de niveau 1
==============================================================================*/
int n_ActionFirstRuptPlc (char **ptb_InRec_Cur)
{
  int i;
    DEBUT_FCT("n_ActionFirstRuptPlc");

    for (i=0; i < Kn_NbLigPlacmt ; i++)
    {
     strcpy(T_PLACMT[i].sz_PLA_RETCTR_NF , " ");
	   strcpy(T_PLACMT[i].sz_PLA_RETEND_NT , " ");
	   strcpy(T_PLACMT[i].sz_PLA_RETSEC_NF , " ");
	   strcpy(T_PLACMT[i].sz_PLA_RTY_NF    , " ");
	   strcpy(T_PLACMT[i].sz_PLA_RETUW_NT  , " ");
	   strcpy(T_PLACMT[i].sz_PLA_PLC_NT    , " ");
	   strcpy(T_PLACMT[i].sz_PLA_OVRCOM_R  , " ");
	   strcpy(T_PLACMT[i].sz_PLA_RETSIGSHA_R , " ");
	   strcpy(T_PLACMT[i].sz_PLA_PLCSTS_CT , " ");
	   strcpy(T_PLACMT[i].sz_PLA_OVRBASIS_NT , " ");
    }
    /* mise a zero cpt ligne table */
    Kn_NbLigPlacmt = 0;

    RETURN_VAL(0);
}

/*==============================================================================
objet :
     Initialisation de la synchronisation du fic maitre (fic des versements)
     avec l'esclave (fic des placements)

retour :
	OK
==============================================================================*/
int n_InitVer(T_RUPTURE_SYNC_VAR  *pbd_Rupt)
{
  memset(pbd_Rupt,0,sizeof(T_RUPTURE_SYNC_VAR)) ;

				/* Ouverture du fichier esclave (placements) */
  if (n_OpenFileAppl ("ESTC2147_I2","rt",&(pbd_Rupt->pf_InputFil)) == ERR)
    ExitPgm(ERR_XX,"");

				/* Fonction de test de la ligne du maitre
 			       	   versements avec l'esclave */
  pbd_Rupt->ConditionEndSync = n_ConditionSyncVer;
   

  /* spira:57929 Gestion du PLAement sans versement : Pere sans fils */
     
  pbd_Rupt->n_PereSansFils        = n_ActionPlacPereSansFils;     //spira:57929//  


				/* Fonction d'action sur la ligne courante
                                   du fichier esclave */
 pbd_Rupt->n_ActionLigne = n_ActionLignePla;
 

  pbd_Rupt->c_Separ = SEPARATEUR;
   

  return OK;
}


/*==============================================================================
objet :
	fonction de test de synchro

retour :
	0	---> pbd_InRecOwner = pbd_InRecChild
	> 0   	---> pbd_InRecOwner > pbd_InRecChild
	< 0   	---> pbd_InRecOwner < pbd_InRecChild
==============================================================================*/
int n_ConditionSyncVer(
  char **pbd_InRecOwner, /* adresse de la ligne du maitre fic placements */
  char **pbd_InRecChild) /* adresse de la ligne de l'esclave fic versements */
{
  int ret ;
						/* Contrat retro */
  ret = strcmp(pbd_InRecOwner[PLA1_RETCTR_NF],pbd_InRecChild[CES1_RETCTR_NF]);
  if (ret != 0)
     return ret;
						/* Avenant retro */
/*  ret = strcmp(pbd_InRecOwner[PLA1_RETEND_NT],pbd_InRecChild[CES_RETEND_NT]);
  if (ret != 0)
     return ret; */
						/* Section retro */
  ret = strcmp(pbd_InRecOwner[PLA1_RETSEC_NF],pbd_InRecChild[CES1_RETSEC_NF]);
  if (ret != 0)
     return ret;
						/* Exercice retro */
  ret = strcmp(pbd_InRecOwner[PLA1_RTY_NF],pbd_InRecChild[CES1_RTY_NF]);
  if (ret != 0)
     return ret;
						/* Num ordre exercice retro */
/*  ret = strcmp(pbd_InRecOwner[PLA1_RETUW_NT],pbd_InRecChild[CES_RETUW_NT]);
  if (ret != 0)
     return ret; */

  return 0;
}


/*============================================================================
objet :
	fonction lancee pour chaque ligne

retour :OK ---> traitement correctement effectue
	ERR --> probleme rencontre
===========================================================================*/
int n_ActionLignePla(
  char **ptb_InRecOwner, /* adresse de la ligne du maitre fic placements */
  char **ptb_InRecChild) /* adresse de la ligne de l'esclave versements */

{
  char *(ptb_Ligne[PLA1_NBCOL + 1]);
  int  n_i;
  int i;

    for (i=0; i < Kn_NbLigPlacmt ; i++)    /*  modif jr 28 08 03 */
    {

  				/* Initialisation de la ligne en sortie */
  for (n_i = 0 ; n_i < PLA1_NBCOL ; n_i ++)
    ptb_Ligne[n_i] = "";

  ptb_Ligne[PLA1_SSD_CF] = ptb_InRecChild[CES1_SSD_CF];
  ptb_Ligne[PLA1_ESB_CF] = ptb_InRecChild[CES1_ESB_CF];

  ptb_Ligne[PLA1_RETCTR_NF] = T_PLACMT[i].sz_PLA_RETCTR_NF;
  ptb_Ligne[PLA1_RETEND_NT] = "0";
  ptb_Ligne[PLA1_RETSEC_NF] = T_PLACMT[i].sz_PLA_RETSEC_NF;
  ptb_Ligne[PLA1_RTY_NF]    = T_PLACMT[i].sz_PLA_RTY_NF;
  ptb_Ligne[PLA1_RETUW_NT] = "1";
  ptb_Ligne[PLA1_PLC_NT]    = T_PLACMT[i].sz_PLA_PLC_NT;
  ptb_Ligne[PLA1_OVRCOM_R]    = T_PLACMT[i].sz_PLA_OVRCOM_R;
  ptb_Ligne[PLA1_RETSIGSHA_R]    = T_PLACMT[i].sz_PLA_RETSIGSHA_R;

  ptb_Ligne[PLA1_CTR_NF] = ptb_InRecChild[CES1_CTR_NF];
  ptb_Ligne[PLA1_END_NT] = "0";
  ptb_Ligne[PLA1_SEC_NF] = ptb_InRecChild[CES1_SEC_NF];
  ptb_Ligne[PLA1_UWY_NF] = ptb_InRecChild[CES1_UWY_NF];
  ptb_Ligne[PLA1_UW_NT]  = ptb_InRecChild[CES1_UW_NT];
  ptb_Ligne[PLA1_CUR_CF]  = ptb_InRecChild[CES1_RETPCPCUR_CF];
  ptb_Ligne[PLA1_CESSH_R]  = ptb_InRecChild[CES1_CESSH_R];
  ptb_Ligne[PLA1_LOB_CF]  = ptb_InRecChild[CES1_LOB_CF];
/* modif jr 14/02/03 */
  ptb_Ligne[PLA1_CONRETCTR_B]  = ptb_InRecChild[CES1_CONRETCTR_B];
  ptb_Ligne[PLA1_PLCSTS_CT]  =  T_PLACMT[i].sz_PLA_PLCSTS_CT;
  
  ptb_Ligne[PLA1_OVRBASIS_NT]  =  T_PLACMT[i].sz_PLA_OVRBASIS_NT;
  ptb_Ligne[PLA1_ACCFAM_CT]    = ptb_InRecChild[CES1_ACCFAM_CT];
/* ajout HHH 26/03/18 et 06/04/18 */  
  ptb_Ligne[PLA1_BLCSHTSTR_D]    = ptb_InRecChild[CES1_BLCSHTSTR_D]; 
  ptb_Ligne[PLA1_BLCSHTEND_D]    = ptb_InRecChild[CES1_BLCSHTEND_D];   
/* fin ajout HHH */   
  ptb_Ligne[PLA1_NBCOL]  = 0;
  

                         /* Copie ds le fic en sortie*/
  n_WriteCols(Kp_OutputFil,ptb_Ligne,SEPARATEUR,0);                         

  }
  return OK;
  
}


//*pere sans fils --> taux de placement à zéro*//

int n_ActionPlacPereSansFils(char **ptb_InRec)
{
	char *(ptb_Ligne[PLA1_NBCOL + 1]);
	int  n_i;
	sprintf(T_PLACMT_EXT.BLCSHTSTR_D,"%.8s",  "19010101") ;
	sprintf(T_PLACMT_EXT.BLCSHTEND_D,"%.8s",  "19010101") ;
	
	
	DEBUT_FCT("n_ActionPlacPereSansFils");
	for (n_i = 0 ; n_i < PLA1_NBCOL ; n_i ++)  ptb_Ligne[n_i] = "";
    for (n_i = 0 ; n_i < PLA1_NBCOL ; n_i ++) {
		if (ptb_InRec[n_i] != 0 ) ptb_Ligne[n_i] = ptb_InRec[n_i] ;
		else break;
	}
	

  
 /*printf("AVANT DANSn_ActionPlacPereSansFils, ptb_InRec[PLA1_RETSIGSHA_R] =%s ; ptb_InRec[PLA1_RETCTR_NF]=%s; Contrat ptb_InRec[PLA1_CTR_NF] =%s ; ptb_InRec[CES_CTR_NF]=%s \n ", ptb_InRec[PLA1_RETSIGSHA_R], ptb_InRec[PLA1_RETCTR_NF], ptb_InRec[PLA1_CTR_NF], ptb_InRec[CES_CTR_NF]); */

	ptb_Ligne[PLA1_RETSIGSHA_R]   = "0.00000000";


  ptb_Ligne[PLA1_BLCSHTSTR_D] = T_PLACMT_EXT.BLCSHTSTR_D ;
  ptb_Ligne[PLA1_BLCSHTEND_D] = T_PLACMT_EXT.BLCSHTEND_D ;
  ptb_Ligne[PLA1_NBCOL]  = 0;


   n_WriteCols(Kp_OutputFil,ptb_Ligne,SEPARATEUR,0); 

 /* printf("APRES DANSn_ActionPlacPereSansFils, ptb_InRec[PLA1_RETSIGSHA_R] =%s ; ptb_InRec[PLA1_RETCTR_NF]=%s ; Contrat ptb_InRec[PLA1_CTR_NF] =%s ; ptb_InRec[CES_CTR_NF]=%s \n ", ptb_InRec[PLA1_RETSIGSHA_R], ptb_InRec[PLA1_RETCTR_NF], ptb_InRec[PLA1_CTR_NF], ptb_InRec[CES_CTR_NF]); */

return OK;
}

