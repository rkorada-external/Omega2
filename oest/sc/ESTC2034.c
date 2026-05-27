/*==============================================================================
nom de l'application          : Introduction des postes cumuls et conversion en devise principale
nom du source                 : ESTC2034.c
revision                      : $Revision: 1.4 $
date de creation              : 04/06/1997
auteur                        : C. Chavatte
references des specifications : ESIIV01F
squelette de base             : batch
------------------------------------------------------------------------------
description :
------------------------------------------------------------------------------
historique des modifications :
<jj/mm/aaaa>   <auteur>    <description de la modification>
 05/11/1999		Anb			Mise à jour du code ADJCOD_CT pour les affaires terminées
 08/06/2000		Anb			Prise en compte systématique de l'établissement présent dans le fichier Périmètre
 06/02/2001		Anb			Prise en compte (provisoirement en dur) des années limites pour bilan et AC dans le fichier comptable
 28/02/2001		Anb			Prise en compte des ES dans le calcul du bilan - 1  (2ème suffixe = 4)
 05/12/2002		O.Arik	affectation dans le regroupement statutaire pour bilan <= 2002 des postes non zilmerisé
 27/03/2008   J.Ribot :SPOT:15219  ASE15 recompilation des programmes C
[007] D.GATIBELZA 28/07/2010 ESTVIE18754 Creation ligne fds egal. stab dans onglet Primes ( pour tout et tous ) faire le 1093 en dupliquant comme le 1063 et le 1094 comme le 1064
[008] D.GATIBELZA 17/09/2010 SRVIE13868 V10 Pb libération de dépôts dans le nouvel infocentre
[009] D.GATIBELZA 17/12/2010 ESTVIE20627 estimation sur des traités de rattachement en 'terminé comptable'
[010] R. Cassis   14/03/2012 :spot:22315 Ajout test sur postes depot
[011] R. Cassis   13/03/2013 :spot:24910 Correction sur conditions de postes depot
[012] M. MECHRI   06/06/2014 :Correction ACMTRS est à zéros en cas PereSansFils.
[XXX] 02/06/2014 JBG :spot:25773 Warnings suppress in compile
[013] M.MECHRI    03/07/2014 :spot:25773 :Correction d'initialisation de structure et correction de condition de contruction de TRNCOD
[14}  Florent     20/11/2014 :spot:27748 Modif pour utilisation du PER_NBCOL
[015] S.Behague   11/08/2015 :spot:29253 TAC02B Ajout fichier SUBTRS pour postes analytiques
==============================================================================*/

/*--------------------------------------------------*/
/* inclusion des interfaces des composants importes */
/*--------------------------------------------------*/
#include <utctlib.h>
#include <struct.h>
#include "estserv.h"

/**/
//#define TRACE
//#define TRACE_FCT
//#define TRACE_RECHERCHE
//#define TRACE_RECHERCHE_I

/*---------------------------------------------*/
/* definition des constantes et macros privees */
/*---------------------------------------------*/
#define Kn_MaxPostes 20000                           // Le nombre max de postes est fixe a 2000 (modif O.Arik:28/05/2001 1000->2000 suite au dep. de mem.)

char Ksz_vide[1];                                   // Chaine vide pour initialisation

/*----------------------*/
/* variables de travail */
/*----------------------*/
int   Kn_BALSHTYEA_NF;
char  Ksz_BALSHTYEA_NF_1[5];
short Ks_acmtrs_nt;
int   Kn_NbLigTrslnk;
char  Ksz_PER_UWY_NF[5];
char  Ks_CUR[4];
char  Ks_ESTCRB[1];
char  Ks_CTR[10];

T_TRSLNK Kbd_TRSLNK[Kn_MaxPostes];

FILE *Kp_OutputFil,                                 // pointeur sur le fichier de sortie
     *Kp_CoursFil,                                  // fichier des cours devise
     *Kp_TrslnkFil,                                 // fichier des postes
     *Kp_OutGTB1,                                   // fichier Bilan -1 en sortie
     *Kp_PeriRattach,                               // fichier périmetre de rattachement    [009]
     *Kp_OutTermineCptERR;                          // fichier non terminés en ERREUR       [009]

T_RUPTURE_VAR       bd_RuptPerim;                   // gestion rupture sur perimetre
T_RUPTURE_SYNC_VAR  bd_RuptGT;                      // gestion synchro GT-perimetre
T_RUPTURE_SYNC_VAR  bd_RuptTrslnk;                  // gestion synchro trslnk-perimetre
T_RUPTURE_VAR       bd_RuptPeriRattach;             // [009]

int n_InitGT                (T_RUPTURE_SYNC_VAR *);
int n_ActionLigneGT         (char **, char **);
int n_ConditionSyncGT       (char **, char **);

int n_InitPerim             (T_RUPTURE_VAR *) ;
int n_IsR1PER               (char **ptb_InRec,char **ptb_InRec_Cur);
int n_ActionLastRuptPER    (char **ptb_InRec);

int n_ActionLigne_PERIMETRE (char **);
int n_ActionPereSansFilsGT  (char **);
int n_ActionFilsSansPereGT  (char **);

int n_ChargerTRSLNK ();

//[009]     
struct STR_PERIATTACH
{
    char CTR_NF[10];    
    char SEC_NF[3];
    char UWY_NF[5];    
    char SECACCSTS_CT[3];
    struct STR_PERIATTACH *suiv;
};

struct STR_PERIATTACH *T_PERIATTACH_DEBUT;
struct STR_PERIATTACH *T_PERIATTACH;

int T_PERIRATTACH_ADJCOD_CT = -1;
int nb_periattach = 0;
int n_InitPERI_RATTACH_I5               (T_RUPTURE_VAR *);
int n_ActionLignePERIRATTACH_I5         (char **);
int n_recherche_SECACCSTS_PERIRATTACH   (char **);
void DEBUT_FONCTION                     (char *);


T_SUBTRS    SubTrsLigne;
FILE        *Kp_SubTRSFil; 

void init_SubTrsLigne();


