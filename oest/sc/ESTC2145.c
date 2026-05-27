/*[XXX] 6/04/2014 JBG :spot:25773 Modify void main declaration to int main*/

/*==============================================================================
nom de l'application          : Filtrage et Conversion de poste
nom du source                 : ESTC2145.c
revision                      : $Revision:   1.0  $
date de creation              : 03/09/1997
auteur                        : P. Louveau
references des specifications : ESIIV01F
squelette de base             : batch
------------------------------------------------------------------------------
description :   
                
                Reconduit les transactions dont le poste correspond
                a une liberation et convertit ce poste en constitution.
                 
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
        
/*---------------------------------------*/
/* inclusion de l'interface du composant */
/*---------------------------------------*/

/*---------------------------------------------*/
/* definition des constantes et macros privees */
/*---------------------------------------------*/

/*----------------------------------*/

/*----------------------*/
/* variables de travail */
/*----------------------*/


FILE            *Kp_GtInFile;                   /* fichier GT en entree */
FILE            *Kp_GtOutFile;             /* fichier GT en sortie */     

T_RUPTURE_VAR           bd_RuptGT;    /* gestion rupture */

int n_InitGT(T_RUPTURE_VAR *pbd_Rupt);
int n_ActionLigneGT(char **pbd_InRec_Cur);


 
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

        /* Ouverture des fichiers en sortie */
        if ( n_OpenFileAppl ("ESTC2145_O1","wt",&Kp_GtOutFile) == ERR )
                ExitPgm ( ERR_XX , "" );

        /* Initialisation de la varible bd_RuptGT */
        if ( n_InitGT(&bd_RuptGT) )
                ExitPgm ( ERR_XX , "" );

        /* Lancement du traitement du fichier */
        if ( n_ProcessingRuptureVar (&bd_RuptGT) == ERR )
                ExitPgm ( ERR_XX , "" );

        /* Fermeture fichier */
        if (n_CloseFileAppl ("ESTC2145_I1",&(bd_RuptGT.pf_InputFil)) == ERR)
                ExitPgm ( ERR_XX , "" );

        if (n_CloseFileAppl ("ESTC2145_O1",&Kp_GtOutFile) == ERR)
                ExitPgm ( ERR_XX , "" );

        if ( n_EndPgm () == ERR )
                ExitPgm ( ERR_XX , "" );
 
        exit(0);
}


/*==============================================================================
objet :
        fonction d'initialisation de la variable de gestion de rupture du 
        fichier maitre.
retour :
        0
==============================================================================*/
int n_InitGT(T_RUPTURE_VAR  *pbd_Rupt)
{
        DEBUT_FCT("n_InitGT");

        memset(pbd_Rupt,0,sizeof(T_RUPTURE_VAR));

        if ( n_OpenFileAppl ("ESTC2145_I1","rt",&(pbd_Rupt->pf_InputFil)))
                RETURN_VAL (ERR);

        pbd_Rupt->n_NbRupture = 0 ;
        pbd_Rupt->n_ActionLigne = n_ActionLigneGT ;

        pbd_Rupt->c_Separ = '~' ;

        RETURN_VAL (0);
}


    


/*==============================================================================
objet :
        fonction lancee pour chaque ligne du maitre

retour :
        0 ----> traitement correctement effectue
        ERR --> probleme rencontre
==============================================================================*/
int n_ActionLigneGT(char **ptb_InRec_Cur)
{
    DEBUT_FCT("n_ActionLigneGT");


    /* si poste liberation, ... */
    if (ptb_InRec_Cur[GT_ACMTRS_NT][3] == '4')
    {
        /* conversion en constitution */
        ptb_InRec_Cur[GT_ACMTRS_NT][3] = '3';

        /* ecriture dans le fichier de sortie */
        n_WriteCols(Kp_GtOutFile, ptb_InRec_Cur,'~',0);
    }
    
    RETURN_VAL (0);
}



