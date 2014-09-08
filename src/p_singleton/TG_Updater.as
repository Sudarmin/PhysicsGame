package p_singleton
{
	import p_char.TG_Character;
	
	import p_engine.p_interface.TG_UpdaterInterface;
	
	public class TG_Updater implements TG_UpdaterInterface
	{
		public var characters:Vector.<TG_Character>;
		public var holes:Vector.<TG_Character>;
		public var obstacles:Vector.<TG_Character>;
		public var players:Vector.<TG_Character>;
		public var enemies:Vector.<TG_Character>;
		
		private static var INSTANCE:TG_Updater;
		public function TG_Updater()
		{
			init();
		}
		
		public static function getInstance():TG_Updater
		{
			if(INSTANCE == null)
			{
				INSTANCE = new TG_Updater();
			}
			return INSTANCE;
		}
		
		public function init():void
		{
			characters = new Vector.<TG_Character>();
			players = new Vector.<TG_Character>();
			enemies = new Vector.<TG_Character>();
			holes = new Vector.<TG_Character>();
			obstacles = new Vector.<TG_Character>();
		}
		
		public function update(elapsedTime:int):void
		{
			updatePlayers(elapsedTime);
			updateEnemies(elapsedTime);
			updateHoles(elapsedTime);
			updateObstacles(elapsedTime);
		}
		
		private final function updateCharacters(elapsedTime:int):void
		{
			
			var size:int = characters.length;
			var i:int = size-1;
			var character:TG_Character;
			for(i;i>=0;i--)
			{
				character = characters[i];
				character.update(elapsedTime);
				if(character.isDead)
				{
					character.destroy();
					characters.splice(i,1);
				}
			}
		}
		
		private final function updateObstacles(elapsedTime:int):void
		{
			
			var size:int = obstacles.length;
			var i:int = size-1;
			var character:TG_Character;
			for(i;i>=0;i--)
			{
				character = obstacles[i];
				character.update(elapsedTime);
				if(character.isDead)
				{
					character.destroy();
					obstacles.splice(i,1);
				}
			}
		}
		
		private final function updatePlayers(elapsedTime:int):void
		{
			
			var size:int = players.length;
			var i:int = size-1;
			var character:TG_Character;
			for(i;i>=0;i--)
			{
				character = players[i];
				character.update(elapsedTime);
				if(character.isDead)
				{
					character.destroy();
					players.splice(i,1);
				}
			}
		}
		
		private final function updateEnemies(elapsedTime:int):void
		{
			
			var size:int = enemies.length;
			var i:int = size-1;
			var character:TG_Character;
			for(i;i>=0;i--)
			{
				character = enemies[i];
				character.update(elapsedTime);
				if(character.isDead)
				{
					character.destroy();
					enemies.splice(i,1);
				}
			}
		}
		
		private final function updateHoles(elapsedTime:int):void
		{
			
			var size:int = holes.length;
			var i:int = size-1;
			var character:TG_Character;
			for(i;i>=0;i--)
			{
				character = holes[i];
				character.update(elapsedTime);
			}
		}
	}
}