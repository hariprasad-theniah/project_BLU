%Macro Argcnt(Var1,Dlm=' ')/Store Secure ;
%Let Var1=%Sysfunc(Compbl(&Var1)) ;
%Sysfunc(ifn(%Sysfunc(Countc(%Sysfunc(strip(&Var1)),&Dlm.)) eq 0,1,%eval(%Sysfunc(Countc(%Sysfunc(strip(&Var1)),&Dlm.))+1)))
%Mend Argcnt ;
