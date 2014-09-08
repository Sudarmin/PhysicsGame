package p_pusher
{
	
	import flash.geom.Point;
	
	import nape.geom.Vec2;
	import nape.phys.Body;
	import nape.phys.BodyType;
	import nape.space.Space;
	
	import p_char.TG_Character;
	import p_char.TG_Hole;
	
	import p_engine.p_singleton.TG_World;
	
	import p_singleton.TG_Updater;
	
	import p_static.TG_Static;
	
	import p_util.TG_Vec2;
	
	import starling.core.Starling;
	import starling.display.Image;
	import starling.display.Sprite;
	import starling.textures.Texture;
	import starling.utils.HAlign;
	import starling.utils.VAlign;
	import starling.utils.deg2rad;

	public class TG_Pusher
	{
		public var sprite:Sprite;
		private var initialPos:Point = new Point();
		private var speed:int = 50;
		private var offset:int = 20;
		private var velocity:TG_Vec2 = new TG_Vec2();
		private var initialDirection:TG_Vec2 = new TG_Vec2(0,-1);
		private var direction:TG_Vec2 = new TG_Vec2(0,-1);
		private var currDirection:TG_Vec2 = new TG_Vec2(0,-1);
		public var distance:Number = 0;
		public var released:Boolean = false;
		
		private var maxDistance:int = 32*4;
		
		private var m_character:TG_Character;
		private var stepSize:int = 8;
		private var tempPoint:Vec2 = Vec2.get();
		private var m_space:Space;
		
		private var m_positions:Vector.<Vec2> = new Vector.<Vec2>();
		private var m_rotations:Vector.<Number> = new Vector.<Number>();
		
		private var m_impulse:Number = 0;
		public function TG_Pusher(texture:Texture,space:Space)
		{
			m_space = space;
			init(texture);
		}
		
		private function init(texture:Texture):void
		{
			sprite = new Sprite();
			var tempImg:Image = new Image(texture);
			
			//tempImg.pivotX = tempImg.width * 0.5;
			//tempImg.pivotY = 0;
			sprite.addChild(tempImg);
			
			sprite.alignPivot(HAlign.CENTER,VAlign.TOP);
			sprite.visible = false;
		}
		
		public function show(character:TG_Character):void
		{
			m_character = character;
			
			maxDistance = 32 * 1 * TG_World.SCALE;
			
			
			currDirection.x = -direction.x;
			currDirection.y = -direction.y;
			
			tempPoint.x = m_character.body.position.x;
			tempPoint.y = m_character.body.position.y;
			
			while(m_character.body.contains(tempPoint))
			{
				tempPoint.x += currDirection.x * stepSize;
				tempPoint.y += currDirection.y * stepSize;
			}
			
			sprite.x = tempPoint.x / TG_World.SCALE;
			sprite.y = tempPoint.y / TG_World.SCALE;
			
			sprite.x -= TG_World.OFFSETX * 0.5;
			sprite.y -= TG_World.OFFSETY * 0.5;
			
			initialPos.x = sprite.x;
			initialPos.y = sprite.y;
			
			velocity.Set(0,0);
			
			sprite.visible = true;
			released = false;
			
			
			simulatePhysics();
			
		}
		
		public function changePos(posX:Number,posY:Number):void
		{
			if(m_character)
			{
				
				var deltaX:Number = m_character.body.position.x - posX;
				var deltaY:Number = m_character.body.position.y - posY;
				var tempDist:Number = Math.sqrt((deltaX * deltaX) + (deltaY * deltaY));
				
				direction.Set(deltaX,deltaY);
				direction.Normalize();
				
				currDirection.x = -direction.x;
				currDirection.y = -direction.y;
				
				var setInitialPos:Boolean = false;
				tempPoint.x = posX;
				tempPoint.y = posY;
				
				var stuckCounter:int = 0;
				while(m_character.body.contains(tempPoint) && stuckCounter < 500)
				{
					stuckCounter++;
					tempPoint.x += currDirection.x * stepSize;
					tempPoint.y += currDirection.y * stepSize;
					setInitialPos = true;
				}
				
				var offSetDistance:int = 0;
				var bodyPos:Vec2 = Vec2.get(m_character.body.position.x,m_character.body.position.y);
				stuckCounter = 0;
				while(m_character.body.contains(bodyPos) && stuckCounter < 500)
				{
					stuckCounter++;
					bodyPos.x += currDirection.x * stepSize;
					bodyPos.y += currDirection.y * stepSize;
					offSetDistance += stepSize;
				}
				
				if(setInitialPos)
				{
					initialPos.x = tempPoint.x / TG_World.SCALE;
					initialPos.y = tempPoint.y / TG_World.SCALE;
				}
				
				if(tempDist > maxDistance + offSetDistance)
				{
					tempPoint.x = m_character.body.position.x + currDirection.x * (maxDistance + offSetDistance);
					tempPoint.y = m_character.body.position.y + currDirection.y * (maxDistance + offSetDistance);
					tempDist = maxDistance + offSetDistance;
				}
				sprite.x = tempPoint.x / TG_World.SCALE;
				sprite.y = tempPoint.y / TG_World.SCALE;
				
				sprite.x -= TG_World.OFFSETX * 0.5;
				sprite.y -= TG_World.OFFSETY * 0.5;
				
				m_impulse = tempDist / (maxDistance + offSetDistance);
				m_impulse *= m_character.impulse * TG_World.SCALE;
				
				if(tempDist < 5 || setInitialPos)
				{
					m_impulse = 0;
				}
				
				
				var angle:Number = TG_Vec2.vectorToRotation(initialDirection,direction);
				sprite.rotation = deg2rad(angle);
				
				//simulatePhysics();
			}
			
		}
		
		public function update(elapsedTime:int):void
		{
			if(released)
			{
				var travelDistance:Number = speed * elapsedTime/1000;
				var deltaX:Number = initialPos.x - sprite.x;
				var deltaY:Number = initialPos.y - sprite.y;
				var tempDist:Number = Math.sqrt((deltaX * deltaX) + (deltaY * deltaY));
				currDirection.Set(deltaX,deltaY);
				currDirection.Normalize();
				if(Math.round(currDirection.x) > 0 && Math.round(direction.x) < 0 || Math.round(currDirection.x) < 0 && Math.round(direction.x) > 0 || Math.round(currDirection.y) < 0 && Math.round(direction.y) > 0 || Math.round(currDirection.y) > 0 && Math.round(direction.y) < 0)
				{
					sprite.visible = false;
					released = false;
					tempPoint.setxy(direction.x * m_impulse, direction.y * m_impulse);
					m_character.body.applyImpulse(tempPoint);
					//m_character.body.force = tempPoint;
					return;
				}
				
				velocity.x += direction.x * travelDistance;
				velocity.y += direction.y * travelDistance;
				
				sprite.x += velocity.x;
				sprite.y += velocity.y;
			}
		}
		
		private final function applyImpulse(body:Body,impulse:Vec2):void
		{
			if(body.type == BodyType.DYNAMIC)
			{
				body.applyImpulse(tempPoint);
			}
		}
		
		public function simulatePhysics():void
		{
			saveCharsPosition();
			applyImpulse(m_character.body,tempPoint.setxy(direction.x * m_impulse, direction.y * m_impulse));
			var step:int = 0;
			while(step < 100)
			{
				step++;
				var i:int = 0;
				var size:int = TG_Updater.getInstance().characters.length;
				i = size -1;
				var char:TG_Character;
				for(i;i>=0;i--)
				{
					char = TG_Updater.getInstance().characters[i];
					if(char.body.type == BodyType.DYNAMIC)
					{
						char.calculateFriction(100);
						char.lineDraw.lineTo(char.body.position.x, char.body.position.y);
					}
				}
				
				i = TG_Updater.getInstance().holes.length-1;
				var hole:TG_Hole;
				for(i;i>=0;i--)
				{
					hole = TG_Updater.getInstance().holes[i] as TG_Hole;
					hole.simulateUpdate();
				}
				
				m_space.step(0.05,10,10);
			}
			
				
			loadCharsPosition();
		}
		
		private final function saveCharsPosition():void
		{
			while(m_positions.length > 0)
			{
				m_positions.pop().dispose();
				m_rotations.pop();
			}
			var i:int = 0;
			var size:int = TG_Updater.getInstance().characters.length;
			var char:TG_Character;
			for(i;i<size;i++)
			{
				char = TG_Updater.getInstance().characters[i];
				if(char.body.type == BodyType.DYNAMIC)
				{
					char.body.velocity.setxy(0,0);
					char.body.angularVel = 0;
					m_positions.push(char.body.position.copy());
					m_rotations.push(char.body.rotation);
					TG_Static.layerLineDraw.addChild(char.lineDraw);
					char.lineDraw.clear();
					char.lineDraw.moveTo(char.body.position.x, char.body.position.y);
				}
			}
			
			i = 0;
			size = TG_Updater.getInstance().obstacles.length;
			for(i;i<size;i++)
			{
				char = TG_Updater.getInstance().obstacles[i];
				if(char.body.type == BodyType.KINEMATIC)
				{
					char.useTeleport = true;
					char.body.velocity.x = 0;
					char.body.velocity.y = 0;
				}
			}
		}
		
		public final function clearGraphics():void
		{
			var i:int = 0;
			var size:int = TG_Updater.getInstance().characters.length;
			var char:TG_Character;
			for(i;i<size;i++)
			{
				char = TG_Updater.getInstance().characters[i];
				if(char.body.type == BodyType.DYNAMIC)
				{
					char.lineDraw.clear();
					char.lineDraw.removeFromParent();
				}
			}
		}
		
		private final function loadCharsPosition():void
		{
			var i:int = 0;
			var size:int = TG_Updater.getInstance().characters.length;
			var char:TG_Character;
			for(i;i<size;i++)
			{
				char = TG_Updater.getInstance().characters[i];
				if(char.body.type == BodyType.DYNAMIC)
				{
					char.body.position.x = m_positions[i].x;
					char.body.position.y = m_positions[i].y;
					char.body.rotation = m_rotations[i];
					char.body.velocity.setxy(0,0);
					char.body.angularVel = 0;
				}
			}
			
			i = 0;
			size = TG_Updater.getInstance().obstacles.length;
			for(i;i<size;i++)
			{
				char = TG_Updater.getInstance().obstacles[i];
				if(char.body.type == BodyType.KINEMATIC)
				{
					char.useTeleport = false;
				}
			}
		}
		
		public function destroy():void
		{
			if(sprite)
			{
				sprite.removeFromParent(true);
			}
			tempPoint.dispose();
			
		}
	}
}