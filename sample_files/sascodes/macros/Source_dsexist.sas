%Macro Dsexist(Ds)/Secure Store ;

%Put INFO: DSEXIST Macro is been called. ;

%Global DSLIB DSNM ;

%If %Sysfunc(countc(&DS.,.)) Gt 0 %Then %Do ;
        %Let DSLIB = %Upcase(%Scan(&DS.,1,.)) ;
        %Let DSNM  = %Upcase(%Scan(&DS.,2,.)) ;
%End ;
%Else %Do ;
        %Let DSLIB = WORK ;
        %Let DSNM  = %Upcase(&DS.) ;
%End ;

%If Not %Sysfunc(exist(&Ds)) %Then %Do ;
    %Put ERROR: The dataset &DSNM doesnt exist in &DSLIB Library !!! ;
    %ABORT ABEND ;
%End ;

%Mend Dsexist ;
