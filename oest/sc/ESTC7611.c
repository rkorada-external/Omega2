/*[XXX] 6/04/2014 JBG :spot:25773 Modify void main declaration to int main*/

/*==============================================================================
nom de l'application          : Syncro Perimetre Vie et Estimation
nom du source                 : ESTC7611.c
revision                      : $Revision:   1.1  $
date de creation              : 18/02/2005
auteur                        : J. Ribot
references des specifications :
squelette de base             : batch
------------------------------------------------------------------------------
description :


------------------------------------------------------------------------------
historique des modifications :
   <jj/mm/aaaa>   <auteur>    <description de la modification>
[002] 14/11/2013 -=Dch=-  	   :spot:25773  - Omega 2B modification de colonnes pour LIFEST	
[003] 06/10/2014 ABJ  spot:25773 Filtrage de certaines lignes lob31   
[004] 20/04/2021  S.Behague :spira:89086 - APOLO QE : Compte complet yearly sur traité quaterly
=============================================================================*/

/*--------------------------------------------------*/
/* inclusion des interfaces des composants importes */
/*--------------------------------------------------*/
#include <utctlib.h>
#include <struct.h>
#include "estserv.h"


/*---------------------------------------*/
/* inclusion de l'interface du composant */
/*---------------------------------------*/

/*---------------------------------------------*/
/* definition des constantes et macros privees */
/*---------------------------------------------*/

char Ksz_vide[1];               /* Chaine vide pour initialisation */

/*----------------------------------*/

/*----------------------*/
/* variables de travail */
/*----------------------*/
FILE    *Kp_OutputFil,  /* pointeur sur le fichier de sortie */
	*Kp_OutPREB1;   /* fichier Bilan -1 en sortie */


T_RUPTURE_VAR bd_RuptPerim; /* gestion rupture sur perimetre */
T_RUPTURE_SYNC_VAR bd_RuptPRE; /* gestion synchro GT-perimetre */

int n_InitPRE (T_RUPTURE_SYNC_VAR *pbd_Rupt) ;
int n_ActionLignePRE(char **ptb_InRecOwner,char **pbd_InRecChild) ;
int n_ConditionSyncPRE(char **ptb_InRecOwner,char **pbd_InRecChild);

int n_IsR1Perim(char **ptb_InRec, char **ptb_InRec_Cur);
int n_ActionLastRuptPerim(char **ptb_InRec_Cur);
int     Kb_rupt1;       /* 1 si rupture de niveau 1, 0 sinon */

int n_InitPerim(T_RUPTURE_VAR *pbd_Rupt) ;
int n_ActionLignePerim(char **pbd_InRec_Cur);
int n_ActionFilsSansPerePRE(char **ptb_InRecOwner );   /*  jr 11 09 2003 */

char	Ksz_Ctr[10] ;	/* contrat */
char	Ksz_Sec[3] ;	/* section */
char	Ksz_Esb[3] ;	/* Etablissement */

/*==============================================================================
objet :
   point d'entree du programme

retour :
   En cas de probleme, la sortie s'effectue par la fonction ExitPgm().
   Sinon, par l'appel systeme exit()
==============================================================================*/
int main(int argc ,char *argv[])
{

        /* Initialisation des signaux */
        InitSig () ;

        if ( n_BeginPgm (argc  ,argv) == ERR )
                ExitPgm ( ERR_XX , "" );

        /* ouverture des fichiers */

        if ( n_OpenFileAppl ("ESTC7611_O1","wt",&Kp_OutputFil) == ERR )
                  ExitPgm ( ERR_XX , "" );

         /* Initialisation de la varible bd_RuptPerim */
        if ( n_InitPerim(&bd_RuptPerim) )
                ExitPgm ( ERR_XX , "" );

        /* Initialisation de la varible bd_RuptPRE */
        if ( n_InitPRE(&bd_RuptPRE) )
                ExitPgm ( ERR_XX , "" );

        /* lancement du traitement du fichier */
        if ( n_ProcessingRuptureVar (&bd_RuptPerim) == ERR )
                ExitPgm ( ERR_XX , "" );

        if (n_CloseFileAppl ("ESTC7611_O1",&Kp_OutputFil)== ERR)
                ExitPgm ( ERR_XX , "" );

        if (n_CloseFileAppl("ESTC7611_I1",&(bd_RuptPerim.pf_InputFil))== ERR )
                ExitPgm ( ERR_XX , "" );

        if (n_CloseFileAppl ("ESTC7611_I2",&(bd_RuptPRE.pf_InputFil))== ERR)
                ExitPgm ( ERR_XX , "" );

        if ( n_EndPgm () == ERR )
                ExitPgm ( ERR_XX , "" );

        exit(0) ;

}

