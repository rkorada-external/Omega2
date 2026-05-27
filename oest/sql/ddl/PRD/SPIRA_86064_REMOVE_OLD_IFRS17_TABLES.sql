--14/14/2020M.NAJI SPIRA 86064 remove old IFRS17 Tables  

USE BEST
go
IF OBJECT_ID('dbo.TIfrs17Request') IS NOT NULL
BEGIN

	ALTER TABLE dbo.TIfrs17Request
    DROP CONSTRAINT PK_TIFRS17REQUEST

    DROP TABLE dbo.TIfrs17Request
    IF OBJECT_ID('dbo.TIfrs17Request') IS NOT NULL
        PRINT '<<< FAILED DROPPING TABLE dbo.TIfrs17Request >>>'
    ELSE
        PRINT '<<< DROPPED TABLE dbo.TIfrs17Request >>>'
END
go
IF OBJECT_ID('dbo.TIfrs17Plan') IS NOT NULL
BEGIN
	ALTER TABLE dbo.TIfrs17Plan
    DROP CONSTRAINT PK_TIFRS17PLAN
    DROP TABLE dbo.TIfrs17Plan
    IF OBJECT_ID('dbo.TIfrs17Plan') IS NOT NULL
        PRINT '<<< FAILED DROPPING TABLE dbo.TIfrs17Plan >>>'
    ELSE
        PRINT '<<< DROPPED TABLE dbo.TIfrs17Plan >>>'
END
IF OBJECT_ID('dbo.TIfrs17Perm') IS NOT NULL
BEGIN
	ALTER TABLE dbo.TIfrs17Perm
    DROP CONSTRAINT PK_TIFRS17PERM
    DROP TABLE dbo.TIfrs17Perm
    IF OBJECT_ID('dbo.TIfrs17Perm') IS NOT NULL
        PRINT '<<< FAILED DROPPING TABLE dbo.TIfrs17Perm >>>'
    ELSE
        PRINT '<<< DROPPED TABLE dbo.TIfrs17Perm >>>'
END
go
IF OBJECT_ID('dbo.TIfrs17ContextRequest') IS NOT NULL
BEGIN
	ALTER TABLE dbo.TIfrs17ContextRequest
    DROP CONSTRAINT PK_TIFRS17ContextRequest
    DROP TABLE dbo.TIfrs17ContextRequest
    IF OBJECT_ID('dbo.TIfrs17ContextRequest') IS NOT NULL
        PRINT '<<< FAILED DROPPING TABLE dbo.TIfrs17ContextRequest >>>'
    ELSE
        PRINT '<<< DROPPED TABLE dbo.TIfrs17ContextRequest >>>'
END
go
IF OBJECT_ID('dbo.TIfrs17Context') IS NOT NULL
BEGIN
	ALTER TABLE dbo.TIfrs17Context
    DROP CONSTRAINT PK_TIFRS17CONTEXT
    DROP TABLE dbo.TIfrs17Context
    IF OBJECT_ID('dbo.TIfrs17Context') IS NOT NULL
        PRINT '<<< FAILED DROPPING TABLE dbo.TIfrs17Context >>>'
    ELSE
        PRINT '<<< DROPPED TABLE dbo.TIfrs17Context >>>'
END
go
IF OBJECT_ID('dbo.TIfrs17Chain') IS NOT NULL
BEGIN
	ALTER TABLE dbo.TIfrs17Chain
    DROP CONSTRAINT PK_TIFRS17CHAIN
    DROP TABLE dbo.TIfrs17Chain
    IF OBJECT_ID('dbo.TIfrs17Chain') IS NOT NULL
        PRINT '<<< FAILED DROPPING TABLE dbo.TIfrs17Chain >>>'
    ELSE
        PRINT '<<< DROPPED TABLE dbo.TIfrs17Chain >>>'
END
go
