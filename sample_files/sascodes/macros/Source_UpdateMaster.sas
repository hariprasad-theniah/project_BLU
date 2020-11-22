%Macro UpdateMaster(Master=,Transaction=,Key=)/Store Secure ;

%Dsexist(&Master.)
%Let MLib=&DSLIB ;
%Let MDs=&DSNM ;

%Dsexist(&Transaction.)
%Let TLib=&DSLIB ;
%Let TDs=&DSNM ;

%Do UpdateMaster_I=1 %To %ArgCnt(&Key.) ;
    %Let ChkFlag=0 ;
	Options Nonotes ;
    Proc SQL Noprint;
	   
	     Select 1	
               ,type 
		   into :ChkFlag
		       ,:type
		   From Dictionary.Columns
		   Where Libname      = "%Cmpres(%Upcase(&MLib))"
             And Memname      = "%Cmpres(%Upcase(&MDs))"
             And Memtype      = 'DATA'
			 And Upcase(Name) = "%Cmpres(%Upcase(%Scan(&Key.,&UpdateMaster_I.,' ')))"
         ;
	Quit ;
	%If &ChkFlag eq 0 %Then %Do ;
	    %Put ERROR: The %Cmpres(%Upcase(%Scan(&Key.,&UpdateMaster_I.,' '))) Key Variable Is not Present in &Master. ;
		%Goto Exit ;
	%End ;
	%Let ChkFlag=0 ;
    Proc SQL Noprint ;
	     Select 1
		   into :ChkFlag
		   From Dictionary.Columns
		   Where Libname      = "%Cmpres(%Upcase(&TLib))"
             And Memname      = "%Cmpres(%Upcase(&TDs))"
             And Memtype      = 'DATA'
			 And Upcase(Name) = "%Cmpres(%Upcase(%Scan(&Key.,&UpdateMaster_I.,' ')))"
			 and type         = Strip("&type.")
         ;
	Quit ;
	Options Notes ;
	%If &ChkFlag eq 0 %Then %Do ;
	    %Put ERROR: The Key %Cmpres(%Upcase(%Scan(&Key.,&UpdateMaster_I.,' '))) Variable is not Presnt or of diff. datatype in &Transaction. ;
		%Goto Exit ;
	%End ;
%End ;

Options SORTVALIDATE ;
Proc Sort data=&Master.(Sortedby=&Key.) ;
   By
     &Key.
	 ;
run ;

Proc Sort data=&Transaction.(Sortedby=&Key.) ;
   By
     &Key.
	 ;
run ;
Options NoSORTVALIDATE ;

Data
    &MDs.
	;
	Update
	   &Master.
	   &Transaction.
	   ;
	By
	  &Key.
	  ;

Run ;

%If %Sysfunc(Exist(&MDs.)) %Then %Do ;
Proc Copy IN=WORK OUT=&MLib. ;
Select &MDs. ;
Run ;
%End ;

%Exit:

%Mend UpdateMaster ;