/*==============================================================================
objet :     point d'entree du programme
retour :    En cas de probleme, la sortie s'effectue par la fonction ExitPgm().
            Sinon, par l'appel systeme exit()
==============================================================================*/
int main(int argc ,char *argv[])
{
    // Initialisation des signaux
    InitSig () ;

    if ( n_BeginPgm (argc  ,argv) == ERR )                                          ExitPgm ( ERR_XX , "" );

	Kn_BALSHTYEA_NF = n_GetIntArgv(1) ;
	sprintf(Ksz_BALSHTYEA_NF_1,"%d", Kn_BALSHTYEA_NF - 1 ) ;

    // ouverture des fichiers
    if ( n_OpenFileAppl ("ESTC2034_I3","rb",&Kp_TrslnkFil)              == ERR )    ExitPgm ( ERR_XX , "" );
    if ( n_OpenFileAppl ("ESTC2034_I4","rb",&Kp_CoursFil)               == ERR )    ExitPgm ( ERR_XX , "" );
    if ( n_OpenFileAppl ("ESTC2034_O1","wt",&Kp_OutputFil)              == ERR )    ExitPgm ( ERR_XX , "" );
    if ( n_OpenFileAppl ("ESTC2034_O2","wt",&Kp_OutGTB1)                == ERR )    ExitPgm ( ERR_XX , "" );
    if ( n_OpenFileAppl ("ESTC2034_O3","wt",&Kp_OutTermineCptERR)       == ERR )    ExitPgm ( ERR_XX , "" );        //[009]

    // Gestion Fichier SUBTRS
    if (n_OpenFileAppl ("ESTC2034_I6","rb",&Kp_SubTRSFil) == ERR )              ExitPgm ( ERR_XX , "" );
    if ( n_ChargerTsubTRS(Kp_SubTRSFil) == ERR )             					ExitPgm( ERR_XX , "" );  
    init_SubTrsLigne();
    
    // Initialisation de la varible bd_RuptPerim
    if ( n_InitPerim(&bd_RuptPerim) )                                               ExitPgm ( ERR_XX , "" );

    // Initialisation
    if ( n_InitGT(&bd_RuptGT) )                                                     ExitPgm ( ERR_XX , "" );
    if ( n_InitPERI_RATTACH_I5(&bd_RuptPeriRattach) )                               ExitPgm ( ERR_XX , "" );        //[009]

    // Chargement des postes en memoire (PRS_CF ==500 )
    // modif O.Arik:29/05/2001 on sort en cas de dep. de memoire
    if( n_ChargerTRSLNK () == ERR )                                                 ExitPgm ( ERR_XX , "" ) ;

    // lancement des traitements de fichiers
    if ( n_ProcessingRuptureVar (&bd_RuptPeriRattach) == ERR )                      ExitPgm ( ERR_XX , "" );    //[009]
    if ( n_ProcessingRuptureVar (&bd_RuptPerim) == ERR )                            ExitPgm ( ERR_XX , "" );

    if ( n_CloseFileAppl ("ESTC2034_I1",&(bd_RuptPerim.pf_InputFil))    == ERR )    ExitPgm ( ERR_XX , "" );
    if ( n_CloseFileAppl ("ESTC2034_I2",&(bd_RuptGT.pf_InputFil))       == ERR )    ExitPgm ( ERR_XX , "" );
    if ( n_CloseFileAppl ("ESTC2034_I3",&Kp_TrslnkFil)                  == ERR )    ExitPgm ( ERR_XX , "" );
    if ( n_CloseFileAppl ("ESTC2034_I4",&Kp_CoursFil)                   == ERR )    ExitPgm ( ERR_XX , "" );
    if ( n_CloseFileAppl ("ESTC2034_I5",&bd_RuptPeriRattach.pf_InputFil)== ERR )    ExitPgm ( ERR_XX , "" );        //[009]
    if ( n_CloseFileAppl ("ESTC2034_I6",&Kp_SubTRSFil)                  == ERR )    ExitPgm ( ERR_XX , "" );
    if ( n_CloseFileAppl ("ESTC2034_O1",&Kp_OutputFil)                  == ERR )    ExitPgm ( ERR_XX , "" );
    if ( n_CloseFileAppl ("ESTC2034_O2",&Kp_OutGTB1)                    == ERR )    ExitPgm ( ERR_XX , "" );
    if ( n_CloseFileAppl ("ESTC2034_O3",&Kp_OutTermineCptERR)           == ERR )    ExitPgm ( ERR_XX , "" );        //[009]

    if ( n_EndPgm () == ERR )                                                       ExitPgm ( ERR_XX , "" );
  exit(OK) ;
}



// ----------------------------------------------------------------------------
// objet : fonction d'initialisation de la variable de gestion de rupture du
//         fichier maitre.
// retour: OK
// ----------------------------------------------------------------------------
int n_InitPerim(T_RUPTURE_VAR  *pbd_Rupt)
{
    DEBUT_FONCTION("n_InitPerim");

    memset(pbd_Rupt,0,sizeof(T_RUPTURE_VAR));

    if ( n_OpenFileAppl ("ESTC2034_I1","rt",&(pbd_Rupt->pf_InputFil)))
        ExitPgm ( ERR_XX , "" );

    pbd_Rupt->n_NbRupture           = 1  ;
    
    // Ajour Rupture sur CTR pour sauvegarder la devise
    pbd_Rupt->n_ConditionRupture[0] = n_IsR1PER;
    pbd_Rupt->n_ActionLast[0] = n_ActionLastRuptPER;
    
    pbd_Rupt->n_ActionLigne         = n_ActionLigne_PERIMETRE ;

    
    pbd_Rupt->c_Separ = SEPARATEUR ;
		Ksz_PER_UWY_NF[0] = '\0';

  RETURN_VAL(OK);
}

// ----------------------------------------------------------------------------
// objet : Fonction de rupture sur le fichier maitre PERIMETRE
// retour: OK
// ----------------------------------------------------------------------------
int n_IsR1PER(char **ptb_InRec,char **ptb_InRec_Cur)
{
    DEBUT_FONCTION("n_IsR1PER");
    if (strcmp(ptb_InRec[PER_CTR_NF],ptb_InRec_Cur[PER_CTR_NF]) != 0)           RETURN_VAL(1);

    RETURN_VAL (0);
}

// ----------------------------------------------------------------------------
// objet : Fonction de rupture sur le fichier maitre PERIMETRE
// retour: OK
// ----------------------------------------------------------------------------
int n_ActionLastRuptPER(char **ptb_InRec)
{
    DEBUT_FONCTION("n_ActionLastRuptPER");
    // sauvegarde la devise PERIMETRE
    strcpy(Ks_CUR,ptb_InRec[PER_PCPCUR_CF]);
    strcpy(Ks_ESTCRB,ptb_InRec[PER_ESTCRB_CT]);
    strcpy(Ks_CTR,ptb_InRec[PER_CTR_NF]);

    RETURN_VAL (0);
}

