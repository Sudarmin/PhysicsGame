package {

import nape.phys.Body;
import nape.phys.BodyType;
import nape.shape.Shape;
import nape.shape.Polygon;
import nape.shape.Circle;
import nape.geom.Vec2;
import nape.geom.Vec3;
import nape.dynamics.InteractionFilter;
import nape.phys.Material;
import nape.phys.FluidProperties;
import nape.callbacks.CbType;
import nape.callbacks.CbTypeList;
import nape.geom.AABB;

import flash.display.DisplayObject;
import flash.geom.Rectangle;
import flash.utils.Dictionary;

import starling.display.Image;

public class PhysicsData {

    /**
     * Get position and rotation for graphics placement.
     *
     * Example usage:
     * <code>
     *    space.step(1/60);
     *    space.liveBodies.foreach(updateGraphics);
     *    ...
     *    function updateGraphics(body:Body):void {
     *       var position:Vec3 = PhysicsData.graphicsPosition(body);
     *       var graphic:DisplayObject = body.userData.graphic;
     *       graphic.x = position.x;
     *       graphic.y = position.y;
     *       graphic.rotation = position.z;
     *       position.dispose(); //release to object pool.
     *    }
     * </code>
     * In the case that you are using a flash DisplayObject you can simply
     * use <code>space.liveBodies.foreach(PhysicsData.flashGraphicsUpdate);</code>
     * but if using, let's say Starling you should write the equivalent version
     * of the example above.
     *
     * @param body The Body to get graphical position/rotation of.
     * @return A Vec3 allocated from object pool whose x/y are the position
     *         for graphic, and z the rotation in degrees.
     */
    public static function graphicsPosition(body:Body):Vec3 {
		if (body.userData && body.userData.graphicOffset) {
	        var pos:Vec2 = body.localPointToWorld(body.userData.graphicOffset as Vec2);
	        var ret:Vec3 = Vec3.get(pos.x, pos.y, body.rotation);
	        pos.dispose();
	        return ret;
		}
		else {
			return Vec3.get();
		}
    }

    /**
     * Method to update a flash DisplayObject assigned to a Body
     *
     * @param body The Body having a flash DisplayObject to update graphic of.
     */
    public static function flashGraphicsUpdate(body:Body):void {
		if (body.userData && body.userData.graphic) {
	        var position:Vec3 = PhysicsData.graphicsPosition(body);
			if (position) {
		        var graphic:Image = body.userData.graphic;
		        graphic.x = position.x;
		        graphic.y = position.y;
		        graphic.rotation = position.z;
		        position.dispose(); //release to object pool.
			}
		}
	}
    /**
     * Method to create a Body from the PhysicsEditor exported data.
     *
     * If supplying a graphic (of any type), then this will be stored
     * in body.userData.graphic and an associated body.userData.graphicOffset
     * Vec2 will be assigned that represents the local offset to apply to
     * the graphics position.
     *
     * @param name The name of the Body from the PhysicsEditor exported data.
     * @param graphic (optional) A graphic to assign and find a local offset for.
                      This can be of any type, but should have a getBounds function
                      that works like that of the flash DisplayObject to correctly
                      determine a graphicOffset.
	 * @param scale (optional) a factor which is assigned to Body.scaleShapes and 
	 * 				  which is applied to the graphicOffset as well.
     * @return The constructed Body.
     */
    public static function createBody(name:String,graphic:*=null,scale : Number = 1):Body {
        var xret:BodyPair = lookup(name);
        if(graphic==null) return xret.body.copy();

        var ret:Body = xret.body.copy();
		ret.scaleShapes(scale,scale);
        graphic.x = graphic.y = 0;
        graphic.rotation = 0;
        var bounds:Rectangle = graphic.getBounds(graphic);
        var offset:Vec2 = Vec2.get((bounds.x-xret.anchor.x) * scale, (bounds.y-xret.anchor.y) * scale);

		ret.userData.name = name;
        ret.userData.graphic = graphic;
        ret.userData.graphicOffset = offset;

        return ret;
    }

	/**
	 * Method to return the registered anchor for a Body from the PhysicsEditor exported data.
	 *
	 * @param name The name of the Body from the PhysicsEditor exported data.
	 * @return The vector, or an empty vector if the body wasn't found
	 */
	public static function getBodyAnchor(name:String):Vec2 {
		var xret:BodyPair = lookup(name);
		if (xret==null) return Vec2.get(0,0);
		return Vec2.get(xret.anchor.x, xret.anchor.y);
	}

    /**
     * Register a Material object with the name used in the PhysicsEditor data.
     *
     * @param name The name of the Material in the PhysicsEditor data.
     * @param material The Material object to be assigned to this name.
     */
    public static function registerMaterial(name:String,material:Material):void {
        if(materials==null) materials = new Dictionary();
        materials[name] = material;
    }

    /**
     * Register a InteractionFilter object with the name used in the PhysicsEditor data.
     *
     * @param name The name of the InteractionFilter in the PhysicsEditor data.
     * @param filter The InteractionFilter object to be assigned to this name.
     */
    public static function registerFilter(name:String,filter:InteractionFilter):void {
        if(filters==null) filters = new Dictionary();
        filters[name] = filter;
    }

    /**
     * Register a FluidProperties object with the name used in the PhysicsEditor data.
     *
     * @param name The name of the FluidProperties in the PhysicsEditor data.
     * @param properties The FluidProperties object to be assigned to this name.
     */
    public static function registerFluidProperties(name:String,properties:FluidProperties):void {
        if(fprops==null) fprops = new Dictionary();
        fprops[name] = properties;
    }

    /**
     * Register a CbType object with the name used in the PhysicsEditor data.
     *
     * @param name The name of the CbType in the PhysicsEditor data.
     * @param cbType The CbType object to be assigned to this name.
     */
    public static function registerCbType(name:String,cbType:CbType):void {
        if(types==null) types = new Dictionary();
        types[name] = cbType;
    }

    //----------------------------------------------------------------------

    private static var bodies   :Dictionary;
    private static var materials:Dictionary;
    private static var filters  :Dictionary;
    private static var fprops   :Dictionary;
    private static var types    :Dictionary;
    private static function material(name:String):Material {
        if(name=="default") return new Material();
        else {
            if(materials==null || materials[name] === undefined)
                throw "Error: Material with name '"+name+"' has not been registered";
            return materials[name] as Material;
        }
    }
    private static function filter(name:String):InteractionFilter {
        if(name=="default") return new InteractionFilter();
        else {
            if(filters==null || filters[name] === undefined)
                throw "Error: InteractionFilter with name '"+name+"' has not been registered";
            return filters[name] as InteractionFilter;
        }
    }
    private static function fprop(name:String):FluidProperties {
        if(name=="default") return new FluidProperties();
        else {
            if(fprops==null || fprops[name] === undefined)
                throw "Error: FluidProperties with name '"+name+"' has not been registered";
            return fprops[name] as FluidProperties;
        }
    }
    private static function cbtype(outtypes:CbTypeList, name:String):void {
        var names:Array = name.split(",");
        for(var i:int = 0; i<names.length; i++) {
            var name:String = names[i].replace( /^([\s|\t|\n]+)?(.*)([\s|\t|\n]+)?$/gm, "$2" );
            if(name=="") continue;

            if(types[name] === undefined)
                throw "Error: CbType with name '"+name+"' has not been registered";

            outtypes.add(types[name] as CbType);
        }
    }

    private static function lookup(name:String):BodyPair {
        if(bodies==null) init();
        if(bodies[name] === undefined) throw "Error: Body with name '"+name+"' does not exist";
        return bodies[name] as BodyPair;
    }

    //----------------------------------------------------------------------

    private static function init():void {
        bodies = new Dictionary();

        var body:Body;
        var mat:Material;
        var filt:InteractionFilter;
        var prop:FluidProperties;
        var cbType:CbType;
        var s:Shape;
        var anchor:Vec2;

        
            body = new Body();
            cbtype(body.cbTypes,"");

            
                mat = material("default");
                filt = filter("default");
                prop = fprop("default");

                
                    
                        s = new Polygon(
                            [   Vec2.weak(77,65)   ,  Vec2.weak(67,62)   ,  Vec2.weak(47,61)   ,  Vec2.weak(39,62)   ,  Vec2.weak(76,76)   ,  Vec2.weak(78,75)   ],
                            mat,
                            filt
                        );
                        s.body = body;
                        s.sensorEnabled = false;
                        s.fluidEnabled = false;
                        s.fluidProperties = prop;
                        cbtype(s.cbTypes,"");
                    
                        s = new Polygon(
                            [   Vec2.weak(9,5)   ,  Vec2.weak(8,11)   ,  Vec2.weak(10,11)   ,  Vec2.weak(14,7)   ,  Vec2.weak(13,5)   ],
                            mat,
                            filt
                        );
                        s.body = body;
                        s.sensorEnabled = false;
                        s.fluidEnabled = false;
                        s.fluidProperties = prop;
                        cbtype(s.cbTypes,"");
                    
                        s = new Polygon(
                            [   Vec2.weak(14,64)   ,  Vec2.weak(11,72)   ,  Vec2.weak(14,80)   ,  Vec2.weak(39,62)   ,  Vec2.weak(23,62)   ],
                            mat,
                            filt
                        );
                        s.body = body;
                        s.sensorEnabled = false;
                        s.fluidEnabled = false;
                        s.fluidProperties = prop;
                        cbtype(s.cbTypes,"");
                    
                        s = new Polygon(
                            [   Vec2.weak(43,30)   ,  Vec2.weak(39,28)   ,  Vec2.weak(44,42)   ,  Vec2.weak(45,36)   ],
                            mat,
                            filt
                        );
                        s.body = body;
                        s.sensorEnabled = false;
                        s.fluidEnabled = false;
                        s.fluidProperties = prop;
                        cbtype(s.cbTypes,"");
                    
                        s = new Polygon(
                            [   Vec2.weak(14,80)   ,  Vec2.weak(22,168)   ,  Vec2.weak(32,172)   ,  Vec2.weak(58,172)   ,  Vec2.weak(67,169)   ,  Vec2.weak(76,76)   ,  Vec2.weak(39,62)   ],
                            mat,
                            filt
                        );
                        s.body = body;
                        s.sensorEnabled = false;
                        s.fluidEnabled = false;
                        s.fluidProperties = prop;
                        cbtype(s.cbTypes,"");
                    
                        s = new Polygon(
                            [   Vec2.weak(32,31)   ,  Vec2.weak(34,31)   ,  Vec2.weak(33,23)   ,  Vec2.weak(16,7)   ,  Vec2.weak(28,26)   ],
                            mat,
                            filt
                        );
                        s.body = body;
                        s.sensorEnabled = false;
                        s.fluidEnabled = false;
                        s.fluidProperties = prop;
                        cbtype(s.cbTypes,"");
                    
                        s = new Polygon(
                            [   Vec2.weak(26,26)   ,  Vec2.weak(28,26)   ,  Vec2.weak(16,7)   ,  Vec2.weak(14,7)   ,  Vec2.weak(22,21)   ],
                            mat,
                            filt
                        );
                        s.body = body;
                        s.sensorEnabled = false;
                        s.fluidEnabled = false;
                        s.fluidProperties = prop;
                        cbtype(s.cbTypes,"");
                    
                        s = new Polygon(
                            [   Vec2.weak(20,21)   ,  Vec2.weak(22,21)   ,  Vec2.weak(14,7)   ,  Vec2.weak(16,16)   ],
                            mat,
                            filt
                        );
                        s.body = body;
                        s.sensorEnabled = false;
                        s.fluidEnabled = false;
                        s.fluidProperties = prop;
                        cbtype(s.cbTypes,"");
                    
                        s = new Polygon(
                            [   Vec2.weak(14,16)   ,  Vec2.weak(16,16)   ,  Vec2.weak(14,7)   ,  Vec2.weak(10,11)   ],
                            mat,
                            filt
                        );
                        s.body = body;
                        s.sensorEnabled = false;
                        s.fluidEnabled = false;
                        s.fluidProperties = prop;
                        cbtype(s.cbTypes,"");
                    
                        s = new Polygon(
                            [   Vec2.weak(35,23)   ,  Vec2.weak(33,23)   ,  Vec2.weak(34,31)   ,  Vec2.weak(40,57)   ,  Vec2.weak(47,61)   ,  Vec2.weak(44,42)   ,  Vec2.weak(39,28)   ],
                            mat,
                            filt
                        );
                        s.body = body;
                        s.sensorEnabled = false;
                        s.fluidEnabled = false;
                        s.fluidProperties = prop;
                        cbtype(s.cbTypes,"");
                    
                        s = new Polygon(
                            [   Vec2.weak(23,170)   ,  Vec2.weak(32,172)   ,  Vec2.weak(22,168)   ],
                            mat,
                            filt
                        );
                        s.body = body;
                        s.sensorEnabled = false;
                        s.fluidEnabled = false;
                        s.fluidProperties = prop;
                        cbtype(s.cbTypes,"");
                    
                        s = new Polygon(
                            [   Vec2.weak(40,57)   ,  Vec2.weak(39,62)   ,  Vec2.weak(47,61)   ],
                            mat,
                            filt
                        );
                        s.body = body;
                        s.sensorEnabled = false;
                        s.fluidEnabled = false;
                        s.fluidProperties = prop;
                        cbtype(s.cbTypes,"");
                    
                
            

            anchor = (true) ? body.localCOM.copy() : Vec2.get(0,188);
            body.translateShapes(Vec2.weak(-anchor.x,-anchor.y));
            body.position.setxy(0,0);

            bodies["drink"] = new BodyPair(body,anchor);
        
            body = new Body();
            cbtype(body.cbTypes,"");

            
                mat = material("default");
                filt = filter("default");
                prop = fprop("default");

                
                    s = new Circle(
                        38,
                        Vec2.weak(49,38),
                        mat,
                        filt
                    );
                    s.body = body;
                    s.sensorEnabled = false;
                    s.fluidEnabled = false;
                    s.fluidProperties = prop;
                    cbtype(s.cbTypes,"");
                
            

            anchor = (true) ? body.localCOM.copy() : Vec2.get(0,73);
            body.translateShapes(Vec2.weak(-anchor.x,-anchor.y));
            body.position.setxy(0,0);

            bodies["hamburger"] = new BodyPair(body,anchor);
        
            body = new Body();
            cbtype(body.cbTypes,"");

            
                mat = material("default");
                filt = filter("default");
                prop = fprop("default");

                
                    
                        s = new Polygon(
                            [   Vec2.weak(70,30)   ,  Vec2.weak(68,30)   ,  Vec2.weak(44,32)   ,  Vec2.weak(71,32)   ],
                            mat,
                            filt
                        );
                        s.body = body;
                        s.sensorEnabled = false;
                        s.fluidEnabled = false;
                        s.fluidProperties = prop;
                        cbtype(s.cbTypes,"");
                    
                        s = new Polygon(
                            [   Vec2.weak(65,14)   ,  Vec2.weak(64,21)   ,  Vec2.weak(68,30)   ,  Vec2.weak(68,14)   ],
                            mat,
                            filt
                        );
                        s.body = body;
                        s.sensorEnabled = false;
                        s.fluidEnabled = false;
                        s.fluidProperties = prop;
                        cbtype(s.cbTypes,"");
                    
                        s = new Polygon(
                            [   Vec2.weak(64,21)   ,  Vec2.weak(55,22)   ,  Vec2.weak(53,24)   ,  Vec2.weak(53,28)   ,  Vec2.weak(68,30)   ],
                            mat,
                            filt
                        );
                        s.body = body;
                        s.sensorEnabled = false;
                        s.fluidEnabled = false;
                        s.fluidProperties = prop;
                        cbtype(s.cbTypes,"");
                    
                        s = new Polygon(
                            [   Vec2.weak(106,44)   ,  Vec2.weak(101,39)   ,  Vec2.weak(99,39)   ,  Vec2.weak(44,84)   ,  Vec2.weak(83,76)   ,  Vec2.weak(93,72)   ,  Vec2.weak(101,64)   ,  Vec2.weak(106,53)   ],
                            mat,
                            filt
                        );
                        s.body = body;
                        s.sensorEnabled = false;
                        s.fluidEnabled = false;
                        s.fluidProperties = prop;
                        cbtype(s.cbTypes,"");
                    
                        s = new Polygon(
                            [   Vec2.weak(124,6)   ,  Vec2.weak(122,4)   ,  Vec2.weak(116,5)   ,  Vec2.weak(110,11)   ,  Vec2.weak(110,25)   ,  Vec2.weak(112,25)   ,  Vec2.weak(121,16)   ,  Vec2.weak(124,10)   ],
                            mat,
                            filt
                        );
                        s.body = body;
                        s.sensorEnabled = false;
                        s.fluidEnabled = false;
                        s.fluidProperties = prop;
                        cbtype(s.cbTypes,"");
                    
                        s = new Polygon(
                            [   Vec2.weak(10,66)   ,  Vec2.weak(22,75)   ,  Vec2.weak(29,77)   ,  Vec2.weak(20,36)   ,  Vec2.weak(8,40)   ,  Vec2.weak(4,53)   ],
                            mat,
                            filt
                        );
                        s.body = body;
                        s.sensorEnabled = false;
                        s.fluidEnabled = false;
                        s.fluidProperties = prop;
                        cbtype(s.cbTypes,"");
                    
                        s = new Polygon(
                            [   Vec2.weak(29,30)   ,  Vec2.weak(21,34)   ,  Vec2.weak(20,36)   ,  Vec2.weak(29,77)   ,  Vec2.weak(44,84)   ,  Vec2.weak(41,32)   ,  Vec2.weak(39,30)   ],
                            mat,
                            filt
                        );
                        s.body = body;
                        s.sensorEnabled = false;
                        s.fluidEnabled = false;
                        s.fluidProperties = prop;
                        cbtype(s.cbTypes,"");
                    
                        s = new Polygon(
                            [   Vec2.weak(5,43)   ,  Vec2.weak(4,53)   ,  Vec2.weak(8,40)   ],
                            mat,
                            filt
                        );
                        s.body = body;
                        s.sensorEnabled = false;
                        s.fluidEnabled = false;
                        s.fluidProperties = prop;
                        cbtype(s.cbTypes,"");
                    
                        s = new Polygon(
                            [   Vec2.weak(81,80)   ,  Vec2.weak(83,76)   ,  Vec2.weak(44,84)   ,  Vec2.weak(67,84)   ],
                            mat,
                            filt
                        );
                        s.body = body;
                        s.sensorEnabled = false;
                        s.fluidEnabled = false;
                        s.fluidProperties = prop;
                        cbtype(s.cbTypes,"");
                    
                        s = new Polygon(
                            [   Vec2.weak(50,28)   ,  Vec2.weak(44,32)   ,  Vec2.weak(68,30)   ,  Vec2.weak(53,28)   ],
                            mat,
                            filt
                        );
                        s.body = body;
                        s.sensorEnabled = false;
                        s.fluidEnabled = false;
                        s.fluidProperties = prop;
                        cbtype(s.cbTypes,"");
                    
                        s = new Polygon(
                            [   Vec2.weak(30,80)   ,  Vec2.weak(44,84)   ,  Vec2.weak(29,77)   ],
                            mat,
                            filt
                        );
                        s.body = body;
                        s.sensorEnabled = false;
                        s.fluidEnabled = false;
                        s.fluidProperties = prop;
                        cbtype(s.cbTypes,"");
                    
                        s = new Polygon(
                            [   Vec2.weak(82,32)   ,  Vec2.weak(41,32)   ,  Vec2.weak(44,84)   ,  Vec2.weak(99,39)   ,  Vec2.weak(94,36)   ],
                            mat,
                            filt
                        );
                        s.body = body;
                        s.sensorEnabled = false;
                        s.fluidEnabled = false;
                        s.fluidProperties = prop;
                        cbtype(s.cbTypes,"");
                    
                        s = new Polygon(
                            [   Vec2.weak(110,11)   ,  Vec2.weak(100,30)   ,  Vec2.weak(99,37)   ,  Vec2.weak(110,25)   ],
                            mat,
                            filt
                        );
                        s.body = body;
                        s.sensorEnabled = false;
                        s.fluidEnabled = false;
                        s.fluidProperties = prop;
                        cbtype(s.cbTypes,"");
                    
                        s = new Polygon(
                            [   Vec2.weak(100,30)   ,  Vec2.weak(94,36)   ,  Vec2.weak(99,37)   ],
                            mat,
                            filt
                        );
                        s.body = body;
                        s.sensorEnabled = false;
                        s.fluidEnabled = false;
                        s.fluidProperties = prop;
                        cbtype(s.cbTypes,"");
                    
                        s = new Polygon(
                            [   Vec2.weak(99,37)   ,  Vec2.weak(94,36)   ,  Vec2.weak(99,39)   ],
                            mat,
                            filt
                        );
                        s.body = body;
                        s.sensorEnabled = false;
                        s.fluidEnabled = false;
                        s.fluidProperties = prop;
                        cbtype(s.cbTypes,"");
                    
                
            

            anchor = (true) ? body.localCOM.copy() : Vec2.get(0,88);
            body.translateShapes(Vec2.weak(-anchor.x,-anchor.y));
            body.position.setxy(0,0);

            bodies["icecream"] = new BodyPair(body,anchor);
        
            body = new Body();
            cbtype(body.cbTypes,"");

            
                mat = material("bouncy");
                filt = filter("default");
                prop = fprop("default");

                
                    
                        s = new Polygon(
                            [   Vec2.weak(22,2)   ,  Vec2.weak(10,8)   ,  Vec2.weak(8,12)   ,  Vec2.weak(55,22)   ,  Vec2.weak(53,15)   ,  Vec2.weak(46,7)   ,  Vec2.weak(36,2)   ],
                            mat,
                            filt
                        );
                        s.body = body;
                        s.sensorEnabled = false;
                        s.fluidEnabled = false;
                        s.fluidProperties = prop;
                        cbtype(s.cbTypes,"");
                    
                        s = new Polygon(
                            [   Vec2.weak(11,52)   ,  Vec2.weak(23,57)   ,  Vec2.weak(35,57)   ,  Vec2.weak(44,53)   ,  Vec2.weak(50,48)   ,  Vec2.weak(5,14)   ,  Vec2.weak(1,36)   ,  Vec2.weak(4,44)   ],
                            mat,
                            filt
                        );
                        s.body = body;
                        s.sensorEnabled = false;
                        s.fluidEnabled = false;
                        s.fluidProperties = prop;
                        cbtype(s.cbTypes,"");
                    
                        s = new Polygon(
                            [   Vec2.weak(1,24)   ,  Vec2.weak(1,36)   ,  Vec2.weak(5,14)   ],
                            mat,
                            filt
                        );
                        s.body = body;
                        s.sensorEnabled = false;
                        s.fluidEnabled = false;
                        s.fluidProperties = prop;
                        cbtype(s.cbTypes,"");
                    
                        s = new Polygon(
                            [   Vec2.weak(57,34)   ,  Vec2.weak(57,24)   ,  Vec2.weak(55,22)   ,  Vec2.weak(8,12)   ,  Vec2.weak(5,14)   ,  Vec2.weak(50,48)   ],
                            mat,
                            filt
                        );
                        s.body = body;
                        s.sensorEnabled = false;
                        s.fluidEnabled = false;
                        s.fluidProperties = prop;
                        cbtype(s.cbTypes,"");
                    
                
            

            anchor = (true) ? body.localCOM.copy() : Vec2.get(0,59);
            body.translateShapes(Vec2.weak(-anchor.x,-anchor.y));
            body.position.setxy(0,0);

            bodies["orange"] = new BodyPair(body,anchor);
        
            body = new Body();
            cbtype(body.cbTypes,"");

            
                mat = material("default");
                filt = filter("default");
                prop = fprop("default");

                
                    s = new Circle(
                        25.0199920063936,
                        Vec2.weak(24.0872865350687,24.6204933572602),
                        mat,
                        filt
                    );
                    s.body = body;
                    s.sensorEnabled = false;
                    s.fluidEnabled = false;
                    s.fluidProperties = prop;
                    cbtype(s.cbTypes,"");
                
            

            anchor = (true) ? body.localCOM.copy() : Vec2.get(0,49);
            body.translateShapes(Vec2.weak(-anchor.x,-anchor.y));
            body.position.setxy(0,0);

            bodies["holeCircle"] = new BodyPair(body,anchor);
        
            body = new Body();
            cbtype(body.cbTypes,"");

            
                mat = material("default");
                filt = filter("default");
                prop = fprop("default");

                
                    
                        s = new Polygon(
                            [   Vec2.weak(0,32)   ,  Vec2.weak(64,32)   ,  Vec2.weak(64,0)   ,  Vec2.weak(0,0)   ],
                            mat,
                            filt
                        );
                        s.body = body;
                        s.sensorEnabled = false;
                        s.fluidEnabled = false;
                        s.fluidProperties = prop;
                        cbtype(s.cbTypes,"");
                    
                
            

            anchor = (true) ? body.localCOM.copy() : Vec2.get(0,32);
            body.translateShapes(Vec2.weak(-anchor.x,-anchor.y));
            body.position.setxy(0,0);

            bodies["movingWall"] = new BodyPair(body,anchor);
        
    }
}
}

import nape.phys.Body;
import nape.geom.Vec2;

class BodyPair {
    public var body:Body;
    public var anchor:Vec2;
    public function BodyPair(body:Body,anchor:Vec2):void {
        this.body = body;
        this.anchor = anchor;
    }
}
