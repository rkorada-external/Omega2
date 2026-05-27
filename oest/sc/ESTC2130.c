/*[XXX] 6/04/2014 JBG :spot:25773 Modify void main declaration to int main*/

/*==============================================================================
nom de l'application          : Actualisation du parametrage
nom du source                 : ESTC2130.c
revision                      : $Revision: 1.1.1.1 $
date de creation              : 01/07/1997
auteur                        : C. Chavatte
references des specifications : ESIIV01F
squelette de base             : batch
------------------------------------------------------------------------------
description :


------------------------------------------------------------------------------
historique des modifications :
   <jj/mm/aaaa>   <auteur>    <description de la modification>
    30/06/2003     J.Ribot    PRE_NBCOLNEW 38 passe de 37 a 38 pour CNATYP_CT
    04/11/2010     R.Cassis     :spot:20627 - Si estcrb est à R, positionner adjcod à 9 comme pôur non criblé - V002
    08/02/2011     D.GATIBELZA  ESTVIE20627 retour à la version de prod
    26/03/2015     S.ASKRI     SGLA02, spot: 28512
    13/07/2015     spira 37617 des postes analytiques saisis n'existent pas dans le fichier FACCPAR0(ajout du FilsSansPere)
==============================================================================*/

/*--------------------------------------------------*/
/* inclusion des interfaces des composants importes */
/*--------------------------------------------------*/
#include <utctlib.h>
#include <struct.h>

/*---------------------------------------*/
/* inclusion de l'interface du composant */
/*---------------------------------------*/

/*---------------------------------------------*/
/* definition des constantes et macros privees */
/*---------------------------------------------*/

// OMEGA2 B  : on va garder les define de struct.h 
//#define PRE_NBCOLNEW 38        /*  PRE_NBCOLNEW 37 passe a 38 jr 30/06/03 pour cnatyp_ct */

/*----------------------------------*/

/*----------------------*/
/* variables de travail */
/*----------------------*/

FILE    *Kp_GTFil,
        *Kp_PrevFil;            /* pointeurs sur les fichiers en sortie */

T_RUPTURE_VAR bd_RuptAccpar;    /* gestion rupture sur ACCPAR */
T_RUPTURE_SYNC_VAR bd_RuptGT;   /* gestion synchro accpar-GT */
T_RUPTURE_SYNC_VAR  bd_RuptPrev; /* gestion synchro accpar-previsions */

int	Kn_Balshey ;	/* annee bilan passee en argument */

int n_InitGT (T_RUPTURE_SYNC_VAR *pbd_Rupt) ;
int n_ActionLigneGT(char **ptb_InRecOwner,char **pbd_InRecChild) ;
int n_ConditionSyncGT(char **ptb_InRecOwner,char **pbd_InRecChild);

int n_InitPrev(T_RUPTURE_SYNC_VAR  *pbd_Rupt);
int n_ActionLignePrev(char **ptb_InRecOwner,char **pbd_InRecChild) ;
int n_ConditionSyncPrev(char **ptb_InRecOwner,char **pbd_InRecChild);
int n_ActionFilsSansPerePrev(char **ptb_InRecOwner);

