INIT MASTER(S) 	
ID *GenData(ID),MSC/N
SOL *\
*set var first=0
*if(strcmp(GenData(Analysis_Type),"MODES")==0)
*if(first==0)
103*\
*else
,103*\
*endif
*set var first=1
*endif
*if(strcmp(GenData(Analysis_Type),"DIRECT_FREQUENCY_RESPONSE")==0)
*if(first==0)
108*\
*else
,108*\
*endif
*set var first=1
*endif
*if(strcmp(GenData(Analysis_Type),"DIRECT_TRANSIENT_RESPONSE")==0)
*if(first==0)
109*\
*else
,109*\
*endif
*set var first=1
*endif
*if(strcmp(GenData(Analysis_Type),"MODAL_FREQUENCY_RESPONSE")==0)
*if(first==0)
111*\
*else
,111*\
*endif
*set var first=1
*endif
*if(strcmp(GenData(Analysis_Type),"MODAL_TRANSIENT_RESPONSE")==0)
*if(first==0)
112*\
*else
,112*\
*endif
*set var first=1
*endif
*if(strcmp(GenData(Analysis_Type),"STATIC")==0)
*if(first==0)
101*\
*else
,101*\
*endif
*set var first=1
*endif

TIME *GenData(TIME(min))
CEND
