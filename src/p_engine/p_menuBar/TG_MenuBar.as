package p_engine.p_menuBar
{
	
	import com.greensock.TimelineMax;
	import com.greensock.TweenMax;
	import com.greensock.easing.Back;
	
	import flash.display.Bitmap;
	
	import p_engine.p_gameState.TG_GameState;
	import p_engine.p_singleton.TG_AssetsLoader;
	import p_engine.p_singleton.TG_World;
	
	import starling.core.Starling;
	import starling.display.DisplayObject;
	import starling.display.DisplayObjectContainer;
	import starling.display.Sprite;
	import starling.display.Stage;
	import starling.events.Event;
	import starling.textures.Texture;
	
	public class TG_MenuBar
	{
		/** PROTECTED VARIABLES **/
		protected var m_sprite:Sprite;
		protected var m_parent:DisplayObjectContainer;
		protected var m_stageStarling:Stage;
		protected var m_gameState:TG_GameState;
		protected var m_timeline:TimelineMax;
		
		protected var m_assetsToLoad:Array;
		protected var m_loadDone:Boolean = false;
		protected var m_insertedToJuggler:Array = [];
		
		public var ready:Boolean = false;
		public function TG_MenuBar(parent:DisplayObjectContainer,gameState:TG_GameState)
		{
			m_parent = parent;
			m_gameState = gameState;
			m_stageStarling = TG_World.stageStarling;
			m_gameState.menuBars.push(this);
			initBeforeLoad();
		}
		
		public function initBeforeLoad():void
		{
			CONFIG::MOBILE
			{
				describeAssets();
				loadAssets();
			}
			CONFIG::WEB
			{
				init();
			}
			
		}
		
		public function init():void
		{
			initTextureAtlas();
			initSprite();
			addToParent();
			initListeners();
			initAnimation();
			//resize();
			ready = true;
		}
		
		protected function describeAssets():void
		{
			
			
		}
		
		
		protected function loadAssets():void
		{
			if(m_assetsToLoad == null || (m_assetsToLoad && m_assetsToLoad.length <= 0))
			{
				m_loadDone = true;
				init();
			}
			else
			{
				var i:int = 0;
				var size:int = m_assetsToLoad.length;
				var obj:Object;
				for(i;i<size;i++)
				{
					obj = m_assetsToLoad[i];
					TG_AssetsLoader.getInstance().append(obj.url,obj.itemName,obj.type,obj.kbTotal);
				}
				TG_AssetsLoader.getInstance().addEventListener(Event.COMPLETE,onComplete);
				TG_AssetsLoader.getInstance().show();
				TG_AssetsLoader.getInstance().startLoad();	
			}
		}
		
		protected function createTexture(bitmap:Bitmap):Texture
		{
			var texture:Texture;
			texture = Texture.fromBitmap(bitmap,false);
			/**Destroy BitmapData on iOS or Web **/
			if(TG_World.os != "android")
			{
				bitmap.bitmapData.dispose();
				bitmap = null;
			}
			return texture;
		}
		
		protected function onComplete(e:Event):void
		{
			TG_AssetsLoader.getInstance().removeEventListener(Event.COMPLETE,onComplete);
			m_loadDone = true;
			init();
		}
		
		protected function initAnimation():void
		{
			if(!m_timeline)
			{
				m_timeline =  new TimelineMax();
			}
		}
		
		protected function refreshAnimation():void
		{
			if(m_timeline)
			{
				destroyAnimation();
				initAnimation();
				if(m_timeline)
				{
					//m_timeline.play();
				}
			}
		}
		
		protected function destroyAnimation():void
		{
			if(m_timeline)
			{
				m_timeline.kill();
				m_timeline.clear();
				m_timeline = null;
			}
		}
		
		protected function fadeAnimationPos(timelineMax:TimelineMax,disp:*,fromX:Number,fromY:Number,toX:Number,toY:Number,duration:Number,timeStart:Number):void
		{
			timelineMax.insert(TweenMax.fromTo(disp,duration,{x:fromX,y:fromY},{x:toX, y:toY, ease:Back.easeOut,onComplete:showComplete}),timeStart);
			disp.x = fromX;
			disp.y = fromY;
		}
		
		protected function fadeAnimationAlpha(timelineMax:TimelineMax,disp:*,fromAlpha:Number,toAlpha:Number,duration:Number,timeStart:Number):void
		{
			timelineMax.insert(TweenMax.fromTo(disp,duration,{alpha:fromAlpha},{alpha:toAlpha}),timeStart);
			disp.alpha = fromAlpha;
		}
		
		protected function showComplete():void
		{
			
		}
		
		protected function hideComplete():void
		{
			if(m_sprite)
			{
				m_sprite.visible = false;
			}
			
		}
		
		public function update(elapsedTime:int):void
		{
			
		}
		
		protected function removeFromJuggler():void
		{
			while(m_insertedToJuggler.length > 0)
			{
				Starling.juggler.remove(m_insertedToJuggler.pop());
			}
		}
		protected function initTextureAtlas():void
		{
			
		}
		protected function destroyTextureAtlas():void
		{
			
		}
		
		public function destroy():void
		{
			removeFromJuggler();
			destroyAnimation();
			destroyListeners();
			destroySprite();
			destroyTextureAtlas();
		}
		
		public function resize():void
		{
			
		}
		
		protected function initSprite():void
		{
			
		}
		
		protected final function addToParent():void
		{
			if(m_parent && m_sprite)
			{
				m_parent.addChild(m_sprite);
			}
		}
		
		protected function destroySprite():void
		{
			if(m_sprite)
			{
				m_sprite.removeFromParent();
			}
		}
		
		protected function initListeners():void
		{
			
		}
		
		protected function destroyListeners():void
		{
			
		}
		
		public function get sprite():Sprite
		{
			return m_sprite;
		}
		
		public function show():void
		{
			
		}
		
		public function hide():void
		{
			
		}
	}
}