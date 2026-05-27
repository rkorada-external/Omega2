/*==============================================================================
Nom de l'application          : Filtre du fichier XADPERICASE pour eliminer les
                                affaires en retrocession interne
Nom du source                 : ESTM1002.c
Revision                      : $Revision: 1.2 $
Date de creation              : 30/07/1997
Auteur                        : CGI
References des specifications :
Squelette de base             : batch
------------------------------------------------------------------------------
Description :
  Filtre du fichier XADPERICASE pour eliminer les affaires en retrocession
  interne
  En entree : fichier XADPERICASE,
  En sortie : fichier XADPERICASE filtre.
------------------------------------------------------------------------------
Historique des modifications :
   <jj/mm/aaaa>   <auteur>    <description de la modification>
    09/08/98      M.HA-THUC   Suppression du filtre sur la retro interne
				et rajout d'un filtre sur le code origine

    06/10/98      M.HA-THUC   Filtre supplementaire. On ne conserve que les contrats non termines.
    22/11/02      O.GIRAUX    MOD03: Non prise en compte de UWORG=253
    23/12/2003    O.GIRAUX    MOD04: reecriture du test sur UWORG pour ne pas envoyer en sortie certaines lignes
    19/04/2004    M.DJELLOULI MOD05 : Exclusion des Modification MOD04
    13/10/2005    J.Ribot     MOD06: SPOT 11507 reecriture de la fonction  ==>   n_ActionLigneRupture
                                      modification du test pour ecriture d'un 2eme fichier perimetre ne contenant
                                      que les traites terminé (PER_SECACCSTS_CT = 9)
    07/04/2006    J.Ribot     MOD06: SPOT 11507 positionnement LOSCOREXI_B = 0 pour les traites terminés
    27/03/2008   J. Ribot    SPOT 15219  ASE15 : recompilation des programmes C
==============================================================================*/

/*--------------------------------------------------*/
/* Inclusion des interfaces des composants importes */
/*--------------------------------------------------*/

#include <utctlib.h>
#include <stdarg.h>
#include "struct.h"


/*----------------------*/
/* Variables de travail */
/*----------------------*/

FILE 		   *Kp_OutputFile; /* Pointeur sur le fichier de sortie */
FILE 		   *Kp_OutputFile2; /* Pointeur sur le fichier de sortie2 traites terminés (MOD06)  */
T_RUPTURE_VAR  	   *pbd_Rupture;   /* Pointeur sur la structure de la rupture */


/*-----------------------------*/
/* Fonctions du fichier maitre */
/*-----------------------------*/

int n_InitRupture	   (T_RUPTURE_VAR  *pbd_Rupture);
int n_ActionLigneRupture   (char *ptsz_LigneCour[]);


/**************************************************************************/
/*** Objet : Filtrage du fichier XADPERICASE			***/
/***									***/
/*** Nom : main		     						***/
/***									***/
/*** Parametres:							***/
/***	i argc : nombre de parametres					***/
/***	i argv : tableau de pointeurs sur les parametres		***/
/***									***/
/*** Retour:								***/
/***	OK si pas d'erreur,						***/
/***	ERR si erreur.							***/
/**************************************************************************/

int main(
   int argc,
   char *argv[]
)
{
   pbd_Rupture=malloc(sizeof(T_RUPTURE_VAR));

/* Initialisation des signaux */
   InitSig();

   if (n_BeginPgm(argc, argv) == ERR) {
      ExitPgm(ERR_XX , "Erreur appel fonction n_BeginPgm");
   }

/* Ouverture du fichier de sortie */
   if (n_OpenFileAppl("ESTM1002_O1", "wt", &Kp_OutputFile) == ERR) {
      ExitPgm(ERR_XX , "Erreur appel fonction n_OpenFileAppl");
   }
// MOD06
   if (n_OpenFileAppl("ESTM1002_O2", "wt", &Kp_OutputFile2) == ERR) {
      ExitPgm(ERR_XX , "Erreur appel fonction n_OpenFileAppl");
   }

/* Initialisation de la structure de rupture */
   if (n_InitRupture(pbd_Rupture) == ERR) {
      ExitPgm(ERR_XX , "Erreur appel fonction n_InitRupture");
   }

/* Lancement du traitement du fichier maitre */
   if (n_ProcessingRuptureVar(pbd_Rupture) == ERR) {
      ExitPgm(ERR_XX, "Erreur appel fonction n_ProcessingRuptureVar");
   }

   if (n_CloseFileAppl("ESTM1002_I1", &(pbd_Rupture->pf_InputFil)) == ERR) {
      ExitPgm(ERR_XX, "Erreur appel fonction n_CloseFileAppl");
   }

   if (n_CloseFileAppl("ESTM1002_O1", &Kp_OutputFile) == ERR) {
      ExitPgm(ERR_XX , "Erreur appel fonction n_CloseFileAppl");
   }

//MOD06
   if (n_CloseFileAppl("ESTM1002_O2", &Kp_OutputFile2) == ERR) {
      ExitPgm(ERR_XX , "Erreur appel fonction n_CloseFileAppl");
   }


   if (n_EndPgm() == ERR) {
      ExitPgm(ERR_XX, "Erreur appel fonction n_EndPgm");
   }

   free(pbd_Rupture);
   exit(OK);
}




/**************************************************************************/
/*** Objet : initialisation de la structure de rupture			***/
/***									***/
/*** Nom : n_InitRupture     						***/
/***									***/
/*** Parametres:							***/
/***	i pbd_Rupture : pointeur sur la structure de rupture		***/
/***									***/
/*** Retour:								***/
/***	OK si pas d'erreur,						***/
/***	ERR si erreur.							***/
/**************************************************************************/

