
package entities;

import com.haxepunk.Entity;
import com.haxepunk.graphics.Image;
import com.haxepunk.graphics.Spritemap;
import com.haxepunk.graphics.Graphiclist;
import com.haxepunk.math.Vector;
import com.haxepunk.HXP;

import com.haxepunk.utils.Input;
import com.haxepunk.utils.Joystick.OUYA_GAMEPAD;

class TheCloak extends Entity
{
	private var _dodgeTimer:Float = 3;
	private var _dodgeSpeed:Float = 6;
	private var _acc:Float = 0.4;
	private var _maxSpeed:Float=0.4;
	private var image:Graphiclist;
	private var animation:Spritemap;
	private var shadow:Image;

	private var speed:Vector;

	private var canDodge:Bool;
	private var dodgeTimer:Float;

	private var hasToShow:Bool;
	private var showTimer:Float;
	private var runTimer:Int;
	private var _isRunning : Bool;
	private var _shadow : CloakGhost;
	private var _skillTimer : Int;
	private var _telePosition : Vector;

	private var indicator:Image;
	private var _skillIndicator:Image;
	private var teleIndicator : Image;

	private var locked :Bool = false;


	private var idleTimer:Int = 0;

	// end game flags
	private var endgame:Bool;

	public var finished:Bool;
	public var controllerNumber:Int = 1;

	private var _skillID : Int;

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


		_shadow = new CloakGhost();
		indicator = Image.createRect(4,4,0x555555);
		_skillIndicator = Image.createRect(2,2,0x555555);
		_skillTimer = 0;
		_skillID = Registry.cloakSkill;
		setColor();
		_telePosition = new Vector(0,0);

		speed = new Vector(0,0);
		canDodge = true;
		dodgeTimer = 0;
		hasToShow = true;
		showTimer = 0;
		_isRunning = false;

		type = "thecloak";
		name = "thecloak";

