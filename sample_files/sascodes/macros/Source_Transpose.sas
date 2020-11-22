%Macro Transpose(TransposeIn=NIL
                ,TransposeOut=NIL
                ,BaseVar=NIL
                ,ColumnVar=NIL
				,ColumnVarLabel=NIL
                ,SummaryVar=NIL
                ,Prefix=Tran_
                ,Suffix=NIL
                ) 
				/Store Secure
                ;

%If %Upcase(&TransposeIn.) Eq NIL %Then %Do ;
    %Put ERROR: NO Input Dataset to do Transpose !!! ;
	%Goto Exit;
%End ;

%DSExist(&TransposeIn.)

%If %Upcase(&BaseVar.) Eq NIL %Then %Do ;
    %Put ERROR: NO Base Variable to do Transpose !!! ;
	%Goto Exit;
%End ;

%If %Upcase(&SummaryVar.) Eq NIL %Then %Do ;
    %Put ERROR: NO Summary Variable to do Transpose !!! ;
	%Goto Exit;
%End ;

%Do Transpose_i=1 %To %ArgCnt(&BaseVar.) ;
    %VarExist(&TransposeIn.,%Scan(&BaseVar.,&Transpose_i.,' '))
    %If &VarExist. Eq %Str() %Then %Do ;
        %Put ERROR: %Scan(&BaseVar.,&Transpose_i.,' ') is not exist with the Dataset &TransposeIn. ;
        %Goto Exit ;
    %End ;
%End ;

%Do Transpose_i=1 %To %ArgCnt(&SummaryVar.) ;
    %VarExist(&TransposeIn.,%Scan(&SummaryVar.,&Transpose_i.,' '))
    %If &VarExist. Eq %Str() %Then %Do ;
        %Put ERROR: %Scan(&SummaryVar.,&Transpose_i.,' ') is not exist with the Dataset &TransposeIn. ;
        %Goto Exit ;
    %End ;
%End ;

%If %Upcase(&ColumnVar.) Ne NIL %Then %Do ;
    %Do Transpose_i=1 %To %ArgCnt(&ColumnVar.) ;
        %VarExist(&TransposeIn.,%Scan(&ColumnVar.,&Transpose_i.,' '))
        %If &VarExist. Eq %Str() %Then %Do ;
            %Put ERROR: %Scan(&ColumnVar.,&Transpose_i.,' ') is not exist with the Dataset &TransposeIn. ;
            %Goto Exit ;
        %End ;
    %End ;
%End ;

%If %Upcase(&ColumnVarLabel.) Ne NIL %Then %Do ;
    %VarExist(&TransposeIn.,&ColumnVarLabel.)
    %If &VarExist. Eq %Str() %Then %Do ;
        %Put INFO: &ColumnVarLabel. is not exist with the Dataset &TransposeIn. ;
        %Let ColumnVarLabel=NIL ;
    %End ;
%End ;

%If %Upcase(&TransposeOut.) Eq NIL %Then %Do ;
    %Let TransposeOut=TransposeOut;
%End ;

%Let Num_Var=%ArgCnt(&SummaryVar.) ;

%If &Num_Var. Eq 1 %Then %Do ;
Proc Transpose Data=&TransposeIn. 
                Out=&TransposeOut.(Drop=_:) 
             Prefix=&Prefix. 
     %If &Suffix. Ne NIL %Then %Do ;
             Suffix=&Suffix. 
     %End ;
             ;
ID &ColumnVar.;
BY &BaseVar.;
Var &SummaryVar.;
Run ;
%End ;
%Else %Do ;
    %Let Space=%Str( );
    %Do Transpose_i=1 %To %ArgCnt(&SummaryVar.) ;
	%Let SumVar=%Scan(&SummaryVar.,&Transpose_i.,' ') ;
    Proc Transpose Data=&TransposeIn. Out=&TransposeOut.&Transpose_i.(Drop=_:) 
                 Prefix=&Prefix. 
                 Suffix=_%Substr(&SumVar.,1,%Sysfunc(Min(%Length(&SumVar.),10))); 
                 ;
        ID &ColumnVar.;
%If %Upcase(&ColumnVarLabel.) Ne NIL %Then %Do ;
        IDLabel &ColumnVarLabel. ;
%End ;
        BY &BaseVar.;
        VAR &SumVar.;
    Run ;
    %End ;
	Data
	    &TransposeOut.
		;
		Merge
		   %Do Transpose_i=1 %To %ArgCnt(&SummaryVar.) ;
		   &TransposeOut.&Transpose_i.&Space.
		   %End ;
		;
		By
		  &BaseVar.;
		  ;
	Run ;
	%Do Transpose_i=1 %To %ArgCnt(&SummaryVar.) ;
		   %DeleteDs(&TransposeOut.&Transpose_i.)
    %End ;
%End ;

%If %Sysfunc(Exist(&TransposeOut.)) %Then %Do ;
%Put INFO: Transpose Macro ran successfully - Stored in &TransposeOut. !!! ;
%End ;
%Else %Do ;
%Put ERROR: Transpose Macro Failed !!! ;
%End ;

%Exit:

%Mend Transpose ;

/*%Transpose(TransposeIn=SASHELP.CLASS,TransposeOut=MyNewTranDs,BaseVar=NAME,ColumnVar=SEX,SummaryVar=Height Weight)*/
/*Proc Print Data=MyNewTranDs;*/
/*Run ;*/

/*%Contents(SASHELP.CLASS)*/
