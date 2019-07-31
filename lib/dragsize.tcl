##############################################################################
# $Id: dragsize.tcl,v 1.17 2001/12/08 05:53:44 cgavin Exp $
#
# dragsize.tcl - procedures to handle widget sizing and movement
#
# Copyright (C) 1996-1998 Stewart Allen
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
##############################################################################

set vTcl(cursor,w) ""

proc vTcl:store_cursor {target} {
    global vTcl

    ## only store cursor once
    if {$vTcl(cursor,w) == ""} {
        set vTcl(cursor,last) ""
        set vTcl(cursor,w) $target
        catch {set vTcl(cursor,last) [$target cget -cursor]}
    }
}

proc vTcl:restore_cursor {target} {
    global vTcl

    ## only restore cursor once
    if {$vTcl(cursor,w) != "" && [winfo exists $vTcl(cursor,w)]} {
        catch {$vTcl(cursor,w) configure -cursor $vTcl(cursor,last)}
    }

    set vTcl(cursor,w) ""
}

# Rozen Many of these bindings are specified in ../page.tcl
proc vTcl:bind_button_1 {target X Y x y} {
    global vTcl
    vTcl:set_mouse_coords $X $Y $x $y
    set parent [winfo parent $target]
    set parent_class [winfo class $parent]
    if {[string first  "Scroll" $parent_class] > -1} { ;# Rozen 9/2/16
        vTcl:bind_button_top $target $X $Y $x $y
        return
    }
    set parent $target
    # Megawidget ?
    if {[vTcl:WidgetVar $target parent tmp]} { set parent $tmp }

    if {[lindex [split %W .] 1] == "vTcl"} { return }

    set vTcl(cursor,inside_button_1) 1

    vTcl:active_widget $parent

    if {$parent != "." && [winfo class $parent] != "Toplevel"} {
        vTcl:grab $target $X $Y
        vTcl:store_cursor $target
        catch {$target configure -cursor fleur}
    } else {
        vTcl:store_cursor $target
    }

    set vTcl(cursor,inside_button_1) 0
}

proc vTcl:bind_button_2 {target X Y x y} {
    # Rozen. Think that i no longer am using this function.
    global vTcl[lindex [split %W .] 1]
    vTcl:set_mouse_coords $X $Y $x $y
    set parent $target
    set parent_class [winfo class $parent]
    if {$parent_class == "Scrollbar"} {  ;# Rozen 9/2/16
        vTcl:grab $target $X $Y
        vTcl:store_cursor $parent
        catch {$parent configure -cursor fleur}
        return
    }
    # Megawidget ?
    if {[vTcl:WidgetVar $target parent tmp]} { set parent $tmp }

    vTcl:active_widget $parent

    if {$vTcl(w,widget) != "." && \
        [winfo class $vTcl(w,widget)] != "Toplevel" && \
        $vTcl(w,widget) != ""} {

        vTcl:grab $target $X $Y
        vTcl:store_cursor $target
        catch {$target configure -cursor fleur}
    }
}

proc  vTcl:bind_motion_ctrl {W x y} {
    # Added to try and find out if the event included the control
    # button in the case where the widget was a component of a paned
    # window or a notebook.
    global vTcl
    set ctrl 1
    set widget $vTcl(w,widget) ;# The whole widget even if you select a tab
    set parent [winfo parent $widget]
    set parent_class [winfo class $parent]
    if {$parent_class == "TPanedwindow"} { return}
    vTcl:bind_motion $widget $x $y $ctrl ;# Pass the top level of the widget.
}

proc vTcl:bind_motion {W x y {ctrl 0}} {
    # This function is a callback from <B1-Motion> or <B2-Motion>
    # bound in page.tcl. Return if widget is locked.
    global vTcl
    set widget $vTcl(w,widget)
    if {[info exists ::widgets::${widget}::locked] &&
        [set ::widgets::${widget}::locked]} {
        return
   }
    if {$vTcl(w,widget) != "." && $vTcl(w,class) != "Toplevel"} {
        if {$ctrl == 0} {
            set widget $vTcl(w,widget)
            set parent [winfo parent $widget]
            set parent_class [winfo class $parent]
            if {$parent_class == "TPanedwindow"} { return}
        }
        vTcl:grab_motion $vTcl(w,widget) $W $x $y
    }
    if {$vTcl(w,class) != "Toplevel"} {
    }
}

