
/*==============================================================================
nom de l'application          : spira 37826
nom du source                 : ESTC2023.c
revision                      : $Revision: 1.4 $
date de creation              : 26/11/2015
auteur                        : S. ASKRI
references des specifications :
squelette de base             : batch
------------------------------------------------------------------------------
description : Deserialiser le fichier binaire SSDACTR


--------------------------------------------------------------------------
historique des modifications :
   <jj/mm/aaaa>   <auteur>    <description de la modification>
    
==============================================================================*/

/*--------------------------------------------------*/
/* inclusion des interfaces des composants importes */
/*--------------------------------------------------*/
#include <utctlib.h>
#include <struct.h>

/*---------------------------------------*/
/* inclusion de l'interface du composant */
/*---------------------------------------*/

int n_ChargerPilot ();


/*---------------------------------------------*/
/* definition des constantes et macros privees */
/*---------------------------------------------*/

/*----------------------*/
/* variables de travail */
/*----------------------*/

FILE  *Kp_PilotIFil,  /* Pointeur sur le fichier pilotage en entree */
      *Kp_PilotOFil;  /* Pointeur sur le fichier pilotage en sortie */
T_SSDACTR Kbd_PILOT[500];/* Fichier pilotage charge en memoire */

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

  /* ouverture des fichiers */
  if ( n_OpenFileAppl ("ESTC2023_I","rb",&Kp_PilotIFil) == ERR )          ExitPgm ( ERR_XX , "" );

  if ( n_OpenFileAppl ("ESTC2023_O1","wt",&Kp_PilotOFil) == ERR )         ExitPgm ( ERR_XX , "" );

  /* Chargement en memoire du fichier pilotage et reconduction */
   n_ChargerPilot ();

  if (n_CloseFileAppl ("ESTC2023_I",&Kp_PilotIFil))                       ExitPgm ( ERR_XX , "" );

  if (n_CloseFileAppl ("ESTC2023_O1",&Kp_PilotOFil))                      ExitPgm ( ERR_XX , "" );

  if ( n_EndPgm () == ERR )                                               ExitPgm ( ERR_XX , "" );

  exit(0) ;
}

//**********************************************************************************

int n_ChargerPilot()
{
  int n_EOF = 0;
  T_SSDACTR bd_Lu;

  DEBUT_FCT("n_ChargerPilot");

  /* Tant que la fin de fichier n'est pas atteinte,... */
  while (n_EOF == 0)
  {
    /* ... lecture d'une ligne dans le fichier. */
    if (fread(&bd_Lu,sizeof(T_SSDACTR),1,Kp_PilotIFil)<=0)
      /* Fin de fichier, mise a jour du flag */
      n_EOF = 1;
    else
    {
      //strncpy(sz_cred,bd_Lu.CRE_D,17);
      /* Ecriture en sortie */
      fprintf(Kp_PilotOFil,
        "%s~%d~%d~%d~%d~%s~%d~%d~%d~%d~%d~%d\n",      
                         bd_Lu.RETCTR_NF,
                         (int)bd_Lu.RTY_NF,
                         (int)bd_Lu.PLC_NT,
                         (int)bd_Lu.RETSEC_NF,
                         (int)bd_Lu.SSD_CF,
                         bd_Lu.CTR_NF,
                         (int)bd_Lu.UWY_NF,
                         (int)bd_Lu.UW_NT,
                         (int)bd_Lu.SEC_NF,
                         (int)bd_Lu.END_NT,
                          bd_Lu.CLISSD_NF,
                          bd_Lu.RTOSSD_CF);
    }
  }

  RETURN_VAL (0);
}