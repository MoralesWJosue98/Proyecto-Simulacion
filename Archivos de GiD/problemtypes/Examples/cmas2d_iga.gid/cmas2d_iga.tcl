#events invoked from GiD
proc GiD_Event_InitProblemtype {dir} {
    cmas_iga::Modify_GiD_Menu
    GiD_RegisterPluginAddedMenuProc ::Modify_GiD_Menu 
    set ::cmas_iga::old_value_calcwithoutmesh [GiD_Set CalcWithoutMesh]
    GiD_Set CalcWithoutMesh 1
    
    GiD_DataBehaviour materials Default geomlist {surfaces}  
}

proc GiD_Event_EndProblemtype {} {
    GiD_UnRegisterPluginAddedMenuProc Modify_GiD_Menu
    GiD_Set CalcWithoutMesh $::cmas_iga::old_value_calcwithoutmesh
}

proc GiD_Event_AfterWriteCalculationFile { filename errorflag } {
    cmas_iga::WriteCalculationFile $filename
}
#end events

#to be invoked from the .bas with this content:*tcl(WriteCalculationFileInvokedFromBas)*\
#proc WriteCalculationFileInvokedFromBas { } {
#    set model_name [GiD_Info project modelname]
#    set filename [file join ${model_name}.gid [file tail $model_name]].dat
#    cmas_iga::WriteCalculationFile $filename
#    return ""
#}

namespace eval cmas_iga {
    variable old_value_calcwithoutmesh ;#auxiliar variable to restore previous CalcWithoutMesh value
}

proc cmas_iga::Modify_GiD_Menu {} {
    #We check if still exist Mesh menu and delete the menu
    set position [GiDMenu::_FindIndex Mesh PRE ]
    if { $position != "-1" } {
	GiDMenu::Delete Mesh PRE
	GiDMenu::UpdateMenus    
    }
}

# Auxiliar functions to find number value on text string
proc cmas_iga::DoubleValueAfter { searchtext string } {
    if { [regexp -- "${searchtext}\[-+\]?\[0-9\]*\\.?\[0-9\]+" $string result] == 0 } {
        W [= "Could not find ${searchtext}\[-+\]?\[0-9\]*\\.?\[0-9\]+ in $string"]
    }
    set length [string length $searchtext]
    return [string range $result $length end]    
}

proc cmas_iga::IntValueAfter { searchtext string } {
    if { [regexp -- "${searchtext}\[0-9\]+" $string result] == 0 } {
        W [= "Could not find ${searchtext}\[0-9\]+ in $string"]
    }
    set length [string length $searchtext]
    return [string range $result $length end]
}
# End auxiliar functions

proc cmas_iga::WriteCalculationFile { filename } {
    write_calc_data init $filename
    #write description and problem data info:
    write_calc_data puts "-------Input file for cmas2d_iga calculation: [GiD_Info gendata] -------"
    
    write_calc_data puts "-------NurbsSurface information-------"
    cmas_iga::WriteSurfaceInformation		
    
    write_calc_data puts "-------Conditions information-------"
    cmas_iga::WriteConditionsInformation	
    write_calc_data end
}

proc cmas_iga::WriteSurfaceInformation { } {	
    set listsurf [GiD_Geometry list surface 1:end]
    set number_of_surfaces [llength $listsurf]
    write_calc_data puts "$number_of_surfaces"
    write_calc_data puts "-------"
    foreach surfnum $listsurf {
       cmas_iga::WriteOneSurface $surfnum       	
    }
}

