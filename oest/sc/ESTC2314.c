/*[XXX] 6/04/2014 JBG :spot:25773 Modify void main declaration to int main*/

/*=============================================================================
Nom de l'application          : 
nom du source                 : ESTC2314.c
revision                      :
date de creation              : 9/1997 
auteur                        : C.G.I. Kuhna 
references des specifications : #################
squelette de base             : batch
------------------------------------------------------------------------------
description :
  Il s'agit de preparer l'edition des ecarts entre resultats theoriques
  et comptables

  En entree : Fichier des rapprochements trie sur 
              filiale/etablissement/Top retro/
              C/Av/S/E/No ordre E Acceptation
              C/Av/S/E/No ordre E Retro
              Monnaie retro
  En sortie : Fichier des rapprochements auquel on a ajoute des lignes cumuls
               - Somme des montants pour Top retro prop dont ecart epure >= 10
               - Somme des montants pour Top retro prop 
               - Somme des montants pour Top retro non prop 
               - Somme globale des montants pour Top retro prop et non prop 
              Sont otees lignes dont Top retro est prop et ecart epure < 10


  2 ruptures sur fichier des rapprochements :
     Rupt 1 -> Filiale/Etablissement
     Rupt 2 -> Filiale/Etablissement/Top retro
    
------------------------------------------------------------------------------
historique des modifications :
   <jj/mm/aaaa>   <auteur>    <description de la modification>
	   ...           ...            ...              ...
==============================================================================*/

/*--------------------------------------------------*/
/* inclusion des interfaces des composants importes */
/*--------------------------------------------------*/
#include <utctlib.h>
#include <stdarg.h>
#include <struct.h>
#include <estserv.h>
	
/*---------------------------------------*/
/* inclusion de l'interface du composant */
/*---------------------------------------*/

/*---------------------------------------------*/
/* definition des constantes et macros privees */
/*---------------------------------------------*/
/* Definition des types de lignes */
#define COURANTE   1
#define CUM_N      2
#define CUM_PSUP10 3 
#define CUM_P      4 
#define CUM_GLOB   5 

#define CODE_CTR_CUM_PSUP10    "1"
#define CODE_CTR_CUM_P         "2"
#define CODE_TOP_CUM_P         "C"      /*"O"*/
#define CODE_TOP_CUM_N         "B"      /*"M"*/
#define CODE_TOP_CUM_GLOB      "A"
/*------------------------------------------------*/



/*----------------------*/
/* variables de travail */
/*----------------------*/

FILE  	           *Kp_OutputFil, /*pointeur sur le fichier de sortie*/
                                  /*pointeur sur le fichier des cours*/
                   *Kp_InputFilExc;

T_RUPTURE_VAR      Kbd_RuptRapp;  /*variable de gestion de la rupture*/

                                   /*declaration des structures pour les cumuls 
                                     au format du fic de rapprochement */
T_FRAPP		   Kbd_CumPSup10,    /* Top retro=P et ecart epure>10 */
                   Kbd_CumP,         /* Top retro=P */
                   Kbd_CumN ;       /* Top retro=NP */
                    
int                Kn_Conver,       /* Indicateur taux de conversion bon
                                        = diff de -1)*/
                   Kn_AuMoins1ConvertRupt1 = 0,
                                   /* 1 -> Au moins 1 converti Rupt1*/
                   Kn_AuMoins1ConvertRupt2 = 0;     
                                  /* 1 -> Au moins 1 converti Rupt2*/

int                Kn_Annee;                /* Annee de periode de compte
                                             (parametre de la chaine) */
      
int n_ConvertMts(T_FRAPP *bd_Art,char **ptb_InRec_Cur);
int n_CumulMts(T_FRAPP *bd_Cum,T_FRAPP *bd_Art);
int n_CumulGlob(T_FRAPP *bd_Cum);
void o_EcritLigne(int n_TypLin,T_FRAPP *bd_Mts,char **ptb_Ligne);
int n_TransMtsDoubleChaine(T_FRAPP *bd_Double,char **ptb_Ligne);


int n_InitRapp(T_RUPTURE_VAR  *pbd_Rupt);
int n_IsR1Rapp(char **ptb_InRec,char **ptb_InRec_Cur);
int n_IsR2Rapp(char **ptb_InRec,char **ptb_InRec_Cur);
int n_ActionFirstRupt1Rapp(char **ptb_InRec_Cur);
int n_ActionFirstRupt2Rapp(char **ptb_InRec_Cur);
int n_ActionLigneRapp(char **pbd_InRec_Cur);
int n_ActionLastRupt1Rapp(char **ptb_InRec_Cur);
int n_ActionLastRupt2Rapp(char **ptb_InRec_Cur);

