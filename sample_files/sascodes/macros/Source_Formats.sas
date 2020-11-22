Proc Format Library=formats;

Value HpQtr
1			= 'QTR1'
11 - 12     = 'QTR1'
2  - 4      = 'QTR2'
5  - 7      = 'QTR3'
8  - 10     = 'QTR4'
;

Value QTY
0 -< 1		= 'NO'
1 -  High   = 'YES'
Other       = 'NO'
;

InValue QTY
0 -< 1		= 0
1 -  High   = 1
Other       = 0
;

Run ;
