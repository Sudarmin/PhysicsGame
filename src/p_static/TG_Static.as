package p_static
{
	
	import p_engine.p_singleton.TG_World;
	
	import starling.display.Sprite;

	public class TG_Static
	{
		public static var layerTransition:Sprite = new Sprite();
		public static var layerMenuBar:Sprite = new Sprite();
		public static var layerInGame:Sprite = new Sprite();
		public static var layerSniperMask:Sprite = new Sprite();
		public static var layerText:Sprite = new Sprite();
		
		//Initialized in ingamestate
		public static var layerLineDraw:Sprite;
		
		public static const ENGLISH:int = 0;
		public static const INDONESIA:int = 1;
		public static var language:int = ENGLISH;
		
		
		public static var fullCircleRad:Number = Math.PI * 2;
		
		public static var objectsXML:XML;
		public static var objectsXMLArray:Array;
		
		public static const TILESIZE:int = 32;
		public static var LEVEL_CURRENT:int = 0;
		public static var LEVEL_REACHED:int = 0;
		public static function initLayers(parentLayer:Sprite):void
		{
			parentLayer.addChild(layerInGame);
			parentLayer.addChild(layerSniperMask);
			parentLayer.addChild(layerMenuBar);
			parentLayer.addChild(layerText);
			parentLayer.addChild(layerTransition);
		}
		public static function initXML():void
		{
			objectsXML = TG_World.assetManager.getXml("Objects");
			objectsXMLArray = [];
			var i:int = 0;
			var size:int = objectsXML.object.length();
			var xml:XML;
			for(i;i<size;i++)
			{
				xml = objectsXML.object[i];
				objectsXMLArray[xml.id] = xml;
			}
		}
		public function TG_Static()
		{
		}
	}
}