int n_ProcessingRuptureVar(T_RUPTURE_VAR *pbd_Rupt);

/*==============================================================================
objet : Pt d'entree du programme
   
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

                                /* Recuperation de l'annee de compte */
  Kn_Annee=n_GetIntArgv(1);                                            

	                         /* Ouverture du fichier en entree 
                                    des cours de change FCURQUOT */
  if (n_OpenFileAppl("ESTC2314_I2","rb",&Kp_InputFilExc) == ERR)
    ExitPgm(ERR_XX ,"") ;

				/* Ouverture du fichier de sortie */
  if (n_OpenFileAppl ("ESTC2314_O1","wt",&Kp_OutputFil) == ERR)
    ExitPgm(ERR_XX ,"");

				/* Initialisation var Kbd_RuptRapp */
  if (n_InitRapp(&Kbd_RuptRapp) == ERR)
    ExitPgm(ERR_XX ,"");

				/* Lancement traitement fic des rapprochement */
  if (n_ProcessingRuptureVar(&Kbd_RuptRapp) == ERR)
    ExitPgm(ERR_XX,"");

				/* Fermeture des fichiers */
  if (n_CloseFileAppl("ESTC2314_I1",&(Kbd_RuptRapp.pf_InputFil)) == ERR)
    ExitPgm(ERR_XX,"");

  if (n_CloseFileAppl("ESTC2314_I2",&Kp_InputFilExc) == ERR)
    ExitPgm(ERR_XX,"");

  if (n_CloseFileAppl("ESTC2314_O1",&Kp_OutputFil) == ERR)
    ExitPgm(ERR_XX,"");

  if (n_EndPgm() == ERR)
    ExitPgm ( ERR_XX , "" );

  exit(OK);
}


/*==============================================================================
objet :
	fonction d'initialisation de la variable de gestion de rupture
        du fichier de rapprochement.

retour :
	0K
==============================================================================*/
int n_InitRapp(T_RUPTURE_VAR  *pbd_Rupt)
{
  memset(pbd_Rupt,0,sizeof(T_RUPTURE_VAR));
					/* Ouverture du fic GTAa */
  if (n_OpenFileAppl("ESTC2314_I1","rt",&(pbd_Rupt->pf_InputFil)) == ERR)
    return ERR;

  pbd_Rupt->n_NbRupture = 2; 

  pbd_Rupt->n_ConditionRupture[0] = n_IsR1Rapp;
  pbd_Rupt->n_ConditionRupture[1] = n_IsR2Rapp;

  pbd_Rupt->n_ActionFirst[0]      = n_ActionFirstRupt1Rapp;
  pbd_Rupt->n_ActionFirst[1]      = n_ActionFirstRupt2Rapp;

  pbd_Rupt->n_ActionLigne         = n_ActionLigneRapp;

  pbd_Rupt->n_ActionLast[0]       = n_ActionLastRupt1Rapp;
  pbd_Rupt->n_ActionLast[1]       = n_ActionLastRupt2Rapp;

  pbd_Rupt->c_Separ = SEPARATEUR;

  return OK;
}

/*==============================================================================
objet :
	fonction de test de rupture de niveau 1 fichier de rapprochement
        sur Filiale/Etablissement

retour :
	0 ---> pas de rupture
	dif de 0 ---> rupture
===========================================================================*/
int n_IsR1Rapp(char **ptb_InRec,char **ptb_InRec_Cur)
{
  int ret;
				/* Test de correspondance entre ligne courante
                                   et ligne suivante sur : 
                              		  	    Filiale */
  ret = strcmp(ptb_InRec[FRAPP_SSD_CF],ptb_InRec_Cur[FRAPP_SSD_CF]);
  if (ret != 0)
     return ret;

                              			  /* Etablissement */
  ret = strcmp(ptb_InRec[FRAPP_ESB_CF],ptb_InRec_Cur[FRAPP_ESB_CF]);
  if (ret != 0)
     return ret;

  return 0;
}
/*==============================================================================
objet :
	fonction de test de rupture de niveau 2 fichier de raprochement 
        sur Filiale/Etablissement/Top Retro 
         (Top Retro : N -> non proportionnel
                      P -> proportionnel) 
retour :
	0 ---> pas de rupture
	dif de 0 ---> rupture
===========================================================================*/
int n_IsR2Rapp(char **ptb_InRec,char **ptb_InRec_Cur)
{
  int ret;
				/* Test de correspondance entre ligne courante
                                   et ligne suivante sur : 
                              		  	    Filiale */
  ret = strcmp(ptb_InRec[FRAPP_SSD_CF],ptb_InRec_Cur[FRAPP_SSD_CF]);
  if (ret != 0)
     return ret;

                              			  /* Etablissement */
  ret = strcmp(ptb_InRec[FRAPP_ESB_CF],ptb_InRec_Cur[FRAPP_ESB_CF]);
  if (ret != 0)
     return ret;

                              			  /* Top Retro */
  ret = strcmp(ptb_InRec[FRAPP_RETNAT_CF],ptb_InRec_Cur[FRAPP_RETNAT_CF]);
  if (ret != 0)
     return ret;

  return 0;
}

