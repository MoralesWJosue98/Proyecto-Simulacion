*if(strcmp(GenData(NL_Analysis),"Static")==0 || strcmp(GenData(NL_Analysis),"Buckling")==0 )
*format "NLPARM%10i%8i            "
*ID1*GenData(Num._increments,int)*GenData(Stiffness_method)*\
*if(strcmp(GenData(Stiffness_method),"ITER")==0)
*format "%8i"
*GenData(Iter_stiffness_update,int)*\
*else
	*\
*endif
*format "%8i"
*GenData(Max._iter._load_incremen,int)*\
*set var nconv=0
*if(strcmp(GenData(Displacement_Criteria),"YES")==0)
*set var nconv=nconv+1
*endif
*if(strcmp(GenData(Load_Criteria),"YES")==0)
*set var nconv=nconv+10
*endif
*if(strcmp(GenData(Work_Criteria),"YES")==0)
*set var nconv=nconv+100
*endif 
*if(nconv == 1)
       U*\
*endif
*if(nconv == 10)
       P*\
*endif
*if(nconv == 11)
      PU*\
*endif
*if(nconv == 100)
       W*\
*endif
*if(nconv == 101)
      WU*\
*endif  
*if(nconv == 110)
      WP*\
*endif
*if(nconv == 111)
     PWU*\
*endif  
*if(nconv==0)
	*\
*endif
     YES+
*format "+       %#8.2g%#8.2g%#8.2g%8i                                +"
*GenData(Disp._tolerance,real)*GenData(Load_tolerance,real)*GenData(Work_tolerance,real)*GenData(Max_iter._divergence)
+
*endif
*if(strcmp(GenData(NL_Analysis),"Dynamic")==0)
*format "TSTEPNL%9i%8i%8i%8i"
*ID1*GenData(Number_of_time_steps)*GenData(Time_increment)*GenData(Skip_factor_for_output)*\
*if(strcmp(GenData(Stiffness_method_dyn),"AUTO")==0)
    AUTO        *\
*endif
*if(strcmp(GenData(Stiffness_method_dyn),"TSTEP")==0)
*format "   TSTEP%8i"
*GenData(Iter_stiffness_update)*\
*endif
*if(strcmp(GenData(Stiffness_method_dyn),"ADAPT")==0)
   ADAPT        *\
*endif
*format "%8i"
*GenData(Max._iter._time_increment)*\
*set var nconv=0
*if(strcmp(GenData(Displacement_Criteria),"YES")==0)
*set var nconv=nconv+1
*endif
*if(strcmp(GenData(Load_Criteria),"YES")==0)
*set var nconv=nconv+10
*endif
*if(strcmp(GenData(Work_Criteria),"YES")==0)
*set var nconv=nconv+100
*endif 
*if(nconv == 1)
       U+
*endif
*if(nconv == 10)
       P+
*endif
*if(nconv == 11)
      PU+
*endif
*if(nconv == 100)
       W+
*endif
*if(nconv == 101)
      WU+
*endif  
*if(nconv == 110)
      WP+
*endif
*if(nconv == 111)
     PWU+
*endif  
format "+       %#8.2g%#8.2g%#8.2g%8i                                +"
*GenData(Disp._tolerance)*GenData(Load_tolerance)*GenData(Work_tolerance)*GenData(Max_iter._divergence)
+
if(strcmp(GenData(Stiffness_method_dyn),"ADAPT")==0)
format"               %8i"
*GenData(Skip_factor_time_adjust)
*endif