%Macro Contents(Ds,options,Out=NIL)/store secure ;
%If %Upcase(&Out) ne NIL %Then %Let Out=%Str(Out=&Out) ;
%Else %Let Out=%Str() ;

Proc Contents Data=&Ds &options &Out;
Run ;

%Mend Contents ;
