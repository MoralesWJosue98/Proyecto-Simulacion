ID *GenData(ID)/MI
APP *GenData(Rigid_Format)
SOL *\
*set var first=0
*if(strcmp(GenData(Analysis_Type),"MODES")==0)
*if(first==0)
3*\
*else
,3*\
*endif
*set var first=1
*endif
*if(strcmp(GenData(Analysis_Type),"DIRECT_FREQUENCY_RESPONSE")==0)
*if(first==0)
8*\
*else
,8*\
*endif
*set var first=1
*endif
*if(strcmp(GenData(Analysis_Type),"DIRECT_TRANSIENT_RESPONSE")==0)
*if(first==0)
9*\
*else
,9*\
*endif
*set var first=1
*endif
*if(strcmp(GenData(Analysis_Type),"MODAL_FREQUENCY_RESPONSE")==0)
*if(first==0)
11*\
*else
,11*\
*endif
*set var first=1
*endif
*if(strcmp(GenData(Analysis_Type),"MODAL_TRANSIENT_RESPONSE")==0)
*if(first==0)
10*\
*else
,10*\
*endif
*set var first=1
*endif
*if(strcmp(GenData(Analysis_Type),"STATIC")==0)
*if(first==0)
1*\
*else
,1*\
*endif
*set var first=1
*endif

TIME *GenData(TIME(min))
DIAG *GenData(Diagnostics)
CEND