/*==============================================================================
objet :
	fonction lancee a la rupture premiere de niveau 1
        Initialisation des cumuls

retour :
	OK ---> traitement correctement effectue
	ERR --> probleme rencontre
===========================================================================*/
int n_ActionFirstRupt1Rapp(char **ptb_InRec_Cur)
{
  memset(&Kbd_CumPSup10,0,sizeof(T_FRAPP));
  memset(&Kbd_CumP,0,sizeof(T_FRAPP));
  memset(&Kbd_CumN,0,sizeof(T_FRAPP));

  return OK;
}

/*==========================================================================
objet :

retour :
	OK ---> traitement correctement effectue
	ERR --> probleme rencontre
===========================================================================*/
int n_ActionFirstRupt2Rapp(char **ptb_InRec_Cur)
{
  return OK;
}

/*==============================================================================
objet :
	fonction lancee pour chaque ligne
        - conversion des montants en monnaie filiale
        - cumuls
        - ecriture des lignes en sortie

retour :
	OK ---> traitement correctement effectue
	ERR --> probleme rencontre
===========================================================================*/
int n_ActionLigneRapp(char **ptb_InRec_Cur)
{
  T_FRAPP bd_Conv;      /* Ligne courante dont tous les montants sont convertis
                          en monnaie filiale */

  /* Conversion des montants de la ligne courante en monnaie filiale */
  Kn_Conver = n_ConvertMts(&bd_Conv,ptb_InRec_Cur);
  if (Kn_Conver == -1) return OK;           /* Taux de conversion non trouve */
                                            /* pas de calcul ni affichage */

  /* En fonction de la valeur du top retro, 2 traitements differents */
  switch (*(ptb_InRec_Cur[FRAPP_RETNAT_CF]))
    {
    case 'N' :                              /* Cumuls des NP sans distinction */
               n_CumulMts(&Kbd_CumN,&bd_Conv);

                                            /* Ecriture de la ligne courante */
               o_EcritLigne(COURANTE,&bd_Conv,ptb_InRec_Cur);
               break;
    case 'P' :                              /* Cumuls des P sans distinction */
               n_CumulMts(&Kbd_CumP,&bd_Conv);

               if (fabs(bd_Conv.AMT12_M) >= 10)  /* Ecart epure >= 10 ? */
                 {
                   n_CumulMts(&Kbd_CumPSup10,&bd_Conv);

                                            /* Ecriture de la ligne courante */
                   o_EcritLigne(COURANTE,&bd_Conv,ptb_InRec_Cur);
                 }
               break;
    } 

  return OK;
}

/*==============================================================================
objet :
	fonction lancee en rupture derniere de niveau 2
        Ecriture sur le fic en sortie de la ligne cumul
           Kbd_CumPSup10 et Kbd_CumP si on sort d'un bloc en Prop
           Kbd_CumN si on sort d'un bloc en Non Prop
retour :
	OK ---> traitement correctement effectue
	ERR --> probleme rencontre
===========================================================================*/
int n_ActionLastRupt2Rapp(char **ptb_InRec_Cur)
{
                                  /* Si au moins 1 Taux de conversion trouve */
  if (Kn_AuMoins1ConvertRupt2 == 1) 
  {

  /* En fonction de la valeur du top retro, 2 traitements differents */
  switch (*(ptb_InRec_Cur[FRAPP_RETNAT_CF]))
    {
    case 'N' :  
                                        /* Ecriture de la ligne cumul NonProp */
               o_EcritLigne(CUM_N,&Kbd_CumN,ptb_InRec_Cur);
               break;
    case 'P' :    
                                        /* Ecriture ligne cumul Prop*/
               o_EcritLigne(CUM_PSUP10,&Kbd_CumPSup10,ptb_InRec_Cur);
               o_EcritLigne(CUM_P,&Kbd_CumP,ptb_InRec_Cur);
               break;
    } 
  }
  Kn_AuMoins1ConvertRupt2 = 0;
  return OK;
}

