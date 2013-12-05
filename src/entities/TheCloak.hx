
package entities;

import com.haxepunk.Entity;
import com.haxepunk.graphics.Image;
import com.haxepunk.graphics.Spritemap;
import com.haxepunk.graphics.Graphiclist;
import com.haxepunk.math.Vector;
import com.haxepunk.HXP;

class TheCloak extends Entity
{
	private var _dodgeTimer:Float = 2;
	private var _dodgeSpeed:Float = 6;
	private var _acc:Float = 0.4;
	private var _maxSpeed:Float=0.8;
	private var image:Graphiclist;
	private var animation:Spritemap;
	private var shadow:Image;

	private var speed:Vector;

	private var canDodge:Bool;
	private var dodgeTimer:Float;

	private var hasToShow:Bool;
	private var showTimer:Float;
	private var runTimer:Int;
	private var indicator:Image;
	private var shadowIndicator:Image;

	private var locked :Bool = false;

	private var _shadow : CloakGhost;
	private var _shadowTimer : Int;

	private var idleTimer:Int = 0;

	// end game flags
	private var endgame:Bool;

	public var finished:Bool;
	public var controllerNumber:Int = 1;

	private var _checkButtonPressed : Int -> Void;
	private var _checkButtonReleased : Int -> Void;

	public function new (X:Float, Y:Float)
	{
		super(X,Y);
		setHitbox(12,13);
		originX = -4;

		image = new Graphiclist();

		shadow = Image.createCircle(3,0x000000);
		shadow.originY = -10;
		shadow.originX = -7;
		shadow.alpha = 0;
		image.add(shadow);
		
		animation = new Spritemap("graphics/TheCloak_20x20x14.png",20,20);


		animation.add("run",[1,2,3,4,5,6,7,8],12);
		animation.add("walk",[1,2,3,4,5,6,7,8],8);
		animation.add("slash",[9,10,11,12,13,0,0,0,0,0,0,0,0,0,0,0,0],12,false);
		animation.add("die",[14,15,16],1,false);
		animation.add("stand",[0]);
		animation.play("stand");

		animation.alpha = 1;
		animation.originX = 2;
		animation.originY = 5;
		image.add(animation);
		

		graphic = image;


		indicator = Image.createRect(4,4,0x555555);
		shadowIndicator = Image.createRect(2,2,0x555555);

		speed = new Vector(0,0);
		canDodge = true;
		dodgeTimer = 0;
		hasToShow = true;
		showTimer = 0;

		_shadow = new CloakGhost();
		_shadowTimer = 0;

		_checkButtonPressed = function(id:Int){
			if (id==9)
			{

				shootShadow();
			}
		}

		_checkButtonReleased = function (id:Int){

		}

		InputHandler.initButtons(Registry.theCloakControllerNumber, 
								_checkButtonPressed, 	
								_checkButtonReleased);

		type = "thecloak";
		name = "thecloak";

		endgame = false;
		finished = false;
	}

	override public function added()
	{
		scene.addGraphic(indicator,-300,HXP.width/2 - 95, HXP.height - 10);
		scene.addGraphic(shadowIndicator,-300,HXP.width/2 - 100, HXP.height - 10 + 1);
		scene.add(_shadow);
	}