/*==============================================================================
objet :
        fonction d'initialisation de la variable de gestion de rupture du
        fichier maitre.

retour :
        OK
==============================================================================*/
int n_InitPerim(T_RUPTURE_VAR  *pbd_Rupt)
{
        DEBUT_FCT("n_InitPerim");

        memset(pbd_Rupt,0,sizeof(T_RUPTURE_VAR));

        if ( n_OpenFileAppl ("ESTC7611_I1","rt",&(pbd_Rupt->pf_InputFil)))
                ExitPgm ( ERR_XX , "" );

        pbd_Rupt->n_NbRupture = 1  ;
        pbd_Rupt->n_ConditionRupture[0] = n_IsR1Perim;
//       pbd_Rupt->n_ActionFirst[0] = n_ActionFirstRuptPerim;

        pbd_Rupt->n_ActionLast[0] = n_ActionLastRuptPerim;

        pbd_Rupt->n_ActionLigne = n_ActionLignePerim ;

        pbd_Rupt->c_Separ = SEPARATEUR ;

        RETURN_VAL(OK);
}

/*==============================================================================
objet :
        fonction de test de rupture du niveau 1

retour :
        0   ---> Pas de rupture
        1   ---> rupture
==============================================================================*/
int n_IsR1Perim(char **ptb_InRec,char **ptb_InRec_Cur)
{
        DEBUT_FCT("n_IsR1Perim");

        Kb_rupt1=0;

        if (strcmp(ptb_InRec[PER_CTR_NF],ptb_InRec_Cur[PER_CTR_NF])!=0)
                RETURN_VAL(1);
        if (strcmp(ptb_InRec[PER_SEC_NF],ptb_InRec_Cur[PER_SEC_NF])!=0)
                RETURN_VAL(1);
        if (strcmp(ptb_InRec[PER_UWY_NF],ptb_InRec_Cur[PER_UWY_NF])!=0)
                RETURN_VAL(1);
        RETURN_VAL (0);
}

/*==============================================================================
objet :
        fonction lancee pour chaque ligne du maitre

retour :
        0 ----> traitement correctement effectue
        ERR --> probleme rencontre
==============================================================================*/
int n_ActionLastRuptPerim(char **ptb_InRec_Cur)
{
    DEBUT_FCT("n_ActionLastRuptPerim");

// printf("lancement synchro...\n");
    /* lancement synchro */

        strcpy(Ksz_Ctr         , ptb_InRec_Cur[PER_CTR_NF]);
//printf("strcpy:[%s][%s]\n",Ksz_Ctr, ptb_InRec_Cur[PER_CTR_NF]);
        strcpy(Ksz_Sec         , ptb_InRec_Cur[PER_SEC_NF]);
//printf("strcpy:[%s][%s]\n",Ksz_Sec, ptb_InRec_Cur[PER_SEC_NF]);

         strcpy(Ksz_Esb        ,	ptb_InRec_Cur[PER_ACCESB_CF]);

    RETURN_VAL (0);
}
/*==============================================================================
objet :
        fonction lancee pour chaque ligne du maitre

retour :
        OK ---> traitement correctement effectue
        ERR --> probleme rencontre
==============================================================================*/
int n_ActionLignePerim( char **ptb_InRec_Cur)
{
        DEBUT_FCT("n_ActionLignePerim");
// printf("n_ActionLignePerim...\n");
        /* synchronisation du fichier PRE pour chaque ligne */
        n_ProcessingRuptureSyncVar (&bd_RuptPRE, ptb_InRec_Cur) ;

        RETURN_VAL(OK);
}

/*==============================================================================
objet :
        Initialisation de la synchronisation du maitre avec l'esclave GT

retour :
        OK
==============================================================================*/
int n_InitPRE(T_RUPTURE_SYNC_VAR  *pbd_Rupt)
{
        DEBUT_FCT("n_InitPRE");

        memset( pbd_Rupt,0,sizeof(T_RUPTURE_SYNC_VAR) ) ;

        /* ouverture du fichier esclave */
        n_OpenFileAppl ("ESTC7611_I2","rt",&(pbd_Rupt->pf_InputFil));

        pbd_Rupt->n_NbRupture = 0  ;

        /* fonction du test de la ligne du maitre avec l'esclave */
        pbd_Rupt->ConditionEndSync      = n_ConditionSyncPRE ;

        /* fonction d'action sur la ligne courante du fichier esclave */
        pbd_Rupt->n_ActionLigne         = n_ActionLignePRE ;

 	/* fonction d'action quand le maitre n'a pas de fils PRE */
         pbd_Rupt->n_FilsSansPere = n_ActionFilsSansPerePRE;

        pbd_Rupt->c_Separ               = SEPARATEUR ;

        RETURN_VAL(OK);
}

