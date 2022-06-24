

package require customLib_utils
package require ncgi

namespace eval b_write_calc_file {
    variable doc
}

################################################################################
#    main
################################################################################

proc b_write_calc_file::check_times_init {} {
    stime::init
    stime::register ::b_write_calc_file::writeCalcFile "writeCalcFile" \
        ::gid_groups_conds::check_groups_entities "writeCalcFile check_groups_entities" \
        ::write_calc_file::begin "writeCalcFile begin" \
        ::b_write_calc_file::write_loadcases "writeCalcFile write_loadcases" \
        ::b_write_calc_file::write_materials_meshes "writeCalcFile write_materials_meshes" \
        ::b_write_calc_file::write_constraints "writeCalcFile write_constraints" \
        ::b_write_calc_file::write_loads "writeCalcFile write_loads"
}

proc b_write_calc_file::check_times_end {} {

    tk_messageBox -message [stime::print]
}

proc b_write_calc_file::writeCalcFile { _doc file } {
    variable doc
    variable tablesList
    
    set doc $_doc

    #check_times_init

    #gid_groups_conds::check_groups_entities

    #check_values

    set root [$doc documentElement]
#     set fout [open $file w]
#     write_calc_file::begin -local_axes -doc $doc $fout
#     namespace import ::write_calc_file::*

    set tablesList ""

    GiD_WriteCalculationFile init $file
    write_header $root
    write_loadcases $root
    write_materials_meshes $root
    write_detailed_results $root
    write_constraints $root
    write_loads $root
    write_dynamic_conditions $root
    #HIDDEN IN LS-DYNA BECAUSE IT WRITES A BLANK LINE
    #GiD_WriteCalculationFile puts [join $tablesList \n]
    write_output_data $root
    GiD_WriteCalculationFile end
#     write_calc_file::end
#     close $fout

    #check_times_end
}

proc b_write_calc_file::check_values {} {
    variable doc

    sqlite3 db :memory:
    db eval { PRAGMA synchronous=OFF }
    db eval { create table myvalues(name text primary key,node text) }
    _add_values_to_db db [$doc selectNodes /*]
    db close
}

proc b_write_calc_file::_add_values_to_db { db domNode } {
    switch -- [$domNode nodeName] {
        value {
            set n [$domNode @n]
            set err [catch { $db eval { insert
                        into myvalues values($n,$domNode) } } errstring]
            if { $err } {
                error "error when inserting value n=$n ($errstring)"
            }
        }
        condition {
            # nothing
        }
        default {
            if { [$domNode nodeName] eq "blockdata" && 
                [$domNode @sequence 0] == 1 } { return }
            foreach node [$domNode childNodes] {
                _add_values_to_db $db $node
            }
        }
    }
}

proc b_write_calc_file::get_value { name } {
    variable doc

    set node [$doc selectNodes [format_xpath {//value[@n=%s]} $name]]
    return [get_domnode_attribute $node v]
}

################################################################################
#    header
################################################################################

proc b_write_calc_file::write_header { root } {
    global lsdynaPriv
    
    set navalFlag 0
    set problem_type [get_value Problem_type]
    
    set vs [list X Y Z] 

    GiD_WriteCalculationFile puts -nonewline "*KEYWORD"
    #GiD_WriteCalculationFile puts "*TITLE"
    
    GiD_WriteCalculationFile puts -nonewline "\n$\n$ oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo\n$"
    GiD_WriteCalculationFile puts -nonewline "\n$ GiD/LS-DYNA INTERFACE, BETA VERSION"
    GiD_WriteCalculationFile puts -nonewline "\n$ Units: N m s rad Kg (SI)"  
    
    set L_mesh [get_value units_mesh]
    set xp [format_xpath {units/unit_magnitude[@n=%s]/unit[@n=%s]} \
            L $L_mesh]
    set L_mesh_fac [$root getAttributeP $xp factor]

    GiD_WriteCalculationFile puts -nonewline "\n$ Mesh factor: $L_mesh_fac" 
    GiD_WriteCalculationFile puts -nonewline "\n$\n$ oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo\n$"
    
    #############
    # Another Units point of view (User choose output units), possibly needed in future options
    #############

    
#     foreach i "F L M T Rotation Temp" n [list units_force units_length units_mass units_time units_rotation units_temperature] {
#         set $i [get_value $n]
#         # I HAVE PROBLEMS WRITING FACTORS, CAUSE THE SAME 'n' HAS DIFFERENT FACTORS DEPENDING IF SI OR IMPERIAL SYSTEM IS SELECTED
#         # set xp [format_xpath {units/unit_magnitude[@n=%s]/unit[@n=%s]} \
#             # $i [set $i]]
#         # set ${i}_fac [$root getAttributeP $xp factor]
#     }
#     
#     # set P_fac [expr {$F_fac/double($L_fac*$L_fac)}]
# 
# 
#     #MODULE TO KNOW IF THEY ARE CONSISTENT UNITS
#     
#     if {$F=="N"} {
#         if {$T!="s" || $M=="lb"} {error [= "Force units must be consistent (1 force unit = 1 mass unit x 1 acceleration unit)"]}
#         if {$M=="kg" && $L!="m"} {error [= "Force units must be consistent (1 force unit = 1 mass unit x 1 acceleration unit)"]}
#         if {$M=="ton" && $L!="mm"} {error [= "Force units must be consistent (1 force unit = 1 mass unit x 1 acceleration unit)"]}
#         if {$M=="g" && $L!="km"} {error [= "Force units must be consistent (1 force unit = 1 mass unit x 1 acceleration unit)"]}
#     }
#     
#     if {$F=="kN"} {
#         if {$T!="s" || $M=="lb" || $M=="g"} {error [= "Force units must be consistent (1 force unit = 1 mass unit x 1 acceleration unit)"]}
#         if {$M=="ton" && $L!="m"} {error [= "Force units must be consistent (1 force unit = 1 mass unit x 1 acceleration unit)"]}
#         if {$M=="kg" && $L!="km"} {error [= "Force units must be consistent (1 force unit = 1 mass unit x 1 acceleration unit)"]}
#     } 
#     if {$F=="kp" || $F=="lb-f" || $F=="Tmf"} {error [= "Force units must be consistent (1 force unit = 1 mass unit x 1 acceleration unit)"]}
#     
#     GiD_WriteCalculationFile puts -nonewline "\n$ Units: $F $L $M $T $Rotation $Temp"    
    
    
    #WRITING CONTROL SOLUTION (Not necessary at the moment)
    
#     GiD_WriteCalculationFile puts -nonewline "\n*CONTROL_SOLUTION\n$\n$----SOLN-----------\n$" 
#     GiD_WriteCalculationFile puts "\n[format "%8d" [get_value Solution_procedure]]"

    #WRITING CONTROL HOURGLASS AND BULK VISCOSITY IF NEEDED

    set xp {blockdata[@n="General data"]/container[@n="Bulk_viscosity"]/value[@n="Activation"]}
    set valueNode [$root selectNodes $xp]
    set bulk_activation [gid_groups_conds::convert_value_to_default $valueNode]

    if {$bulk_activation=="1"} {

        GiD_WriteCalculationFile puts -nonewline "\n*CONTROL_BULK_VISCOSITY\n$------Q1-------Q2-----TYPE-----\n"
        
        foreach j [list Default_linear_bulk Default_quadratic_bulk] {

            set xp {blockdata[@n="General data"]/container[@n="Bulk_viscosity"]/value[@n="$j"]}
            set xp [subst -nocommands $xp]
            set valueNode [$root selectNodes $xp]
            GiD_WriteCalculationFile puts -nonewline "[format "%8g" [$valueNode @v]],"
        }

        GiD_WriteCalculationFile puts -nonewline "\n*CONTROL_HOURGLASS\n$-----IHQ-------QH---------"
        
        set xp {blockdata[@n="General data"]/container[@n="Bulk_viscosity"]/value[@n="Default_hourglass_type"]}
        set valueNode [$root selectNodes $xp]
        GiD_WriteCalculationFile puts -nonewline "\n[format "%8d" [$valueNode @v]],"

        set xp {blockdata[@n="General data"]/container[@n="Bulk_viscosity"]/value[@n="Default_hourglass_coefficient"]}
        set valueNode [$root selectNodes $xp]
        GiD_WriteCalculationFile puts -nonewline "[format "%8g" [$valueNode @v]]"
    }
    
    #WRITING CONTROL CPU

    set xp {blockdata[@n="General data"]/container[@n="Solver"]/value[@n="CPU_time"]}
    set valueNode [$root selectNodes $xp]
    set cpu_time [gid_groups_conds::convert_value_to_default $valueNode]

    if {$cpu_time>"0"} {        
        GiD_WriteCalculationFile puts -nonewline "\n*CONTROL_CPU"
        GiD_WriteCalculationFile puts -nonewline "\n$\n$---CPUTIM------------\n$"
        GiD_WriteCalculationFile puts -nonewline "\n[format "%8g" $cpu_time]"        
    }   
    
    
    #WRITING CONTROL TIMESTEP

    set xp {blockdata[@n="General data"]/container[@n="Solver"]/value[@n="Dt_Comp"]}
    set valueNode [$root selectNodes $xp]
    set dcomp [$valueNode @v]

    set xp {blockdata[@n="General data"]/container[@n="Solver"]/value[@n="Time_mass_scaled"]}
    set valueNode [$root selectNodes $xp]
    set time_mass_scaled [gid_groups_conds::convert_value_to_default $valueNode]

    if {$dcomp>"0" || $time_mass_scaled>"0"} {
        
        GiD_WriteCalculationFile puts -nonewline "\n*CONTROL_TIMESTEP"
        GiD_WriteCalculationFile puts -nonewline "\n$\n$--DTINIT---TSSFAC----ISDO---TSLIMT----DT2MS-----LCTM----ERODE----MSIST---------\n$"
        GiD_WriteCalculationFile puts -nonewline "\n        ,[format "%8g" $dcomp],        ,        ,[format "%8g" $time_mass_scaled]"
        
    }

    #WRITING CONTROL TERMINATION

    set xp {blockdata[@n="General data"]/container[@n="Solver"]/value[@n="End_time"]} 
    set valueNode [$root selectNodes $xp]
    set time [gid_groups_conds::convert_value_to_default $valueNode]

    set xp {blockdata[@n="General data"]/container[@n="Solver"]/value[@n="End_cycles"]}
    set valueNode [$root selectNodes $xp]
    set cycles [$valueNode @v]

    set xp {blockdata[@n="General data"]/container[@n="Solver"]/value[@n="Dt_Min"]}
    set valueNode [$root selectNodes $xp]
    set dtmin [$valueNode @v]

    set xp {blockdata[@n="General data"]/container[@n="Solver"]/value[@n="End_Energy_ratio"]}
    set valueNode [$root selectNodes $xp]
    set energy [$valueNode @v]

    set xp {blockdata[@n="General data"]/container[@n="Solver"]/value[@n="End_Total_Mass"]}
    set valueNode [$root selectNodes $xp]
    set mass [$valueNode @v]
            
    GiD_WriteCalculationFile puts "\n*CONTROL_TERMINATION"
    GiD_WriteCalculationFile puts "$\n$--ENDTIM---ENDCYC---DTMIN---ENDENG---ENDMAS---------\n$"
    GiD_WriteCalculationFile puts "[format "%8g" $time],[format "%8d" $cycles],[format "%8g" $dtmin],[format "%8g" $energy],[format "%8g" $mass]"
    
    #WRITING GRAVITY
    
    set xp {blockdata[@n="General data"]/container[@n="Gravity"]/value[@n="Active_gravity"]} 
    set valueNode [$root selectNodes $xp]
    set activation [$valueNode @v]
    
    if  {$activation} {
        set xp {blockdata[@n="General data"]/container[@n="Gravity"]/value[@n="Gravity_Magnitude"]} 
        set valueNode [$root selectNodes $xp]
        set g [gid_groups_conds::convert_value_to_default $valueNode]
        if {$g<0} {
            error [= "Invalid Gravity"]
        } else {
            set direction [get_value Gravity_Direction]
            foreach i $vs {
                if { $direction=="$i-" } { 
                    GiD_WriteCalculationFile puts "*LOAD_BODY_$i"
                    GiD_WriteCalculationFile puts "$\n$-----LCID--------SF-------XC------YC-----ZC-------CID------\n$"
                    GiD_WriteCalculationFile puts "[format "%8d" 1],[format "-%-8g" $g],        ,        ,       ,[format "%8d" 0]" 
                }
                if { $direction=="$i+" } { 
                    GiD_WriteCalculationFile puts "*LOAD_BODY_$i"
                    GiD_WriteCalculationFile puts "$\n$-----LCID--------SF--------LCID------XC------YC-----ZC-------CID------\n$"
                    GiD_WriteCalculationFile puts "[format "%8d" 1],[format "%8g" $g],        ,        ,         ,[format "%8d" 0]" 
                }          
            }
        }        
        
    }
    
    #WRITING DYNAMIC RELAXATION (IF NEEDED)
    
    set xp {blockdata[@n="General data"]/container[@n="Dynamic_relaxation"]/value[@n="Activation"]} 
    set valueNode [$root selectNodes $xp]
    set activation [$valueNode @v]
    
    if  {$activation=="1"} {
        
        GiD_WriteCalculationFile puts "*CONTROL_DYNAMIC_RELAXATION"        
        
        foreach i [list Check_iterations Tolerance Relaxation_factor Timestep_factor] j [list NRCYCK DRTOL DRFCTR TSSFDR] {  
          
            set xp ".//value\[@n='${i}'\]"
            set xp [subst -nocommands $xp]
            set valueNode [$root selectNodes $xp]
            set $j [format %8g [$valueNode @v]]

        }
        
        GiD_WriteCalculationFile puts "$\n$--NRCYCK----DRTOL---DRFCTR---DRTERM---TSSFDR---IRELAL----EDTTL---IDRFLG-----------\n$"
        GiD_WriteCalculationFile puts "$NRCYCK,$DRTOL,$DRFCTR,        ,$TSSFDR" 
    }
    
    #WRITING CONTROL SHELL CARD
    
    GiD_WriteCalculationFile puts "*CONTROL_SHELL" 
    
    set xp {blockdata[@n="General data"]/container[@n="Shell_preferences"]/value[@n="Warpage_angle"]} 
    set valueNode [$root selectNodes $xp]
    set warpage_rad [gid_groups_conds::convert_value_to_default $valueNode]
    
    #Warpage is expressed in degrees
    
    set WRPANG [expr ($warpage_rad/0.017453292519943)]
    
    set xp {blockdata[@n="General data"]/container[@n="Shell_preferences"]/value[@n="Element_sorting"]} 
    set valueNode [$root selectNodes $xp]
    set ESORT [$valueNode @v]
    
    GiD_WriteCalculationFile puts "$\n$--WRPANG----ESORT-----" 
    GiD_WriteCalculationFile puts "[format "%8g" $WRPANG],[format "%8d" $ESORT]" 
    
    #WRITING DEFAULT CURVE (CONSTANT VALUES)
    
    GiD_WriteCalculationFile puts "*DEFINE_CURVE\n$\n$----LCID-----SIDR-----------SFA-------------SFO-----------\n$"
    GiD_WriteCalculationFile puts "[format "%8d" 1],[format "%8d" 0],[format "%8g" 1.0],[format "%8g" 1.0]" 
    GiD_WriteCalculationFile puts "$\n$-----------------AI----------------------OI------------\n$"
    GiD_WriteCalculationFile puts -nonewline "[format "%20E" 0.0],[format "%20E" 1.0]\n[format "%20E" $time],[format "%20E" 1.0]\n[format "%20E" [expr (2*$time)]],[format "%20E" 1.0]"
    
}       


proc b_write_calc_file::files_to_copy_to_remote_server {} {

    set files ""
    set root [gid_groups_conds::give_root_node]

    set xp {/*/blockdata[@n="General data"]/}
    append xp {container[@n='Tdyn_coupling']/value[@n='Tdyn_filename']}
    set valueNode [$root selectNodes $xp]
    set filename [get_domnode_attribute $valueNode v]
    if { $filename ne "" } {
        if { ![file exists $filename] } {
            error [= "File '%s' does not exists for Tdyn coupling" $filename]
        }
        lappend files $filename
        set f [file root $filename].msh
        if { [file exists $f] } { lappend files $f }
    }
    return $files
}

