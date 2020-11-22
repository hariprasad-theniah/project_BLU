%Macro AssignLabel/PARMBUFF Store Secure;
%Let ParLen=%Sysfunc(LengthN(%TRIM(&SYSPBUFF)));
%Let MySYSPBUFF=%Sysfunc(Substr(%TRIM(&SYSPBUFF),2,%Eval(&ParLen.-2))) ;

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
%let Labeli=2 ;
%Let Pcnt=%Eval(&Pcnt.+1);
%If %Sysfunc(Mod(&Pcnt.,2)) eq 0  %Then %Do ;
    %Put MACROMSG: The No. of arguments are not sufficient to assign Label for all given variables !!! ;
%End ;

%Do %While(&Pcnt. > &Labeli);

Label %Scan(%Bquote(&MySYSPBUFF),&Labeli.,',') = %Sysfunc(Quote(%Sysfunc(Strip(%Scan(%Bquote(&MySYSPBUFF),%Eval(&Labeli.+1),','))))) ;
/* %Put INFO: %Sysfunc(Quote(%Cmpres(%Scan(%Bquote(&MySYSPBUFF),%Eval(&Labeli.+1),',')))) is assigned as Lbel to %Scan(%Bquote(&MySYSPBUFF),&Labeli.,',') !!! ; */

%Let Labeli=%Eval(&Labeli.+2) ;

%End ;
%If &Labeli. eq &Pcnt. %Then %Do ;
%Put MACROMSG: The Variable %Scan(%Bquote(&MySYSPBUFF),&Labeli.,',') does not have a Label Value !!! ;
%End ;
Run ;

Quit ;

%EXIT:
%Put INFO: AssignLabel Macro is Executed !!! ;

%Mend AssignLabel ;
