
package ;

class Registry 
{

	static public var theCloakControllerNumber:Int = 1;
	static public var theGunControllerNumber:Int = 0;

	static public var score:Array<Int> = [0,0];

	static public function switchCC()
	{
		if (theCloakControllerNumber == 1){
			theCloakControllerNumber = 0;
			theGunControllerNumber = 1;
		} else {
			theCloakControllerNumber = 1;
			theGunControllerNumber = 0;
		}
	}
}