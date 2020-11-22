%Macro Freq(Ds=,Vars=,Options=NIL,Out=NIL,Xtab=NIL,Filter=NIL)/Store Source ;

%If Not %Sysfunc(exist(&Ds)) %Then %Do ;
    %Put ERROR: The &Ds is not existing !!! ;
	%Goto EXIT ;
%End ;

%Let Vars=%Sysfunc(Strip(&Vars)) ;

%If %Bquote(&Options) ne %Bquote(NIL) %Then %Do ;
    %let Options=%Sysfunc(Compbl(&Options.)) ;
    %If &Out ne NIL %Then
        %Let Options=%Str(/ &Options Out=&Out) ;
	%Else
	    %Let Options=%Str(/ &Options) ;
%End ;
%Else %If &Out ne NIL %Then %Let Options=%Str(/ Out=&Out) ;
%Else %Let Options=%Str() ;

%If &Xtab ne NIL %Then %Let Vars=%Sysfunc(translate(%Sysfunc(Strip(%Sysfunc(Compbl(&Vars)))),'*',' ')) ;
%Put Vars=&Vars ;
%Put Filter=&Filter ;
%If %Bquote(&Filter) ne %BQuote(NIL) %Then %Let Filter=%Str(Where %Sysfunc(Dequote(&Filter))) ;
%Else %Let Filter=%str() ;
%Put Filter=&Filter ;

	Proc Freq Data=&Ds ;
	   &Filter ;
	   Tables &Vars &Options;
	Run ;

%EXIT:

%Mend Freq ;
