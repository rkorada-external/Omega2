/*==============================================================================
nom de l'application          : Actualisation des previsions annuelles
nom du source                 : ESTC2035.c
revision                      : $Revision:   1.5  $
date de creation              : 17/10/1997
auteur                        : P.LOUVEAU
references des specifications : ESIIV01F
squelette de base             : batch
------------------------------------------------------------------------------
description :


------------------------------------------------------------------------------
historique des modifications :
   <jj/mm/aaaa>   <auteur>    <description de la modification>
    
==============================================================================*/

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
#define NB_MAX_PILOT    20000    


FILE    *Kp_PilotIFil,  /* pointeur sur le fichier pilotage en entree */
        *Kp_PilotOFil,  /* pointeur sur le fichier pilotage en sortie */
        *Kp_AnoFil,     /* pointeur sur le fichier anomalies en sortie */
        *Kp_Prev1Fil,   /* pointeur sur le fichier previsions en sortie */
        *Kp_Prev2Fil,   /* pointeur sur le fichier previsions en sortie */
        *Kp_Prev3Fil,   /* pointeur sur le fichier previsions en sortie */
        *Kp_CoursFil;   /* Fichier des cours devise en entree */

T_RUPTURE_VAR bd_RuptPrev; /* gestion rupture sur previsions */
T_RUPTURE_SYNC_VAR bd_RuptPerim; /* gestion synchro perimetre-previsions */


int n_InitPerim (T_RUPTURE_SYNC_VAR *pbd_Rupt) ;
int n_ActionLignePerim  (char **ptb_InRecOwner,char **pbd_InRecChild) ;
int n_ConditionSyncPerim(char **ptb_InRecOwner,char **pbd_InRecChild);

int n_InitPrev(T_RUPTURE_VAR *pbd_Rupt) ;
int n_ActionLignePrevision(char **pbd_InRec_Cur);
int n_IsR1Prevision(char **ptb_InRec, char **ptb_InRec_Cur);
int n_ActionFirstRuptPrevision(char **ptb_InRec_Cur);
int n_IsR1PrevisionEx(char **ptb_InRec, char **ptb_InRec_Cur);
int n_ActionFirstRuptPrevisionEx(char **ptb_InRec_Cur);
int n_ActionPereSansFils(char **ptb_InRec);

int n_RechPilot (char **psz_prev, int n_indice);
int n_ChargerPilot();
int n_ReconduirePrevision (char **ptb_InRec_Cur);

int     Kn_DernierEx;           /* Dernier exercice du perimetre */
BOOL    Kb_Resilie;             /* TRUE si cas de traite eteint ou resilie */
int     Kn_TypeComptable,       /* Type comptable du perimetre */
        Kn_annee,                /* annee en cours pour conversion au dernier cours */
        Kn_etat;
char    Kc_crible,                              /* Code crible stocke sur rupture */
        Ksz_date[11],                   /* Date en parametre */
        Ksz_UWGRP_CF[10],       /* Unite de souscription ecrite en ano */
        Ksz_devise[4],                  /* Devise principale stockee */
        Ksz_nature[3];          /* nature du perimetre */

int     Kb_rupt1,       /* 1 si rupture de niveau 1, 0 sinon */
        Kb_rupt2,       /* 1 si rupture de niveau 2, 0 sinon */
        Kb_SyncPeri;

T_LIFDRI Kbd_PILOT[NB_MAX_PILOT];                /* Fichier pilotage charge en memoire */
int     Kn_NbLigPilot;                  /* Nombre de lignes dans le fichier pilotage */


