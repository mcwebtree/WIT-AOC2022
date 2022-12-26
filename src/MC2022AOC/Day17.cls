Class MC2022AOC.Day17 Extends %RegisteredObject
{

/// Current shape
Property CurrentShape As %Integer;

Property HighestRow As %Integer;

Property CurrentMove As %Integer;

Property NumMoves As %Integer;

Property aMoves [ MultiDimensional ];

Property aGrid [ MultiDimensional ];

Property lShapeLocn As %List;

ClassMethod runGame(intLive As %Integer = 1, intShapes As %Integer = 1, intVerb As %Integer = 0) As %Integer
{
	S obj17 = ##class(MC2022AOC.Day17).%New(intLive)

    f i=1:1:intShapes
    {
        D obj17.nextShape()
        D obj17.addShape()
        
        i intVerb>-1 d obj17.DrawGrid() w !

        s dropMoved=1
        while dropMoved=1 {
            s obj17.CurrentMove=obj17.CurrentMove+1
            S:obj17.CurrentMove>obj17.NumMoves obj17.CurrentMove=1
            s pushMoved=obj17.moveShape(obj17.aMoves(obj17.CurrentMove),intVerb)
            w:intVerb>0 "Shape push ("_obj17.CurrentMove_"-"_obj17.aMoves(obj17.CurrentMove)_"): "_pushMoved
            s dropMoved=obj17.moveShape("D",intVerb)
            w:intVerb>0 " Shape drop: "_dropMoved,!
                    
            d:intVerb>1 obj17.DrawGrid()
        }
        w:intVerb>0 "Shape in position. Highest Row: "_obj17.HighestRow,!
        i intVerb>-1 d obj17.DrawGrid() w !
    }

    D:intVerb>0 obj17.DrawGrid()

    W "Highest Row: "_obj17.HighestRow,!
    
    w " Top: "_obj17.findTop()

	Q obj17.HighestRow
}

Method moveShape(sDir As %String = "D", intVerb As %Integer = 0) As %Integer
{
    S retVal=1
    S newLocn=""
    
    // generate the new location
    f i=1:1:$LL(..lShapeLocn)
    {
        s intX=$LI($LI(..lShapeLocn,i),1)
        s intY=$LI($LI(..lShapeLocn,i),2)
        I sDir="D" {
            S intNX=intX
            S intNY=intY-1
        } elseif sDir="<" {
            S intNX=intX-1
            S intNY=intY
        } elseif sDir=">" {
            S intNX=intX+1
            S intNY=intY
        }

        // Any fail is an invalid move so fail
        I (intNY)<1 s retVal=0 w:intVerb>1 "  Y<1 fail  " q
        I (intNX)<1 s retVal=0 w:intVerb>1 "  X<1 fail  " q
        I (intNX)>7 s retVal=0 w:intVerb>1 "  X>7 fail  " q
        I $G(..aGrid(intNX,intNY),".")="#" s retVal=0 w:intVerb>1 "  Hit Rock fail  " q
        S $LI(newLocn,i)=$LB(intNX,intNY)
    }

    I retVal=1 { // Make the move
        D ..clearShape()
        S ..lShapeLocn=newLocn
        D ..addShape()
        //S:sDir="D" ..HighestRow=..HighestRow-1
    } else {
        I sDir="D" D ..addShape("#")
    }

    //d ..DrawGrid()

    q retVal
}

Method %OnNew(intLive As %Integer = 1) As %Status
{
	I intLive=1
	{ d ..initLive() }
	ELSE 
	{ d ..initTest() }

    S strMoves=^AOCD17

    S ..CurrentShape=0
    S ..CurrentMove=0
    s ..HighestRow=0
	
    // init the control array
    S ..NumMoves=$L(strMoves)
	for intChar=1:1:..NumMoves {
        S ..aMoves(intChar)=$E(strMoves,intChar,intChar)
	}

    F intX=1:1:7 {
        F intY=1:1:4
        {
            S ..aGrid(intX,intY)="."
        }
    }


    Q $$$OK
}

Method findTop() As %Integer
{
    //d ..DrawGrid()

    s retVal=0
    s iYMax="0"
    F iCol=1:1:7
        { 
            s tmpMax=$O(..aGrid(iCol,""),-1) 
            I tmpMax>iYMax s iYMax=tmpMax 
        }
    w "Grid Height: "_iYMax
    F iY=iYMax:-1:1
    {
        F iX=1:1:7
        { 
            I $G(..aGrid(iX,iY),".")="#" s retVal=iY q 
            I $G(..aGrid(iX,iY),".")="@" s retVal=iY q 
        }
        I retVal>0 q
    }
    w "  Top at "_retVal,!
    q retVal
}

Method nextShape(intVerb As %Integer = 0)
{

    S sBot=..findTop()+4
    //S sBot=..HighestRow+4

    S ..CurrentShape=..CurrentShape+1
    I ..CurrentShape>5 S ..CurrentShape=1
    w:intVerb>-1 "Current Shape: "_..CurrentShape_" at "_sBot,!
    if ..CurrentShape=1 {
        //####
        S ..lShapeLocn=$LB($LB(3,sBot),$LB(4,sBot),$LB(5,sBot),$LB(6,sBot))
        S ..HighestRow=sBot
    } elseif ..CurrentShape=2 {
        //.#.
        //###
        //.#.
        S ..lShapeLocn=$LB($LB(4,sBot+2),$LB(3,sBot+1),$LB(4,sBot+1),$LB(5,sBot+1),$LB(4,sBot))
        S ..HighestRow=sBot+2
    } elseif ..CurrentShape=3 {
        //..#
        //..#
        //###
        S ..lShapeLocn=$LB($LB(5,sBot+2),$LB(5,sBot+1),$LB(3,sBot),$LB(4,sBot),$LB(5,sBot))
        S ..HighestRow=sBot+2
    } elseif ..CurrentShape=4 {
        //#
        //#
        //#
        //#
        S ..lShapeLocn=$LB($LB(3,sBot+3),$LB(3,sBot+2),$LB(3,sBot+1),$LB(3,sBot))
        S ..HighestRow=sBot+3
    } elseif ..CurrentShape=5 {
        //##
        //##
        S ..lShapeLocn=$LB($LB(3,sBot+1),$LB(4,sBot+1),$LB(3,sBot),$LB(4,sBot))
        S ..HighestRow=sBot+1
    }
     w:intVerb>0 "Highest Row: "_..HighestRow,!
}

Method clearShape()
{
    F i=1:1:$LL(..lShapeLocn)
    {
        S intX=$LI($LI(..lShapeLocn,i),1)
        S intY=$LI($LI(..lShapeLocn,i),2)
        S ..aGrid(intX,intY)="."
    }
}

Method addShape(sChar As %String = "@")
{
    F i=1:1:$LL(..lShapeLocn)
    {
        S intX=$LI($LI(..lShapeLocn,i),1)
        S intY=$LI($LI(..lShapeLocn,i),2)
        S ..aGrid(intX,intY)=sChar
    }
}

Method DrawGrid(intLimit As %Integer = 10)
{
    
    s iYMax=""
    s iYMax=$O(..aGrid(1,iYMax),-1)
    s intIters=0
    F iY=iYMax:-1:1
    {
        W $J(iY,5)_ " |"
        F iX=1:1:7
        {
            W $G(..aGrid(iX,iY),".")
        }
        w "|",!

        s intIters=intIters+1 
        I intIters>intLimit Q 
    }
    // w "+-------+",!

    //w "Grid top at "_iYMax,!
}

Method initTest()
{
 k ^AOCD17 
 S ^AOCD17=">>><<><>><<<>><>>><<<>>><<<><<<>><>><<>>"
}

Method initLive()
{
 k ^AOCD17
 S ^AOCD17=">>>><>>><<<<>>><<<<>><<<<>>>><<<<>>>><>>><<>><>>><<<<>><<<>>><><<<<>>>><<>>>><<<<>>>><>><<>>>><<>><<<>>>><>>><<>><<>><>>><<<<>>><<>>><<>><<<>>><><<<>>>><<<>><<<<>>>><<>>>><>>><>><<<>>>><<>>><><<<<>><<<<>>><<<<>>><<<<>>><>>><<<>>><>>>><>>>><<<<>><<>>>><<>>><<<>>><>>><><<<<>>>><><>>>><<><<<><<<<><><<>><<<<>>><<>>><<<<>>>><<><<<<>><>><<><<>>><<<>><<<><<<<>><<><<<<>>>><>><<<>>><><<><>>><<<<><>><<>>><<>>>><<><<>><<>><<<<>>>><<<>>>><><<<<>>><<>>><><<<><<<><<<><<>>><<<>>><<<<>>>><<<<>>><>>><>>>><<<>>><<<<><>>><<><>><<>><<<<>>>><<<<>>><<>>>><<>><<<<>>><<<<>>>><><<<<>><<<>><<<><<<><<<<>>><<<<>>>><><<<>>>><><<<<>>><<<<>>>><<<>><>>><<<>><><<<>>>><<<><<<>><<<<>><<<<>>>><<<>><<<>><<<<><<<<>><<>><<<>>><<<<>>>><<<><><>><<<<>>>><<<<><<<<><<>>>><<<>><>>>><>>><<<<>>><<>>>><<<><<<>>><<>>>><<>><<<<>>>><<<>><<<><<>>>><<>>>><<<<><>>>><<<>>>><<>><<<<>><<<<>><<<<>>><>>><<<>>>><<>>><<<>><<<<>>>><>><>>><>>>><<<><<><<<>><<<>>><<<<>>><<<<>>>><<<><<<>>><><>>><<<<>>><<<>>><<<>>>><><<<<>><<>><<<<>>><>>><<<>>><>><>>><><<<<>><<>><<<><>>><<><<<>>><<><<>><<<<><>>>><>>>><<<<><>><<>><<<<><><<<>>><<>><<>><<<>><<<<><<>>><>>><><<<>>><<<<>>><<><<<<>>><<<>>>><<>><<<>><<<<>>>><<>><<>>><><>>><>><<<>><><<>>><>><<>><<><<><<<>>>><<<>>><<<<>><<<<>>>><>>>><>>><<<<>><<<>>>><<<>>><<>><>>><>>>><<<<>>>><<<>>>><<<<>><<>>>><>><<<>>><<<><<>>>><<<><<<><<>>><><<<><<<>>>><<>>>><<<<>>>><<<<><<<><<<<>>>><<<<>>><<<>>>><<<><>>><>><<<<>>>><<<><<<<>><<<<>>>><><<<<>><>>><>>>><<<<>><><><<<>><<>>><<<><<<<>><>>><<>>>><<<<>>><<<>><<<<>><<<<>>>><>>><<>>><<<<>><<<<><<>><<<>>>><<<<>>><<<>><>><<>>>><<<>>>><>><>><<<>>>><>>>><<<<>>>><>><><><<<>>>><<>>>><<<><<<><>>><<<><<<<><><<<>>>><<<<>>>><<<<><<><<>>><<>>><<><<<><<<>><><>>>><<<><<>><<>><<<<>>><><<<>>>><>>>><<<>>><>>>><<<>>><<>>>><<<<><><<<>>>><<<<>><><<>><<<<>>><<<<><<<><>>><>>><>>>><>>><<<<>>><<<<><<><<<<>>><<<<>>>><><<<<><<<>><<<>><<>>>><<<><<<>>><<<>>>><<<<>>><>>><<>>>><>><<<><<<>><<<<><<<<>>><<<><><<<>><<<<>><>><>>><<<>>><><<<<><<<>><<<<>>>><<<>>>><>><<>>><<<>>>><<<<>>>><<<<><<>>>><<<>><<<<>><<<>>><<>>>><><<<<>>>><><<>>>><<><<<<>>><>><<<><<>>><>><<>><<<<><<<<>><<><<<><<<<>>>><<<>>>><<<<>><<>>><>>>><><<>><>>><<><>>><<<<>>>><<<<>>><<<><<<<>>><<<><>>>><<<<>>>><<<<>><<>><<<>>><>>>><<>>><>><<>><><><<<<>>>><<><<<>>>><<<>>><>><<>>><<<<>>><>>>><<>><<<<>>><<<<>><><<>>>><><<<>><<<>>><<<<>>><<<>><>>>><>>><<<><<<<>>>><<<<>><<>>>><>>>><<>><>>>><<>>><<><<>><<<<>><<<<>>><>>>><<<<>>><<<><>>>><<<>>>><>>><>><<<<>>><<<<>>><<>>><>>><>>>><>>><<<><<<><<<>>><<<>>>><<<<><<<<>><<<>>>><<>>>><>>><<<><>>>><<>><<<>>>><>>>><<<><<<<><><<>><<>><>>><<>>><>>><<>>>><<<<>>>><<<<>>><<<>>>><<<>><<>>>><<>>><<<>>><<<<><<<<>>><<>>>><<>>><<<<>>><<<<>>><<<<>>>><<<>>><<<><<>><<>><<><>>><<<>>><<>>>><>>>><>><><<>><<>>><<>>><<<>>><<<<>><<>>><<<>>><<<>><<<<>>><<<<>>><<>>><<<>>>><<<><><<>>><>><<<>>><<<>><<<><<<>><>><<<<>>><<<<>>><>>><<<<><<>>>><<><<<><<<>><<>>><<<<>><><<<>>>><<<><<><>>><><<><<<>>>><<>>><<<<>><<<<>><<<>>>><<<<><>>>><<<<>><<<>>>><<>>>><<<<>>>><>><<<<><>><<<<>>>><<<<>><<<>>><<>>>><>><<<<>><>>>><<<>>>><<<<><<<<>>>><<>>><<>>><<<<>>><<<><><<>>><<<>>>><<<<><>>><<<>>>><<>>>><<<>><<<>>>><>>><<<<>><><<<<>><<<<>><<>><<<>>><<><<<><<>>><<><<>><><<><<>>><<<<>><<<>><<<<><<<>><<<<>>>><<<><>>><<>><<<<>>><<<>>>><<<<>>><<>>>><<<>>>><<<<>><<<>>>><<<>><<<>>><<>>>><>><><<>>><<<<>>><<<<>>><>>><<>>>><<<<>><<<<>>><<<><<<><<><<<>>><>>>><<<><<>>>><<<>>><>><<>><<<<>><><><<>>>><><>>>><<<<>>><<>>>><>>>><<>>><<<><<<>><<>>><><>><<<><<<><>><>>>><<<<>><<<>>>><<>>><>><<>><<<>><<<>>>><>><<<>>><<>>><<<>>><<<<><>><<>>>><<><<><><<>>><><<<<>><<>><<<>>>><<<>>>><<<<>>><<>>>><<<<><>>><>>><<>><<<<>>><<<<>><>>>><<<<>>><<<>><<<<>><<<<>>><<<<>>><<<>><>><>><<>>><<<<>><>><>>><<>>><<>><<>>><<<<>>>><<<>><<<>>><><<>>><<<<>>><>><><<<><<<<>>>><<<<>>>><><<<>>>><<<<>>><>><<>><>>>><<>>><<>><<<><<<>>><<>>>><>>><<>>>><<<>>>><<>><<>>><>>>><<>>><<>><<<<>><<<<><>>>><<<<>><<>><<<<>>>><<>>><<<<>>><><<>><<><<<>><<<<>><>>>><<<>><<<>>>><<><<<<>>>><<<>><<<><><<<>>>><<<>>><<>>><<<>><<<<>>>><<<>>>><<<><>>><<><<<<>>><<<>>>><<>><>>>><<<<><<>><<>>><>>>><<>>>><><>>>><<<><<<>>>><>>>><<>>>><<>>>><><<>><<><<>>><<<<><<<<>>><<>>><<<>>><>>><<>>>><>><<<>><>>><<>><<<>>>><>>><<<<>>>><<>>>><<<>><<<>><<<<>>><<>>><<>><<>><>>><>>>><<>><>>>><<<<>><>>><<<>><<<><<>>>><>>><<>>><<><<<<>>>><<<>>><<<<>>><>><<<<>>><<<<>><>><<<<><<>><<<<>>>><><<<<>>><<<>>><>>>><<>>>><<<<>>><<>>><<>>><>><<<><><>>>><<>><><<>>><>><>>><<>>>><<<<>>><<<>><<<>>><<<<>>><>>>><>>><>>><<>>>><<<<><<<<>>><<>>>><<<<>>><>>><>><<<<>>><<>><<<<><<<<>><<<<>><<<<>><<>>><<><<<>>>><<<<><<<<>>>><<<<>><<<<><<<<>>>><<><<<<>>><<<<>>>><>>>><<>><<<>>>><<<><<<<>><<<>><<<>><><>>><><<><<><<<><<<>>><>>>><<>>>><><>>>><<<>>>><<<>>>><<><<><<>><<<<><><>><>>><<>><<<<>><<>>><>>>><<>>>><>>>><<<<>>>><<<<>>><>>><<>><<<>>><<>><<<>><<<>>>><<><<><<<<>>>><<<>>>><<><<<<>>>><<<><<<>>>><<<><<>>><><<>>><<<<>><<>><<<>>><<<<>>><<<><>>><<<<>>><<<<>><>>>><<<<><<<<>>><>>>><<<<>><<><<<><<>><<<<>><<>>><<<<>>><<<>>><<<>>>><>>><>>>><<>>>><<>><<>>><<><<<>><<>><>>><>><<<<><>>>><<>><<<>><<><><<<>>><<<<><<>>>><<<>>>><<<>><<<>>><<>>><<<<>>><>>>><<<>>><<>><<<>><<<<><<<>><<<<>>><>>>><><<<>>>><<<<>>>><<>><>>>><<<<><<<<>>>><<<>>>><><>>><<>>><<<<>>>><<>>><<>>>><<>>>><<>>><<>><<<<>>>><<<<>>><<<>><><>><>>><<<>><<<>><<>>><<<<>>>><<<>>><><<<>>><<<<>>>><<>>><<<<>>>><<>>>><<>>>><<><>>><<<<>>><<<<>>>><<<<>>><<><>><>>>><>>>><<<<>>><<<<>><<<<><<<>>><<<>>><>>><>>>><<<>>><<<<>>>><<<<><<><<<<>><>>><<<>><<>><<>>>><<<<>><<>><<<>><<<>>><<<<><<><<<>>><<<><<<<>><<><<<<>><<<>>>><<<>>><<>><<>>>><<<><<>><>>>><<>>><<<<><<<<><<<<><<<<>>><<<<><<>>><>>>><<<<>>><<<>>>><>>>><<>><>><<>>><>><>>>><<<<>>><<>>><<<<>>>><>><<<<>>><>>>><<<>><<>>>><<<<>><<><>>>><<<>>>><<>><<>>>><<<<><<<<>>><<><<<><<><<>>><<<<>>><>>>><<<>>>><<><<<<><>>><<<<>><<>><<>>><<>>><<<>><<<<><>>><>>>><>>>><<<<><<<<>>>><>>><<<<>>><<<<>>><>><<>>><>><>><<<<>><>>>><<<>>><><<<<>>>><<<<><<<><<><<<<>>><<<<><<>>><<<<>>>><<<<>>>><<<><<>><>>>><<<>><<>>><<<<>>><<<<>>>><<>>><<<>>>><><<><<<<>><<<<>><<<>>><<>>>><><>>><<<<><<>>>><>>><<><>>><>>><<>><<<<><<<<><<><<<<>><<<>>>><<>>>><><<><<>>>><>><<<>>><<<>><>>>><<<<>>>><<>><<<><>>><<<><>><<<><><>><<><<><<>><<<<><<><>>><<<<><<<>>>><>><<<>>><<<>>><<<>>>><<<>>><<><>>>><<<<>>>><<<>><<<<>>>><>><<<><<<><<<><<><<><<<>>><<>>><>><>>>><>>>><<<<>>>><<>><<<<>>><<<>>>><<><<<<>>>><><<<>><<>><>><<<>><>>>><<><>>><<><<>>><<<>><>><<>>><<<<>>>><<<<>>><<<<><<<>>><<><<<>><>><<<<>>>><<><<><<<>>><<<<>>>><<><<<><<>><<<<><<<<>>><>><<<><<><<<<>>><<>>><<<<>><<<><>><<<><<<>>>><<<<><<<><<<><>><><<<><<<<><<>><<<<>>>><<<>>><<>>>><<>>><<><>>><<><<<><>>>><<><<><>>><>><<<<>>>><>>><<<><>>>><<>>>><>><<<<>><<<>>>><<>><<<>>>><<<>><<<<>>><<<>>><<<<>>>><><>><<<<>><<>>><<<<>><<<>><<>>>><>><>>><<<>>>><<><>>><<<><>>>><<<>><>>>><<>>>><<<<><<>>>><>><<<>><<>>><<<<>>><<<<>>>><>>><<<>><<>>><<<>><<<><<<<><<<><>><<<<>>>><<<<>>>><>>>><>>>><<>><<><<<<><<<><<>>><>>>><<<>><<<><<<>>>><<<>>><<<>>><<<>>><>>><<<>>><>>><<>><>><<<<>>><<<><<>>><<<>><<<<>><<>><<<><<<>>>><>><<>>><<>><>>>><<<<><<>>>><<<>>><>><<<>>><<<<>>>><<<<>><<>><<<<>>><<<<>>><<<<>>><<>>><<>>><><>>><<<<>><>><<>>><<<>><<<><<<>>>><<><<<>><<<<>><<<<>>><>><><<<<><<<<>>><>>><<>><<>>>><<<<>>><>><<>>><>>><>><<<>>>><<<><><<<<>><<<>>>><<>><<>>>><<>>><>>>><<><>><<<<>><<>>><>>><<><<<><<<<>>><><<><<<><<<<>>>><<<>>>><<<<><<<>><<<<><>>><<>>>><<<>>><>>>><<><>>><<<>><<>>><<<<>>>><>>>><<<<><<<<><>>>><<<<>>><>>><<>>><<<>><<><<<>>><>>><<>>><<<<>><<>>>><<<<><<<><<<<>><<<<>>><<<><><<>>><>>><>>><<<<><>><<<<>>><<>>><>>>><<>>>><<>>>><<<<>>>><<<<>>><<>><<<<>>>><><<><><<<<>>><<<<>>><<<<><>><<>>>><>><<<>>><<><<>><<<<>>>><>><<>><<<><<<><<<<>>>><<><<>>>><<<<>>><<<<>>><>>>><<>><>><<><>><<>>><<<>>>><<>>>><<>>><<<<>>><<>>><><<<<><<<><<>><<<<>>><>>><<<>>>><<>>>><<<<>><>><<<>><>>><<<>>><<<>>>><>>><>><<<<>>>><><<<>>>><>><<<<>><<<<>>><><<<<>>><<>>><<>>>><<<<>><<>>><<><>><>>><<<<>><<<>><<<><<>>>><<><<<<><>><<>>><<<>><>>>><><<>>><<<<>>>><<><<>>><<<<><<>>>><<<<><<<><<>><><<<<>>><<>>>><><>>><<<>><<<<><<<>><<>>><<<>><<><<<>>>><>>><<><<>>><>>>><<<><<<<><<<>>><<<<>>><<<>><<<<>>>><<<><<<<>>>><><<<>><<>><<<<>>>><>><>>>><<<<>>><>>>><<<<><<<<>>>><<><>>>><<<><><>>>><<<>>>><<>>><<<><<>><<<><<<<><<<><<>><<>>><<<><<<<>><<<<><<<><<<><>>><<<<><<<<><><>><>><<<>><<<><<<>>>><<<>><<<>><<><><<<<>><>>>><<<>>>><>>><<>>>><<<>><<>><<<<><<<><>><<<>>><<<>>><<<<>><<<>>>><<>>>><>><<<<>><><<<>>><>><>>><<<<>>><<<<>>><<<><<<<>><<>>><<<><<<>><<<<>>><<<<><<>>>><<<>>><<<><<<<>>>><<>>><<>><<><>><<<<>>>><<<<>>>><<<<>>><<<<>><<>><<>><<<>><>><<<><<<<>>>><><<><<<><>>>><<<<>>><<>>>><<<>>>><<<<>>>><<<<>>>><<<>><<<<>><<<><<<>>>><<<<>>>><>><<<<>>>><<<>>><<>>>><<>>><<>>>><<>>><<<<>>>><>><<<<>>><<>>><>>><<<<>><<<>>>><<<<>>><<<>>><<<<>>>><<<<><<<<>>><<>>><>>><<<>>>><<>>>><<<>>>><<>>>><<>>><<<>>><<<<><>><<<<>>>><<<<>>><>>>><><>><>><>>><<<<>><>><<>>>><<<<>>><>>><<<>>><<>><<<<>><<>>>><<<>><>><<>>>><<<>>>><<>>>><><>>>><<<<><<<>>><<<<>>><<<>>>><<<<>>>><<<<><<>>><<>>><<<<>>><<<><<><>>><<<>><<>>><<<>>><<<<>><<<<>>><>>><<<<><><<><<<<><>>>><>><<<<>>>><<<<><<>>>><<<<>><<<<>>><<<<>><<<>>>><<<>>><<>><<<<>>><<<<>>>><<>>><<<<><<<>><<<<>><>>>><<<>>>><<<<>>><<<>><><>>><<>><<<>>><<<<>>>><<>>>><<>><<<<>>>><<<>>>><<<><<<<><<<<><<<<>>>><<<>>><<<<>>><<<>>>><<<<>>><<<<>>>><<<<>><<><<<>>><>>>><>>>><<<<><<<>>>><<>><<><<<>>>><<<>>><<<<>>>><<><>>><><<<<>>><<<<>>>><<<>>>><<>>><<<>><<<<>><<<>>>><><<><<<>>>><<<>><>><<<<>>><<<>>><<<<>>><<<<>>>><><<<><>>><>><<<>>><<<<><<<>>><<>>>><><<>>>><<<>>><<<><>>><<<<><<<<>>><<><>><<<<><><<<><<<<>>><<<>>>><>>><<>><<<>><<<>>>><<<>>>><<>>><<><<<><><><<<>>><<>>><<>>><<<<><<>>>><<<><>>><><<><<>>><<<>>><<<<>>><<<<>><<<<><>>>><<>>><<>><>>><<>><>><<><<<<>><>><<<<>>><<>>><<<<>><<<<>><<><<<><<<<>>>><<<<>><<>>><<<>><<<><<<>><>>>><<<>>>><><<><<<<>><<<<>>><<>>>><<<><>>>><<<>>><<<>><<<>>>><<<<>><<><<>>>><<<>><<<>>><<><<<>>><<><><<<<>>>><<><><<<>>>><<>><<>>><>><<<<>><<>>>><<<>><>><>>><<<<>><<<<>><<<>><<<>>>><<<>><<<<>>><<<>>><<<<>>><><<<>>>><<<><>><>>>><>>>><<<<><<>><<<><<<><>>><<>>><<>>>><>>>><>>><<>><<>>><>>>><<<>><<>><<<<>>><<<>>>><<<><<<><<<>>>><<<<>>><<<<>>>><<<>><<>>>><<>>>><><<<>>><>><<<>>>><<<<>><><<<><>><>>><>>>><<<<>>><<<>>><<<<><<<>><<>>>><<>>><<<<>>>><><<<><<<<>>>><<<<>><<<>>>><<>>><<><>><><<<>>>><<<><<<><>>><<<<>>>><<<<>>>>"
}

}