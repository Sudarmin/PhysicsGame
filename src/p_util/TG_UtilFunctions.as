package p_util
{
	import flash.utils.ByteArray;
	import flash.utils.describeType;
	import flash.utils.getDefinitionByName;
	import flash.utils.getQualifiedClassName;
	
	public class TG_UtilFunctions
	{
		
		public static function newSibling(sourceObj:Object):* {
			if(sourceObj) {
				var objSibling:*;
				try {
					var classOfSourceObj:Class = getDefinitionByName(getQualifiedClassName(sourceObj)) as Class;
					objSibling = new classOfSourceObj();
				}
				catch(e:Object) {}
				
				return objSibling;
			}
			return null;
		}
		
		public static function clone(source:Object):Object {
			var clone:Object;
			if(source) {
				clone = newSibling(source);
				
				if(clone) {
					copyData(source, clone);
				}
			}
			
			return clone;
		}
			
		public static function copyData(source:Object, destination:Object):void {
			//copies data from commonly named properties and getter/setter pairs
			if((source) && (destination)) {
				try {
					var sourceInfo:XML = describeType(source);
					var prop:XML;
					
					for each(prop in sourceInfo.variable) {
						if(destination.hasOwnProperty(prop.@name)) {
							destination[prop.@name] = source[prop.@name];
						}
					}
					
					for each(prop in sourceInfo.accessor) {
						if(prop.@access == "readwrite") {
							if(destination.hasOwnProperty(prop.@name)) {
								destination[prop.@name] = source[prop.@name];
							}
						}
					}
				}
				catch (err:Object) {
					;
				}
			}
		}
		
		/**
		 * 
		 * Creates a deep copy (clone) of a reference object to a new 
		 * memory address
		 *
		 * @param   reference object in which to clone
		 * @return  a clone of the original reference object
		 * 
		 */
		public static function deepCopy(reference:*) : Object
		{
			var clone:ByteArray = new ByteArray();
			clone.writeObject( reference );
			clone.position = 0;
			
			return clone.readObject();
		}
	}
}