//[009]
// ----------------------------------------------------------------------------
// objet : Initialisation du fichier
// retour: OK
// ----------------------------------------------------------------------------
int n_InitPERI_RATTACH_I5(T_RUPTURE_VAR *pbd_Rupt)
{
    DEBUT_FONCTION("n_InitPERI_RATTACH_I5");

    memset( pbd_Rupt,0,sizeof(T_RUPTURE_VAR) ) ;

    // ouverture du fichier esclave
    if ( n_OpenFileAppl ("ESTC2034_I5","rt",&(pbd_Rupt->pf_InputFil)))
        ExitPgm ( ERR_XX , "" );

    // fonction du test de la ligne du maitre avec l'esclave
    pbd_Rupt->n_NbRupture           = 0;
    pbd_Rupt->n_ActionLigne         = n_ActionLignePERIRATTACH_I5;
    pbd_Rupt->c_Separ   = '~' ;
    
    T_PERIATTACH=(struct STR_PERIATTACH *)malloc(sizeof(struct STR_PERIATTACH));

  RETURN_VAL(OK);
}



//[009]
// ----------------------------------------------------------------------------
// objet : fonction lancee pour chaque ligne du perimetre
// retour: OK ---> traitement correctement effectue
//         ERR --> probleme rencontre
// ----------------------------------------------------------------------------
int n_ActionLignePERIRATTACH_I5( char **ptb_InRecPERIM_RATTACH )
{
    DEBUT_FONCTION("n_ActionLignePERIRATTACH_I5");

    //Le premier Element de la chaine
    if( nb_periattach==0)
        T_PERIATTACH_DEBUT=T_PERIATTACH;

    strcpy(T_PERIATTACH->CTR_NF, ptb_InRecPERIM_RATTACH[PER_CTR_NF]);
    strcpy(T_PERIATTACH->SEC_NF, ptb_InRecPERIM_RATTACH[PER_SEC_NF]);
    strcpy(T_PERIATTACH->UWY_NF, ptb_InRecPERIM_RATTACH[PER_UWY_NF]);
    strcpy(T_PERIATTACH->SECACCSTS_CT, ptb_InRecPERIM_RATTACH[PER_SECACCSTS_CT]);
    T_PERIATTACH->suiv=(struct STR_PERIATTACH *)malloc(sizeof(struct STR_PERIATTACH));

    nb_periattach++;
    T_PERIATTACH=T_PERIATTACH->suiv;
    
  RETURN_VAL(OK);
}



// ----------------------------------------------------------------------------
// objet : fonction lancee pour chaque ligne du maitre
// retour: OK ---> traitement correctement effectue
//         ERR --> probleme rencontre
// ----------------------------------------------------------------------------
int n_ActionLigne_PERIMETRE( char **ptb_InRec_Cur)
{
    DEBUT_FCT("n_ActionLigne_PERIMETRE");

    // On sauvegarde la ligne pour pouvoir comparer à la ligne suivante
    strcpy(Ksz_PER_UWY_NF,ptb_InRec_Cur[PER_UWY_NF]);

    // synchronisation du fichier GT pour chaque ligne
    n_ProcessingRuptureSyncVar (&bd_RuptGT, ptb_InRec_Cur);

    RETURN_VAL(OK);
}


// ----------------------------------------------------------------------------
// objet : Initialisation de la synchronisation du maitre avec l'esclave GT
// retour: OK
// ----------------------------------------------------------------------------
int n_InitGT(T_RUPTURE_SYNC_VAR  *pbd_Rupt)
{
	DEBUT_FCT("n_InitGT");
	memset( pbd_Rupt, 0, sizeof(T_RUPTURE_SYNC_VAR));
	n_OpenFileAppl ("ESTC2034_I2", "rt", &(pbd_Rupt->pf_InputFil));	// ouverture du fichier esclave
	pbd_Rupt->n_NbRupture = 0;
	pbd_Rupt->ConditionEndSync = n_ConditionSyncGT;					// fonction du test de la ligne du maitre avec l'esclave
	pbd_Rupt->n_ActionLigne = n_ActionLigneGT;						// fonction d'action sur la ligne courante du fichier esclave
	pbd_Rupt->n_PereSansFils = n_ActionPereSansFilsGT;				// fonction d'action quand le maitre n'a pas de fils GT
	pbd_Rupt->n_FilsSansPere = n_ActionFilsSansPereGT;				// fonction d'action quand le maitre n'a pas de fils GT
	pbd_Rupt->c_Separ = SEPARATEUR;
	RETURN_VAL(OK);
}

// ----------------------------------------------------------------------------
// objet : fonction de test de rupture du niveau 1
// retour: 0       ---> pbd_InRecOwner = pbd_InRecChild    ( egalite de rubriques a synchroniser)
//         > 0     ---> pbd_InRecOwne> > pbd_InRecChild
//         < 0     ---> pbd_InRecOwne> < pbd_InRecChild
// ----------------------------------------------------------------------------
//                     ligne du maitre,       ligne de l'esclave
int n_ConditionSyncGT( char **pbd_InRecOwner, char **pbd_InRecChild )
{
	int ret;

	DEBUT_FCT("n_ConditionSyncGT");
	if ((ret = strcmp(pbd_InRecOwner[PER_CTR_NF], pbd_InRecChild[GT_CTR_NF])) != 0)
		RETURN_VAL(ret);
	if ((ret = strcmp(pbd_InRecOwner[PER_SEC_NF], pbd_InRecChild[GT_SEC_NF])) != 0)
		RETURN_VAL(ret);
	if ((ret = strcmp(pbd_InRecOwner[PER_UWY_NF], pbd_InRecChild[GT_UWY_NF])) != 0)
		RETURN_VAL(ret);
	RETURN_VAL(0);
}


// ----------------------------------------------------------------------------
// objet:  Lit le fichier binaire des postes et les met en memoire
// ----------------------------------------------------------------------------
int n_ChargerTRSLNK ()
{
	int			n_EOF = 0;
	T_TRSLNK	bd_Lu;
	char		MsgAno[300];

    DEBUT_FCT("n_ChargerTRSLNK");
    Kn_NbLigTrslnk = 0;
    // Tant que la fin de fichier n'est pas atteinte,...
    while (n_EOF == 0)
    {
        if (fread(&bd_Lu,sizeof(T_TRSLNK),1,Kp_TrslnkFil)<=0)
            n_EOF = 1;
        else
        {
            if ( Kn_NbLigTrslnk + 1 >= Kn_MaxPostes )
            {
                // depassement tableau
                sprintf(MsgAno,"The number of link (/PRS %d /ACMTRS %d /DETTRS %s) overflows the program's storage capacity",
                            bd_Lu.PRS_CF,
                            bd_Lu.ACMTRS_NT,
                            bd_Lu.DETTRS_CF);
                n_WriteAno(MsgAno);
                RETURN_VAL(ERR);
            }
            else
            if (bd_Lu.PRS_CF == 500)
                // Enregistrement ecrit dans le tableau
                Kbd_TRSLNK[Kn_NbLigTrslnk++] = bd_Lu;
        }
    }

  RETURN_VAL(OK);
}