proc cmas_iga::WriteOneSurface { surfnum } {
    set result [GiD_Geometry get surface $surfnum]    
    # GiD_Geometry get surface will return:            
    # <type> <layer> <nl> ?<nurbs_data>? {l1 o1} ... {lnl onl} <geometrical data>      
    #
    # <type> can be: nurbssurface plsurface coonsurface meshsurface                  
    # <layer> is the layer name                  
    # <nl> number of boundary lines (including holes)                  
    # <nurbs_data> only for NURBS surfaces (<du> <dv> <nu> <nv> <istrimmed> <isrational>)                  
    # {li oi} identifier of line and its orientation for the surface (1 if opposite to the line advance, 0 else)                  
    # Note: turning left of a line with orientation 0 we go inside the surface.                  
    # <geometrical data> depends of each entity type, on nurbssurface is:
    # {x y z ?w?}1 ... {x y z ?w?}nuxnv <ku0> ... <kunu+du> <kv0> ... <kvnv+dv>                  
    # where:
    # <du> <dv>degree in u, v direction                  
    # <nu> <nv>number of control points in each direction                  
    # <ratu> <ratv> 1 if rational, 0 else                  
    # {xi yi zi ?wi?} control points coordinates. If rational wi is the weight                  
    # <kui> <kvi> knots in each direction                  
    #
    #Example:
    #nurbssurface Layer0 4 2 2 3 3 0 0 {1 0} {2 0} {3 0} {4 0}
    #{-2.2 1.3 0.2} {-3.9 1.3 0.3} {-5.6 1.3 0.2} 
    #{-2.2 0.2 0.3} {-3.9 0.2 0.9} {-5.6 0.2 0.3} 
    #{-2.2 -0.8 0.2} {-3.9 -0.8 0.3} {-5.6 -0.8 0.2} 
    #0.0 0.0 0.0 1.0 1.0 1.0 
    #0.0 0.0 0.0 1.0 1.0 1.0

    if { [lindex $result 0] != "nurbssurface" } {
        W [= "Surface $surfnum is not a NURBS Surface, it will not be pressent on the result"]
        return
    }
    write_calc_data puts "$surfnum"    
    
    lassign [lrange $result 1 8] layer nl du dv nu nv istrimmed isrational
    
    set num_total_controlpoints [expr $nu*$nv]
    write_calc_data puts "$num_total_controlpoints"
    
    set index_end_boundary_info [expr 9+$nl-1]   
    set boundary_info [lrange $result 9 $index_end_boundary_info]
    
    set index_end_controlpoints [expr $index_end_boundary_info+($nu*$nv)]    
    set list_controlpoints [lrange $result [expr $index_end_boundary_info+1] $index_end_controlpoints ]
    foreach cp $list_controlpoints {
        lassign $cp cpx cpy cpz
        if { $isrational == 1 } {
            #not used in this example
            set cpw [lindex $cp 3]
        }
        write_calc_data puts "$cpx $cpy $cpz"
    }
    
    set index_end_knots_u [expr $index_end_controlpoints+$nu+$du+1]
    set knots_u [lrange $result [expr $index_end_controlpoints+1] $index_end_knots_u]
    
    set index_end_knots_v [expr $index_end_knots_u+$nv+$dv+1]
    set knots_v [lrange $result [expr $index_end_knots_u+1] $index_end_knots_v]
    
    cmas_iga::WriteExtraInfoSurfaceAreaAndDensity $surfnum $num_total_controlpoints
}

proc cmas_iga::WriteExtraInfoSurfaceAreaAndDensity { surfnum num_total_controlpoints } {
    set area [cmas_iga::DoubleValueAfter "Total area=" [GiD_Info ListMassProperties surfaces $surfnum]]    
   
    set materialnum [cmas_iga::IntValueAfter "material: " [GiD_Info list_entities Surfaces $surfnum]]
    if { $materialnum != "0" } {       
        set materialname [lindex [GiD_Info materials] [expr $materialnum-1]]
        set density [cmas_iga::DoubleValueAfter "Density " [GiD_Info materials $materialname]]
    } else {
        set density "0.0"
    }
    
    write_calc_data puts "$area $density"    
}

proc cmas_iga::WriteConditionsInformation { } {
    set listconditions [GiD_Info conditions Point-Weight geometry]
    set number_of_conditions [llength $listconditions]
    write_calc_data puts "$number_of_conditions"
    write_calc_data puts "-------"
    
    foreach cond $listconditions {
	set num_point [lindex $cond 1]
	set weight [lindex $cond 3]
	write_calc_data puts "[lrange [GiD_Geometry get point $num_point] 1 3] $weight"
    }
}






