ID *GenData(ID)/NE
SOL *\
*if(strcmp(GenData(Analysis_Type),"PRESTRESS_MODES")==0)
182
*endif
*if(strcmp(GenData(Analysis_Type),"PRESTRESS_STATIC")==0)
181
*endif
*if(strcmp(GenData(Analysis_Type),"BUCKLING")==0)
105
*endif
*if(strcmp(GenData(Analysis_Type),"NONLINEAR_BUCKLING")==0)
180
*endif 
*if(strcmp(GenData(Analysis_Type),"MODES")==0)
103
*endif 
*if(strcmp(GenData(Analysis_Type),"DIRECT_FREQUENCY_RESPONSE")==0)
111
*endif 
*if(strcmp(GenData(Analysis_Type),"DIRECT_TRANSIENT_RESPONSE")==0)
112
*endif 
*if(strcmp(GenData(Analysis_Type),"MODAL_FREQUENCY_RESPONSE")==0)
*MessageBox error: Modal frequency response is not supported by NE/NASATRAN
*endif 
*if(strcmp(GenData(Analysis_Type),"MODAL_TRANSIENT_RESPONSE")==0)
*MessageBox error: Modal transient response is not supported by NE/NASATRAN
*endif 
*if(strcmp(GenData(Analysis_Type),"NONLINEAR_STATIC")==0)
106
*endif 
*if(strcmp(GenData(Analysis_Type),"NONLINEAR_TRANSIENT")==0)
129
*endif
*if(strcmp(GenData(Analysis_Type),"STATIC")==0)
101
*endif 
*if(strcmp(GenData(Analysis_Type),"STEADY_STATE_HEAT_TRANSFER")==0)
101
ANALISYS = HEAT
*endif
TIME *GenData(TIME(min))
CEND
