package p_gameState
{
	import feathers.controls.Label;
	
	import flash.display.Bitmap;
	import flash.display.StageAspectRatio;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import nape.geom.Vec2;
	import nape.phys.Body;
	import nape.phys.BodyList;
	import nape.phys.BodyType;
	import nape.phys.Material;
	import nape.shape.Polygon;
	import nape.util.Debug;
	import nape.util.ShapeDebug;
	
	import p_char.TG_Character;
	import p_char.TG_Hole;
	import p_char.TG_WallMoving;
	
	import p_engine.p_gameState.TG_GameState;
	import p_engine.p_singleton.TG_AssetsLoader;
	import p_engine.p_singleton.TG_GameManager;
	import p_engine.p_singleton.TG_LoaderMax;
	import p_engine.p_singleton.TG_World;
	
	import p_physic.TG_Space;
	
	import p_pusher.TG_Pusher;
	
	import p_singleton.TG_Updater;
	
	import p_static.TG_Static;
	
	import p_util.TG_Vec2;
	
	import starling.core.Starling;
	import starling.display.DisplayObject;
	import starling.display.DisplayObjectContainer;
	import starling.display.Image;
	import starling.display.Quad;
	import starling.display.Shape;
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	import starling.extensions.TMXObject;
	import starling.extensions.TMXTileMap;
	import starling.extensions.TMXTileSheet;
	import starling.extensions.pixelmask.PixelMaskDisplayObject;
	import starling.textures.Texture;
	import starling.textures.TextureAtlas;
	import starling.utils.AssetManager;
	import starling.utils.deg2rad;
	import starling.utils.rad2deg;
	
	public class TG_InGameState extends TG_GameState
	{
		
		
		protected var m_layerBackground:Sprite;
		protected var m_layerHole:Sprite;
		protected var m_layerObject:Sprite;
		protected var m_layerForeground:Sprite;
		protected var m_layerLineDraw:Sprite;
		
		protected var m_tmx:TMXTileMap;
		protected var m_tilesets:Vector.<Bitmap> = new Vector.<Bitmap>();
		
		
		protected var m_space:TG_Space;
		
		protected var m_debug:Debug;
		
		protected var m_pusher:TG_Pusher;
		protected var m_world:TG_World = TG_World.getInstance();
		
		protected var m_bodyList:BodyList;
		
		public static var LEVELTMX:Array;
		public static var TILESET:Array;
		private var m_hasEnemy:Boolean = false;
		public function TG_InGameState(parent:DisplayObjectContainer)
		{
			super(parent);
		}
		
		//STEP BY STEP IMPLEMENTATION
		
		//STEP 1 DEFINE EMBEDDED PNG AND XML FOR WEB PURPOSE
		CONFIG::WEB
		{
			
			[Embed(source="/assets/tmx/tiledTest.tmx",mimeType="application/octet-stream")]
			public static const tiledTest:Class;
			
			[Embed(source="/assets/tmx/level1.tmx",mimeType="application/octet-stream")]
			public static const level1:Class;
			
			[Embed(source="/assets/tmx/level2.tmx",mimeType="application/octet-stream")]
			public static const level1:Class;
			
			[Embed(source="/assets/tmx/level3.tmx",mimeType="application/octet-stream")]
			public static const level1:Class;
			
			[Embed(source="/assets/tmx/Afrika.png")]
			public static const Afrika:Class;
		}
		
		//STEP 5 INIT SPRITE
		protected override function initSprite():void
		{
			m_sprite = new Sprite();
			
			//Init Layers
			m_layerBackground = new Sprite();
			m_layerObject = new Sprite();
			m_layerForeground = new Sprite();
			m_layerHole = new Sprite();
			m_layerLineDraw = new Sprite();
			
			TG_Static.layerLineDraw = m_layerLineDraw;
			
			m_sprite.addChild(m_layerBackground);
			m_sprite.addChild(m_layerHole);
			m_sprite.addChild(m_layerObject);
			m_sprite.addChild(m_layerLineDraw);
			m_sprite.addChild(m_layerForeground);
		}
		
		//STEP 6 CREATE RESIZE FUNCTION
		public override function resize():void
		{
			super.resize();
			var i:int = 0;
			var size:int = 0;
			m_scale = TG_World.SCALE;
			m_layerBackground.scaleX = m_layerBackground.scaleY = m_scale;
			m_layerForeground.scaleX = m_layerForeground.scaleY = m_scale;
			refreshAnimation();
		}
		
		//STEP 7 INIT ANIMATION
		protected override function initAnimation():void
		{
			super.initAnimation();
			if(m_timeline)
			{
				
				
			}
			show(false);
		}
		
		//STEP 8 INIT LISTENERS
		protected override function initListeners():void
		{
			super.initListeners();
			m_stageStarling.addEventListener(TouchEvent.TOUCH,onTouch);
		}
		//STEP 9 DESTROY LISTENERS
		protected override function destroyListeners():void
		{
			super.destroyListeners();
			m_stageStarling.removeEventListener(TouchEvent.TOUCH,onTouch);
		}
		
		
		public override function init():void
		{
			super.init();
			initTMX();
			initDebug();
			ready = false;
		}
		
		private final function initDebug():void
		{
			m_debug = new ShapeDebug(m_stageStarling.stageWidth, m_stageStarling.stageHeight,0x0000FF);
			m_debug.drawConstraints = true;
			Starling.current.nativeOverlay.addChild(m_debug.display);
		}
		
		private final function initWalls():void
		{
			var i:int = 0;
			var size:int = m_tmx.objectgroups().length;
			var obj:TMXObject;
			var j:int = 0;
			var size2:int = 0;
			var body:Body;
			
			var xStart:int = 0;
			var yStart:int = 0;
			var xEnd:int = 0;
			var yEnd:int = 0;
			
			body = new Body(BodyType.STATIC);
			
			for(i;i<size;i++)
			{
				j = 0;
				size2 = m_tmx.objectgroups()[i].objects.length;
				for(j;j<size2;j++)
				{
					obj = m_tmx.objectgroups()[i].objects[j];
					if(obj.type == TMXObject.WALL)
					{
						
						xStart = int(obj.x);
						yStart = int(obj.y);
						xEnd = int(obj.x + obj.width);
						yEnd = int(obj.y + obj.height);
						
						xStart /= TG_Static.TILESIZE;
						yStart /= TG_Static.TILESIZE;
						xEnd /= TG_Static.TILESIZE;
						yEnd /= TG_Static.TILESIZE;
						
						xEnd++;
						yEnd++;
						
						xStart *= TG_Static.TILESIZE * m_scale;
						yStart *= TG_Static.TILESIZE * m_scale;
						xEnd *= TG_Static.TILESIZE * m_scale;
						yEnd *= TG_Static.TILESIZE * m_scale;
						
						xStart += TG_World.OFFSETX;
						yStart += TG_World.OFFSETY;
						xEnd += TG_World.OFFSETX;
						yEnd += TG_World.OFFSETY;
						
						body.shapes.add(new Polygon(Polygon.rect(xStart,yStart,(xEnd-xStart),(yEnd-yStart))));
						
					}
				}
				
			}
			
			body.space = m_space.space;
		}
		
		protected override function destroySprite():void
		{
			TG_Static.layerLineDraw = null;
			super.destroySprite();
		}
		public override function destroy():void
		{
			super.destroy();
			destroyTMX();
			destroyCharacters();
			destroySpace();
			destroyPusher();
			
		}
		private final function initPusher():void
		{
			m_pusher = new TG_Pusher(TG_World.assetManager.getTexture("fist"),m_space.space);
			m_layerForeground.addChild(m_pusher.sprite);
		}
		
		private final function destroyPusher():void
		{
			if(m_pusher)
			{
				m_pusher.destroy();
			}
		}
		
		protected function initTMX():void
		{
			if(LEVELTMX == null)
			{
				LEVELTMX = [];
				TILESET = [];
				CONFIG::WEB
				{
					LEVELTMX.push(new level1());
					TILESET.push(Afrika);
					LEVELTMX.push(new level2());
					TILESET.push(Afrika);
					LEVELTMX.push(new level3());
					TILESET.push(Afrika);
					LEVELTMX.push(new tiledTest());
					TILESET.push(Afrika);
				}
				CONFIG::MOBILE
				{
					LEVELTMX.push("level1");
					LEVELTMX.push("level2");
					LEVELTMX.push("level3");
					LEVELTMX.push("tiledTest");
				}
				
			}
			m_tmx = new TMXTileMap();
			m_tmx.addEventListener(Event.COMPLETE,loadTMXComplete);
			
			CONFIG::WEB
			{
				m_tilesets.push(Bitmap(new TILESET[TG_Static.LEVEL_CURRENT]));
				var x:XML = XML(LEVELTMX[TG_Static.LEVEL_CURRENT]);
				m_tmx.loadFromEmbed(x,m_tilesets);
			}
			
			CONFIG::MOBILE
			{
				m_tmx.load("assets/tmx/"+LEVELTMX[TG_Static.LEVEL_CURRENT]+".tmx","assets/tmx/");
			}
		}
		
		protected function destroyTMX():void
		{
			if(m_tmx)
			{
				var tileSheet:TMXTileSheet;
				while(m_tmx.tilesheets().length > 0)
				{
					tileSheet = m_tmx.tilesheets().pop();
					if(tileSheet && tileSheet.textureAtlas)
					{
						tileSheet.textureAtlas.dispose();
					}
				}
				
				m_tmx.dispose();
			}
			m_layerBackground.removeChildren();
			m_layerObject.removeChildren();
			m_layerForeground.removeChildren();
		}
		
		private function loadTMXComplete(event:Event):void
		{
			m_tmx.removeEventListener(Event.COMPLETE,loadTMXComplete);
			drawLayers();
			initSpace();
			initWalls();
			initCharacters();
			initPusher();
			
			ready = true;
		}
		
		private final function initSpace():void
		{
			m_space = new TG_Space(TG_World.NORMAL_WIDTH,TG_World.NORMAL_HEIGHT,TG_World.SCALE,TG_World.OFFSETX,TG_World.OFFSETY);
		}
		
		private final function destroySpace():void
		{
			if(m_space)
			{
				m_space.destroy();
			}
		}
		
		private final function initCharacters():void
		{
			
			//register Material for the 'bouncy' ID from the .pes metadata
			PhysicsData.registerMaterial("bouncy", new Material(100));
			
			var body:Body;
			
			var character:TG_Character;
			
			var i:int = 0;
			var size:int = m_tmx.objectgroups().length;
			var obj:TMXObject;
			var j:int = 0;
			var size2:int = 0;
			
			var xStart:int = 0;
			var yStart:int = 0;
			var xEnd:int = 0;
			var yEnd:int = 0;
			var xml:XML;
			
			for(i;i<size;i++)
			{
				j = 0;
				size2 = m_tmx.objectgroups()[i].objects.length;
				for(j;j<size2;j++)
				{
					obj = m_tmx.objectgroups()[i].objects[j];
					
					xStart = int(obj.x);
					yStart = int(obj.y);
					xEnd = int(obj.x + obj.width);
					yEnd = int(obj.y + obj.height);
					
					xStart /= TG_Static.TILESIZE;
					yStart /= TG_Static.TILESIZE;
					xEnd /= TG_Static.TILESIZE;
					yEnd /= TG_Static.TILESIZE;
					
					
					xStart *= (TG_Static.TILESIZE * m_scale);
					yStart *= (TG_Static.TILESIZE * m_scale);
					xEnd *= (TG_Static.TILESIZE * m_scale);
					yEnd *= (TG_Static.TILESIZE * m_scale);
					
					xStart += (TG_Static.TILESIZE * 0.5 * m_scale);
					yStart += (TG_Static.TILESIZE * 0.5 * m_scale);
					xEnd += (TG_Static.TILESIZE * 0.5 * m_scale);
					yEnd += (TG_Static.TILESIZE * 0.5 * m_scale);
					
					
					xStart += TG_World.OFFSETX;
					yStart += TG_World.OFFSETY;
					xEnd += TG_World.OFFSETX;
					yEnd += TG_World.OFFSETY;
					
					
					if(obj.type == TMXObject.PLAYER)
					{
						xml = TG_Static.objectsXMLArray[obj.name];
						character = new TG_Character(xml,m_space.space,m_scale);
						m_layerObject.addChild(character.bodyImg);
						TG_Updater.getInstance().players.push(character);
						TG_Updater.getInstance().characters.push(character);
						character.ableToPush = true;
						character.body.position.setxy(xStart,yStart);
						
					}
					else if(obj.type == TMXObject.ENEMY)
					{
						xml = TG_Static.objectsXMLArray[obj.name];
						character = new TG_Character(xml,m_space.space,m_scale);
						m_layerObject.addChild(character.bodyImg);
						TG_Updater.getInstance().enemies.push(character);
						TG_Updater.getInstance().characters.push(character);
						character.body.position.setxy(xStart,yStart);
						m_hasEnemy = true;
					}
					else if(obj.type == TMXObject.HOLE)
					{
						xml = TG_Static.objectsXMLArray[obj.name];
						character = new TG_Hole(xml,m_space.space,m_scale);
						m_layerHole.addChild(character.bodyImg);
						TG_Updater.getInstance().holes.push(character);
						character.body.position.setxy(xStart,yStart);
					}
					else if(obj.type == TMXObject.OBSTACLE)
					{
						xml = TG_Static.objectsXMLArray[obj.name];
						character = new TG_WallMoving(xml,m_space.space,m_scale);
						m_layerObject.addChild(character.bodyImg);
						TG_Updater.getInstance().obstacles.push(character);
						character.body.position.setxy(xStart,yStart);
					}
					
					var k:int = 0;
					var size3:int = obj.properties.length;
					for(k;k<size3;k++)
					{
						if(obj.properties[k].name == "speed")
						{
							TG_WallMoving(character).speed = int(obj.properties[k].value);
						}
						else if(obj.properties[k].name == "maxX")
						{
							TG_WallMoving(character).maxX = (int(obj.properties[k].value) * TG_Static.TILESIZE * m_scale) + xStart;
						}
						else if(obj.properties[k].name == "minX")
						{
							TG_WallMoving(character).minX = (int(obj.properties[k].value) * TG_Static.TILESIZE * m_scale) + xStart;
						}
					}
				}
			}
				
			
		}
		
		private final function destroyCharacters():void
		{
			while(TG_Updater.getInstance().players.length > 0)
			{
				TG_Updater.getInstance().players.pop().destroy();
			}
			
			while(TG_Updater.getInstance().enemies.length > 0)
			{
				TG_Updater.getInstance().enemies.pop().destroy();
			}
			
			while(TG_Updater.getInstance().holes.length > 0)
			{
				TG_Updater.getInstance().holes.pop().destroy();
			}
		}
		
		private final function drawLayers():void
		{
			var i:int = 0;
			var size:int = m_tmx.layers().length;
			for(i; i < size; i++)
			{
				if(i == 0)
				{
					m_layerBackground.addChild(m_tmx.layers()[i].getQuadBatch());
				}
				else if(i == 1)
				{
					m_layerForeground.addChild(m_tmx.layers()[i].getQuadBatch());
				}
			}
			
			
			
			m_layerBackground.x = (TG_World.GAME_WIDTH - m_layerBackground.width) * 0.5;
			m_layerBackground.y = (TG_World.GAME_HEIGHT - m_layerBackground.height) * 0.5;
			
			m_layerForeground.x = m_layerBackground.x;
			m_layerForeground.y = m_layerBackground.y;
		}
		
		
		protected function onTouch(e:TouchEvent):void
		{
			var touch:Touch = e.getTouch(e.currentTarget as DisplayObject);
			if(touch)
			{
				var phase:String = touch.phase;
				var pos:Point = touch.getLocation(m_sprite);
				var prevPos:Point = touch.getPreviousLocation(m_sprite);
				if(phase == TouchPhase.HOVER)
				{
					
				}
				if(phase == TouchPhase.BEGAN)
				{
					m_bodyList = m_space.space.bodiesUnderPoint(Vec2.get(touch.globalX,touch.globalY));
					for (var i:uint = 0; i < m_bodyList.length; i++) 
					{
						var body:Body = m_bodyList.at(i);
						if (body.isDynamic() && body.userData.character.ableToPush) 
						{
							m_pusher.show(body.userData.character);
							break;
						}
					}
					
				}
				else if(phase == TouchPhase.MOVED)
				{
					if(m_pusher.sprite.visible && !m_pusher.released)
					{
						m_pusher.changePos(touch.globalX,touch.globalY);
					}
				}
				else if(phase == TouchPhase.ENDED)
				{
					if(m_pusher.sprite.visible)
					{
						m_pusher.released = true;
						m_pusher.clearGraphics();
					}
				}
			}
		}
		
		
		public function isEndOfLevel():Boolean
		{
			if(!ready)return false;
			if(m_hasEnemy)
			{
				if(TG_Updater.getInstance().players.length <= 0 || TG_Updater.getInstance().enemies.length <= 0)
				{
					return true;
				}
			}
			else
			{
				if(TG_Updater.getInstance().players.length <= 0)
				{
					return true;
				}
			}
			return false;
		}
		
		public function goToNextLevel():void
		{
			TG_Static.LEVEL_CURRENT ++;
			TG_GameManager.getInstance().changeGameStateInstant(TG_InGameState,TG_Static.layerInGame);
		}
		public override function update(elapsedTime:int):void
		{
			super.update(elapsedTime);
			
			if(m_space)
			{
				m_space.update(elapsedTime);
				var i:int = 0;
				var size:int = m_space.space.bodies.length;
				var body:Body;
				for(i;i<size;i++)
				{
					body = m_space.space.bodies.at(i);
					if(!body.userData.dontUpdate || body.type == BodyType.STATIC)
					{
						PhysicsData.flashGraphicsUpdate(body);
					}
					
					//body.userData.graphic.x -= m_sprite.x;
					//body.userData.graphic.y -= m_sprite.y;
				}
				//m_space.space.liveBodies.foreach(PhysicsData.flashGraphicsUpdate);
				
				//m_debug.clear();
				
				//run simulation
				//space.step(1/60);
				
				//m_debug.draw(m_space.space);
				//m_debug.flush();
			}
			
			if(m_pusher)
			{
				if(m_pusher.sprite.visible && !m_pusher.released)
				{
					m_pusher.simulatePhysics();
				}
				m_pusher.update(elapsedTime);
			}	
			
			if(isEndOfLevel())
			{
				goToNextLevel();
			}
			
			/*var i:int;
			var size:int;
			var body:Body;
			if(m_space)
			{
				i = 0;
				size = m_space.space.bodies.length;
				for(i;i<size;i++)
				{
					body = m_space.space.bodies.at(i);
					if(body.type == BodyType.STATIC)
					{
						body.type = BodyType.DYNAMIC;
						body.rotateShapes(0.01);
						body.type = BodyType.STATIC;
					}
					else
					{
						body.rotateShapes(0.01);
					}
				}
			}*/
			
			
			/*if(m_direction.x != 0 || m_direction.y != 0)
			{
				m_sprite.x += m_direction.x * m_speed * elapsedTime/1000;
				m_sprite.y += m_direction.y * m_speed * elapsedTime/1000;
				
				checkOutOfBounds();
			}*/
		}
	}
}