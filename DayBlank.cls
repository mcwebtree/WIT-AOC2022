Class MC2022AOC.DayBlank [ Abstract ]
{

ClassMethod runGame(intLive As %Integer = 1, intVerb As %Integer = 0) As %Integer
{
	I intLive=1
	{ d ..initLive() }
	ELSE 
	{ d ..initTest() }
	
	S (intCount)=0
		
	// init the control array
	for intRow=1:1:^AOCD {

	}


	Q intCount
}

ClassMethod initTest()
{
 k ^AOCD
 
 S ^AOCD=5
}

ClassMethod initLive()
{
 k ^AOCD
 
 S ^AOCD=99
}

}
