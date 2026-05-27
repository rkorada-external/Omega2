/*[XXX] 6/04/2014 JBG :spot:25773 Modify void main declaration to int main*/

/*==============================================================================
nom de l'application          : 
nom du source                 : ESTC7601.c
revision                      : $Revision:   1.1  $
date de creation              : 10/1997
auteur                        : KUHNA  (C.G.I.)
references des specifications : 
squelette de base             : batch
------------------------------------------------------------------------------
description :
	Passage en partie simple et conversion du GT en vue de l'edition
      de l'etat de balance technique	

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

/*---------------------------------------------*/
/* definition des constantes et macros privees */
/*---------------------------------------------*/

/*---------------------------------------*/
/* inclusion de l'interface du composant */
/*---------------------------------------*/

/*----------------------*/
/* variables de travail */
/*----------------------*/

int Kn_Annee;                /* Annee de periode de compte 
                                (parametre de la chaine) */

T_RUPTURE_VAR Kbd_Rupt;

FILE	*Kp_OutFil,		 /* Fichier en sortie */
				 /* GT eclate */
        *Kp_InputFilExc;         /* Fichier des taux de conversions */

/*---------------------------*/
/* Declaration des fonctions */
/*---------------------------*/

int n_InitGTEclat(T_RUPTURE_VAR  *pbd_Rupt);
int n_ActionLigneGTEclat(char **ptb_InRec_Cur);

/*==============================================================================
objet :
   point d'entree du programme

retour :
   En cas de probleme, la sortie s'effectue par la fonction ExitPgm().
   Sinon, par l'appel systeme exit()
==============================================================================*/
int main(int argc ,char *argv[])
{

  /* Alimentation du nom en clair du programme */
  Gbd_Tech.psz_PgmLabel = "Passage en partie simple et conversion GT";

  /* Initialisation des signaux */
  InitSig ();

  if (n_BeginPgm(argc,argv) == ERR)
    ExitPgm (ERR_XX , "");

                                /* Recuperation de l'annee de compte */
  Kn_Annee=n_GetIntArgv(1);
	                         /* Ouverture du fichier en entree 
                                    des cours de change FCURQUOT */
  if (n_OpenFileAppl("ESTC7601_I2","rb",&Kp_InputFilExc) == ERR)
    ExitPgm(ERR_XX ,"") ;

  n_InitGTEclat(&Kbd_Rupt);

  /* ouverture du fichier en sortie */
  if (n_OpenFileAppl("ESTC7601_O1","wt",&Kp_OutFil) == ERR )
  ExitPgm ( ERR_XX , "" );
  
  /* Traitement principal */
  if (n_ProcessingRuptureVar(&Kbd_Rupt) == ERR)
    ExitPgm(ERR_XX,"");

  /* fermeture des fichiers */
  if (n_CloseFileAppl("ESTC7601_I2",&Kp_InputFilExc) == ERR)
    ExitPgm(ERR_XX,"");

  if (n_CloseFileAppl("ESTC7601_I1",&(Kbd_Rupt.pf_InputFil)) == ERR)
    ExitPgm (ERR_XX,"");

  if (n_CloseFileAppl("ESTC7601_O1",&Kp_OutFil) == ERR)
    ExitPgm (ERR_XX ,"");

  if (n_EndPgm() == ERR)
    ExitPgm (ERR_XX , "");

  exit(OK) ;
}

/*=============================================================================
 objet: Initialisation Rupture : 1 rupture sur filiale/etablissement/Lob
        Chaque rupture correspond a l'edititon d'une GTEclat nouvelle 
=============================================================================*/
int n_InitGTEclat(T_RUPTURE_VAR  *pbd_Rupt)
{
  DEBUT_FCT("n_InitGTEclat");

  memset(pbd_Rupt,0,sizeof(T_RUPTURE_VAR));

  /* Ouverture du fichier maitre */
  if (n_OpenFileAppl ("ESTC7601_I1","rt",&(pbd_Rupt->pf_InputFil)))
  RETURN_VAL (ERR);

  /* Gestion de rupture */
  pbd_Rupt->n_NbRupture = 0;

  /* Fonction executee pour chaque ligne : */
  pbd_Rupt->n_ActionLigne = n_ActionLigneGTEclat;

  /* Separateur utilise dans le fichier en entree */
  pbd_Rupt->c_Separ = SEPARATEUR ;

  RETURN_VAL (0);
}

