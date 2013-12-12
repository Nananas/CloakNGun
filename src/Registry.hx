package ;

import com.haxepunk.HXP;
import com.haxepunk.Scene;
import entities.Map;

class Maps
{
	public static var mapCount : Int = 2;
	public static var Cross : Map = new Map("Cross");
	public static var Boxes : Map = new Map("Boxes");

	public static function loadMaps()
	{
		// --Cross
		Cross.addBox(0, -10, HXP.width, 20);
		Cross.addBox(0, 0, 10, HXP.height);
		Cross.addBox(0, HXP.height-10, HXP.width, 20);
		Cross.addBox(HXP.width-5, 0, 5, HXP.height);
		Cross.addBox(HXP.width/2 - 10, HXP.height/2 - 50,20,100);
		Cross.addBox(HXP.width/2 - 50,HXP.height/2 - 10,100,20);
		Cross.addBox(40,40,40,20);
		Cross.addBox(HXP.width - 80,40,40,20);
		Cross.addBox(40,HXP.height - 60,40,20);
		Cross.addBox(HXP.width - 80,HXP.height - 60,40,20);

		// --Boxes
		Boxes.addBox(0, -10, HXP.width, 20);
		Boxes.addBox(0, 0, 5, HXP.height);
		Boxes.addBox(0, HXP.height-10, HXP.width, 20);
		Boxes.addBox(HXP.width-5, 0, 5, HXP.height);
		for (i in 0...4) {
			for (ii in 0...4) {
				Boxes.addBox((HXP.width-40)/5*(i+1), (HXP.height-20)/3*(ii)-1,25,25);
			}
		}
	}
}

class Registry 
{
	static public var selectScene : menu.SelectMenu;
	static public var playScene : MainScene;

	static public var tiles_Top : flash.display.BitmapData;
	static public var tiles_Wall : flash.display.BitmapData;

	static public function loadScenes()
	{
		// load tiles
		tiles_Top = openfl.Assets.getBitmapData("graphics/Tiles_Top.png");
		tiles_Wall = openfl.Assets.getBitmapData("graphics/Tiles_Wall.png");

		selectScene = new menu.SelectMenu();
		selectScene.init();
		playScene = new MainScene();
		playScene.init();
	}


	static public var theCloakControllerNumber:Int = 1;
	static public var theGunControllerNumber:Int = 0;

	static public var score:Array<Int> = [0,0];

	static public function switchCC()
	{
		theCloakControllerNumber = 1 - theCloakControllerNumber;
		theGunControllerNumber = 1 - theGunControllerNumber;
	}

	// default map is Cross for now
	static public var currentMap : Map = Maps.Cross;
	static public var currentMapID : Int = 1;

	static public function getMapByID (ID : Int) : Map
	{
		switch (ID) {
			case 1: return Maps.Cross;
			case 2: return Maps.Boxes;
			default: return Maps.Boxes;
		}

	}

	public static var loopMaps : Bool = true;
	private static var loopCount : Int = 1;
	public static function nextMap(scene : Scene) : Void
	{ 
		if (loopMaps)
		{
			// let both players play as both characters in each map
			loopCount ++;
			if (loopCount > 2)
			{
				loopCount = 1;
				// remove last map
				currentMap.remove(scene);
				
				changeCurrentMap();

				// build new map
				currentMap.build(scene);
			}
		}
	}

	public static function changeCurrentMap()
	{
		currentMapID ++;
		if (currentMapID > Maps.mapCount) currentMapID = 1;
		currentMap = getMapByID(currentMapID);
	}

	public static var cloakSkill : Int = 1;
	public static var gunSkill : Int = 1;

}


