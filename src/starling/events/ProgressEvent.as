package starling.events
{
	public class ProgressEvent extends Event
	{
		
		/** Event type for a display object that is entering a new frame. */
		public static const PROGRESS:String = "progress";
		
		private var mBytesLoaded:int = 0;
		private var mBytesTotal:int = 0;
		public function ProgressEvent(type:String, bytesLoaded:int = 0, bytesTotal:int = 0, bubbles:Boolean=false)
		{
			mBytesLoaded = bytesLoaded;
			mBytesTotal = bytesTotal;
			
			var obj:Object = new Object();
			obj.bytesLoaded = mBytesLoaded;
			obj.bytesTotal = mBytesTotal;
			
			super(type, bubbles, obj);
		}
		
		public function get bytesLoaded():int { return mBytesLoaded; }
		public function get bytesTotal():int { return mBytesTotal; }
		public function set bytesLoaded(newValue:int):void { mBytesLoaded = newValue; }
		public function set bytesTotal(newValue:int):void { mBytesTotal = newValue; }
	}
}