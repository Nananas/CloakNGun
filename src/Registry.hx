
package ;

class Registry 
{

	static public var theCloakControllerNumber:Int = 1;
	static public var theGunControllerNumber:Int = 0;

	static public var score:Array<Int> = [0,0];

	static public function switchCC()
	{
		theCloakControllerNumber = 1 - theCloakControllerNumber;
		theGunControllerNumber = 1 - theGunControllerNumber;
	}
}