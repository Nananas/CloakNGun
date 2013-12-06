package menu;

import com.haxepunk.Scene;
import com.haxepunk.graphics.Text;
import com.haxepunk.HXP;

import entities.TheCloak;
import entities.TheGun;
import entities.Box;
import entities.Snow;

import Registry.Maps;

class SelectMenu extends Scene
{

	private var welcomeText 	:Text;
	private var mapName 		:Text;
	private var nextMapMethod 	:Text;

	private var switchCC 		:Bool;

	private var cloak 			:TheCloak;
	private var gun 			:TheGun;

	private var snow 			:Snow;
	private var _currentMapID 	:Int = 1;

	public override function begin ()
	{
		trace("startup SelectMenu");

		// show text on screen
		welcomeText = new Text("Press [O] to ready, press [U] to swap positions. [A] change maps. [Y] to change next map method");
		addGraphic(welcomeText,-HXP.height-20,HXP.width / 2 - welcomeText.width / 2, 10);

		mapName = new Text("Cross");
		addGraphic(mapName, -HXP.height - 80, HXP.width / 2 - mapName.width / 2, HXP.height -  40);

		nextMapMethod = new Text("Repeat");
		addGraphic(nextMapMethod, -HXP.height-100,HXP.width/2 - nextMapMethod.width / 2, HXP.height - 50);

		InputHandler.init(2);

		// create cloak and gun, so the joysticks are initialised
		cloak = new TheCloak(70,HXP.height/2);
		gun = new TheGun(HXP.width - 70, HXP.height/2);
		add(cloak);
		add(gun);

		// wall between them and around
		var b:Box = new Box(0,0,HXP.width,50); 		//top
		add(b);
		var b:Box = new Box(0,0,50,HXP.height);		//left
		add(b);
		var b:Box = new Box(0,HXP.height - 50, 120, 50); 	//bottom
		add(b);
		var b:Box = new Box(HXP.width - 120, HXP.height - 50, 120, 50); 	// bottom small
		add(b);
		var b:Box = new Box(0,HXP.height - 20,HXP.width,25);	// bottom small ?
		add(b);
		var b:Box = new Box(HXP.width - 50, 0, 50, HXP.height); 	// right
		add(b);
		var b:Box = new Box(Std.int(HXP.width/2 - 25), 0, 50, HXP.height); // middle
		add(b);


		snow = new Snow();
		add(snow);

		// load all other maps, this can ofc change if it takes too long to load
		Maps.loadMaps();
	}

	public override function update ()
	{
		
		// show cloak
		cloak.show();

		// check for change button press
		if (InputHandler.checkButton(InputHandler.OuyaKeyCode.KEY_U,0) 
			&& InputHandler.checkButton(InputHandler.OuyaKeyCode.KEY_U,1)){

			// switch c en c
			Registry.switchCC();

			// garbage collect
			GC();
			HXP.scene = new menu.SelectMenu();
		}

		// change maps
		if (InputHandler.wasButtonJustPressed(InputHandler.OuyaKeyCode.KEY_A,0))
		{
			setNextMap();
		}
		
		if (InputHandler.wasButtonJustPressed(InputHandler.OuyaKeyCode.KEY_Y,0))
		{
			setNextmapMethod();
		}

		// check for ready state
		if (cloak.y > 180){
			trace("cloak ready");
		}
		if (gun.y > 180){
			trace("gun ready");
		}

		if (cloak.y > 180 && gun.y > 180){
			trace("lets go");
			HXP.scene = new MainScene();
		}

		InputHandler.update();
		super.update();
	}

	private function GC()
	{
		cloak = null;
		gun = null;
		snow = null;
	}

	private function setNextMap()
	{
		Registry.nextMap();
		mapName.text = Registry.currentMap.getName();
	}

	private function setNextmapMethod()
	{
		Registry.loopMaps = !Registry.loopMaps;
		if (Registry.loopMaps)
		{
			nextMapMethod.text = "Loop";
		} else {
			nextMapMethod.text = "Repeat";
		}
	}
}