/*==============================================================================
objet :
   point d'entree du programme

retour :
   En cas de probleme, la sortie s'effectue par la fonction ExitPgm().
   Sinon, par l'appel systeme exit()
==============================================================================*/
void main(int argc ,char *argv[])
{
        char sz_date[11];

        /* Initialisation des signaux */
        InitSig () ;

        if ( n_BeginPgm (argc  ,argv) == ERR )
                ExitPgm ( ERR_XX , "" );

        /* Recuperation de la date de traitement */
        strcpy(Ksz_date,psz_GetCharArgv(1));
        strcpy(sz_date,Ksz_date);
        sz_date[4]=0;
        Kn_annee = atoi(sz_date);

        /* ouverture des fichiers */
        if ( n_OpenFileAppl ("ESTC2035_O1","wt",&Kp_PilotOFil) == ERR )
                ExitPgm ( ERR_XX , "" );

        if ( n_OpenFileAppl ("ESTC2035_O2","wt",&Kp_Prev1Fil) == ERR )
                ExitPgm ( ERR_XX , "" );

        if ( n_OpenFileAppl ("ESTC2035_O3","wt",&Kp_AnoFil) == ERR )
                ExitPgm ( ERR_XX , "" );

        if ( n_OpenFileAppl ("ESTC2035_O4","wt",&Kp_Prev2Fil) == ERR )
                ExitPgm ( ERR_XX , "" );

        if ( n_OpenFileAppl ("ESTC2035_O5","wt",&Kp_Prev3Fil) == ERR )
                ExitPgm ( ERR_XX , "" );

        if ( n_OpenFileAppl ("ESTC2035_I4","rb",&Kp_CoursFil) == ERR )
                ExitPgm ( ERR_XX , "" );

                /* Initialisation de la varible bd_RuptPrev */
        if ( n_InitPrev(&bd_RuptPrev) )
                ExitPgm ( ERR_XX , "" );

        /* Initialisation de la varible bd_RuptPerim */
        if ( n_InitPerim(&bd_RuptPerim) )
                ExitPgm ( ERR_XX , "" );

        /* Chargement en memoire du fichier pilotage */
        n_ChargerPilot ();

        /* lancement du traitement du fichier */
        if ( n_ProcessingRuptureVar (&bd_RuptPrev) == ERR )
                ExitPgm ( ERR_XX , "" );

                /* Fermeture des fichiers */
        if (n_CloseFileAppl("ESTC2035_I1",&(bd_RuptPrev.pf_InputFil))== ERR )
                ExitPgm ( ERR_XX , "" );

        if (n_CloseFileAppl ("ESTC2035_I2",&(bd_RuptPerim.pf_InputFil)))
                ExitPgm ( ERR_XX , "" );

        if (n_CloseFileAppl ("ESTC2035_I3",&Kp_PilotIFil))
                ExitPgm ( ERR_XX , "" );

        if (n_CloseFileAppl ("ESTC2035_I4",&Kp_CoursFil))
                ExitPgm ( ERR_XX , "" );

        if (n_CloseFileAppl ("ESTC2035_O1",&Kp_PilotOFil))
                ExitPgm ( ERR_XX , "" );

        if (n_CloseFileAppl ("ESTC2035_O2",&Kp_Prev1Fil))
                ExitPgm ( ERR_XX , "" );

        if (n_CloseFileAppl ("ESTC2035_O3",&Kp_AnoFil))
                ExitPgm ( ERR_XX , "" );

        if (n_CloseFileAppl ("ESTC2035_O4",&Kp_Prev2Fil))
                ExitPgm ( ERR_XX , "" );

        if (n_CloseFileAppl ("ESTC2035_O5",&Kp_Prev3Fil))
                ExitPgm ( ERR_XX , "" );

        if ( n_EndPgm () == ERR )
                ExitPgm ( ERR_XX , "" );

        exit(OK) ;

}

