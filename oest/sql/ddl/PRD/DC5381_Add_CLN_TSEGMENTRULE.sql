-------------------------------------------------------------------------------
-- Author : BEL 
-- Craetion date : Aug 18, 2025
-- Description : Add a new columns 'RETACT_B' and 'RULCESSH_R' 
-- (indicator of retroactive effect and Rule Cession rate). 
-- DC5381
-------------------------------------------------------------------------------
USE BEST
go


if not exists (select 14 from syscolumns
    where id = object_id('TSEGMENTRULE')
        and name = 'RETACT_B')
    begin
        exec (' alter table TSEGMENTRULE add RETACT_B BIT DEFAULT 1 NOT NULL')
    end
else 
    print 'RETACT_B : already exists '
go


if not exists (select 14 from syscolumns
    where id = object_id('TSEGMENTRULE')
        and name = 'RULCESSH_R')
    begin
        exec (' alter table TSEGMENTRULE add RULCESSH_R USHORAT_R NULL')
    end
else 
    print 'RULCESSH_R : already exists '
go