proc vTcl:bind_button_top {target X Y x y} {
    # What I want to do here is to bind <Control-Button-1> to the top
    # widget of a complex widget like a notebook not one of the inside
    # widgets. The problem is to recognize the right widget. Rozen
    global vTcl
    vTcl:set_mouse_coords $X $Y $x $y
    # See if parent is child of complex_class.
    set parent [winfo parent $target]
    if {$target != "" &&
        [lsearch $vTcl(complex_class) [winfo class $parent]] > -1} {
        set w $parent
    } else {
        set w $target
    }

    set vTcl(cursor,inside_button_1) 1

    vTcl:active_widget $w
    if {$w != "." && [winfo class $w] != "Toplevel"} {
        vTcl:active_widget $w
        vTcl:grab $w $X $Y
        #set vTcl(cursor,last) [$w cget -cursor]
        vTcl:store_cursor $w
        catch {$w configure -cursor fleur}
    } else {
        vTcl:store_cursor $w
    }
    set vTcl(cursor,inside_button_1) 0
}

proc vTcl:bind_button_container {target X Y x y} {
    # Bind <Shift-Button-1> to the containing widget. Particularly
    # useful when a widget has been expanded to fill the contain and
    # otherwise it is impossible to grab the container and move or
    # resize it. Just run back up the hierarchy 'till we find a
    # container widget.
    global vTcl
    vTcl:set_mouse_coords $X $Y $x $y
    set parent [winfo parent $target]
    set class [vTcl:get_class $parent]
    set container "Frame Labelframe TFrame TLabelFrame Toplevel"
    while {[string first $class $container] == -1} {
        set parent [winfo parent $parent]
        set class [vTcl:get_class $parent]
    }
    vTcl:active_widget $parent
}

proc vTcl:bind_release {W X Y x y} {
    global vTcl
    if {[info exist vTcl(cursor,inside_button_1)] &&
        $vTcl(cursor,inside_button_1)} {
        after 500 "vTcl:bind_release $W $X $Y $x $y"
        return
    }

    # puts "release button 1: $W"
    vTcl:set_mouse_coords $X $Y $x $y

    if {$vTcl(w,widget) == ""} {return}

    vTcl:restore_cursor $W
    vTcl:place_handles $vTcl(w,widget)
    vTcl:grab_release $W
    vTcl:update_widget_info $vTcl(w,widget)
}

proc vTcl:grab {widget absX absY} {
    global vTcl
    grab $widget
    set vTcl(w,didmove) 0
    set vTcl(w,grabbed) 1
    set vTcl(grab,startX) [vTcl:grid_snap x $absX]
    set vTcl(grab,startY) [vTcl:grid_snap y $absY]
}

proc vTcl:moving_pane {parent widget x y} {
    # Rozen. Written to facilitate pane specification when a pane is moved.
    global vTcl
    set panes [$parent panes]
    set pane_index [lsearch $panes $widget]
    set o [$parent cget -orient]
    set no_panes [llength $panes]
    set no_sashes [expr $no_panes -1]
    # Determine if pane is an interior pane.
    if {$pane_index > 0 && $pane_index < [expr $no_panes - 1]} {
        update idletasks
        if {$o == "horizontal"} {
            set old_pos1 [$parent sashpos [expr $pane_index - 1]]
            $parent sashpos [expr $pane_index - 1] $x
            set diff [expr $x - $old_pos1]
            $parent sashpos $pane_index [expr $x  + $vTcl(w,width)]

        } else {
            # vertical paned window.
            set old_pos1 [$parent sashpos [expr $pane_index - 1]]
            set diff [expr $y - $old_pos1]
            $parent sashpos [expr $pane_index - 1] $y
            $parent sashpos $pane_index [expr $y  + $vTcl(w,height)]
        }
        vTcl::widgets::ttk::panedwindow::resizeAdjacentPanes \
            $parent $widget $pane_index $o $diff
    }
    update idletasks
}

