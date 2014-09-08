package p_engine.p_transition
{
	import starling.display.DisplayObject;
	import starling.display.DisplayObjectContainer;

	public class TG_TransitionTemplate
	{
		/** PUBLIC VARIABLES **/
		public var timeToDestroy:Boolean = false;
		public var timeToFinish:Boolean = false;
		protected var state:String = "";
		
		private var m_parent:DisplayObjectContainer;
		public function TG_TransitionTemplate(parent:DisplayObjectContainer)
		{
			m_parent = parent;
			initClip();
		}
		
		protected function initClip():void
		{
			
		}
		
		public function resize():void
		{
			
		}
		
		/** NEW GAME STATE HAS BEEN INITIALIZED AND PREV GAME STATE HAS BEEN DESTROYED **/
		public function fadeOut():void
		{
			timeToDestroy = false;
			timeToFinish = false;
		}
		
		/** THE START OF CHANGING GAME STATE **/
		public function fadeIn():void
		{
			timeToDestroy = false;
			timeToFinish = false;
		}
		public function update(elapsedTime:int):void
		{
			
			
		}
	}
}