/*==============================================================================
objet :
        fonction d'initialisation de la variable de gestion de rupture du 
        fichier maitre.

retour :
        OK
==============================================================================*/
int n_InitPrev(T_RUPTURE_VAR  *pbd_Rupt)
{
        DEBUT_FCT("n_InitPrev");

        memset(pbd_Rupt,0,sizeof(T_RUPTURE_VAR));

        if ( n_OpenFileAppl ("ESTC2035_I1","rt",&(pbd_Rupt->pf_InputFil))== ERR)
                RETURN_VAL (ERR);

        pbd_Rupt->n_NbRupture = 2  ;
        pbd_Rupt->n_ConditionRupture[0] = n_IsR1Prevision;
        pbd_Rupt->n_ActionFirst[0] = n_ActionFirstRuptPrevision;
        pbd_Rupt->n_ConditionRupture[1] = n_IsR1PrevisionEx;
        pbd_Rupt->n_ActionFirst[1] = n_ActionFirstRuptPrevisionEx;

        pbd_Rupt->n_ActionLigne = n_ActionLignePrevision ;

        pbd_Rupt->c_Separ = '~' ;

        RETURN_VAL (OK);
}

/*==============================================================================
objet :
        Initialisation de la synchronisation du maitre avec l'esclave Perim

retour :
        OK
==============================================================================*/
int n_InitPerim(T_RUPTURE_SYNC_VAR  *pbd_Rupt)
{
        DEBUT_FCT("n_InitPerim");

        memset( pbd_Rupt,0,sizeof(T_RUPTURE_SYNC_VAR) ) ;

        /* ouverture du fichier esclave */
        n_OpenFileAppl ("ESTC2035_I2","rt",&(pbd_Rupt->pf_InputFil));

        pbd_Rupt->n_NbRupture = 0;

        /* fonction du test de la ligne du maitre avec l'esclave */
        pbd_Rupt->ConditionEndSync      = n_ConditionSyncPerim ;
        /* fonction d'actions si le perimetre ne participe pas */
        pbd_Rupt->n_PereSansFils      = n_ActionPereSansFils;
        /* fonction d'action sur la ligne courante du fichier esclave */
        pbd_Rupt->n_ActionLigne         = n_ActionLignePerim ;

        pbd_Rupt->c_Separ               = '~' ;

        RETURN_VAL (OK);
}


/*==============================================================================
objet :
        fonction de test de rupture du niveau 1

retour :
        0   ---> Pas de rupture
        1   ---> rupture
==============================================================================*/
int n_IsR1Prevision(char **ptb_InRec,char **ptb_InRec_Cur)
{
        DEBUT_FCT("n_IsR1Prevision");

        Kb_rupt1=0;

        if (strcmp(ptb_InRec[PRE_CTR_NF],ptb_InRec_Cur[PRE_CTR_NF])!=0)
                RETURN_VAL(1);
        if (strcmp(ptb_InRec[PRE_SEC_NF],ptb_InRec_Cur[PRE_SEC_NF])!=0)
                RETURN_VAL(1);
        RETURN_VAL (0);
}


/*==============================================================================
objet :
        fonction de test de rupture du niveau 2

retour :
        0   ---> Pas de rupture
        1   ---> rupture
==============================================================================*/
int n_IsR1PrevisionEx(char **ptb_InRec,char **ptb_InRec_Cur)
{
        DEBUT_FCT("n_IsR1PrevisionEx");

        /* Rupture seconde initialisee */
        Kb_rupt2=0;

        if (strcmp(ptb_InRec[PRE_CTR_NF],ptb_InRec_Cur[PRE_CTR_NF])!=0)
                RETURN_VAL(1);
        if (strcmp(ptb_InRec[PRE_SEC_NF],ptb_InRec_Cur[PRE_SEC_NF])!=0)
                RETURN_VAL(1);
        if (strcmp(ptb_InRec[PRE_UWY_NF],ptb_InRec_Cur[PRE_UWY_NF])!=0)
                RETURN_VAL(1);
        RETURN_VAL (0);
}


