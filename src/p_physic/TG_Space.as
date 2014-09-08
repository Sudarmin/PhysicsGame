package p_physic
{
	import nape.phys.Body;
	import nape.phys.BodyType;
	import nape.shape.Polygon;
	import nape.space.Space;

	public class TG_Space
	{
		public var space:Space;
		private var border:Body;
		private var width:int = 0;
		private var height:int = 0;
		private var scale:Number = 1;
		private var offSetX:Number = 0;
		private var offSetY:Number = 0;
		public function TG_Space(width:int,height:int,scale:Number = 1,offSetX:Number=0,offSetY:Number=0)
		{
			this.width = width;
			this.height = height;
			this.scale = scale;
			this.offSetX = offSetX;
			this.offSetY = offSetY;
			init();
		}
		
		public function init():void
		{
			space = new Space();
			border = new Body(BodyType.STATIC);
			
			var xInit:Number = 1 * scale;
			var yInit:Number = 1 * scale;
			border.shapes.add(new Polygon(Polygon.rect(xInit+offSetX,yInit+offSetY,xInit,height-yInit*2)));
			border.shapes.add(new Polygon(Polygon.rect(xInit+offSetX, yInit+offSetY, width-xInit*2, yInit)));
			border.shapes.add(new Polygon(Polygon.rect(width+offSetX-xInit*2, yInit+offSetY, xInit, height-yInit*2)));
			border.shapes.add(new Polygon(Polygon.rect(xInit+offSetX, height+offSetY-yInit*2, width-xInit*2, yInit)));
			border.space = space;
			
		}
		
		public function update(elapsedTime:int):void
		{
			/*if(elapsedTime > 500)
			{
				elapsedTime = 500;
			}*/
			if(space)
			{
				space.step(0.05,10,10);
			}
		}
		
		public function destroy():void
		{
			space.bodies.remove(border);
			border = null;
			space.clear();
			space = null;
		}
	}
}