package
{
	import flash.display.Sprite;
	import starling.core.Starling;
	
	[SWF(width="580", height="400", frameRate="60", backgroundColor="#333333")]
	public class Main extends Sprite
	{
		
		public function Main()
		{
			var starling : Starling  = new Starling(Example,stage);
			starling.start();
			starling.showStatsAt("left","bottom");
		}
	}
}