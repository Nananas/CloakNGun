package menu;

import com.haxepunk.Scene;
import com.haxepunk.graphics.Text;
import com.haxepunk.HXP;

import entities.TheCloak;
import entities.TheGun;
import entities.Box;
import entities.effects.Effect;
import entities.effects.Effect.Effects;

import com.haxepunk.utils.Input;
import com.haxepunk.utils.Joystick.OUYA_GAMEPAD;

import Registry.Maps;

class SelectMenu extends Scene
{

	private var welcomeText 	:Text;
	private var mapName 		:Text;
	private var nextMapMethod 	:Text;

	private var switchCC 		:Bool;

	private var cloak 			:TheCloak;
	private var gun 			:TheGun;

	private var effect 			:Effect;
	private var _currentMapID 	:Int = 1;

	public override function begin()
	{
		reset();
	}

	public function init ()
	{
		trace("startup SelectMenu");

		// show text on screen
		welcomeText = new Text("Press [O] to ready, press [U] to swap positions.\n[A] change maps. [Y] to change cycle method.");
		welcomeText.size = 8;
		addGraphic(welcomeText, - HXP.height*2,HXP.width / 2 - welcomeText.textWidth / 2, 10);
		mapName = new Text("Cross");
		mapName.size = 8;
		addGraphic(mapName, -HXP.height*2, HXP.width / 2 - mapName.textWidth / 2, HXP.height -  40);
		nextMapMethod = new Text("Repeat");
		nextMapMethod.size = 8;
		addGraphic(nextMapMethod, -HXP.height*2,HXP.width/2 - nextMapMethod.textWidth / 2, HXP.height - 50);
		Registry.cloakSkill = 1;

		// create cloak and gun, so the joysticks are initialised
		cloak = new TheCloak(70,HXP.height/2);
		gun = new TheGun(HXP.width - 70, HXP.height/2);
		add(cloak);
		add(gun);

		// wall between them and around
		var b:Box = new Box(0,0,HXP.width,50); 		//top
		add(b);
		var b:Box = new Box(0,0,50,HXP.height+10);		//left
		add(b);
		var b:Box = new Box(0,HXP.height - 50, 120, 50+6); 	//bottom
		add(b);
		var b:Box = new Box(HXP.width - 120, HXP.height - 50, 120, 50+10); 	// bottom small
		add(b);
		//var b:Box = new Box(0,HXP.height - 20,HXP.width,25);	// bottom small ?
		//add(b);
		var b:Box = new Box(HXP.width - 50, 0, 50, HXP.height+10); 	// right
		add(b);
		var b:Box = new Box(Std.int(HXP.width/2 - 25), 0, 50, HXP.height+200); // middle
		add(b);

		effect = new Effect(Effects.RAIN);
		add(effect);
		// load all other maps, this can ofc change if it takes too long to load
		Maps.loadMaps();

	#if cpp		// only one ouya gamepad can be used, enable this for debugging on cpp target
		Input.lastKey = 0;
	#end

	}

	public function reset()
	{
		cloak.reset();
		gun.reset();

		cloak.x = 70;
		cloak.y = HXP.height / 2;

		gun.x = HXP.width - 70;
		gun.y = HXP.height / 2;
	}

	public override function update ()
	{

	#if cpp		// only one ouya gamepad can be used, enable this for debugging on cpp target
		if (Input.pressed(com.haxepunk.utils.Key.SPACE)){
			Input.lastKey = 0;

			// switch character
			Registry.switchCC();
		}
	#end

		// show cloak
		cloak.show();

		// check for change button press
		if (Input.joystick(0).check(OUYA_GAMEPAD.U_BUTTON) 
			&& Input.joystick(1).check(OUYA_GAMEPAD.U_BUTTON)){

			// switch c en g
			Registry.switchCC();

			reset();
		}
		



		// change maps
		if (Input.joystick(0).pressed(OUYA_GAMEPAD.A_BUTTON))
		{
			setNextMap();
		}
		
		if (Input.joystick(0).pressed(OUYA_GAMEPAD.Y_BUTTON))
		{
			setNextmapMethod();
		}

		if (Input.joystick(Registry.theCloakControllerNumber).pressed(OUYA_GAMEPAD.U_BUTTON))
		{
			// switch skill of cloak
			cloak.switchSkill();
		}

		if (cloak.y > 230)
			cloak.y = 260;

		if (gun.y > 230)
			gun.y = 260;

		if (cloak.y > 200 && gun.y > 200){
			HXP.scene = Registry.playScene;
		}

		super.update();
	}

	private function GC()
	{
		cloak = null;
		gun = null;
		effect = null;
	}

	private function setNextMap()
	{
		Registry.changeCurrentMap();
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