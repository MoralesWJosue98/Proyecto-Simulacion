namespace eval button_tables {
    
    variable table_data {
        R0lGODlhGAAYAOMAAAAAAMbGxv//Qv//Sv//Uv//Wv//Y///a///c///e///
        hP///8bGxsbGxsbGxsbGxiH5BAEKAA8ALAAAAAAYABgAAASE8MlJq70418C7
        /94GjGRpjoEoIIAAFEMbu4abUgGQJAdgFISWgHZg3SY5RaLlCwpiBgNieZTk
        TlhS9ZFbeL8LAPgL2HbDI68YvS6Lxmp42NxOh9V2N2495oP1SHVteG10cn5k
        hmxxi3NvcIhqiiSMlI57h4eKfZoiWVlmIKIfGqWmpxURADs=
    }
    variable table [image create photo -data [set table_data]]
    
}
proc button_tables::initbutton { op args } {
    
    switch $op {
        "INIT" {
            set PARENT [lindex $args 0]
            upvar [lindex $args 1] ROW
            set GDN [lindex $args 2]
            set STRUCT [lindex $args 3]
            set cmd "GidOpenMaterials Tables"
            set btable [Button $PARENT.btable -image $button_tables::table \
                    -helptext [= "Open a window to create or to edit a table of values"] \
                    -command $cmd]
            grid $btable -column 1 -row [expr $ROW+1] -sticky nw          
        }
        "SYNC" {
            set GDN [lindex $args 0]
            set STRUCT [lindex $args 1]
            upvar \#0 $GDN GidData 
        }
        "CLOSE" {
        }
    }
}

