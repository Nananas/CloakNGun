
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
	private var _acc:Float = 0.2;
	private var _maxSpeed:Float=0.4;
	private var image:Graphiclist;
	private var animation:Spritemap;
	private var shadow:Image;

	private var running:Bool;
	private var speed:Vector;

	private var canDodge:Bool;
	private var dodgeTimer:Float;

	private var hasToShow:Bool;
	private var showTimer:Float;
	private var runTimer:Int;
	private var indicator:Image;

	private var locked :Bool = false;
	// end game flags
	private var endgame:Bool;

	public var finished:Bool;
	public var controllerNumber:Int = 1;

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
		animation.add("stand",[0]);
		animation.add("die",[14,15,16],1,false);
		animation.play("stand");

		animation.alpha = 1;
		animation.originX = 2;
		animation.originY = 5;
		image.add(animation);
		

		graphic = image;


		indicator = Image.createRect(4,4,0x555555);

		running = false;
		speed = new Vector(0,0);
		canDodge = true;
		dodgeTimer = 0;
		hasToShow = true;
		showTimer = 0;
		

		var checkButtonPressed = function(id:Int){
			#if (!flash && !neko)
				if (id == 0) {
					running = true;
				}else{
					//trace("pressed something else : "+id);
				}
			#else
				if (id==32){
					running = true;
				}else{
					//trace ("pressed something else : "+id);
				}
			#end
		}

		var checkButtonReleased = function (id:Int){
			#if (!flash && !neko)
				if (id==0){
					running = false;
				}else{
					//trace("relased something else: "+id);
				}
			#else
				if (id==32){
					running = false;
				}else{
					//trace("released something else: "+id);
				}
			#end
		}

		InputHandler.initButtons(Registry.theCloakControllerNumber, 
								checkButtonPressed, 	
								checkButtonReleased);

		type = "thecloak";
		name = "thecloak";

		endgame = false;
		finished = false;
	}

	override public function added()
	{
		scene.addGraphic(indicator,-300,HXP.width/2 + 10, HXP.height - 20);
	}
	override public function update()
	{
		if (!endgame){

			// run logic
			if (runTimer >= 0 && runTimer < 600 && InputHandler.eventAxis[Registry.theCloakControllerNumber][18] < 0.15){
				runTimer += 2;
				indicator.color = 0x555555;
			}else{
				indicator.color = 0x000000;
			}

			var extra:Int = 1;
			if (runTimer >= 10){
				// can run
				if (InputHandler.eventAxis[Registry.theCloakControllerNumber][18] > 0.15){
					extra = 4;
					runTimer-= 10;
				}
			}

			if (runTimer > 300)	indicator.color = 0xffffff;
			
			// alpha calculations
			if (extra == 4){
				animation.alpha = 0.7;
				shadow.alpha = 0.2;
			}else if (hasToShow || locked){
				animation.alpha = 0.1;
				shadow.alpha = 0.05;
			}else if (speed.length < _maxSpeed * 2){
				animation.alpha = 0;
				shadow.alpha=0;
			}else{
				animation.alpha = 0.05;
			}

			// dodge logic
			if (canDodge){
				// check right joystick axis
				if (InputHandler.getAxis(Registry.theCloakControllerNumber,1).length > 0){
					//dodge
					dodge();
				}
			}else{
				dodgeTimer -= 1/60;
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
			

			if (showTimer >= 0) showTimer -= 1/60;
			if (showTimer < 0) hasToShow = false;
		} else {
			// the finishing strike should be visible ofc.
			animation.alpha = 1;

			if (animation.complete){
				finished = true;
				animation.frame = 16;
			}
		}

		layer = Std.int(-(y+animation.height));
		super.update();
	}

	public function show(){
		hasToShow = true;
		showTimer = 0.5;

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

	private function sign(i:Dynamic):Int{
		if (i>0) return 1;
		else if (i==0) return 0;
		return -1;
	}
}