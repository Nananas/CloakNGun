import com.haxepunk.Scene;
import com.haxepunk.HXP;
import com.haxepunk.Entity;
import com.haxepunk.graphics.Image;
import com.haxepunk.graphics.Text;
import com.haxepunk.utils.Input;

import entities.*;
import entities.effects.Effect;
import entities.effects.Effect.Effects;
import Registry.Maps;


class MainScene extends Scene
{
	private var theGun:TheGun;
	private var theCloak:TheCloak;
	
	private var PGText:Text;
	private var PCText:Text; 

	private var PGEnt:Entity;
	private var PCEnt:Entity;

	private var scoreText:Text;

	private var effect : Effect;

	public override function begin()
	{
		reset();
	}

	public function init()
	{

		theGun = new TheGun(HXP.width-40, HXP.height/2);
		theCloak = new TheCloak(40,HXP.height/2);
		add(theGun);
		add(theCloak);

		// show player number symbols
		PGText = new Text("P"+(Registry.theGunControllerNumber+1), 0, -20);
		PGText.size = 16;
		PCText = new Text("P"+(Registry.theCloakControllerNumber+1), 0, -20);
		PCText.size = 16;

		PGEnt = addGraphic(PGText, 5, theGun.x, theGun.y);
		PCEnt = addGraphic(PCText, 5, theCloak.x, theCloak.y);

		scoreText = new Text("P1: " +Registry.score[0] + "  |  P2: "+Registry.score[1]);
		scoreText.size = 16;
		addGraphic(scoreText,-HXP.height*2,HXP.width / 2 - scoreText.textWidth/2,HXP.height-15);

		//build chosen map 
		Registry.currentMap.build(this);

		Input.lastKey = 0;

		effect = new Effect(Effects.SNOW);
		add(effect);
	}

	private function reset ()
	{
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

/*		if (Registry.loopMaps)
		{
			// remove last map
			Registry.currentMap.remove(this);

			// build next map
			Registry.nextMap();
			Registry.currentMap.build(this);
		}
*/	
		Registry.nextMap(this);
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

	#if cpp		// only one ouya gamepad can be used, enable this for debugging on cpp target
		if (Input.pressed(com.haxepunk.utils.Key.SPACE)){
			Input.lastKey = 0;

			// switch character
			Registry.switchCC();
		}
	#else
		if (Input.lastKey == 16777234){
			Input.lastKey = 0;
			HXP.scene = Registry.selectScene;
		}
	#end
		if (theGun.finished && theCloak.finished){
			// switch the controllers
			Registry.switchCC();
			reset();
			
		}
		
		super.update();
	}
}