Use BEST
go

-- :Spira:67953 Insertion de contrats dans TCTRACC pour forcer la mise à jour des ultimes TCTRULT et TUNDSTA (du aux doubles dans STATGTA)

select @@servername,suser_Name(), getdate()

insert BEST..TCTRACC
(CTR_NF,END_NT,SEC_NF,UW_NT,UWY_NF)
select distinct CTR_NF,END_NT,SEC_NF,UW_NT,UWY_NF
 from best..TCTRULT a
 Where a.LSTUPD_D >= '20180315 21:29:24.323'
 and   not exists (select 1
                  from best..TCTRACC D
                  where a.CTR_NF = D.CTR_NF
                    and a.UWY_NF = D.UWY_NF
                    and a.UW_NT  = D.UW_NT
                    and a.END_NT = D.END_NT
                    and a.SEC_NF = D.SEC_NF )
 
select @@servername,suser_Name(), getdate()
go