int n_InitAccpar(T_RUPTURE_VAR *pbd_Rupt) ;
int n_ActionLigneAccpar(char **pbd_InRec_Cur);
int n_IsR1ACCPAR(char **ptb_InRec,char **ptb_InRec_Cur);
int n_ActionFirstRuptAccpar ( char **ptb_InRec_Cur);

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


	/* Recuperation des arguments */
	Kn_Balshey = n_GetIntArgv( 1 ) ;
	

        /* ouverture des fichiers en sortie */
        if ( n_OpenFileAppl ("ESTC2130_O1","wt",&Kp_GTFil) == ERR )
                ExitPgm ( ERR_XX , "" );

        if ( n_OpenFileAppl ("ESTC2130_O2","wt",&Kp_PrevFil) == ERR )
                ExitPgm ( ERR_XX , "" );


        /* Initialisation de la varible bd_RuptPrev */
        if ( n_InitPrev(&bd_RuptPrev) )
                ExitPgm ( ERR_XX , "" );

        /* Initialisation de la varible bd_RuptGT */
        if ( n_InitGT(&bd_RuptGT) )
                ExitPgm ( ERR_XX , "" );

        /* Initialisation de la varible bd_RuptAccpar */
        if ( n_InitAccpar (&bd_RuptAccpar) )
                ExitPgm ( ERR_XX , "" );

        /* lancement du traitement du fichier */
        
        if ( n_ProcessingRuptureVar (&bd_RuptAccpar) == ERR )
                ExitPgm ( ERR_XX , "" );

        if (n_CloseFileAppl ("ESTC2130_O1",&Kp_GTFil))
                ExitPgm ( ERR_XX , "" );

        if (n_CloseFileAppl ("ESTC2130_O2",&Kp_PrevFil))
                ExitPgm ( ERR_XX , "" );

        if (n_CloseFileAppl("ESTC2130_I3",&(bd_RuptPrev.pf_InputFil))== ERR )
                ExitPgm ( ERR_XX , "" );

        if (n_CloseFileAppl ("ESTC2130_I1",&(bd_RuptGT.pf_InputFil)))
                ExitPgm ( ERR_XX , "" );

        if (n_CloseFileAppl ("ESTC2130_I2",&(bd_RuptAccpar.pf_InputFil)))
                ExitPgm ( ERR_XX , "" );

        if ( n_EndPgm () == ERR )
                ExitPgm ( ERR_XX , "" );

        exit(OK) ;

}

/*==============================================================================
objet :
        fonction d'initialisation de la variable de gestion de rupture du
        fichier des previsions.

retour :
        OK
==============================================================================*/
int n_InitPrev(T_RUPTURE_SYNC_VAR  *pbd_Rupt)
{
        DEBUT_FCT("n_InitPrev");

        memset(pbd_Rupt,0,sizeof(T_RUPTURE_SYNC_VAR));

        if ( n_OpenFileAppl ("ESTC2130_I3","rt",&(pbd_Rupt->pf_InputFil)))
                ExitPgm ( ERR_XX , "" );

        pbd_Rupt->n_NbRupture = 0  ;

        /* fonction du test de la ligne du maitre avec l'esclave */
        pbd_Rupt->ConditionEndSync      = n_ConditionSyncPrev;
        pbd_Rupt->n_FilsSansPere        = n_ActionFilsSansPerePrev;
        pbd_Rupt->n_ActionLigne         = n_ActionLignePrev ;

        pbd_Rupt->c_Separ               = '~' ;

        RETURN_VAL(OK);
}

