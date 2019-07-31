# Rozen. Debugging procs. Started with PrintByName and Call_Trace from
# the Welch book and went from there. The way I often debug a Tcl
# program such as PAGE is to issue the following command:

# page vrex.tcl | tee output.stuff.

proc PrintByName { args } {

    # Takes a list of variable names and prints the name and the
    # corresponding value for each name along with the enclosing proc.
    # Example usage: dpr x y z

    set x [expr [info level]-1]
    set y [lindex [info level $x] 0]

    set str "dpr: $y: "
    foreach var_name $args {
        upvar 1 $var_name dvar
        append str "$var_name = $dvar, "
    }
    puts stdout $str
}

rename PrintByName dpr

# Prints a trace of the Tcl call stack.
# Example usage: dtrace

proc Call_Trace {{file stdout}} {
    puts $file "Tcl Call Trace"
    for {set x [expr [info level]-1]} {$x > 0} {incr x -1} {
        puts $file "$x: [info level $x]"
    }
}
rename Call_Trace dtrace

proc dmsg {args} {
    # Takes zero or more arguments. If there are no argumenst, it
    # prints the name of the encolsing procedure and the string
    # "Starting" If there are arguments present they are printed as
    # strings with separated with " ".  It saves having to put quotes
    # around the message printed.
    # Example usage: dmsg inside frame clause of switch
    if {[llength $args] == 0} {
        set msg Starting
    } else {
        foreach w $args {
            append msg $w " "
        }
    }
    set x [expr [info level]-1]
    set y [lindex [info level $x] 0]

    set msg ""
    foreach m $args {
        append msg $m " "
    }
    if {$msg == ""} {
        set msg "Starting."
    }
    set msg [string trimright $msg]
    set str "dmsg: $y: $msg."
    puts stdout $str
}

proc dargs { } {
    # Prints out the name of the enclosing proc and the arguments to
    # the proc.
    # Example usage dargs.
    set x [expr [info level]-1]
    set y [lindex [info level $x] 0]
    puts "dargs [info level $x]"
    set a [info args [lrange [info level $x] 0 0]]
    puts "args: $a"
    for {set i 0} {$i < [expr [llength [info level $x]] - 1]} {incr i} {
        set ii [expr $i + 1]
        puts "[lrange $a $i $i] = [lrange [info level $x] $ii $ii]"
    } ;# end for loop
    puts "-----------"

}

proc dpl { arg } {
    # Print out list with each element in a list printed on a separate line..
    set x [expr [info level]-1]
    set y [lindex [info level $x] 0]

    set str "dpl: $y: "
    upvar 1 $arg var
    append str "$arg:"
    foreach element $var {
        append str "\n $element"
    }
    puts stdout $str
}

proc dskip { {lines 1} } {
    # Skips one or more lines in the output for easier spotting of the
    # following lines of debugging output.
    for {set x 0} {$x<$lines} {incr x} {
        puts "\n"
    }
}

proc stop {} {
    # Kills the execution and gives an error message with optional
    # traceback.
    [expr 1 / 0]
}

#proc tracer {varname args} {
#    upvar #0 $varname var
#    puts "$varname was updated to be \"$var\""
#}

# Example of trace statement to be put in the code.
# trace add variable foo write "tracer foo"

proc vTcl:show_config {target} {
    set cfg [$target configure]
    puts "config = $cfg"
}

# This command prints out a procedure suitable for saving in a Tcl
# script. It was found in the tcl info man page.
proc printProc {procName} {
    # Modified from example in tcl documentation.
    if {[llength [info commands $procName]] == 0} {
        puts "\"$procName\" does not exist"
        return
    }
    set result [list proc $procName]
    set formals {}
    foreach var [info args $procName] {
        if {[info default $procName $var def]} {
            lappend formals [list $var $def]
        } else {
            # Still need the list-quoting because variable
            # names may properly contain spaces.
            lappend formals [list $var]
        }
    }
    puts [lappend result $formals [info body $procName]]
}

rename printProc printproc

# proc prettyRec { l i } {
#   #puts "pretty Rec $l : $i"
#   set next ""
#   set indent ""
#   set space "  "
#   for { set j 0} {$j < $i} {incr j} {
#     append indent $space
#   }
#   set result "$indent\[\n"
#   foreach x $l {
#     if {[llength $x] == 1} {
#       append result "$indent$space$x\n"
#     } else {
#       set next [prettyRec $x [expr $i + 1]]
#       append result "\n$next"
#     }
#   }
#   append result "${indent}]\n"
#   return $result
# }

# proc pretty { l } {
#   return [prettyRec $l 0]
# }

# proc dpl { l } {
# puts "++++++++++++++++++++++++++++++++++++++++++++++"
#     set x [expr [info level]-1]
#     set y [lindex [info level $x] 0]
#     upvar 1 $l dvar
#     set str "dpl: $y: $l ="
#     puts $str
#     set pl [pretty $dvar]
#     puts $pl
# puts "++++++++++++++++++++++++++++++++++++++++++++++++"
# }

# Example 21-2 from Welch's book. Useful for debugging tk routines.
proc Widget_Attributes {w {out stdout}} {
#upvar 1 $w_name w
#puts "w_name = $w_name"    
puts "w = $w"    
    #set w $w_name
    set x [expr [info level]-1]
    puts "dargs [info level $x]"
    puts $out [format "%-20s %-10s %s" Attribute Default Value]
    foreach item [$w configure] {
        puts $out [format "%-20s %-10s %s" \
            [lindex $item 0] [lindex $item 3] \
            [lindex $item 4]]
    }
}

rename Widget_Attributes dconf

proc pconf {conf {out stdout}} {
    # Called with "pconf $conf"
    puts $out [format "%-20s %-10s %s" Attribute Default Value]
    foreach item $conf {
        puts $out [format "%-20s %-10s %s" \
                       [lindex $item 0] [lindex $item 3] \
                       [lindex $item 4]]
    }
} ;# end pconf
