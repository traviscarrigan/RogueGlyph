package require PWI_Glyph
pw::Script loadTk

pw::Application reset

set playerSprite "player.pw"

set left  0
set right 0
set up    0
set down  0

bind all <KeyPress-Left>  {set left 1; set right 0; set up 0; set down 0}
bind all <KeyPress-Right> {set left 0; set right 1; set up 0; set down 0}
bind all <KeyPress-Up>    {set left 0; set right 0; set up 1; set down 0}
bind all <KeyPress-Down>  {set left 0; set right 0; set up 0; set down 1}

bind all <KeyRelease-Left>  {set left  0}
bind all <KeyRelease-Right> {set right 0}
bind all <KeyRelease-Up>    {set up    0}
bind all <KeyRelease-Down>  {set down  0}

proc drawBoard {width height} {

    proc createLine {pt1 pt2} {
    
        set line [pw::Curve create]
    
        set seg [pw::SegmentSpline create]
            $seg addPoint $pt1
            $seg addPoint $pt2

        $line addSegment $seg

        return $line

    }

    set bottom [createLine "0 0 0"            "$width 0 0"      ]
    set right  [createLine "$width 0 0"       "$width $height 0"]
    set top    [createLine "$width $height 0" "0 $height 0"     ]
    set left   [createLine "0 $height 0"      "0 0 0"           ]

    set lines [list $bottom $right $top $left]

    set collection [pw::Collection create]
        $collection add $lines
        $collection do setLayer 999

}

proc loadSprite {name layer} {

    pw::Display isolateLayer 0

    set cwd [file dirname [info script]]

    set mode [pw::Application begin ProjectLoader]
        $mode setAppendMode true
        $mode initialize [file join $cwd $name]
        $mode load
        $mode end

    set ents [pw::Layer getLayerEntities 0]

    set collection [pw::Collection create]
        $collection add $ents
        $collection do setLayer $layer

    pw::Display showAllLayers

    return $ents

}

proc unloadSprite {name} {

}

proc translate {obj dir} {

    set mode [pw::Application begin Modify $obj]
    pw::Entity transform [pwu::Transform translation $dir] [$mode getEntities]
    $mode end

}

proc move {obj mag} {

    global left right up down

    if {$left}  {set dir "-$mag 0 0"; translate $obj $dir}
    if {$right} {set dir "$mag 0 0";  translate $obj $dir}
    if {$up}    {set dir "0 $mag 0";  translate $obj $dir}
    if {$down}  {set dir "0 -$mag 0"; translate $obj $dir}

    focus -force .
    pw::Display update

    after 75 move [list $obj] $mag

}

drawBoard 160 160
set player [loadSprite $playerSprite 10]
pw::Display setShowBodyAxes false
pw::Display resetView -Z
move $player 16
