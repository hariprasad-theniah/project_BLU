%Macro ChkMatch(Var,Dsopt1,Dsopt2)/Store Secure;

If &Dsopt1 and &Dsopt2 then do ;
   &Var + 1 ;
   Call Symputx("&Var",put(&Var,8.)) ;
End ;
Drop &Var ;

%Mend ChkMatch;