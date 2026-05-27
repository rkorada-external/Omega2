/*==============================================================================
nom de l'application          : Prise en compte des AS pour les previsions
nom du source                 : ESTC2038.c
revision                      : $Revision:   1.8  $
date de creation              : 24/06/1997
auteur                        : C. Chavatte
references des specifications : ESIIV01F
squelette de base             : batch
------------------------------------------------------------------------------
description :


------------------------------------------------------------------------------
historique des modifications :
   <jj/mm/aaaa>   <auteur>    <description de la modification>
           ...           ...            ...              ...
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
#define NB_MAX_PILOT    20000
/*----------------------------------------------*/
/* Structure utilisee pour stocker la cle du GT */
/*----------------------------------------------*/
typedef struct {
        int ACMTRS_NT;
        char AMT_M[25];
} T_CleGT;

/*----------------------*/
/* variables de travail */
/*----------------------*/

FILE    *Kp_PilotIFil,  /* Pointeur sur le fichier pilotage en entree */
        *Kp_PilotOFil,  /* Pointeur sur le fichier pilotage en sortie */
        *Kp_PrevOFil;   /* pointeur sur les previsions en sortie */
T_LIFDRI Kbd_PILOT[NB_MAX_PILOT];/* Fichier pilotage charge en memoire */
int     Kn_NbLigPilot,  /* Nombre de lignes dans le fichier pilotage */
        Kn_SyncPilot;   /* =-1 si le fichier pilotage n'est pas synchronise, */
                        /* numero de la ligne synchronisee sinon */
T_RUPTURE_VAR bd_RuptGT;/* gestion rupture sur GT */
T_RUPTURE_SYNC_VAR bd_RuptPrev; /* gestion synchro c. previsions-GT */
int     Kb_SyncPilot,   /* Indicateur de synchro. du fichier pilotage */
        Kb_SyncPrev,    /* Indicateur de synchro. du fichier previsions */
        Kb_AUTUPD;      /* Indicateur de MAJ automatique */
CS_TINYINT Kn_FinPer,   /* Mois de fin de periode d'envoi */
           Kn_Period;   /* Periodicite d'envoi des provisions */
T_CleGT Kbd_CleGT[50];  /* Tableau des postes cumul de la rupture */
int     Kn_CleGT=0;     /* Nombre de lignes dans ce tableau */
char    Ksz_DateJour[11];       /* Date de traitement */
int     Kn_BalYear,     
        Kn_BalMonth;         
char    Ksz_Balshey[6], 
        Ksz_Balshtmth[6]; 
        
double  Kf_PnaFarRec5,  /* Cumul des constitutions PNA, FAR et REC (x5xx) */
        Kf_PnaFarRec6;  /* Cumul des constitutions PNA, FAR et REC (x6xx) */
int     Kb_PnaFarRec5,  /* Indique si on a vu passer du PNA, FAR ou REC */
        Kb_PnaFarRec6;



int n_InitPrev(T_RUPTURE_SYNC_VAR *pbd_Rupt) ;
int n_ActionLignePrev(char **ptb_InRecOwner,char **pbd_InRecChild) ;
int n_ConditionSyncPrev(char **ptb_InRecOwner,char **pbd_InRecChild);
int n_ActionPrevSansGT(char **ptb_InRecOwner);
int n_ActionGTsansPrev(char **ptb_InRecOwner);

int n_InitGT(T_RUPTURE_VAR *pbd_Rupt) ;
int n_ActionLigneGT(char **pbd_InRec_Cur);
int n_IsR1GT(char **ptb_InRec, char **ptb_InRec_Cur);
int n_ActionLastRuptGT ( char **ptb_InRec_Cur);
void MemoGT (char **ptb_InRec);
int n_SyncGT(char *ACMTRS_NT);
void CreationPrevision(char c_origine,char *AMT_M,char **ptb_InRec);
void CreationLiberation(char *ACMTRS_NT, double AMT_M, char **ptb_InRec);
void CreationConstitutionNonVie(char *ACMTRS_NT,double AMT_M,char **ptb_InRec);

