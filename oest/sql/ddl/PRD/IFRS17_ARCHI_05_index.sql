USE BEST
go
/*==============================================================*/
/* DBMS name:      Sybase AS Enterprise 15.7                    */
/* Created on:     18/04/2019 15:03:21                          */
/*==============================================================*/


if exists (select 1
            from  sysindexes
           where  id    = object_id('TI17CHN')
            and   name  = 'IIFRS17CHAIN_00'
            and   indid > 0
            and   indid < 255)
   drop index TI17CHN.IIFRS17CHAIN_00
go

if exists (select 1
            from  sysindexes
           where  id    = object_id('TI17FNC')
            and   name  = 'IIFRS17_FNCT_00'
            and   indid > 0
            and   indid < 255)
   drop index TI17FNC.IIFRS17_FNCT_00
go

if exists (select 1
            from  sysindexes
           where  id    = object_id('TI17PERMFIL')
            and   name  = 'IIFRS17PERM_00'
            and   indid > 0
            and   indid < 255)
   drop index TI17PERMFIL.IIFRS17PERM_00
go

if exists (select 1
            from  sysindexes
           where  id    = object_id('TI17REQ')
            and   name  = 'IIFRS17RSQT_00'
            and   indid > 0
            and   indid < 255)
   drop index TI17REQ.IIFRS17RSQT_00
go

if exists (select 1
            from  sysindexes
           where  id    = object_id('TI17REQCHN')
            and   name  = 'IIFRS17_REQST_CHAIN_00'
            and   indid > 0
            and   indid < 255)
   drop index TI17REQCHN.IIFRS17_REQST_CHAIN_00
go

/*==============================================================*/
/* Index: IIFRS17CHAIN_00                                       */
/*==============================================================*/
create unique clustered index IIFRS17CHAIN_00 on TI17CHN (
CHAIN_CT ASC
)
go

/*==============================================================*/
/* Index: IIFRS17_FNCT_00                                       */
/*==============================================================*/
create unique clustered index IIFRS17_FNCT_00 on TI17FNC (
IDF_CT ASC
)
go

/*==============================================================*/
/* Index: IIFRS17PERM_00                                        */
/*==============================================================*/
create unique clustered index IIFRS17PERM_00 on TI17PERMFIL (
IDF_CT ASC,
PERMFIL_CT ASC
)
go

/*==============================================================*/
/* Index: IIFRS17RSQT_00                                        */
/*==============================================================*/
create unique clustered index IIFRS17RSQT_00 on TI17REQ (
REQCOD_CT ASC
)
go

/*==============================================================*/
/* Index: IIFRS17_REQST_CHAIN_00                                */
/*==============================================================*/
create unique clustered index IIFRS17_REQST_CHAIN_00 on TI17REQCHN (
REQCOD_CT ASC,
CHAIN_CT ASC,
IDF_CT ASC
)
go