proc vTcl:grab_motion {parent widget absX absY} {
    # parent designates a megawidget, widget is the
    # child (if any) being dragged
    global vTcl
    set vTcl(w,didmove) 1
    # workaround for Tix
    if { $vTcl(w,grabbed) == 0 } { vTcl:grab $widget $absX $absY }
    if {[regexp {\.[pt][0-9]+$} $widget]} {
        return
    }
    set pparent [winfo parent $widget] ;# Don't know what the arg parent is???
    set parent_class [winfo class $pparent]
    #if {$parent_class == "TNotebook" && $w_c == "Frame"} { return }
    #if {$parent_class == "TPanedwindow"} { return }
    # Detect that this is a window pane using parent_class above.
    # Then don't place it just adjust the appropiate sashes.  Rozen
    # if {$parent_class == "TPanedwindow"} {
    #     # Do the pane thing
    #     set newX [vTcl:grid_snap x \
    #             [expr {$absX-$vTcl(grab,startX)+$vTcl(w,x)}]]
    #     set newY [vTcl:grid_snap y \
    #             [expr {$absY-$vTcl(grab,startY)+$vTcl(w,y)}]]
    #     vTcl:moving_pane $pparent $widget $newX $newY
    #     vTcl:place_handles $parent
    #     return
    # }
    if { $vTcl(w,manager) == "place" } {
        place $parent \
            -x [vTcl:grid_snap x \
                [expr {$absX-$vTcl(grab,startX)+$vTcl(w,x)}]] \
            -y [vTcl:grid_snap y \
                [expr {$absY-$vTcl(grab,startY)+$vTcl(w,y)}]]
    }
    vTcl:place_handles $parent
}


proc vTcl:grab_release {widget} {
    global vTcl
    grab release $widget
    set vTcl(w,grabbed) 0
    if { $vTcl(w,didmove) == 1 } {
        set vTcl(undo) [vTcl:dump_widget_quick $vTcl(w,widget)]
        vTcl:passive_push_action $vTcl(undo) $vTcl(redo)
    }
}

proc vTcl:grab_resize_ctrl {absX absY handle} {
    global vTcl classes
    set widget $vTcl(w,widget)
    set parent [winfo parent $widget]
    set parent_class [winfo class $parent]
    set ctrl 1
    vTcl:grab_resize $absX $absY $handle $ctrl

}


# proc vTcl:grab_resize {absX absY handle {ctrl 0}} {
#     global vTcl classes
#     set vTcl(w,didmove) 1
#     set widget $vTcl(w,widget)
#     set class [vTcl:get_class $widget]
#     set X [vTcl:grid_snap x $absX]
#     set Y [vTcl:grid_snap y $absY]
#     set deltaX [expr {$X - $vTcl(grab,startX)}]
#     set deltaY [expr {$Y - $vTcl(grab,startY)}]
#     ## Can we resize this widget with this handle?
#     set can [vTcl:can_resize $handle]
# dpr can handle widget class
#     if {$can == 0} { return }     ; ## We definitely can't resize.
#     set newX $vTcl(w,x)
#     set newY $vTcl(w,y)
#     set newW $vTcl(w,width)
#     set newH $vTcl(w,height)
#     switch $vTcl(w,manager) {
#         place {
#             switch $handle {
#                 n {
#                     if {$can == 4} { return }
#                     set newX $vTcl(w,x)
#                     set newY [expr {$vTcl(w,y) + $deltaY}]
#                     set newW $vTcl(w,width)
#                     set newH [expr {$vTcl(w,height) - $deltaY}]
#                 }
#                 e {
# dmsg going east
#                     if {$can == 3} { return }
#                     set newX $vTcl(w,x)
#                     set newY $vTcl(w,y)
#                     set newW [expr {$vTcl(w,width) + $deltaX}]
#                     set newH $vTcl(w,height)
#                 }
#                 s {
# dmsg going south
#                     if {$class == "TSeparator"} {
#                         set newY [expr {$vTcl(w,y) + $deltaY}]
#                     } else {
#                     if {$can == 4} { return }
#                     # set newX $vTcl(w,x)
#                     # set newY $vTcl(w,y)
#                     # set newW $vTcl(w,width)
#                     set newH [expr {$vTcl(w,height) + $deltaY}]
#                     }
#                 }
#                 w {
#                     if {$can == 3} { return }
#                     set newX [expr {$vTcl(w,x) + $deltaX}]
#                     set newY $vTcl(w,y)
#                     set newW [expr {$vTcl(w,width) - $deltaX}]
#                     set newH $vTcl(w,height)
#                 }
#                 nw {
#                     if {$can == 1 || $can == 2} {
#                         set newX [expr {$vTcl(w,x) + $deltaX}]
#                         set newW [expr {$vTcl(w,width) - $deltaX}]
#                     }