/*==============================================================================
objet :
        fonction de test de rupture du niveau 1

retour :
        0       ---> pbd_InRecOwner = pbd_InRecChild
                        ( egalite de rubriques a synchroniser)
        > 0     ---> pbd_InRecOwner > pbd_InRecChild
        < 0     ---> pbd_InRecOwner < pbd_InRecChild
==============================================================================*/
int n_ConditionSyncPerim(
        char **pbd_InRecOwner ,/* adresse de la ligne du maitre */
        char **pbd_InRecChild  /* adresse de la ligne de l'esclave */
        )
{
        int ret;

        DEBUT_FCT("n_ConditionSyncPerim");

        if( (ret = strcmp(pbd_InRecOwner[PRE_CTR_NF],pbd_InRecChild[PER_CTR_NF])) != 0 )
                RETURN_VAL (ret);
        if( (ret = strcmp(pbd_InRecOwner[PRE_SEC_NF],pbd_InRecChild[PER_SEC_NF])) != 0 )
                RETURN_VAL (ret);
        if( (ret = strcmp(pbd_InRecOwner[PRE_UWY_NF],pbd_InRecChild[PER_UWY_NF])) != 0 )
                RETURN_VAL (ret);

        RETURN_VAL (0);
}


/**************************************************************************/
/*** Objet:     Recherche une ligne du tableau de structures ou les     ***/
/***            champs correspondent aux parametres en entree.          ***/
/***                                                                    ***/
/*** Nom:       n_RechPilot                                             ***/
/***                                                                    ***/
/*** Parametres:                                                        ***/
/***            La ligne du tableau contenant les valeurs recherchees   ***/
/***            Le nombre de lignes du tableau ou s'effectue la         ***/
/***            recherche                                               ***/
/***                                                                    ***/
/*** Retour:                                                            ***/
/***            Le numero de la ligne du tableau si trouve              ***/
/***            -1 si non trouve                                        ***/
/***                                                                    ***/
/**************************************************************************/
int n_RechPilot (char **psz_prev, int n_indice)
{
        int     b_chp1=0, b_chp2=0;     
                                      

        DEBUT_FCT("n_RechPilot");

        while (1==1)
        {
                /* Si les champs correspondent, on a trouve le debut    */
                /* du bloc. Sinon, et si on etait precedemment sur ce   */
                /* bloc, alors on ne peut plus trouver la ligne, donc   */
                /* on sort en retournant -1                             */
                if (strcmp(psz_prev[PRE_CTR_NF], Kbd_PILOT[n_indice].CTR_NF) ==0 )
                {
                  /* 1er champ trouve */
                  b_chp1=1;
                  if (atoi(psz_prev[PRE_SEC_NF])==
                        Kbd_PILOT[n_indice].SEC_NF)
                  {
                    /* 2eme champ trouve */
                    b_chp2=1;
                    RETURN_VAL (n_indice);
                  } else if (b_chp2==1) RETURN_VAL (-1);
                } else if (b_chp1==1) RETURN_VAL (-1);

                /* Ligne suivante */
                n_indice++;

                /* Si on a depasse la fin du tableau, ligne non trouvee */
                if (n_indice>=Kn_NbLigPilot) RETURN_VAL (-1);
        }
}


/*==============================================================================
objet :
        fonction d'ecriture dans le fichier d'anomalie

retour :
        OK ---> traitement correctement effectue
==============================================================================*/
int n_EcrireAno (int n_ano, char **ptb_InRec_Cur)
{
        DEBUT_FCT("n_EcrireAno");

        fprintf(Kp_AnoFil,"%d~%s~%s~%s~%s~%s~%s~%s~%s\n",
                                n_ano,
                                Ksz_UWGRP_CF,
                                ptb_InRec_Cur[PRE_CTR_NF],
                                ptb_InRec_Cur[PRE_SEC_NF],
                                ptb_InRec_Cur[PRE_UWY_NF],
                                ptb_InRec_Cur[PRE_ACY_NF],
                                ptb_InRec_Cur[PRE_ACMTRS_NT],
                                ptb_InRec_Cur[PRE_CUR_CF],
                                ptb_InRec_Cur[PRE_SSD_CF]
                                );

        RETURN_VAL (0);
}


