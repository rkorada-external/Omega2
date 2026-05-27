/*==============================================================================
 Nom de l'application          : OMEGA/Estimation
 Nom du source                 : ESTC2328.c
 Revision                      : $Revision: 1.2 $
 Date de creation              : 02/01/2000
 Auteur                        : O.Arik
 References des specifications : ######################
 Squelette de base             : batch
------------------------------------------------------------------------------
  Description :
   Generation de GTAA100

------------------------------------------------------------------------------
 Historique des modifications :
   <jj/mm/aaaa>   <auteur>    <description de la modification>
    27/03/2008   J. Ribot    SPOT 15219  ASE15 : recompilation des programmes C
       ...           ...            ...              ...
[001] 30/07/2014 JBG :spot:25773 Replace NB_DETTRS_MAX by MAX_TDETTRS from estserv.h (50000)
==============================================================================*/

/*--------------------------------------------------*/
/* Inclusion des interfaces des composants importes */
/*--------------------------------------------------*/

#include <util.h>
#include "struct.h"
#include "estserv.h"


/*---------------------------------------*/
/* Inclusion de l'interface du composant */
/*---------------------------------------*/

#include "ESTC2328.h"

/*---------------------------------------------*/
/* Definition des constantes et macros privees */
/*---------------------------------------------*/
/*---------------------------------------------*/


int n_RechTrn(char *sz_trn);

/*----------------------*/
/* variables de travail */
/*----------------------*/
int             Kn_NbLigDettrs=0 ;      /* nombre de lignes du tableau Ktbd_Dettrs */

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
  /* Initialisation des signaux */
  InitSig () ;

  if (n_BeginPgm(argc, argv) == ERR) ExitPgm(ERR_XX, "");

  /* Initialisation des variables de gestion de ruptures */
  if (n_InitEST_ARCSTATGTA(&Kbd_ruptEST_ARCSTATGTA)) ExitPgm(ERR_XX, "");

  /* Ouverture des fichiers binaires et des fichiers de sortie */
  if (n_OpenFileAppl("ESTC2328_I2", "rb", &Kp_DETTRS) == ERR) ExitPgm(ERR_XX ,"");
  if (n_OpenFileAppl("ESTC2328_O1", "wt", &Kp_OutputFileGTAA100) == ERR) ExitPgm(ERR_XX ,"");

  if( (Kn_NbLigDettrs = n_ChargerDETTRS( ))==-1)
       ExitPgm ( ERR_XX , "" );


  /* Lancement du traitement du fichier Maitre */
  if (n_ProcessingRuptureVar(&Kbd_ruptEST_ARCSTATGTA) == ERR) ExitPgm(ERR_XX, "");

  /* Fermeture des fichiers ouverts */
  if (n_CloseFileAppl("ESTC2328_I1", &(Kbd_ruptEST_ARCSTATGTA.pf_InputFil)) == ERR) ExitPgm(ERR_XX, "");
  if (n_CloseFileAppl("ESTC2328_I2", &Kp_DETTRS) == ERR) ExitPgm(ERR_XX, "");

  if (n_CloseFileAppl("ESTC2328_O1", &Kp_OutputFileGTAA100)) ExitPgm(ERR_XX, "");

  if (n_EndPgm() == ERR) ExitPgm(ERR_XX, "");

  exit(OK);
}


/*==============================================================================
 Objet :
   Initialisation de la variable de gestion de rupture (Maitre)

 Parametre(s) :
   Pointeur sur une structure T_RUPTURE_VAR

 Retour :
   En cas de probleme retourne ERR
   sinon retourne OK
==============================================================================*/
int n_InitEST_ARCSTATGTA(T_RUPTURE_VAR  *pbd_Rupt)
{
  memset(pbd_Rupt,0,sizeof(T_RUPTURE_VAR));

  if (n_OpenFileAppl("ESTC2328_I1","rt", &(pbd_Rupt->pf_InputFil)))
    return ERR;

  pbd_Rupt->n_NbRupture = 0;
  pbd_Rupt->n_ActionLigne = n_ActionLigneEST_ARCSTATGTA;
  pbd_Rupt->c_Separ = '~';

  return OK;
}


/*==============================================================================
 Objet :
   Fonction lancee pour chaque ligne du Maitre

 Parametre(s) :
   Pointeur sur la ligne courante

 Retour :
   En cas de probleme retourne ERR
   sinon retourne OK
==============================================================================*/
int n_ActionLigneEST_ARCSTATGTA(char **ptb_InRec_Cur)
{
int n_indtrn;

char Ksz_mes[151] = "";/* libelle message ecrit dans fichier ano ou log      */

n_indtrn = n_RechTrn(ptb_InRec_Cur[GT_TRNCOD_CF]);

       if (n_indtrn < 0)
       {
         n_WriteAno(" Poste comptable non trouve ");
         sprintf(Ksz_mes,"CTR  %s, UWY %s, CLM %s, TRNCOD %s \n",
                     ptb_InRec_Cur[GT_CTR_NF],
                     ptb_InRec_Cur[GT_UWY_NF],
                     ptb_InRec_Cur[GT_CLM_NF],
                     ptb_InRec_Cur[GT_TRNCOD_CF]);
          n_WriteAno(Ksz_mes);
        }

       else
       {
	/* Recuperation des mvts comptables acceptation */

       	 if(
        	 (ptb_InRec_Cur[GT_TRNCOD_CF][0]=='1'||ptb_InRec_Cur[GT_TRNCOD_CF][0]=='3')
               	 &&
               	 Ktbd_DETTRS[n_indtrn].TRSTYP_CT==1
           )
       	 n_WriteCols(Kp_OutputFileGTAA100,ptb_InRec_Cur, '~', 0);

	}

  return OK;
}

/*==============================================================================
objet:
        Lit le fichier binaire des postes comptable et les charge en memoire

==============================================================================*/

int n_ChargerDETTRS()
{
  int i = 0 ;

  DEBUT_FCT("n_ChargerDETTRS");

  while (fread(&Ktbd_DETTRS[i], sizeof(T_DETTRS), 1, Kp_DETTRS) == 1)
    {
        i += 1 ;
//[001]
        if ( i == MAX_TDETTRS ){
                n_WriteAno("max DETTRS atteint \n");
                /*printf( " max DETTRS atteint " );*/ return (-1 )  ;
        }

    }

  RETURN_VAL(i);
}

/*==============================================================================
objet :
        fonction de recherche du trncod
retour :
        0               ---> Pas de rupture
        < 0     ---> On n'est pas arrive au bloc synchrone
        > 0     ---> On a depasse le bloc synchrone
==============================================================================*/
int n_RechTrn(char *sz_trn)
{
        int i;

        DEBUT_FCT("n_RechTrn");


        for ( i = 0; i <  Kn_NbLigDettrs ; i++ )
        {
                if ( strcmp( sz_trn, Ktbd_DETTRS[i].DETTRS_CF ) == 0) RETURN_VAL(i); ;
        }

        RETURN_VAL(-1);
}