#                     if {$can == 1 || $can == 3} {
#                         set newY [expr {$vTcl(w,y) + $deltaY}]
#                         set newH [expr {$vTcl(w,height) - $deltaY}]
#                     }
#                 }
#                 ne {
#                     if {$can == 1 || $can == 2} {
#                         set newX $vTcl(w,x)
#                         set newW [expr {$vTcl(w,width) + $deltaX}]
#                     }

#                     if {$can == 1 || $can == 3} {
#                         set newY [expr {$vTcl(w,y) + $deltaY}]
#                         set newH [expr {$vTcl(w,height) - $deltaY}]
#                     }
#                 }
#                 se {
#                     if {$can == 1 || $can == 2} {
#                         set newX $vTcl(w,x)
#                         set newW [expr {$vTcl(w,width) + $deltaX}]
#                     }

#                     if {$can == 1 || $can == 3} {
#                         set newY $vTcl(w,y)
#                         set newH [expr {$vTcl(w,height) + $deltaY}]
#                     }
#                 }
#                 sw {
#                     if {$can == 1 || $can == 2} {
#                         set newX [expr {$vTcl(w,x) + $deltaX}]
#                         set newW [expr {$vTcl(w,width) - $deltaX}]
#                     }

#                     if {$can == 1 || $can == 3} {
#                         set newY $vTcl(w,y)
#                         set newH [expr {$vTcl(w,height) + $deltaY}]
#                     }
#                 }
#             }

#             set class [winfo class $widget]
#             set parent [winfo parent $widget]
#             set parent_class [winfo class $parent]
# dpr class
#             # Detect that this is a window pane using parent_class above.
#             # Then don't place it just adjust the appropiate sashes.

#             if {$parent_class == "TPanedwindow"} {
#                 vTcl::widgets::ttk::panedwindow::resizePane \
#                     $parent $widget $newW $newH $handle


#                 # Do the pane thing
#                 # Pick up facts about the paned window.
#                 set panes [$parent panes]
#                 set pane_index [lsearch $panes $widget]
#                 set o [$parent cget -orient]
#                 set no_panes [llength $panes]
#                 set no_sashes [expr $no_panes -1]
#                 if {$pane_index > 0} {
#                     update idletasks
#                     if {$o == "horizontal"} {
#                         $parent sashpos [expr $pane_index - 1] $newX
#                     } else {
#                         $parent sashpos [expr $pane_index - 1] $newY
#                     }
#                 }
#                 if {$pane_index < [expr $no_panes - 1]} {
#                     if {$o == "horizontal"} {
#                         $parent sashpos $pane_index [expr $newX + $newW]
#                     } else {
#                         $parent sashpos $pane_index [expr $newY + $newH]
#                     }
#                 }
#                 update idletasks

#             } elseif {$class == "Scale" || $class == "TScale"} {   # Rozen
#                 set o [$widget cget -orient]
#                 if {$o == "horizontal"} {
#                     $widget configure -length $newW
#                 } else {
#                     $widget configure -length $newH
#                 }
#                 place $widget -x $newX -y $newY

#             } elseif {$class == "TSeparator"} {
#                 set o [$widget cget -orient]
#                 if {$o == "horizontal"} {
# dmsg horizontal TSeparator
#                     place $widget -x $newX -y $newY -width $newW
#                 } else {
#                     place $widget -x $newX -y $newY -height $newH
#                 }

#             } else {
#                 # This is the normal action for all widgets except
#                 # paned windows or scale widgets.
#                 place $widget -x $newX -y $newY -width $newW -height $newH \
#     -relwidth 0.0 -relheight 0.0 ;# Added for 'Fill Container' 5/30/16
#                 #set vTcl($widget,height) $newH             ;# Rozen 2/15/16
#                 #set vTcl($widget,width) $newW              ;# Rozen 2/15/16
#             }
#             # Rozen
#             set vTcl($widget,x) $newX
#             set vTcl($widget,y) $newY


#         }
#         grid -
#         pack {
#             switch $vTcl(w,class) {
#                 Label -
#                 Entry -
#                 Message -
#                 Scrollbar -
#                 Scale {
# #                    set vTcl(w,opt,-height) ""
#                 }
#             }