/**************************************************************************/
/***                                                                    ***/
/*** Objet :    Copie le contenu du fichier en entree dans un tableau   ***/
/***                                                                    ***/
/*** Nom:       n_ChargerPilot                                          ***/
/***                                                                    ***/
/*** Parametres:                                                        ***/
/***            Le pointeur du fichier                                  ***/
/***            Le tableau de structures                                ***/
/***                                                                    ***/
/*** Retour:                                                            ***/
/***            0                                                       ***/
/***                                                                    ***/
/**************************************************************************/
int n_ChargerPilot()
{
        int n_EOF = 0;
        T_LIFDRI bd_Lu;
        char MsgAno[300];
    
        DEBUT_FCT("n_ChargerPilot");

        if ( n_OpenFileAppl ("ESTC2035_I3","rb",&Kp_PilotIFil) == ERR )
                ExitPgm ( ERR_XX , "" );


        Kn_NbLigPilot=0;
        /* Tant que la fin de fichier n'est pas atteinte,... */
        while ( n_EOF == 0 )
        {
                /* ... lecture d'une ligne dans le fichier. */
                if ( fread(&bd_Lu,sizeof(T_LIFDRI),1,Kp_PilotIFil) <= 0 )
                        /* Fin de fichier, mise a jour du flag */
                        n_EOF = 1;
                else {
                        /* Ecriture dans log si depassement du tableau */
                        if ( Kn_NbLigPilot >= NB_MAX_PILOT) {
                                sprintf(MsgAno,"The number of Driving records  (/CTR %s /SEC %d /UWY %d) overflows the program's storage capacity",
                                        bd_Lu.CTR_NF,
                                        bd_Lu.SEC_NF,
                                        bd_Lu.UWY_NF); 
                                n_WriteAno(MsgAno);
                                RETURN_VAL(0);
                        }
                    
                        /* Enregistrement ecrit dans le tableau */
                        Kbd_PILOT[Kn_NbLigPilot++] = bd_Lu;
                        /* affiche (&bd_Lu);*/
                }
        }
        RETURN_VAL (0);
}


/*==============================================================================
objet :
        Fonction lancee a chaque rupture premiere sur contrat/section
==============================================================================*/
int n_ActionFirstRuptPrevision ( char **ptb_InRec_Cur)
{
    
        DEBUT_FCT("n_ActionFirstRuptPrevision");

/*        printf("Rupt 1 CTR/SEC %s/%s\n",     ptb_InRec_Cur[PRE_CTR_NF],
                                             ptb_InRec_Cur[PRE_SEC_NF]);
*/        
        /* Initialisation du code crible */
        Kc_crible = ' ';

        /* Initialisation de UWGRP_CF si le perimetre ne participe pas */
        strcpy(Ksz_UWGRP_CF,"absente");
        
        Kb_rupt1 = 1;

        RETURN_VAL(OK);
}



/*==============================================================================
objet :
        Fonction lancee a chaque rupture premiere sur exercice
==============================================================================*/
int n_ActionFirstRuptPrevisionEx ( char **ptb_InRec_Cur)
{
        DEBUT_FCT("n_ActionFirstRuptPrevisionEx");

/*        printf("Rupt 2 CTR/SEC/EX %s/%s/%s\n",   ptb_InRec_Cur[PRE_CTR_NF],
                                                 ptb_InRec_Cur[PRE_SEC_NF],
                                                 ptb_InRec_Cur[PRE_UWY_NF]);
*/
        Kb_rupt2=1;

        /* Synchronisation du fichier perimetre pour cette ligne */
        n_ProcessingRuptureSyncVar (&bd_RuptPerim, ptb_InRec_Cur);        

        RETURN_VAL(OK);
}