int n_InitRupture(
   T_RUPTURE_VAR *pbd_Rupture
)
{
   DEBUT_FCT("n_InitRupture");
   memset(pbd_Rupture, 0, sizeof(T_RUPTURE_VAR));

/* Ouverture du fichier maitre */
   if (n_OpenFileAppl("ESTM1002_I1", "rt", &(pbd_Rupture->pf_InputFil)) == ERR) {
      RETURN_VAL(ERR);
   }
   pbd_Rupture->n_ActionLigne=n_ActionLigneRupture;
   pbd_Rupture->c_Separ= '~';

   RETURN_VAL(OK);
}


/**************************************************************************/
/*** Objet : fonction lancee pour chaque ligne du fichier maitre	***/
/***									***/
/*** Nom : n_ActionLigneRupture						***/
/***									***/
/*** Parametres:							***/
/***	i ptsz_LigneCour : pointeur sur la ligne courante		***/
/***									***/
/*** Retour:								***/
/***	OK si pas d'erreur,						***/
/***	ERR si erreur.							***/
/**************************************************************************/

int n_ActionLigneRupture(char *ptsz_LigneCour[])
{
   DEBUT_FCT("n_ActionLigneRupture");

   /*****************************************************/
   /* Modifs du 09/06/98 - M.HA-THUC			*/
   /* Suppression du filtre sur la retro interne ( fait	*/
   /* ulterieurement dans la chaine ), et rajout d'un   */
   /* filtre sur le code origine			*/
   /*****************************************************/

   if (
//        atoi( ptsz_LigneCour[PER_SECACCSTS_CT] ) != 9 &&  /* MOD06, TEST deplacé
        atoi( ptsz_LigneCour[PER_UWORG_CF] ) != 253 &&   /* MOD03, non prise en compte des UWORG=253 */
        atoi( ptsz_LigneCour[PER_UWORG_CF] ) != 255 &&
        atoi( ptsz_LigneCour[PER_UWORG_CF] ) != 13
      )
   {
      if ( atoi( ptsz_LigneCour[PER_SECACCSTS_CT] ) != 9  )
         {
              n_WriteCols(Kp_OutputFile, ptsz_LigneCour,'~', 0);
         }
      else
         {
//              ptsz_LigneCour[PER_LOSCOREXI_B] = 0;
              strcpy(ptsz_LigneCour[PER_LOSCOREXI_B],"0");
              n_WriteCols(Kp_OutputFile2, ptsz_LigneCour,'~', 0);
         }
    }
   RETURN_VAL(OK);
}


//// MOD06 SAVE ANCIENNE FONCTION
//
//int n_ActionLigneRupture(char *ptsz_LigneCour[])
//{
//   DEBUT_FCT("n_ActionLigneRupture");
//
//   /*****************************************************/
//   /* Modifs du 09/06/98 - M.HA-THUC			*/
//   /* Suppression du filtre sur la retro interne ( fait	*/
//   /* ulterieurement dans la chaine ), et rajout d'un   */
//   /* filtre sur le code origine			*/
//   /*****************************************************/
//
//   if (
//        atoi( ptsz_LigneCour[PER_SECACCSTS_CT] ) != 9 &&
//        atoi( ptsz_LigneCour[PER_UWORG_CF] ) != 253 &&   /* MOD03, non prise en compte des UWORG=253 */
//        atoi( ptsz_LigneCour[PER_UWORG_CF] ) != 255 &&
//        atoi( ptsz_LigneCour[PER_UWORG_CF] ) != 13
//
//       /* MOD05
//
//       atoi( ptsz_LigneCour[PER_UWORG_CF] ) != 79 &&   mis en commentaire JR 06/10/2003 */
//        /*
//        //MOD04 OG 23/12/2003 Reecriture du test qui suit, pour ne pas envoyer en sortie les lignes répondant aux critères ci-dessous
//        &&
//        !(                // ATTENTION, ON A UN ! <=> NOT DEVANT LA PARENTHESE
//            (
//                atoi( ptsz_LigneCour[PER_UWORG_CF] ) == 60 ||
//                atoi( ptsz_LigneCour[PER_UWORG_CF] ) == 61 ||
//                atoi( ptsz_LigneCour[PER_UWORG_CF] ) == 67 ||
//                atoi( ptsz_LigneCour[PER_UWORG_CF] ) == 72
//            )
//            &&
//            (
//                ptsz_LigneCour[PER_CTR_NF][2] == 'U' ||  ptsz_LigneCour[PER_CTR_NF][2] == 'W'
//            )
//	         &&
//            (
//                atoi( ptsz_LigneCour[PER_SSD_CF] ) == 1 ||
//                atoi( ptsz_LigneCour[PER_SSD_CF] ) == 2 ||
//                atoi( ptsz_LigneCour[PER_SSD_CF] ) == 5 ||
//                atoi( ptsz_LigneCour[PER_SSD_CF] ) == 6
//            )
//        )
//
//       &&
//        !(                 //ATTENTION, ON A UN ! <=> NOT DEVANT LA PARENTHESE
//          atoi( ptsz_LigneCour[PER_UWORG_CF] ) == 54 &&
//          atoi( ptsz_LigneCour[PER_SSD_CF] ) == 20
//        )
//       // Fin MOD04
//
//
//       */ // FIN MOD05
//
//      )
//   {
//      n_WriteCols(Kp_OutputFile, ptsz_LigneCour,'~', 0);
//   }
//
//   RETURN_VAL(OK);
//}