#             switch $handle {
#                 n {
#                     set newW $vTcl(w,opt,-width)
#                     set newH [expr {$vTcl(w,opt,-height) - $deltaY}]
#                 }
#                 e {
#                     set newW [expr {$vTcl(w,opt,-width) + $deltaX}]
#                     set newH $vTcl(w,opt,-height)
#                 }
#                 s {
#                     set newW $vTcl(w,opt,-width)
#                     set newH [expr {$vTcl(w,opt,-height) + $deltaY}]
#                 }
#                 w {
#                     set newW [expr {$vTcl(w,opt,-width) - $deltaX}]
#                     set newH $vTcl(w,opt,-height)
#                 }
#                 nw {
#                     set newW [expr {$vTcl(w,opt,-width) - $deltaX}]
#                     set newH [expr {$vTcl(w,opt,-height) - $deltaY}]
#                 }
#                 ne {
#                     set newW [expr {$vTcl(w,opt,-width) + $deltaX}]
#                     set newH [expr {$vTcl(w,opt,-height) - $deltaY}]
#                 }
#                 se {
#                     set newW [expr {$vTcl(w,opt,-width) + $deltaX}]
#                     set newH [expr {$vTcl(w,opt,-height) + $deltaY}]
#                 }
#                 sw {
#                     set newW [expr {$vTcl(w,opt,-width) - $deltaX}]
#                     set newH [expr {$vTcl(w,opt,-height) + $deltaY}]
#                 }
#             }
#             if { $newW < 0 } { set newW 0 }
#             if { $newH < 0 } { set newH 0 }
#     }
#     }
#     $classes($vTcl(w,class),resizeCmd) $widget $newW $newH $handle
#     vTcl:place_handles $widget
# } ;# End of vTcl:grab_resize

proc vTcl:resize_tseparator {widget absX absY handle} {
    # Handle the can of worms related to TSeparator.
    global vTcl classes
    if {[info exists ::widgets::${widget}::locked] &&
        [set ::widgets::${widget}::locked]} {
        return
    }
    set vTcl(w,didmove) 1
    set X [vTcl:grid_snap x $absX]
    set Y [vTcl:grid_snap y $absY]
    set deltaX [expr {$X - $vTcl(grab,startX)}]
    set deltaY [expr {$Y - $vTcl(grab,startY)}]
    set newX $vTcl(w,x)
    set newY $vTcl(w,y)
    set newW $vTcl(w,width)
    set newH $vTcl(w,height)
    set orientation [$widget cget -orient]
    switch $orientation {
        horizontal {
            switch $handle {
                e {
                    set newW [expr {$vTcl(w,width) + $deltaX}]
                    place $widget -x $newX -y $newY -width $newW
                }
                w {
                    set newW [expr {$vTcl(w,width) - $deltaX}]
                    set newX [expr {$vTcl(w,x) + $deltaX}]
                    place $widget -x $newX -y $newY -width $newW
                }
                s {
                    set newX [expr {$vTcl(w,x) + $deltaX}]
                    set newY [expr {$vTcl(w,y) + $deltaY}]
                    place $widget -x $newX -y $newY -width $newW
                }
            }
        }
        vertical {
           switch $handle {
                n {
                    set newH [expr {$vTcl(w,height) - $deltaY}]
                    set newY [expr {$vTcl(w,y) + $deltaY}]
                    place $widget -x $newX -y $newY -height $newH
                }
                w {
                    set newX [expr {$vTcl(w,x) + $deltaX}]
                    set newY [expr {$vTcl(w,y) + $deltaY}]
                    place $widget -x $newX -y $newY -height $newH
                }
                s {
                    set newH [expr {$vTcl(w,height) + $deltaY}]
                    place $widget -x $newX -y $newY -height $newH
                }
            }
        }
    }

    set vTcl($widget,x) $newX
    set vTcl($widget,y) $newY
    set vTcl($widget,height) $newY
    set vTcl($widget,width) $newY


    #   $classes($vTcl(w,class),resizeCmd) $widget $newW $newH $handle
    update
    vTcl:place_handles $widget
}

