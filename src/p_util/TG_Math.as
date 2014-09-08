package p_util
{
	import flash.geom.Point;

	public final class TG_Math
	{
		public function TG_Math()
		{
		}
		/// This function is used to ensure that a floating point number is
		/// not a NaN or infinity.
		static public function b2IsValid(x:Number) : Boolean
		{
			return isFinite(x);
		}
		
		/*static public function b2InvSqrt(x:Number):Number{
		union
		{
		float32 x;
		int32 i;
		} convert;
		
		convert.x = x;
		float32 xhalf = 0.5f * x;
		convert.i = 0x5f3759df - (convert.i >> 1);
		x = convert.x;
		x = x * (1.5f - xhalf * x * x);
		return x;
		}*/
		
		static public function b2Dot(a:TG_Vec2, b:TG_Vec2):Number
		{
			return a.x * b.x + a.y * b.y;
		}
		
		static public function b2CrossVV(a:TG_Vec2, b:TG_Vec2):Number
		{
			return a.x * b.y - a.y * b.x;
		}
		
		static public function b2CrossVF(a:TG_Vec2, s:Number):TG_Vec2
		{
			var v:TG_Vec2 = new TG_Vec2(s * a.y, -s * a.x);
			return v;
		}
		
		static public function b2CrossFV(s:Number, a:TG_Vec2):TG_Vec2
		{
			var v:TG_Vec2 = new TG_Vec2(-s * a.y, s * a.x);
			return v;
		}
		
		
		
		
		
		static public function AddVV(a:TG_Vec2, b:TG_Vec2):TG_Vec2
		{
			var v:TG_Vec2 = new TG_Vec2(a.x + b.x, a.y + b.y);
			return v;
		}
		
		static public function SubtractVV(a:TG_Vec2, b:TG_Vec2):TG_Vec2
		{
			var v:TG_Vec2 = new TG_Vec2(a.x - b.x, a.y - b.y);
			return v;
		}
		
		static public function b2Distance(a:TG_Vec2, b:TG_Vec2) : Number{
			var cX:Number = a.x-b.x;
			var cY:Number = a.y-b.y;
			return Math.sqrt(cX*cX + cY*cY);
		}
		
		static public function b2DistanceSquared(a:TG_Vec2, b:TG_Vec2) : Number{
			var cX:Number = a.x-b.x;
			var cY:Number = a.y-b.y;
			return (cX*cX + cY*cY);
		}
		
		static public function MulFV(s:Number, a:TG_Vec2):TG_Vec2
		{
			var v:TG_Vec2 = new TG_Vec2(s * a.x, s * a.y);
			return v;
		}
		
		
		
		static public function b2Abs(a:Number):Number
		{
			return a > 0.0 ? a : -a;
		}
		
		static public function b2AbsV(a:TG_Vec2):TG_Vec2
		{
			var b:TG_Vec2 = new TG_Vec2(b2Abs(a.x), b2Abs(a.y));
			return b;
		}
		
		
		
		static public function b2Min(a:Number, b:Number):Number
		{
			return a < b ? a : b;
		}
		
		static public function b2MinV(a:TG_Vec2, b:TG_Vec2):TG_Vec2
		{
			var c:TG_Vec2 = new TG_Vec2(b2Min(a.x, b.x), b2Min(a.y, b.y));
			return c;
		}
		
		static public function b2Max(a:Number, b:Number):Number
		{
			return a > b ? a : b;
		}
		
		static public function b2MaxV(a:TG_Vec2, b:TG_Vec2):TG_Vec2
		{
			var c:TG_Vec2 = new TG_Vec2(b2Max(a.x, b.x), b2Max(a.y, b.y));
			return c;
		}
		
		static public function b2Clamp(a:Number, low:Number, high:Number):Number
		{
			return b2Max(low, b2Min(a, high));
		}
		
		static public function b2ClampV(a:TG_Vec2, low:TG_Vec2, high:TG_Vec2):TG_Vec2
		{
			return b2MaxV(low, b2MinV(a, high));
		}
		
		static public function b2Swap(a:Array, b:Array) : void
		{
			var tmp:* = a[0];
			a[0] = b[0];
			b[0] = tmp;
		}
		
		// b2Random number in range [-1,1]
		static public function b2Random():Number
		{
			return Math.random() * 2 - 1;
		}
		
		static public function b2RandomRange(lo:Number, hi:Number) : Number
		{
			var r:Number = Math.random();
			r = (hi - lo) * r + lo;
			return r;
		}
		
		// "Next Largest Power of 2
		// Given a binary integer value x, the next largest power of 2 can be computed by a SWAR algorithm
		// that recursively "folds" the upper bits into the lower bits. This process yields a bit vector with
		// the same most significant 1 as x, but all 1's below it. Adding 1 to that value yields the next
		// largest power of 2. For a 32-bit value:"
		static public function b2NextPowerOfTwo(x:uint):uint
		{
			x |= (x >> 1) & 0x7FFFFFFF;
			x |= (x >> 2) & 0x3FFFFFFF;
			x |= (x >> 4) & 0x0FFFFFFF;
			x |= (x >> 8) & 0x00FFFFFF;
			x |= (x >> 16)& 0x0000FFFF;
			return x + 1;
		}
		//Addition from Sudarmin
		// Converts radians to degrees. There are 2pi radians per 360 degrees.
		public static function radiansToDegrees(radians:Number):Number 
		{
			return (radians/Math.PI) * 180;
		}
		public static function degreesToRadians(degrees:Number):Number
		{
			return (degrees/180) * Math.PI;
		}
		
		static public function findDistance(a:Point, b:Point) : Number{
			var cX:Number = a.x-b.x;
			var cY:Number = a.y-b.y;
			return Math.sqrt(cX*cX + cY*cY);
		}
		
		// THIS IS THE FUNCTION THAT WORKS WITH KEITH'S FUNCTION TO CALCULATE THE DISTANCE OFF OF A LINE
		// returns an object containing the distance point c is from line ab (obj.dist), and the point of intersection (obj.poi)
		// obj.dist will be -1 if the perpendicular line to ab that passes through line ab would not intersect ab
		public static function getDistanceFromLine(a:Point,b:Point,c:Point,as_seg:Boolean=false):Object{
			
			//c.y *= -1; // flip for Flash
			var tempY:Number = c.y * -1;
			var obj:Object = new Object();
			obj.dist = -1;
			obj.pt = new Point();			
			var m:Number = (a.y-b.y)/(a.x-b.x);
			var B:Number = (1/m)*c.x - tempY;
			var d:Point = new Point(b.x,b.x*(-1/m)+B);
			var e:Point = new Point(a.x,a.x*(-1/m)+B);
			var poi:Point = lineIntersectLine(a,b,d,e,as_seg); // use Keith's function to check for an intersection
			if(poi != null){
				var dx:Number = poi.x - c.x, dy:Number = poi.y + tempY;
				obj.dist = Math.floor(Math.pow(dx * dx + dy * dy, .5));
				obj.poi = poi;
			}
			return obj;
		}
		
		// Keith Hair's line intersection function
		public static function lineIntersectLine(A:Point,B:Point,E:Point,F:Point,as_seg:Boolean=false):Point {
			var ip:Point;
			var a1:Number;
			var a2:Number;
			var b1:Number;
			var b2:Number;
			var c1:Number;
			var c2:Number;
			
			a1= B.y-A.y;
			b1= A.x-B.x;
			c1= B.x*A.y - A.x*B.y;
			a2= F.y-E.y;
			b2= E.x-F.x;
			c2= F.x*E.y - E.x*F.y;
			
			var denom:Number=a1*b2 - a2*b1;
			if (denom == 0) {
				return null;
			}
			ip=new Point();
			ip.x=(b1*c2 - b2*c1)/denom;
			ip.y=(a2*c1 - a1*c2)/denom;
			
			//---------------------------------------------------
			//Do checks to see if intersection to endpoints
			//distance is longer than actual Segments.
			//Return null if it is with any.
			//---------------------------------------------------
			if(as_seg){
				if(Math.pow(ip.x - B.x, 2) + Math.pow(ip.y - B.y, 2) > Math.pow(A.x - B.x, 2) + Math.pow(A.y - B.y, 2)){
					return null;
				}
				if(Math.pow(ip.x - A.x, 2) + Math.pow(ip.y - A.y, 2) > Math.pow(A.x - B.x, 2) + Math.pow(A.y - B.y, 2)){
					return null;
				}		 
				if(Math.pow(ip.x - F.x, 2) + Math.pow(ip.y - F.y, 2) > Math.pow(E.x - F.x, 2) + Math.pow(E.y - F.y, 2)){
					return null;
				}
				if(Math.pow(ip.x - E.x, 2) + Math.pow(ip.y - E.y, 2) > Math.pow(E.x - F.x, 2) + Math.pow(E.y - F.y, 2)){
					return null;
				}
			}
			return ip;
		}
		
		static public const TG_Vec2_zero:TG_Vec2 = new TG_Vec2(0.0, 0.0);
	}
}