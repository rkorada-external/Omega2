USE BREF
go
/***************************************************
Programme: Insertion Messages 2011,2012,2013 pour ESTIMATION
Fichier script associé : 
Domaine : Estimations
Base principale : BREF
*****************************************************/

/* Declaration des Variables */
declare @msg varchar(100)
set nocount on
/* Debut Routine */
select @msg=@@servername + ' => ' + host_name() + '  Debut  UPDATE/INSERT TABLE des MESSAGES'+convert(char(9),getdate(),6)+' '+ convert(char(8),getdate(),8)
 + substring(convert(char(27),getdate(),109),21,4)
print @msg
set nocount off
go
set flushmessage off

-- Table Temporaire des Messages à Enregistrer
CREATE TABLE #ITMESSAGE
(
    LANG_C    ULAG_CF      NOT NULL,
    MESSTHM_C UMESSTHM_C   NOT NULL,
    MESS_N    int          NOT NULL,
    MESS_L    varchar(200) NULL,
    ICON_T    tinyint      NULL,
    BUTT_T    tinyint      NULL
)
go

-- Table Temporaire des Messages à Enregistrer
Declare CRSMSG cursor for
SELECT  LANG_C, MESSTHM_C, MESS_N, MESS_L, ICON_T, BUTT_T
   From #ITMESSAGE 
go
-- Entrez ICI vos Modifications
/* ----------------------------------------------------------------------------------------------- */
/* ---------------- INSERTION DES MESSAGES ------------------------------------------------------- */
/* ----------------------------------------------------------------------------------------------- */

INSERT INTO #ITMESSAGE VALUES ('E', 'ESTIMATION', 21021, "The retro contract is terminated",0,0)
INSERT INTO #ITMESSAGE VALUES ('F', "ESTIMATION", 21021, "Le contrat rétro est terminé.",0,0)
INSERT INTO #ITMESSAGE VALUES ('E', "ESTIMATION", 21022, "The retro claim is closed (or not taken up).",0,0)
INSERT INTO #ITMESSAGE VALUES ('F', "ESTIMATION", 21022, "Le sinistre est clos (ou sans suite).",0,0)
/* ----------------------------------------------------------------------------------------------- */

-- NE PAS TOUCHER le RESTE de la PROCéDURE

/* Declaration des Variables */
declare @erreur int, @tran_imbr  bit

Declare    @v_lang_c ULAG_CF,
           @v_messthm_c UMESSTHM_C,
           @v_mess_n    int,
           @v_mess_l    varchar(200),
           @v_icon_t    tinyint,
           @v_butt_t    tinyint

Declare @p_msginfo varchar(260)

/* Initialisation */
select @erreur = 0
select @tran_imbr = 1

/* Init Transaction */
if @@trancount = 0
  begin
   select @tran_imbr = 0
   BEGIN TRAN
  end

/* ------------------------------------------------------------ */
/* Chargement des Messages à Insérer depuis la TABLE TEMPORAIRE */
/* ------------------------------------------------------------ */
OPEN CRSMSG
FETCH CRSMSG into @v_lang_c, @v_messthm_c, @v_mess_n, @v_mess_l, @v_icon_t, @v_butt_t

/* Gestion Erreur Ouverture CURSEUR */
select @erreur = @@error
if @erreur != 0     /* Erreurs */
begin
    if @erreur = 2601
       begin
            print 'Erreur Insertion MESSAGE : Aucune ligne à Insérer !'
       end
    else
       begin
            print 'Erreur FETCH CURSOR MESSAGE !'
       end 
    Close CRSMSG
    Deallocate cursor CRSMSG
    goto annultask
end 

WHILE @@sqlstatus = 0
BEGIN
    
    Select @p_msginfo = "Message [" + @v_lang_c + "]" + rtrim(@v_messthm_c) + " - " + convert(char(8), @v_mess_n) + " - " + rtrim(@v_mess_l)

    IF NOT EXISTS (SELECT 1 FROM BREF..TMESSAGE WHERE LANG_C = @v_lang_c and MESSTHM_C = @v_messthm_c and MESS_N = @v_mess_n) 
        BEGIN
            Select @p_msginfo = " INSERT : " + @p_msginfo
            print @p_msginfo

            INSERT INTO TMESSAGE (LANG_C, MESSTHM_C, MESS_N, MESS_L, ICON_T, BUTT_T) 
            VALUES (@v_lang_c, @v_messthm_c, @v_mess_n, @v_mess_l, @v_icon_t, @v_butt_t)

           if @erreur != 0     /* Erreurs */
              begin
                  print 'Erreur INSERT TABLE TMESSAGE !'
                  Close CRSMSG
                  Deallocate cursor CRSMSG
                  goto annultask
              end 
        END
    ELSE
        BEGIN
            Select @p_msginfo = " UPDATE : " + @p_msginfo
            print @p_msginfo

            UPDATE TMESSAGE SET MESS_L = @v_mess_l, ICON_T = @v_icon_t, BUTT_T = @v_butt_t
              where LANG_C = @v_lang_c
                and MESS_N = @v_mess_n
                and MESSTHM_C = @v_messthm_c
           if @erreur != 0     /* Erreurs */
              begin
                  print 'Erreur UPDATE TABLE TMESSAGE !'
                  Close CRSMSG
                  Deallocate cursor CRSMSG
                  goto annultask
              end 
        END

   FETCH CRSMSG into @v_lang_c, @v_messthm_c, @v_mess_n, @v_mess_l, @v_icon_t, @v_butt_t
   select @erreur = @@error
   if @erreur != 0     /* Erreurs */
      begin
          print 'Erreur FETCH CURSOR MESSAGE !'
          Close CRSMSG
          Deallocate cursor CRSMSG
          goto annultask
      end 
END      -- Fin de boucle ............................................


EndCurs:
Close CRSMSG
Deallocate cursor CRSMSG

/* Terminé */
if @tran_imbr = 0
    COMMIT TRAN
goto fin


annultask:
if @tran_imbr = 0
   ROLLBACK TRAN
goto fin

fin:
DROP TABLE #ITMESSAGE

set nocount on
declare @msg varchar(100)
select @msg=@@servername + ' => ' + host_name() + '  Fin UPDATE/INSERT TABLE des MESSAGES'+convert(char(9),getdate(),6)+' '+convert(char(8),getdate(),8)
 + substring(convert(char(27),getdate(),109),21,4)
print @msg
set nocount off
go

