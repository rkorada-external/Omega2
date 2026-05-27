/*
[001] 27/06/2014 R. Cassis :spot:25036 Modifie compteur du NB_DETTRS_MAX (triplé)
[002] 30/07/2014 JBG :spot:25773 Replace NB_DETTRS_MAX by MAX_TDETTRS from estserv.h (50000)
*/

#ifndef __ESTC2328
#define __ESTC2328

/*
** Objet  : EST_ARCSTATGTA (Maitre)
** Entree : ESTC2328_I1
** Cle    : ( (0 champs)
*/

/** #define Kn_MaxLigDETTRS 10000 **/
//[002]
// #define NB_DETTRS_MAX 30000   /* Le nombre max de postes est fixe a 10000 [001] */

T_RUPTURE_VAR Kbd_ruptEST_ARCSTATGTA;

int n_InitEST_ARCSTATGTA(T_RUPTURE_VAR *pbd_Rupt);



int n_ActionLigneEST_ARCSTATGTA(char **pbd_InRec_Cur);


/*
** Objet  : DETTRS (Binaire)
** Entree : ESTC2328_I2
*/


FILE *Kp_DETTRS;
//[002]
T_DETTRS Ktbd_DETTRS[MAX_TDETTRS];

int n_ChargerDETTRS();


/*
** Objet  : GTAA100
** Sortie : ESTC2328_O1
*/

FILE *Kp_OutputFileGTAA100;


#endif /* __ESTC2328 */
