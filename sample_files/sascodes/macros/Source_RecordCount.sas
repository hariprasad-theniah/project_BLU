%Macro RecordsCount(RecordsCount,Count=Nobs) / Store Secure;
%Global &Count. ;
%Let RecordsCountDsn=%Sysfunc(open(&RecordsCount.));
%Let &Count.=%Sysfunc(Attrn(&RecordsCountDsn,nobs)) ;
%Let RecordsCountDsn=%Sysfunc(Close(&RecordsCountDsn)) ;
%Mend RecordsCount ;
