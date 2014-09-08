package p_engine.p_singleton
{
	import com.greensock.events.LoaderEvent;
	import com.greensock.loading.BinaryDataLoader;
	import com.greensock.loading.ImageLoader;
	import com.greensock.loading.LoaderMax;
	import com.greensock.loading.MP3Loader;
	import com.greensock.loading.XMLLoader;
	import com.greensock.loading.display.ContentDisplay;
	
	import flash.system.System;
	
	import starling.events.Event;
	import starling.events.EventDispatcher;
	import starling.events.ProgressEvent;

	public class TG_LoaderMax extends EventDispatcher
	{
		public static const IMAGE:int = 1;
		public static const XML:int = 2;
		public static const MP3:int = 3;
		public static const BINARY:int = 4;
		
		private static var INSTANCE:TG_LoaderMax;
		
		private var loaderMax:LoaderMax;
		private var prevProgressEvent:ProgressEvent;
		public function TG_LoaderMax()
		{
			init();
		}
		

		
		public function init():void
		{
			//LoaderMax.defaultAuditSize = false;
			loaderMax = new LoaderMax({name:"mainQueue", onProgress:progressHandler, onComplete:completeHandler, onError:errorHandler,onChildComplete:handleChild});
			loaderMax.maxConnections = 1;
		}
		
		public function append(url:String,itemName:String,type:int,kbTotal:Number):void
		{
			var totalBytes:int = kbTotal*1000;
			if(type == IMAGE)
			{
				loaderMax.append(new ImageLoader(url,{name:itemName,estimatedBytes:totalBytes}));
			}
			else if(type == XML)
			{
				loaderMax.append(new XMLLoader(url,{name:itemName,estimatedBytes:totalBytes}));
			}
			else if(type == MP3)
			{
				loaderMax.append(new MP3Loader(url,{name:itemName,estimatedBytes:totalBytes}));
			}
			else if(type == BINARY)
			{
				loaderMax.append(new BinaryDataLoader(url,{name:itemName,estimatedBytes:totalBytes}));
			}
		}
		
		public function startLoad():void
		{
			loaderMax.load(true);
		}
		public function pause():void
		{
			loaderMax.pause();
		}
		public function resume():void
		{
			if(loaderMax.paused)
			{
				loaderMax.resume();
			}
			
		}
		public function getContent(nameOrURL:String):*
		{
			return loaderMax.getContent(nameOrURL);
		}
		
		public function getLoader(nameOrURL:String):*
		{
			return loaderMax.getLoader(nameOrURL);
		}
		public function empty(disposeChildren:Boolean = true,unloadAll:Boolean = false):void
		{
			loaderMax.empty(disposeChildren,unloadAll);
		}
		
		public function dispose(flushContent:Boolean = false):void
		{
			loaderMax.dispose(flushContent);
		}
		
		private final function handleChild(event:LoaderEvent):void 
		{
			
			
			
			//System.pauseForGCIfCollectionImminent(0.25);
			//System.gc();
			//this.dispatchEvent(new Event(Event.COMPLETE));
		}
		
		private final function progressHandler(event:LoaderEvent):void 
		{
			if(prevProgressEvent == null)
			{
				prevProgressEvent = new ProgressEvent(ProgressEvent.PROGRESS,event.target.bytesLoaded, event.target.bytesTotal);
			}
			prevProgressEvent.bytesLoaded = event.target.bytesLoaded;
			prevProgressEvent.bytesTotal = event.target.bytesTotal;
		
			this.dispatchEvent(prevProgressEvent);
		
		}
		
		private final function completeHandler(event:LoaderEvent):void 
		{
			
			//trace(event.target + " is complete!");
			this.dispatchEvent(new Event(Event.COMPLETE));
		}
		
		private final function errorHandler(event:LoaderEvent):void 
		{
			trace("error occured with " + event.target + ": " + event.text);
		}
		
		public static function getInstance():TG_LoaderMax
		{
			if(INSTANCE == null)
			{
				INSTANCE = new TG_LoaderMax();
			}
			return INSTANCE;
		}
	}
}