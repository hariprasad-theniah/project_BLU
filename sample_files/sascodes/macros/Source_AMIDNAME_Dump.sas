/*Data*/
/*    Hari2004.AMID_NAMES*/
/*	;*/
/*	Set*/
/*	   Hariship.shipmentmaster_bcs ( Keep= AMID AMID_NAME AMID_L2_CLASS_CD AMID_L2_IND_CD AMID_L2_SEG_CD AMID_L4 AMID_L4_NAME)*/
/*	   Hariship.shipmentmaster_iss ( Keep= AMID AMID_NAME AMID_L2_CLASS_CD AMID_L2_IND_CD AMID_L2_SEG_CD AMID_L4 AMID_L4_NAME)*/
/*	   Hariship.shipmentmaster_swd ( Keep= AMID AMID_NAME AMID_L2_CLASS_CD AMID_L2_IND_CD AMID_L2_SEG_CD AMID_L4 AMID_L4_NAME)*/
/*	   ;*/
/*Run ;*/
/*%AmidNameDedup(Ds=Hari2004.AMID_NAMES,Amid=Amid,AmidName=Amid_Name)*/
/*Proc Sort Data=Hari2004.AMID_NAMES Nodupkey ;*/
/*By*/
/*  AMID AMID_NAME*/
/*  ;*/
/*Run ;*/

%FmtMatch(Ds=Hari2004.AMID_NAMES
,FmtName=$Amid
,Var=Amid
)

Data
    AMID_NAMES
	;
	Set
	   Hariship.shipmentmaster_bcs ( Keep= AMID AMID_NAME AMID_L2_CLASS_CD AMID_L2_IND_CD AMID_L2_SEG_CD AMID_L4 AMID_L4_NAME)
	   Hariship.shipmentmaster_iss ( Keep= AMID AMID_NAME AMID_L2_CLASS_CD AMID_L2_IND_CD AMID_L2_SEG_CD AMID_L4 AMID_L4_NAME)
	   Hariship.shipmentmaster_swd ( Keep= AMID AMID_NAME AMID_L2_CLASS_CD AMID_L2_IND_CD AMID_L2_SEG_CD AMID_L4 AMID_L4_NAME)
	   ;
Where Put(Amid,$Amid.) Eq 'N' ;
Run ;

%AmidNameDedup(Ds=AMID_NAMES,Amid=Amid,AmidName=Amid_Name)
Proc Sort Data=AMID_NAMES Nodupkey ;
By
  AMID AMID_NAME
  ;
Run ;

Data
    Hari2004.AMID_NAMES
	;
	Set
	   Hari2004.AMID_NAMES
	   AMID_NAMES
	   ;
	By
	  Amid
	  ;
Run ;