proc vTcl:grab_resize {absX absY handle {ctrl 0}} {
    global vTcl classes
    set widget $vTcl(w,widget)
    if {[info exists ::widgets::${widget}::locked] &&
        [set ::widgets::${widget}::locked]} {
        return
    }
    set vTcl(w,didmove) 1
    set class [vTcl:get_class $widget]
    if {$class == "TSeparator"} {
        # So many special cases I will do i completely separately.
        vTcl:resize_tseparator $widget $absX $absY $handle
        return
    }
    set X [vTcl:grid_snap x $absX]
    set Y [vTcl:grid_snap y $absY]
    set deltaX [expr {$X - $vTcl(grab,startX)}]
    set deltaY [expr {$Y - $vTcl(grab,startY)}]
    ## Can we resize this widget with this handle?
    set can [vTcl:can_resize $handle]
    if {$can == 0} { return }     ; ## We definitely can't resize.
    set newX $vTcl(w,x)
    set newY $vTcl(w,y)
    set newW $vTcl(w,width)
    set newH $vTcl(w,height)
    switch $handle {
        n {
            if {$can == 4} { return }
            set newY [expr {$vTcl(w,y) + $deltaY}]
            set newH [expr {$vTcl(w,height) - $deltaY}]
        }
        e {
            if {$can == 3} { return }
            set newW [expr {$vTcl(w,width) + $deltaX}]
        }
        s {
            if {$can == 4} { return }
            set newH [expr {$vTcl(w,height) + $deltaY}]
        }
        w {
            if {$can == 3} { return }
            set newX [expr {$vTcl(w,x) + $deltaX}]
            set newW [expr {$vTcl(w,width) - $deltaX}]
        }
        nw {
            if {$can == 1 || $can == 2} {
                set newX [expr {$vTcl(w,x) + $deltaX}]
                set newW [expr {$vTcl(w,width) - $deltaX}]
            }

            if {$can == 1 || $can == 3} {
                set newY [expr {$vTcl(w,y) + $deltaY}]
                set newH [expr {$vTcl(w,height) - $deltaY}]
            }
        }
        ne {
            if {$can == 1 || $can == 2} {
                set newW [expr {$vTcl(w,width) + $deltaX}]
            }

            if {$can == 1 || $can == 3} {
                set newY [expr {$vTcl(w,y) + $deltaY}]
                set newH [expr {$vTcl(w,height) - $deltaY}]
            }
        }
        se {
            if {$can == 1 || $can == 2} {
                set newW [expr {$vTcl(w,width) + $deltaX}]
            }

            if {$can == 1 || $can == 3} {
                set newH [expr {$vTcl(w,height) + $deltaY}]
            }
        }
        sw {
            if {$can == 1 || $can == 2} {
                set newX [expr {$vTcl(w,x) + $deltaX}]
                set newW [expr {$vTcl(w,width) - $deltaX}]
            }

            if {$can == 1 || $can == 3} {
                set newH [expr {$vTcl(w,height) + $deltaY}]
            }
        }
    }

    set class [winfo class $widget]
    set parent [winfo parent $widget]
    set parent_class [winfo class $parent]
    # Detect that this is a window pane using parent_class above.
    # Then don't place it just adjust the appropiate sashes.

    if {$parent_class == "TPanedwindow"} {
        vTcl::widgets::ttk::panedwindow::resizePane \
            $parent $widget $newW $newH $handle


        # Do the pane thing
        # Pick up facts about the paned window.
        set panes [$parent panes]
        set pane_index [lsearch $panes $widget]
        set o [$parent cget -orient]
        set no_panes [llength $panes]
        set no_sashes [expr $no_panes -1]
        if {$pane_index > 0} {
            update idletasks
            if {$o == "horizontal"} {
                $parent sashpos [expr $pane_index - 1] $newX
            } else {
                $parent sashpos [expr $pane_index - 1] $newY
            }
        }
        if {$pane_index < [expr $no_panes - 1]} {
            if {$o == "horizontal"} {
                $parent sashpos $pane_index [expr $newX + $newW]
            } else {
                $parent sashpos $pane_index [expr $newY + $newH]
            }
        }
        update idletasks

    } elseif {$class == "Scale" || $class == "TScale"} {   # Rozen
        set o [$widget cget -orient]
        if {$o == "horizontal"} {
            $widget configure -length $newW
        } else {
            $widget configure -length $newH
        }
        place $widget -x $newX -y $newY



    } else {
        # This is the normal action for all widgets except
        # paned windows or scale widgets.
        place $widget -x $newX -y $newY -width $newW -height $newH \
            -relwidth 0.0 -relheight 0.0 ;# Added for 'Fill Container' 5/30/16
        #set vTcl($widget,height) $newH             ;# Rozen 2/15/16
        #set vTcl($widget,width) $newW              ;# Rozen 2/15/16
    }
    # Rozen
    set vTcl($widget,x) $newX
    set vTcl($widget,y) $newY



    $classes($vTcl(w,class),resizeCmd) $widget $newW $newH $handle
    vTcl:place_handles $widget
} ;# End of vTcl:grab_resize


