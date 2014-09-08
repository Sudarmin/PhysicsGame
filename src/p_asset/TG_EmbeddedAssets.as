package p_asset
{
	public class TG_EmbeddedAssets
	{
		//Map Texture Atlas
		[Embed(source="/assets/textures/textures.png")]
		public static const textures:Class;
		
		[Embed(source="/assets/textures/textures.xml",mimeType="application/octet-stream")]
		public static const texturesXML:Class;
		
		//Objects XML
		[Embed(source="/assets/xml/Objects.xml",mimeType="application/octet-stream")]
		public static const Objects:Class;
		public function TG_EmbeddedAssets()
		{
			
		}
	}
}