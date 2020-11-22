%Macro VarExist(Ds,Varname)/Secure Store ;

%DsExist(&Ds.)

%Let VarExist_Lib=&DSLIB;
%Let VarExist_DsNm=&DSNM;

%Global VarExist;

%If &Varname. eq %Str() %Then %Do ;
%Put ERROR: No argument to VarExist Macro to process !!! ;
%GOTO EXIT;
%End ;

%If %Sysfunc(IndexC(&Varname.,' ""''!@#$%^&*()+{}|\:;,./?><`~')) gt 0 or %Sysfunc(Lengthn(&Varname.)) Gt 32 %Then %Do;
%Put ERROR: &Varname. -> Its not a valid var name !!! ;
%GOTO EXIT;
%End ;

%If %Bquote(%Sysfunc(Dequote(&Varname.))) eq %Bquote(&Varname.) %Then %Let Varname=%Upcase(%Sysfunc(Quote(&Varname.)));

Option Nonotes ;
Proc SQL Noprint;

Select Name
  Into :VarExist
  From Dictionary.Columns
 Where libname       ="%Cmpres(%Upcase(&VarExist_Lib.))"
   and memtype       ='DATA'
   and Memname       ="%Cmpres(%Upcase(&VarExist_DsNm.))"
   and upcase(Name) In(&Varname.)
   ;

Quit ;
Option Notes;

%If %Symexist(VarExist) %Then %Do ;
%Let VarExist=%Unquote(&VarExist.) ;
%End;
%Else %Let VarExist=%Str() ;

%Exit:

%Mend VarExist ;