/*==============================================================================
objet :
   point d'entree du programme

retour :
   En cas de probleme, la sortie s'effectue par la fonction ExitPgm().
   Sinon, par l'appel systeme exit()
==============================================================================*/
void main(int argc ,char *argv[])
{
        /* Initialisation des signaux */
        InitSig () ;

        if ( n_BeginPgm (argc  ,argv) == ERR )
                ExitPgm ( ERR_XX , "" );

        /* Recuperation des parametres et calcul des zones qui en decoulent */
        strcpy(Ksz_Balshey,   psz_GetCharArgv(1));
        strcpy(Ksz_Balshtmth, psz_GetCharArgv(2));
        strcpy(Ksz_DateJour,psz_GetCharArgv(3));
        
        Kn_BalYear  = atoi(Ksz_Balshey);
        Kn_BalMonth = atoi(Ksz_Balshtmth);

        /* ouverture des fichiers */
        if ( n_OpenFileAppl ("ESTC2038_O1","wt",&Kp_PilotOFil) == ERR )
                ExitPgm ( ERR_XX , "" );

        if ( n_OpenFileAppl ("ESTC2038_O2","wt",&Kp_PrevOFil) == ERR )
                ExitPgm ( ERR_XX , "" );

        /* Initialisation de la varible bd_RuptGT */
        if ( n_InitGT(&bd_RuptGT) )
                ExitPgm ( ERR_XX , "" );

        /* Initialisation de la varible bd_RuptPrev */
        if ( n_InitPrev(&bd_RuptPrev) )
                ExitPgm ( ERR_XX , "" );

        /* Chargement en memoire du fichier pilotage */
         n_ChargerPilot ();

        /* lancement du traitement du fichier */
        if ( n_ProcessingRuptureVar (&bd_RuptGT) == ERR )
                ExitPgm ( ERR_XX , "" );

        if (n_CloseFileAppl ("ESTC2038_I1",&(bd_RuptGT.pf_InputFil)))
                ExitPgm ( ERR_XX , "" );

        if (n_CloseFileAppl ("ESTC2038_I3",&(bd_RuptPrev.pf_InputFil)))
                ExitPgm ( ERR_XX , "" );

        if (n_CloseFileAppl ("ESTC2038_I2",&Kp_PilotIFil))
                ExitPgm ( ERR_XX , "" );

        if (n_CloseFileAppl ("ESTC2038_O1",&Kp_PilotOFil))
                ExitPgm ( ERR_XX , "" );

        if (n_CloseFileAppl ("ESTC2038_O2",&Kp_PrevOFil))
                ExitPgm ( ERR_XX , "" );

        if ( n_EndPgm () == ERR )
                ExitPgm ( ERR_XX , "" );

        exit(0) ;

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
int n_RechPilot (char **psz_GT)
{
        int     n_indice = 0,   /* indice dans le tableau parcouru */
                b_chp1=0,b_chp2=0,b_chp3=0;
                                /* Indiquent si le champ a deja ete trouve */

        DEBUT_FCT("n_RechPilot");

        while (1==1)
        {
                /* Si les champs correspondent, on a trouve le debut    */
                /* du bloc. Sinon, et si on etait precedemment sur ce   */
                /* bloc, alors on ne peut plus trouver la ligne, donc   */
                /* on sort en retournant -1                             */
                if (strcmp(psz_GT[GT_CTR_NF],Kbd_PILOT[n_indice].CTR_NF)==0)
                {
                  /* 1er champ trouve */
                  b_chp1=1;
                  if (atoi(psz_GT[GT_SEC_NF])==Kbd_PILOT[n_indice].SEC_NF)
                  {
                    /* 2eme champ trouve */
                    b_chp2=1;
                    /* 3eme champ trouve: plus aucun controle sur l'exercice */
                    b_chp3=1;
                    /* Si le 4eme champ correspond, retour de l'indice */
                    if (atoi(psz_GT[GT_ACY_NF])==Kbd_PILOT[n_indice].ACY_NF)
                        RETURN_VAL (n_indice);
                  } else if (b_chp2==1) RETURN_VAL (-1);
                } else if (b_chp1==1) RETURN_VAL (-1);

                /* Ligne suivante */
                n_indice++;

                /* Si on a depasse la fin du tableau, ligne non trouvee */
                if (n_indice>=Kn_NbLigPilot) RETURN_VAL (-1);
        }
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

        if ( n_OpenFileAppl ("ESTC2038_I2","rb",&Kp_PilotIFil) == ERR )
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
        fonction d'initialisation de la variable de gestion de rupture du GT.

retour :
        0
==============================================================================*/
int n_InitGT(T_RUPTURE_VAR  *pbd_Rupt)
{
        DEBUT_FCT("n_InitGT");

        memset(pbd_Rupt,0,sizeof(T_RUPTURE_VAR));

        if ( n_OpenFileAppl ("ESTC2038_I1","rt",&(pbd_Rupt->pf_InputFil)))
                RETURN_VAL (ERR);

        pbd_Rupt->n_NbRupture = 1;
        pbd_Rupt->n_ConditionRupture[0] = n_IsR1GT;
        pbd_Rupt->n_ActionLast[0] = n_ActionLastRuptGT;

        pbd_Rupt->n_ActionLigne = n_ActionLigneGT ;

        pbd_Rupt->c_Separ = '~' ;

        RETURN_VAL (0);
}

/*==============================================================================
objet :
        fonction de test de rupture du niveau 1

retour :
        0   ---> Pas de rupture
        1   ---> rupture
==============================================================================*/
int n_IsR1GT(char **ptb_InRec,char **ptb_InRec_Cur)
{
        DEBUT_FCT("n_IsR1GT");

        if (strcmp(ptb_InRec[GT_CTR_NF],ptb_InRec_Cur[GT_CTR_NF])!=0)
                RETURN_VAL(1);
        if (strcmp(ptb_InRec[GT_SEC_NF],ptb_InRec_Cur[GT_SEC_NF])!=0)
                RETURN_VAL(1);
        if (strcmp(ptb_InRec[GT_UWY_NF],ptb_InRec_Cur[GT_UWY_NF])!=0)
                RETURN_VAL(1);
        if (strcmp(ptb_InRec[GT_ACY_NF],ptb_InRec_Cur[GT_ACY_NF])!=0)
                RETURN_VAL(1);

        RETURN_VAL (0);
}

/*==============================================================================
objet :
        Fonction lancee a chaque rupture derniere sur contrat
==============================================================================*/
int n_ActionLastRuptGT (char **ptb_InRec_Cur)
{
        int i;
        char sz_acmtrs[5];
        T_LIFDRI bd_new;
        double d_montant;
        char sz_new_cre[20];

        DEBUT_FCT("n_ActionLastRuptGT");

        /* A priori, on suppose que le pilotage n'est pas syncrho */
        Kn_SyncPilot = -1;
        Kb_AUTUPD=0;

        /* Si le GT est en Arrete statistique: */
        if (ptb_InRec_Cur[GT_COMACC_B][0]=='1')
        {
          /* synchronisation du fichier Pilotage pour cette ligne ...   */
          Kn_SyncPilot = n_RechPilot(ptb_InRec_Cur);

          /* ... et recuperation de l'indicateur de maj automatique     */
          if (Kn_SyncPilot>=0)
                Kb_AUTUPD=Kbd_PILOT[Kn_SyncPilot].AUTUPD_B;
          else
                Kb_AUTUPD=1;
        } /* Fin de la condition "AS" du GT */

        /* Avant synchro, mise a zero du cumul et des indicateurs */
        Kf_PnaFarRec5=0;
        Kf_PnaFarRec6=0;
        Kb_PnaFarRec5=0;
        Kb_PnaFarRec6=0;

        /* Synchronisation des previsions */
        Kb_SyncPrev=0;
        n_ProcessingRuptureSyncVar(&bd_RuptPrev, ptb_InRec_Cur);

        if (ptb_InRec_Cur[GT_COMACC_B][0]=='1')
        {
          /* Si previsions synchro., creation pilotage  */
          /* avec la date du jour et l'AS positionne a 1*/
          if (Kb_SyncPrev==1)
          {
            /* Si pilotage synchro, ajout d'une ligne avec annee-mois bilan */
            sprintf(sz_new_cre, "%s %s", Ksz_DateJour, "23:58:58");   /* MODIF CRE_D */
         /*   printf("Nouvelle date cre_d=|%s|\n", sz_new_cre);*/
            
            if (Kn_SyncPilot>=0)
            {
                bd_new=Kbd_PILOT[Kn_SyncPilot];
                if (bd_new.COMACC_B != 1) {
                        bd_new.COMACC_B=1;
                        bd_new.UPD_NF='I';
                        strcpy(bd_new.CRE_D,sz_new_cre);
                        bd_new.BALSHEY_NF=Kn_BalYear;
                        bd_new.BALSHTMTH_NF=Kn_BalMonth;
                        bd_new.CMT_NT=0;
                        fwrite(&bd_new,sizeof(T_LIFDRI),1,Kp_PilotOFil);
                }
            }
            /* Sinon, creation d'une nouvelle ligne dans le pilotage */
            else
            {
                bd_new.UPD_NF='I';
                sprintf(bd_new.CTR_NF,"%.9s",ptb_InRec_Cur[GT_CTR_NF]);
                bd_new.END_NT=atoi(ptb_InRec_Cur[GT_END_NT]);
                bd_new.SEC_NF=atoi(ptb_InRec_Cur[GT_SEC_NF]);
                bd_new.UWY_NF=atoi(ptb_InRec_Cur[GT_ACY_NF]);
                bd_new.UW_NT=atoi(ptb_InRec_Cur[GT_UW_NT]);
                bd_new.ACY_NF=atoi(ptb_InRec_Cur[GT_ACY_NF]);
                bd_new.SSD_CF=atoi(ptb_InRec_Cur[GT_SSD_CF]);
                bd_new.BALSHEY_NF=Kn_BalYear;
                bd_new.BALSHTMTH_NF=Kn_BalMonth;
                bd_new.AUTUPD_B=1;
                bd_new.COMACC_B=1;
                strcpy(bd_new.CRE_D,sz_new_cre);
                bd_new.CMT_NT=0;
                /* Nouvelles donnees */
                strcpy(bd_new.CREUSR_CF, "");
                strcpy(bd_new.LSTUPDUSR_CF, "");
                strcpy(bd_new.LSTUPD_D, "");
                /* ----------------- */
                fwrite(&bd_new,sizeof(T_LIFDRI),1,Kp_PilotOFil);
            }
          }

          /* Pour tous les postes qui sont encore dans la liste (qui    */
          /* sont ceux auxquels ne correspond aucune prevision), une    */
          /* nouvelle prevision est cree, sauf si le montant est nul.   */
          if ( (Kb_AUTUPD==1) && (Kb_SyncPrev==1) ) for (i=0;i<Kn_CleGT;i++)
          {
            d_montant=-1*atof(Kbd_CleGT[i].AMT_M);

            /* Un poste fait partie de la liste ssi ACMTRS_NT <> 0      */
            if ( (Kbd_CleGT[i].ACMTRS_NT!=0) && (d_montant!=0) )
            {
                sprintf(sz_acmtrs,"%4.4d",Kbd_CleGT[i].ACMTRS_NT);

                /* On ne cree pas de prevision sur une liberation */
                if (sz_acmtrs[3]!='4')
                {
                  /* Creation de la prevision avec le montant du GT... */
                  ptb_InRec_Cur[GT_ACMTRS_NT]=sz_acmtrs;
                  CreationPrevision('G',Kbd_CleGT[i].AMT_M,ptb_InRec_Cur);

                  /* et on cree a la fois une constitution et une */
                  /* liberation quand on est sur une constitution */
                  if (sz_acmtrs[3]=='3')
                  {
                    if (sz_acmtrs[1]=='5')
                    {
                      Kb_PnaFarRec5=1;
                      Kf_PnaFarRec5+=d_montant;
                    }
                    else if (sz_acmtrs[1]=='6')
                    {
                      Kb_PnaFarRec6=1;
                      Kf_PnaFarRec6+=d_montant;
                    }
                    else CreationLiberation(sz_acmtrs,d_montant,
                                        ptb_InRec_Cur);
                  }
                }
            }
          }

          /* S'il y a eu des postes de constitution PNA, FAR ou REC     */
          /* creation de la liberation correspondant a la somme.        */
          if (Kb_PnaFarRec5==1)
          {
                CreationConstitutionNonVie("1063",Kf_PnaFarRec5,ptb_InRec_Cur);
                CreationLiberation("1064",Kf_PnaFarRec5,ptb_InRec_Cur);
          }
          if (Kb_PnaFarRec6==1)
          {
                CreationConstitutionNonVie("1083",Kf_PnaFarRec6,ptb_InRec_Cur);
                CreationLiberation("1084",Kf_PnaFarRec6,ptb_InRec_Cur);
          }
        }

        /* Reinitialisation du compteur du tableau GT */
        Kn_CleGT=0;

        RETURN_VAL(0);
}

/*==============================================================================
objet :
        fonction lancee pour chaque ligne du GT

retour :
        0 ----> traitement correctement effectue
        ERR --> probleme rencontre
==============================================================================*/
int n_ActionLigneGT(char **ptb_InRec_Cur)
{
        DEBUT_FCT("n_ActionLigneGT");

        /* La ligne du GT est memorisee */
        MemoGT(ptb_InRec_Cur);

        RETURN_VAL (0);
}

/*==============================================================================
objet :
        Initialisation de la synchronisation du GT avec les previsions

retour :
        0
==============================================================================*/
int n_InitPrev(T_RUPTURE_SYNC_VAR  *pbd_Rupt)
{
        DEBUT_FCT("n_InitPrev");

        memset( pbd_Rupt,0,sizeof(T_RUPTURE_SYNC_VAR) ) ;

        /* ouverture du fichier previsions */
        n_OpenFileAppl ("ESTC2038_I3","rt",&(pbd_Rupt->pf_InputFil));

        pbd_Rupt->n_NbRupture = 0;

        /* fonction du test de la ligne du GT avec les previsions */
        pbd_Rupt->ConditionEndSync = n_ConditionSyncPrev;

        /* fonction d'action quand le GT est seul */
        pbd_Rupt->n_PereSansFils = n_ActionGTsansPrev;

        /* fonction d'action quand les previsions sont seules */
        pbd_Rupt->n_FilsSansPere = n_ActionPrevSansGT;

        /* fonction d'action sur la ligne courante du fichier previsions */
        pbd_Rupt->n_ActionLigne = n_ActionLignePrev;

        pbd_Rupt->c_Separ = '~';

        RETURN_VAL (0);
}

/*==============================================================================
objet :
        fonction lancee quand le GT est seul (pas de previsions)
retour :
        0 ---> traitement correctement effectue
        ERR --> probleme rencontre

==============================================================================*/
int n_ActionGTsansPrev(
        char **ptb_InRec        /* adresse de la ligne du GT */
        )
{
        int i;
        T_LIFDRI bd_new;
        double d_montant;
        char sz_poste[10];
        char sz_new_cre[20];

        DEBUT_FCT("n_ActionGTsansPrev");

        if ((ptb_InRec[GT_COMACC_B][0]=='1') && (Kb_AUTUPD==1))
        {
          /* Creation d'une nouvelle prevision pour chaque poste */
          /* sauf si le montant est nul ou pour une liberation.  */
          for (i=0;i<Kn_CleGT;i++)
          {
            /* Utilisation du numero de poste et du montant stockes */
            sprintf(sz_poste,"%4.4d",Kbd_CleGT[i].ACMTRS_NT);
            ptb_InRec[GT_ACMTRS_NT]=sz_poste;

            d_montant=-1*atof(Kbd_CleGT[i].AMT_M);

            if ( (Kbd_CleGT[i].ACMTRS_NT!=0) && (d_montant!=0)
                && (sz_poste[3]!='4') )
            {

                  /* Creation de la prevision avec le montant du GT... */
                  CreationPrevision('G',Kbd_CleGT[i].AMT_M,ptb_InRec);

                  /* et on cree a la fois une constitution et une */
                  /* liberation quand on est sur une constitution */
                  if (sz_poste[3]=='3')
                  {
                    if (sz_poste[1]=='5')
                    {
                      Kb_PnaFarRec5=1;
                      Kf_PnaFarRec5+=d_montant;
                    }
                    else if (sz_poste[1]=='6')
                    {
                      Kb_PnaFarRec6=1;
                      Kf_PnaFarRec6+=d_montant;
                    }
                    else CreationLiberation(sz_poste,d_montant,ptb_InRec);
                  }
            }
          }

          /* Synchronisation du fichier Pilotage pour cette ligne */
          Kn_SyncPilot = n_RechPilot(ptb_InRec);

/* MODIF CRE_D */
          sprintf(sz_new_cre, "%s %s", Ksz_DateJour, "23:58:58");
      /*    printf("Nouvelle date cre_d=|%s|\n", sz_new_cre);*/

          /* Si pilotage synchro, ajout d'une ligne avec annee-mois bilan */
          if (Kn_SyncPilot>=0)
          {
                bd_new=Kbd_PILOT[Kn_SyncPilot];
                if (bd_new.COMACC_B != 1) {
                        bd_new.COMACC_B=1;
                        bd_new.UPD_NF='I';
                        strcpy(bd_new.CRE_D,sz_new_cre);
                        bd_new.BALSHEY_NF=Kn_BalYear;
                        bd_new.BALSHTMTH_NF=Kn_BalMonth;
                        bd_new.CMT_NT=0;
                        fwrite(&bd_new,sizeof(T_LIFDRI),1,Kp_PilotOFil);
                }
          }
          /* Sinon, creation d'une nouvelle ligne dans le pilotage */
          else
          {
                bd_new.UPD_NF='I';
                bd_new.SSD_CF=atoi(ptb_InRec[GT_SSD_CF]);
                sprintf(bd_new.CTR_NF,"%.9s",ptb_InRec[GT_CTR_NF]);
                bd_new.END_NT=atoi(ptb_InRec[GT_END_NT]);
                bd_new.SEC_NF=atoi(ptb_InRec[GT_SEC_NF]);
                bd_new.UWY_NF=atoi(ptb_InRec[GT_ACY_NF]);
                bd_new.UW_NT=atoi(ptb_InRec[GT_UW_NT]);
                bd_new.ACY_NF=atoi(ptb_InRec[GT_ACY_NF]);
                bd_new.BALSHEY_NF=Kn_BalYear;
                bd_new.BALSHTMTH_NF=Kn_BalMonth;
                bd_new.AUTUPD_B=1;
                bd_new.COMACC_B=1;
                strcpy(bd_new.CRE_D,sz_new_cre);
                bd_new.CMT_NT=0;
                /* Nouvelles donnees */
                strcpy(bd_new.CREUSR_CF, "");
                strcpy(bd_new.LSTUPDUSR_CF, "");
                strcpy(bd_new.LSTUPD_D, "");
                /* ----------------- */
                fwrite(&bd_new,sizeof(T_LIFDRI),1,Kp_PilotOFil);
          }
        }

        RETURN_VAL (0);
}

/*==============================================================================
objet :
        fonction lancee quand les previsions sont seules (pas de GT)
retour :
        OK ---> traitement correctement effectue
        ERR --> probleme rencontre

==============================================================================*/
int n_ActionPrevSansGT(
        char **ptb_InRec        /* adresse de la ligne des previsions */
        )
{
        char *espace=" ";

        DEBUT_FCT("n_ActionPrevSansGT");

        /* La prevision est reconduite */
        ptb_InRec[PRE_UPD_NF]=espace;
        n_WriteCols(Kp_PrevOFil,ptb_InRec,SEPARATEUR,0);

        RETURN_VAL (0);
}

/*==============================================================================
objet :
        fonction de test de synchro

retour :
        0 ---> synchro
        sinon, non trouve
==============================================================================*/
int n_ConditionSyncPrev(
        char **pbd_InRecOwner ,/* adresse de la ligne du GT */
        char **pbd_InRecChild  /* adresse de la ligne des previsions */
        )
{
        int ret;

        DEBUT_FCT("n_ConditionSyncPrev");

        if ((ret=strcmp(pbd_InRecOwner[GT_CTR_NF],
                        pbd_InRecChild[PRE_CTR_NF]))!=0)
        RETURN_VAL (ret);

        if ((ret=strcmp(pbd_InRecOwner[GT_SEC_NF],
                        pbd_InRecChild[PRE_SEC_NF]))!=0)
        RETURN_VAL (ret);

        if ((ret=strcmp(pbd_InRecOwner[GT_UWY_NF],
                        pbd_InRecChild[PRE_UWY_NF]))!=0)
        RETURN_VAL (ret);

        if ((ret=strcmp(pbd_InRecOwner[GT_ACY_NF],
                        pbd_InRecChild[PRE_ACY_NF]))!=0)
        RETURN_VAL (ret);

        RETURN_VAL (0);
}

/*==============================================================================
objet :
        fonction lancee pour chaque ligne des previsions synchronisee
        avec le GT

retour :
        0 ----> traitement correctement effectue
        ERR --> probleme rencontre
==============================================================================*/
int n_ActionLignePrev(
        char **ptb_InRecOwner ,/* adresse de la ligne du GT */
        char **ptb_InRecChild  /* adresse de la ligne des previsions */
)
{
        int n_GT,n_poste;
        double d_montant;
        char *espace=" ",unite,PnaFarRec,*sz_poste,*sz_amt;

        DEBUT_FCT("n_ActionLignePrev");

        Kb_SyncPrev=1;

        /* La prevision est reconduite dans tous les cas */
        ptb_InRecChild[PRE_UPD_NF]=espace;
        n_WriteCols(Kp_PrevOFil,ptb_InRecChild,SEPARATEUR,0);

        /* Si le GT est en arrete statistique */
        if ( (ptb_InRecOwner[GT_COMACC_B][0]=='1') && (Kb_AUTUPD==1) )
        {
          /* Stockage du poste et de son chiffre des unites */
          sz_poste=ptb_InRecChild[PRE_ACMTRS_NT];
          n_poste=atoi(sz_poste);
          unite=sz_poste[3];

          /* Exclusion de PNA, FAR et REC */
          PnaFarRec=sz_poste[1];

          /* Si la synchro. s'effectue jusqu'au poste */
          n_GT=n_SyncGT(ptb_InRecChild[PRE_ACMTRS_NT]);
          if (n_GT>=0)
          {
                /* Report du montant */
                sz_amt=Kbd_CleGT[n_GT].AMT_M;

                /* Si le montant est different de celui du GT,  */
                /* et pas sur une liberation     */
                if ( ( atoi(ptb_InRecChild[PRE_ESTMNT_M]) != atoi(sz_amt) )
                        && (unite!='4') )
                {
                /*    printf("Creation d'une nouvelle prevision 1\n");*/
                  /* Creation d'une nouvelle prevision */
                  CreationPrevision('P',sz_amt,ptb_InRecChild);

                  /* Si c'est une constitution (sauf PNA,FAR,REC) */

                  if (unite=='3')
                  {
                    d_montant=-1*atof(sz_amt);

                    /* Cumul du montant pour creer une lib.     */
                    /* sur ce cumul en rupture derniere ou      */
                    /* creation de la liberation correspondante */
                    if (PnaFarRec=='5')
                    {
                        Kf_PnaFarRec5+=d_montant;
                        Kb_PnaFarRec5=1;
                    }
                    else if (PnaFarRec=='6')
                    {
                        Kf_PnaFarRec6+=d_montant;
                        Kb_PnaFarRec6=1;
                    }
                    else CreationLiberation(sz_poste,d_montant,ptb_InRecOwner);
                  }
                }
                /* On enleve cette ligne du tableau GT (on considere que le */
                /* poste fait partie de la liste ssi ACMTRS_NT est non-nul) */
                Kbd_CleGT[n_GT].ACMTRS_NT=0;
          } /* Fin de la synchro jusque ACMTRS_NT */
          /* Si les previsions participent seules jusque ACMTRS_NT */
          else
          {
                /* Si liberation,                                       */
                /* ou si le montant de la prevision initiale est 0,     */
                /* ou si on est sur un poste 1063 ou 1083 et sur une    */
                /* branche non vie (lob=31),                            */
                /* alors pas de prevision generee. Sinon:               */
                if (!( (unite=='4') || (atoi(ptb_InRecChild[PRE_ESTMNT_M])==0)
/* MODIF 21/10    || (    (atoi(ptb_InRecChild[PRE_LOB_CF])==31) && */
                || (    (atoi(ptb_InRecOwner[GT_LOB_CF])==31) &&
                        ((n_poste==1063) || (n_poste==1083)) ) ) )
                {
                  /* Creation d'une nouvelle prevision */
                  CreationPrevision('P',"0",ptb_InRecChild);

                  /* Si PNA/FAR/REC, memoriser pour ecriture ulterieure */
                  if (PnaFarRec=='5') Kb_PnaFarRec5=1;
                  else if (PnaFarRec=='6') Kb_PnaFarRec6=1;

                  /* Sinon, si constitution, ecriture de la liberation */
                  else if (unite=='3')
                    CreationLiberation(sz_poste,0,ptb_InRecOwner);
                }
          }
        }

        RETURN_VAL (0);
}

/*=============================================================================
objet:
        Memorise dans un tableau la cle de la ligne courante du GT avec
        le montant qui l'accompagne
Parametre:
        La ligne courante du GT
=============================================================================*/
void MemoGT (char **ptb_InRec)
{
        DEBUT_FCT("MemoGT");

        /* On memorise le poste */
        Kbd_CleGT[Kn_CleGT].ACMTRS_NT=atoi(ptb_InRec[GT_ACMTRS_NT]);
        strcpy(Kbd_CleGT[Kn_CleGT].AMT_M,ptb_InRec[GT_ESTAMT_M]);

        /* Ligne suivante */
        Kn_CleGT++;

        RETURN_VOID();
}

/*=============================================================================
objet:
        Verifie la synchronisation des previsions avec le GT jusqu'a ACMTRS_NT
Parametre:
        Le poste regroupe des previsions
Retour:
        -> la ligne correspondante dans le tableau GT
        -> -1 si non trouve
=============================================================================*/
int n_SyncGT(char *ACMTRS_NT)
{
        int i;

        DEBUT_FCT("n_SyncGT");

        for (i=0;i<Kn_CleGT;i++)
        {
          if (Kbd_CleGT[i].ACMTRS_NT==atoi(ACMTRS_NT)) RETURN_VAL(i);
        }

        RETURN_VAL(-1)
}

/*=============================================================================
objet:
        Cree un enregistrement dans le fichier des previsions en sortie avec:
        - le montant passe
        - si l'indicateur de mise a jour est I, le pointeur represente le GT,
          sinon il represente la ligne de prevision courante
Parametres:
        - l'indicateur d'origine (G pour GT, P pour Previsions)
        - le montant sous forme de chaine de caracteres
        - le pointeur sur le GT/la prevision
=============================================================================*/
void CreationPrevision(char c_origine,char *AMT_M,char **ptb_InRec)
{
  int i;
  char *psz_ligne[PRE_NBCOL+1],sz_prs[]="500",
  sz_maj[]="I",sz_amt[20];
  char sz_new_cre[20];

  DEBUT_FCT("CreationPrevision");

  if (c_origine=='G')
  {
        for (i=0;i<PRE_NBCOL;i++) psz_ligne[i]="";
        psz_ligne[PRE_NBCOL]=0;

        psz_ligne[PRE_SSD_CF]=ptb_InRec[GT_SSD_CF];
        psz_ligne[PRE_CTR_NF]=ptb_InRec[GT_CTR_NF];
        psz_ligne[PRE_END_NT]=ptb_InRec[GT_END_NT];
        psz_ligne[PRE_SEC_NF]=ptb_InRec[GT_SEC_NF];
        psz_ligne[PRE_UWY_NF]=ptb_InRec[GT_UWY_NF];
        psz_ligne[PRE_UW_NT]=ptb_InRec[GT_UW_NT];
        psz_ligne[PRE_ACY_NF]=ptb_InRec[GT_ACY_NF];
        psz_ligne[PRE_ACMTRS_NT]=ptb_InRec[GT_ACMTRS_NT];
        psz_ligne[PRE_PRS_CF]=sz_prs;
        psz_ligne[PRE_CUR_CF]=ptb_InRec[GT_ESTCUR_CF];
        psz_ligne[PRE_LOB_CF]=ptb_InRec[GT_LOB_CF];
        psz_ligne[PRE_ACCADMTYP_CT]=ptb_InRec[GT_ACCADMTYP_CT];
        psz_ligne[PRE_ESTCRB_CT]=ptb_InRec[GT_ESTCRB_CT];
        psz_ligne[PRE_CED_NF]=ptb_InRec[GT_CED_NF];
        psz_ligne[PRE_BRK_NF]=ptb_InRec[GT_BRK_NF];
        psz_ligne[PRE_PAY_NF]=ptb_InRec[GT_PAY_NF];
        psz_ligne[PRE_ADJCOD_CT]=ptb_InRec[GT_ADJCOD_CT];
        psz_ligne[PRE_RETCOD_CT]=ptb_InRec[GT_RETCOD_CT];
        psz_ligne[PRE_DETTRS_CF]=ptb_InRec[GT_DETTRS_CF];
        psz_ligne[PRE_ADJSIG_B]=ptb_InRec[GT_ADJSIG_B];
  }
  else
  {
        for (i=0;i<PRE_NBCOL;i++) psz_ligne[i]=ptb_InRec[i];
        psz_ligne[PRE_NBCOL]=0;
  }

  /* Annee et mois bilan, indicateur maj, date de creation */
  psz_ligne[PRE_BALSHEY_NF]=Ksz_Balshey;
  psz_ligne[PRE_BALSHTMTH_NF]=Ksz_Balshtmth;
  psz_ligne[PRE_UPD_NF]=sz_maj;
/* MODIF CRE_D */
        sprintf(sz_new_cre, "%s %s", Ksz_DateJour, "23:58:58");
        psz_ligne[PRE_CRE_D]=sz_new_cre;

  /* Substitution du montant */
  sprintf(sz_amt,"%18.3lf",atof(AMT_M));
  psz_ligne[PRE_ESTMNT_M]=sz_amt;

  /* Mise a blanc */
  strcpy(psz_ligne[PRE_CREUSR_CF], "");
  strcpy(psz_ligne[PRE_LSTUPD_D], "");
  strcpy(psz_ligne[PRE_LSTUPDUSR_CF], "");
  
  n_WriteCols(Kp_PrevOFil,psz_ligne,SEPARATEUR,0);

  RETURN_VOID();
}

/*=============================================================================
objet:
        Cree un enregistrement dans le fichier des previsions en sortie avec:
        - le montant passe
        - ACMTRS_NT passant de constitution (xxx3) a liberation (xxx4)
        - annee de compte + 1
        - exercice + 1 si type comptable = 1 ou si (type 3 et provision prime)
Parametres:
        - le poste
        - le montant
        - le pointeur sur le GT
=============================================================================*/
void CreationLiberation(char *ACMTRS_NT, double AMT_M, char **ptb_InRec)
{
        int i,n_an;
        char sz_ligne[200],sz_uwy[5],sz_acy[5],sz_acmtrs[5],sz_prs[]="500",
        *psz_ligne[PRE_NBCOL+1],sz_maj[]="I",
        sz_amt[20];
        char sz_new_cre[20];

        DEBUT_FCT("CreationLiberation");

        for (i=0;i<PRE_NBCOL;i++) psz_ligne[i]="";
        psz_ligne[PRE_NBCOL]=0;

        psz_ligne[PRE_SSD_CF]=ptb_InRec[GT_SSD_CF];
        psz_ligne[PRE_CTR_NF]=ptb_InRec[GT_CTR_NF];
        psz_ligne[PRE_END_NT]=ptb_InRec[GT_END_NT];
        psz_ligne[PRE_SEC_NF]=ptb_InRec[GT_SEC_NF];

        /* Si type comptable = 1 ou                             */
        /* si type comptable = 3 et ACMTRS_NT=provision prime   */
        /* alors UWY_NF = exercice+1, sinon = exercice  */
        if ( (ptb_InRec[GT_ACCADMTYP_CT][0]=='1') ||
        ((ptb_InRec[GT_ACCADMTYP_CT][0]=='3') &&
        ((strcmp(ptb_InRec[GT_ACMTRS_NT],"1063")==0) ||
        (strcmp(ptb_InRec[GT_ACMTRS_NT],"1083")==0))) )
                n_an=1+atoi(ptb_InRec[GT_UWY_NF]);
        else
                n_an=atoi(ptb_InRec[GT_UWY_NF]);
        sprintf(sz_uwy,"%4.4d",n_an);
        psz_ligne[PRE_UWY_NF]=sz_uwy;

        psz_ligne[PRE_UW_NT]=ptb_InRec[GT_UW_NT];

        n_an=1+atoi(ptb_InRec[GT_ACY_NF]);
        sprintf(sz_acy,"%4.4d",n_an);
        psz_ligne[PRE_ACY_NF]=sz_acy;

        /* Affichage des 3 chiffres de poids fort du poste */
        /* et remplacement du chiffre des unites par un 4. */
        sprintf(sz_acmtrs,"%3.3s4",ACMTRS_NT);
        psz_ligne[PRE_ACMTRS_NT]=sz_acmtrs;

        psz_ligne[PRE_PRS_CF]=sz_prs;
        psz_ligne[PRE_CUR_CF]=ptb_InRec[GT_ESTCUR_CF];

        /* Montant en parametre */
        sprintf(sz_amt,"%18.3lf",AMT_M);
        psz_ligne[PRE_ESTMNT_M]=sz_amt;

        /* Ces donnees ne sont plus renseignees car elles
        sont susceptibles d'etre erronees en sortie
        psz_ligne[PRE_LOB_CF]=ptb_InRec[GT_LOB_CF];
        psz_ligne[PRE_ACCADMTYP_CT]=ptb_InRec[GT_ACCADMTYP_CT];
        psz_ligne[PRE_ESTCRB_CT]=ptb_InRec[GT_ESTCRB_CT];
        psz_ligne[PRE_CED_NF]=ptb_InRec[GT_CED_NF];
        psz_ligne[PRE_BRK_NF]=ptb_InRec[GT_BRK_NF];
        psz_ligne[PRE_PAY_NF]=ptb_InRec[GT_PAY_NF];
        */

        /* Annee et mois bilan, indicateur maj, date de creation */
        psz_ligne[PRE_BALSHEY_NF]=Ksz_Balshey;
        psz_ligne[PRE_BALSHTMTH_NF]=Ksz_Balshtmth;
        psz_ligne[PRE_UPD_NF]=sz_maj;
/* MODIF CRE_D */
        sprintf(sz_new_cre, "%s %s", Ksz_DateJour, "23:58:58");
        psz_ligne[PRE_CRE_D]=sz_new_cre;

        /* Mise a vide des utilisateurs */
        strcpy(psz_ligne[PRE_CREUSR_CF], "");
        strcpy(psz_ligne[PRE_LSTUPD_D], "");
        strcpy(psz_ligne[PRE_LSTUPDUSR_CF], "");

        n_WriteCols(Kp_PrevOFil,psz_ligne,SEPARATEUR,0);

        RETURN_VOID();
}

/*=============================================================================
objet:
        Cree un enregistrement dans le fichier des previsions en sortie avec:
        - le montant passe
        - ACMTRS_NT passe
        - annee de compte
        - exercice
Parametres:
        - le poste
        - le montant
        - le pointeur sur le GT
=============================================================================*/
void CreationConstitutionNonVie(char *ACMTRS_NT, double AMT_M, char **ptb_InRec)
{
        int i,n_an;
        char sz_ligne[200],sz_uwy[5],sz_acy[5],sz_acmtrs[5],sz_prs[]="500",
        *psz_ligne[PRE_NBCOL+1],sz_maj[]="I",
        sz_amt[20];
        char sz_new_cre[20];

        DEBUT_FCT("CreationConstitutionNonVie");

        for (i=0;i<PRE_NBCOL;i++) psz_ligne[i]="";
        psz_ligne[PRE_NBCOL]=0;

        psz_ligne[PRE_SSD_CF]=ptb_InRec[GT_SSD_CF];
        psz_ligne[PRE_CTR_NF]=ptb_InRec[GT_CTR_NF];
        psz_ligne[PRE_END_NT]=ptb_InRec[GT_END_NT];
        psz_ligne[PRE_SEC_NF]=ptb_InRec[GT_SEC_NF];
        psz_ligne[PRE_UWY_NF]=ptb_InRec[GT_UWY_NF];
        psz_ligne[PRE_UW_NT]=ptb_InRec[GT_UW_NT];
        psz_ligne[PRE_ACY_NF]=ptb_InRec[GT_ACY_NF];

        psz_ligne[PRE_ACMTRS_NT]=ACMTRS_NT;

        psz_ligne[PRE_PRS_CF]=sz_prs;
        psz_ligne[PRE_CUR_CF]=ptb_InRec[GT_ESTCUR_CF];

        /* Montant oppose de celui passe en parametre */
        sprintf(sz_amt,"%18.3lf",-AMT_M);
        psz_ligne[PRE_ESTMNT_M]=sz_amt;

        /* Annee et mois bilan, indicateur maj, date de creation */
        psz_ligne[PRE_BALSHEY_NF]=Ksz_Balshey;
        psz_ligne[PRE_BALSHTMTH_NF]=Ksz_Balshtmth;
        psz_ligne[PRE_UPD_NF]=sz_maj;
/* MODIF CRE_D */
        sprintf(sz_new_cre, "%s %s", Ksz_DateJour, "23:58:58");
        psz_ligne[PRE_CRE_D]=sz_new_cre;

        /* Mise a vide des utilisateurs */
        strcpy(psz_ligne[PRE_CREUSR_CF], "");
        strcpy(psz_ligne[PRE_LSTUPD_D], "");
        strcpy(psz_ligne[PRE_LSTUPDUSR_CF], "");
        
        n_WriteCols(Kp_PrevOFil,psz_ligne,SEPARATEUR,0);

        RETURN_VOID();
}
