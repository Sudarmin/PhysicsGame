package {
	
	import PhysicsData;
	
	import nape.geom.Vec2;
	import nape.phys.Body;
	import nape.phys.BodyType;
	import nape.phys.Material;
	import nape.shape.Polygon;
	import nape.space.Space;
	import nape.util.Debug;
	import nape.util.ShapeDebug;
	
	import starling.core.Starling;
	import starling.display.DisplayObject;
	import starling.display.Image;
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.textures.Texture;
	import starling.textures.TextureSmoothing;
	
	
	public class Example extends Sprite {
		//graphical assets.
		[Embed(source="icecream.png")]  private var IceCream :Class;
		[Embed(source="hamburger.png")] private var Hamburger:Class;
		[Embed(source="drink.png")]     private var Drink    :Class;
		[Embed(source="orange.png")]    private var Orange   :Class;
		
		//factory methods for building the PhysicsData bodies with their graphics.
		private function icecream ():Body { return PhysicsData.createBody("icecream", Image.fromBitmap(new IceCream ())); }
		private function hamburger():Body { return PhysicsData.createBody("hamburger",Image.fromBitmap(new Hamburger())); }
		private function drink    ():Body { return PhysicsData.createBody("drink",    Image.fromBitmap(new Drink    ())); }
		private function orange   ():Body { return PhysicsData.createBody("orange",   Image.fromBitmap(new Orange   ())); }
		
		public function Example():void {
			addEventListener(Event.ADDED_TO_STAGE,init);
		}
		
		private function init(ev:Event):void {
			if(ev!=null) removeEventListener(Event.ADDED_TO_STAGE,init);
			
			//create a new nape Space with gravity (0,600)
			var space:Space = new Space(new Vec2(0,600));
			
			var debug : Debug = new ShapeDebug(stage.stageWidth, stage.stageHeight, stage.color);
			debug.drawConstraints = true;
			Starling.current.nativeOverlay.addChild(debug.display);
			
			//create the private border out of 3 rectangles
			var border:Body = new Body(BodyType.STATIC);
			border.shapes.add(new Polygon(Polygon.rect(0,-400,-1,stage.stageHeight+400)));
			border.shapes.add(new Polygon(Polygon.rect(stage.stageWidth,-400,1,stage.stageHeight+400)));
			border.shapes.add(new Polygon(Polygon.rect(0,stage.stageHeight,stage.stageWidth,1)));
			border.space = space;
			
			//register Material for the 'bouncy' ID from the .pes metadata
			PhysicsData.registerMaterial("bouncy", new Material(10));
			
			var factory:Array = [icecream,hamburger,drink,orange];
			var fall:Function = function():void {
				//generate a random one of our objects.
				var body:Body = factory[int(Math.random()*factory.length)]();
				addChild(body.userData.graphic);
				body.space = space;
				
				//random position above stage
				body.position.setxy(Math.random()*(stage.stageWidth-100)+50,-200);
				body.rotation = Math.PI*2*Math.random();
				
				//rsemi-randomised velocity.
				body.velocity.y = 350;
				body.angularVel = Math.random()*10-5;
			};
			
			addEventListener(Event.ENTER_FRAME, function(ev:Event):void {
				//until we have 30 objects, drop an object every 30 time steps
				if(space.timeStamp%30==0 && space.bodies.length<30) fall();
				
				debug.clear();
				
				//run simulation
				space.step(1/60);
				
				debug.draw(space);
				debug.flush();
				
				//update graphic positions
				space.liveBodies.foreach(PhysicsData.flashGraphicsUpdate);
			});
			
			addEventListener(Event.COMPLETE, function(ev:Event):void {
				debug.clear();	
				Starling.current.nativeOverlay.removeChild(debug.display);
				removeChildren();
				space.clear()
			});
		}
	}
}
