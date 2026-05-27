
-- Specifying HORDNBR_NT taglist request util
update BEST..TSEGCRITERIA set SGTCRICTL_CT = '5', SGTCRIPAR_LS = 'TREPCRI', LSTUPD_D = getDate(), LSTUPDUSR_CF = suser_name() where SGTCRI_CF='CLI_GROUP_SEGMENT'
go