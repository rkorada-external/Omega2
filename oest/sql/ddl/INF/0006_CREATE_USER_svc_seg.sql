USE BSEG
go
EXEC sp_addalias 'svc_seg','dbo'
go
IF EXISTS (SELECT * FROM sysalternates WHERE suid=SUSER_ID('svc_seg'))
    PRINT '<<< CREATED ALIAS svc_seg >>>'
ELSE
    PRINT '<<< FAILED CREATING ALIAS svc_seg >>>'
go

USE BREF
go
EXEC sp_adduser 'svc_seg','svc_seg','GCONSULT'
go
IF USER_ID('svc_seg') IS NOT NULL
    PRINT '<<< CREATED USER svc_seg>>>'
ELSE
    PRINT '<<< FAILED CREATING USER svc_seg >>>'
go

USE BEST
go
EXEC sp_adduser 'svc_seg','svc_seg','GCONSULT'
go
IF USER_ID('svc_seg') IS NOT NULL
    PRINT '<<< CREATED USER svc_seg>>>'
ELSE
    PRINT '<<< FAILED CREATING USER svc_seg >>>'
go
