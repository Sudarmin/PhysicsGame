package p_engine.p_singleton
{
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	import p_engine.p_singleton.TG_World;
	
	import starling.core.Starling;
	import starling.events.Event;
	import starling.events.EventDispatcher;
	import starling.events.ProgressEvent;


	
	public class TG_AssetsLoader extends EventDispatcher
	{
		public static const IMAGE:int = 1;
		public static const XML:int = 2;
		public static const MP3:int = 3;
		public static const BINARY:int = 4;
		
		[Embed(source = "/assets/screenDefaultStartupLoading.png")]
		public const Background:Class;
		
		private var bitmap:Bitmap;
		private var textField:TextField;
		private var clip:Sprite;
		
		private var stageNative:Stage;
		
		private static var INSTANCE:TG_AssetsLoader;
		public function TG_AssetsLoader()
		{
			init();
		}
		
		public static function getInstance():TG_AssetsLoader
		{
			if(INSTANCE == null)
			{
				INSTANCE = new TG_AssetsLoader();
			}
			return INSTANCE;
		}
		
		public function append(url:String,itemName:String,type:int,kbTotal:Number):void
		{
			TG_LoaderMax.getInstance().append(url,itemName,type,kbTotal);
		}
		public function startLoad():void
		{
			show();
			TG_LoaderMax.getInstance().startLoad();
		}
	
		public function pause():void
		{
			TG_LoaderMax.getInstance().pause();
		}
		public function resume():void
		{
			TG_LoaderMax.getInstance().resume();
		}
		public function empty(disposeChildren:Boolean = true,unloadAll:Boolean = false):void
		{
			TG_LoaderMax.getInstance().empty(disposeChildren,unloadAll);
		}
		public function dispose(flushContent:Boolean = false):void
		{
			TG_LoaderMax.getInstance().dispose(flushContent);
		}
		
		public function init():void
		{
			initClip();
			initListeners();
			hide();
		}
		
		public function show(showClip:Boolean = true):void
		{
			if(!clip.visible && showClip)
			{
				clip.visible = true;
				bitmap.scaleX = bitmap.scaleY = TG_World.SCALE_ROUNDED * 0.5;
				bitmap.x = (TG_World.GAME_WIDTH - bitmap.width)*0.5;
				bitmap.y = (TG_World.GAME_HEIGHT - bitmap.height)*0.5;
				
				
				textField.x = 0;
				textField.y = TG_World.GAME_HEIGHT - textField.height;
				
				
			}
			
		}
		public function hide():void
		{
			if(clip.visible)
			{
				clip.visible = false;
			}
		}
		
		protected function initListeners():void
		{
			TG_LoaderMax.getInstance().addEventListener(ProgressEvent.PROGRESS,onProgress);
			TG_LoaderMax.getInstance().addEventListener(Event.COMPLETE,onComplete);
		}

		private function onComplete(e:Event):void
		{
			this.dispatchEvent(new Event(Event.COMPLETE));
			hide();
		}
		
		private function onProgress(e:ProgressEvent):void
		{
			var bytesLoaded:int = e.bytesLoaded;
			var bytesTotal:int = e.bytesTotal;
			var progress:Number = bytesLoaded/bytesTotal;
			progress = Math.round(progress * 100);
			textField.text = ""+bytesLoaded+" / "+bytesTotal+" Progress : "+progress+"%";
		}
		
		
		protected function initClip():void
		{
			var scaleSize:Number = TG_World.SCALE;
			
			bitmap = new Background();
			//bitmap.width  = TG_World.GAME_WIDTH;
			//bitmap.height = TG_World.GAME_HEIGHT;
			bitmap.smoothing = true;
			
			var myFormat:TextFormat = new TextFormat();
			myFormat.size = 15;
			myFormat.align = TextFormatAlign.LEFT;
			myFormat.color = 0xFFFFFF;
			
			textField = new TextField();
			textField.width = TG_World.GAME_WIDTH;
			textField.height = 30 * scaleSize;
			textField.text = "Progress : 0%";
			textField.x = 0;
			textField.y = TG_World.GAME_HEIGHT - textField.height;
			textField.defaultTextFormat = myFormat;
			textField.background = false;
			
			clip = new Sprite();
			clip.addChild(bitmap);
			clip.addChild(textField);
			
			
			Starling.current.nativeOverlay.addChild(clip);
		}
		
		
		
	}
}