		endgame = false;
		finished = false;

	}

	override public function added()
	{
		scene.addGraphic(indicator,-300,HXP.width/2 - 95, HXP.height - 10);
		if (_skillID == 1 || _skillID == 3) 	// ghost or teleport
		{
			scene.addGraphic(_skillIndicator,-300,HXP.width/2 - 100, HXP.height - 10 + 1);
			scene.add(_shadow);
		}
	}

	override public function update()
	{
		if (!endgame){
			if (_skillID == 1 || _skillID == 3) 	// ghost or teleport
			{
				if (_skillTimer >= 0) 	// unable to do skill
				{
					_skillTimer --;
					_skillIndicator.color = 0x000000;

				} else {				// able to do skill
					if (_skillID == 3){ // if skill is teleport, show indication of active positino
						if (_telePosition.length > 0){
							// active
							_skillIndicator.color = 0x555555;
						} else {
							// position still needs to be set
							_skillIndicator.color = 0xffffff;
						}
					} else if (_skillID== 1){
						_skillIndicator.color = 0xffffff;
					}
				}
			}


			// Skill
			if (Input.joystick(Registry.theCloakControllerNumber).pressed(OUYA_GAMEPAD.RIGHT_TRIGGER_BUTTON)) doSkill();

			// run logic
			if (runTimer >= 0 && runTimer < 600 && Input.joystick(Registry.theCloakControllerNumber).getAxis(OUYA_GAMEPAD.LEFT_TRIGGER) < 0.15){
				runTimer += 2;
				indicator.color = 0x555555;
			}else{
				indicator.color = 0x000000;
			}

			var extra:Int = 1;
			if (runTimer >= 10){
				// can run
				if (Input.joystick(Registry.theCloakControllerNumber).getAxis(OUYA_GAMEPAD.LEFT_TRIGGER) > 0.15){
					extra = 4;
					runTimer-= 10;
				}
			}

			if (extra == 4)
				_isRunning = true;
			else
				_isRunning = false;

			if (runTimer > 300)	indicator.color = 0xffffff;
			
			// alpha calculations
			if (extra == 4){ 	// running
				animation.alpha = 0.5;
				shadow.alpha = 0.2;
				idleTimer = 10*30;
			}else if (hasToShow || locked){ 	// trapped or selectscreen
				animation.alpha = 0.1;
				shadow.alpha = 0.05;
				idleTimer = 10*30;
			}else if (speed.length < _maxSpeed * 2){	// invisible
				animation.alpha = 0;
				shadow.alpha=0;
				idleTimer--;
				if (idleTimer < 0){
					idleTimer = 10*30;
					show();
				}
			}else{ 			// dashing (speed > maxspeed * 2)
				animation.alpha = 0.05;
				shadow.alpha = 0.03;
				idleTimer = 10*30;
			}

			// dodge logic
			if (canDodge){
				// check right joystick axis
				if (Input.joystick(Registry.theCloakControllerNumber).getAxis(OUYA_GAMEPAD.RIGHT_ANALOGUE_X) != 0 || Input.joystick(Registry.theCloakControllerNumber).getAxis(OUYA_GAMEPAD.RIGHT_ANALOGUE_Y) != 0){
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
				speed.x += Input.joystick(Registry.theCloakControllerNumber).getAxis(OUYA_GAMEPAD.LEFT_ANALOGUE_X) * _acc * extra;
				speed.y += Input.joystick(Registry.theCloakControllerNumber).getAxis(OUYA_GAMEPAD.LEFT_ANALOGUE_Y) * _acc * extra;
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
			}else if (_isRunning){
				animation.play("run",false);
			}else{
				animation.play("walk",false);
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

	public function isImmune() : Bool
	{
		return (_skillID==2 && speed.length > _maxSpeed && !_isRunning);
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

		// reset teleport
		_telePosition.x = 0;
		_telePosition.y = 0;

		finished = false;
		endgame = false;

		_skillID = Registry.cloakSkill;
	}

	public function switchSkill ()
	{
		_skillID ++;
		if (_skillID>3)
		{
			_skillID = 1;
		}

		setColor();

		Registry.cloakSkill = _skillID;
	}

	public function lock(){ locked = true;}
	public function unlock(){locked = false;}

	// ------------------------------
	//--------------------------------
	private function dodge(){
		canDodge = false;
		dodgeTimer = _dodgeTimer;
		var v:Vector = new Vector(Input.joystick(Registry.theCloakControllerNumber).getAxis(OUYA_GAMEPAD.RIGHT_ANALOGUE_X), 
									Input.joystick(Registry.theCloakControllerNumber).getAxis(OUYA_GAMEPAD.RIGHT_ANALOGUE_Y));
		v.normalize(1);
		speed.x += v.x * _dodgeSpeed;
		speed.y += v.y * _dodgeSpeed;
	}

	private function doSkill()
	{
		if (_skillTimer < 0)
		{
			if (_skillID == 1){	// ghost
				shootShadow();
				_skillTimer = 30*10;
			} else if (_skillID == 3)	// teleport
				doTeleport();
			
		}


		// dodge roll is not an active skill
		// so do nothing
	}

	private function shootShadow()
	{
		var sp : Vector = new Vector(speed.x, speed.y);
		sp.normalize(_maxSpeed*4);

		_shadow.shoot(x,y,sp.x, sp.y);
	}

	private function doTeleport()
	{
		// set teleport or teleport to position
		trace("teleporting");

		if (_telePosition.length == 0)
		{
			// set next teleport position
			_telePosition.x = x;
			_telePosition.y = y;
		} else {
			//teleport to the set teleport position
			x = _telePosition.x;
			y = _telePosition.y;

			// reset last teleport position
			_telePosition.x = 0;
			_telePosition.y = 0;

			// only set timer when actually teleporting
			_skillTimer = 30*10;

			// show for an instant
			show();
		}
	}

	private function setColor()
	{
		switch (_skillID) {
			case 1: // ghost
				animation.color = 0xffffff;
				_shadow.setColor(0xffffff);
			case 2: // dodge roll
				animation.color = 0xDBAB76;
				_shadow.setColor(0xDBAB76);
			case 3: // teleport
				animation.color = 0x71DB53;
				_shadow.setColor(0x71DB53);
		}
	}

	private function sign(i:Dynamic):Int{
		if (i>0) return 1;
		else if (i==0) return 0;
		return -1;
	}
}