%Macro RenameVarX/PARMBUFF store secure;
%Let ParLen=%Sysfunc(LengthN(%TRIM(&SYSPBUFF)));
%Let MySYSPBUFF=%Sysfunc(Substr(%TRIM(&SYSPBUFF),2,%Eval(&ParLen.-2))) ;
%Let MySYSPBUFF=%Upcase(&MySYSPBUFF.) ;

%Let Ds=%Scan(%Bquote(&MySYSPBUFF.),1,',') ;
%Let PCnt=%Sysfunc(Countc(%Bquote(&MySYSPBUFF.),','));

%If &PCnt. le 1 %Then %Do ;
    %Put ERROR: Less number of Arguments !!! ;
	%Goto Exit ;
%End ;

%If %Sysfunc(ANYSPACE(&Ds.)) gt 0 %Then %Do ;
    %Put ERROR: The &Ds Name is Invalid !!! ;
	%Goto Exit ;
%End ;
%Else %If %Sysfunc(Countc(&Ds.,'!@#$%^&*()-+={}[]\/:<>`~"')) gt 0 or %Sysfunc(Countc(&Ds.,"'")) gt 0 %Then %Do ;
    %Put ERROR: The &Ds Name is Invalid !!! ;
	%Goto Exit ;
%End ;
%Else %If %Sysfunc(Countc(&Ds.,'.')) gt 1 %Then %Do ;
    %Put ERROR: The &Ds Name is Invalid !!! ;
    %Goto Exit ;
%End ;
%Else %If NOT %Sysfunc(exist(&Ds.)) %Then %Do ;
    %Put ERROR: The &Ds NOT EXISTING !!! ;
	%Goto Exit ;
%End ;

%If %Sysfunc(countc(&DS.,.)) Gt 0 %Then %Do ;
        %Let Lib = %Upcase(%Scan(&DS.,1,.)) ;
        %Let DS  = %Upcase(%Scan(&DS.,2,.)) ;
%End ;
%Else %Do ;
        %Let Lib = WORK ;
        %Let DS  = %Upcase(&DS.) ;
%End ;

Proc Datasets Lib=&Lib nolist;

Modify &Ds. ;
%let Renamei=2 ;
%Let Pcnt=%Eval(&Pcnt.+1);
%If %Sysfunc(Mod(&Pcnt.,2)) eq 0  %Then %Do ;
    %Put INFO: The No. of arguments are not sufficient to rename all the given variables !!! ;
%End ;

%Do %While(&Pcnt. > &Renamei);

%If %Scan(%Bquote(&MySYSPBUFF),&Renamei.,',') Ne %Cmpres(%Scan(%Bquote(&MySYSPBUFF),%Eval(&Renamei.+1),',')) %Then %Do ;
Rename %Scan(%Bquote(&MySYSPBUFF),&Renamei.,',') = %Cmpres(%Scan(%Bquote(&MySYSPBUFF),%Eval(&Renamei.+1),',')) ;
/*%Put INFO: Variable %Scan(%Bquote(&MySYSPBUFF),&Renamei.,',') is Renamed to %Cmpres(%Scan(%Bquote(&MySYSPBUFF),%Eval(&Renamei.+1),',')) !!! ; */
%End ;
%Else %Do ;
%Put INFO: The Old Variable name and New Variable name are same !!! ;
%End ;

%Let Renamei=%Eval(&Renamei.+2) ;

%End ;
%If &Renamei. eq &Pcnt. %Then %Do ;
%Put MACROMSG: The Variable %Scan(%Bquote(&MySYSPBUFF),&Renamei.,',') does not have a new name to rename !!! ;
%End ;
Run ;

Quit ;

%EXIT:
%Put INFO: RenameVar Macro is Executed !!! ;

%Mend RenameVarx;
