package p_char
{
	import nape.space.Space;
	
	import p_singleton.TG_Updater;
	
	public class TG_Hole extends TG_Character
	{
		private static var characters:Vector.<TG_Character>;
		private var radius:Number = 0;
		public function TG_Hole(xml:XML, space:Space, worldScale:Number=1)
		{
			super(xml, space, worldScale);
			if(characters == null)
			{
				characters = TG_Updater.getInstance().characters;
			}
			radius = bodyImg.width * 0.5;
		}
		
		public override function update(elapsedTime:int):void
		{
			var size:int = characters.length;
			var i:int = size-1;
			var character:TG_Character;
			for(i;i>=0;i--)
			{
				character = characters[i];
				if(character.isFalling)continue;
				
				var deltaX:Number = body.position.x - character.body.position.x;
				var deltaY:Number = body.position.y - character.body.position.y;
				var distance:Number = Math.sqrt((deltaX * deltaX) + (deltaY * deltaY));
				if(distance <= radius)
				{
					character.bodyImg.alignPivot();
					character.body.userData.dontUpdate = true;
					character.body.velocity.setxy(0,0);
					character.bodyImg.x = body.position.x;
					character.bodyImg.y = body.position.y;
					character.isFalling = true;
				}
			}
		}
		
		public function simulateUpdate():void
		{
			var size:int = characters.length;
			var i:int = size-1;
			var character:TG_Character;
			for(i;i>=0;i--)
			{
				character = characters[i];
				if(character.isFalling)continue;
				
				var deltaX:Number = body.position.x - character.body.position.x;
				var deltaY:Number = body.position.y - character.body.position.y;
				var distance:Number = Math.sqrt((deltaX * deltaX) + (deltaY * deltaY));
				if(distance <= radius)
				{
					character.body.velocity.setxy(0,0);
				}
			}
		}
	}
}