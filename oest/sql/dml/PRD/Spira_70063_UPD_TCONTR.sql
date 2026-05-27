

----------------------------------------------------
---------- Update Table BTRT..TCONTR ---------------
----------------------------------------------------
          --select "Avant UPDATE TCONTR" "Avant UPDATE TCONTR", * 
      --from BTRT..TCONTR where ssd_cf in (14,25,26,27) and ( ctrsts_ct in (12,14,16,17,19)  or CTRACCSTS_CT in (0,1,2) )

        UPDATE BTRT..TCONTR SET ESTCRB_CT = 'V' 
      WHERE  ssd_cf in (14,25,26,27)
        and ESTCRB_CT <> 'D' and ESTCRB_CT <> 'N' and ESTCRB_CT <> 'S'
        
        -- and ( ctrsts_ct in (12,14,16,17,19)  or CTRACCSTS_CT in (0,1,2) )

                    -- récuperer codes retour et nb lignes impactées --
                    /*SELECT @erreur = @@error, @nb_maj1 = @@rowcount, @trans_etat = @@transtate
                    IF @erreur != 0 OR @trans_etat > 1
                      BEGIN
                            PRINT 'BTRT..TCONTR - UPDATE ERREUR : %1!',@erreur
                            ROLLBACK TRAN
                            GOTO fin
                      END
          select "Après UPDATE TCONTR" "Après UPDATE TCONTR", * from BTRT..TCONTR where ssd_cf in (14,25,26,27) and ( ctrsts_ct in (12,14,16,17,19)  or CTRACCSTS_CT in (0,1,2) )
*/
----------------------------------------------------
---------- Update Table BTRT..TSection--------------
----------------------------------------------------

          --select "Avant UPDATE TSECTION" "Avant UPDATE TSECTION", sec.* from btrt..tsection sec, btrt..tcontr ctr WHERE sec.ctr_nf = ctr.ctr_nf and sec.uwy_nf = ctr.uwy_nf and ctr.estcrb_ct = 'V'

          update btrt..tsection set estcrb_ct = 'V' from btrt..tsection sec, btrt..tcontr ctr
          WHERE 
          sec.ctr_nf = ctr.ctr_nf
          and sec.uwy_nf = ctr.uwy_nf
          and ctr.estcrb_ct = 'V'

                    /*-- récuperer codes retour et nb lignes impactées --
                    SELECT @erreur = @@error, @nb_maj1 = @@rowcount, @trans_etat = @@transtate
                    IF @erreur != 0 OR @trans_etat > 1
                      BEGIN
                            PRINT 'BTRT..TCONTR - UPDATE ERREUR : %1!',@erreur
                            ROLLBACK TRAN
                            GOTO fin
                      END
          select "Apres UPDATE TSECTION" "Apres UPDATE TSECTION", sec.* from btrt..tsection sec, btrt..tcontr ctr WHERE sec.ctr_nf = ctr.ctr_nf and sec.uwy_nf = ctr.uwy_nf and ctr.estcrb_ct = 'V'
*/
      
      -----------------------------------------------------
---------- Update Table BRET..TRETCTR ---------------
----------------------------------------------------

          --select "Avant UPDATE TRETCTR" "Avant UPDATE TRETCTR", *  from bret..tretctr where  retctrsts_ct in (3,19) and ssd_cf in (14,25,26,27)

          UPDATE BRET..TRETCTR SET ESTCRB_CT = 'V' 
          WHERE  ssd_cf in (14,25,26,27)
        and ESTCRB_CT <> 'D' and ESTCRB_CT <> 'N' and ESTCRB_CT <> 'S'
                    /*-- récuperer codes retour et nb lignes impactées --
                    SELECT @erreur = @@error, @nb_maj1 = @@rowcount, @trans_etat = @@transtate
                    IF @erreur != 0 OR @trans_etat > 1
                      BEGIN
                            PRINT 'BRET..TRETCTR - UPDATE ERREUR : %1!',@erreur
                            ROLLBACK TRAN
                            GOTO fin
                      END*/