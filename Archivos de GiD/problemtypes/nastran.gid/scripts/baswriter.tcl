 
namespace eval BasWriter { } { 
    variable matid
    variable currentmatid 0
} 

proc BasWriter::WriteContacts { } {
    
    foreach i [GiD_Info Conditions Contact mesh] {
        foreach "tetra face - master_slave group" $i break
        if { $master_slave == "Master" } {
            lappend masters($group) [list $tetra $face]
        } else {
            lappend slaves($group) [list $tetra $face]
        }
    }
    
    foreach "elm n1 n2 n3 n4 mat"  [GiD_Info Mesh Elements Tetrahedra] {
        set elms($elm) [list $n1 $n2 $n3 $n4]
    }
    set nn [list [list 0 1 2] [list 1 3 2] [list  2 3 0] [list  3 1 0]]
    
    
    set result ""
    set term "\n        "
    
    set idmax 0
    set idlist ""
    foreach i [array names masters] {
        if { $i > $idmax } { set idmax $i }
        lappend idlist $i
        append result [format "BSSEG   %8i" $i]
        set nasidx 3
        foreach j $masters($i) {
            foreach "num face" $j break
            for { set k 2 } { $k >= 0 } { incr k -1 } {
                set pos [lindex [lindex $nn [expr $face-1]] $k]
                set n [lindex $elms($num) $pos]
                if { $nasidx > 9 } { append result $term ; set nasidx 2 }
                append result [format "%8i" $n]
                incr nasidx
            }
            if { $nasidx > 9 } { append result $term ; set nasidx 2 }
            append result [format "%8i" 0]
            incr nasidx
        }
    }
    append result "\n"
    foreach i [array names slaves] {
        append result [format "BSSEG   %8i" [expr {$i+$idmax}]]
        set nasidx 3
        foreach j $slaves($i) {
            foreach "num face" $j break
            for { set k 2 } { $k >= 0 } { incr k -1 } {
                set pos [lindex [lindex $nn [expr $face-1]] $k]
                set n [lindex $elms($num) $pos]
                if { $nasidx > 9 } { append result $term ; set nasidx 2 }
                append result [format "%8i" $n]
                incr nasidx
            }
            if { $nasidx > 9 } { append result $term ; set nasidx 2 }
            append result [format "%8i" 0]
            incr nasidx
        }
    }
    append result "\n"
    
    set ic 1
    foreach i $idlist {
        append result [format "BSCONP  %8i%8i%8i%#8.3g%#8.3g%#8.3g%8i\n" $ic [expr {$i+$idmax}] \
                $i 1.0 0.0 0.0 2]
        incr ic
    }
    return $result
}

proc BasWriter::getmatnum { input } {
    variable matid
    set matid $input
    return ""
    
}

proc BasWriter::matnastran  { matname } {
    variable matid
    variable currentmatid
    set currentmatid $matid
    
    array set NasComposite::matidlist [list "$matname" $matid]
    array set plate::matidlist [list "$matname" $matid]
    
    set matname [string trim $matname]
    array set matinfo [lrange [ GiD_Info materials $matname ] 1 end]
    set output ""
    switch $matinfo(Type) {
        "isotropic" {
            nasmat::getmatnum $matid
            set output [nasmat::writenastran "$matname"]
        }
        "anisotropic_shell" {
            nasmat_anisotropicshell::getmatnum $matid
            set output [nasmat_anisotropicshell::writenastran "$matname"]
        }
        "orthotropic_shell" {
            nasmat_orthotropicshell::getmatnum $matid
            set output [nasmat_orthotropicshell::writenastran "$matname"]
        }
        default {
            WarnWin [= "Material type not supported by GiD-NASTRAN Interface.\n Error ref: Baswriter-->#1(swicth//matnastran)"]
        }
    }
    return $output
}

