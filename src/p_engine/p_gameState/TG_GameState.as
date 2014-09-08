package p_engine.p_gameState
{
	
	import com.greensock.TimelineMax;
	import com.greensock.TweenMax;
	import com.greensock.easing.Back;
	import com.greensock.plugins.ShortRotationPlugin;
	import com.greensock.plugins.TweenPlugin;
	
	import feathers.controls.Button;
	import feathers.controls.Callout;
	import feathers.controls.Label;
	import feathers.themes.AeonDesktopTheme;
	import feathers.themes.MetalWorksMobileTheme;
	import feathers.themes.MinimalMobileTheme;
	
	import flash.display.Bitmap;
	
	import p_engine.p_input.KeyPoll;
	import p_engine.p_menuBar.TG_MenuBar;
	import p_engine.p_singleton.TG_AssetsLoader;
	import p_engine.p_singleton.TG_World;
	
	import starling.core.Starling;
	import starling.display.DisplayObject;
	import starling.display.DisplayObjectContainer;
	import starling.display.Sprite;
	import starling.display.Stage;
	import starling.events.Event;
	import starling.textures.Texture;

	public class TG_GameState
	{
		/*private var m_gameAtlas:TextureAtlas;
		private var m_gameTexture:Texture;
		private var m_bitmap:Bitmap;
		
		
		protected var m_background:Image;
		protected var m_foreground:Image;*/
		
		/** PROTECTED VARIABLES **/
		protected var m_sprite:Sprite;
		protected var m_parent:DisplayObjectContainer;
		protected var m_stageStarling:Stage;
		protected var m_scale:Number = 1;
		protected var m_timeline:TimelineMax;
		
		protected var m_assetsToLoad:Array;
		protected var m_loadDone:Boolean = false;
		protected var m_insertedToJuggler:Array = [];
		
		/** PUBLIC VARIABLES **/
		public var menuBars:Vector.<TG_MenuBar>;
		public var ready:Boolean = false;
		
		/** KEYBOARD INPUTS **/
		protected var m_keyPoll:KeyPoll;
		protected var m_keyArray:Array;
		
		protected var button:Button;
		public function TG_GameState(parent:DisplayObjectContainer)
		{
			m_parent = parent;
			m_stageStarling = TG_World.stageStarling;
			m_scale = TG_World.SCALE;
			TweenPlugin.activate([ShortRotationPlugin]);
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
			initMenuBars();
			initListeners();
			resize();
			initAnimation();
			initKeypoll();
			emptyLoader();
			//initFeather();
			ready = true;
		}
		
		protected function initFeather():void
		{
			new MinimalMobileTheme(null,false);
			this.button = new Button();
			this.button.label = "Click Me";
			m_sprite.addChild( button );
			this.button.addEventListener( Event.TRIGGERED, button_triggeredHandler );
		}
		
		protected function button_triggeredHandler( event:Event ):void
		{
			const label:Label = new Label();
			label.text = "Hi, I'm Feathers!\nHave a nice day." + m_sprite.stage.stageWidth +","+this.button.width+","+TG_World.SCALE;
			Callout.show( label, this.button );
			
			this.button.validate();
			
			this.button.x = (m_sprite.stage.stageWidth - this.button.width) / 2;
			this.button.y = (m_sprite.stage.stageHeight - this.button.height) / 2;
		}
		
		protected function emptyLoader():void
		{
			TG_AssetsLoader.getInstance().empty(true,true);
		}
		
		private final function initKeypoll():void
		{
			m_keyPoll = new KeyPoll(TG_World.stageStarling);
			m_keyArray = [];
		}
		
		private final function destroyKeypoll():void
		{
			m_keyPoll.destroy();
		}
		
		protected function updateInput():void
		{
			
		}
		protected function describeAssets():void
		{
			CONFIG::MOBILE
			{
				/*m_assetsToLoad = [];
				var obj:Object;
				
				obj = new Object();
				obj.url = "assets/textures/mapTest.png";
				obj.itemName = "mapTestPNG";
				obj.type = TG_AssetsLoader.IMAGE;
				obj.kbTotal = 517;
				m_assetsToLoad.push(obj);
				
				obj = new Object();
				obj.url = "assets/textures/mapTest.xml";
				obj.itemName = "mapTestXML";
				obj.type = TG_AssetsLoader.XML;
				obj.kbTotal = 3;
				m_assetsToLoad.push(obj);*/
				
			}
		}
		
		public function doSomething(str:String):void
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
					m_timeline.play();
				}
			}
			
		}
		
		public function menuBarsVisible(clipException:DisplayObject = null,visible:Boolean = false):void
		{
			for each(var a:TG_MenuBar in menuBars)
			{
				
				if(a.sprite)
				{
					if(clipException)
					{
						if(a.sprite == clipException)
						{
							a.sprite.visible = !visible;
							continue;
						}
					}
					a.sprite.visible = visible;
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
		
		public function show(useLabel:Boolean = true):void
		{
			if(m_sprite)
			{
				m_sprite.visible = true;
				if(!m_timeline)
				{
					initAnimation();
				}
				if(m_timeline)
				{
					if(m_timeline.paused)
					{
						m_timeline.play();
					}
					if(useLabel)
						m_timeline.tweenFromTo("fadeInStart","fadeInEnd",{onComplete:showComplete});
				}
				
			}
		}
		
		public function hide():void
		{
			if(m_sprite)
			{
				if(m_timeline)
				{
					m_timeline.tweenFromTo("fadeInEnd","fadeInStart",{onComplete:hideComplete});
				}
				
			}
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
		
		protected function removeFromJuggler():void
		{
			while(m_insertedToJuggler.length > 0)
			{
				Starling.juggler.remove(m_insertedToJuggler.pop());
			}
		}
		protected function initTextureAtlas():void
		{
			/*super.initTextureAtlas();
			var xml:XML;
			CONFIG::WEB
			{
			m_bitmap = new mapTest();
			m_gameTexture = Texture.fromBitmap(m_bitmap);
			xml = XML(new mapTestXML());
			m_gameAtlas = new TextureAtlas(m_gameTexture,xml);
			
			//DONT FORGET TO PUT RESTORE FUNCTION
			m_gameTexture.root.onRestore = function():void
			{
			// restore the texture from its original source
			m_gameTexture.root.uploadBitmap(m_bitmap);
			}
			}
			
			
			CONFIG::MOBILE
			{
			m_bitmap = TG_LoaderMax.getInstance().getLoader("mapTestPNG").rawContent;
			m_gameTexture = createTexture(m_bitmap);
			xml = TG_LoaderMax.getInstance().getLoader("mapTestXML").content;
			m_gameAtlas = new TextureAtlas(m_gameTexture,xml);
			
			//IF IT'S ON APPLE DISPOSE THE m_bitmap, BECAUSE WE DONT NEED IT
			if(TG_World.os == "ios")
			{
			m_bitmap.bitmapData.dispose();
			m_bitmap = null;
			}
			//DONT FORGET TO PUT RESTORE FUNCTION ON ANDROID
			if(TG_World.os == "android")
			{
			m_gameTexture.root.onRestore = function():void
			{
			// restore the texture from its original source
			m_gameTexture.root.uploadBitmap(m_bitmap);
			}
			}
			}*/
		}
		protected function destroyTextureAtlas():void
		{
			/*super.destroyTextureAtlas();
			m_gameTexture.dispose();
			m_gameAtlas.dispose();
			if(m_bitmap && m_bitmap.bitmapData)
			{
			m_bitmap.bitmapData.dispose();
			m_bitmap = null;
			}*/
		}
		public function destroy():void
		{
			removeFromJuggler();
			destroyAnimation();
			destroyListeners();
			destroySprite();
			destroyMenuBars();
			destroyTextureAtlas();
			destroyKeypoll();
			emptyLoader();
		}
		public function update(elapsedTime:int):void
		{
			updateInput();
			
			if(menuBars)
			{
				var menuBar:TG_MenuBar;
				for each(menuBar in menuBars)
				{
					menuBar.update(elapsedTime);
				}
			}
		}
		
		
		
		public function resize():void
		{
			if(menuBars)
			{
				var menuBar:TG_MenuBar;
				for each(menuBar in menuBars)
				{
					menuBar.resize();
				}
			}
		}
		
		protected function initSprite():void
		{
			
		}
		
		protected function addToParent():void
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
		
		protected function initMenuBars():void
		{
			menuBars = new Vector.<TG_MenuBar>();
		}
		protected function destroyMenuBars():void
		{
			if(menuBars)
			{
				var menuBar:TG_MenuBar;
				/*while(menuBars.length > 0)
				{
					menuBar = menuBars.pop();
					menuBar.destroy();
				}*/
				for each(menuBar in menuBars)
				{
					menuBar.destroy();
				}
				menuBars = null;
			}
			
		}
		
		protected function initListeners():void
		{
			
		}
		
		protected function destroyListeners():void
		{
			
		}
		
		protected function checkOutOfBounds():void
		{
			if(m_sprite.width < m_stageStarling.stageWidth)
			{
				m_sprite.x = (m_stageStarling.stageWidth - m_sprite.width) * 0.5;
			}
			if(m_sprite.height < m_stageStarling.stageHeight)
			{
				m_sprite.y = (m_stageStarling.stageHeight - m_sprite.height) * 0.5;
			}
			
			if(m_sprite.x < m_stageStarling.stageWidth - m_sprite.width)
			{
				m_sprite.x = m_stageStarling.stageWidth - m_sprite.width;
			}
			else if(m_sprite.x > 0)
			{
				m_sprite.x = 0;
			}
			
			if(m_sprite.y < m_stageStarling.stageHeight - m_sprite.height)
			{
				m_sprite.y = m_stageStarling.stageHeight - m_sprite.height;
			}
			else if(m_sprite.y > 0)
			{
				m_sprite.y = 0;
			}
			
		}
	}
}