/*==============================================================================
objet :
        fonction lancee pour chaque ligne des previsions

retour :
        OK ---> traitement correctement effectue
        ERR --> probleme rencontre
==============================================================================*/
int n_ActionLignePrev(
        char **ptb_InRecOwner ,/* adresse de la ligne du maitre */
        char **ptb_InRecChild  /* adresse de la ligne de l'esclave */
)
{
        int i;

        DEBUT_FCT("n_ActionLignePrev");


        //strcpy(sz_ligne,ptb_InRecChild[0]);
        for (i=0;i<PRE_NBCOLNEW;i++)
        {
                if (i==PRE_ADJCOD_CT)
                {
                    if ( atoi( ptb_InRecChild[PRE_ACY_NF] ) > Kn_Balshey )
                        //sprintf(sz_ligne,"%s~%s",sz_ligne, "0");
                        //strcpy(ptb_InRecChild[PRE_ADJCOD_CT],"0");
                        ptb_InRecChild[PRE_ADJCOD_CT]="0";
                     else
                        //sprintf(sz_ligne,"%s~%s",sz_ligne, ptb_InRecOwner[ACC_ADJCOD_CT]);
                        //strcpy(ptb_InRecChild[PRE_ADJCOD_CT],ptb_InRecOwner[ACC_ADJCOD_CT]);
                        ptb_InRecChild[PRE_ADJCOD_CT]=ptb_InRecOwner[ACC_ADJCOD_CT];
                }
                else if (i==PRE_RETCOD_CT)
                    //sprintf(sz_ligne,"%s~%s",sz_ligne, ptb_InRecOwner[ACC_RETCOD_CT]);
                    //strcpy(ptb_InRecChild[PRE_RETCOD_CT],ptb_InRecOwner[ACC_RETCOD_CT]);
                    ptb_InRecChild[PRE_RETCOD_CT]=ptb_InRecOwner[ACC_RETCOD_CT];
                else if (i==PRE_DETTRS_CF)
                {
                    if ( atoi( ptb_InRecChild[PRE_ACY_NF] ) > Kn_Balshey )
	                    //sprintf(sz_ligne,"%s~%s",sz_ligne, "");
	                    strcpy(ptb_InRecChild[PRE_DETTRS_CF],"");
	                else
	                    //sprintf(sz_ligne,"%s~%s",sz_ligne, ptb_InRecOwner[ACC_DETTRS_CF]);
	                    //strcpy(ptb_InRecChild[PRE_DETTRS_CF],ptb_InRecOwner[ACC_DETTRS_CF]);
	                    ptb_InRecChild[PRE_DETTRS_CF]=ptb_InRecOwner[ACC_DETTRS_CF];
 }
                //else if (i==PRE_ADJSIG_B) SBE On enlève suite à modification du nom du champ 20/02/2014
                //sprintf(sz_ligne,"%s~%s",sz_ligne, ptb_InRecOwner[ACC_ADJSIG_B]);
                //strcpy(ptb_InRecChild[PRE_ADJSIG_B],ptb_InRecOwner[ACC_ADJSIG_B]); SBE On enlève suite à modification du nom du champ 20/02/2014
//                else if (i==PRE_SPIMOD_CT) //[besoin.SGLA02]
//                    //sprintf(sz_ligne,"%s~%s",sz_ligne, ptb_InRecOwner[ACC_SPIMOD_CT]);
//                    //strcpy(ptb_InRecChild[PRE_SPIMOD_CT],ptb_InRecOwner[ACC_SPIMOD_CT]);
//                    ptb_InRecChild[PRE_SPIMOD_CT]=ptb_InRecOwner[ACC_SPIMOD_CT];
//                //else
                    //sprintf(sz_ligne,"%s~%s",sz_ligne, ptb_InRecChild[i]);

        }
        //fprintf(Kp_PrevFil,"%s\n",sz_ligne);
        n_WriteCols(Kp_PrevFil,ptb_InRecChild,'~',0);

        RETURN_VAL(OK);
}

/*==============================================================================
objet :
        Initialisation de la synchronisation du maitre avec l'esclave GT

retour :
        OK
==============================================================================*/
int n_InitGT(T_RUPTURE_SYNC_VAR  *pbd_Rupt)
{
        DEBUT_FCT("n_InitGT");

        memset( pbd_Rupt,0,sizeof(T_RUPTURE_SYNC_VAR) ) ;

        /* ouverture du fichier esclave */
        n_OpenFileAppl ("ESTC2130_I1","rt",&(pbd_Rupt->pf_InputFil));

        pbd_Rupt->n_NbRupture = 0  ;

        /* fonction du test de la ligne du maitre avec l'esclave */

        pbd_Rupt->ConditionEndSync      = n_ConditionSyncGT ;

        /* fonction d'action sur la ligne courante du fichier esclave */
        pbd_Rupt->n_ActionLigne         = n_ActionLigneGT ;

        pbd_Rupt->c_Separ               = '~' ;

        RETURN_VAL(OK);
}

/*==============================================================================
objet :
        Initialisation du maitre

retour :
        OK
==============================================================================*/
int n_InitAccpar(T_RUPTURE_VAR  *pbd_Rupt)
{
        DEBUT_FCT("n_InitAccpar");

        memset( pbd_Rupt,0,sizeof(T_RUPTURE_VAR) ) ;

        /* ouverture du fichier esclave */
        n_OpenFileAppl ("ESTC2130_I2","rt",&(pbd_Rupt->pf_InputFil));

        pbd_Rupt->n_NbRupture = 1  ;
        pbd_Rupt->n_ConditionRupture[0] = n_IsR1ACCPAR;
        pbd_Rupt->n_ActionFirst[0] = n_ActionFirstRuptAccpar;

        pbd_Rupt->n_ActionLigne         = n_ActionLigneAccpar ;

        pbd_Rupt->c_Separ               = '~' ;

        RETURN_VAL(OK);
}

