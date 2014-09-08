package p_singleton
{
	public class TG_Status
	{
		private static var INSTANCE:TG_Status;
		public function TG_Status()
		{
			init();
		}
		public static function getInstance():TG_Status
		{
			if(INSTANCE == null)
			{
				INSTANCE = new TG_Status();
			}
			return INSTANCE;
		}
		private function init():void
		{
		}
		
		public function saveGame():void
		{
			
		}
		
		public function loadGame():void
		{
			
		}
	}
}