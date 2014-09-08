package p_char
{
	import flash.geom.Point;
	
	import nape.geom.Vec2;
	import nape.geom.Vec3;
	import nape.phys.Body;
	import nape.phys.BodyType;
	import nape.phys.Material;
	import nape.shape.Shape;
	import nape.space.Space;
	
	import p_engine.p_singleton.TG_World;
	
	import starling.display.Image;
	import starling.display.Shape;
	import starling.display.Sprite;
	import starling.textures.Texture;
	import starling.utils.HAlign;
	import starling.utils.VAlign;

	public class TG_Character
	{
		public var body:Body;
		public var bodyImg:Image;
		private var space:Space;
		public var scale:Number = 1;
		public var id:String = "";
		public var name:String = "";
		
		public var angularDamping:Number = 2;
		public var linearDamping:Number = 10;
		public var elasticity:Number = 0;
		public var density:Number = 1;
		public var static:Boolean = false;
		public var collisionGroup:int = 1;
		public var impulse:int = 0;
		//For Drawing Line
		//public var lineDraw:starling.display.Shape;
		public var lineDraw:DashedLine;
		
		public var xml:XML;
		
		public var forceDestroyCounter:int = 0;
		public var forceDestroy:Boolean = false;
		public var isDead:Boolean = false;
		public var isFalling:Boolean = false;
		private var fallCounter:int = 0;
		private var fallDelay:int = 500;
		
		public var ableToPush:Boolean = false;
		
		public var useTeleport:Boolean = false;
		public function TG_Character(xml:XML,space:Space,worldScale:Number = 1)
		{
			init(xml,space,worldScale);
		}
		
		public function init(xml:XML,space:Space,worldScale:Number = 1):void
		{
			lineDraw = new DashedLine(2 * worldScale,0x333333,new Array(5 * worldScale,5 * worldScale));
			//lineDraw = new starling.display.Shape();
			this.xml = xml;
			this.scale = worldScale * Number(xml.scale);
			this.angularDamping = Number(xml.angularDamping);
			this.linearDamping = Number(xml.linearDamping);
			this.elasticity = Number(xml.elasticity);
			this.density = Number(xml.density);
			this.collisionGroup = int(xml.collisionGroup);
			this.static = int(xml.static) == 1? true : false;
			this.impulse = int(xml.impulse);
			
			bodyImg = new Image(TG_World.assetManager.getTexture(xml.textureName));
			
			body = PhysicsData.createBody(xml.physicName,bodyImg,scale);
			body.space = space;
			body.mass = 1;
			body.isBullet = true;
			
			if(this.static)
				body.type = BodyType.KINEMATIC;
			else
				body.type = BodyType.DYNAMIC;
			
			this.space = space;
			
			bodyImg.scaleX = bodyImg.scaleY = this.scale;
			
			//random position above stage
			/*body.position.setxy(Math.random()*(TG_World.NORMAL_WIDTH),Math.random()*(TG_World.NORMAL_HEIGHT));
			body.position.x += TG_World.OFFSETX;
			body.position.y += TG_World.OFFSETY
			body.position.x += 10 * worldScale;
			body.position.y += 10 * worldScale;*/
			
			var positionTemp:Vec3 = PhysicsData.graphicsPosition(body);
			if(positionTemp)
			{
				bodyImg.x = positionTemp.x;
				bodyImg.y = positionTemp.y;
				bodyImg.rotation = positionTemp.z;
			}
			
			
			var i:int = 0;
			var size:int = body.shapes.length;
			var shapeTemp:nape.shape.Shape;
			for(i;i<size;i++)
			{
				shapeTemp = body.shapes.at(i);
				shapeTemp.material.elasticity = this.elasticity;
				shapeTemp.material.density = this.density;
				shapeTemp.filter.collisionGroup = this.collisionGroup;
				shapeTemp.filter.collisionMask = this.collisionGroup;
			}
			
			body.userData.character = this;
			
			
			
			
			//body.rotation = Math.PI*2*Math.random();
			
			
			
			//rsemi-randomised velocity.
			//body.velocity.y = 350;
			//body.angularVel = Math.random()*10-5;
		}
		
		public function update(elapsedTime:int):void
		{
			if(isFalling)
			{
				
				//body.angularVel = 1;
				//body.velocity.setxy(0,0);
				fallCounter += elapsedTime;
				var angularVelTemp:Number = body.angularVel;
				if(fallCounter < fallDelay)
				{
					bodyImg.rotation += angularVelTemp * elapsedTime/1000;
					bodyImg.scaleX = bodyImg.scaleY = this.scale * 0.6 * (1 - (fallCounter / fallDelay));
					bodyImg.alpha = 1 - (fallCounter / fallDelay);
				}
				else
				{
					//fallCounter = 0;
					isDead = true;
					isFalling = false;
					
				}
			}
			else
			{
				calculateFriction(100);
			}
		}
		
		public function calculateFriction(elapsedTime:int):void
		{
			if(body)
			{
				if(body.angularVel > 0)
				{
					//body.applyAngularImpulse(-angularDamping * elapsedTime/1000);
					body.angularVel  -= angularDamping * elapsedTime/1000;
					if(body.angularVel < 0)
					{
						body.angularVel = 0;
					}
					//trace("angular vel = "+body.angularVel );
				}
				else if(body.angularVel < 0)
				{
					//body.applyAngularImpulse(angularDamping * elapsedTime/1000);
					body.angularVel  += angularDamping * elapsedTime/1000;
					if(body.angularVel > 0)
					{
						body.angularVel = 0;
					}
				}
				
				if(body.velocity.length > 0)
				{
					var tempVec:Vec2 = Vec2.get();
					tempVec.x = body.velocity.x;
					tempVec.y = body.velocity.y;
					tempVec = tempVec.normalise();
					//tempVec.length *= -1;
					tempVec.x *= linearDamping * elapsedTime/1000;
					tempVec.y *= linearDamping * elapsedTime/1000;
					if(body.velocity.x > 0)
					{
						body.velocity.x -= tempVec.x * linearDamping * elapsedTime/1000;
						if(body.velocity.x < 0)
						{
							body.velocity.x = 0;
						}
					}
					else if(body.velocity.x < 0)
					{
						body.velocity.x -= tempVec.x * linearDamping * elapsedTime/1000;
						if(body.velocity.x > 0)
						{
							body.velocity.x = 0;
						}
					}
					
					if(body.velocity.y > 0)
					{
						body.velocity.y -= tempVec.y * linearDamping * elapsedTime/1000;
						if(body.velocity.y < 0)
						{
							body.velocity.y = 0;
						}
					}
					else if(body.velocity.y < 0)
					{
						body.velocity.y -= tempVec.y * linearDamping * elapsedTime/1000;
						if(body.velocity.y > 0)
						{
							body.velocity.y = 0;
						}
					}
					
					//body.applyImpulse(tempVec);
					//body.velocity.x -= tempVec.x * linearDamping * elapsedTime/1000;
				}
			}
		}
		
		public function destroy():void
		{
			space.bodies.remove(body);
			if(bodyImg)
			{
				bodyImg.removeFromParent();
			}
		}
	}
}