package p_util
{
	import flash.display.Sprite;
	

/// A 2D column vector.

public final class TG_Vec2
{
	public final function TG_Vec2(x_:Number=0, y_:Number=0) : void {x=x_; y=y_;};

	public final function SetZero() : void { x = 0.0; y = 0.0; }
	public final function Set(x_:Number=0, y_:Number=0) : void {x=x_; y=y_;};
	public final function SetV(v:TG_Vec2) : void {x=v.x; y=v.y;};

	public final function Negative():TG_Vec2 { return new TG_Vec2(-x, -y); }
	
	static public function Make(x_:Number, y_:Number):TG_Vec2
	{
		return new TG_Vec2(x_, y_);
	}
	
	public final function Copy():TG_Vec2{
		return new TG_Vec2(x,y);
	}
	
	public final function Add(v:TG_Vec2) : void
	{
		x += v.x; y += v.y;
	}
	
	public final function Subtract(v:TG_Vec2) : void
	{
		x -= v.x; y -= v.y;
	}

	public final function Multiply(a:Number) : void
	{
		x *= a; y *= a;
	}
	
	
	
	public final function CrossVF(s:Number) : void
	{
		var tX:Number = x;
		x = s * y;
		y = -s * tX;
	}
	
	public final function CrossFV(s:Number) : void
	{
		var tX:Number = x;
		x = -s * y;
		y = s * tX;
	}
	
	public final function MinV(b:TG_Vec2) : void
	{
		x = x < b.x ? x : b.x;
		y = y < b.y ? y : b.y;
	}
	
	public final function MaxV(b:TG_Vec2) : void
	{
		x = x > b.x ? x : b.x;
		y = y > b.y ? y : b.y;
	}
	
	public final function Abs() : void
	{
		if (x < 0) x = -x;
		if (y < 0) y = -y;
	}

	public final function Length():Number
	{
		return Math.sqrt(x * x + y * y);
	}
	
	public final function LengthSquared():Number
	{
		return (x * x + y * y);
	}

	public final function Normalize():Number
	{
		var length:Number = Math.sqrt(x * x + y * y);
		if (length < Number.MIN_VALUE)
		{
			return 0.0;
		}
		var invLength:Number = 1.0 / length;
		x *= invLength;
		y *= invLength;
		
		return length;
	}

	//Addition from Sudarmin
	public final function rotate(degree:Number):void
	{
		var radians:Number = TG_Math.degreesToRadians(degree);
		var a:Number = (x * Math.cos(radians)) - (y * Math.sin(radians));
		var b:Number = (x * Math.sin(radians)) + (y * Math.cos(radians));
		
		x = a;
		y = b;
	}
	public final function rotate2(radians:Number):void
	{
		
		var a:Number = (x * Math.cos(radians)) - (y * Math.sin(radians));
		var b:Number = (x * Math.sin(radians)) + (y * Math.cos(radians));
		
		x = a;
		y = b;
	}
	
	
	public static function vectorTransform(degree:Number, oldVector:TG_Vec2):TG_Vec2
		{
		
			
			var radians:Number = TG_Math.degreesToRadians(degree);
			var a:Number = (oldVector.x * Math.cos(radians)) - (oldVector.y * Math.sin(radians));
			var b:Number = (oldVector.x * Math.sin(radians)) + (oldVector.y * Math.cos(radians));
			var vector:TG_Vec2 = new TG_Vec2();
			vector.x = a;
			vector.y = b;
			return vector;
			
		
		}
		
	public static function vectorToRotation(vector1:TG_Vec2,vector2:TG_Vec2):Number
		{
			var vectorLength1:Number = vector1.Length();
			var vectorLength2:Number = vector2.Length();
			var normalized1:Number = vector1.Normalize();
			var normalized2:Number = vector2.Normalize();
			var vectorDotProduct:Number = TG_Math.b2Dot(vector1,vector2);
			var lengthTimesLength:Number = vectorLength1 * vectorLength2;
			var angleInRad:Number = Math.acos((vectorDotProduct / lengthTimesLength));
			var angleInDeg:Number = TG_Math.radiansToDegrees(angleInRad);
			
			//cross product (clockwise or counter-clockwise)
			var cross:Number = (vector1.x * vector2.y) - (vector2.x * vector1.y);
			if (cross < 0) // vec1 rotate clockwise to vec2
			{
				angleInDeg *= -1;
			}
			if(isNaN(angleInDeg))
				{
					angleInDeg = 0;
				}
			
			return angleInDeg;
			
			/* if(clip.angle<90 && clip.angle>-90)
			clip._rotation = clip.angle+angleInDeg;
			else
			clip._rotation = clip.angle-angleInDeg; */
			
		}
	
	

	public var x:Number;
	public var y:Number;
};

}