/*==============================================================================
objet :
        fonction de test de rupture du niveau 1

retour :
        0   ---> Pas de rupture
        1   ---> rupture
==============================================================================*/
int n_IsR1ACCPAR(char **ptb_InRec,char **ptb_InRec_Cur)
{
        DEBUT_FCT("n_IsR1ACCPAR");

        if (strcmp(ptb_InRec[ACC_ACMTRS_NT],ptb_InRec_Cur[ACC_ACMTRS_NT])!=0)
                RETURN_VAL(1);

        RETURN_VAL(0);
}

/*==============================================================================
objet :
        Fonction lancee a chaque rupture premiere
==============================================================================*/
int n_ActionFirstRuptAccpar ( char **ptb_InRec_Cur)
{

        DEBUT_FCT("n_ActionFirstRuptAccpar");

        /* synchronisation du fichier des previsions */
        n_ProcessingRuptureSyncVar (&bd_RuptPrev, ptb_InRec_Cur) ;

        /* synchronisation du fichier GT */
        n_ProcessingRuptureSyncVar (&bd_RuptGT, ptb_InRec_Cur) ;

        RETURN_VAL(0);
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
int n_ConditionSyncGT(
        char **pbd_InRecOwner ,/* adresse de la ligne du maitre */
        char **pbd_InRecChild  /* adresse de la ligne de l'esclave */
        )
{
        int ret;

        DEBUT_FCT("n_ConditionSyncGT"); 
        

        if( (ret = strcmp(pbd_InRecOwner[ACC_ACMTRS_NT],pbd_InRecChild[GT_ACMTRS_NT])) != 0 ) RETURN_VAL(ret);

        RETURN_VAL(ret);
}

/*==============================================================================
objet :
        fonction de test de rupture du niveau 1
retour :
        0       ---> Pas de rupture
        < 0     ---> On n'est pas arrive au bloc synchrone
        > 0     ---> On a depasse le bloc synchrone
==============================================================================*/
int n_ConditionSyncPrev(
        char **pbd_InRecOwner ,/* adresse de la ligne du maitre */
        char **pbd_InRecChild  /* adresse de la ligne de l'esclave */
        )
{
        int ret ;

        DEBUT_FCT("n_ConditionSyncPrev");

        if( (ret = strcmp(pbd_InRecOwner[ACC_ACMTRS_NT],pbd_InRecChild[PRE_ACMTRS_NT])) != 0 ) RETURN_VAL(ret);

        RETURN_VAL(0);
}

/*==============================================================================
objet :
        fonction lancee quand le filsqui n'a pas de pere ACCPAR
retour :
        OK ---> traitement correctement effectue
        ERR --> probleme rencontre

==============================================================================*/

int n_ActionFilsSansPerePrev(  //pira 37617
        char **pbd_InRecChild  
)
{

    DEBUT_FCT("n_ActionFilsSansPerePrev");
  
      pbd_InRecChild[PRE_ADJCOD_CT] = "1"; 

	  n_WriteCols(Kp_PrevFil,pbd_InRecChild,'~',0);

RETURN_VAL(OK);
}

/*==============================================================================
objet :
        fonction lancee pour chaque ligne du GT synchronisee avec ACCPAR

retour :
        OK ---> traitement correctement effectue
        ERR --> probleme rencontre
==============================================================================*/
int n_ActionLigneGT(
        char **ptb_InRecOwner ,/* adresse de la ligne du maitre */
        char **ptb_InRecChild  /* adresse de la ligne de l'esclave */
) 
{
        int i;

        DEBUT_FCT("n_ActionLigneGT");

        //printf("\nTraceSeb --> n_ActionLigneGT\n");
        //strcpy(sz_ligne,ptb_InRecChild[0]);

        for (i=0;i<GT_NBCOL;i++)
        {
		/**********************************************************/
		/* Modifs du 30/03/98 et du 21/10/98 - M.HA-THUC / ANB    */
		/* Si en entree, ADJCOD_CT = 9 (section terminée) alors : */
		/* - on met ADJCOD_CT = 0 pour les criblés                */
		/* - on laisse ADJCOD_CT = 9 pour les non cribles      	  */
		/* Dans les 2 cas le but est de ne pas calculer ou de     */
		/* ne pas ventiler de compléments pour ces affaires       */
		/* (ce top est prépositionné par le programme ESTC2034    */
		/* dans le ESID2030)                                      */
		/**********************************************************/
            if (i==GT_ADJCOD_CT)
            {
                if ( ( atoi( ptb_InRecChild[GT_ADJCOD_CT] ) == 9 ) && ( ptb_InRecChild[GT_ESTCRB_CT][0] =='O' ) )
                     //sprintf(sz_ligne,"%s~%s",sz_ligne, "0" );
                     //strcpy(ptb_InRecChild[GT_ADJCOD_CT],"0");
                     ptb_InRecChild[GT_ADJCOD_CT]="0";
                else
                if ( ( atoi( ptb_InRecChild[GT_ADJCOD_CT] ) == 9 ) && 
                   ( ptb_InRecChild[GT_ESTCRB_CT][0] =='N' ) )
                    //sprintf(sz_ligne,"%s~%s",sz_ligne, "9" );
                    //strcpy(ptb_InRecChild[GT_ADJCOD_CT],"9");
                    ptb_InRecChild[GT_ADJCOD_CT]="9";
                else
                    //sprintf(sz_ligne,"%s~%s",sz_ligne, ptb_InRecOwner[ACC_ADJCOD_CT]);
                    //strcpy(ptb_InRecChild[GT_ADJCOD_CT],ptb_InRecOwner[ACC_ADJCOD_CT]);
                    ptb_InRecChild[GT_ADJCOD_CT]=ptb_InRecOwner[ACC_ADJCOD_CT];
            }
          
            //else if (i==GT_RETCOD_CT) SBE On enlève suite à modification du nom du champ 20/02/2014
              //sprintf(sz_ligne,"%s~%s",sz_ligne, ptb_InRecOwner[ACC_RETCOD_CT]);
              //strcpy(ptb_InRecChild[GT_RETCOD_CT],ptb_InRecOwner[ACC_RETCOD_CT]); SBE On enlève suite à modification du nom du champ 20/02/2014

            else if (i==GT_DETTRS_CF)
                //sprintf(sz_ligne,"%s~%s",sz_ligne, ptb_InRecOwner[ACC_DETTRS_CF]); //Seb, modification ici pour ces lignes, revoir l'affectation
                //strcpy(ptb_InRecChild[GT_DETTRS_CF],ptb_InRecOwner[ACC_DETTRS_CF]);
                ptb_InRecChild[GT_DETTRS_CF]=ptb_InRecOwner[ACC_DETTRS_CF];
          //else if (i==GT_ADJSIG_B) SBE On enlève suite à modification du nom du champ 20/02/2014
              //sprintf(sz_ligne,"%s~%s",sz_ligne, ptb_InRecOwner[ACC_ADJSIG_B]);
              //strcpy(ptb_InRecChild[GT_ADJSIG_B],ptb_InRecOwner[ACC_ADJSIG_B]); SBE On enlève suite à modification du nom du champ 20/02/2014
          
          //else if (i==GT_SPIMOD_CT) SBE On enlève suite à modification du nom du champ 20/02/2014
              //sprintf(sz_ligne,"%s~%s",sz_ligne, ptb_InRecOwner[ACC_SPIMOD_CT]);
              //strcpy(ptb_InRecChild[GT_SPIMOD_CT],ptb_InRecOwner[ACC_SPIMOD_CT]); SBE On enlève suite à modification du nom du champ 20/02/2014
            //else
              //sprintf(sz_ligne,"%s~%s",sz_ligne, ptb_InRecChild[i]);
        }
        //fprintf(Kp_GTFil,"%s\n",sz_ligne);
        
        n_WriteCols(Kp_GTFil,ptb_InRecChild,'~',0);

        //printf("TraceSeb <-- n_ActionLigneGT\n");
        RETURN_VAL(OK);
}

/*==============================================================================
objet :
        fonction lancee pour chaque ligne des postes regroupes
retour :
        OK ---> traitement correctement effectue
        ERR --> probleme rencontre
==============================================================================*/
int n_ActionLigneAccpar( char **ptb_InRec_Cur )

{
        DEBUT_FCT("n_ActionLigneAccpar");

        RETURN_VAL(OK);
}