/*==============================================================================
objet :
        fonction de test de rupture du niveau 1

retour :
        0       ---> pbd_InRecOwner = pbd_InRecChild
                        ( egalite de rubriques a synchroniser)
        > 0     ---> pbd_InRecOwne> > pbd_InRecChild
        < 0     ---> pbd_InRecOwne> < pbd_InRecChild
==============================================================================*/
int n_ConditionSyncPRE(
        char **pbd_InRecOwner ,/* adresse de la ligne du maitre */
        char **pbd_InRecChild  /* adresse de la ligne de l'esclave */
        )
{
        int ret;

        DEBUT_FCT("n_ConditionSyncPRE");

        if ( (ret = strcmp(pbd_InRecOwner[PER_CTR_NF],pbd_InRecChild[TLIFEST_CTR_NF])) != 0 )
                RETURN_VAL(ret);
        if ( (ret = strcmp(pbd_InRecOwner[PER_SEC_NF],pbd_InRecChild[TLIFEST_SEC_NF])) != 0 )
                RETURN_VAL(ret);
        if ( (ret = strcmp(pbd_InRecOwner[PER_UWY_NF],pbd_InRecChild[TLIFEST_UWY_NF])) != 0 )
                RETURN_VAL(ret);

        RETURN_VAL(0);
}


