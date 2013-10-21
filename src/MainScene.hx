import com.haxepunk.Scene;
import com.haxepunk.HXP;
import com.haxepunk.Entity;
import com.haxepunk.graphics.Image;
import com.haxepunk.graphics.Text;
import com.haxepunk.utils.Input;

import entities.*;
import InputHandler;


class MainScene extends Scene
{
	private var theGun:TheGun;
	private var theCloak:TheCloak;

	private var _theGunSpeed:Float = 0.5;
	private var _theCloakSpeed:Float = 0.3;
	
	private var PGText:Text;
	private var PCText:Text; 

	private var PGEnt:Entity;
	private var PCEnt:Entity;

	private var scoreText:Text;

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

		// 
		var b:Box = new Box(0,-10,HXP.width,20);
		add(b);

		var b:Box = new Box(0,0,5,HXP.height);
		add(b);

		var b:Box = new Box(0,HXP.height - 10, HXP.width, 20);
		add(b);

		var b:Box = new Box(HXP.width - 5, 0, 5, HXP.height);
		add(b);

		var b:Box = new Box(Std.int(HXP.width/2 - 10), Std.int(HXP.height/2 - 50),20,100);
		add(b);

		var b:Box = new Box(Std.int(HXP.width/2 - 50), Std.int(HXP.height/2 - 10),100,20);
		add(b);

		var b:Box = new Box(40,40,40,20);
		add(b);

		var b:Box = new Box(Std.int(HXP.width - 80),40,40,20);
		add(b);

		var b:Box = new Box(40,Std.int(HXP.height - 60),40,20);
		add(b);

		var b:Box = new Box(Std.int(HXP.width - 80),Std.int(HXP.height - 60),40,20);
		add(b);


	}

	public override function update()
	{

		// fade out those player numbers
		PGText.alpha -= 0.01;
		PGEnt.x = theGun.x; PGEnt.y = theGun.y;
		PCText.alpha -= 0.01;
		PCEnt.x = theCloak.x; PCEnt.y = theCloak.y;

		if (PGText.alpha == 0){
			remove(PGEnt);
			remove(PCEnt);
		}

		if (Input.lastKey == 16777234){
			Input.lastKey = 0;
			HXP.scene = new MainScene();
		}

		if (theGun.finished && theCloak.finished){
			// show end game stuff

			HXP.scene = new MainScene();

			// switchControllers
			Registry.switchCC();
		}

		super.update();
	}
}