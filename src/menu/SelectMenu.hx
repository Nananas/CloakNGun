
package menu;

import com.haxepunk.Scene;
import com.haxepunk.graphics.Text;
import com.haxepunk.HXP;

import entities.TheCloak;
import entities.TheGun;
import entities.Box;

import entities.Snow;


class SelectMenu extends Scene
{

	private var welcomeText 	:Text;
	private var switchCC 		:Bool;

	private var cloak 			:TheCloak;
	private var gun 			:TheGun;

	private var snow 			:Snow;

	public override function begin ()
	{
		trace("startup SelectMenu");

		// show text on screen
		welcomeText = new Text("Press [O] to ready, press [U] to switch");
		addGraphic(welcomeText,-HXP.height-20,HXP.width / 2 - welcomeText.width / 2, 10);

		InputHandler.init(2);

		// create cloak and gun, so the joysticks are initialised
		cloak = new TheCloak(70,HXP.height/2);
		gun = new TheGun(HXP.width - 70, HXP.height/2);
		add(cloak);
		add(gun);

		// wall between them and around
		var b:Box = new Box(0,0,HXP.width,50);
		add(b);
		var b:Box = new Box(0,0,50,HXP.height);
		add(b);
		// bottom
		var b:Box = new Box(0,HXP.height - 50, 120, 50);
		add(b);
		var b:Box = new Box(HXP.width - 120, HXP.height - 50, 120, 50);
		add(b);
		var b:Box = new Box(0,HXP.height - 20,HXP.width,25);
		add(b);
		var b:Box = new Box(HXP.width - 50, 0, 50, HXP.height);
		add(b);
		var b:Box = new Box(Std.int(HXP.width/2 - 25), 0, 50, HXP.height);
		add(b);


		snow = new Snow();
		add(snow);

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

		super.update();
	}

	private function GC()
	{
		cloak = null;
		gun = null;
		snow = null;
	}
}