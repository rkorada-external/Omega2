/*==============================================================================
 Nom de l'application          : Loader programs V2
 Nom du source                 : ESTC3002.c
 Revision                      : $Revision: 1.16 $
 Date de creation              : 09/01/2012
 Auteur                        : gensource v2.0 (auto)
 References des specifications : ######################
 Squelette de base             : batch
------------------------------------------------------------------------------
  Description :
   Loader programs V2
------------------------------------------------------------------------------
Historique des modifications :
[01]  01/06/2012  -=Dch=-  :spot:23937 SOLVENCY II
[02]  01/06/2012  -=Dch=-  :spot:24041 SOLVENCY II
[03]  21/10/2013   Cyrille :spot:26391 Gestion des ICV
[04]  28/04/2015 Florent   :spot:26391 gestion des ICV
[05]  19/05/2016 Florent :spot:30543 on passe � 65 ann�es
[06]  26/09/2019 KBagwe : #80560 :- REQ3.3.1 - Change in CSF (CUM and ICV) pattern Upload (complement to 62221 )
[07]  31/08/2020 KBagwe	: #88995 :- REQ3.3.1 - Change in CSF (CUM and ICV) pattern Upload (complement to 62221 ) - Copy
==============================================================================*/

/*--------------------------------------------------*/
/* Inclusion des interfaces des composants importes */
/*--------------------------------------------------*/
#include <utctlib.h>
#include "ESTC3001.h"

T_RUPTURE_VAR Kbd_ruptEstBatchIN;
FILE *Kp_OutputFileEstBatchOut;
FILE *Kp_OutputFileTraceOut;

/*--------------------------------------------------*/
/* Prototype des fonctions              */
/*--------------------------------------------------*/
int n_InitEstBatchIN(T_RUPTURE_VAR *pbd_Rupt);
int n_ActionLigneEstBatchIN(char **pbd_InRec_Cur);
char* subString (const char* input, int offset, int len, int destlength);

/*---------------------------------------------*/
/* Definition des constantes et macros privees */
/*---------------------------------------------*/
char ksz_output_patternCategory[4];  // Categorie (PATCAT_CT)
char closingD[9];
char monthclosd[3];
char anAmoutOut[TAILLE_PATTERNSII_TAUX];
/*==============================================================================
 Objet :
   Point d'entree du programme

 Parametre(s) :
   int argc    : Nombre d'arguments sur la ligne de commande;
   char **argv : parametres

 Retour :
   En cas de probleme, sortie par ExitPgm(ERRCODE)
   sinon appel systeme exit(OK)
==============================================================================*/
int main(int argc, char **argv)
{
  // Initialisation des signaux
  InitSig () ;

  if (n_BeginPgm(argc, argv) == ERR) ExitPgm(ERR_XX, "Probl�me lors de l'appel de la m�thode n_BeginPGM.");

  //Initialisation du PATTYP_CT
  if (strncmp(psz_GetCharArgv(1), PATCAT_CUMULATIVE, sizeof(PATCAT_CUMULATIVE)) == 0)
    strcpy(ksz_output_patternCategory, PATCAT_CASHFLOW);
  else
    strcpy(ksz_output_patternCategory, PATCAT_INCREMENTAL);
 

  stpcpy(closingD, psz_GetCharArgv(2));
  stpcpy(monthclosd, subString (closingD, 4, 2, 3));
  
  // Ouverture des fichiers binaires et des fichiers de sortie
  if (n_OpenFileAppl("ESTC3002_O1", "wt", &Kp_OutputFileEstBatchOut)) ExitPgm(ERR_XX, "Probl�me lors de l'ouverture du fichier d'output." );
  if (n_OpenFileAppl("ESTC3002_O2", "wt", &Kp_OutputFileTraceOut)) ExitPgm(ERR_XX, "Probl�me lors de l'ouverture du fichier d'output(TRACE SEG)." );

  // Initialisation des variables de gestion de ruptures
  if (n_InitEstBatchIN(&Kbd_ruptEstBatchIN)) ExitPgm(ERR_XX, "Probl�me lors de l'ex�cution de la m�thode n_InitEstBatchIN");

  if (n_ProcessingRuptureVar(&Kbd_ruptEstBatchIN) != OK) ExitPgm(ERR_XX, "Erreur lors du traitement ligne � ligne." );

  // Fermeture des fichiers ouverts
  if (n_CloseFileAppl("ESTC3002_I1", &(Kbd_ruptEstBatchIN.pf_InputFil)))  ExitPgm(ERR_XX, "Probl�me lors de la fermeture du fichier d'input.");

  if (n_CloseFileAppl("ESTC3002_O1", &Kp_OutputFileEstBatchOut)) ExitPgm(ERR_XX, "Probl�me lors de la fermeture du fichier d'output.");
  if (n_CloseFileAppl("ESTC3002_O2", &Kp_OutputFileTraceOut)) ExitPgm(ERR_XX, "Probl�me lors de la fermeture du fichier d'output(TRACESEG)\n.");

  if (n_EndPgm() == ERR) ExitPgm(ERR_XX, "Probl�me lors de l'appel de la m�thode n_EndPgm.");

  exit(OK);
}

