/*==============================================================================
nom de l'application          : ESTC2141
nom du source                 : ESTC2141
revision                      : 
date de creation              : 15/04/2019
auteur                        : S.Behague
references des specifications : 
squelette de base             : batch
------------------------------------------------------------------------------
description :
			Dans le cadre du Quarterly, ce programme applique un cumul sur les estimations
   		    trimestrielles afin de coller au fonctionnement de la trimestrialisation du
			programme ESTC2136

------------------------------------------------------------------------------
historique des modifications :
   <jj/mm/aaaa>>   <auteur>>    <description de la modification>>
           ...           ...            ...              ...
[001] 15/04/2019 SBE  spira:70045: 
[002] 14/10/2019 SBE  spira:78597: APOLO QE : TLIFSTAREP current, annual and photo plan estimations are wrong
[003] 13/11/2019 SBE  spira:78597: APOLO QE : TLIFSTAREP current, annual and photo plan estimations are wrong
[004] 09/01/2020 SBE  spira:81946: Apolo QE - Computation of Accruals for Cash T.code
[005] 14/01/2021 SBE  spira:101410: Apolo QE - Computation of Accruals for Reserves T.Codes - Copy
*/


/*--------------------------------------------------*/
/* inclusion des interfaces des composants importes */
/*--------------------------------------------------*/
#include <utctlib.h>
#include <struct.h>
#include <estserv.h>

static char VERSION_ESTC2141_C[100] = "ESTC2141 version [003] - Spira 78597"; 

double mnttotal_m;
char sz_clodatyea[5], sz_clodatmth[3], sz_clodatday[3] ;
int Kb_AnInv;

FILE    *Kp_SubTRSFil,
		*Kp_OutPutFile;		/* Pointeur sur le fichier de sortie */

T_RUPTURE_VAR           bd_RuptPrevision;    /* gestion rupture sur pere */
T_SUBTRS     			SubTrsLigne;

/* Initialisation Pere */
int n_InitPrevision	     		(T_RUPTURE_VAR *pbd_Rupt);
int n_ActionFirstRuptPrevision		(char **pbd_InRec_Cur);
int n_ActionFirstRuptPrevision1		(char **pbd_InRec_Cur);
int n_ActionLastRuptPrevision		(char **pbd_InRec_Cur);
int n_ConditionRuptPrevision 		(char **pbd_InRecOwner, char **pbd_InRecChild);
int n_ConditionRuptPrevision1		(char **pbd_InRecOwner, char **pbd_InRecChild);
int n_ActionLignePrevision           (char **pbd_InRec_Cur);

void EcrirePrevision(double d, char **psz_ligne);
int n_AcyCourante(char **ptb_InRec_Cur);
void init_SubTrsLigne();

/*==============================================================================
objet :     point d'entree du programme
retour :    En cas de probleme, la sortie s'effectue par la fonction ExitPgm().
            Sinon, par l'appel systeme exit()
==============================================================================*/
int main(int argc ,char *argv[])
{
    /* Initialisation des signaux */
    InitSig () ;
 	char sz_clodat[9];

  if (n_BeginPgm (argc, argv) == ERR)
    ExitPgm (ERR_XX, "");

	/* Recuperation des dates d'inventaire */

	strcpy (sz_clodat, psz_GetCharArgv(1));

	/* Eclatement du clodat AAAAMMJJ en 3 chaines de caractere */
	sscanf( sz_clodat, "%4s%2s%2s", sz_clodatyea, sz_clodatmth, sz_clodatday ) ;

	if (n_OpenFileAppl("ESTC2141_O1", "wt", &Kp_OutPutFile) == ERR) ExitPgm(ERR_XX, "");
	if (n_InitPrevision(&bd_RuptPrevision) == ERR) ExitPgm(ERR_XX, "");

 	// Chargement fichier T_SUBTRS
    if (n_OpenFileAppl ("ESTC2141_I2","rb",&Kp_SubTRSFil) == ERR ) ExitPgm ( ERR_XX , "" );
    if ( n_ChargerTsubTRS(Kp_SubTRSFil) == ERR ) 				   ExitPgm ( ERR_XX , "" ); 
	init_SubTrsLigne();

	// lancement du traitement du fichier
	if (n_ProcessingRuptureVar(&bd_RuptPrevision) == ERR) ExitPgm(ERR_XX, "");

	if (n_CloseFileAppl("ESTC2141_O1", &Kp_OutPutFile) == ERR) ExitPgm(ERR_XX, "");
	if (n_CloseFileAppl("ESTC2141_I1", &(bd_RuptPrevision.pf_InputFil)) 	== ERR) ExitPgm(ERR_XX, "");

	if (n_CloseFileAppl ("ESTC2141_I2",&Kp_SubTRSFil))                      ExitPgm ( ERR_XX , "" );

	if (n_EndPgm() == ERR) ExitPgm(ERR_XX, "");

	exit(OK);
}

