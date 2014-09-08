package starling.extensions
{
	import flash.display.Bitmap;
	import flash.events.Event;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.utils.ByteArray;
	
	import starling.display.Image;
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.textures.TextureSmoothing;

	/**
	 * @author shaun.mitchell
	 */
	public class TMXTileMap extends Sprite
	{
		// The TMX file to load
		private var _fileName:String;
		private var _loader:URLLoader;
		private var _mapLoaded:Boolean;
		// XML of TMX file
		private var _TMX:XML;
		// Layers and tilesheet holders
		private var _layers:Vector.<TMXLayer>;
		private var _tilesheets:Vector.<TMXTileSheet>;
		// variables pertaining to map description
		private var _numLayers:uint;
		private var _numObjectgroups:uint;
		private var _numTilesets:uint;
		private var _tilelistCount:uint;
		private var _mapWidth:uint;
		private var _tileHeight:uint;
		private var _tileWidth:uint;
		// used to get the correct tile from various tilesheets
		private var _gidLookup:Vector.<uint>;
		private var _embedTilesets:Vector.<Bitmap>;
		private var _objectgroups:Vector.<TMXObjectGroup>;
		
		private var _assetURL:String = "";

		public function TMXTileMap():void
		{
			_mapLoaded = false;
			_fileName = "";
			_loader = new URLLoader();
			_numLayers = 0;
			_numTilesets = 0;
			_tilelistCount = 0;
			_mapWidth = 0;
			_tileHeight = 0;
			_tileWidth = 0;

			_layers = new Vector.<TMXLayer>();
			_tilesheets = new Vector.<TMXTileSheet>();
			_gidLookup = new Vector.<uint>();
			_objectgroups = new Vector.<TMXObjectGroup>();
		}

		public function load(file:String,assetURL:String = ""):void
		{
			_fileName = file;
			_assetURL = assetURL;
			
			trace(_fileName);

			_loader.addEventListener(flash.events.Event.COMPLETE, loadTilesets);
			_loader.load(new URLRequest(_fileName));
		}

		public function loadFromEmbed(tmx:XML, tilesets:Vector.<Bitmap>):void
		{
			_TMX = tmx;
			_embedTilesets = tilesets;

			loadEmbedTilesets();
		}

		// Getters ------------------------------------------
		public function objectgroups():Vector.<TMXObjectGroup>
		{
			return _objectgroups;
		}
		public function layers():Vector.<TMXLayer>
		{
			return _layers;
		}

		public function tilesheets():Vector.<TMXTileSheet>
		{
			return _tilesheets;
		}

		public function numLayers():uint
		{
			return _numLayers;
		}

		public function numTilesets():uint
		{
			return _numTilesets;
		}

		public function mapWidth():uint
		{
			return _mapWidth;
		}

		public function tileHeight():uint
		{
			return _tileHeight;
		}

		public function tileWidth():uint
		{
			return _tileWidth;
		}

		// End getters --------------------------------------
		// get the number of tilsets from the TMX XML
		private function getNumTilesets():uint
		{
			if (_mapLoaded)
			{
				var count:uint = 0;
				for (var i:int = 0; i < _TMX.children().length(); i++)
				{
					if (_TMX.tileset[i] != null)
					{
						count++;
					}
				}

				trace(count);
				return count;
			}

			return 0;
		}

		// get the number of layers from the TMX XML
		private function getNumLayers():uint
		{
			if (_mapLoaded)
			{
				var count:uint = 0;
				for (var i:int = 0; i < _TMX.children().length(); i++)
				{
					if (_TMX.layer[i] != null)
					{
						count++;
					}
				}

				trace(count);
				return count;
			}
			return 0;
		}
		
		private function getNumObjectgroup():uint
		{
			if(_mapLoaded)
			{
				var count:uint = 0;
				for (var i:int = 0; i < _TMX.children().length(); i++)
				{
					if (_TMX.objectgroup[i] != null)
					{
						count++;
					}
				}
				
				trace(count);
				return count;
			}
			return 0;
		}

		private function loadTilesets(event:flash.events.Event):void
		{
			trace("loading tilesets from file");
			_mapLoaded = true;

			_TMX = new XML(_loader.data);

			if (_TMX)
			{
				_mapWidth = _TMX.@width;
				_tileHeight = _TMX.@tileheight;
				_tileWidth = _TMX.@tilewidth;

				trace("map width" + _mapWidth);

				_numLayers = getNumLayers();
				_numTilesets = getNumTilesets();
				_numObjectgroups = getNumObjectgroup();
				// _TMX.properties.property[1].@value;

				var tileSheet:TMXTileSheet = new TMXTileSheet();
				tileSheet.loadTileSheet(_TMX.tileset[_tilelistCount].@name, _TMX.tileset[_tilelistCount].image.@source, _TMX.tileset[_tilelistCount].@tilewidth, _TMX.tileset[_tilelistCount].@tileheight, _TMX.tileset[_tilelistCount].@firstgid - 1,_assetURL);
				tileSheet.addEventListener(starling.events.Event.COMPLETE, loadRemainingTilesets);
				_tilesheets.push(tileSheet);
				_gidLookup.push(_TMX.tileset[_tilelistCount].@firstgid);
			}
		}

		private function loadEmbedTilesets():void
		{
			trace("loading embedded tilesets");
			_mapLoaded = true;

			if (_TMX)
			{
				_mapWidth = _TMX.@width;
				_tileHeight = _TMX.@tileheight;
				_tileWidth = _TMX.@tilewidth;

				trace("map width" + _mapWidth);

				_numLayers = getNumLayers();
				_numTilesets = getNumTilesets();
				_numObjectgroups = getNumObjectgroup();
				trace(_numTilesets);
				// _TMX.properties.property[1].@value;

				for (var i:int = 0; i < _numTilesets; i++)
				{
					var tileSheet:TMXTileSheet = new TMXTileSheet();
					trace(_TMX.tileset[i].@name, _embedTilesets[i], _TMX.tileset[i].@tilewidth, _TMX.tileset[i].@tileheight, _TMX.tileset[i].@firstgid - 1);
					tileSheet.loadEmbedTileSheet(_TMX.tileset[i].@name, _embedTilesets[i], _TMX.tileset[i].@tilewidth, _TMX.tileset[i].@tileheight, _TMX.tileset[i].@firstgid - 1);
					_tilesheets.push(tileSheet);
					_gidLookup.push(_TMX.tileset[i].@firstgid);
				}
				
				loadMapData();
			}
		}

		private function loadRemainingTilesets(event:starling.events.Event):void
		{
			event.target.removeEventListener(starling.events.Event.COMPLETE, loadRemainingTilesets);

			_tilelistCount++;
			if (_tilelistCount >= _numTilesets)
			{
				trace("done loading tilelists");
				loadMapData();
			}
			else
			{
				trace(_TMX.tileset[_tilelistCount].@name);
				var tileSheet:TMXTileSheet = new TMXTileSheet();
				tileSheet.loadTileSheet(_TMX.tileset[_tilelistCount].@name, _TMX.tileset[_tilelistCount].image.@source, _TMX.tileset[_tilelistCount].@tilewidth, _TMX.tileset[_tilelistCount].@tileheight, _TMX.tileset[_tilelistCount].@firstgid - 1,_assetURL);
				tileSheet.addEventListener(starling.events.Event.COMPLETE, loadRemainingTilesets);
				_gidLookup.push(_TMX.tileset[_tilelistCount].@firstgid);
				_tilesheets.push(tileSheet);
			}
		}

		private function loadMapData():void
		{
			if (_mapLoaded)
			{
				var i:int = 0;
				var j:int = 0;
				var k:int = 0;
				
				var data:Array;
				
				var a:int;
				var b:int;
				var c:int;
				var d:int;
				
				var gid:int;
				
				for (i = 0; i < _numLayers; i++)
				{
					trace("loading map data");
					var ba:ByteArray = Base64.decode(_TMX.layer[i].data);
					ba.uncompress();

					data = new Array();

					for (j = 0; j < ba.length; j += 4)
					{
						// Get the grid ID

						a = ba[j];
						b = ba[j + 1];
						c = ba[j + 2];
						d = ba[j + 3];

						gid = a | b << 8 | c << 16 | d << 24;
						data.push(gid);
					}

					var tmxLayer:TMXLayer = new TMXLayer(data);

					_layers.push(tmxLayer);
					
					//Object groups
					
				}
				
				for(i=0;i< _numObjectgroups;i++)
				{
					var objGroup:TMXObjectGroup = new TMXObjectGroup();
					var length:int = _TMX.objectgroup[i].object.length();
					for(j = 0;j< length;j++)
					{
						var object:TMXObject = new TMXObject();
						object.name = _TMX.objectgroup[i].object[j].attribute("name");
						object.type = _TMX.objectgroup[i].object[j].attribute("type");
						object.x = _TMX.objectgroup[i].object[j].attribute("x");
						object.y = _TMX.objectgroup[i].object[j].attribute("y");
						object.width = _TMX.objectgroup[i].object[j].attribute("width");
						object.height = _TMX.objectgroup[i].object[j].attribute("height");
						var length2:int = _TMX.objectgroup[i].object[j].properties.property.length();
						for(k = 0;k<length2;k++)
						{
							var obj:Object = new Object();
							obj.name = _TMX.objectgroup[i].object[j].properties.property[k].attribute("name");
							obj.value = _TMX.objectgroup[i].object[j].properties.property[k].attribute("value");
							object.properties.push(obj);
						}
						objGroup.objects.push(object);
					}
					_objectgroups.push(objGroup);
					
				}

				drawLayers();
			}
		}

		// draw the layers into a holder contained in a TMXLayer object
		private function drawLayers():void
		{
			trace("drawing layers");
			for (var i:int = 0; i < _numLayers; i++)
			{
				trace("drawing layers num "+i);
				var row:int = 0;
				var col:int = 0;
				for (var j:int = 0; j < _layers[i].getData().length; j++)
				{
					if (col > (_mapWidth - 1) * _tileWidth)
					{
						col = 0;
						row += _tileHeight;
					}

					if (_layers[i].getData()[j] != 0)
					{
						var img:Image = new Image(_tilesheets[findTileSheet(_layers[i].getData()[j])].textureAtlas.getTexture(String(_layers[i].getData()[j])));
						img.smoothing = TextureSmoothing.NONE;
						img.x = col;
						img.y = row;
						//_layers[i].getHolder().addChild(img);
						_layers[i].getQuadBatch().addImage(img);
						img.dispose();
						img = null;
					}

					col += _tileWidth;
				}
			}

			// notify that the load is complete
			dispatchEvent(new starling.events.Event(starling.events.Event.COMPLETE));
		}

		private function findTileSheet(id:uint):int
		{
			var value:int = 0;
			var theOne:int;
			for (var i:int = 0; i < _tilesheets.length; i++)
			{
				if (_tilesheets[i].textureAtlas.getTexture(String(id)) != null)
				{
					theOne = i;
				}
				else
				{
					value = i;
				}
			}
			return theOne;
		}
	}
}
