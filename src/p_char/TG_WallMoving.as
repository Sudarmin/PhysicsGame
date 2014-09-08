package p_char
{
	import nape.phys.BodyType;
	import nape.space.Space;
	
	public class TG_WallMoving extends TG_Character
	{
		public var minX:int = -1;
		public var maxX:int = -1;
		public var minY:int = -1;
		public var maxY:int = -1;
		public var speed:int = 0;
		
		private var moveXPlus:Boolean = true;
		private var moveYPlus:Boolean = true;
		
		public var initPosX:int = 0;
		public var initPosY:int = 0;
		
		
		public function TG_WallMoving(xml:XML, space:Space, worldScale:Number=1)
		{
			super(xml, space, worldScale);
		}
		
		public override function update(elapsedTime:int):void
		{
			var newPos:Number = 0;
			if(moveXPlus)
			{
				if(maxX != -1)
				{
					if(body.position.x >= maxX)
					{
						moveXPlus = false;
					}
					else
					{
						if(useTeleport)
						{
							body.position.x += speed * elapsedTime/1000;
						}
						else
						{
							newPos = body.position.x + (speed * elapsedTime/1000);
							body.velocity.x = (newPos - body.position.x) / 0.05;
						}
						
					}
				}
			}
			else
			{
				if(minX != -1)
				{
					if(body.position.x <= minX)
					{
						moveXPlus = true;
					}
					else
					{
						if(useTeleport)
						{
							body.position.x -= speed * elapsedTime/1000;
						}
						{
							newPos = body.position.x - (speed * elapsedTime/1000);
							body.velocity.x = (newPos - body.position.x) / 0.05;
						}
						
					}
				}
			}
			
			
		}
	}
}