/*==============================================================================================
objet :     fonction d'initialisation de la variable de gestion de rupture du fichier Pere.
==============================================================================================*/
int n_InitPrevision(T_RUPTURE_VAR *pbd_Rupt)
{
	DEBUT_FCT("n_InitPrevision");

	memset(pbd_Rupt, 0, sizeof(*pbd_Rupt));
	if (n_OpenFileAppl ("ESTC2141_I1", "rt", &(pbd_Rupt->pf_InputFil)) == ERR)
		RETURN_VAL(ERR);

	pbd_Rupt->n_NbRupture           = 2;
	pbd_Rupt->n_ConditionRupture[0] = n_ConditionRuptPrevision;
	pbd_Rupt->n_ConditionRupture[1] = n_ConditionRuptPrevision1;
	pbd_Rupt->n_ActionLigne         = n_ActionLignePrevision;
	pbd_Rupt->n_ActionFirst[0]      = n_ActionFirstRuptPrevision;
	pbd_Rupt->n_ActionFirst[1]      = n_ActionFirstRuptPrevision1;
	pbd_Rupt->n_ActionLast[1]       = n_ActionLastRuptPrevision;
	pbd_Rupt->c_Separ               = SEPARATEUR;

	RETURN_VAL (OK);
}

/*==============================================================================
objet :
==============================================================================*/
int n_ConditionRuptPrevision(char **pbd_InRec, char **pbd_InRec_Cur)
{
	int ret;

	DEBUT_FCT("n_ConditionRuptPrevision");

	if ((ret = strcmp(pbd_InRec[PRE_CTR_NF],  pbd_InRec_Cur[PRE_CTR_NF])) != 0) RETURN_VAL(ret);
	if ((ret = strcmp(pbd_InRec[PRE_SEC_NF],  pbd_InRec_Cur[PRE_SEC_NF])) != 0) RETURN_VAL(ret);
	if ((ret = strcmp(pbd_InRec[PRE_UWY_NF],  pbd_InRec_Cur[PRE_UWY_NF])) != 0) RETURN_VAL(ret);
	if ((ret = strcmp(pbd_InRec[PRE_ACY_NF],  pbd_InRec_Cur[PRE_ACY_NF])) != 0) RETURN_VAL(ret);
	if ((ret = strcmp(pbd_InRec[PRE_DETTRNCOD_CF],  pbd_InRec_Cur[PRE_DETTRNCOD_CF])) != 0) RETURN_VAL(ret);
	if ((ret = strcmp(pbd_InRec[PRE_GAAP_NF],  pbd_InRec_Cur[PRE_GAAP_NF])) != 0) RETURN_VAL(ret);
		
	RETURN_VAL (ret);
}

/*==============================================================================
objet :
==============================================================================*/
int n_ConditionRuptPrevision1(char **pbd_InRec, char **pbd_InRec_Cur)
{
	int ret;

	DEBUT_FCT("n_ConditionRuptPrevision1");

	if ((ret = strcmp(pbd_InRec[PRE_CTR_NF],  pbd_InRec_Cur[PRE_CTR_NF])) != 0) RETURN_VAL(ret);
	if ((ret = strcmp(pbd_InRec[PRE_SEC_NF],  pbd_InRec_Cur[PRE_SEC_NF])) != 0) RETURN_VAL(ret);
	if ((ret = strcmp(pbd_InRec[PRE_UWY_NF],  pbd_InRec_Cur[PRE_UWY_NF])) != 0) RETURN_VAL(ret);
	if ((ret = strcmp(pbd_InRec[PRE_ACY_NF],  pbd_InRec_Cur[PRE_ACY_NF])) != 0) RETURN_VAL(ret);
	if ((ret = strcmp(pbd_InRec[PRE_DETTRNCOD_CF],  pbd_InRec_Cur[PRE_DETTRNCOD_CF])) != 0) RETURN_VAL(ret);
	if ((ret = strcmp(pbd_InRec[PRE_GAAP_NF],  pbd_InRec_Cur[PRE_GAAP_NF])) != 0) RETURN_VAL(ret);
	if ((ret = strcmp(pbd_InRec[PRE_ESTMTH_NF],  pbd_InRec_Cur[PRE_ESTMTH_NF])) != 0) RETURN_VAL(ret);
		
	RETURN_VAL (ret);
}

/*==============================================================================
objet :
==============================================================================*/
int n_ActionFirstRuptPrevision(char **ptb_InRec_Cur)
{
	DEBUT_FCT("n_ActionFirstRuptPrevision");

	Kb_AnInv = n_AcyCourante(ptb_InRec_Cur);

	mnttotal_m = 0;
	RETURN_VAL (OK);
}

