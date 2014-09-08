package p_engine
{
	import flash.desktop.NativeApplication;
	import flash.desktop.SystemIdleMode;
	import flash.display.Bitmap;
	import flash.display.DisplayObjectContainer;
	import flash.display.Stage;
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.geom.Rectangle;
	import flash.media.AudioPlaybackMode;
	import flash.media.SoundMixer;
	import flash.system.Capabilities;
	
	import p_engine.p_interface.TG_UpdaterInterface;
	import p_engine.p_singleton.TG_GameManager;
	import p_engine.p_singleton.TG_World;
	import p_engine.p_transition.TG_TransitionTemplate;
	
	import starling.core.Starling;
	import starling.display.Stage;

	public class TG_Engine
	{
		private var m_starling:Starling;
		private var m_stage:flash.display.Stage;
		private var m_normalWidth:Number = 0;
		private var m_normalHeight:Number = 0;
		private var m_coreClass:Class;
		private var m_bitmap:Bitmap;
		private var m_parent:DisplayObjectContainer;
		
		private static var m_current:TG_Engine;
		/** The Engine
		 * @param coreClass Main Class
		 * @param stage Flash Display Stage
		 * @param normalWidth Width of the game that it was supposed to be
		 * @param normalHeight Height of the game that it was supposed to be
		 * @param bitmap The default bitmap when the app launches
		 * @param parent The root parent
		 * **/
		public function TG_Engine(coreClass:Class,stage:flash.display.Stage,normalWidth:Number,normalHeight:Number,bitmap:Bitmap,parent:DisplayObjectContainer)
		{
			m_coreClass = coreClass;
			m_stage = stage;
			m_normalWidth = normalWidth;
			m_normalHeight = normalHeight;
			m_bitmap = bitmap;
			m_parent = parent;
			startEngine();
			
			m_current = this;
		}
		
		public static function get current():TG_Engine
		{
			return m_current;
		}
		
		public function startEngine():void
		{
			checkVersion();
			calculateAndInitialize();
			
		}
		
		protected function onResizeEvent(event:Event):void
		{
			calculateScreen();
		}
		/** INITIALIZE 
		 * @param stageStarling starling stage
		 * @param updater the game updater instance
		 * @param collisionDetector the game collision detector instance
		 * @param transition the game transition instance
		 * **/
		public function initialize(stageStarling:starling.display.Stage,updater:TG_UpdaterInterface,collisionDetector:TG_UpdaterInterface,transition:TG_TransitionTemplate):void
		{
			TG_World.stageStarling = stageStarling;
			TG_World.getInstance().updaterInstance = updater;
			TG_World.getInstance().collisionDetectorInstance = collisionDetector;
			TG_GameManager.getInstance().transition = transition;
			TG_GameManager.getInstance().init();
		}
		
		public final function calculateScreen():void
		{
			
			var viewPort:Rectangle;
			if(TG_World.os.indexOf("ios") >= 0 || TG_World.os.indexOf("android") >= 0)
			{
				viewPort =  new Rectangle(0, 0, m_stage.fullScreenWidth, m_stage.fullScreenHeight);
				TG_World.GAME_WIDTH = m_stage.fullScreenWidth;
				TG_World.GAME_HEIGHT = m_stage.fullScreenHeight;
			}
			else
			{
				viewPort =  new Rectangle(0, 0, m_stage.stageWidth, m_stage.stageHeight);
				TG_World.GAME_WIDTH = m_stage.stageWidth;
				TG_World.GAME_HEIGHT = m_stage.stageHeight;
			}
			
			if(TG_World.GAME_WIDTH <= 0)TG_World.GAME_WIDTH = 1;
			if(TG_World.GAME_HEIGHT <= 0)TG_World.GAME_HEIGHT = 1;
			
			var fullWidth:int = TG_World.GAME_WIDTH;
			var fullHeight:int = TG_World.GAME_HEIGHT;
			
			var stageWidth:int = 0;
			var stageHeight:int = 0;
			var stageX:int = 0;
			var stageY:int = 0;
			
			var normalWidth:int = m_normalWidth;
			var normalHeight:int = m_normalHeight;
			
			//LANDSCAPE
			if(TG_World.GAME_WIDTH > TG_World.GAME_HEIGHT)
			{
				if(normalHeight > normalWidth)
				{
					normalWidth = m_normalHeight;
					normalHeight = m_normalWidth;
				}
			}
			//PORTRAIT
			else
			{
				if(normalWidth > normalHeight)
				{
					normalWidth = m_normalHeight;
					normalHeight = m_normalWidth;
				}
			}
			
			var fullRatio:Number = fullWidth/normalWidth;
			
			var testWidth:Number = normalWidth * fullRatio;
			var testHeight:Number = normalHeight * fullRatio;
			
			if(testHeight > fullHeight)
			{
				fullRatio = fullHeight / normalHeight;
				testWidth = normalWidth * fullRatio;
				testHeight = normalHeight * fullRatio;
			}
			
			TG_World.NORMAL_WIDTH = testWidth;
			TG_World.NORMAL_HEIGHT = testHeight;
			
			TG_World.SCALE_ROUNDED = Math.floor(fullRatio);
			if(TG_World.SCALE_ROUNDED <= 0)
			{
				TG_World.SCALE_ROUNDED = 1;
			}
			/*if(maxScale > 0)
			{
				if(TG_World.SCALE_ROUNDED > maxScale)
				{
					TG_World.SCALE_ROUNDED = maxScale;
				}
			}*/
			TG_World.SCALE = fullRatio;
			if(TG_World.SCALE <= 0)
			{
				TG_World.SCALE = 1;
			}
			
			TG_World.SCALEX = fullWidth/normalWidth;
			TG_World.SCALEY = fullHeight/normalHeight;
			
			viewPort.setTo(stageX, stageY, fullWidth, fullHeight);
			
			Starling.current.viewPort = viewPort;
			Starling.current.stage.stageWidth = fullWidth;
			Starling.current.stage.stageHeight = fullHeight;
			
		}
		
		private final function calculateAndInitialize():void
		{
			var viewPort:Rectangle;
			if(TG_World.os.indexOf("ios") >= 0 || TG_World.os.indexOf("android") >= 0)
			{
				viewPort =  new Rectangle(0, 0, m_stage.fullScreenWidth, m_stage.fullScreenHeight);
				TG_World.GAME_WIDTH = m_stage.fullScreenWidth;
				TG_World.GAME_HEIGHT = m_stage.fullScreenHeight;
			}
			else
			{
				viewPort =  new Rectangle(0, 0, m_stage.stageWidth, m_stage.stageHeight);
				TG_World.GAME_WIDTH = m_stage.stageWidth;
				TG_World.GAME_HEIGHT = m_stage.stageHeight;
			}
			
			if(TG_World.GAME_WIDTH <= 0)TG_World.GAME_WIDTH = 1;
			if(TG_World.GAME_HEIGHT <= 0)TG_World.GAME_HEIGHT = 1;
			
			var fullWidth:int = TG_World.GAME_WIDTH;
			var fullHeight:int = TG_World.GAME_HEIGHT;
			
			var stageWidth:int = 0;
			var stageHeight:int = 0;
			var stageX:int = 0;
			var stageY:int = 0;
			
			var normalWidth:int = m_normalWidth;
			var normalHeight:int = m_normalHeight;
			
			//LANDSCAPE
			if(TG_World.GAME_WIDTH > TG_World.GAME_HEIGHT)
			{
				if(normalHeight > normalWidth)
				{
					normalWidth = m_normalHeight;
					normalHeight = m_normalWidth;
				}
			}
				//PORTRAIT
			else
			{
				if(normalWidth > normalHeight)
				{
					normalWidth = m_normalHeight;
					normalHeight = m_normalWidth;
				}
			}
			
			var fullRatio:Number = fullWidth/normalWidth;
			
			var testWidth:Number = normalWidth * fullRatio;
			var testHeight:Number = normalHeight * fullRatio;
			
			if(testHeight > fullHeight)
			{
				fullRatio = fullHeight / normalHeight;
				testWidth = normalWidth * fullRatio;
				testHeight = normalHeight * fullRatio;
			}
			
			TG_World.NORMAL_WIDTH = testWidth;
			TG_World.NORMAL_HEIGHT = testHeight;
			
			TG_World.SCALE_ROUNDED = Math.floor(fullRatio);
			if(TG_World.SCALE_ROUNDED <= 0)
			{
				TG_World.SCALE_ROUNDED = 1;
			}
			/*if(maxScale > 0)
			{
				if(TG_World.SCALE_ROUNDED > maxScale)
				{
					TG_World.SCALE_ROUNDED = maxScale;
				}
			}*/
			TG_World.SCALE = fullRatio;
			if(TG_World.SCALE <= 0)
			{
				TG_World.SCALE = 1;
			}
			
			TG_World.SCALEX = fullWidth/normalWidth;
			TG_World.SCALEY = fullHeight/normalHeight;
			
			viewPort.setTo(stageX, stageY, fullWidth, fullHeight);
			
			m_bitmap.x = viewPort.x;
			m_bitmap.y = viewPort.y;
			m_bitmap.width  = fullWidth;
			m_bitmap.height = fullHeight;
			m_bitmap.smoothing = true;
			m_parent.addChild(m_bitmap);
			
			Starling.multitouchEnabled = true; // useful on mobile devices
			
			if(TG_World.os == "ios")
			{
				Starling.handleLostContext = false;
			}
			else
			{
				Starling.handleLostContext = true; // deactivate on mobile devices (to save memory)
				//Starling.handleLostContext = false;
			}
			
			m_starling = new Starling(m_coreClass, m_stage,viewPort);
			m_starling.simulateMultitouch = true;
			m_starling.enableErrorChecking = false;
			m_starling.antiAliasing = 0;
			m_starling.showStats = true;
			
			m_starling.stage.stageWidth  = fullWidth;
			m_starling.stage.stageHeight = fullHeight;
			
			m_stage.stageWidth = fullWidth;
			m_stage.stageHeight = fullHeight;
			
			m_stage.stage3Ds[0].addEventListener(Event.CONTEXT3D_CREATE, onContextCreated);
			
			CONFIG::NATIVEAPP
			{
				NativeApplication.nativeApplication.autoExit = false;
				NativeApplication.nativeApplication.systemIdleMode = SystemIdleMode.KEEP_AWAKE;
				SoundMixer.audioPlaybackMode = AudioPlaybackMode.AMBIENT;
			}
			
			m_stage.stage3Ds[0].addEventListener(ErrorEvent.ERROR,onError);
		}
		private final function onError(e:ErrorEvent):void
		{
		}
		private function onContextCreated(event:Event):void
		{
			// set framerate to 30 in software mode
			
			m_stage.stage3Ds[0].removeEventListener(Event.CONTEXT3D_CREATE, onContextCreated);
			if(m_bitmap && m_bitmap.parent)
			{
				m_bitmap.parent.removeChild(m_bitmap);
				m_bitmap.bitmapData.dispose();
			}
			m_starling.start();
			
			if (Starling.context.driverInfo.toLowerCase().indexOf("software") != -1)
				Starling.current.nativeStage.frameRate = 30;
		}
		
		private final function checkVersion():void
		{
			var str:String;
			
			//check manufaturer
			str = String(Capabilities.manufacturer).toLowerCase();
			if(str.indexOf("windows") >= 0)
			{
				TG_World.manufacturer = "windows";
			}
			else if(str.indexOf("macintosh") >= 0)
			{
				TG_World.manufacturer = "macintosh";
			}
			else if(str.indexOf("linux") >= 0)
			{
				TG_World.manufacturer = "linux";
			}
			
			//check os
			str = String(Capabilities.version).toLowerCase();
			str = str.substr(0,3);
			if(str.indexOf("ios") >= 0)
			{
				TG_World.os = "ios";
			}
			else if(str.indexOf("and") >= 0)
			{
				TG_World.os = "android";
			}
			else
			{
				TG_World.os = "web";
			}
			
			//check device
			str = String(Capabilities.os);
			TG_World.device = str.toLowerCase();
			
			trace("os = "+TG_World.os);
			trace("device = "+TG_World.device);
			trace("manufacturer = "+TG_World.manufacturer);
		}
	}
}