/*=============================================================================
 objet: Action sur chacune des lignes  : 
         - Diviser chaque ligne du GT en deux lignes ( de maniere differente
           si la ligne initiale correspond a une acceptation ou une retro )
         - Ecriture de ces deux lignes dans le fichier en sortie
=============================================================================*/
int n_ActionLigneGTEclat(char **ptb_InRec_Cur)
{
  double d_Taux;     /* Taux de conversion */
  int  n_i;          /* Indice */
  char MsgAno[200];  /* Message anomalie */
   double VAR_AMT;
   char sz_tmp[30];
   double VAR_RETAMT;
   char sz_tmpret[30];


  DEBUT_FCT("n_ActionLigneGTEclat");

                             /* si ligne retrocession */
  if (   (*(ptb_InRec_Cur[GT_TRNCOD_CF]) != '1')
      && (*(ptb_InRec_Cur[GT_TRNCOD_CF]) != '3') )
    {
      /* l'exercice est l'exercice retro */
/*       ptb_InRec_Cur[GT_UWY_NF] = ptb_InRec_Cur[GT_RTY_NF]; */
/* Pour le taux on met Kn Annee et non UWY_NF                 */

      /* dans monnaie acceptation, on met monnaie retro */
      ptb_InRec_Cur[GT_CUR_CF] = ptb_InRec_Cur[GT_RETCUR_CF];

      /* dans montant acceptation, on copie montant retro */
      strcpy(ptb_InRec_Cur[GT_AMT_M],ptb_InRec_Cur[GT_RETAMT_M]);
    }

  /* Recherche du taux de conversion */ 
   d_Taux = d_GetTaux(Kp_InputFilExc,
                      (char) atoi(ptb_InRec_Cur[GT_SSD_CF]),
		      Kn_Annee,
                      ptb_InRec_Cur[GT_CUR_CF], 
		      0);
  

  if (d_Taux == -1)          /* Taux de conversion inexistant */
    {                        /* Anomalie */
       sprintf(MsgAno,"The conversion rate between the %s currency and the currency of subsidiary %s is not defined for %d\n",
               ptb_InRec_Cur[GT_CUR_CF],
               ptb_InRec_Cur[GT_SSD_CF],
               Kn_Annee);
       n_WriteAno(MsgAno);
       return OK;
    }
                             /* Taux de conversion trouve */
  /* Mise sous chaine du montant qui a ete converti */
/*  sprintf(ptb_InRec_Cur[GT_RETAMT_M],
          "%-.3lf",
          atof(ptb_InRec_Cur[GT_AMT_M]) * d_Taux);
*/
   VAR_RETAMT= atof(ptb_InRec_Cur[GT_AMT_M])*d_Taux;
   sprintf(sz_tmpret,"%-.3lf",VAR_RETAMT);
   ptb_InRec_Cur[GT_RETAMT_M]= sz_tmpret;



  /* Ecriture dans le fichier en sortie : 1ere ligne */
  n_WriteCols(Kp_OutFil,ptb_InRec_Cur,SEPARATEUR,7,
              GT_SSD_CF,
              GT_ESB_CF,
              GT_BALSHEY_NF,
              GT_TRNCOD_CF,
              GT_CUR_CF,
              GT_AMT_M,
              GT_RETAMT_M);


  /* Preparation de la 2de ligne :
      on met la contre partie dans le poste comptable
      et les montants sont multiplies par -1 */

  ptb_InRec_Cur[GT_TRNCOD_CF] = ptb_InRec_Cur[GT_DBLTRNCOD_CF];

/* dans certains cas l affectation se passe mal : du coup on passe */
/* par un variable temporaire  */
/*  sprintf(ptb_InRec_Cur[GT_AMT_M],
         "%-.3lf",
         atof(ptb_InRec_Cur[GT_AMT_M]) * (-1)); 

  sprintf(ptb_InRec_Cur[GT_RETAMT_M],
          "%-.3lf",
          atof(ptb_InRec_Cur[GT_RETAMT_M]) * (-1)); 
*/
      VAR_AMT= -atof(ptb_InRec_Cur[GT_AMT_M]);
      sprintf(sz_tmp,"%-.3lf",VAR_AMT);
      ptb_InRec_Cur[GT_AMT_M]= sz_tmp;

      VAR_RETAMT= -atof(ptb_InRec_Cur[GT_RETAMT_M]);
      sprintf(sz_tmpret,"%-.3lf",VAR_RETAMT);
      ptb_InRec_Cur[GT_RETAMT_M]= sz_tmpret;



  /* Ecriture dans le fichier en sortie : 2ere ligne */
  n_WriteCols(Kp_OutFil,ptb_InRec_Cur,SEPARATEUR,7,
              GT_SSD_CF,
              GT_ESB_CF,
              GT_BALSHEY_NF,
              GT_TRNCOD_CF,
              GT_CUR_CF,
              GT_AMT_M,
              GT_RETAMT_M);

  RETURN_VAL (0);
}
