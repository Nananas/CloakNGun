import com.haxepunk.Scene;
import com.haxepunk.HXP;
import com.haxepunk.Entity;
import com.haxepunk.graphics.Image;
import com.haxepunk.graphics.Text;
import com.haxepunk.utils.Input;

import entities.*;
import Registry.Maps;
import InputHandler;


class MainScene extends Scene
{
	private var theGun:TheGun;
	private var theCloak:TheCloak;
	
	private var PGText:Text;
	private var PCText:Text; 

	private var PGEnt:Entity;
	private var PCEnt:Entity;

	private var scoreText:Text;

	private var snow : Snow;

	public override function begin()
	{
		trace("beginning game");
		//InputHandler.init(2);

		theGun = new TheGun(HXP.width-40, HXP.height/2);
		theCloak = new TheCloak(40,HXP.height/2);
		add(theGun);
		add(theCloak);

		// show player number symbols
		PGText = new Text("P"+(Registry.theGunControllerNumber+1), 0, -20);
		PGText.size = 32;
		PCText = new Text("P"+(Registry.theCloakControllerNumber+1), 0, -20);
		PCText.size = 32;

		PGEnt = addGraphic(PGText, 5, theGun.x, theGun.y);
		PCEnt = addGraphic(PCText, 5, theCloak.x, theCloak.y);

		scoreText = new Text("P1: " +Registry.score[0] + "  |  P2: "+Registry.score[1]);
		scoreText.size = 24;
		addGraphic(scoreText,1,HXP.width / 2,10);

		//build chosen map 
		Registry.currentMap.build(this);

		Input.lastKey = 0;

		snow = new Snow();
		add(snow);
	}

	private function reset ()
	{
		// switchControllers
		Registry.switchCC();

		var gclist : Array<Dynamic> = new Array<Dynamic>();

		theGun.reset();
		theGun.x = HXP.width - 40;
		theGun.y = HXP.height / 2;

		theCloak.reset();
		theCloak.x = 40;
		theCloak.y = HXP.height / 2;

		PGText.text = "P" + Registry.theGunControllerNumber + 1;
		PGText.x = theGun.x;
		PGText.y = theGun.y;
		PGText.alpha = 1;

		PCText.text = "P" + Registry.theCloakControllerNumber + 1;
		PCText.x = theCloak.x;
		PCText.y = theCloak.y;
		PCText.alpha = 1;

		scoreText.text = "P1: " +Registry.score[0] + "  |  P2: "+Registry.score[1];

		getClass(BlueParticles, gclist);
		getClass(GunsLockTrap, gclist);

		for (i in gclist) {
			remove(i);
		}

		if (Registry.loopMaps)
		{
			// remove last map
			Registry.currentMap.remove(this);

			// build next map
			Registry.nextMap();
			Registry.currentMap.build(this);
		}
	}

	public override function update()
	{
		if (PGText.alpha > 0)
		{
			// fade out those player numbers
			PGText.alpha -= 0.02;
			PGEnt.x = theGun.x; PGEnt.y = theGun.y;
			PCText.alpha -= 0.02;
			PCEnt.x = theCloak.x; PCEnt.y = theCloak.y;			
		}

		//if (PGText.alpha == 0){
		//	remove(PGEnt);
		//	remove(PCEnt);
		//}

		if (Input.lastKey == 16777234){
			Input.lastKey = 0;
			HXP.scene = new menu.SelectMenu();
		}

		if (theGun.finished && theCloak.finished){

			// restart scene
			//HXP.scene = new MainScene();
			reset();
			
		}

		super.update();
	}


	// does a memory leak cause lag??
	override public function end() : Void
	{
		removeAll();
	}
}