	override public function update()
	{
		if (!endgame){
			if (_shadowTimer >= 0)
			{
				_shadowTimer --;
				shadowIndicator.color = 0x000000;

			} else {
				shadowIndicator.color = 0xffffff;
			}


			// run logic
			if (runTimer >= 0 && runTimer < 600 && InputHandler.eventAxis[Registry.theCloakControllerNumber][17] < 0.15){
				runTimer += 2;
				indicator.color = 0x555555;
			}else{
				indicator.color = 0x000000;
			}

			var extra:Int = 1;
			if (runTimer >= 10){
				// can run
				if (InputHandler.eventAxis[Registry.theCloakControllerNumber][17] > 0.15){
					extra = 4;
					runTimer-= 10;
				}
			}

			if (runTimer > 300)	indicator.color = 0xffffff;
			
			// alpha calculations
			if (extra == 4){
				animation.alpha = 0.5;
				shadow.alpha = 0.2;
				idleTimer = 10*30;
			}else if (hasToShow || locked){
				animation.alpha = 0.1;
				shadow.alpha = 0.05;
				idleTimer = 10*30;
			}else if (speed.length < _maxSpeed * 2){
				animation.alpha = 0;
				shadow.alpha=0;
				idleTimer--;
				if (idleTimer < 0){
					idleTimer = 10*30;
					show();
				}
			}else{
				animation.alpha = 0.05;
				shadow.alpha = 0.03;
				idleTimer = 10*30;
			}

			// dodge logic
			if (canDodge){
				// check right joystick axis
				if (InputHandler.getAxis(Registry.theCloakControllerNumber,1).length > 0){
					//dodge
					dodge();
				}
			}else{
				dodgeTimer -= 1/30;
				if (dodgeTimer < 0){
					canDodge = true;
				}
			}

			speed.x *= 0.9;
			speed.y *= 0.9;

			// not too fast
			if (speed.length < _maxSpeed*extra){
				speed.x += InputHandler.getAxis(Registry.theCloakControllerNumber).x * _acc * extra;
				speed.y += InputHandler.getAxis(Registry.theCloakControllerNumber).y * _acc * extra;
			}

			// collision with walls
			if (collide("wall",x+speed.x,y) != null){
				var i:Int = Std.int(Math.abs(speed.x));
				while(collide("wall",x+sign(speed.x),y) == null){
					x+=sign(speed.x);
					i--;
					if (i<0)break;
				}
				speed.x = 0;
			}
			if (collide("wall",x,y+speed.y) != null){
				var i:Int = Std.int(Math.abs(speed.y));
				while(collide("wall",x,y+sign(speed.y)) == null){
					y+= sign(speed.y);
					i--;
					if (i<0) break;
				}
				speed.y = 0;
			} 

			//
			if (!locked){
				x += speed.x;
				y += speed.y;
			}

			// animation, VFX logic
			if (speed.length < 0.05){
				animation.play("stand");
			}else if (speed.length > _maxSpeed*2){
				animation.play("run");
			}else{
				animation.play("walk");
			}

			// change only when moving
			if (speed.x < 0){
				animation.flipped = false;
				animation.originX = 3;
			}else if (speed.x > 0){
				animation.flipped = true;
				animation.originX = -2;
			}
			

			if (showTimer >= 0) showTimer -= 1/30;
			if (showTimer < 0) hasToShow = false;
		} else {
			// the finishing strike should be visible ofc.
			animation.alpha = 1;

			if (animation.complete){
				finished = true;
				animation.frame = 0;
			}
		}

		layer = Std.int(-(y+animation.height));
		super.update();
	}

	public function show(){
		hasToShow = true;
		showTimer = 0.3;

	}


	public function winGame(facing:Int){
		endgame = true;

		animation.play("slash");

		if (facing == 0){
			animation.flipped = true;
			//animation.originX = -8;
		}else{
			animation.flipped = false;
			//animation.originX = 8;
		}

		// update score
		Registry.score[Registry.theCloakControllerNumber] += 1;
	}

	public function loseGame(){
		endgame = true;
		// show some animation or something...
		animation.play("die");
	}

	public function reset()
	{
		speed.x = 0;
		speed.y = 0;
		finished = false;
		endgame = false;
		InputHandler.initButtons(Registry.theCloakControllerNumber, 
								_checkButtonPressed, 	
								_checkButtonReleased);
	}

	public function lock(){ locked = true;}
	public function unlock(){locked = false;}

	// ------------------------------
	//--------------------------------
	private function dodge(){
		canDodge = false;
		dodgeTimer = _dodgeTimer;
		var v:Vector = InputHandler.getAxis(Registry.theCloakControllerNumber,1);
		v.normalize(1);
		speed.x += v.x * _dodgeSpeed;
		speed.y += v.y * _dodgeSpeed;
	}

	private function shootShadow()
	{
		if (_shadowTimer < 0)
		{
			var sp : Vector = new Vector(speed.x, speed.y);
			sp.normalize(_maxSpeed*4);

			_shadow.shoot(x,y,sp.x, sp.y);
			
			_shadowTimer = 30*10;
		}
	}

	private function sign(i:Dynamic):Int{
		if (i>0) return 1;
		else if (i==0) return 0;
		return -1;
	}
}