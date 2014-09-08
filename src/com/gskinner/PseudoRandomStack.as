package com.gskinner
{
	
	import flash.display.MovieClip;
	import com.gskinner.utils.Rndm;
	
	public class PseudoRandomStack extends MovieClip 
	{
		private static var randomNumberList:Array = new Array();
		private static var stackLength:int = 1000;
		private static var counter:int = 0;
		
		public function PseudoRandomStack() 
		{
			// constructor code
		}
		
		public static function generateNewStack(seed:uint = 1):void
		{
			if(Rndm.seed != seed)
			{
				Rndm.seed = seed;
			}
			
			var i:int;
			for( i = 0; i < stackLength; i++ )
			{
				randomNumberList.push(Rndm.random());
			}
		}
		
		public static function random():Number
		{
			counter++;
			if(counter >= stackLength)
			{
				counter = 0;
			}
			return randomNumberList[counter];
		}
	}
	
}
