%Macro AmidNameDedup(Ds=NIL,Amid=NIL,AmidName=NIL) / Store Secure;
%If %Upcase(&ds) eq NIL %Then %Do ;
    %Put ERROR: &Ds Dataset not existing !!! ;
    %goto Exit ;
%End ;

%If %Upcase(&Amid) eq NIL %Then %Do ;
    %Put ERROR: Amid Number name not specified !!! ;
    %goto Exit ;
%End ;

%If %Upcase(&AmidName) eq NIL %Then %Do ;
    %Put ERROR: Amid Name not specified !!! ;
    %goto Exit ;
%End ;

Proc Sort Data=&Ds(Keep=&Amid &AmidName) nodupkey Out=AmidNameDedup;
By
  &Amid 
  &AmidName 
  ;
Run ;

Data
   AmidNameDedup
   ;
   Set
      AmidNameDedup
	  ;
Len=Lengthn(Strip(&AmidName)) ;
Run ;

Proc Sort Data=AmidNameDedup ;
By
  &Amid
  Len
  ;
Run ;

Data
   AmidNameDedup
   ;
   Set
      AmidNameDedup
	  ;
   By
     &Amid
     ;

If %Cmpres(Last.&Amid) ;
Run ;

%HashLookup(BaseDs=&Ds,LookupDs=AmidNameDedup,Key=&Amid,Values=&AmidName)
%DeleteDs(AmidNameDedup)

%Exit:
%Put INFO: Macro AmidNameDedup Ended !!!;

%Mend AmidNameDedup;
