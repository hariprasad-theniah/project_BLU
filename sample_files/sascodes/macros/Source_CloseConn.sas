%Macro CloseConn(Conn)/Store Secure;

waitfor _all_  &Conn ;

%Let i=1 ;

%Do %While(%Scan(&Conn,&i) Ne %Str()) ;
	Signoff %Scan(&Conn,&i) ;
	%let i=%Eval(&i+1) ;
%End ;

%Mend CloseConn;