/*==============================================================================
 Objet :            Initialisation de la variable de gestion de rupture (Maitre)
 Parametre(s) :     Pointeur sur une structure T_RUPTURE_VAR
 Retour :           En cas de probleme retourne ERR
                    sinon retourne OK
==============================================================================*/
int n_InitEstBatchIN(T_RUPTURE_VAR  *pbd_Rupt)
{
  memset(pbd_Rupt, 0, sizeof(T_RUPTURE_VAR));

  if (n_OpenFileAppl("ESTC3002_I1", "rt", &(pbd_Rupt->pf_InputFil)))
    return ERR;

  pbd_Rupt->n_NbRupture   = 0;
  pbd_Rupt->n_ActionLigne = n_ActionLigneEstBatchIN;
  pbd_Rupt->c_Separ       = '~';

  return OK;
}

/*==============================================================================
 Objet :            Fonction lancee pour chaque ligne du Maitre
 Parametre(s) :     Pointeur sur la ligne courante
 Retour :           En cas de probleme retourne ERR
                    sinon retourne OK
==============================================================================*/
int n_ActionLigneEstBatchIN(char **ptb_InRec_Cur)
{
  char   sz_annees[PATTERNSII_ANNEES][TAILLE_PATTERNSII_TAUX], sz_uwy[5], sz_totaux[TAILLE_PATTERNSII_TAUX], sz_uwy_1[5];     //[06]
  double d_anneesIN[PATTERNSII_ANNEES];
  double d_anneesCalc[PATTERNSII_ANNEES];

  double TOTAUX = 0;
  double taux1, taux2, taux3, d_annee;
  double arrondi = 0;
  int    i_uwy_nf;
  int    i, i_an;
  int    y = 0;
  int    BALSHEY_NF = 0; // Ann�e Bilan

  DEBUT_FCT("n_ActionLigneEstBatchIN");

  BALSHEY_NF = atoi(ptb_InRec_Cur[PAT_BALSHEY_NF]);
  memset(sz_annees, 0, sizeof(sz_annees));
  // Modif du 10/09/2012 : on conserve tous les taux

  //on modifie l'enregistrement pour le faire pointer sur les donn�es � �crire
  for (i_an = 0 ; i_an < PATTERNSII_ANNEES; i_an++)
  {
    //sauvegardes des taux en entr�e
    d_anneesIN[i_an] = atof(ptb_InRec_Cur[PAT_AN1 + i_an]);
    //et on change pour le mettre sur les valeurs calcul�es dans cette fonction
    ptb_InRec_Cur[PAT_AN1 + i_an] = sz_annees[i_an];
  }

  //[03]  La PATCAT_CT (pattern category) n'est plus mise en dur � CSF, mais d�pend de la categorie (PATCAT_CT) d'origine (CUM ou ICV)
  ptb_InRec_Cur[PAT_PATCAT_CT] = ksz_output_patternCategory;
  ptb_InRec_Cur[PAT_UWY_NF] = sz_uwy;
  ptb_InRec_Cur[PAT_TOTAUX] = sz_totaux;

  /* Pour chacunes des ann�es pour lesquelles il faut g�n�rer une ligne en sortie */
  for (i_uwy_nf = BALSHEY_NF - PATTERNSII_ANNEES + 1; i_uwy_nf <= BALSHEY_NF + 1; i_uwy_nf++)
  {
    //---------------------------------------------------
    // Calcul de Taux3 = Taux {BALSHEY_NF - i_uwy_nf}
    //---------------------------------------------------
    i = BALSHEY_NF - i_uwy_nf;
    // Si l'indice du taux recherch� est invalide alors on prend 0
    if ((i < 0 ) || (i > PATTERNSII_ANNEES))
    {
      taux3 = 0.0;
    }
    // sinon on prend le taux correspondant en entr�e
    else
    {
      taux3 = d_anneesIN[i];    // 1 <= i <= PATTERNSII_ANNEES mais i est indic� de 0 � PATTERNSII_ANNEES - 1
      // Pour chaque ann�e de l'UWY_NF courant
      for (i_an = 1; i_an <= PATTERNSII_ANNEES; i_an++)
      {
        // Pour l'ann�e courante i_an, le taux recherch� vaut: (Taux1 - Taux2) / (1 - Taux3)
        // O�   Taux1 = Taux {BALSHEY_NF - i_uwy_nf + i_an)}         = Taux {Ann�e Bilan - UWY_NF + Age (= i de colonne AN i)}
        //      Taux2 = Taux {BALSHEY_NF - i_uwy_nf + i_an - 1}      = Taux {Ann�e Bilan - UWY_NF + Age (= i de colonne AN i) - 1}
        //      Taux3 = Taux {BALSHEY_NF - i_uwy_nf}                 = Taux {Ann�e Bilan - UWY_NF}
        // Initialisation des taux interm�diaires
        taux1 = 0.0;
        taux2 = 0.0;

        //---------------------------------------------------
        // Calcul de Taux1 = Taux {BALSHEY_NF - i_uwy_nf + i_an)}
        //---------------------------------------------------
        i = BALSHEY_NF  - i_uwy_nf + i_an;
        //i va de 1 jusqu'� PATTERNSII_ANNEES et donc dans l'enregistrement le pointeur devra �tre PAT_AN1 + i - 1
        // Si l'indice du taux recherch� est invalide alors on prend 0
        if ((i < 1) || (i > PATTERNSII_ANNEES))
        {
          taux1 = 0.0;
        }
        else
        {
          // sinon on prend le taux correspondant en entr�e
          taux1 = d_anneesIN[i];
          if ((taux1 == 1) && (d_anneesIN[i - 1] == 1))
          {
            for (y = i_an - 1; y < PATTERNSII_ANNEES; y++)
            {
              strcpy(sz_annees[y],"0");
            }
            break; // on sort de la boucle
          }
        }
        //------------------------------------------------------
        // Calcul de Taux2 = Taux {BALSHEY_NF - i_uwy_nf + i_an - 1}
        //------------------------------------------------------
        i --; //BALSHEY_NF - i_uwy_nf + i_an - 1;

        // Si l'indice du taux recherch� est invalide alors on prend 0
        if ((i < 0) || (i > PATTERNSII_ANNEES))
        {
          taux2 = 0.0;
        }
        // sinon on prend le taux correspondant en entr�e
        else
        {
          taux2 = d_anneesIN[i];
        }

        // gestion du max des taux
        if (taux1 > 1.0 ) taux1 = 1.0;
        if (taux2 > 1.0 ) taux2 = 1.0;
        if (taux3 > 1.0 ) taux3 = 1.0;

        if (taux3 != 1)
        {
          d_annee = (taux1 - taux2) / (1 - taux3);
          if (d_annee != 0 )
          {
            if (d_annee < 0)
            {
              arrondi = (long) ((d_annee * 100000000) - 0.5) ;
            }
            else
              arrondi = (long) ((d_annee * 100000000) + 0.5) ;
          }
          else
            arrondi = 0;

          snprintf(sz_annees[i_an - 1], TAILLE_PATTERNSII_TAUX, "%.8f", (arrondi != 0) ? (double) (arrondi / 100000000 ) : 0);
          if (arrondi !=0) TOTAUX += (arrondi / 100000000);
        }
        else
        {
          strcpy(sz_annees[i_an - 1],"0");
        }
      }
    }
    // Ecriture de la ligne courante
    if (TOTAUX != 0)
    {
      sprintf(sz_uwy, "%d", i_uwy_nf);
      snprintf(sz_totaux, TAILLE_PATTERNSII_TAUX, "%.8f", TOTAUX);
      n_WriteCols(Kp_OutputFileEstBatchOut, ptb_InRec_Cur, SEPARATEUR, 0 );
	  //printf("monthclosd : %s \n",monthclosd);
	if (i_uwy_nf == BALSHEY_NF){                                  //[06]
  		  sprintf(sz_uwy_1, "%d", i_uwy_nf+1);
	      ptb_InRec_Cur[PAT_UWY_NF] =sz_uwy_1;
	      TOTAUX = 0;
	      arrondi = 0;

          for (i_an = PATTERNSII_ANNEES-1; i_an >=0; i_an--)
          {
			    if (d_anneesIN[i_an] >= 1.0 ) {
					d_anneesIN[i_an] = 1.0;
				}
				if (d_anneesIN[i_an-1] >= 1.0 ) {
					d_anneesIN[i_an-1] = 1.0;
				}
				
                if (i_an != 0)
                    d_anneesCalc[i_an] = d_anneesIN[i_an]-d_anneesIN[i_an-1];
                else
                    d_anneesCalc[i_an] = d_anneesIN[i_an];

              // printf("d_anneesCalc[%d] : %f \n", i_an, d_anneesCalc[i_an]);
                d_annee = d_anneesCalc[i_an];
                 if (d_annee != 0 )
                 {
                   if (d_annee < 0)
                   {
                     arrondi = (long) ((d_annee * 100000000) - 0.5) ;
                   }
                   else
                     arrondi = (long) ((d_annee * 100000000) + 0.5) ;
                 }
                 else
                   arrondi = 0;

                 strcpy(anAmoutOut,"0");
                 if (arrondi != 0){
                  	snprintf(anAmoutOut, TAILLE_PATTERNSII_TAUX, "%.8f", (double) (arrondi / 100000000 ) );
                 }
				 	strcpy( ptb_InRec_Cur[i_an+PAT_AN1],anAmoutOut);
				 	if (arrondi !=0) TOTAUX += (arrondi / 100000000);
         }
          snprintf(anAmoutOut, TAILLE_PATTERNSII_TAUX, "%.8f", TOTAUX);
          ptb_InRec_Cur[PAT_TOTAUX] =  anAmoutOut;
          n_WriteCols(Kp_OutputFileEstBatchOut, ptb_InRec_Cur, SEPARATEUR, 0 );
      } 
    }
    memset(sz_annees, 0, sizeof(sz_annees));
    TOTAUX = 0;
    arrondi = 0;
  }

  fprintf(Kp_OutputFileTraceOut, "%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s\n",
          ptb_InRec_Cur[PAT_CRE_D], //CLODAT_D
          PER_CF_NEW,
          ptb_InRec_Cur[PAT_SSD_CF],
          ptb_InRec_Cur[PAT_SEG_NF],
          ptb_InRec_Cur[PAT_LOB_CF],
          ptb_InRec_Cur[PAT_CUR_CF],
          ptb_InRec_Cur[PAT_NORME_CF],
          ptb_InRec_Cur[PAT_SEGNAT_CT],
          ptb_InRec_Cur[PAT_PATCAT_CT],
          ptb_InRec_Cur[PAT_PATTYP_CT],
          ptb_InRec_Cur[PAT_PATTERN_ID],
          "",
          "",
          ptb_InRec_Cur[PAT_PATTERN_ID],
          ptb_InRec_Cur[PAT_CREUSR_CF],
          ptb_InRec_Cur[PAT_CRE_D]);
  return OK;
}

/*===========================================================================
  Objet : substring based on offset and length
 				e.g
 					subString('11140000',0,1,dest)  = 1
              	  	subString('11140000',2,2,dest)  = 14
  Retour :
             char*
===========================================================================*/
char* subString (const char* input, int offset, int len,  int destlength)
{
 // char* dest = "";
  char *dest = (char*) malloc(destlength); 

  int input_len = strlen (input);

  if (offset + len > input_len)
  {
	 printf("ERROR : subctring - (offset + len) is greator then input len ");
     return NULL;
  }
 // memset(dest, '\0', destlength);
  strncpy (dest, input + offset, len);
  dest[destlength-1] = '\0';
  //printf("dest : %s \n", dest);
  return dest;
}