/*==============================================================================
objet :
==============================================================================*/
int n_ActionFirstRuptPrevision1(char **ptb_InRec_Cur)
{
	DEBUT_FCT("n_ActionFirstRuptPrevision1");

	Kb_AnInv = n_AcyCourante(ptb_InRec_Cur);

	//mnttotal_m = 0;
	RETURN_VAL (OK);
}

/*==============================================================================
objet :
==============================================================================*/
int n_ActionLastRuptPrevision(char **ptb_InRec_Cur)
{
	DEBUT_FCT("n_ActionLastRuptPrevision");

	// Il ne faut écrire la ligne en sortie que si mois ESTMTH <= mois bilan
	if (( atoi(ptb_InRec_Cur[PRE_ACY_NF]) < atoi(sz_clodatyea) ) || ( atoi(ptb_InRec_Cur[PRE_ACY_NF]) <= atoi(sz_clodatyea) && atoi(ptb_InRec_Cur[PRE_ESTMTH_NF]) <= atoi(sz_clodatmth))) 
	{
		EcrirePrevision(mnttotal_m, ptb_InRec_Cur);
	}

	RETURN_VAL (OK);
}

/*==============================================================================
objet :     fonction lancee pour chaque ligne du pere
retour :    0 ----> traitement correctement effectue
            ERR --> probleme rencontre
==============================================================================*/
int n_ActionLignePrevision(char **ptb_InRec_Cur)
{
	int n_poste, m_poste;
	int resultposte=0;

    DEBUT_FCT("n_ActionLignePrevision");

	/* Numero de poste */
	n_poste = atoi(ptb_InRec_Cur[PRE_ACMTRS_NT]);
	m_poste = atoi(ptb_InRec_Cur[PRE_NBCOL + 2]);

	resultposte = n_FindTsubTRS(&SubTrsLigne,ptb_InRec_Cur[PRE_DETTRNCOD_CF]);

	// Si poste réserve, type_ct = 3, on garde la valeur du dernier trimestre, on ne fait pas de cumul.
	// On ne tient pas compte si année de compte inférieure à année bilan pour les postes réserves
	if ( resultposte == 0 && SubTrsLigne.TRSTYPE_CT == 3 )
	{
				// on garde le dernier mois d'estimation présent pour l'année de compte
				// SBE 17122019 - Attention ! faire le test différemment si acy_nf < Balshey. Il ne faut pas limiter le mois bilan
				//if ( atoi(ptb_InRec_Cur[PRE_ESTMTH_NF]) <= atoi(sz_clodatmth) )
				//{
					mnttotal_m = atof(ptb_InRec_Cur[PRE_ESTMNT_M]);
				//}
	}
	else
	{
			mnttotal_m = atof(ptb_InRec_Cur[PRE_ESTMNT_M]);
	}
	
	RETURN_VAL (0);
}

/*==============================================================================
objet : Fonction d'ecriture dans le champs  psz_ligne
==============================================================================*/
void EcrirePrevision(double d, char **psz_ligne)
{
   
  	char sz_montant[30];
  	char sz_balshtmth[3];

  	/* Conversion du montant en chaine */
  	sprintf(sz_montant, "%lf", d);
	sprintf( sz_balshtmth, "%d", atoi(sz_clodatmth) ) ;
  	//printf("ecriture prevision d'un montant=%s\n", sz_montant);

  	/* Affectation a la structure de prevision */
  	/*   strcpy(psz_ligne[PRE_ESTMNT_M],sz_montant);*/
  	psz_ligne[PRE_ESTMNT_M] = sz_montant;

  	/* Affectation a la structure de l'annee et mois bilan */
  	psz_ligne[PRE_BALSHEY_NF] = sz_clodatyea ;
  	psz_ligne[PRE_BALSHTMTH_NF] = sz_balshtmth ;
  	//psz_ligne[PRE_ESTMTH_NF] = sz_balshtmth ; SBE Ne plus changer pour les complements au trimestre

  	/* Ecriture */
  	n_WriteCols(Kp_OutPutFile, psz_ligne, '~', 0);
}

/*==========================================================================
  Objet :     Acy Courante
  Parametres: Pointeur sur ligne prevision
  Retour:     0 si la prevision est courante
              -1 si la prevision est passee
              +1 si la prevision est future

              A modifier pour traiter les traités décalés
===========================================================================*/
int n_AcyCourante(char **ptb_InRec_Cur)  //[026]
{
	if ( atoi(ptb_InRec_Cur[PRE_ACY_NF]) == atoi(sz_clodatyea) )
        return 1;
    else
        return 0;
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