## Default routine to adjust the size of a widget after it's been resized.
## This routine can be overridden in the widget definition.
proc vTcl:adjust_widget_size {widget w h {handle {}}} {
    # @@change by Christian Gavin 3/19/2000
    # added catch in case some widgets don't have a -width
    # or a -height option (for example Iwidgets toolbar)
    if {![winfo exists $widget]} { return }
    set class [winfo class $widget]
    #catch {
        switch $class {
            Label -
            Entry -
            Message -
            Spinbox -
            Scrollbar {
                $widget configure -width $w
            }
            TLabelframe {
                set parent_window [winfo parent $widget]
                set parent_class [winfo class $parent_window]
                    if {$parent_class == "TPanedwindow"} {
                        vTcl::widgets::ttk::panedwindow::resizePane \
                               $parent_window $widget $w $h $handle
                    } else {
                        $widget configure -width $w
                        $widget configure -height $h
                    }
            }
            Scale -
            TScale {
                set orient [$widget cget -orient]
                if {$orient == "vertical"} {
                    $widget configure -length $h
                } else {
                    $widget configure -length $w
                }
            }
            TSeparator {
                # Don't do anything
                set orient [$widget cget -orient]
                if {$orient == "vertical"} {
                    place configure $widget -height $h
                } else {
                    place configure $widget -width $w
                }
            }
            TPanedwindow {
                # This block has been replaced by ResizeCmd in tpanedwindow.wgt.
                set panes [$widget panes]
                set last_pane [lrange $panes end end]
                vTcl::widgets::ttk::panedwindow::resizeCmd \
                    $widget $last_pane $w $h $handle
            }
            TCheckbutton -
            TRadiobutton -
            TButton -
            TEntry -
            TLabel {
                $widget configure -width $w
            }
            TProgressbar {
                $widget configure -length $w
            }
            Treeview {
                $widget configure -height $h
            }
            default {
                $widget configure -height $h
                $widget configure -width $w
            }
        }
        #}  ;# End of catch
    update
    # @@end_change
}

## Can we resize this widget?
## 0 = no
## 1 = yes
## 2 = only horizontally
## 3 = only vertically

## classes($class,resizable)
## 0 = none
## 1 = both
## 2 = horizontal
## 3 = vertical

proc vTcl:can_resize {dir} {
    # determines whether a widget can be resized or not.
    global vTcl classes
    set c [vTcl:get_class $vTcl(w,widget)]
    # Added the orientation stuff because the Scale and TScale can be
    # resized only along the 'long' dimension; i. e., it is dependent
    # on orientation.
    if {$c == "Scale" || $c == "TScale" || $c == "TSeparator"} {
        set orient [$vTcl(w,widget) cget -orient]
        if {$orient == "vertical"} {
            return 3
        } else {
            return 4
        }
    }
    # Resizable is set in the wgt file.
    set resizable $classes($c,resizable)
    ## We can't resize at all.
    if {$resizable == 0} { return 0 }

    ## We can resize both.
    if {$resizable == 1} { return 1 }

    switch -- $dir {
        e  -
        w  {
            return [expr $resizable == 2]
        }

        n  -
        s  {
            return [expr $resizable == 3]
        }

        ne -
        se -
        sw -
        nw {
            if {$resizable == 2} { return 2 }
            if {$resizable == 3} { return 3 }
        }
    }
}

proc vTcl:lock_widget {} {
    # Entered when a user locks a widget using the context widget.
    # The entries in the context widget are set in page.tcl/
    global vTcl
    set target $vTcl(w,widget)
    namespace eval ::widget::${target} {
        variable locked
    }
    set ::widgets::${target}::locked  1
    set vTcl(w,place,locked) 1
    vTcl:init_wtree
    vTcl:prop:update_attr
}

proc vTcl:unlock_widget {} {
    # Entered when user unlocks a widget using the context widget.
    global vTcl
    set target $vTcl(w,widget)
    set ::widgets::${target}::locked 0
    set vTcl(w,place,locked) 0
    vTcl:init_wtree
    vTcl:prop:update_attr
}

proc vTcl:copy_lock {target} {
    # Called when opening a project that contains locked widgets.
    namespace eval ::widgets::${target} {
        variable locked
    }
    set ::widgets::${target}::locked  1
}