/*==============================================================================
objet :
        fonction lancee pour chaque ligne du GT synchronisee avec le perimetre

retour :
        OK ---> traitement correctement effectue
        ERR --> probleme rencontre
==============================================================================*/
int n_ActionLignePRE(
        char **ptb_InRecOwner ,/* adresse de la ligne du maitre */
        char **ptb_InRecChild  /* adresse de la ligne de l'esclave */
)
{
      DEBUT_FCT("n_ActionLignePRE");

//printf("n_ActionLignePRE..\n");
//
int i;
char *LigneMod2[TLIFEST_ESB_CF+2];
     for(i=0;i<TLIFEST_ESB_CF+1;i++)
     LigneMod2[i]="";
     
  LigneMod2[TLIFEST_CTR_NF]= ptb_InRecChild[TLIFEST_CTR_NF];
  LigneMod2[TLIFEST_END_NT]= ptb_InRecChild[TLIFEST_END_NT]; 
  LigneMod2[TLIFEST_SEC_NF]= ptb_InRecChild[TLIFEST_SEC_NF];
  LigneMod2[TLIFEST_UWY_NF]= ptb_InRecChild[TLIFEST_UWY_NF];
  LigneMod2[TLIFEST_UW_NT]= ptb_InRecChild[TLIFEST_UW_NT];
  LigneMod2[TLIFEST_CRE_D]= ptb_InRecChild[TLIFEST_CRE_D];
  LigneMod2[TLIFEST_BALSHEY_NF]= ptb_InRecChild[TLIFEST_BALSHEY_NF];
  LigneMod2[TLIFEST_BALSHTMTH_NF]= ptb_InRecChild[TLIFEST_BALSHTMTH_NF];
  LigneMod2[TLIFEST_ACY_NF]= ptb_InRecChild[TLIFEST_ACY_NF];
  LigneMod2[TLIFEST_GAAP_NF]= ptb_InRecChild[TLIFEST_GAAP_NF];
  LigneMod2[TLIFEST_DETTRNCOD_CF]= ptb_InRecChild[TLIFEST_DETTRNCOD_CF];
  LigneMod2[TLIFEST_ESTMTH_NF]= ptb_InRecChild[TLIFEST_ESTMTH_NF];
  LigneMod2[TLIFEST_PRS_CF]= ptb_InRecChild[TLIFEST_PRS_CF];
  LigneMod2[TLIFEST_ACMTRS_NT]= ptb_InRecChild[TLIFEST_ACMTRS_NT];
  LigneMod2[TLIFEST_SSD_CF]= ptb_InRecChild[TLIFEST_SSD_CF];
  LigneMod2[TLIFEST_CUR_CF]=ptb_InRecChild[TLIFEST_CUR_CF];
  LigneMod2[TLIFEST_ESTMNT_M]=ptb_InRecChild[TLIFEST_ESTMNT_M];
  LigneMod2[TLIFEST_INDSUP_B]= ptb_InRecChild[TLIFEST_INDSUP_B];
  LigneMod2[TLIFEST_ORICOD_LS]= ptb_InRecChild[TLIFEST_ORICOD_LS];
  LigneMod2[TLIFEST_CREUSR_CF]= ptb_InRecChild[TLIFEST_CREUSR_CF];
  LigneMod2[TLIFEST_LSTUPD_D]= ptb_InRecChild[TLIFEST_LSTUPD_D];
  LigneMod2[TLIFEST_LSTUPDUSR_CF]= ptb_InRecChild[TLIFEST_LSTUPDUSR_CF];
  LigneMod2[TLIFEST_ESB_CF]= ptb_InRecOwner[PER_ACCESB_CF];
  LigneMod2[TLIFEST_ESB_CF+1]=0;
  if((strcmp(LigneMod2[TLIFEST_ACMTRS_NT],"1063")==0) ||  (strcmp(LigneMod2[TLIFEST_ACMTRS_NT],"2063")==0) 
  	  || (strcmp(LigneMod2[TLIFEST_ACMTRS_NT],"1064")==0) || (strcmp(LigneMod2[TLIFEST_ACMTRS_NT],"2064")==0)  
  	  || (strcmp(LigneMod2[TLIFEST_ACMTRS_NT],"1083")==0) ||  (strcmp(LigneMod2[TLIFEST_ACMTRS_NT],"2083")==0) 
  	  || (strcmp(LigneMod2[TLIFEST_ACMTRS_NT],"1084")==0) ||  (strcmp(LigneMod2[TLIFEST_ACMTRS_NT],"2084")==0) )
  	  {
   if (strcmp(ptb_InRecOwner[PER_LOB_CF],"31")==0) //[003]
   	  {
   		 RETURN_VAL(OK);
   	  }
    
    }
        
      n_WriteCols(Kp_OutputFil, LigneMod2, '~',0);




/*
fprintf( Kp_OutputFil,"%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s\n",
 

       ptb_InRecChild[TLIFEST_CTR_NF],
       ptb_InRecChild[TLIFEST_END_NT],
       ptb_InRecChild[TLIFEST_SEC_NF],
       ptb_InRecChild[TLIFEST_UWY_NF],
       ptb_InRecChild[TLIFEST_UW_NT],
       ptb_InRecChild[TLIFEST_CRE_D],
       ptb_InRecChild[TLIFEST_BALSHEY_NF],
       ptb_InRecChild[TLIFEST_BALSHTMTH_NF],
       ptb_InRecChild[TLIFEST_ACY_NF],
       ptb_InRecChild[TLIFEST_PRS_CF],
       ptb_InRecChild[TLIFEST_ACMTRS_NT],
       ptb_InRecChild[TLIFEST_SSD_CF],
       ptb_InRecChild[TLIFEST_CUR_CF],
       ptb_InRecChild[TLIFEST_ESTMNT_M],
       ptb_InRecChild[TLIFEST_INDSUP_B],
       ptb_InRecChild[TLIFEST_ORICOD_LS],
       ptb_InRecChild[TLIFEST_CREUSR_CF],
       ptb_InRecChild[TLIFEST_LSTUPD_D],
       ptb_InRecChild[TLIFEST_LSTUPDUSR_CF],
       ptb_InRecOwner[PER_ACCESB_CF]
       
       ) ;
*/
        RETURN_VAL(OK);
}


/*==============================================================================
objet :
        fonction lancee quand le pere n'a pas de fils GT
retour :
        OK ---> traitement correctement effectue
        ERR --> probleme rencontre

==============================================================================*/

