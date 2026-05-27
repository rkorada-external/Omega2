if object_id('TI17REQFNCCHN') is not null
begin
  drop TABLE #TVAL
  if object_id('#TVAL') is not null
      print '<<< FAILED DROPPING TABLE TI17REQFNCCHN >>>'
  else
      print '<<< DROPPED TABLE TI17REQFNCCHN >>>'
end
go


delete BEST..TI17REQFNC 
where REQCOD_CT in 
(
'BookingPOCE',
'BookingPOCEAnnuel',
'BookingPOCI',
'BookingPOCIAnnuel',
'BookingPOSE',
'BookingPOSEAnnuel',
'BookingPOSI',
'BookingPOSIAnnuel',
'POCE',
'POCI',
'POSE',
'POSI'
)

go 

delete BEST..TI17REQ 
where REQCOD_CT in 
(
	'BookingPOCE',
	'BookingPOCEAnnuel',
	'BookingPOCI',
	'BookingPOCIAnnuel',
	'BookingPOSE',
	'BookingPOSEAnnuel',
	'BookingPOSI',
	'BookingPOSIAnnuel',
	'POCE',
	'POCI',
	'POSE',
	'POSI'
)


go