/*==============================================================================
objet :
        fonction lancee pour chaque ligne du perimetre synchronisee
        avec les previsions

retour :
        OK ---> traitement correctement effectue
        ERR --> probleme rencontre
==============================================================================*/
int n_ActionLignePerim(
        char **ptb_InRecOwner ,/* adresse de la ligne du maitre */
        char **ptb_InRecChild  /* adresse de la ligne de l'esclave */
)
{
        int Kn_status;
        
        DEBUT_FCT("n_ActionLignePerim");

/*        printf("SYNCHRO avec perimetre\n");
        printf("------  PERIMETRE  -----\n");
        printf("%s/%s/%s/%s/%s/%s/%s\n",
                ptb_InRecChild[PER_SSD_CF],
                ptb_InRecChild[PER_CTR_NF],
                ptb_InRecChild[PER_END_NT],
                ptb_InRecChild[PER_SEC_NF],
                ptb_InRecChild[PER_UWY_NF],
                ptb_InRecChild[PER_UW_NT],
                ptb_InRecChild[PER_PCPCUR_CF]);
        printf("-----------------------\n");
*/
        Kb_SyncPeri = 1;

        Kn_DernierEx            = atoi(ptb_InRecChild[PER_UWY_NF]);
        Kn_TypeComptable        = atoi(ptb_InRecChild[PER_ACCADMTYP_CT]);
        Kn_status               = atoi(ptb_InRecChild[PER_SECSTS_CT]);
        Kn_etat                 = atoi(ptb_InRecChild[PER_SECACCSTS_CT]);
        
        if ( (Kn_status==18) || (Kn_status==19) )
                Kb_Resilie = TRUE;
        else    Kb_Resilie = FALSE;
/*        
        if (Kb_Resilie == TRUE) 
                 printf("RESILIE\n");
        else printf("NON RESILIE\n");
*/
        /* Memorisation, traitement devise */
        strcpy(Ksz_devise,ptb_InRecChild[PER_PCPCUR_CF]);
        strcpy(Ksz_UWGRP_CF,ptb_InRecChild[PER_UWGRP_CF]);

        /* Memorisation du code crible et de l'etat */
        Kc_crible = ptb_InRecChild[PER_ESTCRB_CT][0];

        strcpy ( Ksz_nature, ptb_InRecChild[PER_NAT_CF]);
/*        printf("nature = %s\n", Ksz_nature); */
/*        printf("Etat = %d  Crible = %c\n", Kn_etat, Kc_crible); */
        
        RETURN_VAL (OK);        
}


/*==============================================================================
objet :
        fonction d'action si le perimetre n'existe pas
retour :
        OK ---> traitement correctement effectue
==============================================================================*/
int n_ActionPereSansFils(char **ptb_InRec)
{

    DEBUT_FCT("n_EcrireAno");

/*    printf("Prevision SANS Perimetre\n");  */

    if (Kc_crible=='N') RETURN_VAL (OK);

    Kb_SyncPeri = 0;

    RETURN_VAL (OK);
}


/*==============================================================================
objet :
        fonction d'ecriture d'un enregistrement LIFDRI
retour :
        OK ---> traitement correctement effectue
==============================================================================*/
int n_ReconduirePilotage ( char **ptb_InRec_Cur)
{
        static int Kn_SyncPilot = 0;

        DEBUT_FCT("n_ReconduirePrevision");

        /* reconduction de tous les LIFDRI correspondant au contrat/section */
        if (Kc_crible!='N')
        {
             /* Synchronisation du Pilotage pour cette ligne */
/*             printf("reconduction LIFDRI %s %s \n",
                                ptb_InRec_Cur[PRE_CTR_NF],
                                ptb_InRec_Cur[PRE_SEC_NF]);
*/                                                                
             while ((Kn_SyncPilot = n_RechPilot(ptb_InRec_Cur,Kn_SyncPilot))!=-1) {
                                Kbd_PILOT[Kn_SyncPilot].UPD_NF=' ';
                                fwrite(&Kbd_PILOT[Kn_SyncPilot],
                                sizeof(T_LIFDRI),1,Kp_PilotOFil);
                                Kn_SyncPilot++ ;
                        }
        } /* fin reconduction LIFDRI */
        
        RETURN_VAL(OK);
}