// ----------------------------------------------------------------------------
// objet : fonction de recherche du poste
// retour: 0       ---> Pas de rupture
//         < 0     ---> On n'est pas arrive au bloc synchrone
//         > 0     ---> On a depasse le bloc synchrone
// ----------------------------------------------------------------------------
int n_RechPoste(char *sz_poste)
{
  int n_indice, ret;

    DEBUT_FCT("n_RechPoste");

    Ksz_vide[0]=0;
    n_indice=0;

    while (1==1)
    {
        // Comparaison des codes
        ret=strcmp(sz_poste,Kbd_TRSLNK[n_indice].DETTRS_CF);

        // S'ils sont egaux, retourner l'indice
        if (ret==0)
            RETURN_VAL(n_indice);

        // Si la ligne est passee, retourner -1 (echec)
        if (ret<0)
            RETURN_VAL(-1);

        // Ligne suivante
        n_indice++;

        // Si on est a la fin du tableau, echec
        if (n_indice>=Kn_NbLigTrslnk) RETURN_VAL(-1);
    }
}



// ----------------------------------------------------------------------------
// objet : fonction lancee pour chaque ligne du GT synchronisee avec le perimetre
// retour: OK ---> traitement correctement effectue
//         ERR --> probleme rencontre
// ----------------------------------------------------------------------------
//           adresse de la ligne du maitre,          de l'esclave
int n_ActionLigneGT( char **ptb_InRecOwner, char **ptb_InRecChild )
{
  double d_montant,d_aliment,d_taux;
  char sz_montant[30],sz_aliment[30];
  char sz_acmtrs[10]="";
  int i;
  int flag_B1 = 0;
  int resultposte;
  int balshmth;
  char sz_DETTRNCOD[6]="DETRN";

    DEBUT_FCT("n_ActionLigneGT");
    // Récupération prévision pour calcul situation bilan - 1
    if ( ptb_InRecChild[GT_TRNCOD_CF][7] == '2' )
    {
        ptb_InRecChild[GT_TRNCOD_CF][7] = '0';

        // Modif Anb du 28/2/01 pour prise en cpte des ES
        if ( ptb_InRecChild[GT_TRNCOD_CF][1] == '4' )
        {
            ptb_InRecChild[GT_TRNCOD_CF][1] = '1';
        }
 
        // Fin modif
        flag_B1 =1;
        if (ptb_InRecChild[GT_TRNCOD_CF][0] == '1' || ptb_InRecChild[GT_TRNCOD_CF][0] == '3')
        {
            ptb_InRecChild[GT_BALSHEY_NF] = Ksz_BALSHTYEA_NF_1;
            ptb_InRecChild[GT_BALSHRMTH_NF] = "12";
            ptb_InRecChild[GT_BALSHRDAY_NF] = "31";
        }
    }
    for(i=GT_ESTCUR_CF;i<GT_NBCOL + 2;i++)
        ptb_InRecChild[i]="";
    ptb_InRecChild[GT_NBCOL + 2] = 0 ;

    // Synchronisation du fichier trslnk afin de recuperer ACMTRS_NT
    i = n_RechPoste(ptb_InRecChild[GT_TRNCOD_CF]);
    
    if (i==-1)
    {
      // SBE : Le STAM1501 devrait renseigner tous les champs du poste à 8 maintenant, pour prendre en compte les PrevSansGT du 2038. Une fois ok, commentaire ci dessous a supprimer
        RETURN_VAL(OK);
    }
    else
    {
        Ks_acmtrs_nt=Kbd_TRSLNK[i].ACMTRS_NT;
    }

    sprintf(sz_acmtrs,"%d",Ks_acmtrs_nt);

    // rajouté par O. Arik le 05/12/2002
    if ( ( atoi(ptb_InRecOwner[PER_SSD_CF]) != 14 )             &&
         ( atoi(ptb_InRecChild[GT_BALSHEY_NF]) <= 2002 )        &&
         ( atoi(ptb_InRecChild[GT_TRNCOD_CF]) == 31400100 )   )
        sprintf(sz_acmtrs,"%d",1063);

    // rajouté par O. Arik le 05/12/2002
    if ( ( atoi(ptb_InRecOwner[PER_SSD_CF]) != 14 )             &&
         ( atoi(ptb_InRecChild[GT_BALSHEY_NF]) <= 2002 )        &&
         ( atoi(ptb_InRecChild[GT_TRNCOD_CF] ) == 31401100 ) )
        sprintf(sz_acmtrs,"%d",1064);

 
    // Calcul du taux de conversion

    // Pour tous les traites
    // si devise<>devise principale, conversion du montant
    ptb_InRecChild[GT_ESTAMT_M]=ptb_InRecChild[GT_AMT_M];
    ptb_InRecChild[GT_ESTCUR_CF]=ptb_InRecChild[GT_CUR_CF];


    // [015] Si poste analytique de type Ratio ou quantité, on ne change pas le montant
    sprintf(sz_DETTRNCOD,"%.5s", ptb_InRecChild[GT_TRNCOD_CF]+2);
    resultposte = n_FindTsubTRS(&SubTrsLigne,sz_DETTRNCOD);
    // SI non trouvé TRSNATURE_CT = 2 on met flag_trsnat = 2
    if ( ! (resultposte == (-1) || SubTrsLigne.TRSNATURE_CT == 2) )
    {
        if (strcmp(ptb_InRecOwner[PER_PCPCUR_CF],ptb_InRecChild[GT_CUR_CF])!=0)
        {
            d_taux=d_GetTaux(Kp_CoursFil,
                         (char)atoi(ptb_InRecOwner[PER_SSD_CF]),
                         (short)atoi(ptb_InRecChild[GT_BALSHEY_NF]),
                         ptb_InRecChild[GT_CUR_CF],
                         ptb_InRecOwner[PER_PCPCUR_CF]);

            // Si le taux est trouve, conversion
            if (d_taux>0)
            {
                d_montant=atof(ptb_InRecChild[GT_AMT_M]);
                d_montant *= d_taux;
            }
            // Sinon, montant mis a -1
            else
                d_montant = -1;

            // Remplacement du montant
            sprintf(sz_montant,"%.3lf",d_montant);
            ptb_InRecChild[GT_ESTAMT_M]=sz_montant;
        }
    }
    // Calcul du taux de conversion (cours: 31/12/exercice precedent)
    d_taux=d_GetTaux(Kp_CoursFil,
                     (char)atoi(ptb_InRecOwner[PER_SSD_CF]),
                     (short)atoi(ptb_InRecOwner[PER_UWY_NF])-1,
                     ptb_InRecOwner[PER_EGPCUR_CF],
                     ptb_InRecOwner[PER_PCPCUR_CF]);

    if (d_taux>0)
    {
        // Conversion de l'aliment brut SCOR
        d_aliment=atof(ptb_InRecOwner[PER_SCOEGP_M]);
        d_aliment *= d_taux;
    }
	else
		// Sinon, montant mis a -1
		d_aliment=-1;

    // Remplacement de l'aliment
    sprintf(sz_aliment,"%.3lf",d_aliment);


    ptb_InRecChild[GT_ESTCUR_CF]    =ptb_InRecOwner[PER_PCPCUR_CF];
    ptb_InRecChild[GT_NAT_CF]       = ptb_InRecOwner[PER_NAT_CF];
    ptb_InRecChild[GT_ACMTRS_NT]    = sz_acmtrs;
    ptb_InRecChild[GT_ESTCTR_NF]    = ptb_InRecOwner[PER_ESTCTR_NF];
    ptb_InRecChild[GT_ESTSEC_NF]    = ptb_InRecOwner[PER_ESTSEC_NF];
    ptb_InRecChild[GT_LOB_CF]       = ptb_InRecOwner[PER_LOB_CF];
    ptb_InRecChild[GT_SCOEGP_M]     = sz_aliment;
    ptb_InRecChild[GT_ESTCRB_CT]    = ptb_InRecOwner[PER_ESTCRB_CT];
    ptb_InRecChild[GT_LIFTRTTYP_CF] = ptb_InRecOwner[PER_LIFTRTTYP_CF];
    ptb_InRecChild[GT_ACCADMTYP_CT] = ptb_InRecOwner[PER_ACCADMTYP_CT];
    ptb_InRecChild[GT_SECSTS_CT]    = ptb_InRecOwner[PER_SECSTS_CT];
    ptb_InRecChild[GT_BRK_NF]       = ptb_InRecOwner[PER_PRD_NF];
    ptb_InRecChild[GT_PRD_NF]       = ptb_InRecOwner[PER_PRD_NF];
    ptb_InRecChild[GT_SEG_NF]       = ptb_InRecOwner[PER_SEG_NF];
    ptb_InRecChild[GT_COMACC_B]     = "0";

    ptb_InRecChild[GT_ADJCOD_CT]    = "0";
    //ptb_InRecChild[GT_RETCOD_CT]    = "0";
    ptb_InRecChild[GT_DETTRS_CF]    = "";

    //ptb_InRecChild[GT_ADJSIG_B]     = "0";
    ptb_InRecChild[GT_ESTUWY_NF]    = "";

    ptb_InRecChild[GT_PROPER_N]     = ptb_InRecOwner[PER_ACCFRQ_CT];
    ptb_InRecChild[GT_UWGRP_CF]     = ptb_InRecOwner[PER_UWGRP_CF];
    ptb_InRecChild[GT_RTOCTY_CF]    = "";

	/************************************************************/
	/* Modifs du 8/06/00 - par A.BORDET 			            */
	/* Prise en cpte systématique de l'établissement présent    */
	/* dans le fichier souscription                             */
	/************************************************************/
    ptb_InRecChild[GT_ESB_CF]       = ptb_InRecOwner[PER_ACCESB_CF];


    //[008] ne pas ecraser l'exercice par l'année de compte si acmtrs_nt finit par 303,323                              //[008]
    if( ( atoi( ptb_InRecOwner[PER_ACCADMTYP_CT] ) == 1 || atoi( ptb_InRecOwner[PER_ACCADMTYP_CT] ) == 3 ) &&           //[008]
        ( (sz_acmtrs[3] == '3' || sz_acmtrs[3] == '4') && sz_acmtrs[1]=='3' ) )                                         //[008] [010]
    {                                                                                                                   //[008]
        // Ne rien faire                                                                                                //[008]
    }                                                                                                                   //[008]
    else                                                                                                                //[008]
    {                                                                                                                   //[008]
    	/************************************************************/
    	/* Modifs du 27/03/98 - par M.HA-THUC 			            */
    	/* l'exercice est force a l'annee de compte		            */
    	/* si type comptable = 1 			                 	    */
    	/* ou si type comptable = 3 et postes prime/charge/depot	*/
    	/************************************************************/
    	if ( atoi( ptb_InRecOwner[PER_ACCADMTYP_CT] ) == 1 ||
    		 ( atoi( ptb_InRecOwner[PER_ACCADMTYP_CT] ) == 3    &&
    		   ( sz_acmtrs[1] == '0'    ||
    		     sz_acmtrs[1] == '1'    ||
    		     sz_acmtrs[1] == '3'    ||
    		     sz_acmtrs[1] == '5'    ||
    		     sz_acmtrs[1] == '6'
    		   ) && 
    		   ( atoi(sz_acmtrs) != 1160 && atoi(sz_acmtrs) != 2160 && atoi(sz_acmtrs) != 1303 && 
    		     atoi(sz_acmtrs) != 1323 && atoi(sz_acmtrs) != 2303 && atoi(sz_acmtrs) != 2323 && 
    		     atoi(sz_acmtrs) != 1340 && atoi(sz_acmtrs) != 2340 )  // [011]
    		 )
    		 )
    	{
    		ptb_InRecChild[GT_UWY_NF] = ptb_InRecChild[GT_ACY_NF] ;
    	}
    }                                                                                                                   //[008]
    
    /********************************************************/
    /* Modifs du 05/10/98 - par A.BORDET         	        */
    /* pour certains contrats / sections / exercices, forcer*/
    /* l'exercice au dernier exercice existant              */
    /********************************************************/
    if ( (strcmp(ptb_InRecChild[GT_CTR_NF],"04Z0N0009") == 0)   &&
         (atoi( ptb_InRecChild[GT_SEC_NF] ) == 1)               &&
         (atoi( ptb_InRecChild[GT_UWY_NF] ) >= 1994 ) )
    {
        ptb_InRecChild[GT_UWY_NF] = "1994" ;
    }

    if ( (strcmp(ptb_InRecChild[GT_CTR_NF],"04Z085211") == 0)   &&
         (atoi( ptb_InRecChild[GT_SEC_NF] ) == 2)               &&
         (atoi( ptb_InRecChild[GT_UWY_NF] ) >= 1985 ) )
    {
        ptb_InRecChild[GT_UWY_NF] = "1985" ;
    }

    if ( (strcmp(ptb_InRecChild[GT_CTR_NF],"04Z085211") == 0)   &&
         (atoi( ptb_InRecChild[GT_SEC_NF] ) == 3)               &&
         (atoi( ptb_InRecChild[GT_UWY_NF] ) >= 1985 ) )
    {
        ptb_InRecChild[GT_UWY_NF] = "1985" ;
    }

    if ( (strcmp(ptb_InRecChild[GT_CTR_NF],"04Z085212") == 0)   &&
         (atoi( ptb_InRecChild[GT_SEC_NF] ) == 2)               &&
         (atoi( ptb_InRecChild[GT_UWY_NF] ) >= 1985 ) )
    {
        ptb_InRecChild[GT_UWY_NF] = "1985" ;
    }

    if ( (strcmp(ptb_InRecChild[GT_CTR_NF],"04Z085214") == 0)   &&
         (atoi( ptb_InRecChild[GT_SEC_NF] ) == 1)               &&
         (atoi( ptb_InRecChild[GT_UWY_NF] ) >= 1995 ) )
    {
        ptb_InRecChild[GT_UWY_NF] = "1995" ;
    }

    if ( (strcmp(ptb_InRecChild[GT_CTR_NF],"04Z0N0136") == 0)   &&
         (atoi( ptb_InRecChild[GT_SEC_NF] ) == 1)               &&
         (atoi( ptb_InRecChild[GT_UWY_NF] ) >= 1996 ) )
    {
        ptb_InRecChild[GT_UWY_NF] = "1996" ;
    }

    if ( (strcmp(ptb_InRecChild[GT_CTR_NF],"04Z085671") == 0)   &&
         (atoi( ptb_InRecChild[GT_SEC_NF] ) == 2)               &&
         (atoi( ptb_InRecChild[GT_UWY_NF] ) > 1996 ) )
    {
        ptb_InRecChild[GT_UWY_NF] = "1996" ;
    }

    if ( (strcmp(ptb_InRecChild[GT_CTR_NF],"05Z120120") == 0)   &&
         (atoi( ptb_InRecChild[GT_SEC_NF] ) == 1)               &&
         (atoi( ptb_InRecChild[GT_UWY_NF] ) > 1992 ) )
    {
        ptb_InRecChild[GT_UWY_NF] = "1992" ;
    }


    /********************************************************/
    /* Modifs du 10/03/99 - par A.BORDET 			        */
    /* si annee de compte < 1992  	                        */
    /* alors ne pas reecrire le mouvement en sortie		    */
    /* cela fait suite aux pbs de reprise compta pour les   */
    /* années de compte < 1992                              */
    /********************************************************/
	if ( atoi( ptb_InRecChild[GT_ACY_NF] ) < 1992 )
	{
		RETURN_VAL(OK);
	}


//	/****************************************************************/
//	/* Modifs du 30/03/98 - par M.HA-THUC 				            */
//	/* si l'affaire est terminee comptablement ( SECACCSTS_CT = 9 ) */
//	/* alors on positionne ADJCOD_CT a 9 de facon à ne pas calculer */
//	/* de compléments pour ces affaires dans le traitement ESID2040 */
//	/* (pour les criblés et les non criblés en fait)                 */
//	/****************************************************************/
    //  printf ("CTR: [%s]\n", ptb_InRecChild[GT_CTR_NF]);
    //  printf ("SEC: [%s]\n", ptb_InRecChild[GT_SEC_NF]);
    //  printf ("UWY: [%s]\n", ptb_InRecChild[GT_UWY_NF]);
	balshmth = atoi(ptb_InRecChild[GT_SCOENDMTH_NF]);
	if (ptb_InRecChild[GT_ESTCRB_CT][0] == 'T' || ptb_InRecChild[GT_ESTCRB_CT][0] == 'U')
	{
		if (balshmth >= 1 && balshmth <= 3)
			ptb_InRecChild[74] = "3";
		else if (balshmth >= 4 && balshmth <= 6)
			ptb_InRecChild[74] = "6";
		else if (balshmth >= 7 && balshmth <= 9)
			ptb_InRecChild[74] = "9";
		else
			ptb_InRecChild[74] = "12";
	}
	else
		ptb_InRecChild[74] = "13";


	//int toto;
	//for (toto = 0; toto < 75; toto++) {
	//	printf("[%d] -> %s\n", toto, ptb_InRecChild[toto]);
	//}
    //[009]
    if  ( atoi( ptb_InRecOwner[PER_SECACCSTS_CT] ) == 9 )
    {
        ptb_InRecChild[GT_ADJCOD_CT] = "9" ;
    } 
    else
    if ( n_recherche_SECACCSTS_PERIRATTACH(ptb_InRecChild)==9  )
    {
        n_WriteCols(Kp_OutTermineCptERR, ptb_InRecChild,SEPARATEUR,0);
        ptb_InRecChild[GT_ADJCOD_CT] = "9";
    }


   	if ( atoi( ptb_InRecChild[GT_BALSHEY_NF] ) <=  Kn_BALSHTYEA_NF - 1 &&
	     atoi( ptb_InRecChild[GT_ACY_NF] ) <=  Kn_BALSHTYEA_NF -1  )
	{
		n_WriteCols(Kp_OutGTB1,ptb_InRecChild,SEPARATEUR,0);
	}
   	if ( atoi( ptb_InRecChild[GT_BALSHEY_NF] ) <= Kn_BALSHTYEA_NF &&
	     flag_B1 == 0 && atoi( ptb_InRecChild[GT_ACY_NF] ) <= Kn_BALSHTYEA_NF )
	{
        n_WriteCols(Kp_OutputFil,ptb_InRecChild,SEPARATEUR,0);
	}
     RETURN_VAL(OK);
}

