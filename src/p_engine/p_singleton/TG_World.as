package p_engine.p_singleton
{
	import flash.utils.getTimer;
	
	import p_engine.p_interface.TG_UpdaterInterface;
	
	import starling.display.Sprite;
	import starling.display.Stage;
	import starling.events.Event;
	import starling.utils.AssetManager;

	public class TG_World
	{
		/** STATIC INSTANCE **/
		private static var INSTANCE:TG_World;
		
		public static var os:String;
		public static var manufacturer:String;
		public static var device:String;
		
		/**SCALE , WIDTH, AND HEIGHT **/
		public static var GAME_WIDTH:Number = 0;
		public static var GAME_HEIGHT:Number = 0;
		public static var NORMAL_WIDTH:Number = 0;
		public static var NORMAL_HEIGHT:Number = 0;
		public static var SCALE_ROUNDED:int = 0;
		public static var SCALE:Number = 0;
		public static var SCALEX:Number = 0;
		public static var SCALEY:Number = 0;
		
		/** PRIVATE VARIABLES **/
		private var m_oldTime:int;
		private var m_elapsedTime:int;
		private var m_gameRunning:Boolean = true;
		
		/** PUBLIC VARIABLES **/
		
		/** NEED TO BE INITIALIZED **/
		private var m_updaterInstance:TG_UpdaterInterface;
		private var m_collisionDetectorInstance:TG_UpdaterInterface;
		public static var stageStarling:Stage;
		public static var assetManager:AssetManager;
		/*****************************/
		
		
		public function TG_World()
		{
			init();
		}
		
		public static function getInstance():TG_World
		{
			if(INSTANCE == null)
			{
				INSTANCE = new TG_World();
			}
			return INSTANCE;
		}
		
		private final function init():void
		{
			stageStarling.addEventListener(Event.ENTER_FRAME,update);
		}
		
		private final function update(e:Event):void
		{
			var newTime:int = getTimer();
			m_elapsedTime = newTime - m_oldTime;
			m_oldTime = newTime;
			
			//IF THE GAME IS RUNNING OR NOT PAUSED
			if(m_gameRunning)
			{
				if(m_updaterInstance)
				{
					m_updaterInstance.update(m_elapsedTime);
				}
				if(m_collisionDetectorInstance)
				{
					m_collisionDetectorInstance.update(m_elapsedTime);
				}
			}
			
			// GAME STATE & UI IS UPDATING NO MATTER WHETHER IT IS BEING PAUSED OR NOT
			TG_GameManager.getInstance().update(m_elapsedTime);
		}
		
		
		public static function get OFFSETX():Number
		{
			return (GAME_WIDTH - NORMAL_WIDTH) * 0.5;
		}
		public static function get OFFSETY():Number
		{
			return (GAME_HEIGHT - NORMAL_HEIGHT) * 0.5;
		}
		public function pauseGame():void
		{
			m_gameRunning = false;
		}
		
		public function resumeGame():void
		{
			m_gameRunning = true;
		}
		
		public final function set updaterInstance(instance:*):void
		{
			m_updaterInstance = instance;
		}
		
		public final function set collisionDetectorInstance(instance:*):void
		{
			m_collisionDetectorInstance = instance;
		}
		
		public final function get elapsedTime():int
		{
			return m_elapsedTime;
		}
	}
}