/*==============================================================================
objet :
        fonction d'ecriture d'une prevision dans le fichier adequat
retour :
        OK ---> traitement correctement effectue
==============================================================================*/
int n_ReconduirePrevision ( char **ptb_InRec_Cur)
{
    DEBUT_FCT("n_ReconduirePrevision");

        if (Kn_etat==9) {
/*                printf("%s %s: type 9 => Ecriture prev3\n",
                        ptb_InRec_Cur[PRE_CTR_NF],
                        ptb_InRec_Cur[PRE_UWY_NF]);
*/                        
                n_WriteCols(Kp_Prev3Fil,ptb_InRec_Cur,SEPARATEUR,0);
                RETURN_VAL (OK);
        }

        if ( (atoi(ptb_InRec_Cur[PRE_ACY_NF]) <= Kn_annee) &&
             (atoi(ptb_InRec_Cur[PRE_UWY_NF]) <= Kn_annee) ) {
/*                printf("%s %s: => Ecriture prev1\n",
                        ptb_InRec_Cur[PRE_CTR_NF],
                        ptb_InRec_Cur[PRE_UWY_NF]); */
                n_WriteCols(Kp_Prev1Fil,ptb_InRec_Cur,SEPARATEUR,0);
                RETURN_VAL (OK);
        }
/*        printf("%s %s: => Ecriture prev2\n",
                        ptb_InRec_Cur[PRE_CTR_NF],
                        ptb_InRec_Cur[PRE_UWY_NF]); */
        n_WriteCols(Kp_Prev2Fil,ptb_InRec_Cur,SEPARATEUR,0);
        RETURN_VAL (OK);
}