// ----------------------------------------------------------------------------
// objet : fonction lancee quand le pere n'a pas de fils GT
// retour: OK ---> traitement correctement effectue
//         ERR --> probleme rencontre
// ----------------------------------------------------------------------------
//                          adresse de la ligne du maitre
int n_ActionPereSansFilsGT( char **ptb_InRecOwner )
{
  int i;
  int balshmth;
  double d_aliment,d_taux;
  char sz_aliment[22];
  //[013]
  char *tb[GT_NBCOL + 3];
  //[012]
  char   sz_TRNCOD[9];
  int    n_Trncod1 = 0, n_Trncod2= 0, n_Trncod3 = 0;
  char sz_DETTRNCOD[6];
    DEBUT_FCT("n_ActionPereSansFilsGT");
    
    for(i=0;i<GT_NBCOL + 2;i++)
        tb[i]="";

	//printf("%d\n", sizeof(tb) / sizeof(*tb));
    tb[GT_NBCOL + 2] = 0;

    // Calcul du taux de conversion (cours: 31/12/exercice precedent)
    d_taux=d_GetTaux( Kp_CoursFil,
                      (char)atoi(ptb_InRecOwner[PER_SSD_CF]),
                      (short)atoi(ptb_InRecOwner[PER_UWY_NF])-1,
                      ptb_InRecOwner[PER_EGPCUR_CF],
                      ptb_InRecOwner[PER_PCPCUR_CF] );

    if (d_taux>0)
    {
        // Conversion de l'aliment brut SCOR
        d_aliment=atof(ptb_InRecOwner[PER_SCOEGP_M]);
        // Conversion
        d_aliment *= d_taux;
    }
    else
        d_aliment=-1;

    sprintf(sz_aliment,"%.3lf",d_aliment);

    tb[GT_SSD_CF]=                  ptb_InRecOwner[PER_SSD_CF];
    tb[GT_ESB_CF]=                  ptb_InRecOwner[PER_ACCESB_CF];

    tb[GT_CTR_NF]=                  ptb_InRecOwner[PER_CTR_NF];
    tb[GT_END_NT]=                  ptb_InRecOwner[PER_END_NT];
    tb[GT_SEC_NF]=                  ptb_InRecOwner[PER_SEC_NF];
    tb[GT_UWY_NF]=                  ptb_InRecOwner[PER_UWY_NF];
    tb[GT_UW_NT]=                   ptb_InRecOwner[PER_UW_NT];
    tb[GT_ACY_NF]=                  ptb_InRecOwner[PER_UWY_NF];

    tb[GT_CUR_CF]=                  ptb_InRecOwner[PER_PCPCUR_CF];  	// Modif ANB du 16/10/98 : Ajout de la monnaie principale pour la conversion de l'aliment lors du traitement de ventilation
    tb[GT_CED_NF]=                  ptb_InRecOwner[PER_CED_NF];
    tb[GT_BRK_NF]=                  ptb_InRecOwner[PER_PRD_NF];
    tb[GT_PAY_NF]=                  ptb_InRecOwner[PER_GENPRMPAY_NF];
    tb[GT_KEY_NF]=                  ptb_InRecOwner[PER_GANPAYORD_NT];

    // GT enrichi
    tb[GT_ESTCUR_CF]=               ptb_InRecOwner[PER_PCPCUR_CF];
    tb[GT_NAT_CF]=                  ptb_InRecOwner[PER_NAT_CF];
    //[012]
    memset(sz_DETTRNCOD, 0, sizeof(sz_DETTRNCOD));
    if (atoi(ptb_InRecOwner[PER_NAT_CF]) >= 30)
    {
        strcpy (sz_DETTRNCOD , "10110");
    }
    else
    {
        strcpy (sz_DETTRNCOD , "10000");
    }
    //[013]
    if (strcmp (ptb_InRecOwner[PER_SEGTYP_CT], "") == 0)
    {
        tb[GT_ACMTRS_NT]= "2010";
        if (atoi (ptb_InRecOwner[PER_LOB_CF]) == 30)
        {
            n_Trncod1 = 4;
        }
        if (atoi (ptb_InRecOwner[PER_LOB_CF]) == 31)
        {
            n_Trncod1 = 2;
        }
    }
    else
    {
        tb[GT_ACMTRS_NT]= "1010";
        if (atoi (ptb_InRecOwner[PER_LOB_CF]) == 30)
        {
            n_Trncod1 = 3;
        }
        if (atoi (ptb_InRecOwner[PER_LOB_CF]) == 31)
        {
            n_Trncod1 = 1;
        }
    }
    n_Trncod2 = 1;
    n_Trncod3 = 0;
    //tb[GT_ACMTRS_NT]=               sz_acmtrs;//"0"
    memset(sz_TRNCOD, 0, sizeof(sz_TRNCOD));
    sprintf (sz_TRNCOD, "%d%d%s%d",n_Trncod1,n_Trncod2,sz_DETTRNCOD,n_Trncod3);
    tb[GT_TRNCOD_CF]= sz_TRNCOD;
    
    tb[GT_ESTCTR_NF]=               ptb_InRecOwner[PER_ESTCTR_NF];
    tb[GT_ESTSEC_NF]=               ptb_InRecOwner[PER_ESTSEC_NF];
    tb[GT_LOB_CF]=                  ptb_InRecOwner[PER_LOB_CF];
    tb[GT_SCOEGP_M]=                sz_aliment;
    tb[GT_ESTCRB_CT]=               ptb_InRecOwner[PER_ESTCRB_CT];
    tb[GT_LIFTRTTYP_CF]=            ptb_InRecOwner[PER_LIFTRTTYP_CF];
    tb[GT_ACCADMTYP_CT]=            ptb_InRecOwner[PER_ACCADMTYP_CT];
    tb[GT_SECSTS_CT]=               ptb_InRecOwner[PER_SECSTS_CT];
    tb[GT_PRD_NF]=                  ptb_InRecOwner[PER_PRD_NF];
    tb[GT_SEG_NF]=                  ptb_InRecOwner[PER_SEG_NF];
    tb[GT_COMACC_B]=                "0";

	balshmth = atoi(ptb_InRecOwner[GT_SCOENDMTH_NF]);

		
     // printf ("Pere sans fils\n");
     // printf ("CTR: [%s]\n", tb[GT_CTR_NF]);
     // printf ("SEC: [%s]\n", tb[GT_SEC_NF]);
     // printf ("UWY: [%s]\n", tb[GT_UWY_NF]);
	if (tb[GT_ESTCRB_CT][0] == 'T' || tb[GT_ESTCRB_CT][0] == 'U')
	{
		if (balshmth >= 1 && balshmth <= 3)
			tb[74] = "3";
		else if (balshmth >= 4 && balshmth <= 6)
			tb[74] = "6";
		else if (balshmth >= 7 && balshmth <= 9)
			tb[74] = "9";
		else
			tb[74] = "12";
	}
	else
		tb[74] = "13";


    // Modif Anb le 5/11/1999 : Report modification adjcod_ct si affaire sans mouvement terminée
    if ( atoi( ptb_InRecOwner[PER_SECACCSTS_CT] ) == 9 )
    {
        tb[GT_ADJCOD_CT] = "9" ;
    }

    //tb[GT_RETCOD_CT]                = "0";
    tb[GT_DETTRS_CF]                = "";
    //tb[GT_ADJSIG_B]=                "0";
    tb[GT_ESTUWY_NF]=               "";
    tb[GT_PROPER_N]=                ptb_InRecOwner[PER_ACCFRQ_CT];
    tb[GT_UWGRP_CF]=                ptb_InRecOwner[PER_UWGRP_CF];
    tb[GT_RTOCTY_CF]=               "";

    n_WriteCols(Kp_OutGTB1,tb,SEPARATEUR,0);
    /*if (atoi (tb[GT_ACMTRS_NT]) == 0)
    {
      printf ("TRNCODPereSansFils: [%s]\n", tb[GT_TRNCOD_CF]);
      printf ("CTR: [%s]\n", tb[GT_CTR_NF]);
      printf ("SEC: [%s]\n", tb[GT_SEC_NF]);
      printf ("UWY: [%s]\n", tb[GT_UWY_NF]);
    }*/
    n_WriteCols(Kp_OutputFil,tb,SEPARATEUR,0);

  RETURN_VAL(OK);
}

