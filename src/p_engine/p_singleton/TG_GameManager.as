package p_engine.p_singleton
{
	import p_engine.TG_Engine;
	import p_engine.p_gameState.TG_GameState;
	import p_engine.p_transition.TG_TransitionTemplate;
	
	import starling.display.DisplayObjectContainer;
	import starling.events.Event;

	public class TG_GameManager
	{
		/** PRIVATE VARIABLES **/
		private var m_currentGameState:TG_GameState;
		private var m_nextGameStateClass:Class;
		private var m_parent:DisplayObjectContainer;
		private var m_changingState:Boolean = false;
		
		
		/** STATIC VARIABLES **/
		private static var INSTANCE:TG_GameManager;
		
		/** NEED TO BE INITIALIZED **/
		private var m_transition:TG_TransitionTemplate;
		
		public function TG_GameManager()
		{
		}
		
		public static function getInstance():TG_GameManager
		{
			if(INSTANCE == null)
			{
				INSTANCE = new TG_GameManager();
			}
			return INSTANCE;
		}
		
		public final function init():void
		{
			TG_World.stageStarling.addEventListener(Event.RESIZE,onResize);
		}
		
		private final function onResize(e:Event):void
		{
			TG_Engine.current.calculateScreen();
			if(m_currentGameState)
			{
				m_currentGameState.resize();
			}
			if(m_transition)
			{
				m_transition.resize();
			}
		}
		
		public final function set transition(instance:TG_TransitionTemplate):void
		{
			m_transition = instance;
		}
		
		public function changeGameState(nextGameState:Class,parent:DisplayObjectContainer):void
		{
			m_nextGameStateClass = nextGameState;
			m_parent = parent;
			m_changingState = true;
			m_transition.fadeIn();
		}
		
		public function changeGameStateInstant(nextGameState:Class,parent:DisplayObjectContainer):void
		{
			if(m_currentGameState)
			{
				m_currentGameState.destroy();
			}
			m_parent = parent;
			m_currentGameState = new nextGameState(m_parent) as TG_GameState;
			m_currentGameState.initBeforeLoad();
			m_changingState = false;
		}
		
		public final function update(elapsedTime:int):void
		{
			if(m_changingState)
			{
				if(m_transition)
				{
					changingState(elapsedTime);	
				}
				else
				{
					changeGameStateInstant(m_nextGameStateClass,m_parent);
				}
			}
			else
			{
				if(m_currentGameState)
				{
					m_currentGameState.update(elapsedTime);
				}
			}
		}
		
		private final function changingState(elapsedTime:int):void
		{
			if(m_transition)
			{
				if(m_transition.timeToDestroy)
				{
					if(m_currentGameState)
					{
						m_currentGameState.destroy();
					}
					m_currentGameState = new m_nextGameStateClass(m_parent) as TG_GameState;
					m_currentGameState.initBeforeLoad();
					m_transition.fadeOut();
				}
				else if(m_transition.timeToFinish)
				{
					m_changingState = false;
				}
				else
				{
					m_transition.update(elapsedTime);
				}
			}
			
		}
	}
}