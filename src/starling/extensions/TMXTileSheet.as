package starling.extensions
{
	import flash.display.Bitmap;
	import flash.display.DisplayObject;
	import flash.display.Loader;
	import flash.events.Event;
	import flash.net.URLRequest;
	
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.textures.Texture;
	import starling.textures.TextureAtlas;

	/**
	 * @author shaun.mitchell
	 */
	public class TMXTileSheet extends Sprite
	{
		// the name and file paths
		private var _name:String;
		private var _sheetFilename:String;
		// texture, atlas and loader
		private var _sheet:Bitmap;
		private var _textureAtlas:TextureAtlas;
		private var _imageLoader:Loader = new Loader();
		private var _startID:uint;
		private var _tileHeight:uint;
		private var _tileWidth:uint;
		private var _embedded:Boolean;
		

		public function TMXTileSheet():void
		{
		}

		public function loadTileSheet(name:String, sheetFile:String, tileWidth:uint, tileHeight:uint, startID:uint,assetURL:String = ""):void
		{
			_embedded = false;
			_name = name;
			if(assetURL != "")
			{
				var tempArr:Array = sheetFile.split("/");
				var tempString:String = tempArr[tempArr.length-1];
				_sheetFilename = assetURL+tempArr;
			}
			else
			{
				_sheetFilename = sheetFile;
			}
			
			//_sheetFilename = "/assets/tmx/"+sheetFile;
			_startID = startID;

			_tileHeight = tileHeight;
			_tileWidth = tileWidth;

			trace("creating TMX tilesheet");

			_imageLoader.contentLoaderInfo.addEventListener(flash.events.Event.COMPLETE, loadSheet);
			_imageLoader.load(new URLRequest(_sheetFilename));
		}

		public function loadEmbedTileSheet(name:String, img:Bitmap, tileWidth:uint, tileHeight:uint, startID:uint):void
		{
			trace("creating TMX tilesheet");
			_embedded = true;
			_name = name;
			_startID = startID;

			_sheet = img;

			_tileHeight = tileHeight;
			_tileWidth = tileWidth;

			loadAtlas();
		}

		/*
		Load the image file needed for this tilesheet
		 */
		private function loadSheet(event:flash.events.Event):void
		{
			var sprite:DisplayObject = _imageLoader.content;
			_sheet = Bitmap(sprite);

			loadAtlas();
		}

		/*
		dynamically create a texture atlas to look up tiles
		 */
		private function loadAtlas():void
		{
			trace("loading atlas");
			var numRows:uint = _sheet.height / _tileHeight;
			var numCols:uint = _sheet.width / _tileWidth;

			var id:int = _startID;

			var xml:XML = <Atlas></Atlas>;

			xml.appendChild(<TextureAtlas imagePath={_sheetFilename}></TextureAtlas>);
			for (var i:int = 0; i < numRows; i++)
			{
				for (var j:int = 0; j < numCols; j++)
				{
					id++;
					xml.child("TextureAtlas").appendChild(<SubTexture name={id} x = {(j * _tileWidth)} y={(i * _tileHeight)} width={_tileWidth} height={_tileHeight}/>);
				}
			}

			var newxml:XML = XML(xml.TextureAtlas);

			//trace(newxml);

			_textureAtlas = new TextureAtlas(Texture.fromBitmap(_sheet), newxml);
			trace("done with atlas, dispatching");
			dispatchEvent(new starling.events.Event(starling.events.Event.COMPLETE));
		}

		public function get sheet():Bitmap
		{
			return _sheet;
		}

		public function get textureAtlas():TextureAtlas
		{
			return _textureAtlas;
		}
	}
}