// ----------------------------------------------------------------------------
// objet : fonction lancee fils(GT) n'a pas de père(PERIMETRE)
// retour:  OK ---> traitement correctement effectue
//          ERR --> probleme rencontre
// Si le GT n'a pas de périmètre et pour un type comptable = 4
// on met le champ UWY_GT de la ligne GT au dernier exercie connu dans le périmètre
// Pour cela, on a auvegardé la ligné PERIMETRE précédente, et si le contrat est identique au contrat GT en cours,
// on force le champ GT_UWY_NF.
// ----------------------------------------------------------------------------
int n_ActionFilsSansPereGT( char **ptb_InRecChild )
{
    int i;
	int balshmth;
    //[013]
    char *tb[GT_NBCOL+3];

    DEBUT_FCT("n_ActionPereSansFilsGT");

    for(i = 0; i < GT_NBCOL; i++)
        tb[i]=ptb_InRecChild[i];

    tb[GT_NBCOL] = "";
    tb[GT_NBCOL+1] = "";
    tb[GT_NBCOL + 2] = 0;
 	balshmth = atoi(tb[GT_SCOENDMTH_NF]);
    tb[GT_ESTCRB_CT] = Ks_ESTCRB;
	if (tb[GT_ESTCRB_CT][0] == 'T' || tb[GT_ESTCRB_CT][0] == 'U')
	{
		if (balshmth >= 1 && balshmth <= 3)
			tb[74] = "3";
		else if (balshmth >= 4 && balshmth <= 6)
			tb[74] = "6";
		else if (balshmth >= 7 && balshmth <= 9)
			tb[74] = "9";
		else
			tb[74] = "12";
	}
	else
		tb[74] = "13";

    // Si on est sur le même contrat que sur la dernière rupture Périmètre, on actualise la devise sauvegardée.
    if ( strcmp(Ks_CTR, ptb_InRecChild[GT_CTR_NF]) == 0 )
    {
        tb[GT_CUR_CF] = Ks_CUR;
        tb[GT_ESTCUR_CF] = Ks_CUR;

		    }
    if ( !strcmp(ptb_InRecChild[GT_ACCADMTYP_CT],"4") )
    {
        tb[GT_UWY_NF]=Ksz_PER_UWY_NF;
    }
    /*if (atoi (tb[GT_ACMTRS_NT]) == 0)
    {
      printf ("TRNCODFilsSansPere: [%s]\n", tb[GT_TRNCOD_CF]);
    }*/
    n_WriteCols(Kp_OutputFil,tb,SEPARATEUR,0);
    RETURN_VAL(OK);
}