/*==============================================================================
objet :
	fonction lancee en rupture derniere de niveau 1
        Ecriture sur le fic en sortie de la ligne cumul global
retour :
	OK ---> traitement correctement effectue
	ERR --> probleme rencontre
===========================================================================*/
int n_ActionLastRupt1Rapp(char **ptb_InRec_Cur)
{
  T_FRAPP  bd_CumGlob;

                                  /* Si au moins 1 Taux de conversion trouve */
  if (Kn_AuMoins1ConvertRupt1 == 1) 
    {
      n_CumulGlob(&bd_CumGlob);
                                  /* Ecriture de la ligne cumul global */
      o_EcritLigne(CUM_GLOB,&bd_CumGlob,ptb_InRec_Cur);
    }
  Kn_AuMoins1ConvertRupt1 = 0;
  return OK;
}
/*=============================================================================
objet :
        fonction qui convertit chacun des montants de la ligne courante 
        dans la monnaie de la filiale 
        Ces montants convertis sont stockes dans bd_Art et sont de type DOUBLE
        
retour -> OK  si ok
          -1 si taux de conversion pas trouve
=============================================================================*/
int n_ConvertMts(T_FRAPP *bd_Art,char **ptb_InRec_Cur)
{
  double d_Taux;
  char MsgAno[200];
  

  /* Calcul du taux de conversion */
  d_Taux = d_GetTaux(Kp_InputFilExc,
                     (char) atoi(ptb_InRec_Cur[FRAPP_SSD_CF]),
		     Kn_Annee,
                     ptb_InRec_Cur[FRAPP_RETCUR_CF], 
		     0);


  if (d_Taux == -1)          /* Taux de conversion inexistant */
    {                        /* Anomalie */
      sprintf(MsgAno,"The conversion rate between the %s currency and the currency of subsidiary %s is not defined for %d\n",
             ptb_InRec_Cur[FRAPP_RETCUR_CF],
             ptb_InRec_Cur[FRAPP_SSD_CF],
             Kn_Annee);

      n_WriteAno(MsgAno);
      return -1; 
    }
  Kn_AuMoins1ConvertRupt1 = 1;    /* Au moins 1 converti Rupt1*/
  Kn_AuMoins1ConvertRupt2 = 1;    /* Au moins 1 converti Rupt2*/

                             /* Conversion de tous les montants */
  bd_Art->ACRES_M =  d_Taux
                  * atof(ptb_InRec_Cur[FRAPP_ACRES_M]); 

  bd_Art->THRES_M =  d_Taux
                  * atof(ptb_InRec_Cur[FRAPP_THRES_M]); 

  bd_Art->AMT1_M =  d_Taux
                  * atof(ptb_InRec_Cur[FRAPP_AMT1_M]); 

  bd_Art->AMT2_M =  d_Taux
                  * atof(ptb_InRec_Cur[FRAPP_AMT2_M]); 

  bd_Art->AMT3_M =  d_Taux
                  * atof(ptb_InRec_Cur[FRAPP_AMT3_M]); 

  bd_Art->AMT4_M =  d_Taux
                  * atof(ptb_InRec_Cur[FRAPP_AMT4_M]); 

  bd_Art->AMT5_M =  d_Taux
                  * atof(ptb_InRec_Cur[FRAPP_AMT5_M]); 

  bd_Art->AMT6_M =  d_Taux
                  * atof(ptb_InRec_Cur[FRAPP_AMT6_M]); 

  bd_Art->AMT7_M =  d_Taux
                  * atof(ptb_InRec_Cur[FRAPP_AMT7_M]); 

  bd_Art->AMT8_M =  d_Taux
                  * atof(ptb_InRec_Cur[FRAPP_AMT8_M]); 

  bd_Art->AMT9_M =  d_Taux
                  * atof(ptb_InRec_Cur[FRAPP_AMT9_M]); 

  bd_Art->AMT10_M =  d_Taux
                  * atof(ptb_InRec_Cur[FRAPP_AMT10_M]); 

  bd_Art->AMT11_M =  d_Taux
                  * atof(ptb_InRec_Cur[FRAPP_AMT11_M]); 

  bd_Art->AMT12_M =  d_Taux
                  * atof(ptb_InRec_Cur[FRAPP_AMT12_M]); 

  return OK;
}  

