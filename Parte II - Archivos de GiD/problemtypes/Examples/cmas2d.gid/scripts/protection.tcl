namespace eval Cmas2d {
}

proc Cmas2d::GetHasPassword { dir } {    
    set has_password 0
    set message ""
    if { [catch { package require verifp } message] } {        
        set has_password 0
    } else {
        set filename [file join $dir password.txt]
        set program [string tolower $::problemtype_current(Name)]
        set main_version [lindex [split $::problemtype_current(Version) .] 0]
        lassign [vp_getauthorization $program $main_version * "my cmas2d secret key" $filename 0] status message
        if { $status == "VERSION_PRO" || $status == "VERSION_TMPPRO" } {
            set has_password 1
        }
    }     
    return [list $has_password $message]
}

proc Cmas2d::ReleasePassword { } {
    if { [catch { package require verifp } err] } {
        W [= "Error loading library"]
    } else {
        set program [string tolower $::problemtype_current(Name)]
        set main_version [lindex [split $::problemtype_current(Version) .] 0]
        return [vp_releaseauthorization $program $main_version *]
    }
}

proc Cmas2d::VerifyPassword { password {machinename ""} {operatingsystem ""} {sysinfo ""} } {    
    if { [catch { package require verifp } err] } {
        W [= "Error loading library"]
    } else {
        set program [string tolower $::problemtype_current(Name)]
        set main_version [lindex [split $::problemtype_current(Version) .] 0]
        return [vp_verifypassword $program $main_version * "my cmas2d secret key" $machinename $operatingsystem $sysinfo $password]
    }
}

proc Cmas2d::ValidatePassword { key dir computer_name } {
    set is_ok 0
    set message ""
    lassign [Cmas2d::VerifyPassword $key] is_ok message
    if { $is_ok } {
        set message [= "This is the professional version of this problemtype"]        
    } else {       
        set message [= "The password for this problemtype is not valid (%s)" $message]]
    }
    return [list $is_ok $message]
}