proc b_write_calc_file::write_dynamic_non_linear_header { root } {

    if { [get_value Analysis_Type] eq "Linear_Static" } { return }

################################################################################
#    LINEAR DYNAMIC ANALYSIS
################################################################################
    
    if { [get_value Analysis_Type] eq "Linear_Dynamic" } {
        GiD_WriteCalculationFile puts "dynamic_analysis_type [get_value Dynamic_Analysis_Type]"

        switch [get_value Dynamic_Analysis_Type] {
            Modal_Analysis {
                set p [list Number_of_Modes Eigen_max_iter DeltaT \
                        Number_of_steps Matrix_storage Damping_Type]
            }
            Direct_Integration {
                set p [list DeltaT Number_of_steps Gamma Beta Matrix_storage \
                        Damping_Type]
            }
            Spectrum_Analysis {
                set p [list Number_of_Modes Eigen_max_iter Matrix_storage \
                        Damping_Type Spectrum_Analysis_type]
            }
        }
        foreach i $p {
            GiD_WriteCalculationFile puts "[string tolower $i] [get_value $i]"
        }
        if { [get_value Damping_Type] eq "Rayleigh_Damping" } {
            GiD_WriteCalculationFile puts "alpha_m [get_value Alpha_M]"
            if { [get_value Matrix_storage] eq "Lumped" } {
                GiD_WriteCalculationFile puts "alpha_k 0.0"
            } else {
                GiD_WriteCalculationFile puts "alpha_k [get_value Alpha_K]"
            }
        } else {
            if { [get_value Dynamic_Analysis_Type] eq "Direct_Integration" } {
                error [= "Only Rayleigh Damping is allowed for Direct Integration"]
            }
            GiD_WriteCalculationFile puts "damping_ratio [get_value Damping_ratio]"
        }
        if { [get_value Dynamic_Analysis_Type] eq "Spectrum_Analysis" } {
            if { [get_value Spectrum_Analysis_type] eq "User_defined_spectrum" } {
                set xp {//value[@n="Spectrum_Table"]/function/functionVariable}
                set fvNode [$root selectNodes $xp]
                if { $fvNode eq "" } {
                    error [= "error: There is no spectrum table defined"]
                }
                set values [$fvNode selectNodes value]
                if { [llength $values] < 1} {
                    error [= "error: Spectrum table does not contain enough data"]
                }
                GiD_WriteCalculationFile puts "begin_spectral_table"
                set last_t ""
                foreach v $values {
                    foreach "t f" [split [$v @v] ,] break
                    if { $last_t ne "" && $t <= $last_t } {
                        error [= "error: Spectrum table must have increasing times"]
                    }
                    GiD_WriteCalculationFile puts "$t $f"
                }
                GiD_WriteCalculationFile puts "end_table"
                foreach i [list x y z] {
                    set xp [format_xpath {//value[@n=%s]} Spectrum_direction_n$i]
                    set valueNode [$root selectNodes $xp]
                    set v [gid_groups_conds::convert_value_to_default $valueNode]
                    GiD_WriteCalculationFile puts "j$i $v"
                }
            } elseif { [get_value Spectrum_Analysis_type] eq "Seismic_codes" } {
                if { [get_value Code_type] eq "NCSE-94_Spain_Code" } {
                    GiD_WriteCalculationFile puts "code_type NCSE-94"
                    set xp {//value[@n="Design_Seismic_Acceleration"]}
                    set valueNode [$root selectNodes $xp]
                    set v [gid_groups_conds::convert_value_to_default $valueNode]
                    GiD_WriteCalculationFile puts "design_acceleration $v"
                    foreach i [list x y z] {
                        GiD_WriteCalculationFile puts "j$i [get_value Seismic_direction_n$i]"
                    }
                    foreach i "c k ductility" j [list Soil_coefficient \
                            Contribution_coefficient Ductility] {
                        GiD_WriteCalculationFile puts "$i [get_value $j]"
                    }
                } else {
                    error [= "Other Seismic codes are not still available"]
                }
            } else {
                error "unknown Spectrum_Analysis_type=[get_value Spectrum_Analysis_type]"
            }
        } else {
            GiD_WriteCalculationFile puts "initial_conditions [get_value Initial_Conditions]"
        }
    } elseif { [get_value Analysis_Type] eq "Non-Linear_Static" } {
        foreach i [list factor_incremental number_increments \
                automatic_increment control_type convergence_tolerance_fact \
                iteration_type maximun_iter_number line_search auto_arc_switch] \
            j [list Delta_Fac Num_inc Automatic_inc Control \
                Conv._tolerance_static Iteration_type Max_iter Line-Search Auto-ARC-switch] {
            GiD_WriteCalculationFile puts "$i [get_value $j]"
        }
        if { [get_value Automatic_inc] } {
            foreach i [list number_iteration_desider maxim_load_increment \
                    minim_load_increment] j [list Num_Iter_d DeltaP_max DeltaP_min] {
                GiD_WriteCalculationFile puts "$i [get_value $j]"
            }
        }
        if { [get_value Control] eq "Arc-length_Control" } {
            foreach i [list desired_length_inc max_lenght_inc \
                    min_length_inc] j [list DeltaL_d DeltaL_max DeltaL_min] {
                GiD_WriteCalculationFile puts "$i [get_value $j]"
            }
        }
        if { [get_value Line-Search] } {
            foreach i [list max_num_ls_loops tolerance_ls \
                    min_step_length max_step_length max_amplitude] \
                j [list LS-loops LS-toler LS-min LS-max Amp-max] {
                GiD_WriteCalculationFile puts "$i [get_value $j]"
            }
        }
        if { [get_value Auto-ARC-switch] } {
           foreach i [listdesired_current_stiffness] \
                j [list C_Stif] {
                GiD_WriteCalculationFile puts "$i [get_value $j]"
            }
        }
    } elseif { [get_value Analysis_Type] eq "Non-Linear_Dynamic" } {
        if { [get_value Integration_method] eq "Implicit" } {
            GiD_WriteCalculationFile puts "integration_method implicit"
            GiD_WriteCalculationFile puts "t_0 [get_value T_0]"

            set xp {//value[@n="DeltaT_variation"]}
            set valueNode [$root selectNodes $xp]
            set fvNode [$valueNode selectNodes {function/functionVariable}]
            if { $fvNode eq "" } {
                error [= "error: There is no Delta t variation table defined"]
            }
            set values [$fvNode selectNodes value]
            if { [llength $values] < 1} {
                error [= "error: Delta t variation table does not contain enough data"]
            }
            GiD_WriteCalculationFile puts "deltat_groups [llength $values]"
            set nsteps 0
            foreach v $values {
                foreach "nstep deltat" [split [$v @v] ,] break
                set deltat [gid_groups_conds::convert_v_to_default $deltat \
                        T [$valueNode @units]]
                GiD_WriteCalculationFile puts "$nstep $deltat"
                incr nsteps $nstep
            }
            GiD_WriteCalculationFile puts "number_of_steps $nsteps"
            foreach i [list gamma beta matrix_storage initial_conditions alpha_m \
                    alpha_k convergence_tolerance_fact iteration_type \
                    maximun_iter_number] \
                j [list Gamma_NL Beta_NL Matrix_storage_NL Initial_Conditions_NL \
                    Alpha_M_NL Alpha_K_NL Conv._tolerance_dynamic \
                    Iteration_type_NL Max_iter_NL] {
                GiD_WriteCalculationFile puts "$i [get_value $j]"
            }
            if { [get_value Initial_Conditions] eq "Comb._Load_1" } {
                GiD_WriteCalculationFile puts "Comb_Load_1_data [get_value Comb_Load_1_data]"
            }
        } elseif { [get_value Integration_method] eq "Explicit" } {
            GiD_WriteCalculationFile puts "integration_method explicit"
            foreach i [list t_0 deltat number_of_steps initial_conditions \
                    alpha_m] \
                j [list T_0 Delta_T Number-of-steps Initial_Conditions_NL \
                    Alpha_M_NL] {
                GiD_WriteCalculationFile puts "$i [get_value $j]"
            }
            GiD_WriteCalculationFile puts "matrix_storage lumped"
            if { [get_value Initial_Conditions] eq "Comb._Load_1" } {
                GiD_WriteCalculationFile puts "Comb_Load_1_data [get_value Comb_Load_1_data]"
            }
            GiD_WriteCalculationFile puts "alpha_k 0.0"
        } else {
            error "error: Integration_method=[get_value Integration_method]"
        }
    } elseif { [get_value Analysis_Type] ne "Linear_Static" } {
        error "error: Analysis_Type=[get_value Analysis_Type]"
    }
    set nres 0
    foreach res [list Displacements Rotations Velocities Accelerations \
            Strengths Reactions ElemDamage] {
        GiD_WriteCalculationFile puts "write_[string tolower $res] [get_value Write_$res]"
        if { [get_value Write_$res] } { incr nres }
    }
    GiD_WriteCalculationFile puts "output_step [get_value Output_Step]"
    if { $nres == 0 } {
        error [= "error: It is necesary to write at least one result. Check General data->Dynamic output"]
    }
}

################################################################################
#    Load cases
################################################################################

proc b_write_calc_file::write_loadcases { root } {
    set problem_type [get_value Problem_type]

    set xp {container[@n='loadcases']/container[@n='combined_loadcases']/blockdata}
    set loadcasesNodes [$root selectNodes $xp]
    #GiD_WriteCalculationFile puts "combined_load_cases"
    if { ![llength $loadcasesNodes] } {
        #GiD_WriteCalculationFile puts "inactive"
    } else {
        GiD_WriteCalculationFile puts "active"
        foreach lcNode $loadcasesNodes {
            regsub -all {\s+} [$lcNode @name] {_} name
            GiD_WriteCalculationFile puts -nonewline "combined_load name=$name type="
            switch [$lcNode @comb_type] {
                ELU { GiD_WriteCalculationFile puts -nonewline "strengths" }
                ELS { GiD_WriteCalculationFile puts -nonewline "deformation" }
            }
            GiD_WriteCalculationFile puts ""
            set list ""
            foreach v [$lcNode selectNodes value] {
                regsub -all {\s+} [$v @name] {_} name
                lappend list [$v @v] $name
            }
            GiD_WriteCalculationFile puts [join $list ,]
            GiD_WriteCalculationFile puts "end combined_load"
        }
    }
    #GiD_WriteCalculationFile puts "end combined_load_cases"
}

################################################################################
#    Materials
################################################################################

proc b_write_calc_file::write_materials_meshes { root } {

    set laminNames ""
    set xp {container[@n="Properties"]/container[@n="Shells"]/condition[@n="Laminate_shell"]/group}
    foreach gNode [$root selectNodes $xp] {
        if { [dict exists $groupsS [$gNode @n]] } {
            error [= "There are repeated groups in the shell properties"]
        }
        dict set groupsS [$gNode @n] $nmat
        set laminFlag [lindex $groupsS 0]
        lappend laminNames $laminFlag
    }
    if {$laminNames != ""} {
        GiD_WriteCalculationFile puts "Laminate"
    }
    
    set nmat 1
    
    set change_keyword [dict create Specific_weight Weight W_y Wy W_z Wz \
            Inertia_y Iy Inertia_z Iz Thickness t \
            steel_section_name Section steel_material Steel Z_axe_position z_axe \
            Elastic_limit plasticity_shell Saturation_flow_stress "" \
            Saturation_hardening_law_exponent "" Linear_hardening "" \
            Linear_kinematic_hardening "" StiffDm Dm StiffDf Df StiffDmf Dmf StiffDc Dc \
            StiffWeight Weight StiffMaxstress Maximum_Stress StiffWx Wx StiffWy Wy \
            StiffWt Wt StiffAx Ax StiffAy Ay StiffAt At StiffAtx Atx StiffAty Aty \
            area Area weight Weight iyy Iy izz Iz j J g G units Units \
            e E laminate_properties laminate]

    set no_print [list Material Isotropic_hardening Kinematic_hardening \
            win_info Layer_number Units matlist lamlist mathick \
            section_prop section_info mat_prop lamprop comprop layersList laminatesList \
            StiffThickness StiffClearance StiffDirection StiffMat \
            laminates StiffName numero_de_capas thickness]


    #IN THIS LSDYNA VERSION, GROUPS CONTACTS ARE NOT MATERIALS SECTION
    set groupsContact ""

##################################PART DATA INITIALITATION####################################################

    global part_info    
    #MAT INFO IS GLOBAL A CAUSE OF CARDS LIKE *BOUNDARY_PRESCRIBED_MOTION_RIGID
    global mat_info
    
    global curve_num
    set curve_num 1

    set part_info ""
    set mat_info ""
    
    set part_num 0
    set mat_num 0

    set hourglass_num 0

#####################################WRITING SOLID PARTS#####################################################

    set groupsV ""

    #Set_num is a global variable because it is used in loads and constraints
    global set_num
    set set_num 0

    set section_info_solids ""
    set xp {container[@n="Properties"]/container[@n="Solids"]/condition/group}
    
    ###### Start writing *PART, Preparing *SECTION_SOLID and Start Preparing *MAT_ELASTIC ########
 
    set section_solids_num 0
    set set_solid_definition 0
    
    foreach gNode [$root selectNodes $xp] {
        if { [dict exists $groupsV [$gNode @n]] } {
            error [= "There are repeated groups in the solid properties"]
        }
        
        incr part_num
        dict set groupsV [$gNode @n] $part_num

        #PARTS MATCH GiD GROUPS, THAT'S WHY THEY ARE NOT SIMPLIFIED
        
        dict set part_info [$gNode @n] PID "[format %8d $part_num]"
        
        set xp ".//value\[@n='m']"
        set valueNode [$gNode selectNodes $xp]
        set mass [get_domnode_attribute $valueNode v]
        
        #We write only not inertia parts
        if {$mass=="0"} {
            GiD_WriteCalculationFile puts -nonewline "\n*PART\n$-----PID---SECID-----MID--------\nPart $part_num Header\n[format %8d $part_num],"  
            dict set part_info [$gNode @n] TM 0
        } else {
            #We read inertia properties
            
            set mass [format %8g [gid_groups_conds::convert_value_to_default $valueNode]]
            dict set part_info [$gNode @n] TM $mass
            
            set xp ".//value\[@n='Define_center']"
            set valueNode [$gNode selectNodes $xp]
            set center [get_domnode_attribute $valueNode v]
            dict set part_info [$gNode @n] CENTER $center
            
            switch $center {
                1 {
                    set list_names [list Ixx Iyy Izz Ixy Ixz Iyz xc yc zc]
                    set list_variables [list IXX IYY IZZ IXY IXZ IYZ XC YC ZC]
                }
                0 {
                    set list_names [list Ixx Iyy Izz Ixy Ixz Iyz]
                    set list_variables [list IXX IYY IZZ IXY IXZ IYZ]
                }
            }
            
            foreach i $list_names j $list_variables {
                
                set xp ".//value\[@n='$i']"
                set valueNode [$gNode selectNodes $xp]   
                dict set part_info [$gNode @n] $j "[format %8g [gid_groups_conds::convert_value_to_default $valueNode]]"   
            }
        }
        
        set xp ".//value\[@n='Ambient_element']"
        set valueNode [$gNode selectNodes $xp]
        
        set ambient_v [format %8d [get_domnode_attribute $valueNode v]]
        set ambient_state [$valueNode @state]
        
        set xp ".//value\[@n='Element_formulation']"
        set valueNode [$gNode selectNodes $xp]
        set formulation [format %8d [get_domnode_attribute $valueNode v]]
        
        #TO AVOID SECTION_SOLID REPETITION     

        set section_found 0

        dict for {sid info} $section_info_solids {
            if {!$section_found} {
                set section_exists 1
                dict with info {
                    if { $ELFORM!=$formulation } { set section_exists 0 }
                    if { $ambient_state=="normal" && $AET!=$ambient_v } { set section_exists 0 }
                    if { $section_exists } {
                        dict set part_info [$gNode @n] SID "[format %8d $sid]"
                        if {$mass=="0"} {
                            GiD_WriteCalculationFile puts -nonewline "[format %8d $sid],"
                        }
                        set section_found 1
                    }
                }
            }
        }
        
        if {!$section_found || $section_solids_num=="0"} {
            
            incr section_solids_num
            dict set section_info_solids "$section_solids_num" ELFORM "$formulation"
            dict set section_info_solids "$section_solids_num" ACTIVATION "$ambient_state"
            dict set section_info_solids "$section_solids_num" AET "$ambient_v"
            
            dict set part_info [$gNode @n] SID "[format %8d $section_solids_num]"
            if {$mass=="0"} {
                GiD_WriteCalculationFile puts -nonewline "[format %8d $section_solids_num],"
            }
        } 
        
        #SAVING MATERIAL DATA
        
        set aux [save_materials $root $gNode $mat_info $mat_num 0 $mass 0]

        #WRITING *HOURGLASS CARD IF NEEDED

        set hourglass_id [write_hourglass $gNode $hourglass_num $mass]  

        #WRITING *SET_SOLID IF NEEDED

        set xp ".//value\[@n='Create_set']"
        set valueNode [$gNode selectNodes $xp]
        set activate_set [get_domnode_attribute $valueNode v]

        if {$activate_set=="1"} {

            incr set_solid_definition 
            
            GiD_WriteCalculationFile puts -nonewline "\n*SET_SOLID\n$-----SID-----\n[format "%8d" $set_solid_definition]"
            GiD_WriteCalculationFile puts -nonewline "\n$------K1-------K2-------K3-------K4-------K5-------K6-------K7-------K8----" 
            set groupsSetSolid ""

            dict set groupsSetSolid [$gNode @n] $set_solid_definition     
                    
            set isquadratic [lindex [GiD_Info Project] 5]                   
                                   
            foreach elemtype [list Tetrahedra Hexahedra] {
                
                switch $elemtype {                
                    Tetrahedra {
                        switch $isquadratic {
                            0 { set nnode 4 }
                            1 { set nnode 10 }
                            2 { set nnode 10 }
                        }
                    }
                    Hexahedra {
                        switch $isquadratic {
                            0 { set nnode 8 }
                            1 { set nnode 20}
                            2 { set nnode 27}
                        }
                    }
                }
                
                set formats ""

                #WE PRINT ONLY THE ELEMENT NUMBER IN EACH LINE
                set f "\n%8d"

                set nodenum 1
                
                while { $nodenum<=$nnode } {
                    append f "%0.s"
                    set nodenum [expr ($nodenum+1)]
                }

                set nodenum 1
 
                while { $nodenum<="7" } {
                    append f ",       0"
                    set nodenum [expr ($nodenum+1)]
                }
                
                set f [subst -novariables $f] 
                            
                dict for "n v" $groupsSetSolid {
                    dict set formats $n "$f"
                }
                
                if { [GiD_WriteCalculationFile has_elements -elemtype $elemtype $formats] } {
                    set SetSolid_elements [GiD_WriteCalculationFile connectivities -elemtype $elemtype $formats]
                }
            }  
        } 
    }
    
    #####################################WRITING SHELL PARTS#####################################################
    
    
    set groupsS ""
    
    set section_info_shells ""
    set xp {container[@n="Properties"]/container[@n="Shells"]/condition/group}
    set xp2 {container[@n="Properties"]/container[@n="Airbags"]/condition/groupList/group[1]}
    set xp3 {container[@n="Properties"]/container[@n="Airbags"]/condition/groupList/group[2]}
    
    ##### Continue writing *PART, Preparing *SECTION_SHELL and Continue Preparing *MAT_ELASTIC ########
    
    set section_shells_num 0
    
    foreach gNode [$root selectNodes "$xp|$xp2|$xp3"] {
        
        if { [dict exists $groupsS [$gNode @n]] } {
            error [= "There are repeated groups in the shell properties"]
        }
        
        incr part_num
        dict set groupsS [$gNode @n] $part_num
        
        dict set part_info [$gNode @n] PID "[format %8d $part_num]"
            
        set mass 0

        set property_container [$gNode selectNodes {string(../../@n)}]

        #THERE IS NO MASS DATA IN AIRBAGS AT THE MOMENT
    
        if {$property_container!="Airbag"} {
            set xp ".//value\[@n='m']"
            set valueNode [$gNode selectNodes $xp]
            set mass [get_domnode_attribute $valueNode v]
        }       
 
        #We write only not inertia parts
        if {$mass=="0"} {
            GiD_WriteCalculationFile puts -nonewline "\n*PART\n$-----PID---SECID-----MID--------\nPart $part_num Header\n[format %8d $part_num],"  
            dict set part_info [$gNode @n] TM 0
        } else {
            #We read inertia properties
            
            set mass [format %8g [gid_groups_conds::convert_value_to_default $valueNode]]
            dict set part_info [$gNode @n] TM $mass
            
            set xp ".//value\[@n='Define_center']"
            set valueNode [$gNode selectNodes $xp]
            set center [get_domnode_attribute $valueNode v]
            dict set part_info [$gNode @n] CENTER $center
            
            switch $center {
                1 {
                    set list_names [list Ixx Iyy Izz Ixy Ixz Iyz xc yc zc]
                    set list_variables [list IXX IYY IZZ IXY IXZ IYZ XC YC ZC]
                }
                0 {
                    set list_names [list Ixx Iyy Izz Ixy Ixz Iyz]
                    set list_variables [list IXX IYY IZZ IXY IXZ IYZ]
                }
            }
            
            foreach i $list_names j $list_variables {
                
                set xp ".//value\[@n='$i']"
                set valueNode [$gNode selectNodes $xp]  
                set tensor [get_domnode_attribute $valueNode v]
                #To avoid units problems
                if {$tensor=="0.0"} {
                    dict set part_info [$gNode @n] $j 0 
                } else {
                    dict set part_info [$gNode @n] $j "[format %8g [gid_groups_conds::convert_value_to_default $valueNode]]"   
                }     
            }
        }
        
        #IN AIRBAGS WE HAVE DIFFERENT PATHS
        if {$property_container=="Airbag"} {
           set xp "..//value\[@n='Thickness']"
        } else {
            set xp ".//value\[@n='Thickness']"
        }
        
        set valueNode [$gNode selectNodes $xp]
        set thickness [format %8g [gid_groups_conds::convert_value_to_default $valueNode]]  

        if {$property_container=="Airbag"} {
            set xp "..//value\[@n='Element_formulation']"
        } else {
            set xp ".//value\[@n='Element_formulation']"
        }

        set valueNode [$gNode selectNodes $xp]
        set formulation [format %8d [get_domnode_attribute $valueNode v]]   


        foreach i [list Shear_factor Integration_points Reference_surface_factor] j [list shear_factor integration_points surface_factor] {
            if {$property_container=="Airbag"} {
                set xp "..//value\[@n='$i']"
            } else {
                set xp ".//value\[@n='$i']"
            }
            
            set valueNode [$gNode selectNodes $xp]
            set $j [format %8g [get_domnode_attribute $valueNode v]]
        }

        foreach i [list Thickness_field 2D_solid_element] j [list thickness_field_v 2D_v] k [list thickness_field_state 2D_state] {
            if {$property_container=="Airbag"} {
                set xp "..//value\[@n='$i']"
            } else {
                set xp ".//value\[@n='$i']"
            }
            set valueNode [$gNode selectNodes $xp]
            set $j [format %8d [get_domnode_attribute $valueNode v]]
            set $k [$valueNode @state]
        }
          
        #TO AVOID SECTION_SHELL REPETITION
        
        set section_found 0
              
        dict for {sid info} $section_info_shells {
            if {!$section_found} {
                set section_exists 1
                dict with info {
                    if { $ELFORM!=$formulation || $SHRF!=$shear_factor || $NIP!=$integration_points || $T1234!=$thickness || $NLOC!=$surface_factor } { set section_exists 0 }
                    if { $thickness_field_state=="normal" && $IDOF!=$thickness_field_v } { set section_exists 0 }  
                    if { $2D_state=="normal" && $SETYP!=$2D_v } { set section_exists 0 }
                    if { $section_exists } {
                        dict set part_info [$gNode @n] SID "[format %8d $sid]"
                        if {$mass=="0"} {
                            GiD_WriteCalculationFile puts -nonewline "[format %8d $sid],"
                        }
                        set section_found 1
                    }
                }
            }
        }
        
        if {!$section_found || $section_shells_num=="0"} {    
            incr section_shells_num
            dict set section_info_shells "[ expr { $section_solids_num + $section_shells_num }]" ELFORM "$formulation"
            dict set section_info_shells "[ expr { $section_solids_num + $section_shells_num }]" SHRF "$shear_factor"
            dict set section_info_shells "[ expr { $section_solids_num + $section_shells_num }]" NIP "$integration_points"
            dict set section_info_shells "[ expr { $section_solids_num + $section_shells_num }]" T1234 "$thickness"
            dict set section_info_shells "[ expr { $section_solids_num + $section_shells_num }]" NLOC "$surface_factor"
            dict set section_info_shells "[ expr { $section_solids_num + $section_shells_num }]" IDOF "$thickness_field_v"
            dict set section_info_shells "[ expr { $section_solids_num + $section_shells_num }]" ACTIVATION_IDOF "$thickness_field_state" 
            dict set section_info_shells "[ expr { $section_solids_num + $section_shells_num }]" SETYP "$2D_v" 
            dict set section_info_shells "[ expr { $section_solids_num + $section_shells_num }]" ACTIVATION_SETYP "$2D_state"
            
            dict set part_info [$gNode @n] SID "[format %8d [ expr { $section_solids_num + $section_shells_num }]]"
            if {$mass=="0"} {
                GiD_WriteCalculationFile puts -nonewline "[format %8d [ expr { $section_solids_num + $section_shells_num }]],"
            }
        }
        
        #SAVING MATERIAL DATA
        
        set aux [save_materials $root $gNode $mat_info $mat_num 0 $mass 0]

        #WRITING *HOURGLASS CARD IF NEEDED (DISABLED FOR AIRBAGS)

        if {$property_container!="Airbag"} {
            set hourglass_id [write_hourglass $gNode $hourglass_num $mass]  
        }
    }
    
    #########################WRITING BEAM PARTS##################################################

    set xp {container[@n="Properties"]/container[@n="Beams"]/condition/group}

    set groupsL ""
    set section_info_beams ""
    
    ##### Continue writing *PART, Preparing *SECTION_BEAM and Continue Preparing *MAT_ELASTIC ########
    
    set section_beams_num 0
    
    foreach gNode [$root selectNodes "$xp"] {
        
        if { [dict exists $groupsL [$gNode @n]] } {
            error [= "There are repeated groups in the beam properties"]
        }        
        
        incr part_num
        dict set groupsL [$gNode @n] $part_num
 
        dict set part_info [$gNode @n] PID "[format %8d $part_num]"
        set xp ".//value\[@n='m']"
        set valueNode [$gNode selectNodes $xp]
        set mass [get_domnode_attribute $valueNode v]
        
        #We write only not inertia parts
        if {$mass=="0"} {
            GiD_WriteCalculationFile puts -nonewline "\n*PART\n$-----PID---SECID-----MID--------\nPart $part_num Header\n[format %8d $part_num],"  
            dict set part_info [$gNode @n] TM 0
        } else {
            #We read inertia properties
            
            set mass [format %8g [gid_groups_conds::convert_value_to_default $valueNode]]
            dict set part_info [$gNode @n] TM $mass
            
            set xp ".//value\[@n='Define_center']"
            set valueNode [$gNode selectNodes $xp]
            set center [get_domnode_attribute $valueNode v]
            dict set part_info [$gNode @n] CENTER $center
            
            switch $center {
                1 {
                    set list_names [list Ixx Iyy Izz Ixy Ixz Iyz xc yc zc]
                    set list_variables [list IXX IYY IZZ IXY IXZ IYZ XC YC ZC]
                }
                0 {
                    set list_names [list Ixx Iyy Izz Ixy Ixz Iyz]
                    set list_variables [list IXX IYY IZZ IXY IXZ IYZ]
                }
            }
            
            foreach i $list_names j $list_variables {
                
                set xp ".//value\[@n='$i']"
                set valueNode [$gNode selectNodes $xp]   
                dict set part_info [$gNode @n] $j "[format %8g [gid_groups_conds::convert_value_to_default $valueNode]]"   
            }
        }  

        set type [$gNode selectNodes {string(../@n)}]
        
            
            set xp ".//value\[@n='WidthY']"
            set valueNode [$gNode selectNodes $xp]
            set widthy [format %8g [gid_groups_conds::convert_value_to_default $valueNode]]
            
            set xp ".//value\[@n='WidthZ']"
            set valueNode [$gNode selectNodes $xp]
            set widthz [format %8g [gid_groups_conds::convert_value_to_default $valueNode]]
            
            set xp ".//value\[@n='Element_formulation']"
            set valueNode [$gNode selectNodes $xp]
            set formulation [format %8d [get_domnode_attribute $valueNode v]]
            
            set xp ".//value\[@n='Quadrature_rule']"
            set valueNode [$gNode selectNodes $xp]
            set quadrature_v [format %8g [get_domnode_attribute $valueNode v]]
            set quadrature_state [$valueNode @state]
            
            set xp ".//value\[@n='Non_structural_mass']"
            set valueNode [$gNode selectNodes $xp]
            set mass_v [format %8g [gid_groups_conds::convert_value_to_default $valueNode]]
            set mass_state [$valueNode @state]
            if {$mass_v=="0"} {
                error [= "Structural masses of beams elements must be >0"]
            }
            
            set xp ".//value\[@n='Location_y_axis']"
            set valueNode [$gNode selectNodes $xp]
            set yaxis_v [format %8g [get_domnode_attribute $valueNode v]]
            set yaxis_state [$valueNode @state]
            
            set xp ".//value\[@n='Location_z_axis']"
            set valueNode [$gNode selectNodes $xp]
            set zaxis_v [format %8g [get_domnode_attribute $valueNode v]]
            set zaxis_state [$valueNode @state]
            
            set xp ".//value\[@n='Output_force']"
            set valueNode [$gNode selectNodes $xp]
            set output_v [format %8d [get_domnode_attribute $valueNode v]]
            set output_state [$valueNode @state]
            
            #TO AVOID SECTION_BEAM REPETITION
            
            set section_found 0
            
            dict for {sid info} $section_info_beams {
                if {!$section_found} {
                    set section_exists 1
                    dict with info {
                        if { $ELFORM!=$formulation || $TS!=$widthy || $TT!=$widthz } { set section_exists 0 }
                        if { $quadrature_state=="normal" && $QR!=$quadrature_v } { set section_exists 0 }  
                        if { $mass_state=="normal" && $NSM!=$mass_v } { set section_exists 0 }
                        if { $yaxis_state=="normal" && $NSLOC!=$yaxis_v } { set section_exists 0 }
                        if { $zaxis_state=="normal" && $NTLOC!=$zaxis_v } { set section_exists 0 }
                        if { $output_state=="normal" && $PRINT!=$output_v } { set section_exists 0 }
                        if { $section_exists } {
                            dict set part_info [$gNode @n] SID "[format %8d $sid]"
                            if {$mass=="0"} {
                                GiD_WriteCalculationFile puts -nonewline "[format %8d $sid],"
                            }
                            set section_found 1
                        }
                    }
                }
            }
            
            if {!$section_found || $section_beams_num=="0"} {    
                incr section_beams_num
                dict set section_info_beams "[ expr { $section_solids_num + $section_shells_num + $section_beams_num }]" TYPE "$type"
                dict set section_info_beams "[ expr { $section_solids_num + $section_shells_num + $section_beams_num }]" ELFORM "$formulation"
                dict set section_info_beams "[ expr { $section_solids_num + $section_shells_num + $section_beams_num }]" TS "$widthy"
                dict set section_info_beams "[ expr { $section_solids_num + $section_shells_num + $section_beams_num }]" TT "$widthz"
                dict set section_info_beams "[ expr { $section_solids_num + $section_shells_num + $section_beams_num }]" QR "$quadrature_v"
                dict set section_info_beams "[ expr { $section_solids_num + $section_shells_num + $section_beams_num }]" NSM "$mass_v"
                dict set section_info_beams "[ expr { $section_solids_num + $section_shells_num + $section_beams_num }]" NSLOC "$yaxis_v"
                dict set section_info_beams "[ expr { $section_solids_num + $section_shells_num + $section_beams_num }]" NTLOC "$zaxis_v"
                dict set section_info_beams "[ expr { $section_solids_num + $section_shells_num + $section_beams_num }]" PRINT "$output_v"
                
                dict set part_info [$gNode @n] SID "[format %8d [ expr { $section_solids_num + $section_shells_num + $section_beams_num }]]"
                if {$mass=="0"} {
                    GiD_WriteCalculationFile puts -nonewline "[format %8d [ expr { $section_solids_num + $section_shells_num + $section_beams_num }]],"
                }
            }
        


        #SAVING MATERIAL DATA
        
        set aux [save_materials $root $gNode $mat_info $mat_num 0 $mass 0]
                   
    }


    ##################################### WRITING INERTIA PARTS###################################

  
    set print_title 0
    
    dict for {id info} $part_info {
        #WE PRINT ONLY INERTIA PARTS
        dict with info { 
            if {$TM=="0"} continue
            GiD_WriteCalculationFile puts -nonewline "\n*PART_INERTIA\nPart Inertia $PID Header"
            if {$print_title=="0"} {
                GiD_WriteCalculationFile puts -nonewline "\n$\n$-----PID----SECID------MID----EOSID-----HGID------\n$"
            }
            GiD_WriteCalculationFile puts -nonewline "\n[format %8d $PID],[format %8d $SID],[format %8d $MID]" 

            if {$HGID!=-1} {
                 GiD_WriteCalculationFile puts -nonewline ",        ,[format %8d $HGID]"
            }

            if {$print_title=="0"} {
                GiD_WriteCalculationFile puts -nonewline "\n$\n$------XC-------YC-------ZC-------TM------\n$"
            }
            switch $CENTER {
                1 {
                    GiD_WriteCalculationFile puts -nonewline "\n[format %8g $XC],[format %8g $XC],[format %8g $XC]," 
                }
                0 {
                    GiD_WriteCalculationFile puts -nonewline "\n        ,        ,        ,"   
                }
            }
            GiD_WriteCalculationFile puts -nonewline "[format %8g $TM]"

            if {$print_title=="0"} {
                GiD_WriteCalculationFile puts -nonewline "\n$\n$-----IXX------IXY------IXZ------IYY------IYZ------IZZ------\n$"
            }
            GiD_WriteCalculationFile puts -nonewline "\n[format %8g $IXX],[format %8g $IXY],[format %8g $IXZ],[format %8g $IYY],[format %8g $IYZ],[format %8g $IZZ]" 
            
            if {$print_title=="0"} {
                GiD_WriteCalculationFile puts -nonewline "\n$\n$-----VTX------VTY------VTZ------VRX------VRY------VRZ------\n$"
            }
            GiD_WriteCalculationFile puts -nonewline "\n" 
            
            set print_title 1
            
        }    
    }


##############################WRITING EACH SECTION AND MATERIALS#########################################


    ########## Writing *SECTION_SOLID ##############


    if {$section_solids_num!="0"} {
        
        GiD_WriteCalculationFile puts -nonewline "\n*SECTION_SOLID\n$\n$---SECID--ELFORM---AET--------\n$"
        
        foreach id [dict keys $section_info_solids] {
            GiD_WriteCalculationFile puts -nonewline "\n[format %8d $id],[dict get $section_info_solids $id ELFORM]"
            
            if {[dict get $section_info_solids $id ACTIVATION] == "hidden"} {
                GiD_WriteCalculationFile puts -nonewline ",        "
                
            } else {                
                GiD_WriteCalculationFile puts -nonewline ",[dict get $section_info_solids $id AET]"
            }
        }
    }

    ########## Writing *SECTION_SHELL ##############
    
    foreach id [dict keys $section_info_shells] {
        
        GiD_WriteCalculationFile puts -nonewline "\n*SECTION_SHELL\n$\n$---SECID---ELFORM-----SHRF------NIP----PROPT--QR/IRID----ICOMP----SETYP-------\n$"
        GiD_WriteCalculationFile puts -nonewline "\n[format %8d $id],[dict get $section_info_shells $id ELFORM],[dict get $section_info_shells $id SHRF],[dict get $section_info_shells $id NIP],        ,        ,        ,"
        
        if {[dict get $section_info_shells $id ACTIVATION_SETYP] == "hidden"} {
            GiD_WriteCalculationFile puts -nonewline "        "     
        } else {                
            GiD_WriteCalculationFile puts -nonewline "[dict get $section_info_shells $id SETYP]"
        }
        
        GiD_WriteCalculationFile puts -nonewline "\n$\n$------T1-------T2-------T3-------T4-----NLOC----MAREA-----IDOF---EDGSET-------\n$"
        GiD_WriteCalculationFile puts -nonewline "\n[dict get $section_info_shells $id T1234],[dict get $section_info_shells $id T1234],[dict get $section_info_shells $id T1234],[dict get $section_info_shells $id T1234],[dict get $section_info_shells $id NLOC],        ,"
        
        if {[dict get $section_info_shells $id ACTIVATION_IDOF] == "hidden"} {
            GiD_WriteCalculationFile puts -nonewline "         ,        "         
        } else {                
            GiD_WriteCalculationFile puts -nonewline "[dict get $section_info_shells $id IDOF],        "
        }    
    }

    ######### Writing *SECTION_BEAM ##################

    
    foreach id [dict keys $section_info_beams] {

        #ORIENTATION WOULD BE APPOINTED BY y AXIS
        
        GiD_WriteCalculationFile puts -nonewline "\n*SECTION_BEAM\n$\n$---SECID---ELFORM-----SHRF-------QR------CST----SCOOR------NSM------\n$"
        
        set elform [dict get $section_info_beams $id ELFORM]
        GiD_WriteCalculationFile puts -nonewline "\n[format %8d $id],$elform,        ,"
        
        if {$elform=="1" || $elform=="4" || $elform=="5" || $elform=="11"} {
            GiD_WriteCalculationFile puts -nonewline "[dict get $section_info_beams $id QR]," 
        } else {
            GiD_WriteCalculationFile puts -nonewline "        ,"  
        }

        #HERE WE CONSIDER IF IT'S A TRIANGULAR OR RECTANGULAR SECTION

        if {[dict get $section_info_beams $id TYPE]=="Rectangular_Section" || [dict get $section_info_beams $id TYPE]=="Rectangular_Plastic_Section"} {
            GiD_WriteCalculationFile puts -nonewline "[format "%8g" 0.0]," 
            
        } elseif {[dict get $section_info_beams $id TYPE]=="Circular_Section" || [dict get $section_info_beams $id TYPE]=="Circular_Plastic_Section"} {      
            GiD_WriteCalculationFile puts -nonewline "[format "%8g" 1.0],"
        }

        GiD_WriteCalculationFile puts -nonewline "        ,"
        
        if {$elform=="1" || $elform=="4" || $elform=="5"} {
            GiD_WriteCalculationFile puts -nonewline "[dict get $section_info_beams $id NSM]" 
        } else {
            GiD_WriteCalculationFile puts -nonewline "        "  
        }
        
        GiD_WriteCalculationFile puts -nonewline "\n$\n$-----TS1------TS2------TT1------TT2"
        
        if {$elform=="1" || $elform=="11"} {
            GiD_WriteCalculationFile puts -nonewline "----NSLOC----NTLOC-------\n$"
        } elseif { $elform=="9" } {
            GiD_WriteCalculationFile puts -nonewline "----PRINT-------\n$"
        } else {
            GiD_WriteCalculationFile puts -nonewline "---------\n$"
        }
        
        GiD_WriteCalculationFile puts -nonewline "\n[dict get $section_info_beams $id TS],[dict get $section_info_beams $id TS],[dict get $section_info_beams $id TT],[dict get $section_info_beams $id TT]"
        
        if {$elform=="1" || $elform=="11"} {
            GiD_WriteCalculationFile puts -nonewline ",[dict get $section_info_beams $id NSLOC],[dict get $section_info_beams $id NTLOC]"
        } elseif { $elform=="9" } {
            GiD_WriteCalculationFile puts -nonewline ",[dict get $section_info_beams $id PRINT]"
        }        
    }
    
    ##################################### WRITING SEATBELT PARTS (THEY ARE SAVED IN groupsL dict) ################################

    set xp {container[@n="Properties"]/container[@n="Seatbelts"]/condition[@n="Seatbelt"]/group}
    
    ##### Continue writing *PART ########

    set groupsSeatbelts ""
    set seatbelt_section_num -1
    
    foreach gNode [$root selectNodes "$xp"] {
        
        if { [dict exists $groupsSeatbelts [$gNode @n]] } {
            error [= "There are repeated groups in the seatbelt properties"]
        }  
  
        if {$seatbelt_section_num=="-1"} {
            #this section is computed in the total section calculus as a beam section
            incr section_beams_num
            set seatbelt_section_num $section_beams_num
            GiD_WriteCalculationFile puts -nonewline "\n*SECTION_SEATBELT\n$\n$---SECID-----\n$"
            GiD_WriteCalculationFile puts -nonewline "\n[format "%8d" [expr ($section_solids_num + $section_shells_num + $seatbelt_section_num)]]"
        }
     
        dict set part_info [$gNode @n] SID "[format %8d [ expr ($section_solids_num + $section_shells_num + $seatbelt_section_num)]]"
        
        incr part_num
        dict set groupsSeatbelts [$gNode @n] $part_num
        
        dict set part_info [$gNode @n] PID "[format %8d $part_num]"
        GiD_WriteCalculationFile puts -nonewline "\n*PART\n$-----PID---SECID-----MID--------\nPart $part_num Header"
        GiD_WriteCalculationFile puts -nonewline "\n[format %8d $part_num],[format %8d [ expr ($section_solids_num + $section_shells_num + $seatbelt_section_num)]]" 
        
        dict set part_info [$gNode @n] TM 0 
        set type [$gNode selectNodes {string(../@n)}]
        
        #SAVING MATERIAL DATA
        
        set aux [save_materials $root $gNode $mat_info $mat_num 0 0 0]
        
    }
    
    
    
           
    ######### Writing *MATERIALS ###############
       

    if {$mat_num!="0"} {  
        
        set last_type 0
        
        foreach id [dict keys $mat_info] {
            
            set type [dict get $mat_info $id TYPE]
                 
            switch $type {
                1 {
                    #ELASTIC MATERIAL
                    
                    if {$last_type!="1"} {
                        
                        GiD_WriteCalculationFile puts -nonewline "\n*MAT_ELASTIC"
                        GiD_WriteCalculationFile puts -nonewline "\n$\n$----MID-------------RHO---------------E---------PR-----\n$"                  
                    }
                    
                    GiD_WriteCalculationFile puts -nonewline "\n[dict get $mat_info $id MID],[dict get $mat_info $id RHO],[dict get $mat_info $id E],[dict get $mat_info $id PR]"
                }
                2 {
                    #ORTHOTROPIC MATERIAL
                    #Warning: Type 2 is different than Type 2_ANIS (MAT_ANISOTROPIC_ELASTIC for solids)
                    
                    GiD_WriteCalculationFile puts -nonewline "\n*MAT_ORTHOTROPIC_ELASTIC"
                    GiD_WriteCalculationFile puts -nonewline "\n$\n$-----MID-------RO-------EA-------EB-------EC-----PRBA-----PRCA-----PRCB-----\n$"
                    #EB IS REPEATED (BUT NOT USED BY LS-DYNA)
                    GiD_WriteCalculationFile puts -nonewline "\n[dict get $mat_info $id MID],[dict get $mat_info $id RHO],[dict get $mat_info $id EA],[dict get $mat_info $id EB],[dict get $mat_info $id EB]"
                    GiD_WriteCalculationFile puts -nonewline ",        ,[dict get $mat_info $id NUAB],        ,        "
                    GiD_WriteCalculationFile puts -nonewline "\n$\n$-----GAB------GBC------GCA-----AOPT--------G-----SIGF------\n$"
                    GiD_WriteCalculationFile puts -nonewline "\n[dict get $mat_info $id GAB],[dict get $mat_info $id GBC],[dict get $mat_info $id GAC],[format "%8g" 3.0]"
                    #ARBITRARY CHOSEN VECTOR (WARNING: USER MAY CHOOSE ONE VECTOR NORMAL TO SHELL SURFACE) 
                    GiD_WriteCalculationFile puts -nonewline "\n$\n$------V1-------V2-------V3-------\n$"
                    GiD_WriteCalculationFile puts -nonewline "\n\n[format "%8g" 1.0],[format "%8g" 0.0],[format "%8g" 0.0]"
                }
                20 {
                    #RIGID MATERIAL

                    if {$last_type!="20"} {
                        
                        GiD_WriteCalculationFile puts -nonewline "\n*MAT_RIGID"
                        GiD_WriteCalculationFile puts -nonewline "\n$\n$----MID-------------RHO---------------E---------PR-----\n$"                  
                    }
                    
                    GiD_WriteCalculationFile puts -nonewline "\n[dict get $mat_info $id MID],[dict get $mat_info $id RHO],[dict get $mat_info $id E],[dict get $mat_info $id PR]\n\n"
                }
                9 {
                    #NULL MATERIAL
                    if {$last_type!="9"} {                        
                        GiD_WriteCalculationFile puts -nonewline "\n*MAT_NULL"
                        GiD_WriteCalculationFile puts -nonewline "\n$\n$-----MID-------RO-------PC-------MU----TEROD----CEROD-------YM-------PR-----\n$"                  
                    }
                    
                    GiD_WriteCalculationFile puts -nonewline "\n[dict get $mat_info $id MID],[dict get $mat_info $id RHO],        ,        ,        ,        ,[dict get $mat_info $id E],[dict get $mat_info $id PR]"
                    
                }
                6 {
                    #VISCOELASTIC MATERIAL 
                    if {$last_type!="6"} {                        
                        GiD_WriteCalculationFile puts -nonewline "\n*MAT_VISCOELASTIC"
                        GiD_WriteCalculationFile puts -nonewline "\n$\n$-----MID-------RO-----BULK-------G0-------GI-----BETA-----\n$"                  
                    }
                    
                    GiD_WriteCalculationFile puts -nonewline "\n[dict get $mat_info $id MID],[dict get $mat_info $id RO],[dict get $mat_info $id BULK],[dict get $mat_info $id G0],[dict get $mat_info $id GI],[dict get $mat_info $id BETA]"                  
                    
                }
                24 {
                    #PIECEWISE PLASTIC LINEAR MATERIAL                    
                   
                    GiD_WriteCalculationFile puts -nonewline "\n*MAT_PIECEWISE_LINEAR_PLASTICITY"
                    GiD_WriteCalculationFile puts -nonewline "\n$\n$-----MID-------RO-------E--------PR-----SIGY-----ETAN-------\n$"              
               
                    #FAILURE CRITERIA COULD BE IMPLEMENTED HERE, AS WELL AS PLASTIC BEHAVIOUR CURVE
                    GiD_WriteCalculationFile puts -nonewline "\n[dict get $mat_info $id MID],[dict get $mat_info $id RHO],[dict get $mat_info $id E],[dict get $mat_info $id PR],[dict get $mat_info $id SIGY],[dict get $mat_info $id ETAN]\n\n\n"              
                }
                3 {
                    #PLASTIC KINEMATIC MATERIAL   
                    GiD_WriteCalculationFile puts -nonewline "\n*MAT_PLASTIC_KINEMATIC"
                    GiD_WriteCalculationFile puts -nonewline "\n$\n$-----MID-------RO-------E--------PR-----SIGY-----ETAN-----BETA-------\n$"
                    GiD_WriteCalculationFile puts -nonewline "\n[dict get $mat_info $id MID],[dict get $mat_info $id RHO],[dict get $mat_info $id E],[dict get $mat_info $id PR],[dict get $mat_info $id SIGY],[dict get $mat_info $id ETAN],        \n"                      
                }
                29 {    
                    #FORCE LIMITED MATERIAL
                    GiD_WriteCalculationFile puts -nonewline "\n*MAT_FORCE_LIMITED"
                    GiD_WriteCalculationFile puts -nonewline "\n$-----MID-------RO--------E-------PR-------DF-----AOPT---YTFLAG----ASOFT-------" 
                    GiD_WriteCalculationFile puts -nonewline "\n[dict get $mat_info $id MID],[dict get $mat_info $id RHO],[dict get $mat_info $id E],[dict get $mat_info $id PR],[format "%8g" 0],[dict get $mat_info $id AOPT],[format "%8g" 0],[format "%8g" 0]"   
                    GiD_WriteCalculationFile puts -nonewline "\n$------M1-------M2-------M3-------M4-------M5-------M6-------M7-------M8-------"
                    GiD_WriteCalculationFile puts -nonewline "\n[dict get $mat_info $id M],[format "%8g" 0],[format "%8g" 0],[format "%8g" 0],[format "%8g" 0],[format "%8g" 0],[format "%8g" 0],[format "%8g" 0]" 
                    GiD_WriteCalculationFile puts -nonewline "\n$-----LC1------LC2------LC3------LC4------LC5------LC6------LC7------LC8-------"
                    GiD_WriteCalculationFile puts -nonewline "\n[dict get $mat_info $id LCDR],[format "%8d" 0],[format "%8d" 0],[format "%8d" 0],[format "%8d" 0],[format "%8d" 0],[format "%8d" 0],[format "%8d" 0]" 
                    GiD_WriteCalculationFile puts -nonewline "\n$----LPS1-----SFS1-----LPS2-----SFS2-----YMS1-----YMS2-------"
                    GiD_WriteCalculationFile puts -nonewline "\n[format "%8d" 0],[dict get $mat_info $id SF],[format "%8d" 0],[dict get $mat_info $id SF],[dict get $mat_info $id YM],[dict get $mat_info $id YM]" 
                    GiD_WriteCalculationFile puts -nonewline "\n$----LPT1-----SFT1-----LPT2-----SFT2-----YMT1-----YMT2-------"
                    GiD_WriteCalculationFile puts -nonewline "\n[format "%8d" 0],[dict get $mat_info $id SF],[format "%8d" 0],[dict get $mat_info $id SF],[dict get $mat_info $id YM],[dict get $mat_info $id YM]"
                    GiD_WriteCalculationFile puts -nonewline "\n$-----LPR------SFR------YMR-----"
                    GiD_WriteCalculationFile puts -nonewline "\n[format "%8d" 0],[dict get $mat_info $id SFR],[dict get $mat_info $id YMR]" 
                }
                34 {
                    #FABRIC MATERIAL
                    GiD_WriteCalculationFile puts -nonewline "\n*MAT_FABRIC"                    
                    GiD_WriteCalculationFile puts -nonewline "\n$\n$-----MID-------RO-------EA-------EB-------EC-----PRBA-----PRCA-----PRCB-----\n$"
                    #EB IS REPEATED (BUT NOT USED BY LS-DYNA)
                    GiD_WriteCalculationFile puts -nonewline "\n[dict get $mat_info $id MID],[dict get $mat_info $id RHO],[dict get $mat_info $id EA],[dict get $mat_info $id EB],[dict get $mat_info $id EB]"
                    GiD_WriteCalculationFile puts -nonewline ",[dict get $mat_info $id NUAB],        ,        "
                    GiD_WriteCalculationFile puts -nonewline "\n$\n$-----GAB------GBC------GCA-----CSE-------EL------PRL----LRATIO-----DAMP------\n$"
                    GiD_WriteCalculationFile puts -nonewline "\n[dict get $mat_info $id GAB],[dict get $mat_info $id GBC],[dict get $mat_info $id GAC],[dict get $mat_info $id CSE],"
                    
                    #Liner data is optional
                    if {[dict get $mat_info $id EL]==-1} {
                        GiD_WriteCalculationFile puts -nonewline "        ,"
                    } else {
                        GiD_WriteCalculationFile puts -nonewline "[dict get $mat_info $id EL],"
                    }
                    
                    if {[dict get $mat_info $id PRL]==-1} {
                        GiD_WriteCalculationFile puts -nonewline "        ,"
                    } else {
                        GiD_WriteCalculationFile puts -nonewline "[dict get $mat_info $id PRL],"
                    }

                    GiD_WriteCalculationFile puts -nonewline "[dict get $mat_info $id LRATIO],[dict get $mat_info $id DAMP]"

                    GiD_WriteCalculationFile puts -nonewline "\n$\n$-----AOPT-------\n$"
                    GiD_WriteCalculationFile puts -nonewline "\n[format "%8d" 3]"
                    #ARBITRARY CHOSEN VECTOR (WARNING: USER MAY CHOOSE ONE VECTOR NORMAL TO SHELL SURFACE) 
                    GiD_WriteCalculationFile puts -nonewline "\n$\n$------V1-------V2-------V3-------\n$"
                    GiD_WriteCalculationFile puts -nonewline "\n\n[format "%8g" 1.0],[format "%8g" 0.0],[format "%8g" 0.0]"
                }
                801 {
                    #SEATBELT MATERIAL
                    GiD_WriteCalculationFile puts -nonewline "\n*MAT_SEATBELT" 
                    GiD_WriteCalculationFile puts -nonewline "\n$\n$-----MID-----MPUL----LLCID----ULCID-----LMIN---------\n$"
                    GiD_WriteCalculationFile puts -nonewline "\n[dict get $mat_info $id MID],[dict get $mat_info $id MPUL],[dict get $mat_info $id LLCID],[dict get $mat_info $id ULCID],[dict get $mat_info $id LMIN]"
                }
            }
            set last_type $type
        }
    }

    #################################WRITING AIRBAG CARDS###########################################   

    set airbags_info ""
    
    #SAVING AIRBAG CARDS DATA AND WRITING LCDIM CURVES
    foreach i [list 1 2] {
        
        set xp {container[@n="Properties"]/container[@n="Airbags"]/condition[@n="Airbag"]/groupList}
        append xp {/group[$i]}
        set xp [subst -nocommands $xp]      
        
        set airbags_num 0
        
        foreach gNode [$root selectNodes $xp] {               
            
            incr airbags_num 
            
            #WE OBTAIN PART ID (from each shell)
            
            set part_name [$gNode @n]
            set part_id [dict get $part_info $part_name PID]
            dict set airbags_info $airbags_num ${i}_id $part_id  
            
            #WE PRINT AIRBAG CARD (only once)
            if {$i=="1"} {    
                #FIRST OF ALL WE GUESS AIRBAG TYPE
                
                set xp "..//value\[@n='Airbag_type']"       
                set valueNode [$gNode selectNodes $xp]  
                set airbag_type [$valueNode @v]
                
                
                #WE PRINT MASS FLOW RATE CURVE
                set xp "..//value\[@n='Factor'\]"
                set valueNode [$gNode selectNodes $xp]     
                set function [$valueNode selectNodes {.//function}]                   
                
                if { $function eq "" } {
                    #if no equation is entered lcid is set to zero
                    set lcid 0
                } else {
                    
                    incr curve_num  
                    set lcid $curve_num 
                    
                    set curve_info ""
                    
                    foreach fNode [$function selectNodes {functionVariable}] {
                        lappend function_name [$fNode @n] [$fNode @variable]
                        dict set curve_info [$gNode @n] $curve_num
                    }            
                    
                    GiD_WriteCalculationFile puts -nonewline "\n*DEFINE_CURVE\n$\n$----LCID-----SIDR------SFA------SFO-----OFFA-----------\n$"
                    GiD_WriteCalculationFile puts -nonewline "\n[format "%8d" $curve_num],[format "%8d" 0],[format "%8g" 1.0],[format "%8g" 1.0]"
                    GiD_WriteCalculationFile puts -nonewline "\n$\n$-----------------AI----------------------OI------------\n$"
                    
                    set xp {functionVariable[@n="interpolator_func" and @variable="t"]}
                    set fvNode [$function selectNodes $xp]
                    set values [$fvNode selectNodes value]
                    
                    #WE FIND TIME UNITS FACTOR 
                    set abcissa_units  [$fvNode @units]
                    set abcissa_factor [compute_units_factor time $abcissa_units] 
                    
                    foreach v $values {                        
                        set abcissa_value [expr ($abcissa_factor*[lindex [split [$v @v] ,] 0])]
                        set ordinate_value [lindex [split [$v @v] ,] 1]
                        GiD_WriteCalculationFile puts -nonewline "\n[format "%20E" $abcissa_value],[format "%20E" $ordinate_value] "
                    }           
                    
                }                 
                
                #WE PRINT GAS TEMPERATURE CURVE
                set xp "..//value\[@n='Factor_Temp'\]"
                set valueNode [$gNode selectNodes $xp]     
                set function [$valueNode selectNodes {.//function}]                   
                
                if { $function eq "" } {
                    #if no equation is entered lcid is set to zero, except on Wang_Nefske airbags
                    set lcid_temp 0
                    
                    if {$airbag_type=="Wang_Nefske"} {                      
                        set factor_temp [$valueNode @v]
                        if {$factor_temp==""} {
                            set factor_temp 0.0
                        } else {
                            set factor_temp [gid_groups_conds::convert_value_to_default $valueNode]
                        }
                    }                
                } else {                    
                    incr curve_num  
                    set lcid_temp $curve_num 
                    
                    set curve_info ""
                    
                    foreach fNode [$function selectNodes {functionVariable}] {
                        lappend function_name [$fNode @n] [$fNode @variable]
                        dict set curve_info [$gNode @n] $curve_num
                    }            
                    
                    GiD_WriteCalculationFile puts -nonewline "\n*DEFINE_CURVE\n$\n$----LCID-----SIDR------SFA------SFO-----OFFA-----------\n$"
                    GiD_WriteCalculationFile puts -nonewline "\n[format "%8d" $curve_num],[format "%8d" 0],[format "%8g" 1.0],[format "%8g" 1.0]"
                    GiD_WriteCalculationFile puts -nonewline "\n$\n$-----------------AI----------------------OI------------\n$"
                    
                    set xp {functionVariable[@n="interpolator_func" and @variable="t"]}
                    set fvNode [$function selectNodes $xp]
                    set values [$fvNode selectNodes value]
                    
                    #WE FIND TIME UNITS FACTOR 
                    set abcissa_units  [$fvNode @units]
                    set abcissa_factor [compute_units_factor time $abcissa_units] 
                    
                    #WE FIND TEMP UNITS FACTOR
                    
                    set ordinate_units [$valueNode @units]
                    set xp [format_xpath {units/unit_magnitude[@n="Temp"]/unit[@n=%s]} $ordinate_units]
                    set ordinate_factor [$root getAttributeP $xp factor]  
                    
                    foreach v $values {                        
                        set abcissa_value [expr ($abcissa_factor*[lindex [split [$v @v] ,] 0])]
                        set ordinate_value [expr ($ordinate_factor*[lindex [split [$v @v] ,] 1])]
                        GiD_WriteCalculationFile puts -nonewline "\n[format "%20E" $abcissa_value],[format "%20E" $ordinate_value] "
                    }          
                } 
                
                #WE PRINT ORIFICE AREA CURVE (only wang_nefske airbags)
                
                if {$airbag_type=="Wang_Nefske"} {
                    
                    set xp "..//value\[@n='Factor_Exit'\]"
                    set valueNode [$gNode selectNodes $xp]     
                    set function [$valueNode selectNodes {.//function}]                   
                    
                    if { $function eq "" } {
                        #if no equation is entered we read the coefficient
                        set lcid_exit 0                    
                        set factor_exit [$valueNode @v]
                        if {$factor_exit==""} {
                            set factor_exit 0.0
                        } else {
                            set factor_exit [gid_groups_conds::convert_value_to_default $valueNode]
                        }                     
                    } else {                    
                        incr curve_num  
                        set lcid_exit $curve_num 
                        
                        set curve_info ""
                        
                        foreach fNode [$function selectNodes {functionVariable}] {
                            lappend function_name [$fNode @n] [$fNode @variable]
                            dict set curve_info [$gNode @n] $curve_num
                        }            
                        
                        GiD_WriteCalculationFile puts -nonewline "\n*DEFINE_CURVE\n$\n$----LCID-----SIDR------SFA------SFO-----OFFA-----------\n$"
                        GiD_WriteCalculationFile puts -nonewline "\n[format "%8d" $curve_num],[format "%8d" 0],[format "%8g" 1.0],[format "%8g" 1.0]"
                        GiD_WriteCalculationFile puts -nonewline "\n$\n$-----------------AI----------------------OI------------\n$"
                        
                        set xp {functionVariable[@n="interpolator_func" and @variable="P"]}
                        set fvNode [$function selectNodes $xp]
                        set values [$fvNode selectNodes value]
                        
                        
                        #WE FIND ORDINATE FACTOR 
                        set ordinate_units [$valueNode @units]
                        set ordinate_units_square [lindex [split $ordinate_units ^] 0]
                        set xp [format_xpath {units/unit_magnitude[@n="L"]/unit[@n=%s]} $ordinate_units_square]
                        set ordinate_factor_square [$root getAttributeP $xp factor]  
                        set ordinate_factor [expr ($ordinate_factor_square*$ordinate_factor_square)]
                        
                        
                        #WE FIND ABCISSA FACTOR
                        
                        set abcissa_units [$fvNode @units]
                        
                        #force units
                        set abcissa_units_force [lindex [split $abcissa_units /] 0]
                        set xp [format_xpath {units/unit_magnitude[@n="F"]/unit[@n=%s]} $abcissa_units_force]
                        set abcissa_factor_force [$root getAttributeP $xp factor]  
                        
                        #distance units
                        
                        set abcissa_units_distance [lindex [split $abcissa_units /] 1]
                        set abcissa_units_distance_square [lindex [split $abcissa_units_distance ^] 0]
                        set xp [format_xpath {units/unit_magnitude[@n="L"]/unit[@n=%s]} $abcissa_units_distance_square]
                        set abcissa_factor_distance [$root getAttributeP $xp factor]                      
                        
                        #global factor
                        
                        set abcissa_factor [expr ($abcissa_factor_force/($abcissa_factor_distance*$abcissa_factor_distance))]
                        
                        foreach v $values {                        
                            set abcissa_value [expr ($abcissa_factor*[lindex [split [$v @v] ,] 0])]
                            set ordinate_value [expr ($ordinate_factor*[lindex [split [$v @v] ,] 1])]
                            GiD_WriteCalculationFile puts -nonewline "\n[format "%20E" $abcissa_value],[format "%20E" $ordinate_value] "
                        }          
                    } 
                }
                
                #WE PRINT DAMPING CURVE (only if defined)
                
                set xp "..//value\[@n='Damping'\]"
                set valueNode [$gNode selectNodes $xp]     
                set function [$valueNode selectNodes {.//function}]  
                               
                if { $function eq "" } {
                    #if no equation no curve is written                   
                    dict set airbags_info $airbags_num lcid_damping 0 
                    
                } else {                    
                    incr curve_num  
                    set lcid_damping $curve_num 
                    dict set airbags_info $airbags_num lcid_damping $curve_num 
                    
                    set curve_info ""
                    
                    foreach fNode [$function selectNodes {functionVariable}] {
                        lappend function_name [$fNode @n] [$fNode @variable]
                        dict set curve_info [$gNode @n] $curve_num
                    }            
                    
                    GiD_WriteCalculationFile puts -nonewline "\n*DEFINE_CURVE\n$\n$----LCID-----SIDR------SFA------SFO-----OFFA-----------\n$"
                    GiD_WriteCalculationFile puts -nonewline "\n[format "%8d" $curve_num],[format "%8d" 0],[format "%8g" 1.0],[format "%8g" 1.0]"
                    GiD_WriteCalculationFile puts -nonewline "\n$\n$-----------------AI----------------------OI------------\n$"
                    
                    set xp {functionVariable[@n="interpolator_func" and @variable="Material"]}
                    set fvNode [$function selectNodes $xp]
                    set values [$fvNode selectNodes value]
                    
                    #WE FIND ABCISSA FACTOR
                    
                    set abcissa_units [$fvNode @units]
                    
                    #force units
                    set abcissa_units_rotation [lindex [split $abcissa_units /] 0]
                    set abcissa_factor_rotation [compute_units_factor rotation $abcissa_units_rotation] 
                    
                    #distance units
                    
                    set abcissa_units_time [lindex [split $abcissa_units /] 1]
                    set abcissa_factor_time [compute_units_factor time $abcissa_units_time]             
                    
                    #global factor
                    
                    set abcissa_factor [expr ($abcissa_factor_rotation/$abcissa_factor_time)]
                    
                    foreach v $values {                        
                        set abcissa_value [expr ($abcissa_factor*[lindex [split [$v @v] ,] 0])]
                        set ordinate_value [lindex [split [$v @v] ,] 1]
                        GiD_WriteCalculationFile puts -nonewline "\n[format "%20E" $abcissa_value],[format "%20E" $ordinate_value] "
                    }          
                } 
                           
                #WE READ GENERAL DATA             
                
                switch $airbag_type {
                    Hybrid {
                        set n_list [list Vsca Psca Atmospheric_temperature Atmospheric_pressure Atmospheric_density R Gauge_pressure Initial_weight Venting_weight A0 A1]
                        set dict_list [list VSCA PSCA ATMOST ATMOSP ATMOSD GC PVENT MW1 MW2 A0 A1]
                    }
                    Wang_Nefske {
                        set n_list [list Vsca Psca Atmospheric_pressure Atmospheric_density Cv Cp]
                        set dict_list [list VSCA PSCA ATMOSP ATMOSD CV CP]
                    }
                }
                
                foreach j $n_list k $dict_list {                    
                    set xp "..//value\[@n='$j']"       
                    set valueNode [$gNode selectNodes $xp]  
                    set $k [format "%8g" [gid_groups_conds::convert_value_to_default $valueNode]]
                }  
                
                #WE PRINT AIRBAG CARD
                
                incr set_num       
                dict set airbags_info $airbags_num set_id $set_num 
                
                
                
                switch $airbag_type {
                    Hybrid {
                        GiD_WriteCalculationFile puts -nonewline "\n*AIRBAG_HYBRID_ID\n$\n$------ID----TITLE------\n$" 
                        GiD_WriteCalculationFile puts -nonewline "\n[format "%8d" $airbags_num]"
                        GiD_WriteCalculationFile puts -nonewline "\n$\n$-----SID---SIDTYP-----RBID-----VSCA-----PSCA-----VINI------MWD-----SPSF------\n$"
                        GiD_WriteCalculationFile puts -nonewline "\n[format "%8d" $set_num],[format "%8d" 1],[format "%8g" 0],[format "%8g" $VSCA],[format "%8g" $PSCA],[format "%8g" 0],[format "%8g" 0],[format "%8g" 0]"
                        GiD_WriteCalculationFile puts -nonewline "\n$\n$-ATMOST---ATMOSP---ATMOSD-------GC-------CC------\n$"
                        GiD_WriteCalculationFile puts -nonewline "\n[format "%8g" $ATMOST],[format "%8g" $ATMOSP],[format "%8g" $ATMOSD],[format "%8g" $GC],[format "%8g" 1]"
                        GiD_WriteCalculationFile puts -nonewline "\n$\n$------C23----LCC23------A23----LCA23-----CP23----LCP23-----AP23---LCAP23--------\n$"
                        GiD_WriteCalculationFile puts -nonewline "\n[format "%8g" 0],[format "%8d" 0],[format "%8g" 0],[format "%8d" 0],[format "%8g" 0],[format "%8d" 0],[format "%8g" 0],[format "%8d" 0]"
                        GiD_WriteCalculationFile puts -nonewline "\n$\n$------OPT----PVENT-----NGAS------\n$"
                        GiD_WriteCalculationFile puts -nonewline "\n[format "%8d" 1],[format "%8g" $PVENT],[format "%8d" 2]"
                        GiD_WriteCalculationFile puts -nonewline "\n$\n$----LCIDM----LCIDT-NOTUSED-------MW----INITM-------A0------\n$ Initial gas"
                        GiD_WriteCalculationFile puts -nonewline "\n[format "%8d" 0],[format "%8d" 0],[format "%8g" 0],[format "%8g" $MW1],[format "%8d" 1],[format "%8g" $A0],[format "%8g" 0],[format "%8g" 0]"
                        GiD_WriteCalculationFile puts -nonewline "\n$\n$----FMASS---------\n$\n[format "%8g" 0]"
                        GiD_WriteCalculationFile puts -nonewline "\n$\n$----LCIDM----LCIDT-NOTUSED-------MW----INITM-------A1------\n$ Venting gas"
                        GiD_WriteCalculationFile puts -nonewline "\n[format "%8d" $lcid],[format "%8d" $lcid_temp],[format "%8g" 0],[format "%8g" $MW2],[format "%8d" 0],[format "%8g" $A1],[format "%8g" 0],[format "%8g" 0]"
                        GiD_WriteCalculationFile puts -nonewline "\n$\n$----FMASS---------\n$\n[format "%8g" 0]"
                    }
                    Wang_Nefske {
                        GiD_WriteCalculationFile puts -nonewline "\n*AIRBAG_WANG_NEFSKE_ID\n$\n$------ID----TITLE------\n$" 
                        GiD_WriteCalculationFile puts -nonewline "\n[format "%8d" $airbags_num]"
                        GiD_WriteCalculationFile puts -nonewline "\n$\n$-----SID---SIDTYP-----RBID-----VSCA-----PSCA-----VINI------MWD-----SPSF------\n$"
                        GiD_WriteCalculationFile puts -nonewline "\n[format "%8d" $set_num],[format "%8d" 1],[format "%8g" 0],[format "%8g" $VSCA],[format "%8g" $PSCA],[format "%8g" 0],[format "%8g" 0],[format "%8g" 0]"
                        GiD_WriteCalculationFile puts -nonewline "\n$\n$------CV-------CP--------T------LCT-----LCMT------\n$"
                        GiD_WriteCalculationFile puts -nonewline "\n[format "%8g" $CV],[format "%8g" $CP]"
                        
                        if {$lcid_temp=="0"} {
                            GiD_WriteCalculationFile puts -nonewline ",[format "%8g" $factor_temp],[format "%8d" 0],[format "%8d" $lcid]"
                        } else {
                            GiD_WriteCalculationFile puts -nonewline ",[format "%8g" 0],[format "%8d" $lcid_temp],[format "%8d" $lcid]"
                        }
                        
                        GiD_WriteCalculationFile puts -nonewline "\n$\n$------C23----LCC23------A23----LCA23-----CP23----LCP23-----AP23---LCAP23--------\n$"
                        
                        if {$lcid_exit=="0"} {
                            GiD_WriteCalculationFile puts -nonewline "\n[format "%8g" 1],[format "%8d" 0],[format "%8g" $factor_exit],[format "%8d" 0],[format "%8g" 1]"
                        } else {
                            GiD_WriteCalculationFile puts -nonewline "\n[format "%8g" 1],[format "%8d" 0],[format "%8g" 0],[format "%8d" $lcid_exit],[format "%8g" 1]"
                        }
                        
                        GiD_WriteCalculationFile puts -nonewline "\n$\n$-------PE-------RO-------GC------\n$"
                        GiD_WriteCalculationFile puts -nonewline "\n[format "%8g" $ATMOSP],[format "%8g" $ATMOSD],[format "%8g" 1]"
                        
                        GiD_WriteCalculationFile puts -nonewline "\n$\n$-----------\n$\n"
                    }
                }      
            } 
        }
    }         
        
    #WRITING AIRBAG CARDS AND DAMPING (if needed)

    dict for {id info} $airbags_info {       
        dict with info {
            GiD_WriteCalculationFile puts -nonewline "\n*SET_PART_LIST\n$\n$-----SID-------\n$\n[format "%8d" $set_id]"
            GiD_WriteCalculationFile puts -nonewline "\n$\n$----PID1-----PID2------\n$" 
            GiD_WriteCalculationFile puts -nonewline "\n[format "%8d" $1_id],[format "%8d" $2_id]"  
            if {$lcid_damping!="0"} {
                GiD_WriteCalculationFile puts -nonewline "\n*DAMPING_PART_MASS\n$\n$-----PID-----LCID-------\n$\n[format "%8d" $1_id],[format "%8d" $lcid_damping]"
                GiD_WriteCalculationFile puts -nonewline "\n*DAMPING_PART_MASS\n$\n$-----PID-----LCID-------\n$\n[format "%8d" $2_id],[format "%8d" $lcid_damping]" 
            } 
        }
    } 

################################################################################
#    PRINTING NODES AND ELEMENTS
################################################################################

    set isquadratic [lindex [GiD_Info Project] 5]
    set all_groups [concat [dict keys $groupsL] [dict keys $groupsS] [dict keys $groupsV]]
    set NumElems 0
    global NumElemsTot
    global NumNodesTot
    set NumElemsTot 0
    set printed_coords 0
    
    set formats ""
    set formatsLA ""
    set formats_seatbelt ""
    
    set fLA ""
  
    #We need to merge groupsSeatbelts and groupsL dictionaries
    
    set groupsL "$groupsL $groupsSeatbelts"

        foreach elemtype [list Contact Linear Triangle Quadrilateral Tetrahedra Hexahedra] {
            
            switch $elemtype {
                Contact {
                set groups $groupsContact
                    switch $isquadratic {
                        0 { set nnode 2 }
                        default { set nnode 3 }
                    }
                }
                Linear {
                set groups $groupsL
                    switch $isquadratic {
                        0 { set nnode 2 }
                        default {
                            set nnode 3
                            #error [= "Quadratic 3-noded Linear elements are not supported at the moment"]
                        }
                    }
                }                
                Triangle {
                set groups $groupsS
                switch $isquadratic {
                    0 { set nnode 3 }
                    default { set nnode 6 
                        #error [= "Quadratic triangular elements are not supported at the moment"], anisotropic materials
                    }
                }
            }
            Quadrilateral {
                set groups $groupsS
                switch $isquadratic {
                    0 { set nnode 4 }
                    1 { set nnode 8 
                        #error [= "Quadratic quadrilateral elements are not supported at the moment"], anisotropic materials
                    }
                    2 { set nnode 9
                        #error [= "Quadratic 9-noded quadrilateral elements are not supported at the moment"]
                    }
                }
                }
                Tetrahedra {
                 set groups $groupsV
                    switch $isquadratic {
                        0 { set nnode 4 }
                        1 { set nnode 10 }
                        2 { set nnode 10 }
                    }
                }
                Hexahedra {
                 set groups $groupsV
                    switch $isquadratic {
                        0 { set nnode 8 }
                        1 { set nnode 20 
                            #error [= "Quadratic 20-noded Hexaedra elements are not supported at the moment"]
                        }
                        2 { set nnode 27 
                        #error [= "Quadratic 27-noded Hezaedra elements are not supported at the moment"]
                    }
                }
            }
        }
        
        dict for "n v" $groups {
            
            if {$nnode==4 && $elemtype=="Tetrahedra"} {
                
                set f {\n%1$8d[format "%8d" $v]%2$8d%3$8d%4$8d%5$8d%5$8d%5$8d%5$8d%5$8d}
                
            } elseif {$nnode==2 && $elemtype=="Linear" && ![dict exists $groupsSeatbelts $n]} { 
                
                #ORIENTED BEAM ELEMENT (NODAL DEGREES OF FREEDOM COULD BE DEFINIDED HERE)
                
                set fLA {\n*ELEMENT_BEAM_ORIENTATION\n$-----EID-------PID--------N1,N2,N3...----------------------\n$\n%8d}
                set fLA1 "[format "%8g" $v]"
                
                append fLA $fLA1
                set fLA [subst -novariables -nocommands $fLA]
                
                set fLA2 {%8d%8d\n$\n$------VX-------VY-------VZ-----\n$\n[format %+5f [EAmat 1 2]] [format %+5f [EAmat 2 2]] [format %+5f [EAmat 3 2]]}
                
                append fLA $fLA2
                set fLA [subst -novariables -nocommands $fLA] 
                
                #BEAM ELEMENT
                
                set f {\n*ELEMENT_BEAM\n%8d[format "%8d" $v]%8d%8d}
                
            } elseif {$nnode==2 && $elemtype=="Linear" && [dict exists $groupsSeatbelts $n]} {
                
                #ELEMENT SEATBELTS
                
                set f {\n*ELEMENT_SEATBELT\n$-----EID------PID-------N1-------N2----\n%8d[format "%8d" $v]%8d%8d}              
               set f [subst -novariables $f] 

            } elseif {$elemtype=="Quadrilateral" || $elemtype=="Triangle"} {
                
                #ORIENTED SHELL ELEMENT
                
                set fLA {\n*ELEMENT_SHELL_MCID\n$-----EID-------PID--------N1,N2,N3...----------------------\n$\n%1$8d}
                set fLA [subst -novariables $fLA] 
                
                switch $nnode {
                    3 {
                        set fLA1 {[format "%8g" $v]%2$8d%3$8d%4$8d\n$\n$---THIC1----THIC2----THIC3----THIC4-----MCID-----\n$}
                    }
                    4 {
                        set fLA1 {[format "%8g" $v]%2$8d%3$8d%4$8d%5$8d\n$\n$---THIC1----THIC2----THIC3----THIC4-----MCID-----\n$}
                    } 
                    6 {
                        set fLA1 {[format "%8g" $v]%2$8d%3$8d%4$8d%5$8d%6$8d%7$8d\n$\n$---THIC1----THIC2----THIC3----THIC4-----MCID-----\n$}
                    }
                    8 {
                        set fLA1 {[format "%8g" $v]%2$8d%3$8d%4$8d%5$8d%6$8d%7$8d%8$8d%9$8d\n$\n$---THIC1----THIC2----THIC3----THIC4-----MCID-----\n$}
                    }
                }
                
                    set fLA1 [subst -novariables $fLA1] 
                    
                    append fLA $fLA1
                    set fLA [subst -novariables -nocommands $fLA]
                    
                    #COORDINATE SYSTEM DEFINITION (WITH CID=NUM_ELEMENT AND VX=Vx,VYX=Vy 
                    
                    set fLA2 {\n[format "%16E" 0][format "%16E" 0][format "%16E" 0][format "%16E" 0]%1$16d\n*DEFINE_COORDINATE_VECTOR\n%1$8d,\
                        [format %3f [EAmat 1 1]],[format %3f [EAmat 2 1]],[format %3f [EAmat 3 1]],[format %3f [EAmat 1 2]],[format %3f [EAmat 2 2]],[format %3f [EAmat 3 2]]}
                    
                    set fLA2 [subst -novariables -nocommands $fLA2]
                    
                    append fLA $fLA2
                    set fLA [subst -novariables -nocommands $fLA]  
                    
                    #SHELL ELEMENT
                    
                    set f {\n*ELEMENT_SHELL\n%8d[format "%8d" $v] [lrepeat $nnode %7d]}
                    
            } else {
                #IT SHOULD BE %8d FOR ELEMENTS CONNECTIVITIES, BUT I CAN'T DELETE THE EXTRA SPACE 
                set f {\n%8d[format "%8d" $v] [lrepeat $nnode %7d]}
            }
                
            if {$nnode==2 && $elemtype=="Linear" && [dict exists $groupsSeatbelts $n]} {
                
                dict set formats_seatbelt $n "$f"
            } else {
                set f [subst -novariables $f]                
                dict set formats $n "$f"
                
                set fLA [subst -novariables -nocommands $fLA] 
                dict set formatsLA $n "$fLA" 
            }            
            
        }  
        
        set elemtype_aux $elemtype
        if {$elemtype eq "Contact" } {
            if {$groupsContact ne ""} {
                set elemtype_aux Linear
            } else {
                continue
            }
        }
        if { $elemtype == "Linear"  && $groupsL == ""} {
            continue
        }
        
        
        if { [GiD_WriteCalculationFile has_elements -elemtype $elemtype_aux $formats] || [GiD_WriteCalculationFile has_elements -elemtype $elemtype_aux $formats_seatbelt] } {
            if { !$printed_coords } {
                #FIRST WE WRITE ORDINARY NODES
                
                GiD_WriteCalculationFile puts "\n*NODE" 
                GiD_WriteCalculationFile puts "$ Mesh Dimension = 3 Elemtype $elemtype nnode = $nnode"
                GiD_WriteCalculationFile puts -nonewline "$-----NID--------------X---------------Y---------------Z-------\n$" 
                
                set L_mesh [get_value units_mesh]
                
                set xp [format_xpath {units/unit_magnitude[@n=%s]/unit[@n=%s]} \
                        L $L_mesh]
                set L_mesh_fac [$root getAttributeP $xp factor]
                
                set NumNodesTot [GiD_WriteCalculationFile coordinates -factor $L_mesh_fac "\n%8d%+16E%+16E%+16E"]                               

                
                #NOW WE WRITE JOINT NODES (IF ANY)
                
                set joint_nodes_num 0
                set printed_card 0
                
                set xp {container[@n="Constraints"]/condition[@n="Joints"]/groupList}
                
                foreach gNode [$root selectNodes $xp] {
                    
                    if {$printed_card=="0"} {
                        GiD_WriteCalculationFile puts -nonewline "\n$ Joint Nodes"
                        set printed_card 1
                    }
                                        
                    # We write twice each joint node (two,three or six nodes in total, in function of $type)
                    
                    set xp ".//value\[@n='Joint_type']"
                    set valueNode [$gNode selectNodes $xp]
                    set type [$valueNode @v]
                    
                    switch $type {
                        Spherical {
                            set extra_joint_nodes 2
                        }
                        Revolute {
                            set extra_joint_nodes 4
                        }     
                        Translational {
                            set extra_joint_nodes 6
                        }   
                    }    
                
                    set j 1

                    while {$j<=$extra_joint_nodes} {
                        
                        incr joint_nodes_num
                        GiD_WriteCalculationFile puts -nonewline "\n[format "%8d" [expr ($NumNodesTot+$joint_nodes_num)]]"
                        
                        #We spicify if first, second or third node must be read
                        if {$j==1 || $j==2} {

                            set coordinates_list [list x y z]
                            set k "First"

                        } elseif {$j==3 || $j==4} {

                            set coordinates_list [list x_2 y_2 z_2]
                            set k "Second"
                            
                        } elseif {$j==5 || $j==6} {
                            
                            set coordinates_list [list x_3 y_3 z_3]
                            set k "Third"
                            
                        }           
                        
                        foreach i $coordinates_list {    
                            set xp {.//container[@n='${k}']/value[@n='${i}']}
                            set xp [subst -nocommands $xp]
                            set valueNode [$gNode selectNodes $xp]
                            set value [format %+16E [gid_groups_conds::convert_value_to_default $valueNode]]
                            GiD_WriteCalculationFile puts -nonewline "$value"
                        }
                        incr j
                    }
                    #Now we write nodes used for joint coordinate systems definition
                    
                    foreach j [list 1 2] {
                        
                        set xp ".//value\[@n='Axes_system_${j}']"                        
                        set valueNode [$gNode selectNodes $xp]
                        set axes_type [$valueNode @v]
                        
                        if {$axes_type=="local"} {
                            
                            set k 1
                            
                            while {$k<=3} {
                                
                                incr joint_nodes_num
                                GiD_WriteCalculationFile puts -nonewline "\n[format "%8d" [expr ($NumNodesTot+$joint_nodes_num)]]"
                                
                                switch $k {
                                    1 {
                                        set coordinates_list [list x_center_${j} y_center_${j} z_center_${j}]
                                        set coordinates_list [subst -nocommands $coordinates_list]
                                    }
                                    2 {
                                        set coordinates_list [list x_posx_${j} y_posx_${j} z_posx_${j}]
                                        set coordinates_list [subst -nocommands $coordinates_list]
                                    }
                                    3 {
                                        set coordinates_list [list x_posz_${j} y_posz_${j} z_posz_${j}]
                                        set coordinates_list [subst -nocommands $coordinates_list]
                                    }
                                }
                                
                                foreach i $coordinates_list {    
                                    set xp {.//container[@n="Data"]/value[@n='${i}']}
                                    set xp [subst -nocommands $xp]
                                    set valueNode [$gNode selectNodes $xp]
                                    set value [format %+16E [gid_groups_conds::convert_value_to_default $valueNode]]
                                    GiD_WriteCalculationFile puts -nonewline "$value"
                                }                           
                                incr k
                            }
                        }
                    }
                } 

                #NOW WE WRITE RETRACTOR NODES (IF ANY)
                
                set seatbelts_num 0
                set printed_card 0
                
                set xp {container[@n="Properties"]/container[@n="Seatbelts"]/condition[@n="Retractor"]/group}
                
                foreach gNode [$root selectNodes $xp] {
                    
                    if {$printed_card=="0"} {
                        GiD_WriteCalculationFile puts -nonewline "\n$ Seatbelt Nodes"
                        set printed_card 1
                    }

                    set sensor_list_0 [list x_r y_r z_r]
                    set sensor_list_1 [list x y z]
                    set sensor_list_2 [list x_2 y_2 z_2]
                    set sensor_list_3 [list x_3 y_3 z_3]
                    set sensor_list_4 [list x_4 y_4 z_4]
                    
                    
                    set xp {.//container[@n="Retractor"]/container[@n="Retractor_data"]/value[@n='Sensor_number']}
                    set valueNode [$gNode selectNodes $xp]
                    set sensor_number [$valueNode @v]                                 
                    
                    # We write each seatbelt node  

                    set k 0
                    
                    while {$k<=$sensor_number} {
                        
                        incr seatbelts_num
                        GiD_WriteCalculationFile puts -nonewline "\n[format "%8d" [expr ($NumNodesTot+$joint_nodes_num+$seatbelts_num)]]"                                 
                        
                        set sensor_list "sensor_list_$k"

                        foreach i [subst "$$sensor_list"] {    
                            set xp {.//value[@n='${i}']}
                            set xp [subst -nocommands $xp]
                            set valueNode [$gNode selectNodes $xp]
                            set value [format %+16E [gid_groups_conds::convert_value_to_default $valueNode]]
                            GiD_WriteCalculationFile puts -nonewline "$value"
                        }

                        incr k
                    }


                } 
                
                #NOW WE WRITE SLIPRING NODES (IF ANY)
                
                
                set xp {container[@n="Properties"]/container[@n="Seatbelts"]/condition[@n="Slipring"]/groupList}
                
                foreach gNode [$root selectNodes $xp] {
                    
                    #Information will be printed in the same section as retractor nodes, but after those
                    
                    if {$printed_card=="0"} {
                        GiD_WriteCalculationFile puts -nonewline "\n$ Seatbelt Nodes"
                        set printed_card 1
                    }
                    
                    incr seatbelts_num
                    
                    GiD_WriteCalculationFile puts -nonewline "\n[format "%8d" [expr ($NumNodesTot+$joint_nodes_num+$seatbelts_num)]]"  
                    
                    foreach i [list x y z] {    
                        set xp {.//value[@n='${i}']}
                        set xp [subst -nocommands $xp]
                        set valueNode [$gNode selectNodes $xp]
                        set value [format %+16E [gid_groups_conds::convert_value_to_default $valueNode]]
                        GiD_WriteCalculationFile puts -nonewline "$value"
                    }
                }

                set printed_coords 1
            } 
            
            
            if { $elemtype_aux=="Tetrahedra" || $elemtype_aux=="Hexahedra"} {
                GiD_WriteCalculationFile puts -nonewline "\n*ELEMENT_SOLID"    
                GiD_WriteCalculationFile puts -nonewline "\n$\n$-----EID-------PID--------N1,N2,N3...----------------------\n$"
            }           
            
            if {$nnode==2 && $elemtype=="Linear"} {
                # ERROR MESSAGE FOR BEAMS WITHOUT LOCALAXES (AT THE MOMENT *ELEMENT_BEAM IS NOT ALREADY IMPLEMENTED)
                set actual_values [GiD_WriteCalculationFile connectivities -do_subst -localaxes $formatsLA \
                        -elemtype $elemtype_aux ""]        
            } else {
                set actual_values [GiD_WriteCalculationFile connectivities -do_subst -localaxes $formatsLA \
                        -elemtype $elemtype_aux $formats]   
            }

            #We print seatbelt elements separately
            set seatbelt_connectivities [GiD_WriteCalculationFile connectivities -do_subst -elemtype $elemtype_aux $formats_seatbelt]  
            
            if { [string is integer -strict $actual_values] } { incr NumElems $actual_values }
            if { [string is integer -strict $seatbelt_connectivities] } { incr NumElems $seatbelt_connectivities }
            
            set NumElemsTot [GiD_WriteCalculationFile all_connectivities -count ""]
            
        }
    }

    ###################WRITING DISCRETE ELEMENTS,PARTS,SECTIONS AND MATERIALS##############################

    set discrete_num 0

    global part_discrete_info
    set part_discrete_info ""

    set section_info_discrete ""
    set section_discrete_num 0

    #VID WOULD STARTS AT NUMBER 4
    set vid_num 3
    set print_default 0
    
    set nondiscrete_part_num $part_num

    set xp {/*/container[@n="Properties"]/container[@n="Discrete"]/condition[@n="Discrete"]/group} 

    foreach gNode [$root selectNodes $xp] { 

#         if { [dict exists $groupsD [$gNode @n]] } {
#             error [= "There are repeated groups in discrete properties"]
#         }

        #WE PRINT AND IDENTIFYING CARD BECAUSE THIS SECTION DOESN'T FOLLOW THE STANDARD ORDER

        if {$discrete_num=="0"} {
            GiD_WriteCalculationFile puts -nonewline "\n$\n$ oooooooooooooooooo WRITING SPRING/DAMPER ELEMENTS,PARTS AND MATERIALS oooooooooooooooooo\n$"
        }

        set groupsD ""

        incr discrete_num
        dict set groupsD [$gNode @n] $discrete_num  
 
        set xp ".//value\[@n='Dimension']"
        set valueNode [$gNode selectNodes $xp]
        set dimension [get_domnode_attribute $valueNode v]  
        
        while {$dimension>"0"} {

            #################FINDING EID (=NumElemsTot)###################

            incr NumElemsTot
            
            #################FINDING PID, SAVING SECTION AND MATERIALS DATA###################

            #EACH DISCRETE GROUP COULD BE 1,2 OR 3 PARTS (PARTS CAN BE REPEATED)
            
            incr part_num
            dict set part_discrete_info "[$gNode @n]_${dimension}" PID "[format %8d $part_num]"
            

            #WRITING MATERIAL IF NEEDED

            set xp ".//value\[@n='Motion']"
            set valueNode [$gNode selectNodes $xp]
            set motion [get_domnode_attribute $valueNode v]
            set motion [format %8d [expr ($motion-1)]]
            
            set mid [save_materials $root $gNode $mat_info $mat_num $dimension 0 $motion]
            dict set part_discrete_info "[$gNode @n]_${dimension}" MID "[format %8d $mid]"

            #SEARCHING SECTION MUMBER
            
            set xp ".//value\[@n='Motion']"
            set valueNode [$gNode selectNodes $xp]
            
            #To avoid section_discrete repetition    
            
            set section_found 0

            dict for {sid info} $section_info_discrete {
                if {!$section_found} {
                    set section_exists 1
                    dict with info {
                        if { $DRO!=$motion } { set section_exists 0 }
                        if { $section_exists } {
                            dict set part_discrete_info "[$gNode @n]_${dimension}" SID "[format %8d $sid]"
                            set section_found 1
                        }
                    }
                }
            }
            
            if {!$section_found || $section_discrete_num=="0"} {
                
                incr section_discrete_num

                set section_num_total [expr ([dict size $section_info_solids]+[dict size $section_info_shells]+[dict size $section_info_beams])] 

                dict set section_info_discrete "[expr ($section_discrete_num + $section_num_total)]" DRO "$motion"
                
                dict set part_discrete_info "[$gNode @n]_${dimension}" SID "[format %8d [expr ($section_discrete_num + $section_num_total)]]"
            } 
            

            ################FINDING AND WRITING VID############################

            set xp ".//value\[@n='Axes']"
            set valueNode [$gNode selectNodes $xp]
            set axes [get_domnode_attribute $valueNode v]

            set vid ""
            
            if {$axes=="global"} {
                
                if {$print_default=="0"} {
                    
                    GiD_WriteCalculationFile puts -nonewline "\n*DEFINE_SD_ORIENTATION\n$-----VID------IOP-------XT-------YT-------ZT------"
                    GiD_WriteCalculationFile puts -nonewline "\n[format "%8d" 1],[format "%8d" 0],[format "%8g" 1.0],[format "%8g" 0],[format "%8g" 0]"
                    GiD_WriteCalculationFile puts -nonewline "\n*DEFINE_SD_ORIENTATION\n$-----VID------IOP-------XT-------YT-------ZT------"
                    GiD_WriteCalculationFile puts -nonewline "\n[format "%8d" 2],[format "%8d" 0],[format "%8g" 0],[format "%8g" 1.0],[format "%8g" 0]"
                    GiD_WriteCalculationFile puts -nonewline "\n*DEFINE_SD_ORIENTATION\n$-----VID------IOP-------XT-------YT-------ZT------"
                    GiD_WriteCalculationFile puts -nonewline "\n[format "%8d" 3],[format "%8d" 0],[format "%8g" 0],[format "%8g" 0],[format "%8g" 1.0]"
                    
                    set print_default 1
                }  
                
                set vid $dimension
                set vid [format %8d $vid]
                
            } else {
                
                incr vid_num
                set vid $vid_num
                set vid [format %8d $vid]
                
                set f "\n*DEFINE_SD_ORIENTATION\n$-----VID------IOP-------XT-------YT-------ZT------\n$vid,       0,"

                #we append correct local vector

                switch $dimension {
                    1 {
                        set f1 {%.0s[format %3f [EAmat 1 1]],[format %3f [EAmat 2 1]],[format %3f [EAmat 3 1]]}
                    }
                    2 {
                        set f1 {%.0s[format %3f [EAmat 1 2]],[format %3f [EAmat 2 2]],[format %3f [EAmat 3 2]]}
                    }
                    3 {
                        set f1 {%.0s[format %3f [EAmat 1 3]],[format %3f [EAmat 2 3]],[format %3f [EAmat 3 3]]}
                    }
                }
                
                set f1 [subst -novariables -nocommands $f1]
                
                append f $f1
                set f [subst -novariables -nocommands $f]  
                

                set formats ""
                        
                dict for "n v" $groupsD {
                    dict set formats $n "$f"
                }

                set formats_no_print ""

                dict for "n v" $groupsD {
                    dict set formats_no_print $n "%.0s"
                }
                
                #Warning in LS-DYNA: Vector definition will be defined twice
                
                set Discrete_nodes [GiD_WriteCalculationFile nodes -unique -do_subst -localaxes $formats $formats_no_print] 
                  
            }

            ##################FINALLY, WE WRITE ELEMENT_DISCRETE CARD###############################

            GiD_WriteCalculationFile puts -nonewline "\n*ELEMENT_DISCRETE\n$-----EID------PID-------N1-------N2------VID----"
            GiD_WriteCalculationFile puts -nonewline "\n[format "%8d" $NumElemsTot],[format "%8d" $part_num]"
           
            set f ",%8d"         
            set formats ""
            
            dict for "n v" $groupsD {
                dict set formats $n "$f"
            }
            
            set Discrete_nodes [GiD_WriteCalculationFile nodes -unique $formats] 

            GiD_WriteCalculationFile puts -nonewline ",$vid"
            

            #######We iterate each direction#######     
            
            set dimension [expr ($dimension-1)]
        }
    }
    #PROPERTIES CHECKING ERROR MESSAGE (now disabled)

    if {$NumElemsTot == "0"} {
        error [= "No element introduced"]
    }
    
    #######################WRITING DISCRETE PARTS###########################

    set print_part 0
  
    dict for {id info} $part_discrete_info {
        #WE PRINT ONLY DISCRETE PARTS
        dict with info { 
            if {$print_part=="0"} {
                GiD_WriteCalculationFile puts -nonewline "\n*PART" 
                set print_part 1
            }
            GiD_WriteCalculationFile puts -nonewline "\nPart [format %8d $PID] Header (Discrete)\n[format %8d $PID],[format %8d $SID],[format %8d $MID]" 
        }    
    }
    

    #####################WRITING *SECTION_DISCRETE#########################

    if {$section_discrete_num!=0} {
        
        GiD_WriteCalculationFile puts -nonewline "\n*SECTION_DISCRETE\n$\n$---SECID------DRO---------\n$"
        
        foreach id [dict keys $section_info_discrete] {
            GiD_WriteCalculationFile puts -nonewline "\n[format %8d $id],[dict get $section_info_discrete $id DRO]\n"
        }
        
    }

    #######################WRITING DISCRETE MATERIALS########################
    
    if {$mat_num!="0"} {  
        
        set last_type 0
        
        foreach id [dict keys $mat_info] {
            
            set type [dict get $mat_info $id TYPE]
            
            if {$type!="S02" && $type!="S05" && $type!="S04" && $type!="S01" && $type!="S08"} { continue }
            
            if {$type=="S01" || $type=="S02"} {
                
                #DAMPER VISCOUS AND SPRING ELASTIC MATERIAL
                
                switch $type {
                    "S01" {
                        if {$last_type!="S01"} {   
                            GiD_WriteCalculationFile puts -nonewline "\n*MAT_SPRING_ELASTIC"
                            GiD_WriteCalculationFile puts -nonewline "\n$\n$----MID--------K----------\n$"                      
                        }                         
                    }
                    "S02" {
                        if {$last_type!="S02"} {   
                            GiD_WriteCalculationFile puts -nonewline "\n*MAT_DAMPER_VISCOUS"
                            GiD_WriteCalculationFile puts -nonewline "\n$\n$----MID-------CD----------\n$"                                         
                        } 
                    }
                }

                GiD_WriteCalculationFile puts -nonewline "\n[dict get $mat_info $id MID],[dict get $mat_info $id CD]"
    
            } elseif {$type=="S04" || $type=="S05"} {
                
                #DAMPER NONLINEAR VISCOUS and SPRING NONLINEAR ELASTIC

                switch $type {
                    S05 {
                        GiD_WriteCalculationFile puts -nonewline "\n*MAT_DAMPER_NONLINEAR_VISCOUS"
                    }
                    S04 {
                        GiD_WriteCalculationFile puts -nonewline "\n*MAT_SPRING_NONLINEAR_ELASTIC"
                    }
                }
                
                GiD_WriteCalculationFile puts -nonewline "\n$\n$-----MID-----LCDR/LCD-------\n$"
                GiD_WriteCalculationFile puts -nonewline "\n[dict get $mat_info $id MID],[dict get $mat_info $id LCDR]"
                
            } elseif {$type=="S08"} {
                
                # SPRING INELASTIC
                
                GiD_WriteCalculationFile puts -nonewline "\n*MAT_SPRING_INELASTIC"
                GiD_WriteCalculationFile puts -nonewline "\n$\n$-----MID-----LCFD-------KU------CTF-------\n$"
                GiD_WriteCalculationFile puts -nonewline "\n[dict get $mat_info $id MID],[dict get $mat_info $id LCDR]"
                
                if {[dict get $mat_info $id KU]=="0"} {
                    GiD_WriteCalculationFile puts -nonewline ",        ,[dict get $mat_info $id CTF]"
                } else {
                    GiD_WriteCalculationFile puts -nonewline ",[dict get $mat_info $id KU],[dict get $mat_info $id CTF]"
                }
            }

            set last_type $type
        }
    }
    
    if {$nondiscrete_part_num!=$part_num} {
        GiD_WriteCalculationFile puts -nonewline "\n$\n$ oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo\n$"
    }

    
    #     IT'S NOT TRUE IN LS-DYNA (EXAMPLE:SOLIDS WITH MESH CRITERIA:SURFACE)
    #     if { $NumElems > 0 } {
        #         set NumElemsTot [GiD_WriteCalculationFile all_connectivities -count ""]
        #         
        #         if { $NumElemsTot != $NumElems } {
            #             error [= "Error: not all elements have properties assigned (Total=%d Assigned=%d)" \
                #                     $NumElemsTot $NumElems]
            #         }
        #     }
    #     
    
}


###############################################################################
#    Materials saving module
###############################################################################

proc b_write_calc_file::save_materials { root gNode mat_info mat_num dimension mass motion} {
    
    global part_info
    global curve_num
    
    upvar 1 mat_num material_num
    upvar 1 mat_info material_info       

    #WE VERIFY IF IT IS AN AIRBAG MATERIAL
    set property_container [$gNode selectNodes {string(../../@n)}]
    
    if {$property_container=="Airbag"} {
        set property $property_container
    } else {
        set property [$gNode selectNodes {string(../@n)}]
    }    
    
    #considering spring and airbags elements
    if {$dimension=="0"} {   
        set xp ".//value\[@n='Material']"
    } else {
        set xp ".//value\[@n='Material_${dimension}']"
    }

    if {$property=="Airbag"} {
        set xp "..//value\[@n='Material']"        
    }
    
    set valueNode [$gNode selectNodes $xp]
    set material_name [get_domnode_attribute $valueNode v]     
    
    #AVOIDING MATERIAL REPETITION (user definded materials be always saved)
    #Discrete materials are always printed provisionally (because its double utlity: translation and rotation)
    
    if { ![dict exists $material_info $material_name] || $material_name=="User defined" || $property=="Discrete" } {

        incr material_num

        #We print discrete materials and inertia parts separately
        if {$property!="Discrete"} {            
            dict set part_info [$gNode @n] MID "[format %8d $material_num]"
            if {$mass=="0"} {
                GiD_WriteCalculationFile puts -nonewline "[format %8d $material_num]"   
            }
        }        
        
        #In order to print every user defined material
        if {$material_name=="User defined"} {
            set material_name "$material_name$material_num"
        }        

        set group_name [$gNode @n]

        if {$property=="Discrete"} {
            #To avoid material overwriting
            dict set material_info "$group_name $material_num" MID "[format %8d $material_num]"
        } else {
            dict set material_info $material_name MID "[format %8d $material_num]"
        }
        
        set xp {blockdata[@n="General data"]/container[@n="Gravity"]/value[@n="Gravity_Magnitude"]} 
        set valueNode [$root selectNodes $xp]
        set g [format "%8g" [gid_groups_conds::convert_value_to_default $valueNode]]        
        
        if {$property=="Anisotropic_Shell" || $property=="Airbag"} { 
             ###################################ANISOTROPIC MATERIALS##########################################
            
            #ORTHOTROPIC (ANISOTROPIC) AND FABRIC MATERIALS DATA
            
            if {$property=="Anisotropic_Shell"} {
                dict set material_info $material_name TYPE 2
            } else {
                dict set material_info $material_name TYPE 34
            }
            
            #WRITING ANISOTROPIC DATA

            set xp {/*/container[@n="Properties"]/container[@n="Materials"]//} 
            append xp [format_xpath {blockdata[@n="material" and @name=%s]/} $material_name]
            append xp [format_xpath {container[@n=%s]} "material_anisotropic_elastic"]
            set cNode [$root selectNodes $xp]         
            
            foreach i "Ex Ey nuXY Gxy Gxz Gyz" n [list EA EB NUAB GAB GAC GBC] {
                
                set xp ".//value\[@n='$i']"
                set valueNode [$cNode selectNodes $xp]
                
                dict set material_info $material_name $n [format "%8g" [gid_groups_conds::convert_value_to_default $valueNode]]
                
            }
                    
            set xp ".//value\[@n='Specific_weight']"
            set valueNode [$cNode selectNodes $xp]
            set Specific_weight [format "%-8g" [gid_groups_conds::convert_value_to_default $valueNode]]
            
            #WINDOWS NEED 5 CHARACTERS TO PRINT AN EXPONENTIAL NUMBER
            dict set material_info $material_name RHO [format "%8g" [expr ($Specific_weight/$g)]]

            #WRITING AIRBAG DATA

            if {$property=="Airbag"} {
                set xp {/*/container[@n="Properties"]/container[@n="Materials"]//} 
                append xp [format_xpath {blockdata[@n="material" and @name=%s]/} $material_name]
                append xp [format_xpath {container[@n=%s]} "material_airbag"]
                set cNode [$root selectNodes $xp]  

                foreach i "Compressive_stress L_ratio Damping" n [list CSE LRATIO DAMP] {
                    
                    set xp ".//value\[@n='$i']"
                    set valueNode [$cNode selectNodes $xp]   
                    
                    dict set material_info $material_name $n [format "%8g" [gid_groups_conds::convert_value_to_default $valueNode]]                    
                } 

                #Liner data is optional
                foreach i "E_liner nu_liner" n [list EL PRL] {
                    
                    set xp ".//value\[@n='$i']"
                    set valueNode [$cNode selectNodes $xp]
                    set parameter_value [$valueNode @v]

                    if {$parameter_value==""} {
                        dict set material_info $material_name $n -1
                    } else {
                        dict set material_info $material_name $n [format "%8g" [gid_groups_conds::convert_value_to_default $valueNode]]  
                    }                   
                                      
                } 
            } 
        } elseif {$property=="Plasticity_Shell" || $property=="Circular_Plastic_Section" || $property=="Rectangular_Plastic_Section"} {
            ###################################PLASTIC MATERIALS##########################################


            #WE GUESS MATERIAL TYPE
            set xp {container[@n="Properties"]/container[@n="Materials"]/container[@n="materials_types"]/blockdata[@n="material"]}

            foreach gNode [$root selectNodes $xp] { 
                set name [$gNode @name] 
                if {$name==$material_name} {
                    set type [$gNode selectNodes {string(../@pn)}]
                }
            }         
            
            if {$type=="Force Limited"} {
                #FORCE LIMITED MATERIALS DATA
                
                dict set material_info $material_name TYPE 29
                
                set xp {/*/container[@n="Properties"]/container[@n="Materials"]//} 
                append xp [format_xpath {blockdata[@n="material" and @name=%s]/} $material_name]
                append xp [format_xpath {container[@n=%s]} "material_plasticity"]
                set cNode [$root selectNodes $xp]  
                
                # READING PLASTIC DATA
                
                foreach i "Curves_option End_moment Plastic_moment_factor Plastic_torsional_moment_factor Yield_moment Torsional_yield_moment" n [list AOPT M SF SFR YM YMR] {                
                    set xp ".//value\[@n='$i']"
                    set valueNode [$cNode selectNodes $xp]                
                    dict set material_info $material_name $n [format "%8g" [gid_groups_conds::convert_value_to_default $valueNode]]                
                }
                
                #WRITING LOADING CURVE
                
                incr curve_num
                set lcid $curve_num
                
                dict set material_info $material_name LCDR [format %8d $curve_num]      
                
                set xp ".//value\[@n='Factor'\]"
                set valueNode [$cNode selectNodes $xp]
                
                set factor [$cNode selectNodes {string(.//value[@n="Factor"]/@v)}]
                set function [$cNode selectNodes {.//value[@n="Factor"]/function}]                
                
                if { [string trim $factor] eq "" } { set factor 1.0 }
                set function_name "" 
                
                set curve_info ""
                
                if { $function ne "" } {
                    set factor 1.0
                    foreach fNode [$function selectNodes {functionVariable}] {
                        lappend function_name [$fNode @n] [$fNode @variable]
                        dict set curve_info [$cNode @n] $curve_num
                    }            
                    
                    GiD_WriteCalculationFile puts -nonewline "\n*DEFINE_CURVE\n$\n$----LCID-----SIDR------SFA------SFO-----OFFA-----------\n$"
                    GiD_WriteCalculationFile puts -nonewline "\n[format "%8d" $curve_num],[format "%8d" 0],[format "%8g" 1.0],[format "%8g" 1.0]"
                    GiD_WriteCalculationFile puts -nonewline "\n$\n$-----------------AI----------------------OI------------\n$"
                    
                    set xp {functionVariable[@n="interpolator_func" and @variable="Material"]}
                    set fvNode [$function selectNodes $xp]
                    set values [$fvNode selectNodes value]
                    
                    foreach v $values {                        
                        set abcissa_value [lindex [split [$v @v] ,] 0]
                        set ordinate_value [lindex [split [$v @v] ,] 1]
                        GiD_WriteCalculationFile puts -nonewline "\n[format "%20E" $abcissa_value],[format "%20E" $ordinate_value] "
                    }           
                    
                } else {
                    error [= "You must introduce a function in all Force Limited Materials"]
                }             
                
                #  READING ELASTIC DATA
                
                set xp {/*/container[@n="Properties"]/container[@n="Materials"]//} 
                append xp [format_xpath {blockdata[@n="material" and @name=%s]/} $material_name]
                append xp [format_xpath {container[@n=%s]} "material_elastic"]
                set cNode [$root selectNodes $xp]  
                
                foreach i "nu E" n [list PR E] {
                    
                    set xp ".//value\[@n='$i']"
                    set valueNode [$cNode selectNodes $xp]
                    
                    dict set material_info $material_name $n [format "%8g" [gid_groups_conds::convert_value_to_default $valueNode]]                
                }
                
                set xp ".//value\[@n='Specific_weight']"
                set valueNode [$cNode selectNodes $xp]
                set Specific_weight [format "%-8g" [gid_groups_conds::convert_value_to_default $valueNode]]
                
                #WINDOWS NEED 5 CHARACTERS TO PRINT AN EXPONENTIAL NUMBER
                dict set material_info $material_name RHO [format "%8g" [expr ($Specific_weight/$g)]]                
            }  
                        
            if {$type=="Piecewise Linear Plasticity" || $type=="Plastic Kinematic"} {
                #PIECEWISE LINEAR PLASTICITY AND PLASTIC KINEMATIC MATERIALS DATA                

                if {$type=="Piecewise Linear Plasticity"} {
                    dict set material_info $material_name TYPE 24
                }
                if {$type=="Plastic Kinematic"} {
                    dict set material_info $material_name TYPE 3
                }

                
                set xp {/*/container[@n="Properties"]/container[@n="Materials"]//} 
                append xp [format_xpath {blockdata[@n="material" and @name=%s]/} $material_name]
                append xp [format_xpath {container[@n=%s]} "material_plasticity"]
                set cNode [$root selectNodes $xp]  
                
                # READING PLASTIC DATA
                
                foreach i "Elastic_limit Tangent_modulus" n [list SIGY ETAN] {
                    
                    set xp ".//value\[@n='$i']"
                    set valueNode [$cNode selectNodes $xp]
                    
                    dict set material_info $material_name $n [format "%8g" [gid_groups_conds::convert_value_to_default $valueNode]]
                    
                }
                
                set xp {/*/container[@n="Properties"]/container[@n="Materials"]//} 
                append xp [format_xpath {blockdata[@n="material" and @name=%s]/} $material_name]
                append xp [format_xpath {container[@n=%s]} "material_elastic"]
                set cNode [$root selectNodes $xp]  
                
                #  READING ELASTIC DATA
                
                foreach i "nu E" n [list PR E] {
                    
                    set xp ".//value\[@n='$i']"
                    set valueNode [$cNode selectNodes $xp]
                    
                    dict set material_info $material_name $n [format "%8g" [gid_groups_conds::convert_value_to_default $valueNode]]                
                }
                
                set xp ".//value\[@n='Specific_weight']"
                set valueNode [$cNode selectNodes $xp]
                set Specific_weight [format "%-8g" [gid_groups_conds::convert_value_to_default $valueNode]]
                
                #WINDOWS NEED 5 CHARACTERS TO PRINT AN EXPONENTIAL NUMBER
                dict set material_info $material_name RHO [format "%8g" [expr ($Specific_weight/$g)]]                
            }   
            
        } elseif {$property=="Viscoelastic_Solid"} {
            ###################################VISCOELASTIC MATERIALS##########################################
            
            dict set material_info $material_name TYPE 6
            
            set xp {/*/container[@n="Properties"]/container[@n="Materials"]//} 
            append xp [format_xpath {blockdata[@n="material" and @name=%s]/} $material_name]
            append xp [format_xpath {container[@n=%s]} "material_viscoelastic"]
            set cNode [$root selectNodes $xp] 
            
            foreach i "K G0 G Specific_weight Decay_constant" n [list BULK G0 GI RO BETA] {
                
                set xp ".//value\[@n='$i']"
                set valueNode [$cNode selectNodes $xp]
                
                dict set material_info $material_name $n [format "%8g" [gid_groups_conds::convert_value_to_default $valueNode]]                
            }
            
        } elseif {$property=="Seatbelt"} {
            ###################################SEATBELT MATERIALS##########################################
            
            dict set material_info $material_name TYPE 801
            
            set xp {/*/container[@n="Properties"]/container[@n="Materials"]//} 
            append xp [format_xpath {blockdata[@n="material" and @name=%s]/} $material_name]
            append xp [format_xpath {container[@n=%s]} "material_seatbelt"]
            set cNode [$root selectNodes $xp] 
            
            foreach i "Mass Length" n [list MPUL LMIN] {
                
                set xp ".//value\[@n='$i']"
                set valueNode [$cNode selectNodes $xp]
                
                dict set material_info $material_name $n [format "%8g" [gid_groups_conds::convert_value_to_default $valueNode]]                
            }

            #WRITING LOADING CURVE      
     
            set xp ".//value\[@n='Factor_load'\]"
            set valueNode [$cNode selectNodes $xp]
            
            set factor [$cNode selectNodes {string(.//value[@n="Factor_load"]/@v)}]
            set function [$cNode selectNodes {.//value[@n="Factor_load"]/function}]                
            
            if { [string trim $factor] eq "" } { set factor 1.0 }
            set function_name ""             
            set curve_info ""
            
            if { $function ne "" } {
                incr curve_num
                set lcid $curve_num
                
                dict set material_info $material_name LLCID [format %8d $curve_num] 
                
                set factor 1.0
                foreach fNode [$function selectNodes {functionVariable}] {
                    lappend function_name [$fNode @n] [$fNode @variable]
                    dict set curve_info [$cNode @n] $curve_num
                }            
                
                GiD_WriteCalculationFile puts -nonewline "\n*DEFINE_CURVE\n$\n$----LCID-----SIDR------SFA------SFO-----OFFA-----------\n$"
                GiD_WriteCalculationFile puts -nonewline "\n[format "%8d" $curve_num],[format "%8d" 0],[format "%8g" 1.0],[format "%8g" 1.0]"
                GiD_WriteCalculationFile puts -nonewline "\n$\n$-----------------AI----------------------OI------------\n$"
                
                set xp {functionVariable[@n="interpolator_func" and @variable="Material"]}
                set fvNode [$function selectNodes $xp]
                set values [$fvNode selectNodes value]
                
                #First we find force units factor
                
                set ordinate_units [$valueNode @units]
                set xp [format_xpath {units/unit_magnitude[@n="F"]/unit[@n=%s]} $ordinate_units]
                set ordinate_factor [$root getAttributeP $xp factor]  
                
                foreach v $values {                        
                    set abcissa_value [lindex [split [$v @v] ,] 0]
                    set ordinate_value [expr ($ordinate_factor*[lindex [split [$v @v] ,] 1])]
                    GiD_WriteCalculationFile puts -nonewline "\n[format "%20E" $abcissa_value],[format "%20E" $ordinate_value] "
                }        
                
            } else {
                # If not function defined, Load curve is set to 0
                dict set material_info $material_name LLCID [format "%8d" 0]               
            }  

            #WRITING UNLOADING CURVE
            
            set xp ".//value\[@n='Factor_unload'\]"
            set valueNode [$cNode selectNodes $xp]
            
            set factor [$cNode selectNodes {string(.//value[@n="Factor_unload"]/@v)}]
            set function [$cNode selectNodes {.//value[@n="Factor_unload"]/function}]                
            
            if { [string trim $factor] eq "" } { set factor 1.0 }
            set function_name ""             
            set curve_info ""
            
            if { $function ne "" } {
                incr curve_num
                set lcid $curve_num
                
                dict set material_info $material_name ULCID [format %8d $curve_num] 
                
                set factor 1.0
                foreach fNode [$function selectNodes {functionVariable}] {
                    lappend function_name [$fNode @n] [$fNode @variable]
                    dict set curve_info [$cNode @n] $curve_num
                }            
                
                GiD_WriteCalculationFile puts -nonewline "\n*DEFINE_CURVE\n$\n$----LCID-----SIDR------SFA------SFO-----OFFA-----------\n$"
                GiD_WriteCalculationFile puts -nonewline "\n[format "%8d" $curve_num],[format "%8d" 0],[format "%8g" 1.0],[format "%8g" 1.0]"
                GiD_WriteCalculationFile puts -nonewline "\n$\n$-----------------AI----------------------OI------------\n$"
                
                set xp {functionVariable[@n="interpolator_func" and @variable="Material"]}
                set fvNode [$function selectNodes $xp]
                set values [$fvNode selectNodes value]
                
                #First we find force units factor
                
                set ordinate_units [$valueNode @units]
                set xp [format_xpath {units/unit_magnitude[@n="F"]/unit[@n=%s]} $ordinate_units]
                set ordinate_factor [$root getAttributeP $xp factor]  
                
                foreach v $values {                        
                    set abcissa_value [lindex [split [$v @v] ,] 0]
                    set ordinate_value [expr ($ordinate_factor*[lindex [split [$v @v] ,] 1])]
                    GiD_WriteCalculationFile puts -nonewline "\n[format "%20E" $abcissa_value],[format "%20E" $ordinate_value] "
                }        
                
            } else {
                # If not function defined, Load curve is set to 0
                dict set material_info $material_name ULCID [format "%8d" 0]               
            }  

        } elseif {$property=="Discrete"} {
            ###################################DISCRETE MATERIALS##########################################
            
            set xp {container[@n="Properties"]/container[@n="Materials"]/container[@n="materials_types"]/blockdata[@n="material"]} 
            
            foreach gNode [$root selectNodes $xp] { 
                set name [$gNode @name] 
                if {$name==$material_name} {
                    set type [$gNode selectNodes {string(../@pn)}]
                }
            }
            
            set xp {/*/container[@n="Properties"]/container[@n="Materials"]//} 
            append xp [format_xpath {blockdata[@n="material" and @name=%s]/} $material_name]
            append xp [format_xpath {container[@n=%s]} "material_discrete"]
            set cNode [$root selectNodes $xp]   
            
            #WRITING MATERIAL DAMPER VISCOUS DATA
            
            if {$type=="Damper Viscous"} {
                
                dict set material_info "$group_name $material_num" TYPE "S02"
                
                set xp ".//value\[@n='DC'\]"
                set valueNode [$cNode selectNodes $xp]
                set dc [$valueNode @v]
                
                dict set material_info "$group_name $material_num" CD "[format "%8g" $dc]"
                
            }

            #WRITING MATERIAL SPRING ELASTIC DATA

            if {$type=="Spring Elastic"} {
                
                dict set material_info "$group_name $material_num" TYPE "S01"

                if {$motion=="0"} {
                    #transtational springs
                    set xp ".//value\[@n='Elastic_Stiffness_displacement'\]"
                }
                
                if {$motion=="1"} {
                    #rotational springs
                    set xp ".//value\[@n='Elastic_Stiffness_rotation'\]"
                }             
                
                set valueNode [$cNode selectNodes $xp]
                set dc [gid_groups_conds::convert_value_to_default $valueNode]
                
                
                dict set material_info "$group_name $material_num" CD "[format "%8g" $dc]"                
            }
            
            #SAVING MATERIAL DAMPER NONLINEAR VISCOUS, SPRING NONLINEAR ELASTIC AND SPRINF INELASTIC DATA
            
            if {$type=="Damper Nonlinear Viscous" || $type=="Spring Nonlinear Elastic" || $type=="Spring Inelastic"} {
                
                if {$type=="Damper Nonlinear Viscous"} {
                    dict set material_info "$group_name $material_num" TYPE "S05"
                } elseif {$type=="Spring Nonlinear Elastic"} {
                    dict set material_info "$group_name $material_num" TYPE "S04"
                } elseif {$type=="Spring Inelastic"} {
                    dict set material_info "$group_name $material_num" TYPE "S08"
                }
                
                incr curve_num
                set lcid $curve_num
                
                dict set material_info "$group_name $material_num" LCDR [format %8d $curve_num]      
                                
                set xp ".//value\[@n='Factor'\]"
                set valueNode [$cNode selectNodes $xp]
                
                set factor [$cNode selectNodes {string(.//value[@n="Factor"]/@v)}]
                set function [$cNode selectNodes {.//value[@n="Factor"]/function}]                
                
                if { [string trim $factor] eq "" } { set factor 1.0 }
                set function_name "" 
                
                set curve_info ""
                
                if { $function ne "" } {
                    set factor 1.0
                    foreach fNode [$function selectNodes {functionVariable}] {
                        lappend function_name [$fNode @n] [$fNode @variable]
                        dict set curve_info [$cNode @n] $curve_num
                    }            

                    GiD_WriteCalculationFile puts -nonewline "\n*DEFINE_CURVE\n$\n$----LCID-----SIDR------SFA------SFO-----OFFA-----------\n$"
                    GiD_WriteCalculationFile puts -nonewline "\n[format "%8d" $curve_num],[format "%8d" 0],[format "%8g" 1.0],[format "%8g" 1.0]"
                    GiD_WriteCalculationFile puts -nonewline "\n$\n$-----------------AI----------------------OI------------\n$"
                    
                    set xp {functionVariable[@n="interpolator_func" and @variable="Material"]}
                    set fvNode [$function selectNodes $xp]
                    set values [$fvNode selectNodes value]
                    
                    if {$motion=="0"} {
                        
                        #translational motion reading
                        set xp ".//value\[@n='Force_factor'\]"
                        set valueNode [$cNode selectNodes $xp]                        
                        set ordinate_magnitude [$valueNode @v]
                        
                        set ordinate_units [$valueNode @units]
                        set xp [format_xpath {units/unit_magnitude[@n="F"]/unit[@n=%s]} $ordinate_units]
                        set ordinate_fac [$root getAttributeP $xp factor]                        

                    } elseif {$motion=="1"} {
                        
                        #rotational motion reading
                        set xp ".//value\[@n='Moment_factor'\]"
                        set valueNode [$cNode selectNodes $xp]
                        set ordinate_units [$valueNode @units]
                        set ordinate_magnitude [$valueNode @v]
                        
                        #force units
                        set ordinate_units_0 [lindex [split $ordinate_units �] 0]
                        set xp [format_xpath {units/unit_magnitude[@n="F"]/unit[@n=%s]} $ordinate_units_0]
                        set ordinate_fac_0 [$root getAttributeP $xp factor]    

                        #moments units
                        set ordinate_units_1 [lindex [split $ordinate_units �] 1]
                        set xp [format_xpath {units/unit_magnitude[@n="L"]/unit[@n=%s]} $ordinate_units_1]
                        set ordinate_fac_1 [$root getAttributeP $xp factor]                         
                        
                        set ordinate_fac [expr ($ordinate_fac_0*$ordinate_fac_1)]
                    }


                    #WE WRITE ABCISSA FACTORS FOR SPRING NONLINEAR ELASTIC AND SPRING INELASTIC MATERIALS

                    set abcissa_magnitude 1
                    set abcissa_fac 1

                    if {$type=="Spring Nonlinear Elastic" || $type=="Spring Inelastic"} {                        
                        
                        if {$motion=="0"} {     
                            set xp ".//value\[@n='Displacement_factor'\]"
                        } elseif {$motion=="1"} {
                            set xp ".//value\[@n='Rotation_factor'\]"
                        }                          
                        
                        set valueNode [$cNode selectNodes $xp]                        
                        set abcissa_magnitude [$valueNode @v]
                        
                        set abcissa_units [$valueNode @units]
                        
                        if {$motion=="0"} {     
                            set xp [format_xpath {units/unit_magnitude[@n="L"]/unit[@n=%s]} $abcissa_units]
                            set abcissa_fac [$root getAttributeP $xp factor]  
                        } elseif {$motion=="1"} {
                            set abcissa_fac [compute_units_factor rotation $abcissa_units]
                        }                                   
                    }
                    
                    foreach v $values {                        
                        set abcissa_value [expr ($abcissa_magnitude*$abcissa_fac*[lindex [split [$v @v] ,] 0])]
                        set ordinate_value [expr ($ordinate_magnitude*$ordinate_fac*[lindex [split [$v @v] ,] 1])]
                        GiD_WriteCalculationFile puts -nonewline "\n[format "%20E" $abcissa_value],[format "%20E" $ordinate_value] "
                    }           

                } else {
                    error [= "You must introduce a function in all Damper Nonlinear Viscous Materials"]
                } 
                
                #WE WRITE ADDITIONAL DATA FOR SPRING INELASTIC MATERIALS
                
                if {$type=="Spring Inelastic"} {                    
                    
                    set xp ".//value\[@n='Spring_behaviour'\]"
                    set valueNode [$cNode selectNodes $xp]
                    set ctf [$valueNode @v]
                    
                    dict set material_info "$group_name $material_num" CTF "[format "%8g" $ctf]"                    
                          
                    if {$motion=="0"} {
                        #transtational springs
                        set xp ".//value\[@n='Unloading_translational'\]"
                    }
                    
                    if {$motion=="1"} {
                        #rotational springs
                        set xp ".//value\[@n='Unloading_rotational'\]"
                    }                
      
                    set valueNode [$cNode selectNodes $xp]
                    set ku [gid_groups_conds::convert_value_to_default $valueNode]                    
                    
                    dict set material_info "$group_name $material_num" KU "[format "%8g" $ku]"   
                } 
            }
        } else {
             ###################################ELASTIC, RIGID AND NULL MATERIALS##########################################
            
            foreach i "nu E" n [list PR E] {
                
                set xp ".//value\[@n='$i']"
                set valueNode [$gNode selectNodes $xp]
                set value [get_domnode_attribute $valueNode v]
                
                #To avoid units problems
                if {$value=="0.0"} {
                    dict set material_info $material_name $n 0
                } else {
                    dict set material_info $material_name $n [format "%8g" [gid_groups_conds::convert_value_to_default $valueNode]]
                }        
            }
            
            set xp ".//value\[@n='Specific_weight']"
            set valueNode [$gNode selectNodes $xp]
            set Specific_weight [format "%-8g" [gid_groups_conds::convert_value_to_default $valueNode]]
            
            #WINDOWS NEED 5 CHARACTERS TO PRINT AN EXPONENTIAL NUMBER
            dict set material_info $material_name RHO [format "%8g" [expr ($Specific_weight/$g)]]
            
            #CHOOSING MATERIAL'S TYPE
            
            if {$material_name=="User defined$material_num"} {
                #BY DEFAULT WE HAVE AN ELASTIC MATERIAL
                set type 1
            } else { 
                
                set xp {container[@n="Properties"]/container[@n="Materials"]/container[@n="materials_types"]/blockdata[@n="material"]} 
                
                foreach gNode [$root selectNodes $xp] { 
                    set name [$gNode @name] 
                    if {$name==$material_name} {
                        set type [$gNode selectNodes {string(../@pn)}]
                    }
                }
                
                if {$type=="Rigid"} {
                    set type 20
                } elseif {$type=="Null"} {
                    set type 9
                } else {
                    set type 1
                }         
            }
            
            dict set material_info $material_name TYPE $type
        }   
         
    } else {
        #WE FIND MATERIAL MID WHEN IT'S ALREADY SAVED
        foreach id [dict keys $material_info] {
            if {$id==$material_name} {
                #We print inertia parts separately                
                dict set part_info [$gNode @n] MID "[format %8d [dict get $material_info $id MID]]"
                if {$mass=="0"} {
                    GiD_WriteCalculationFile puts -nonewline "[format %8d [dict get $material_info $id MID]]"
                }                
            }
        }
    }

    if {$property=="Discrete"} {
        return $material_num
    } else {
        return [dict get $material_info $material_name MID]
    }
}

###################################################################
#   Module that writes hourglass cards
###################################################################

proc write_hourglass {gNode hourglass_num mass} {

    global part_info  
    upvar 1 hourglass_num hourglass_id
    
    set property_container [$gNode selectNodes {string(../../@n)}]
    
    #HOURGLASS IS ONLY DEFINED FOR SHELLS AND SOLIDS

    if {$property_container!="Solids" && $property_container!="Shells"} {
        #BY DEFAULT, THERE IS NOT HOURGLASS DATA
        dict set part_info [$gNode @n] HGID -1        
        return 0    
    }    

    set xp {.//container[@n='Hourglass']/value[@n='Hourglass_type']}
    set valueNode [$gNode selectNodes $xp]
    set hourglass_type [get_domnode_attribute $valueNode v]
    
    #IS TYPE -1 IS CHOOSEN, NO HOURGLASS IS DEFINED
    if {$hourglass_type=="-1"} { 
        dict set part_info [$gNode @n] HGID -1  
        return 0
    }
    
    incr hourglass_id 

    if {$mass=="0"} {
        #IN *PART, WE WRITE HGID
        GiD_WriteCalculationFile puts -nonewline ",        ,[format "%8d" $hourglass_id]"  
    } else {
        #IN *PART_INERTIA, WE JUST SAVE THIS DATA
        dict set part_info [$gNode @n] HGID $hourglass_id
    } 

    foreach i [list Hourglass_coefficient Linear_bulk Quadratic_bulk] j [list hourglass_coefficient linear_bulk quadratic_bulk] {
        
        set xp {.//container[@n='Hourglass']/value[@n='$i']}
        set xp [subst -nocommands $xp]
        set valueNode [$gNode selectNodes $xp]
        set $j [get_domnode_attribute $valueNode v]
    }
    
    GiD_WriteCalculationFile puts -nonewline "\n*HOURGLASS\n$----HGID------IHQ-------QM------IBQ-------Q1-------Q2-------QB-------QW-------"
    GiD_WriteCalculationFile puts -nonewline "\n[format "%8d" $hourglass_id],[format "%8d" $hourglass_type],[format "%8g" $hourglass_coefficient],[format "%8d" 0],[format "%8g" $linear_bulk],[format "%8g" $quadratic_bulk],[format "%8g" $hourglass_coefficient],[format "%8g" $hourglass_coefficient]"
    
    
    return $hourglass_id   
    
}

################################################################################
#    Detailed results
################################################################################


proc b_write_calc_file::write_detailed_results { root } {

    set formats ""
    set xp {blockdata[@n="General data"]/}
    append xp {condition[@n="Detailed_results"]/group}

    foreach gNode [$root selectNodes $xp] {
        regsub -all {\s+} [$gNode @n] {_} name
        set f "%d $name\n"
        dict set formats [$gNode @n] $f
    }
    if { [dict size $formats]  } {
        GiD_WriteCalculationFile puts "detailed_results"
        GiD_WriteCalculationFile nodes $formats
        GiD_WriteCalculationFile puts "end detailed_results"
    }
}

################################################################################
#    Constraints
################################################################################

proc b_write_calc_file::write_constraints { root } {
    
    variable tablesList
    set problem_type [get_value Problem_type]
    global NumElemsTot

    global curve_num
    global part_info
    global mat_info
    
    set curve_info ""
 
######################WRITING FIXED CONSTRAINTS########################

    #ELASTIC CONSTRAINTS COULD ALSO BE IMPLEMENTED HERE
    set xp1 {container[@n="Constraints"]/condition[@n="Fixed_constraints"]/group}
    
    set formats ""
    set LA 0
    set printed_card 0
    
    #WRITING BPSC BOUNDARY DATA
    
    set write_motion_card 0
    
    foreach gNode [$root selectNodes "$xp1"] {
        
        set spc_error 1
        
        set vs [list X Y Z theta_x theta_y theta_z]
        set vs2 [list Value Velocity Acceleration]
        
        foreach i $vs {  
            
            set xp ".//value\[@n='${i}_Constraint'\]"
            set valueNode [$gNode selectNodes $xp]
            set constraint [$valueNode @v]
            
            if {$constraint} {
                set prescribed_motion 0
                foreach j $vs2 {
                    set xp ".//value\[@n='${i}_${j}'\]"
                    set valueNode [$gNode selectNodes $xp]
                    set disp [$valueNode @v]
                    if {$disp!=0} {
                        set prescribed_motion 1
                        set write_motion_card 1
                    }
                }
                set spc_error 0
            }          
        }
        
        if {$spc_error} {
            error [= "Invalid data, no constraint activated"]; 
            continue
        }
        
        if {!$prescribed_motion} {
            
            set formats ""
            set f ""
            
            if {!$printed_card} {
                GiD_WriteCalculationFile puts "\n*BOUNDARY_SPC_NODE"
                GiD_WriteCalculationFile puts -nonewline "$\n$-----NID------CID-----DOFX-----DOFY-----DOFZ----DOFRX----DOFRY----DOFRZ------------\n$"
                set printed_card 1
            }
            
            #0=>DEFAULT COORDINATE SYSTEM, NUM_NODE+NUM_ELEMS_TOTAL =>SELECTED COORDINATE SYSTEM ********NOT USED NOW*********
            
            set constraint_type "constraints"
            
            set xp ".//value\[@n='Local_axes'\]"
            set valueNode [$gNode selectNodes $xp]
            set v [$valueNode @v]
            
            if { $v } {
                set f {\n%1$8d,[expr (%1$8d+$NumElemsTot)]}        
                set f [subst -novariables -nocommands $f]
                set LA 1
            } else {
                set f "\n%8d,[format "%8d" 0]"
                set LA 0
            }     
            
            foreach i $vs {  
                
                set xp ".//value\[@n='${i}_Constraint'\]"
                set valueNode [$gNode selectNodes $xp]
                set constraint [$valueNode @v]
                
                set active 1
                
                if {$constraint} {
                    foreach j $vs2 {
                        set xp ".//value\[@n='${i}_${j}'\]"
                        set valueNode [$gNode selectNodes $xp]
                        set disp [$valueNode @v]
                        if {$disp!=0} { set active 0 } 
                    }
                }  
                
                if {!$constraint || !$active} {
                    append f ",[format "%8d" 0]"
                } else {
                    append f ",[format "%8d" 1]"
                }
            }
            
            if {$LA} {
                append f {\n*DEFINE_VECTOR\n[expr (%1$8d+$NumElemsTot)],[EAmat 1 1]],[EAmat 2 1],[EAmat 3 1],[EAmat 1 2]],[EAmat 2 2],[EAmat 3 2]}
                set f [subst -novariables -nocommands $f]
            }
            
            dict set formats $constraint_type $LA [$gNode @n] $f              
            
            
            if { !$LA } {
                foreach j [dict keys $formats] { 
                    dict set formats $j 1 ""
                    GiD_WriteCalculationFile nodes -unique -localaxes [dict get $formats $j 1]\
                        [dict get $formats $j 0]          
                }  
            } else {
                foreach j [dict keys $formats] { 
                    dict set formats $j 0 ""
                    GiD_WriteCalculationFile nodes -unique -do_subst -localaxes [dict get $formats $j 1]\
                        [dict get $formats $j 0]          
                }   
            }
        }
    }
    
    
################WRITING PRESCRIBED MOTION CARD###############################################
    
    if {$write_motion_card} {

        set printed_card 0
        
        set direction 1
        
        foreach i $vs {
            
            foreach gNode [$root selectNodes "$xp1"] { 
                
                foreach j $vs2 {
                    
                    set formats "formats$i"
                    set motion 0
                    
                    set xp ".//value\[@n='Factor_${j}'\]"
                    set valueNode [$gNode selectNodes $xp]

                    #THIS SWITCH CAN BE DONE AUTOMATICLY

                    switch $j {
                        Value {
                            set factor [$gNode selectNodes {string(.//value[@n="Factor_Value"]/@v)}]
                            set function [$gNode selectNodes {.//value[@n="Factor_Value"]/function}]  
                        }
                        Velocity {
                            set factor [$gNode selectNodes {string(.//value[@n="Factor_Velocity"]/@v)}]
                            set function [$gNode selectNodes {.//value[@n="Factor_Velocity"]/function}]  
                        }
                        Acceleration {
                            set factor [$gNode selectNodes {string(.//value[@n="Factor_Acceleration"]/@v)}]
                            set function [$gNode selectNodes {.//value[@n="Factor_Acceleration"]/function}]  
                        }
                    }                 
                    
                    if { [string trim $factor] eq "" } { set factor 1.0 }
                    set function_name "" 
                    
                    #Warning: WE HAVE CHANGED CURVEINFO HERE BECAUSE WE COULD HAVE THREE LCID IN EACH GROUP
                    #Be careful if it affects other function definitions

                    set lcid 1
                    
                    if { $function ne "" } {
                        set factor 1.0
                        foreach fNode [$function selectNodes {functionVariable}] {
                            lappend function_name [$fNode @n] [$fNode @variable]
                            #FOR EACH NODE, WE ONLY WRITE THE FUNTION AT i=X
                            if {$i=="X"} { 
                                incr curve_num 
                                dict set curve_info [$gNode @n] $j $curve_num
                                set lcid $curve_num
                            } else {
                                set lcid [dict get $curve_info [$gNode @n] $j]
                            }
                        }
                    }
                    
                    if { ![string is double -strict $factor] } {
                        error [= "Error in loadcase '%s', load '%s', group '%s'. Factor is not correct" \
                                $loadcase $load [$gNode @n]]
                    }
                    
                    #FOR EACH NODE, WE ONLY WRITE THE FUNTION AT i=X
                    
                    if {$i=="X"} {
                        
                        switch -regexp -- [string trim [join $function_name " "]] {
                            "^$" { }
                            
                            {^sinusoidal_load t$} {
                                
                                set function_info ""
                                
                                set fvNode [$function selectNodes {functionVariable[@n="sinusoidal_load"]}]
                                set xp {string(value[@n="amplitude"]/@v)}
                                set A [$fvNode selectNodes $xp]
                                
                                #ENDING AND INITIAL TIME NOT IMPLEMENTED
                                foreach l [list circular_frequency phase_angle ] \
                                    m [list freq phi ] {
                                    
                                    set xp [format_xpath {value[@n=%s]} $l]
                                    dict set function_info $m [gid_groups_conds::convert_value_to_default [$fvNode selectNodes $xp]]
                                }
                                
                                GiD_WriteCalculationFile puts -nonewline "\n*DEFINE_CURVE_FUNCTION\n$\n$----LCID-----SIDR------SFA------SFO-----OFFA-----------\n$"
                                #                             GiD_WriteCalculationFile puts -nonewline "\n[format "%8d" $curve_num],[format "%8d" 0],[format "%8g" 1.0],[format "%8g" 1.0],[format "%8g" [dict get $function_info ti]]\n$\n$-FUNCTION-------\n$"
                                GiD_WriteCalculationFile puts -nonewline "\n[format "%8d" $curve_num],\n$\n$-FUNCTION-------\n$"
                                GiD_WriteCalculationFile puts -nonewline "\n$A*SIN([dict get $function_info freq]*TIME+[dict get $function_info phi])"                    
                            }  
                            
                            {^interpolator_func t$} {
                                
                                GiD_WriteCalculationFile puts -nonewline "\n*DEFINE_CURVE\n$\n$----LCID-----SIDR------SFA------SFO-----OFFA-----------\n$"
                                GiD_WriteCalculationFile puts -nonewline "\n[format "%8d" $curve_num],[format "%8d" 0],[format "%8g" 1.0],[format "%8g" 1.0]"
                                GiD_WriteCalculationFile puts -nonewline "\n$\n$-----------------AI----------------------OI------------\n$"
                                
                                set xp {functionVariable[@n="interpolator_func" and @variable="t"]}
                                set fvNode [$function selectNodes $xp]
                                set values [$fvNode selectNodes value]

                                #WE FIND TIME UNITS FACTOR
                                set time_units  [$fvNode @units]
                                set time_factor [compute_units_factor time $time_units]             

                                foreach v $values {
                                    set ordinate_value [lindex [split [$v @v] ,] 1]
                                    set abcissa_value [ expr ($time_factor*[lindex [split [$v @v] ,] 0])]
                                    GiD_WriteCalculationFile puts -nonewline "\n[format "%20E" $abcissa_value],[format "%20E" $ordinate_value] "
                                }             
                            }
                            default {
                                error [= "Function load not implemented" $function_name]
                            }
                        }  

                        #WE MUST REPRINT THE PRESCRIBED MOTION CARD AFTER A FUNCTION
                        set printed_card 0
                    }         
                    
                    #ALL THESE PARAMETERS WOULD BE VARIABLE
                    set xp {.//value[@n='Local_axes']}
                    set constraint_type "constraints"
                    set LA 0
                    
                    #TRANSLATING type form members of vs2
                    set list_type [list 2 0 1]
                    set type [lindex $list_type [lsearch $vs2 $j]]
                    
                    set xp ".//value\[@n='${i}_${j}'\]"
                    set valueNode [$gNode selectNodes $xp]
                    set disp [gid_groups_conds::convert_value_to_default $valueNode]
                    set disp [expr {$factor*$disp}]
                    set disp [format "%8g" $disp]     
                    
                    if {$disp!="0"} {
                        set f "\n%8d,[format "%8d" $direction],[format "%8d" $type],[format "%8d" $lcid],$disp,        ,        ,        " 
                        dict set $formats $constraint_type $LA [$gNode @n] $f
                        set motion 1
                    }  
                    
                    if {$motion} {
                        #FIRST WE GUESS IF SPECIFIED GROUP IS AN ALREADY EXISTING RIGID BODY (*BOUNDARY_PRESCRIBED_MOTION_RIGID)

                        set mat_type 0
                        
                        if {[dict exists $part_info [$gNode @n]]} {
                            #We find MID
                            set mat_id [dict get $part_info [$gNode @n] MID]
                            
                            #We find material type
                            dict for {id info} $mat_info {
                                dict with info {
                                    if {$mat_id==$MID} {
                                        set mat_type $TYPE
                                    }
                                }
                            }
                        }
                        
                        if {$mat_type=="20"} {
                            #We precribe a rigid body motion
                            GiD_WriteCalculationFile puts -nonewline "\n*BOUNDARY_PRESCRIBED_MOTION_RIGID"
                            GiD_WriteCalculationFile puts -nonewline "\n$\n$-----PID------DOF------VAD-----LCID-------SF------VID----DEATH----BIRTH-------\n$"
                            GiD_WriteCalculationFile puts -nonewline "\n[dict get $part_info [$gNode @n] PID],[format "%8d" $direction],[format "%8d" $type],[format "%8d" $lcid],$disp,        ,        ,        "   
                        } else {   
                            #We prescribe the motion as a set of nodes
                            set values [subst "$$formats"]
                            foreach k [dict keys $values] {                              
                                dict set values $k 1 ""
                                if {$printed_card=="0"} {
                                    GiD_WriteCalculationFile puts "\n*BOUNDARY_PRESCRIBED_MOTION_NODE"
                                    GiD_WriteCalculationFile puts -nonewline "$\n$-----NID------DOF------VAD-----LCID-------SF------VID----DEATH----BIRTH-------\n$"
                                    set printed_card 1
                                }
                                GiD_WriteCalculationFile nodes -unique -localaxes [dict get $values $k 1]\
                                    [dict get $values $k 0]
                            }
                        }                        
                    }    
                }   
            }
            if {$direction=="3"} {
                set direction [expr { $direction+2 }]
            } else {
                incr direction
            }
        }
}

    ##################WRITING CONTACTS##############################################################

    
    set set_info ""
    set contact_info ""
    global part_info
    
    #set_num is a global variable because it is used in loads section
    global set_num

    #IT WOULD START IN PART NUMBER+1
#     set set_num [dict size $part_info]
    
    
    ##########SAVING MASTER SLAVE CONTACTS###########
    
    foreach i [list 1 2] {
        
        set xp {container[@n="Constraints"]/container[@n="Contacts"]/condition[@n="Contacts"]/groupList}
        append xp {/group[$i]}
        set xp [subst -nocommands $xp]
        
        set contact_num 0
        
        foreach gNode [$root selectNodes $xp] {
            
            incr contact_num
            
            set xp "..//value\[@n='Contact_type'\]"
            set valueNode [$gNode selectNodes $xp]
            set type [$valueNode @v]
            
            set set_name [$gNode @n]  
            
            #FIRST WE STUDY IF IT'S AN ALREADY EXISTING PART
            
            if {[dict exists $part_info $set_name]} {
                set set_id [dict get $part_info $set_name PID]
                #CLASS 3--> PART ID
                set card "3"                
            } else {
                
                #WRITING SET SEGMENTS AND SET NODES  
                
                #ASSIGN WRITING WAY
                set card ""
                #CLASS 0--> SEGMENT SET ID
                if {$type=="Surface_to_surface" || $type=="Automatic_surface_to_surface" || ($type=="Nodes_to_surface" && $i=="2") || ($type=="Automatic_nodes_to_surface" && $i=="2")} { set card "0" }
                #CLASS 4--> SET NODE ID
                if {($type=="Nodes_to_surface" && $i=="1") || ($type=="Automatic_nodes_to_surface" && $i=="1")} { set card "4" }
                #IN RIGID BODIES TYPE YOU MUST SELECT AN ALREADY EXISTING PART
                if {$type=="Rigid_body_one_way"} {error [= "Rigid body to Rigid body contacts must be attached to already existing groups only"]}
                
                
                if {[dict exists $set_info $set_name]} {
                    
                    #WE VERIFY IF THE GROUP EXISTS AND IF IT'S WRITTEN IN THE SAME WAY
                    
                    foreach id [dict keys $set_info] {
                        if {$id==$set_name} {
                            set set_id [dict get $set_info $id ID]
                            set ancient_card [dict get $set_info $id CARD]
                        }
                    }
                    
                }
                
                #IF IT ISN'T ALREADY WRITTEN (OR NOT IN THE SAME WAY) WE MUST DO IT
                
                if {![dict exists $set_info $set_name] || $card!=$ancient_card} {
                    
                    incr set_num
                    set set_id $set_num
                    dict set set_info $set_name ID $set_num
                    
                    if {$card=="0"} { 
                        GiD_WriteCalculationFile puts -nonewline "\n*SET_SEGMENT\n$\n$-----SID------DA1------DA2------DA3------DA4-----\n$"
                        GiD_WriteCalculationFile puts -nonewline "\n[format "%8d" $set_num],\n$\n$-------N1-------N2-------N3-------N4-------A1-------A2-------A3-------A4--------\n$"
                    }
                    
                    if {$card=="4"} {
                        GiD_WriteCalculationFile puts -nonewline "\n*SET_NODE_COLUMN\n$\n$-----SID------DA1------DA2------DA3------DA4-----\n$"
                        GiD_WriteCalculationFile puts -nonewline "\n[format "%8d" $set_num],\n$\n$-------N1,N2,N3...----------\n$"  
                    }             
                    
                    set groupsContact ""
                    dict set groupsContact [$gNode @n] $set_num    
                    
                    set isquadratic [lindex [GiD_Info Project] 5]
                    
                    if {$card=="0"} {
                        
                        foreach elemtype [list Triangle Quadrilateral] {
                            
                            switch $elemtype {                
                                Triangle {
                                    switch $isquadratic {
                                        0 { set nnode 3 }
                                        default { error [= "Quadratic triangular elements are not supported"]}
                                    }
                                }
                                Quadrilateral {
                                    switch $isquadratic {
                                        0 { set nnode 4 }
                                        1 { error [= "Quadratic quadrilateral elements are not supported"] }
                                        2 { error [= "Quadratic 9-noded quadrilateral elements are not supported"]}
                                    }
                                }
                            }
                            set formats ""
                            set f ""
                            
                            if {$nnode=="3"} {
                                set f {\n%1$.0s%2$8d,%3$8d,%4$8d,%4$8d}
                            } elseif {$nnode=="4"} {
                                set f {\n%.0s [lrepeat $nnode %9d]}
                            }
                            
                            set f [subst -novariables $f] 
                            
                            dict for "n v" $groupsContact {
                                #I CAN'T DELETE THE EXTRA SPACE
                                dict set formats $n "$f"
                            }
                            
                            if { [GiD_WriteCalculationFile has_elements -elemtype $elemtype $formats] } {
                                set Contact_elements [GiD_WriteCalculationFile connectivities -elemtype $elemtype $formats]
                            }
                        }
                    }
                    
                    if {$card=="4"} {
                        
                        set formats ""
                        set f ""
                        
                        set f "\n%8d,"
                        
                        dict for "n v" $groupsContact {
                            #I CAN'T DELETE THE EXTRA SPACE
                            dict set formats $n "$f"
                        }
                        
                        set Contact_elements [GiD_WriteCalculationFile nodes -unique $formats]
                    }
                    
                    dict set set_info $set_name CARD $card
                    
                } 
            }
            
            dict set contact_info $contact_num ${i}_id $set_id
            dict set contact_info $contact_num ${i}_card $card
            dict set contact_info $contact_num type $type
            
            #WE SAVE ADITIONAL CONTACT DATA
            
            foreach j [list Static_friction Dynamic_friction Viscous_damping Small_penetration Slave_penalty Master_penalty] l [list FS FD VDC PENCHK SFS SFM] {
                
                set xp "..//value\[@n='${j}'\]"
                set xp [subst -nocommands $xp]
                set valueNode [$gNode selectNodes $xp]
                dict set contact_info $contact_num $l [$valueNode @v]
            }
            
            #IN RIGID BODY TO RIGID BODY CONTACTS
            
            if {$type=="Rigid_body_one_way"} {

                #Savig aditional parameters
                foreach j [list Force_method Unloading_stiffness] l [list FCM US] {  
                    set xp "..//value\[@n='${j}'\]"
                    set xp [subst -nocommands $xp]
                    set valueNode [$gNode selectNodes $xp]
                    dict set contact_info $contact_num $l [$valueNode @v]
                }

                #Writing loading curve                
                set xp "..//value\[@n='Factor'\]"
                set valueNode [$gNode selectNodes $xp]     
                set function [$valueNode selectNodes {.//function}]
                
                set function_name "" 
                
                set lcid 1
                
                if { $function eq "" } {
                    error [= "You must define a curve for every Rigid Body contact to Rigid Body contact"]
                } else {
                    set factor 1.0
                    foreach fNode [$function selectNodes {functionVariable}] {
                        lappend function_name [$fNode @n] [$fNode @variable]
                        #FOR EACH CONTACT, WE ONLY WRITE THE FUNCTION ONLY ONCE (AT i=1)
                        if {$i=="1"} { 
                            incr curve_num 
                            dict set curve_info $contact_num $curve_num
                            set lcid $curve_num
                        } else {
                            set lcid [dict get $curve_info $contact_num]
                        }
                    }
                }
                
                if { ![string is double -strict $factor] } {
                    error [= "Curve not correct in Rigid Body to Rigid Body contacts"]
                }
                
                #FOR EACH NODE, WE ONLY WRITE THE FUNTION AT i=1
                
                if {$i=="1"} {
                    
                    #WE WILL HAVE ONLY INTERPOLATOR TYPE FUNCTION       
                    
                    GiD_WriteCalculationFile puts -nonewline "\n*DEFINE_CURVE\n$\n$----LCID-----SIDR------SFA------SFO-----OFFA-----------\n$"
                    GiD_WriteCalculationFile puts -nonewline "\n[format "%8d" $curve_num],[format "%8d" 0],[format "%8g" 1.0],[format "%8g" 1.0]"
                    GiD_WriteCalculationFile puts -nonewline "\n$\n$-----------------AI----------------------OI------------\n$"
                    
                    set xp {functionVariable[@n="interpolator_func" and @variable="Material"]}
                    set fvNode [$function selectNodes $xp]
                    set values [$fvNode selectNodes value]
                    
                    #WE FIND DISP UNITS FACTOR
                    set disp_units  [$fvNode @units]
                    set xp [format_xpath {units/unit_magnitude[@n="L"]/unit[@n=%s]} $disp_units]
                    set disp_factor [$root getAttributeP $xp factor]   
                    
                    foreach v $values {
                        set ordinate_value [lindex [split [$v @v] ,] 1]
                        set abcissa_value [ expr ($disp_factor*[lindex [split [$v @v] ,] 0])]
                        GiD_WriteCalculationFile puts -nonewline "\n[format "%20E" $abcissa_value],[format "%20E" $ordinate_value] "
                    }           
                    
                }
                
                dict set contact_info $contact_num LCID $lcid
                
            }
        }
    }
    

    ##########SAVING SINGLE CONTACTS###########


    set xp {container[@n="Constraints"]/container[@n="Contacts"]/container[@n="Single_contacts"]/blockdata[@n="Automatic_contact"]/condition/group}   
    set last_name ""
    
    foreach gNode [$root selectNodes $xp] {
        
        set xp {string(ancestor::blockdata[@n='Automatic_contact']/@name)}
        set contactname [$gNode selectNodes $xp]
        regsub -all {\s+} $contactname {_} name
        
#         set xp [format_xpath {container[@n="Constraints"]/container[@n="Contacts"]/container[@n="Single_contacts"]/blockdata[@name=%s]/condition[@n="Groups"]/value[@n="Contact_type"]} $contactname] 
        set xp [format_xpath {container[@n="Constraints"]/container[@n="Contacts"]/container[@n="Single_contacts"]/blockdata[@name=%s]/value[@n="Contact_type"]} $contactname]
        set valueNode [$root selectNodes $xp]
        set type [$valueNode @v]
        
        if {$type=="Automatic_single_surface"} {
            
            if {$contactname!=$last_name} {
                
                incr contact_num
                incr set_num
                
                #WE DONT HAVE TO PRINT TWO 0's
                dict set contact_info $contact_num 2_id 0
                dict set contact_info $contact_num 2_card 0
                dict set contact_info $contact_num type $type
                #TYPE 2--> SET PART ID
                dict set contact_info $contact_num 1_card 2
                dict set contact_info $contact_num 1_id $set_num
                
                #WE SAVE ADITIONAL CONTACT DATA
                
                foreach j [list Static_friction Dynamic_friction Viscous_damping Small_penetration Slave_penalty Master_penalty] l [list FS FD VDC PENCHK SFS SFM] {
                    
                    set xp [format_xpath {container[@n="Constraints"]/container[@n="Contacts"]/container[@n="Single_contacts"]/blockdata[@name=%s]/value[@n="$j"]} $contactname]
                    set xp [subst -nocommands $xp]
                    set valueNode [$root selectNodes $xp]
                    dict set contact_info $contact_num $l [$valueNode @v]
                }  
            
            GiD_WriteCalculationFile puts -nonewline "\n*SET_PART_COLUMN\n$\n$-----SID------DA1------DA2------DA3------DA4-----\n$"
            GiD_WriteCalculationFile puts -nonewline "\n[format "%8d" $set_num]," 
            GiD_WriteCalculationFile puts -nonewline "\n$-----PID------" 
        }
        
        set set_name [$gNode @n]
        GiD_WriteCalculationFile puts -nonewline "\n[format "%8d" [dict get $part_info $set_name PID]],"
    }
    
    set last_name $contactname
}


    ##########SAVING "CONTACT ALL"#######################

    set xp {container[@n="Constraints"]/container[@n="Contacts"]/blockdata[@n="Contact_all"]/value[@n="Contact_type"]}
    set valueNode [$root selectNodes $xp]
    set contact_all [$valueNode @v]

    #AT THE MOMENT, ONLY AUTOMATIC_SINGLE SURFACE AVAILABLE
    
    if {$contact_all=="Automatic_single_surface"} {
        
        set type "Automatic_single_surface"

        incr contact_num
        
        #WE DONT HAVE TO PRINT TWO 0's
        dict set contact_info $contact_num 2_id 0
        dict set contact_info $contact_num 2_card 0
        dict set contact_info $contact_num type $type
        dict set contact_info $contact_num 1_id 0
        dict set contact_info $contact_num 1_card 0
        
        #WE SAVE ALL ADITIONAL DATA
        
        foreach j [list Static_friction Dynamic_friction Viscous_damping Small_penetration Slave_penalty Master_penalty] l [list FS FD VDC PENCHK SFS SFM] {
            
            set xp {container[@n="Constraints"]/container[@n="Contacts"]/blockdata[@n="Contact_all"]/value[@n="$j"]}
            set xp [subst -nocommands $xp]
            set valueNode [$root selectNodes $xp]
            dict set contact_info $contact_num $l [$valueNode @v]
        } 

    }
    
    ##########WRITING SINGLE AND SLAVE MASTER CONTACTS#########################
    
    dict for {id info} $contact_info {
        
        dict with info {
            switch $type {
                Surface_to_surface {
                    GiD_WriteCalculationFile puts -nonewline "\n*CONTACT_SURFACE_TO_SURFACE"
                }
                Automatic_surface_to_surface {
                    GiD_WriteCalculationFile puts -nonewline "\n*CONTACT_AUTOMATIC_SURFACE_TO_SURFACE"
                }
                Nodes_to_surface {
                    GiD_WriteCalculationFile puts -nonewline "\n*CONTACT_NODES_TO_SURFACE"
                }
                Automatic_nodes_to_surface {
                    GiD_WriteCalculationFile puts -nonewline "\n*CONTACT_AUTOMATIC_NODES_TO_SURFACE"
                }
                Automatic_single_surface {
                    GiD_WriteCalculationFile puts -nonewline "\n*CONTACT_AUTOMATIC_SINGLE_SURFACE"
                }
                Rigid_body_one_way {
                    GiD_WriteCalculationFile puts -nonewline "\n*CONTACT_RIGID_BODY_ONE_WAY_TO_RIGID_BODY"
                }
            }          
            
            GiD_WriteCalculationFile puts -nonewline "\n$\n$----SSID-----MSID----SSTYP----MSTYP---SBOXID---MBOXID------SPR------MPR-------\n$"
            
            if {[format "%8d" $1_id]=="0" && [format "%8d" $2_id]=="0"} {
                #WRITING "CONTACT ALL"
                GiD_WriteCalculationFile puts -nonewline "\n[format "%8d" 0],"
            } elseif {[format "%8d" $1_id]!="0" && [format "%8d" $2_id]=="0"} {
                #WRITING SINGLE CONTACTS 
                GiD_WriteCalculationFile puts -nonewline "\n[format "%8d" $1_id],[format "%8d" $2_id],[format "%8d" $1_card],"
            } else {
                #WRITING MASTER SLAVE CONTACTS
                GiD_WriteCalculationFile puts -nonewline "\n[format "%8d" $1_id],[format "%8d" $2_id],[format "%8d" $1_card],[format "%8d" $2_card]"
            }
            
            GiD_WriteCalculationFile puts -nonewline "\n$\n$------FS-------FD-------DC-------VC-------VDC-------PENCHK-------BT-------DT-------\n$"
            GiD_WriteCalculationFile puts -nonewline "\n[format "%8g" $FS],[format "%8g" $FD],        ,        ,[format "%8g" $VDC],[format "%8d" $PENCHK]"
            GiD_WriteCalculationFile puts -nonewline "\n$\n$-----SFS------SFM------SST------MST-----SFST-----SFMT------FSF------VSF-------\n$"
            GiD_WriteCalculationFile puts -nonewline "\n[format "%8g" $SFS],[format "%8g" $SFM]" 
            
            if {$type=="Rigid_body_one_way"} {
                GiD_WriteCalculationFile puts -nonewline "\n$\n$----LCID------FCM-------US-----------\n$"
                GiD_WriteCalculationFile puts -nonewline "\n[format "%8d" $LCID],[format "%8d" $FCM]"
                
                if {$US==""} {
                    GiD_WriteCalculationFile puts -nonewline ",        "
                } else {
                    GiD_WriteCalculationFile puts -nonewline ",[format "%8g" $US]"
                }
            }            
        }
    } 

    #IF THERE IS SOME CONTACT, WE ALSO WRITE CONTROL CONTACT CARD 

    if {[dict size $contact_info]!="0" || $contact_all} {
        GiD_WriteCalculationFile puts -nonewline "\n*CONTROL_CONTACT"
        GiD_WriteCalculationFile puts -nonewline "\n$\n$--SLSFAC---RWPNAL---ISLCHK---SHLTHK---PENOPT---THKCHG----ORIEN---ENMASS-------\n$"

        foreach i [list Orientation Maximum_penetration Penalty_factor Penalty_stiffness Contact_cycles] j [list orientation penetration factor stiffness cycles] {
            set xp {container[@n="Constraints"]/container[@n="Contacts"]/container[@n="Control"]/value[@n="$i"]} 
            set xp [subst -nocommands $xp]
            set valueNode [$root selectNodes $xp]
            set $j [$valueNode @v]
        }

        GiD_WriteCalculationFile puts -nonewline "\n[format "%8g" $factor],        ,        ,        ,[format "%8d" $stiffness],        ,[format %8d $orientation]"

        GiD_WriteCalculationFile puts -nonewline "\n$\n$--USRSTR---USRFAC----NSBCS---INTERM----XPENE----SSTHK-----ECDT--TIEDPRJ-------\n$"

        GiD_WriteCalculationFile puts -nonewline "\n        ,        ,"

        #If cycles=0, we less default values
        if {$cycles=="0"} {
            GiD_WriteCalculationFile puts -nonewline "        ,"
        } else {
             GiD_WriteCalculationFile puts -nonewline "[format "%8d" $cycles],"
        }

        GiD_WriteCalculationFile puts -nonewline "        ,[format "%8g" $penetration]"
    }



    ##################WRITING JOINTS##############################################################


    #Note: To avoid data mixture, we will do four times the groups loop

    global NumNodesTot
    set original_nodes_num $NumNodesTot
 
    set xp {container[@n="Constraints"]/condition[@n="Joints"]/groupList}

    #CONTACT CARD GENERATION
    
    foreach gNode [$root selectNodes $xp] {
        
        set xp {.//value[@n='Joint_type']}
        set valueNode [$gNode selectNodes $xp]
        set type [$valueNode @v]

        switch $type {
            Spherical {
                GiD_WriteCalculationFile puts -nonewline "\n*CONSTRAINED_JOINT_SPHERICAL"   
                set j 2
            }
            Revolute {
                GiD_WriteCalculationFile puts -nonewline "\n*CONSTRAINED_JOINT_REVOLUTE"   
                set j 4
            }
            Translational {
                GiD_WriteCalculationFile puts -nonewline "\n*CONSTRAINED_JOINT_TRANSLATIONAL"   
                set j 6
            }
        }    

        GiD_WriteCalculationFile puts -nonewline "\n$\n$------N1-------N2-------N3-------N4-------N5-------N6------RPS-----DAMP-------\n$\n"

        #Now we create j new NID's
        #We will also write each entered point twice (as two nodes) 
        
        while {$j>0} {            
            incr NumNodesTot
            GiD_WriteCalculationFile puts -nonewline "[format "%8d" $NumNodesTot],"            
            set j [expr ($j-1)]
        }

        #We write blank nodes
        
        switch $type {
            Spherical {
                GiD_WriteCalculationFile puts -nonewline "[format "%8d" 0],[format "%8d" 0],[format "%8d" 0],[format "%8d" 0]," 
            }
            Revolute {
                GiD_WriteCalculationFile puts -nonewline "[format "%8d" 0],[format "%8d" 0]," 
            }
            Translational {
                #NO BLANK NODES ARE REQUIRED
            }
        }  
        
        #We write additional data
        
        foreach i [list Relative_penalty Damping_factor] {
            
            set xp ".//value\[@n='${i}'\]"
            set valueNode [$gNode selectNodes $xp]
            set value [$valueNode @v]
            GiD_WriteCalculationFile puts -nonewline "[format "%8g" $value],"
            
        }  
    }

    #WRITING EXTRA NODE CARDS

    set printed_card 0   
    
    foreach i [list 1 2] {
        
        set xp {container[@n="Constraints"]/condition[@n="Joints"]/groupList}
        append xp {/group[$i]}
        set xp [subst -nocommands $xp]
        
        set joint_num 0
        
        foreach gNode [$root selectNodes $xp] {
            
            incr joint_num
            
            if {$printed_card=="0"} {
                GiD_WriteCalculationFile puts -nonewline "\n*CONSTRAINED_EXTRA_NODES_NODE\n$\n$-----PID-----NSID-----\n$"
                set printed_card 1
            }
            
            #FIRST WE OBTAIN PART ID
            
            set part_name [$gNode @n]
            set part_id [dict get $part_info $part_name PID]
            
            #NOW WE COMPUTE NODE ID (BECAUSE WE KNOW JOINT NUMBER)
            
            set node_id [expr ($original_nodes_num + $joint_num + $joint_num + $i -2)]
            GiD_WriteCalculationFile puts -nonewline "\n[format "%8d" $part_id],[format "%8d" $node_id]"        
                   
            set xp "..//value\[@n='Joint_type'\]"
            set valueNode [$gNode selectNodes $xp]
            set type [$valueNode @v]

            #IF JOINT TYPE REVOLUTE, WE MUST DO THIS PROCESS ONCE AGAIN (BECAUSE WE HAVE 4 NODES IN EACH CARD), AND TWICE IN TRANSLATIONAL JOINTS

            switch $type {
                Spherical {
                    set j 0
                }
                Revolute {
                    set j 1
                }
                Translational {
                    set j 2
                }
            }
            
            while {$j>0} {              
                incr joint_num
                set node_id [expr ($original_nodes_num + $joint_num + $joint_num + $i -2)]
                GiD_WriteCalculationFile puts -nonewline "\n[format "%8d" $part_id],[format "%8d" $node_id]"
                set j [expr ($j-1)]
            }         
        }        
    }


    #SAVING STIFFNESS DATA (IF NEEDED)

    global NumElemsTot
    set joint_stiffness_info ""
    set pi 3.1415926535897931
    set printed_card 0

    foreach i [list 1 2] {
        
        set xp {container[@n="Constraints"]/condition[@n="Joints"]/groupList}
        append xp {/group[$i]}
        set xp [subst -nocommands $xp]
        
        set stiff_joint_num 0
        
        foreach gNode [$root selectNodes $xp] {        
            
            set xp "..//value\[@n='Define_stiffness'\]"
            set valueNode [$gNode selectNodes $xp]
            set stiffness_activation [$valueNode @v]
            
            if {$stiffness_activation=="0"} continue   
            
            incr stiff_joint_num 
            
            #WE OBTAIN PART ID
            
            set part_name [$gNode @n]
            set part_id [dict get $part_info $part_name PID]
            dict set joint_stiffness_info $stiff_joint_num ${i}_id $part_id
            
            #We record stiffness data only once
            
            if {$i=="1"} {                
                
                foreach j [list Mx_friction My_friction Mz_friction Stiffness_x Stiffness_y Stiffness_z] z [list FMPH FMT FMPS ESPH EST ESPS ] {   
                    set xp "..//value\[@n='${j}'\]"
                    set valueNode [$gNode selectNodes $xp]
                    set value [gid_groups_conds::convert_value_to_default $valueNode]
                    dict set joint_stiffness_info $stiff_joint_num $z $value               
                }
                
                
                foreach j [list Angle_x_positive Angle_x_negative Angle_y_positive Angle_y_negative Angle_z_positive Angle_z_negative] z [list PSAPH NSAPH PSAT NSAT PSAPS NSAPS] {
                    set xp "..//value\[@n='${j}'\]"
                    set valueNode [$gNode selectNodes $xp]
                    set value [gid_groups_conds::convert_value_to_default $valueNode]
                    #degrees must be expressed in degrees                    
                    set value [expr ($value*180/$pi)]
                    dict set joint_stiffness_info $stiff_joint_num $z $value                   
                    
                }
                
                
                foreach j [list Factor_Mx Factor_My Factor_Mz Factor_Mdx Factor_Mdy Factor_Mdz] z [list LCIDPH LCIDT LCIDPS DLCIDPH DLCIDT DLCIDPS] k [list rotation rotation rotation velocity velocity velocity] {
                    
                    set xp "..//value\[@n='${j}'\]"
                    set valueNode [$gNode selectNodes $xp]     
                    set function [$valueNode selectNodes {.//function}]                   
                    
                    if { $function eq "" } {
                        #if no equation is entered lcid is set to zero
                        dict set joint_stiffness_info $stiff_joint_num $z 0
                    } else {    
                        incr curve_num
                        dict set joint_stiffness_info $stiff_joint_num $z $curve_num   
                        
                        set function_name ""                         
                        set curve_info ""                      
                        
                        foreach fNode [$function selectNodes {functionVariable}] {
                            lappend function_name [$fNode @n] [$fNode @variable]
                            dict set curve_info [$gNode @n] $curve_num
                        }  
                        
                        GiD_WriteCalculationFile puts -nonewline "\n*DEFINE_CURVE\n$\n$----LCID-----SIDR------SFA------SFO-----OFFA-----------\n$"
                        GiD_WriteCalculationFile puts -nonewline "\n[format "%8d" $curve_num],[format "%8d" 0],[format "%8g" 1.0],[format "%8g" 1.0]"
                        GiD_WriteCalculationFile puts -nonewline "\n$\n$-----------------AI----------------------OI------------\n$"
                        
                        set xp {functionVariable[@n="interpolator_func" and @variable="Moment"]}
                        set fvNode [$function selectNodes $xp]
                        set values [$fvNode selectNodes value]
                        
                        #WE FIND ROTATIONAL UNITS FACTOR 
                        set abcissa_units  [$fvNode @units]
                        set abcissa_factor [compute_units_factor $k $abcissa_units]                       
                        
                        foreach v $values {                        
                            set abcissa_value [expr ($abcissa_factor*[lindex [split [$v @v] ,] 0])]
                            set ordinate_value [lindex [split [$v @v] ,] 1]
                            GiD_WriteCalculationFile puts -nonewline "\n[format "%20E" $abcissa_value],[format "%20E" $ordinate_value] "
                        }
                    }
                }
            }
            
            #we also write coordinate system if needed
            
            set xp "..//value\[@n='Axes_system_${i}'\]"
            set xp [subst -nocommands $xp]
            set valueNode [$gNode selectNodes $xp]
            set axes_system [$valueNode @v]
            
            if {$axes_system=="local"} {
                
                #Warning: Here we take CID after NumElemsTot (to avoid problems with shell orientation)
                
                set cid [expr ($NumElemsTot+($stiff_joint_num*2)+($i-2))]
                
                if {$printed_card=="0"} {
                    GiD_WriteCalculationFile puts -nonewline "\n*DEFINE_COORDINATE_NODES\n$\n$-----CID-------N1-------N2-------N3-----FLAG------DIR-------\n$"
                    set printed_card 1
                }
                
                #IN GID COORDINATE SYSTEM DEFINITION STYLE, NODES N2 AND N3 ARE SWAPED (DIRECTION IS SET TO Z)
                
                GiD_WriteCalculationFile puts -nonewline "\n[format "%8d" $cid],[format "%8d" [ expr ($NumNodesTot+1)]],[format "%8d" [ expr ($NumNodesTot+3)]],[format "%8d" [ expr ($NumNodesTot+2)]],[format "%8d" 0],       Z"
                set NumNodesTot [ expr ($NumNodesTot+3)]
                
                dict set joint_stiffness_info $stiff_joint_num ${i}_cid $cid
                
            } elseif {$axes_system=="same"} {
                dict set joint_stiffness_info $stiff_joint_num ${i}_cid 0
            } else {
                #global axes system by default
                dict set joint_stiffness_info $stiff_joint_num ${i}_cid -1
            }                 
            
            
        }
    }
    
    #WRITING STIFFNESS DATA (IF NEEDED)

    dict for {id info} $joint_stiffness_info {

        GiD_WriteCalculationFile puts -nonewline "\n*CONSTRAINED_JOINT_STIFFNESS_GENERALIZED\n$\n$----JSID-----PIDA-----PIDB-----CIDA-----CIDB------JID------\n$" 
        GiD_WriteCalculationFile puts -nonewline "\n[format "%8d" $id],"        
        
        dict with info {
            GiD_WriteCalculationFile puts -nonewline "[format "%8d" $1_id],[format "%8d" $2_id]"

            if {$1_cid=="-1"} {
                GiD_WriteCalculationFile puts -nonewline ",        "
            } else {
                GiD_WriteCalculationFile puts -nonewline ",[format "%8d" $1_cid]"
            }
            if {$2_cid=="-1"} {
                GiD_WriteCalculationFile puts -nonewline ",        "
            } else {
                GiD_WriteCalculationFile puts -nonewline ",[format "%8d" $2_cid]"
            }

            GiD_WriteCalculationFile puts -nonewline ",[format "%8d" 0]"

            GiD_WriteCalculationFile puts -nonewline "\n$--LCIDPH----LCIDT---LCIDPS--DLCIDPH---DLCIDT--DLCIDPS----"
            GiD_WriteCalculationFile puts -nonewline "\n[format "%8d" $LCIDPH],[format "%8d" $LCIDT],[format "%8d" $LCIDPS],[format "%8d" $DLCIDPH],[format "%8d" $DLCIDT],[format "%8d" $DLCIDPS]"
            GiD_WriteCalculationFile puts -nonewline "\n$----ESPH-----FMPH------EST------FMT-----ESPS-----FMPS------"
            GiD_WriteCalculationFile puts -nonewline "\n[format "%8g" $ESPH],[format "%8g" $FMPH],[format "%8g" $EST],[format "%8g" $FMT],[format "%8g" $ESPS],[format "%8g" $FMPS]"
            GiD_WriteCalculationFile puts -nonewline "\n$---NSAPH----PSAPH-----NSAT-----PSAT----NSAPS----PSAPS------"
            GiD_WriteCalculationFile puts -nonewline "\n[format "%8g" $NSAPH],[format "%8g" $PSAPH],[format "%8g" $NSAT],[format "%8g" $PSAT],[format "%8g" $NSAPS],[format "%8g" $PSAPS]"           
        }
    } 

    #################WRITING EXTRA NODES INFORMATION (now hidden)###########################################################

#     set extra_nodes_info ""
#     
#     foreach i [list 1 2] {
#         
#         set xp {container[@n="Constraints"]/condition[@n="Extra_nodes"]/groupList}
#         append xp {/group[$i]}
#         set xp [subst -nocommands $xp]
#         
#         set extra_nodes_num 0
#         
#         foreach gNode [$root selectNodes $xp] {
#             
#             incr extra_nodes_num
#             set set_name [$gNode @n]  
#             
#             switch $i {
#                 
#                 1 {
#                     #CHOOSING AND WRITING PART ID
#                     set set_id [dict get $part_info $set_name PID]
#                 }
#                 
#                 2 {
#                     #WE WILL WRITE IT AS NODE LIST
#                     set card 4 
#                     
#                     if {[dict exists $set_info $set_name]} {
#                         
#                         #WE VERIFY IF THE GROUP EXISTS AND IF IT'S WRITTEN IN THE SAME WAY
#                         foreach id [dict keys $set_info] {
#                             if {$id==$set_name} {
#                                 set set_id [dict get $set_info $id ID]
#                                 set ancient_card [dict get $set_info $id CARD]
#                             }
#                         } 
#                     }
#                     
#                     #IF IT ISN'T ALREADY WRITTEN (OR NOT IN THE SAME WAY) WE MUST DO IT
#                     
#                     if {![dict exists $set_info $set_name] || $card!=$ancient_card} {
#                         
#                         incr set_num
#                         set set_id $set_num
#                         dict set set_info $set_name ID $set_num
#                         
#                         GiD_WriteCalculationFile puts -nonewline "\n*SET_NODE_COLUMN\n$\n$-----SID------DA1------DA2------DA3------DA4-----\n$"
#                         GiD_WriteCalculationFile puts -nonewline "\n[format "%8d" $set_num],\n$\n$-------N1,N2,N3...----------\n$"  
#                         
#                         set groupsContact ""
#                         dict set groupsContact [$gNode @n] $set_num    
#                         
#                         set f "\n%8d,"
#                         
#                         set formats ""
#                         
#                         dict for "n v" $groupsContact {
#                             #I CAN'T DELETE THE EXTRA SPACE
#                             dict set formats $n "$f"
#                         }
#                         
#                         set Extra_nodes [GiD_WriteCalculationFile nodes -unique $formats]
#                         #THERE SHOULD BE PROBLEMS SHARING CONTACT GROUPS AND EXTRA NODES GROUPS, BECAUSE HERE THERE IS NO "TYPE" INFORMATION
#                         dict set set_info $set_name CARD 4
#                         
#                     }   
#                     
#                 } 
#             }
#             
#             dict set extra_nodes_info $extra_nodes_num ${i}_id $set_id
#         }
#     }
#     
#     
#     #################WRITING EXTRA NODES################################
#     
#     dict for {id info} $extra_nodes_info {
#         
#         GiD_WriteCalculationFile puts -nonewline "\n*CONSTRAINED_EXTRA_NODES_SET\n$\n$-----PID-----NSID-----\n$"
#         
#         dict with info {
#             GiD_WriteCalculationFile puts -nonewline "\n[format "%8d" $1_id],[format "%8d" $2_id]"
#         }
#     } 


######################### WRITING RIGID CONNECTIONS#############################

    
    set connections_rigid_info ""

    foreach i [list 1 2] {
        
        set xp {container[@n="Constraints"]/condition[@n="Connections_rigid"]/groupList}
        append xp {/group[$i]}
        set xp [subst -nocommands $xp]
        
        set connections_rigid_num 0
        
        foreach gNode [$root selectNodes $xp] {               
            
            incr connections_rigid_num 
            
            #WE OBTAIN PART ID
            
            set part_name [$gNode @n]
            set part_id [dict get $part_info $part_name PID]
            dict set connections_rigid_info $connections_rigid_num ${i}_id $part_id          
            
        }
    }


    dict for {id info} $connections_rigid_info {
        if {$id=="1"} {
            GiD_WriteCalculationFile puts -nonewline "\n*CONSTRAINED_RIGID_BODIES\n$\n$----PIDM-----PIDS------\n$" 
        }
        dict with info {
            GiD_WriteCalculationFile puts -nonewline "\n[format "%8d" $1_id],[format "%8d" $2_id]"          
        }
    } 

######################## WRITING SEATBELT RETRACTORS AND SENSORS ################################


    set seatbelt_retractors_num 0
    set seatbelt_sensors_num 0

    set xp {container[@n="Properties"]/container[@n="Seatbelts"]/condition[@n="Retractor"]/group}

    #CONTACT CARD GENERATION
    
    foreach gNode [$root selectNodes $xp] {
        
        GiD_WriteCalculationFile puts -nonewline "\n*ELEMENT_SEATBELT_RETRACTOR"
        
        incr seatbelt_retractors_num
        incr NumNodesTot

        GiD_WriteCalculationFile puts -nonewline "\n$---SBRID---SBRNID----SBID------SID1------SID2------SID3------SID4---------"
        GiD_WriteCalculationFile puts -nonewline "\n[format "%8d" $seatbelt_retractors_num],[format "%8d" $NumNodesTot],"

        #We write selected seatbelt element
        set groupsRetractor ""
        dict set groupsRetractor [$gNode @n] $seatbelt_retractors_num
        set isquadratic [lindex [GiD_Info Project] 5]

        #Elements could be 1D or 2D (not already implemented in seatbelt_element writing)
        #  foreach elemtype [list Linear Triangle Quadrilateral] {            
            
            
            # switch $elemtype {
                #Linear {
                    #  switch $isquadratic {
                        #  0 { set f "%8d %.0s %.0s" }
                        # default { set f "%8d %.0s %.0s %.0s"}
                        #  }
                    #   }  
                #  Triangle {
                    #  switch $isquadratic {
                        #  0 { set f "%8d %.0s %.0s %.0s" }
                        #  default { set f "%8d %.0s %.0s %.0s %.0s %.0s %.0s"  }
                        #   }
                    #  }
                #  Quadrilateral {
                    # switch $isquadratic {
                        #  0 { set f "%8d %.0s %.0s %.0s %.0s"  }
                        #  1 { set f "%8d %.0s %.0s %.0s %.0s %.0s %.0s %.0s %.0s"  }
                        #  2 { set f "%8d %.0s %.0s %.0s %.0s %.0s %.0s %.0s %.0s %.0s" }
                        #   }
                    #   }
                # }
            
            #}

        set elemtype "Linear"
        
        switch $isquadratic {
            0 { set f "%8d%.0s%.0s" }
            default { set f "%8d%.0s%.0s%.0s"}
        }        
        
        #IT SHOULD BE VARIABLE
        set formats ""
        
        dict for "n v" $groupsRetractor {
            dict set formats $n "$f"            
        }        
        
        #only one element will be present in the selection
        if { [GiD_WriteCalculationFile has_elements -elemtype $elemtype $formats] } {  
            set Retractorelements [GiD_WriteCalculationFile connectivities -elemtype "$elemtype" $formats] 
            if {$Retractorelements=="0"} {
                error [= "No element selected in seatbelt retractor definition"]
            }
            if {$Retractorelements>"1"} {
                error [= "You must select only one seatbelt element for each retractor"]
            }
        }
        
        #Now we write SID for seatbelt element sensors

        set original_sensors_num $seatbelt_sensors_num

        set xp ".//value\[@n='Sensor_number']"
        set valueNode [$gNode selectNodes $xp]            
        set sensor_number [$valueNode @v]  

        set k 0

        while {$k<4} {
            
            if {$sensor_number>$k} {
                incr seatbelt_sensors_num
                GiD_WriteCalculationFile puts -nonewline ",[format "%8d" $seatbelt_sensors_num]"
            } else {
                GiD_WriteCalculationFile puts -nonewline ",[format "%8d" 0]"                
            }           
            
            incr k
        }      
        
        GiD_WriteCalculationFile puts -nonewline "\n$----TDEL-----PULL----LLCID----ULCID-----LFED---------"
        GiD_WriteCalculationFile puts -nonewline "\n[format "%8g" 0],[format "%8g" 0]"

        #We write loading curve ID   
        
        set xp ".//value\[@n='Factor_load'\]"
        set valueNode [$gNode selectNodes $xp]
        
        set factor_load [$gNode selectNodes {string(.//value[@n="Factor_load"]/@v)}]
        set function_load [$gNode selectNodes {.//value[@n="Factor_load"]/function}]                
        
        if { [string trim $factor_load] eq "" } { set factor_load 1.0 }
        set function_load_name ""             
        set curve_info ""
        
        if { $function_load ne "" } {
            incr curve_num
            set lcid_load $curve_num
            
            GiD_WriteCalculationFile puts -nonewline ",[format %8d $curve_num]" 
            
            #We find values list

            set factor_load 1.0
            foreach fNode [$function_load selectNodes {functionVariable}] {
                lappend function_load_name [$fNode @n] [$fNode @variable]
                dict set curve_info [$gNode @n] $curve_num
            }            
             
            set xp {functionVariable[@n="interpolator_func" and @variable="Material"]}
            set fvNode [$function_load selectNodes $xp]
            set values_load [$fvNode selectNodes value]
            
            #First we find force units factor
            
            set ordinate_units_load [$valueNode @units]
            set xp [format_xpath {units/unit_magnitude[@n="F"]/unit[@n=%s]} $ordinate_units_load]
            set ordinate_factor_load [$root getAttributeP $xp factor]

            #Then we find distance units factor
            
            set abcissa_units_load  [$fvNode @units]
            set xp [format_xpath {units/unit_magnitude[@n="L"]/unit[@n=%s]} $abcissa_units_load]
            set abcissa_factor_load [$root getAttributeP $xp factor]            
     
            
        } else {
            # If not function defined, Load curve is set to 0
            GiD_WriteCalculationFile puts -nonewline ",[format "%8d" 0]"               
        } 
        
        #We write unloading curve ID   

        set xp ".//value\[@n='Factor_unload'\]"
        set valueNode [$gNode selectNodes $xp]
        
        set factor_unload [$gNode selectNodes {string(.//value[@n="Factor_unload"]/@v)}]
        set function_unload [$gNode selectNodes {.//value[@n="Factor_unload"]/function}]                
        
        if { [string trim $factor_unload] eq "" } { set factor_unload 1.0 }
        set function_unload_name ""             
        set curve_info ""
        
        if { $function_unload ne "" } {
            incr curve_num
            set lcid_unload $curve_num
            
            GiD_WriteCalculationFile puts -nonewline ",[format %8d $curve_num]" 
            
            #We find values list

            set factor_unload 1.0
            foreach fNode [$function_unload selectNodes {functionVariable}] {
                lappend function_unload_name [$fNode @n] [$fNode @variable]
                dict set curve_info [$gNode @n] $curve_num
            }            

            set xp {functionVariable[@n="interpolator_func" and @variable="Material"]}
            set fvNode [$function_load selectNodes $xp]
            set values_unload [$fvNode selectNodes value]
            
            #First we find force units factor
            
            set ordinate_units_unload [$valueNode @units]
            set xp [format_xpath {units/unit_magnitude[@n="F"]/unit[@n=%s]} $ordinate_units_unload]
            set ordinate_factor_unload [$root getAttributeP $xp factor]

            #Then we find distance units factor
            
            set abcissa_units_unload  [$fvNode @units]
            set xp [format_xpath {units/unit_magnitude[@n="L"]/unit[@n=%s]} $abcissa_units_unload]
            set abcissa_factor_unload [$root getAttributeP $xp factor] 
            
        } else {
            # If not function defined, Load curve is set to 0
            GiD_WriteCalculationFile puts -nonewline ",[format "%8d" 0]"               
        } 
        
        #Finally we write Fed length
        
        set xp ".//value\[@n='Fed_length']"
        set valueNode [$gNode selectNodes $xp]
        GiD_WriteCalculationFile puts -nonewline ",[format "%8g" [gid_groups_conds::convert_value_to_default $valueNode]]"              
        

        # AFTER ELEMENT WRITING WE WRITE LOADING AND UNLOADING CURVES IF NEEDED

        if { $function_load ne "" } {            
            
            GiD_WriteCalculationFile puts -nonewline "\n*DEFINE_CURVE\n$\n$----LCID-----SIDR------SFA------SFO-----OFFA-----------\n$"
            GiD_WriteCalculationFile puts -nonewline "\n[format "%8d" $lcid_load],[format "%8d" 0],[format "%8g" 1.0],[format "%8g" 1.0]"
            GiD_WriteCalculationFile puts -nonewline "\n$\n$-----------------AI----------------------OI------------\n$"
            
            foreach v $values_load {                        
                set abcissa_value [expr ($abcissa_factor_load*[lindex [split [$v @v] ,] 0])]
                set ordinate_value [expr ($ordinate_factor_load*[lindex [split [$v @v] ,] 1])]
                GiD_WriteCalculationFile puts -nonewline "\n[format "%20E" $abcissa_value],[format "%20E" $ordinate_value] "
            }   
        }
        
        if { $function_unload ne "" } {
            
            GiD_WriteCalculationFile puts -nonewline "\n*DEFINE_CURVE\n$\n$----LCID-----SIDR------SFA------SFO-----OFFA-----------\n$"
            GiD_WriteCalculationFile puts -nonewline "\n[format "%8d" $lcid_unload],[format "%8d" 0],[format "%8g" 1.0],[format "%8g" 1.0]"
            GiD_WriteCalculationFile puts -nonewline "\n$\n$-----------------AI----------------------OI------------\n$"
            
            foreach v $values_unload {                        
                set abcissa_value [expr ($abcissa_factor_unload*[lindex [split [$v @v] ,] 0])]
                set ordinate_value [expr ($ordinate_factor_unload*[lindex [split [$v @v] ,] 1])]
                GiD_WriteCalculationFile puts -nonewline "\n[format "%20E" $abcissa_value],[format "%20E" $ordinate_value] "
            } 
        }
        
        #FINALLY WE WRITE EACH SEATBELT SENSOR CARD   
        
        set coeff_list_1 [list Activating_acceleration Time_over]
        set scalar_list_1 [list Sensor_activation Degree_freedom]
        
        set coeff_list_2 [list Activating_acceleration_2 Time_over_2]
        set scalar_list_2 [list Sensor_activation_2 Degree_freedom_2]
        
        set coeff_list_3 [list Activating_acceleration_3 Time_over_3]
        set scalar_list_3 [list Sensor_activation_3 Degree_freedom_3]
        
        set coeff_list_4 [list Activating_acceleration_4 Time_over_4]
        set scalar_list_4 [list Sensor_activation_4 Degree_freedom_4]                            
                       
        set k 1
        
        while {$k<=$sensor_number} {

            #We take originalsensorssnum because sensorsnum is already increased
            incr original_sensors_num            
            incr NumNodesTot

            set coeff_list "coeff_list_$k"
            set scalar_list "scalar_list_$k"

            foreach i [subst "$$coeff_list"] n [list ACC ATIME] {            
                set xp ".//value\[@n='$i']"
                set valueNode [$gNode selectNodes $xp]            
                set $n [gid_groups_conds::convert_value_to_default $valueNode]            
            }
            
            foreach i [subst "$$scalar_list"] n [list SBSFL DOF] {            
                set xp ".//value\[@n='$i']"
                set valueNode [$gNode selectNodes $xp]
                set $n [$valueNode @v]            
            }

            #We correct SBSFL value
            set SBSFL [expr ($SBSFL-1)]
            
            GiD_WriteCalculationFile puts -nonewline "\n*ELEMENT_SEATBELT_SENSOR"
            GiD_WriteCalculationFile puts -nonewline "\n$---SBSID---SBSTYP----SBSFL---------"
            GiD_WriteCalculationFile puts -nonewline "\n[format "%8d" $original_sensors_num],[format "%8d" 1],[format "%8d" $SBSFL]"
            GiD_WriteCalculationFile puts -nonewline "\n$-----NID------DOF------ACC----ATIME---------"        
            GiD_WriteCalculationFile puts -nonewline "\n[format "%8d" $NumNodesTot],[format "%8d" $DOF],[format "%8g" $ACC],[format "%8g" $ATIME]" 

            incr k

        }   
    }
    
    ######################## WRITING SLIP RING CARDS ###################################
    
    set xp {container[@n="Properties"]/container[@n="Seatbelts"]/condition[@n="Slipring"]/groupList/group[1]}
    
    ##### First we read first element identity ########
    
    set sliprings_num 0
    set slipring_dict ""
    
    foreach gNode [$root selectNodes "$xp"] {
        
        incr sliprings_num
        
        #We save selected seatbelt element
        
        set groupsSlipRing ""
        dict set groupsSlipRing [$gNode @n] $sliprings_num
        set isquadratic [lindex [GiD_Info Project] 5]

        #Elements could be 1D or 2D (not already implemented in seatbelt_element writing)
        #  foreach elemtype [list Linear Triangle Quadrilateral] {            
            
            
            # switch $elemtype {
                #Linear {
                    #  switch $isquadratic {
                        #  0 { set f "%8d %.0s %.0s" }
                        # default { set f "%8d %.0s %.0s %.0s"}
                        #  }
                    #   }  
                #  Triangle {
                    #  switch $isquadratic {
                        #  0 { set f "%8d %.0s %.0s %.0s" }
                        #  default { set f "%8d %.0s %.0s %.0s %.0s %.0s %.0s"  }
                        #   }
                    #  }
                #  Quadrilateral {
                    # switch $isquadratic {
                        #  0 { set f "%8d %.0s %.0s %.0s %.0s"  }
                        #  1 { set f "%8d %.0s %.0s %.0s %.0s %.0s %.0s %.0s %.0s"  }
                        #  2 { set f "%8d %.0s %.0s %.0s %.0s %.0s %.0s %.0s %.0s %.0s" }
                        #   }
                    #   }
                # }
            
            #}

        set elemtype "Linear"
        
        switch $isquadratic {
            0 { set f "%8d%.0s%.0s" }
            default { set f "%8d%.0s%.0s%.0s"}
        }        
        
        #IT SHOULD BE VARIABLE
        set formats ""
        
        dict for "n v" $groupsSlipRing {
            dict set formats $n "$f"            
        }        
        
        #only one element will be present in the selection
        if { [GiD_WriteCalculationFile has_elements -elemtype $elemtype $formats] } {  
            set SlipRingrelements [GiD_WriteCalculationFile connectivities -elemtype "$elemtype" -count $formats]             
            if {$SlipRingrelements=="0"} {
                error [= "No element selected in one field of seatbelt slip ring definition"]
            }
            if {$SlipRingrelements>"1"} {
                error [= "You must select only two seatbelt elements for each slip ring"]
            }
            dict set slipring_dict $sliprings_num [GiD_WriteCalculationFile connectivities -elemtype "$elemtype" -return $formats] 
        }  
    }
    
    set xp {container[@n="Properties"]/container[@n="Seatbelts"]/condition[@n="Slipring"]/groupList/group[2]}
    
    set sliprings_num 0
    
    foreach gNode [$root selectNodes "$xp"] {
        
        incr sliprings_num
        
        GiD_WriteCalculationFile puts -nonewline "\n*ELEMENT_SEATBELT_SLIPRING"
        GiD_WriteCalculationFile puts -nonewline "\n$--SBSRID----SBID1----SBID2-------FC---SBRNID----LTIME------FCS-------" 
        
        #We print first element data (which is already saved in the dictionary)
        
        GiD_WriteCalculationFile puts -nonewline "\n[format "%8d" $sliprings_num],[dict get $slipring_dict $sliprings_num],"
        
        #Now we print second element ID
        
        set groupsSlipRing ""
        dict set groupsSlipRing [$gNode @n] $sliprings_num
        set isquadratic [lindex [GiD_Info Project] 5]

        #Elements could be 1D or 2D (not already implemented in seatbelt_element writing)
        #  foreach elemtype [list Linear Triangle Quadrilateral] {            
            
            
            # switch $elemtype {
                #Linear {
                    #  switch $isquadratic {
                        #  0 { set f "%8d %.0s %.0s" }
                        # default { set f "%8d %.0s %.0s %.0s"}
                        #  }
                    #   }  
                #  Triangle {
                    #  switch $isquadratic {
                        #  0 { set f "%8d %.0s %.0s %.0s" }
                        #  default { set f "%8d %.0s %.0s %.0s %.0s %.0s %.0s"  }
                        #   }
                    #  }
                #  Quadrilateral {
                    # switch $isquadratic {
                        #  0 { set f "%8d %.0s %.0s %.0s %.0s"  }
                        #  1 { set f "%8d %.0s %.0s %.0s %.0s %.0s %.0s %.0s %.0s"  }
                        #  2 { set f "%8d %.0s %.0s %.0s %.0s %.0s %.0s %.0s %.0s %.0s" }
                        #   }
                    #   }
                # }
            
            #}

        set elemtype "Linear"
        
        switch $isquadratic {
            0 { set f "%8d%.0s%.0s" }
            default { set f "%8d%.0s%.0s%.0s"}
        }        
        
        #IT SHOULD BE VARIABLE
        set formats ""
        
        dict for "n v" $groupsSlipRing {
            dict set formats $n "$f"            
        }        
        
        #only one element will be present in the selection
        if { [GiD_WriteCalculationFile has_elements -elemtype $elemtype $formats] } {  
            set SlipRingrelements [GiD_WriteCalculationFile connectivities -elemtype "$elemtype" $formats]             
            if {$SlipRingrelements=="0"} {
                error [= "No element selected in one field of seatbelt slip ring definition"]
            }
            if {$SlipRingrelements>"1"} {
                error [= "You must select only two seatbelt elements for each slip ring"]
            }
        }  
        
        #  WE READ AND WRITE ADDITIONAL DATA
        
        foreach i [list Coulomb_coefficient Lockup_time node_mass] j [list FC LTIME MASS] {
            set xp "..//value\[@n='$i']"
            set xp [subst -nocommands $xp]
            set valueNode [$gNode selectNodes $xp]
            set $j [gid_groups_conds::convert_value_to_default $valueNode]
        }
        
        incr NumNodesTot        
        GiD_WriteCalculationFile puts -nonewline ",[format "%8g" $FC],[format "%8d" $NumNodesTot],[format "%8g" $LTIME]"
        
        #####Now we specify slip ring node mass with the help of *ELEMENT_MASS CARD (we write each node as an additional element)
        
        if {$MASS>"0"} {            
            GiD_WriteCalculationFile puts -nonewline "\n*ELEMENT_MASS"            
            incr NumElemsTot            
            GiD_WriteCalculationFile puts -nonewline "\n[format "%8d" $NumElemsTot],[format "%8d" $NumNodesTot],[format "%8g" $MASS]"
        } 
    } 

}


################################################################################
#    Dynamic conditions
################################################################################

proc b_write_calc_file::write_dynamic_conditions { root } {

    set Analysis_Type [get_value Analysis_Type]
    if { [lsearch "Linear_Dynamic Non-Linear_Dynamic" $Analysis_Type] == -1 } {
        return
    }
    set formats ""
    set xp {container[@n="Dynamic_conditions"]/condition[@n="Masses"]/group}
    foreach gNode [$root selectNodes $xp] {
        set f "%d"
        switch [$gNode @v] {
            point {
                set vs [list Mass_x Mass_y Mass_z Mom_iner_x Mom_iner_y \
                        Mom_iner_z]
            }
            line {
                set vs [list Trasl_Mass Mom_iner_x Mom_iner_y \
                        Mom_iner_z]
            }
            surface {
                set vs [list Surface_mass]
            }
        }
        foreach i $vs {
            set xp ".//value\[@n='$i'\]"
            set valueNode [$gNode selectNodes $xp]
            set v [gid_groups_conds::convert_value_to_default $valueNode]
            append f " $v"
        }
        append f " Units=N-m-kg\n"
        dict set formats [$gNode @v] [$gNode @n] $f
    }
    foreach i [dict keys $formats] {
        switch [$gNode @v] {
            point { set rList nodal_point_mass }
            line {
                set rList ""
                if { [GiD_WriteCalculationFile has_elements -elements_faces faces \
                    [dict get $formats $i]] } {
                    lappend rList face_shell_mass
                }
                if { [GiD_WriteCalculationFile has_elements -elements_faces elements \
                    [dict get $formats $i]] } {
                    lappend rList beam_mass
                }
            }
            surface { set rList surface_shell_mass }
        }
        foreach r $rList {
            if { $r ne "nodal_point_mass" } {
                GiD_WriteCalculationFile puts "element_mass"
            }
            GiD_WriteCalculationFile puts $r

            switch $r {
                nodal_point_mass {
                    GiD_WriteCalculationFile nodes [dict get $formats $i]
                }
                face_shell_mass {
                    set formats_face ""
                    dict for "n v" [dict get $formats $i] {
                        dict set formats_face $n "%d $v"
                    }
                    GiD_WriteCalculationFile elements -elements_faces faces \
                        $formats_face
                }
                default {
                    GiD_WriteCalculationFile elements -elements_faces elements \
                        [dict get $formats $i]
                }
            }
            GiD_WriteCalculationFile puts "end $r"
            if { $r ne "nodal_point_mass" } {
                GiD_WriteCalculationFile puts "end element_mass"
            }
        }
    }


 #HIDDEN IN THIS LSDYNA VERSION
#     switch $Analysis_Type {
#         "Linear_Dynamic" { set v [get_value Initial_Conditions] }
#         "Non-Linear_Dynamic" { set v [get_value Initial_Conditions_NL] }
#         default { set v None }
#     }

    #if { $v ne "User_Defined" } { return }

##################WRITING INITIAL VELOCITY CARD##############################
    

    #WRITING INITIAL VELOCITY (ALL)
    
    set print_all 0
    
    foreach i [list Vel_x Vel_y Vel_z W_x W_y W_z] {
        
        set xp {container[@n="Initial_conditions"]/blockdata["Initial_conditions_all"]/value[@n="$i"]}
        set xp [subst -nocommands $xp]
        set valueNode [$root selectNodes $xp]
        set initial_value [$valueNode @v]       
        
        if {$initial_value!=0} {
            set print_all 1
        }
    }
    
    if {$print_all} {
        GiD_WriteCalculationFile puts -nonewline "\n*INITIAL_VELOCITY\n$\n$----NSID---NSIDEX----BOXID-----\n$\n[format "%8d" 0],"
        GiD_WriteCalculationFile puts -nonewline "\n$\n$------VX-------VY-------VZ------VRX------VRY------VRZ---------\n$\n"    
        
        foreach i [list Vel_x Vel_y Vel_z W_x W_y W_z] {
            
            set xp {container[@n="Initial_conditions"]/blockdata["Initial_conditions_all"]/value[@n="$i"]}
            set xp [subst -nocommands $xp]
            set valueNode [$root selectNodes $xp]
            set initial_value [$valueNode @v]   
            
            #TO PREVENT ERRORS RELATED TO UNITS AND MAGNITUDES
            if {$initial_value=="0"} { 
                GiD_WriteCalculationFile puts -nonewline "[format "%8g" 0],"
            } else {
                GiD_WriteCalculationFile puts -nonewline "[format "%8g" [gid_groups_conds::convert_value_to_default $valueNode]]," 
            }                
        }        
    }
     
    #WRITING INITIAL VELOCITY GROUPS

    set xp {container[@n="Initial_conditions"]/condition["Initial_conditions_group"]/group}  
    set printed_card 0
    
    foreach gNode [$root selectNodes $xp] {
        
        set formats ""
        set f "\n%8d"
        
        foreach i [list Vel_x Vel_y Vel_z W_x W_y W_z] {
            
            set xp ".//value\[@n='${i}'\]"
            set valueNode [$gNode selectNodes $xp]
            set initial_value [$valueNode @v]
            
            #TO PREVENT ERRORS RELATED TO UNITS AND MAGNITUDES
            if {$initial_value=="0"} { set initial_value_units 0} else {
                set initial_value_units [gid_groups_conds::convert_value_to_default $valueNode] }          
            append f ",[format "%8g" $initial_value_units]"
        }    
        
        dict set formats [$gNode @n] $f
        
        if { [dict size $formats] } {
            if {$printed_card=="0"} {
                GiD_WriteCalculationFile puts "\n*INITIAL_VELOCITY_NODE"
                GiD_WriteCalculationFile puts -nonewline "$\n$-----NID-------VX-------VY-------VZ------VRX------VRY------VRZ---------\n$"
                set printed_card 1
            }
            GiD_WriteCalculationFile nodes -unique $formats
        }
    }
    
    
}

################################################################################
#    Loads
################################################################################

proc b_write_calc_file::write_loads { root } {
    
    variable tablesList
    global curve_num
    global set_num
    global part_info
    
    set problem_type [get_value Problem_type]



###########LOAD_BODY_PARTS CARD##########################################

    set xp {container[@n="Loads"]/condition[@n="No_self_weight"]/group}

    foreach gNode [$root selectNodes $xp] { 

        set set_num [expr ($set_num+1)]

        GiD_WriteCalculationFile puts -nonewline "\n*LOAD_BODY_PARTS\n$----PSID------\n[format "%8d" $set_num]"        
        GiD_WriteCalculationFile puts -nonewline "\n*SET_PART_COLUMN\n$-----PID------\n[format "%8d" $set_num]"

        set part_name [$gNode @n]
        GiD_WriteCalculationFile puts -nonewline "\n[format "%8d" [dict get $part_info $part_name PID]]"
    }

  

#########LOAD_NODE_POINT CARD#############################################
      
        #AT THE MOMENT THIS DIFFERENCE DOESN'T EXIST
#         switch $problem_type {
#             Solids { set vs [list X Y Z] }
#             default { set vs [list X Y Z Mx My Mz] }
#         } 

    
    set vs [list X Y Z Mx My Mz]
    set direction 1
    set card_printed 0
    
    foreach i $vs {
        
        set formats ""
        set printcard 0
        
        set xp {container[@n="Loads"]/condition[@n="Punctual_Load"]/group}    
        
        foreach gNode [$root selectNodes $xp] { 
            
            set xp ".//value\[@n='${i}_Force'\]"
            set valueNode [$gNode selectNodes $xp]
            set force [$valueNode @v]
            
            if {$force==0} {continue} else { 
                set printcard 1 }
            
            set f "\n%8d,[format "%8d" $direction],"                      
            
            set factor [$gNode selectNodes {string(.//value[@n="Factor"]/@v)}]
            set function [$gNode selectNodes {.//value[@n="Factor"]/function}]
            
            set lcid 1
            
            if { [string trim $factor] eq "" } { set factor 1.0 }
            set function_name "" 
            if { $function ne "" } {
                set factor 1.0
                foreach fNode [$function selectNodes {functionVariable}] {
                    lappend function_name [$fNode @n] [$fNode @variable]
                    incr curve_num     
                    set lcid $curve_num
                }
            }
            
            if { ![string is double -strict $factor] } {
                error [= "Error in Puctual Load, group '%s'. Factor is not correct" \
                        [$gNode @n]]
            }
            
            
            switch -regexp -- [string trim [join $function_name " "]] {
                "^$" { }
                
                {^sinusoidal_load t$} {
                    
                    set function_info ""
                    
                    set fvNode [$function selectNodes {functionVariable[@n="sinusoidal_load"]}]
                    set xp {string(value[@n="amplitude"]/@v)}
                    set A [$fvNode selectNodes $xp]
                    
                    #ENDING AND INITIAL TIME NOT IMPLEMENTED
                    foreach j [list circular_frequency phase_angle ] \
                        k [list freq phi ] {
                        
                        set xp [format_xpath {value[@n=%s]} $j]
                        dict set function_info $k [gid_groups_conds::convert_value_to_default [$fvNode selectNodes $xp]]
                    }
                    
                    GiD_WriteCalculationFile puts -nonewline "\n*DEFINE_CURVE_FUNCTION\n$\n$----LCID-----SIDR------SFA------SFO-----OFFA-----------\n$"
                    #                             GiD_WriteCalculationFile puts -nonewline "\n[format "%8d" $curve_num],[format "%8d" 0],[format "%8g" 1.0],[format "%8g" 1.0],[format "%8g" [dict get $function_info ti]]\n$\n$-FUNCTION-------\n$"
                    GiD_WriteCalculationFile puts -nonewline "\n[format "%8d" $curve_num],\n$\n$-FUNCTION-------\n$"
                    GiD_WriteCalculationFile puts -nonewline "\n$A*SIN([dict get $function_info freq]*TIME+[dict get $function_info phi])"   
                    set card_printed 0
                }  
                
                {^interpolator_func t$} {
                    
                    GiD_WriteCalculationFile puts -nonewline "\n*DEFINE_CURVE\n$\n$----LCID-----SIDR------SFA------SFO-----OFFA-----------\n$"
                    GiD_WriteCalculationFile puts -nonewline "\n[format "%8d" $curve_num],[format "%8d" 0],[format "%8g" 1.0],[format "%8g" 1.0]"
                    GiD_WriteCalculationFile puts -nonewline "\n$\n$-----------------AI----------------------OI------------\n$"
                    
                    set xp {functionVariable[@n="interpolator_func" and @variable="t"]}
                    set fvNode [$function selectNodes $xp]
                    set values [$fvNode selectNodes value]
                    
                    #WE FIND TIME UNITS FACTOR
                    set time_units  [$fvNode @units]
                    set time_factor [compute_units_factor time $time_units]             
                    
                    foreach v $values {
                        set ordinate_value [lindex [split [$v @v] ,] 1]
                        set abcissa_value [ expr ($time_factor*[lindex [split [$v @v] ,] 0])]
                        GiD_WriteCalculationFile puts -nonewline "\n[format "%20E" $abcissa_value],[format "%20E" $ordinate_value] "
                    }   

                    set card_printed 0
                }
                default {
                    error [= "Function load not implemented" $function_name]
                }
            }
            
            
            set vList ""
            
            set xp ".//value\[@n='${i}_Force'\]"
            set valueNode [$gNode selectNodes $xp]
            set v [expr {$factor*[gid_groups_conds::convert_value_to_default $valueNode]}]
            set v [format "%8g" $v]
            
            lappend vList "[format "%8d" $lcid],$v,[format "%8d" 0]"
            append f " [join $vList { }]" 
            
            set LA 0                  
            set formats "formats$i"

            #Load type set as standard, loadcase set as 1
            
            dict set $formats [list Punctual_load standard $function_name] 1 \
                $LA [$gNode @n] $f
        }
        
        if {!$printcard} {
            if {$direction=="3"} {
                set direction [expr { $direction+2 }]
            } else {
                incr direction
            }   
            continue
        } 
        
        set data [subst "$$formats"]
        foreach j [dict keys $data] {                                  
            foreach loadcase [dict keys [dict get $data $j]] {
                if {$card_printed=="0"} {
                    GiD_WriteCalculationFile puts -nonewline "\n*LOAD_NODE_POINT"
                    GiD_WriteCalculationFile puts -nonewline "\n$\n$-----NID------DOF-----LCID-------SF------CID------\n$"
                    set card_printed 1
                }
                GiD_WriteCalculationFile nodes [dict get $data $j 1 0]
            }
        }
        
        if {$direction=="3"} {
            set direction [expr { $direction+2 }]
        } else {
            incr direction
        }     
    }
    

##########LOAD_RIGID_BODY CARD###################
        
    set direction 1
    set vs [list X Y Z Mx My Mz]
    
    set card_printed 0
    
    foreach i $vs {
        
        set xp {container[@n="Loads"]/condition[@n="Solid_load"]/group}
        
        foreach gNode [$root selectNodes $xp] { 
            
            set xp ".//value\[@n='${i}_Force'\]"
            set valueNode [$gNode selectNodes $xp]
            set force [$valueNode @v]
            
            if {$force=="0"} {continue} else { 
                set printcard 1 }
            
          
            
            set part_id 0
            
            dict for {id info} $part_info {
                if {[$gNode @n]=="$id"} {  
                    dict with info {
                        set part_id $PID 
                        break
                    }
                }
            }
            
            if { $part_id=="0" } {error [= "Invalid Group in Solid Load Data"]}
            
            set factor [$gNode selectNodes {string(.//value[@n="Factor"]/@v)}]
            set function [$gNode selectNodes {.//value[@n="Factor"]/function}]
            
            set lcid 1
            
            if { [string trim $factor] eq "" } { set factor 1.0 }
            set function_name "" 
            if { $function ne "" } {
                set factor 1.0
                foreach fNode [$function selectNodes {functionVariable}] {
                    lappend function_name [$fNode @n] [$fNode @variable]
                    incr curve_num        
                    set lcid $curve_num
                }
            }
            if { ![string is double -strict $factor] } {
                error [= "Error in solid load, group '%s'. Factor is not correct" \
                        [$gNode @n]]
            }
            
            
            switch -regexp -- [string trim [join $function_name " "]] {
                "^$" { }
                
                {^sinusoidal_load t$} {
                    
                    set function_info ""
                    
                    set fvNode [$function selectNodes {functionVariable[@n="sinusoidal_load"]}]
                    set xp {string(value[@n="amplitude"]/@v)}
                    set A [$fvNode selectNodes $xp]
                    
                    #ENDING AND INITIAL TIME NOT IMPLEMENTED
                    foreach j [list circular_frequency phase_angle ] \
                        k [list freq phi ] {
                        
                        set xp [format_xpath {value[@n=%s]} $j]
                        dict set function_info $k [gid_groups_conds::convert_value_to_default [$fvNode selectNodes $xp]]
                    }
                    
                    GiD_WriteCalculationFile puts -nonewline "\n*DEFINE_CURVE_FUNCTION\n$\n$----LCID-----SIDR------SFA------SFO-----OFFA-----------\n$"
                    #                             GiD_WriteCalculationFile puts -nonewline "\n[format "%8d" $curve_num],[format "%8d" 0],[format "%8g" 1.0],[format "%8g" 1.0],[format "%8g" [dict get $function_info ti]]\n$\n$-FUNCTION-------\n$"
                    GiD_WriteCalculationFile puts -nonewline "\n[format "%8d" $curve_num],\n$\n$-FUNCTION-------\n$"
                    GiD_WriteCalculationFile puts -nonewline "\n$A*SIN([dict get $function_info freq]*TIME+[dict get $function_info phi])"   

                    set card_printed 0
                }  
                
                {^interpolator_func t$} {
                    
                    GiD_WriteCalculationFile puts -nonewline "\n*DEFINE_CURVE\n$\n$----LCID-----SIDR------SFA------SFO-----OFFA-----------\n$"
                    GiD_WriteCalculationFile puts -nonewline "\n[format "%8d" $curve_num],[format "%8d" 0],[format "%8g" 1.0],[format "%8g" 1.0]"
                    GiD_WriteCalculationFile puts -nonewline "\n$\n$-----------------AI----------------------OI------------\n$"
                    
                    set xp {functionVariable[@n="interpolator_func" and @variable="t"]}
                    set fvNode [$function selectNodes $xp]
                    set values [$fvNode selectNodes value]
                    
                    #WE FIND TIME UNITS FACTOR
                    set time_units  [$fvNode @units]
                    set time_factor [compute_units_factor time $time_units]             
                    
                    foreach v $values {
                        set ordinate_value [lindex [split [$v @v] ,] 1]
                        set abcissa_value [ expr ($time_factor*[lindex [split [$v @v] ,] 0])]
                        GiD_WriteCalculationFile puts -nonewline "\n[format "%20E" $abcissa_value],[format "%20E" $ordinate_value] "
                    }    

                    set card_printed 0
                }
                default {
                    error [= "Function load not implemented" $function_name]
                }
            }
            
            set xp ".//value\[@n='${i}_Pressure' or @n='${i}_Force' or @n='$i'\]"
            set valueNode [$gNode selectNodes $xp]
            if { $valueNode eq "" } { continue }
            set v [expr {$factor*[gid_groups_conds::convert_value_to_default $valueNode]}]
            
            if {$card_printed=="0"} {
                GiD_WriteCalculationFile puts "\n*LOAD_RIGID_BODY"
                GiD_WriteCalculationFile puts -nonewline "$\n$-----PID------DOF-----LCID-------SF------CID------\n$"
                set card_printed 1
            }

            GiD_WriteCalculationFile puts -nonewline "\n[format %8d $part_id],[format %8d $direction],[format %8d $lcid],[format %8g $v],[format %8d 0]"               
        }        
        
        if {$direction=="3"} {
            set direction [expr { $direction+2 }]
        } else {
            incr direction
        }      
    }
    

##########LOAD SEGMENT CARD########################################
        
    set groups_num 1
    
    set xp {container[@n="Loads"]/condition[@n="pressure_load"]/group}
    
    foreach gNode [$root selectNodes $xp] {
        
        set xp ".//value\[@n='Arrival_time'\]"
        set valueNode [$gNode selectNodes $xp]
        
        #TO AVOID UNITS PROBLEMS
        if {[$valueNode @v]=="0"} {
            set time 0 } else {
            set time [gid_groups_conds::convert_value_to_default $valueNode]
        }
        
        set factor [$gNode selectNodes {string(.//value[@n="Factor"]/@v)}]
        set function [$gNode selectNodes {.//value[@n="Factor"]/function}]
        
        if { [string trim $factor] eq "" } { set factor 1.0 }
        set function_name "" 
        
        set lcid 1
        
        if { $function ne "" } {
            set factor 1.0
            foreach fNode [$function selectNodes {functionVariable}] {
                lappend function_name [$fNode @n] [$fNode @variable]
                incr curve_num     
                set lcid $curve_num
            }
        }
        if { ![string is double -strict $factor] } {
            error [= "Error in solid load', group '%s'. Factor is not correct" \
                    [$gNode @n]]
        }
        
        
        switch -regexp -- [string trim [join $function_name " "]] {
            "^$" { }
            
            {^sinusoidal_load t$} {
                
                set function_info ""
                
                set fvNode [$function selectNodes {functionVariable[@n="sinusoidal_load"]}]
                set xp {string(value[@n="amplitude"]/@v)}
                set A [$fvNode selectNodes $xp]
                
                #ENDING AND INITIAL TIME NOT IMPLEMENTED
                foreach j [list circular_frequency phase_angle ] \
                    k [list freq phi ] {
                    
                    set xp [format_xpath {value[@n=%s]} $j]
                    dict set function_info $k [gid_groups_conds::convert_value_to_default [$fvNode selectNodes $xp]]
                }
                
                GiD_WriteCalculationFile puts -nonewline "\n*DEFINE_CURVE_FUNCTION\n$\n$----LCID-----SIDR------SFA------SFO-----OFFA-----------\n$"
                #                             GiD_WriteCalculationFile puts -nonewline "\n[format "%8d" $curve_num],[format "%8d" 0],[format "%8g" 1.0],[format "%8g" 1.0],[format "%8g" [dict get $function_info ti]]\n$\n$-FUNCTION-------\n$"
                GiD_WriteCalculationFile puts -nonewline "\n[format "%8d" $curve_num],\n$\n$-FUNCTION-------\n$"
                GiD_WriteCalculationFile puts -nonewline "\n$A*SIN([dict get $function_info freq]*TIME+[dict get $function_info phi])"                   
            }  
            
            {^interpolator_func t$} {
                
                GiD_WriteCalculationFile puts -nonewline "\n*DEFINE_CURVE\n$\n$----LCID-----SIDR------SFA------SFO-----OFFA-----------\n$"
                GiD_WriteCalculationFile puts -nonewline "\n[format "%8d" $curve_num],[format "%8d" 0],[format "%8g" 1.0],[format "%8g" 1.0]"
                GiD_WriteCalculationFile puts -nonewline "\n$\n$-----------------AI----------------------OI------------\n$"
                
                set xp {functionVariable[@n="interpolator_func" and @variable="t"]}
                set fvNode [$function selectNodes $xp]
                set values [$fvNode selectNodes value]
                
                #WE FIND TIME UNITS FACTOR
                set time_units  [$fvNode @units]
                set time_factor [compute_units_factor time $time_units]             
                
                foreach v $values {
                    set ordinate_value [lindex [split [$v @v] ,] 1]
                    set abcissa_value [ expr ($time_factor*[lindex [split [$v @v] ,] 0])]
                    GiD_WriteCalculationFile puts -nonewline "\n[format "%20E" $abcissa_value],[format "%20E" $ordinate_value] "
                }             
            }
            default {
                error [= "Function load not implemented" $function_name]
            }
        }
        
        set xp ".//value\[@n='Pressure']"
        set valueNode [$gNode selectNodes $xp]
        if { $valueNode eq "" } { continue }
        
        #TO AVOID UNITS PROBLEMS
        if {[$valueNode @v]=="0"} {
            set pressure 0 } else {
            set pressure [expr {$factor*[gid_groups_conds::convert_value_to_default $valueNode]}]
        }
        
        set groupsPressure ""
        dict set groupsPressure [$gNode @n] $groups_num    
        
        set isquadratic [lindex [GiD_Info Project] 5]
        
        foreach elemtype [list Linear Triangle Quadrilateral] {
            
            switch $elemtype {
                
                Linear {
                    switch $isquadratic {
                        0 { set nnode 2 }
                        default {
                            set nnode 3
                        }
                    }
                }           
                Triangle {
                    switch $isquadratic {
                        0 { set nnode 3 }
                        default { set nnode 6 }
                    }
                }
                Quadrilateral {
                    switch $isquadratic {
                        0 { set nnode 4 }
                        1 { set nnode 8 }
                        2 { error [= "9 noded elements not supported in Pressure Load condition"]  }
                    }
                }
            }
            
            #IT SHOULD BE VARIABLE
            set formats ""
            set formatsLA ""
            
            dict for "n v" $groupsPressure {
                
                set card_needed 1
                
                if {$nnode=="6" || $nnode=="8" } {
                    set fc1 "\n*LOAD_SEGMENT\n$\n$----LCID-------SF-------AT-------N1,N2,N3...------\n$\n[format "%8d" 1],[format "%8g" $pressure],[format "%8g" $time],"
                    set card_needed 0    
                } else {
                    set fc1 "\n[format "%8d" $lcid],[format "%8g" $pressure],[format "%8g" $time],"
                }
                
                if {$nnode=="2"} {
                    set fc2 {%1$.0s%2$8d,%3$8d,%3$8d,%3$8d}
                }
                if {$nnode=="3"} {   
                    if {$isquadratic} {
                        set fc2 {%1$.0s%2$8d,%3$8d,%3$8d,%3$8d,%4$8d}
                    } else { 
                        #I'M NO SURE IF IT FOLLOWS THE MANUAL
                        set fc2 {%1$.0s%2$8d,%3$8d,%4$8d,%4$8d}
                    }
                } 
                if {$nnode=="4"} {
                    set fc2 {%.0s%8d,%8d,%8d,%8d}
                }
                if {$nnode=="6"} {
                    set fc2 {%1$.0s%2$8d,%3$8d,%4$8d,%4$8d\n$\n$------N6,N7---------\n$\n %5$8d,%6$8d,%7$8d}
                    
                }
                if {$nnode=="8"} {
                    set fc2 {%.0s%8d,%8d,%8d,%8d,%8d\n$\n$------N6,N7,N8---------\n$\n%8d,%8d,%8d}
                }
                
                append fc1 $fc2 
                set fc1 [subst -novariables $fc1] 
                dict set formats $n "$fc1"
                
                #IT COULD BE VARIABLE
                dict set formatsLA $n "$fc1"
                
            }
            
            if {[GiD_WriteCalculationFile has_elements -elemtype $elemtype $formats]=="1" && $card_needed=="1"} {
                GiD_WriteCalculationFile puts -nonewline "\n*LOAD_SEGMENT"
                GiD_WriteCalculationFile puts -nonewline "\n$\n$----LCID-------SF-------AT-------N1,N2,N3...------\n$"
            }
            
            set Contact_elements [GiD_WriteCalculationFile connectivities -localaxes $formatsLA \
                    -elemtype "$elemtype" $formats]
        }
        incr groups_num
    }         
    
    
#############################################################
#     Writing custom loads
    set customdataList ""
    set formats ""
    set xp {container[@n='loadcases']/condition[@n='custom_load']/group}
    foreach gNode [$root selectNodes $xp] {
        set xp {string(ancestor::blockdata[@n='loadcase']/@name)}
        set loadcase [$gNode selectNodes $xp]
        regsub -all {\s+} $loadcase {_} name
        set f "%d"
        set tcl_code [$gNode selectNodes {string(value[@n='tcl_code']/@v)}]
        set tcl_code_enc [string map [list %0D ""] [::ncgi::encode $tcl_code]]
        set units [$gNode selectNodes {string(value[@n='units']/@v)}]
        
        set num [expr {[llength $customdataList]+1}]
        set c "$num units=$units tcl=$tcl_code_enc name=custom_data$num"
        lappend customdataList $c
        append f " $num name=$name\n"
        if { [$gNode @ov] eq "point" } {
            set l custom_data_nodes
        } else {
            set l custom_data_elems
        }
        dict set formats $l $loadcase [$gNode @n] $f
    }

###########################################################
#     Writing wave loads 
    set formats ""
    set has_NavalWaveLoad 0
    set xp {container[@n='loadcases']/blockdata[@n='loadcase']/container[@n='Shells']/condition[@n='WaveLoad_shell']/group}
    foreach gNode [$root selectNodes $xp] {
        set xp {string(ancestor::blockdata[@n='loadcase']/@name)}
        set loadcase [$gNode selectNodes $xp]
        regsub -all {\s+} $loadcase {_} name
        set f "%d"
        set units [$gNode selectNodes {string(value[@n='WaveUnits']/@v)}]
        set tcl_code [$gNode selectNodes {string(value[@n='WaveTclCode']/@v)}]
        set tcl_code_enc [string map [list %0D ""] [::ncgi::encode $tcl_code]]
                
        set num [expr {[llength $customdataList]+1}]
        set c "$num units=$units tcl=$tcl_code_enc name=custom_data$num"
        lappend customdataList $c
        append f " $num name=$name\n"

        set l custom_data_elems
        
        dict set formats $l $loadcase [$gNode @n] $f
        incr has_NavalWaveLoad

    }
    if { $has_NavalWaveLoad } { GiD_WriteCalculationFile puts "NavalWaveLoad" }

###########################################################
#     Writing Morison loads 
    set formats ""
    set has_MorisonLoad 0
    set xp {container[@n='loadcases']/blockdata[@n='loadcase']/container[@n='Shells']/condition[@n='morison_load_shell']/group}
    foreach gNode [$root selectNodes $xp] {
        set xp {string(ancestor::blockdata[@n='loadcase']/@name)}
        set loadcase [$gNode selectNodes $xp]
        regsub -all {\s+} $loadcase {_} name
        set f "%d"
        set units [$gNode selectNodes {string(value[@n='MorUnits']/@v)}]
        set tcl_code [$gNode selectNodes {string(value[@n='MorisonTclCodeS']/@v)}]
        set tcl_code_enc [string map [list %0D ""] [::ncgi::encode $tcl_code]]
                
        set num [expr {[llength $customdataList]+1}]
        set c "$num units=$units tcl=$tcl_code_enc name=custom_data$num"
        lappend customdataList $c
        append f " $num name=$name\n"

        set l custom_data_elems
        
        dict set formats $l $loadcase [$gNode @n] $f
        incr has_MorisonLoad

    }
#     if { $has_MorisonLoad } { GiD_WriteCalculationFile puts "MorisonSurfLoad" }
############################################################

    if { [llength $customdataList] } {
        GiD_WriteCalculationFile puts "custom_data"
        GiD_WriteCalculationFile puts [join $customdataList \n]
        GiD_WriteCalculationFile puts "end custom_data"
    }


    foreach i [dict keys $formats] {
        GiD_WriteCalculationFile puts "static_load"
        GiD_WriteCalculationFile puts $i
        
        foreach loadcase [dict keys [dict get $formats $i]] {
            set NRDict ""
            foreach key [dict keys [dict get $formats $i $loadcase]] {
                foreach format [dict values [dict get $formats $i $loadcase]] {
                    dict set NRDict $format "%d:$format"
                }
            }
            if { $i eq "custom_data_nodes" } {
                GiD_WriteCalculationFile nodes -number_ranges $NRDict \
                    [dict get $formats $i $loadcase]
            } else {
                #                 GiD_WriteCalculationFile elements -elements_faces elements \
                    #                     -number_ranges $NRDict [dict get $formats $i $loadcase]
                # De momento sin la opci�n de rangos
                GiD_WriteCalculationFile elements -elements_faces elements [dict get $formats $i $loadcase]
                
                set formats_face ""
                dict for "n v" [dict get $formats $i $loadcase] {
                    dict set formats_face $i $loadcase $n "%d $v"
                }
                set NRDict ""
                foreach format [dict values [dict get $formats $i $loadcase]] {
                    dict set NRDict $format "%d:$format"
                }
                GiD_WriteCalculationFile elements -elements_faces faces \
                    -number_ranges $NRDict $formats_face
                
            }
        }
        
    }       
}

###############################################################
# OUTPUT FORMAT
##############################################################

proc b_write_calc_file::write_output_data  { root } {
    
    set printed_card 0
    global set_num
    
    set xp {blockdata[@n="Database"]/value[@n="DT"]}
    set valueNode [$root selectNodes $xp]
    set avs_time [gid_groups_conds::convert_value_to_default $valueNode]  

    if {$avs_time <= "0"}  {
        error [= "Invalid interval between GiD outputs"]
    }

    #WE SPECIFY AVSFLT FILE CARDS++++++++++++++++++++++++++++++++++++++++++++++++++++
    

    #WRITING GiD POST-PROCESS ACTIVATIONS (DATA EXTENT CARD)

    # SOME CASES OF SHELL STRAINS ARE IMPLEMENTED IN EASYDYNA.EXE BUT NOT HERE (BECAUSE SOMETIMES THEY ARE NOT PRESENT IN AVSFLT FILE)
    # CASE 49: Max. Principal Strain Midsurface
    # CASE 51: Min. Principal Strain Midsurface
    # CASE 52: Effective Strain lower Surface
    # CASE 53: Max. Principal Strain lower Surface
    # CASE 54: Trough thickness min. strain
    # CASE 55: Max. Principal Strain lower Surface
    # CASE 57: Effective Strain lower Surface
    # CASE 59: Max. Principal Strain upper Surface
    # CASE 60: Max. Principal Strain upper Surface

    foreach i [list Displacements Velocities Accelerations Stresses Strains Quadratic Brick_Stresses Brick_Plastic_Strain] j [list 0 0 0 3 3 3 1 1] \
        k [list 1 2 3 [list 1 2 3 4 5 6 46 8 9 10 11 12 13 47 15 16 17 18 19 20 48] [list 7 33 34 35 36 37 38 14 39 40 41 42 43 44 21] [list 22 23 24 25 26 27 28 29 30] [list 1 2 3 4 5 6] 7]  {
        switch $j {
            0 {
                set xp {blockdata[@n="Database"]/container[@n="Nodal"]/value[@n="Activate_${i}"]}
            }
            1 {
                set xp {blockdata[@n="Database"]/container[@n="Nodal"]/container[@n="Brick_Elements"]/value[@n="Activate_${i}"]}
            }
            3 {
                set xp {blockdata[@n="Database"]/container[@n="Nodal"]/container[@n="Brick_Elements"]/container[@n="Shell"]/value[@n="Activate_${i}"]}
            }
        }
        
        set xp [subst -nocommands $xp]
        set valueNode [$root selectNodes $xp]
        set activation [$valueNode @v]
        
        if {$activation=="yes"} {
            if {$printed_card=="0"} {
                GiD_WriteCalculationFile puts -nonewline "\n*DATABASE_EXTENT_AVS"
                GiD_WriteCalculationFile puts -nonewline "\n$\n$---VTYPE-----COMP-----\n$"
                set printed_card 1
            } 
            foreach v $k {
                GiD_WriteCalculationFile puts -nonewline "\n[format %8d $j],[format %8d $v]"
            }
        }
    }
    
    #IF ANY DATABASE_EXTENT IS ACTIVATED, WE PRINT DATABASE_AVSFLT CARD+++++++++++++++++
    
    if {$printed_card=="1"} {
        GiD_WriteCalculationFile puts -nonewline "\n*DATABASE_AVSFLT"
        GiD_WriteCalculationFile puts -nonewline "\n$\n$------DT-----\n$"       
        GiD_WriteCalculationFile puts -nonewline "\n[format "%8g" $avs_time],[format "%8d" 1]"  
    }    

    #WRITING LS-DYNA BINARY POSTPROCESS FILE PARAMETERS +++++++++++++++++++++++++++++++++++++
    # Now it is set automatically, consulting values from GiD postprocess data
    
    GiD_WriteCalculationFile puts -nonewline "\n*DATABASE_BINARY_D3PLOT"
    GiD_WriteCalculationFile puts -nonewline "\n$\n$-DT/CYC--LCDT/NR---BEAM-----------NPLTC----PSETID-------\n$"
    GiD_WriteCalculationFile puts -nonewline "\n[format "%8g" $avs_time]"

    #WE SPECIFY ELOUT FILE CARDS++++++++++++++++++++++++++++++++++++++++++++++++++++
    #IF ANY DATABASE_HISTORY CARD IS ACTIVATED, WE PRINT THIS CARD+++++++++++++++++++++++++

    foreach i [list Solid_Stress Yield_Function] {
        
        set xp {blockdata[@n="Database"]/container[@n="Elements"]/container[@n="Solids"]/value[@n="Activate_${i}"]}
        set xp [subst -nocommands $xp]
        set valueNode [$root selectNodes $xp]
        set $i [$valueNode @v]
    }
    
    foreach i [list Beam_Resultant Beam_Integration] {
        
        set xp {blockdata[@n="Database"]/container[@n="Elements"]/container[@n="Beams"]/value[@n="Activate_${i}"]}
        set xp [subst -nocommands $xp]
        set valueNode [$root selectNodes $xp]
        set $i [$valueNode @v]
    }
    
    if {$Solid_Stress=="yes" || $Yield_Function=="yes" || $Beam_Resultant=="yes" || $Beam_Integration=="yes"} {
        
        GiD_WriteCalculationFile puts -nonewline "\n*DATABASE_ELOUT"
        GiD_WriteCalculationFile puts -nonewline "\n$\n$------DT-----\n$"       
        GiD_WriteCalculationFile puts -nonewline "\n[format "%8g" $avs_time],[format "%8d" 1]"
    }
      

    #Then we write all solid elements as a list (if needed)
    
    if {$Solid_Stress=="yes" || $Yield_Function=="yes"} {
        incr set_num
       
        GiD_WriteCalculationFile puts -nonewline "\n*SET_SOLID_GENERAL"   
        GiD_WriteCalculationFile puts -nonewline "\n[format "%8d" $set_num]\n     ALL"
     
        GiD_WriteCalculationFile puts -nonewline "\n*DATABASE_HISTORY_SOLID_SET"
        
        #We will read this lines from easydyna
        if {$Solid_Stress=="yes"} {GiD_WriteCalculationFile puts -nonewline "\n$--Solid Stress"}
        if {$Yield_Function=="yes"} {GiD_WriteCalculationFile puts -nonewline "\n$--Yield Function"}

        GiD_WriteCalculationFile puts -nonewline "\n[format "%8d" $set_num]" 
        

    }
    
    #First we write all beam elements as a list (if needed)
    
    if {$Beam_Resultant=="yes" || $Beam_Integration=="yes"} {
        incr set_num
       
        GiD_WriteCalculationFile puts -nonewline "\n*SET_BEAM_GENERAL"   
        GiD_WriteCalculationFile puts -nonewline "\n[format "%8d" $set_num]\n     ALL"
     
        GiD_WriteCalculationFile puts -nonewline "\n*DATABASE_HISTORY_BEAM_SET"
        
        #We will read this lines from easydyna
        if {$Beam_Resultant=="yes"} {GiD_WriteCalculationFile puts -nonewline "\n$--Beam Resultant"}
        if {$Beam_Integration=="yes"} {GiD_WriteCalculationFile puts -nonewline "\n$--Beam Integration"}

        GiD_WriteCalculationFile puts -nonewline "\n[format "%8d" $set_num]" 
        
    }
   

        
#     set xp {blockdata[@n="Database"]/container[@n="General"]/container[@n="Nodal"]/container[@n="Brick_Elements"]/container[@n="Shell"]/container[@n="d3plot"]/value[@n="Output_Steps_Time"]}
#     set valueNode [$root selectNodes $xp]
#     set step_time [gid_groups_conds::convert_value_to_default $valueNode]
#     
#     if {$step_time == ""} {
#         GiD_WriteCalculationFile puts -nonewline "\n        ,"
#     } elseif {$step_time > "0"} {
#         GiD_WriteCalculationFile puts -nonewline "\n[format "%8g" $step_time],"
#     } else {      
#         error [= "Invalid Step time"] 
#     }
#     
#     #OPTIONAL LCDT NOT ALREADY IMPLEMENTED
#     GiD_WriteCalculationFile puts -nonewline "        ,"
#     #OPTIONAL BEAM NOT ALREADY IMPLEMENTED
#     GiD_WriteCalculationFile puts -nonewline "        ,"
#     
#     set step_number [get_value Output_Steps_Number]
#     
#     if {$step_number == ""} {
#         GiD_WriteCalculationFile puts -nonewline "        ,"
#     } elseif {$step_number > "0"} {
#         GiD_WriteCalculationFile puts -nonewline "[format "%8d" $step_number],"
#     } else {      
#         error [= "Invalid Step Number"]
#     }
    
    GiD_WriteCalculationFile puts -nonewline "\n*END" 
}

proc b_write_calc_file::compute_units_factor  { magnitude units } {
    #THIS FUNCTION HAVE BEEN CREATED IN ORDER TO SOLVE PROBLEMS 
    #FINDING TIME FACTORS (BECAUSE NOW s,min AND hours are in both
    #imperial and international system
    
    switch $magnitude {
        time {
            switch $units {
                s {
                    return 1
                }
                min {
                    return 60
                }
                hour {
                    return 360
                }
            }
        }  
        rotation {
            switch $units {
                deg {
                    return 0.017453292519943
                }
                rad {
                    return 1
                }
            }
        }
        velocity {                            

            set units_0 [lindex [split $units /] 0]  

            switch $units_0 {
                deg {
                    set factor_0 0.017453292519943
                }
                rad {
                    set factor_0 1
                }
            }
                    
            set units_1 [lindex [split $units /] 1]

            switch $units_1 {
                s {
                    set factor_1 1
                }
                min {
                    set factor_1 60
                }
                hour {
                    set factor_1 360
                }
            }           
            
            return [expr ($factor_0*$factor_1)]          
        }
    }    
    error [= "Invalid time units in curve definition"]
}