/*=============================================================================
objet :
        dans cette fonction on ajoute les montants de la ligne courante
        (montants figurant dans bd_Art) avec les montants de la ligne cumul
        (montants figurant dans bd_Cum) 
        
retour -> OK
=============================================================================*/
int n_CumulMts(T_FRAPP *bd_Cum,T_FRAPP *bd_Art)
{
  bd_Cum->ACRES_M += bd_Art->ACRES_M; 
  bd_Cum->THRES_M += bd_Art->THRES_M; 
  bd_Cum->AMT1_M += bd_Art->AMT1_M; 
  bd_Cum->AMT2_M += bd_Art->AMT2_M; 
  bd_Cum->AMT3_M += bd_Art->AMT3_M; 
  bd_Cum->AMT4_M += bd_Art->AMT4_M; 
  bd_Cum->AMT5_M += bd_Art->AMT5_M; 
  bd_Cum->AMT6_M += bd_Art->AMT6_M; 
  bd_Cum->AMT7_M += bd_Art->AMT7_M; 
  bd_Cum->AMT8_M += bd_Art->AMT8_M; 
  bd_Cum->AMT9_M += bd_Art->AMT9_M; 
  bd_Cum->AMT10_M += bd_Art->AMT10_M; 
  bd_Cum->AMT11_M += bd_Art->AMT11_M; 
  bd_Cum->AMT12_M += bd_Art->AMT12_M; 

  return OK;
}

/*=============================================================================
objet :
        On cree une ligne "Cumul Global" dont les montants sont composes
        de la somme des montants cumul prop et cumul Non prop
        
retour -> OK
=============================================================================*/
int n_CumulGlob(T_FRAPP *bd_Cum)
{
  /* Calcul des cumuls globaux = cumulN + cumulP (pour chaque montant) */
  bd_Cum->ACRES_M = Kbd_CumP.ACRES_M + Kbd_CumN.ACRES_M;
  bd_Cum->THRES_M = Kbd_CumP.THRES_M + Kbd_CumN.THRES_M;
  bd_Cum->AMT1_M = Kbd_CumP.AMT1_M + Kbd_CumN.AMT1_M;
  bd_Cum->AMT2_M = Kbd_CumP.AMT2_M + Kbd_CumN.AMT2_M;
  bd_Cum->AMT3_M = Kbd_CumP.AMT3_M + Kbd_CumN.AMT3_M;
  bd_Cum->AMT4_M = Kbd_CumP.AMT4_M + Kbd_CumN.AMT4_M;
  bd_Cum->AMT5_M = Kbd_CumP.AMT5_M + Kbd_CumN.AMT5_M;
  bd_Cum->AMT6_M = Kbd_CumP.AMT6_M + Kbd_CumN.AMT6_M;
  bd_Cum->AMT7_M = Kbd_CumP.AMT7_M + Kbd_CumN.AMT7_M;
  bd_Cum->AMT8_M = Kbd_CumP.AMT8_M + Kbd_CumN.AMT8_M;
  bd_Cum->AMT9_M = Kbd_CumP.AMT9_M + Kbd_CumN.AMT9_M;
  bd_Cum->AMT10_M = Kbd_CumP.AMT10_M + Kbd_CumN.AMT10_M;
  bd_Cum->AMT11_M = Kbd_CumP.AMT11_M + Kbd_CumN.AMT11_M;
  bd_Cum->AMT12_M = Kbd_CumP.AMT12_M + Kbd_CumN.AMT12_M;

  return OK;
}

