package starling.extensions
{
	public class TMXObject
	{
		public var name:String = "";
		public var type:String = "";
		public var x:Number = 0;
		public var y:Number = 0;
		public var width:Number = 0;
		public var height:Number = 0;
		public var properties:Vector.<Object>;
		
		public static const WALL:String = "wall";
		public static const PLAYER:String = "player";
		public static const ENEMY:String = "enemy";
		public static const HOLE:String = "hole";
		public static const OBSTACLE:String = "obstacle";
		public function TMXObject()
		{
			properties = new Vector.<Object>();
		}
	}
}