//[009]
// ----------------------------------------------------------------------------
// objet : 
// retour: SECACCSTS
// ----------------------------------------------------------------------------
int n_recherche_SECACCSTS_PERIRATTACH(char **ptb_InRecChild)
{
  int secaccsts=0;
  int i;

    DEBUT_FONCTION("n_recherche_SECACCSTS_PERIRATTACH");


//#==============
//#    TRACE
//#--------------
#ifdef TRACE_RECHERCHE
if(strcmp(ptb_InRecChild[GT_ESTCTR_NF], "")!=0)
if(strcmp(ptb_InRecChild[GT_ESTSEC_NF], "")!=0)
{
printf("-- NB lignes PERIMETRE ATTACHEMENT: %d\n", nb_periattach);
printf("-- Rechche sur : %s/%s/%s ~ %s/%s/%s\n",
    ptb_InRecChild[GT_CTR_NF],
    ptb_InRecChild[GT_SEC_NF],
    ptb_InRecChild[GT_UWY_NF],

    ptb_InRecChild[GT_ESTCTR_NF],
    ptb_InRecChild[GT_ESTSEC_NF],
    ptb_InRecChild[GT_ESTUWY_NF]);
    

    for(int i=0;i<67;i++)
//    printf("%d"[%s]\n", i, ptb_InRecChild[i]);
    printf("%s~", ptb_InRecChild[i]);
    printf("\n");
}
#endif
//#--------------
//#  FIN TRACE
//#==============


    if(strcmp(ptb_InRecChild[GT_ESTCTR_NF], "")!=0)
    if(strcmp(ptb_InRecChild[GT_ESTSEC_NF], "")!=0)
    for(i=0,  T_PERIATTACH=T_PERIATTACH_DEBUT; i<nb_periattach;  i++, T_PERIATTACH=T_PERIATTACH->suiv)
    {
//#==============
//#    TRACE
//#--------------
#ifdef TRACE_RECHERCHE_I
printf("-- RECHERCHE[%d]: %s~%s~%s~%s\n",
i,
T_PERIATTACH->CTR_NF,
T_PERIATTACH->SEC_NF,
T_PERIATTACH->UWY_NF,
T_PERIATTACH->SECACCSTS_CT);
#endif
//#--------------
//#  FIN TRACE
//#==============

        if( strcmp(ptb_InRecChild[GT_ESTCTR_NF], T_PERIATTACH->CTR_NF ) ==0     &&
            strcmp(ptb_InRecChild[GT_ESTSEC_NF], T_PERIATTACH->SEC_NF ) ==0     &&
            strcmp(ptb_InRecChild[GT_UWY_NF],    T_PERIATTACH->UWY_NF ) ==0     )
        {
            secaccsts=atoi(T_PERIATTACH->SECACCSTS_CT);
            return secaccsts;
        }
    }

  return secaccsts;
}


// ----------------------------------------------------------------------------
// objet : Encapsulation DEBUT_FCT pour DEBUG
// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------
// objet : Encapsulation DEBUT_FCT pour DEBUG
// ----------------------------------------------------------------------------
void DEBUT_FONCTION(char *fonction)
{
    DEBUT_FCT(fonction);
//#==============
//#    TRACE
//#--------------
#ifdef TRACE_FCT
printf("%s\n", fonction);
#endif
//#--------------
//#  FIN TRACE
//#==============
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