/*=============================================================================
objet :
        Ecriture d'une ligne dans le fichier en sortie (differente en fonction
        de la valeur de n_TypLin)
        Les montants (de type double) proviennent de la ligne bd_Mts. Ils sont
        transformes en chaine de caracteres et copies dans la ligne ptb_Ligne.
        C'est cette ligne qui est delivree
        
=============================================================================*/
void o_EcritLigne(int n_TypLin,T_FRAPP *bd_Mts,char **ptb_Ligne)
{
  char sz_Tmp1[30],
       sz_Tmp2[30],
       sz_Tmp3[30],
       sz_Tmp4[30],
       sz_Tmp5[30],
       sz_Tmp6[30],
       sz_Tmp7[30],
       sz_Tmp8[30],
       sz_Tmp9[30],
       sz_Tmp10[30],
       sz_Tmp11[30],
       sz_Tmp12[30],
       sz_Tmp13[30],
       sz_Tmp14[30];

  /* Conversion des montants de type double en chaines */

  sprintf(sz_Tmp1,"%-.3lf",bd_Mts->AMT1_M);
  ptb_Ligne[FRAPP_AMT1_M] = sz_Tmp1;

  sprintf(sz_Tmp2,"%-.3lf",bd_Mts->AMT2_M);
  ptb_Ligne[FRAPP_AMT2_M] = sz_Tmp2;

  sprintf(sz_Tmp3,"%-.3lf",bd_Mts->AMT3_M);
  ptb_Ligne[FRAPP_AMT3_M] = sz_Tmp3;

  sprintf(sz_Tmp4,"%-.3lf",bd_Mts->AMT4_M);
  ptb_Ligne[FRAPP_AMT4_M] = sz_Tmp4;

  sprintf(sz_Tmp5,"%-.3lf",bd_Mts->AMT5_M);
  ptb_Ligne[FRAPP_AMT5_M] = sz_Tmp5;

  sprintf(sz_Tmp6,"%-.3lf",bd_Mts->AMT6_M);
  ptb_Ligne[FRAPP_AMT6_M] = sz_Tmp6;

  sprintf(sz_Tmp7,"%-.3lf",bd_Mts->AMT7_M);
  ptb_Ligne[FRAPP_AMT7_M] = sz_Tmp7;

  sprintf(sz_Tmp8,"%-.3lf",bd_Mts->AMT8_M);
  ptb_Ligne[FRAPP_AMT8_M] = sz_Tmp8;

  sprintf(sz_Tmp9,"%-.3lf",bd_Mts->AMT9_M);
  ptb_Ligne[FRAPP_AMT9_M] = sz_Tmp9;

  sprintf(sz_Tmp10,"%-.3lf",bd_Mts->AMT10_M);
  ptb_Ligne[FRAPP_AMT10_M] = sz_Tmp10;

  sprintf(sz_Tmp11,"%-.3lf",bd_Mts->AMT11_M);
  ptb_Ligne[FRAPP_AMT11_M] = sz_Tmp11;

  sprintf(sz_Tmp12,"%-.3lf",bd_Mts->AMT12_M);
  ptb_Ligne[FRAPP_AMT12_M] = sz_Tmp12;

  sprintf(sz_Tmp13,"%-.3lf",bd_Mts->ACRES_M);
  ptb_Ligne[FRAPP_ACRES_M] = sz_Tmp13;

  sprintf(sz_Tmp14,"%-.3lf",bd_Mts->THRES_M);
  ptb_Ligne[FRAPP_THRES_M] = sz_Tmp14;

  /* Pour identifier les lignes de cumuls, on utilise un code :
      Cum Prop >= 10  :  Top=O et Contrat=1
      Cum Prop        :  Top=O et Contrat=2
      Cum Non Prop    :  Top=M
      Cum Global      :  Top=A */

  switch(n_TypLin)
  {
    case CUM_PSUP10 :
                    ptb_Ligne[FRAPP_RETNAT_CF] = CODE_TOP_CUM_P;
                    ptb_Ligne[FRAPP_CTR_NF] = CODE_CTR_CUM_PSUP10;
	            break;

    case CUM_P      :
                    ptb_Ligne[FRAPP_RETNAT_CF] = CODE_TOP_CUM_P;
                    ptb_Ligne[FRAPP_CTR_NF] = CODE_CTR_CUM_P;
	            break;

    case CUM_N      :
                    ptb_Ligne[FRAPP_RETNAT_CF] = CODE_TOP_CUM_N;
	            break;

    case CUM_GLOB   :
                    ptb_Ligne[FRAPP_RETNAT_CF] = CODE_TOP_CUM_GLOB;
	            break;
  }


  ptb_Ligne[FRAPP_FIN] = NULL;

  /* Ecriture de la ligne */
  n_WriteCols(Kp_OutputFil,ptb_Ligne,SEPARATEUR,0);

} 