int n_ActionFilsSansPerePRE(
        char **ptb_InRecChild   /* adresse de la ligne du maitre */
)
{

      DEBUT_FCT("n_ActionFilsSansPerePRE");
int i;
char *LigneMod2[TLIFEST_ESB_CF+2];
 for(i=0;i<TLIFEST_ESB_CF+1;i++)
       LigneMod2[i]="";

//        printf("Rupt 1 GT CTR/SEC %s/%s sav CTR/SEC %s/%s\n", ptb_InRecChild[TLIFEST_CTR_NF],
//                                             ptb_InRecChild[TLIFEST_SEC_NF],
//                                              Ksz_Ctr,
//                                                  Ksz_Sec);
//        printf("%s~%s\n", Ksz_Ctr, Ksz_Sec);

  if ( (strcmp(ptb_InRecChild[TLIFEST_CTR_NF],Ksz_Ctr)== 0 ) &&
             (strcmp(ptb_InRecChild[TLIFEST_SEC_NF],Ksz_Sec)== 0 )  )
     {
     	   	
    
  LigneMod2[TLIFEST_CTR_NF]= ptb_InRecChild[TLIFEST_CTR_NF];
  LigneMod2[TLIFEST_END_NT]= ptb_InRecChild[TLIFEST_END_NT];
  LigneMod2[TLIFEST_SEC_NF]= ptb_InRecChild[TLIFEST_SEC_NF];
  LigneMod2[TLIFEST_UWY_NF]= ptb_InRecChild[TLIFEST_UWY_NF];
  LigneMod2[TLIFEST_UW_NT]= ptb_InRecChild[TLIFEST_UW_NT];
  LigneMod2[TLIFEST_CRE_D]= ptb_InRecChild[TLIFEST_CRE_D];
  LigneMod2[TLIFEST_BALSHEY_NF]= ptb_InRecChild[TLIFEST_BALSHEY_NF];
  LigneMod2[TLIFEST_BALSHTMTH_NF]= ptb_InRecChild[TLIFEST_BALSHTMTH_NF];
  LigneMod2[TLIFEST_ACY_NF]= ptb_InRecChild[TLIFEST_ACY_NF];
  LigneMod2[TLIFEST_GAAP_NF]= ptb_InRecChild[TLIFEST_GAAP_NF];
  LigneMod2[TLIFEST_DETTRNCOD_CF]= ptb_InRecChild[TLIFEST_DETTRNCOD_CF];
  LigneMod2[TLIFEST_ESTMTH_NF]= ptb_InRecChild[TLIFEST_ESTMTH_NF];
  LigneMod2[TLIFEST_PRS_CF]= ptb_InRecChild[TLIFEST_PRS_CF];
  LigneMod2[TLIFEST_ACMTRS_NT]= ptb_InRecChild[TLIFEST_ACMTRS_NT];
  LigneMod2[TLIFEST_SSD_CF]= ptb_InRecChild[TLIFEST_SSD_CF];
  LigneMod2[TLIFEST_CUR_CF]=ptb_InRecChild[TLIFEST_CUR_CF];
  LigneMod2[TLIFEST_ESTMNT_M]=ptb_InRecChild[TLIFEST_ESTMNT_M];
  LigneMod2[TLIFEST_INDSUP_B]= ptb_InRecChild[TLIFEST_INDSUP_B];
  LigneMod2[TLIFEST_ORICOD_LS]= ptb_InRecChild[TLIFEST_ORICOD_LS];
  LigneMod2[TLIFEST_CREUSR_CF]= ptb_InRecChild[TLIFEST_CREUSR_CF];
  LigneMod2[TLIFEST_LSTUPD_D]= ptb_InRecChild[TLIFEST_LSTUPD_D];
  LigneMod2[TLIFEST_LSTUPDUSR_CF]= ptb_InRecChild[TLIFEST_LSTUPDUSR_CF];
    

  LigneMod2[TLIFEST_ESB_CF]=Ksz_Esb; 
  LigneMod2[TLIFEST_ESB_CF+1]=0;
    
   
          n_WriteCols(Kp_OutputFil, LigneMod2, '~',0);

/*		  
     	  fprintf( Kp_OutputFil,"%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s\n",


       ptb_InRecChild[TLIFEST_CTR_NF],
       ptb_InRecChild[TLIFEST_END_NT],
       ptb_InRecChild[TLIFEST_SEC_NF],
       ptb_InRecChild[TLIFEST_UWY_NF],
       ptb_InRecChild[TLIFEST_UW_NT],
       ptb_InRecChild[TLIFEST_CRE_D],
       ptb_InRecChild[TLIFEST_BALSHEY_NF],
       ptb_InRecChild[TLIFEST_BALSHTMTH_NF],
       ptb_InRecChild[TLIFEST_ACY_NF],
       ptb_InRecChild[TLIFEST_PRS_CF],
       ptb_InRecChild[TLIFEST_ACMTRS_NT],
       ptb_InRecChild[TLIFEST_SSD_CF],
       ptb_InRecChild[TLIFEST_CUR_CF],
       ptb_InRecChild[TLIFEST_ESTMNT_M],
       ptb_InRecChild[TLIFEST_INDSUP_B],
       ptb_InRecChild[TLIFEST_ORICOD_LS],
       ptb_InRecChild[TLIFEST_CREUSR_CF],
       ptb_InRecChild[TLIFEST_LSTUPD_D],
       ptb_InRecChild[TLIFEST_LSTUPDUSR_CF],
       Ksz_Esb
       ) ;
*/
 		} 
RETURN_VAL(OK);
}