/*==============================================================================
objet :
        fonction lancee pour chaque ligne du maitre

retour :
        OK ---> traitement correctement effectue
        ERR --> probleme rencontre
==============================================================================*/
int n_ActionLignePrevision( char **ptb_InRec_Cur)
{
        double d_taux,d_montant;
        int exercice, annee_compte;
        int n_liberation, n_poste;
        int b_Type5_Prime = FALSE;
        char sz_montant[30];
        char sz_vide[2] = "";
        
        DEBUT_FCT("n_ActionLignePrevision");

/*        printf("ActionLignePrevision...\n");  */

        annee_compte  = atoi(ptb_InRec_Cur[PRE_ACY_NF]);
        exercice      = atoi(ptb_InRec_Cur[PRE_UWY_NF]);
        
        /* Suppression des non crible */
        if (Kc_crible == 'N') RETURN_VAL (OK);

        /* Reconduction des pilotage en rupture 1ere sur contrat/section */
        if (Kb_rupt1 == 1) n_ReconduirePilotage (ptb_InRec_Cur);

        /* Renseignement de la nature */
        if (Kb_SyncPeri==1) ptb_InRec_Cur[PRE_NAT_CF] = Ksz_nature;
        else  ptb_InRec_Cur[PRE_NAT_CF] = sz_vide;
 
        /* Conversion devise si difference */
        if (strcmp(ptb_InRec_Cur[PRE_CUR_CF],Ksz_devise)!=0)
        {
/*            printf("Conversion %s => %s\n", ptb_InRec_Cur[PRE_CUR_CF], Ksz_devise); */
            if (Kb_rupt2) n_EcrireAno(A_ChmtDev,ptb_InRec_Cur);
            d_taux = d_GetTaux(Kp_CoursFil,(char)atoi(ptb_InRec_Cur[PRE_SSD_CF]),
                                (short)Kn_annee,ptb_InRec_Cur[PRE_CUR_CF],Ksz_devise);
            d_montant = atof(ptb_InRec_Cur[PRE_ESTMNT_M]) * d_taux;
/*            printf("Montant %s %lf\n", ptb_InRec_Cur[PRE_ESTMNT_M], d_montant); */
            sprintf(sz_montant,"%.3lf",d_montant);
            ptb_InRec_Cur[PRE_ESTMNT_M] = sz_montant;
            ptb_InRec_Cur[PRE_CUR_CF]   = Ksz_devise; 
        }

        if (Kn_etat==9) {
            n_ReconduirePrevision (ptb_InRec_Cur);
            RETURN_VAL(OK);
        }
        
        /* Cas du type 1 */
        if (Kn_TypeComptable == 1) {
/*                printf("type comptable 1\n"); */
                if ( annee_compte > exercice )
                {
/*                        printf(" Ac>exercice => ANO\n"); */
                        if (Kb_rupt2==1) n_EcrireAno(A_Type1,ptb_InRec_Cur);
                        RETURN_VAL(OK);
                }
                else {
                        n_ReconduirePrevision (ptb_InRec_Cur);
                        RETURN_VAL(OK);
                }
        }

        /* Cas du type 2 */
        if (Kn_TypeComptable == 2) {
/*                printf("type comptable 2\n"); */
                if ( (exercice>Kn_DernierEx) && (Kb_Resilie==TRUE) )
                {
                     /*   printf("Ex>Ex resiliation\n"); */
                        if (Kb_rupt2==1) n_EcrireAno(A_Type2,ptb_InRec_Cur);
                }
                else n_ReconduirePrevision (ptb_InRec_Cur);
                RETURN_VAL(OK);
        }
                    
        /* Cas du type 3 */
        if (Kn_TypeComptable == 3) {
/*                printf("type comptable 3\n"); */
                n_poste = ( atoi(ptb_InRec_Cur[PRE_ACMTRS_NT]) / 100 ) % 10;
                /* si type comptable 3, Ac>exercice et poste sinistre, ecrire une anomalie et pas de prevision */
                if ( (annee_compte > exercice) && (n_poste==2) )
                {
/*                        printf("Ac > Ex et poste sinistre \n"); */
                        if (Kb_rupt2==1) n_EcrireAno(A_Type3,ptb_InRec_Cur);
                }
                else n_ReconduirePrevision (ptb_InRec_Cur);                                         
                RETURN_VAL(OK);
        }     


        /* Cas du type 5 : initialisation de b_Type5_Prime: poste x0xx, x5xx, 1304 */
        if (Kn_TypeComptable == 5) {
                n_poste = ( atoi(ptb_InRec_Cur[PRE_ACMTRS_NT]) / 100 ) % 10;
                if ( (n_poste == 0) || (n_poste == 5) ) b_Type5_Prime = TRUE;
                if ( atoi(ptb_InRec_Cur[PRE_ACMTRS_NT]) == 1304 ) b_Type5_Prime = TRUE;
        } 
            

        /* Cas du type 4 ou type 5 primes */
        if ( (Kn_TypeComptable == 4) || (b_Type5_Prime == TRUE) ) {
                n_liberation = atoi(ptb_InRec_Cur[PRE_ACMTRS_NT]) % 10;
/*                printf("type comptable 4\n"); */
                if ( (annee_compte > Kn_DernierEx) && (Kb_Resilie==TRUE) )
                {
/*                        printf("Ex>Ex resiliation\n"); */
                        if (Kb_rupt2==1) n_EcrireAno(A_Type45,ptb_InRec_Cur);
                        /* cas special liberation, exercice suivant */
                        if ( (annee_compte == Kn_DernierEx+1) && (Kb_Resilie==TRUE) && (n_liberation==4) )
                        {
/*                            printf("Ex + 1 et liberation => reconduction\n"); */
                            sprintf(ptb_InRec_Cur[PRE_UWY_NF], "%d", Kn_DernierEx);
                            n_ReconduirePrevision (ptb_InRec_Cur);
                        }
                }
                else n_ReconduirePrevision (ptb_InRec_Cur);
                RETURN_VAL(OK);
        }


        /* Cas du type 5 sinistre */
        if ( (Kn_TypeComptable == 5) && (b_Type5_Prime == FALSE) ) {
/*                printf("type comptable 5 sinistre\n"); */
                if ( (exercice>Kn_DernierEx) && (Kb_Resilie==TRUE) )
                {
/*                        printf("Ex>Ex resiliation\n");*/
                        if (Kb_rupt2==1) n_EcrireAno(A_Type45,ptb_InRec_Cur);
                }
                else n_ReconduirePrevision (ptb_InRec_Cur);                
                RETURN_VAL(OK);
        }     

        RETURN_VAL(OK);
}






    
