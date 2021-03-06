
package entities;

import com.haxepunk.Entity;
import com.haxepunk.graphics.Image;
import com.haxepunk.graphics.Spritemap;
import com.haxepunk.graphics.Graphiclist;
import com.haxepunk.math.Vector;
import com.haxepunk.HXP;
import com.haxepunk.utils.Input;
import com.haxepunk.graphics.Emitter;

import com.haxepunk.utils.Joystick.OUYA_GAMEPAD;

import entities.BulletParticle;
import entities.Bullet;
import entities.GunsLockTrap;

class TheGun extends Entity
{
	private var _bulletVelocity:Float = 5;
	private var _acc:Float = 0.3;
	private var _maxSpeed:Float = 1;

	private var animation:Spritemap;
	private var speed:Vector;

	private var angle:Float;

	private var image:Graphiclist;
	private var gunImage:Image;
	private var gunEntity:Entity;
	private var shadow:Image;

	private var shootTimer:Float;
	private var _shootTimer:Float = 3;
	private var canShoot:Bool;

	private var originOffset:Int;

	private var bulletContainer:Int;
	private var bulletRegenTimer:Int;

	private var indicator:Image;

	private var _hasTrap:Bool;

	// end game flag
	private var endgame:Bool;
	public var finished:Bool;

	public var controllerNumber:Int = 0;

	private var particleContainer : Array<BulletParticle>;
	private var inactiveParticles : Array<BulletParticle>;

	private var _KeyDownCallback : Int -> Void;  

	public function new (X:Float, Y:Float)
	{
		super (X,Y);
		setHitbox(7,14);
		originOffset = 0;	// used for offsetting the origin of the gun when flipping

		// images
		image = new Graphiclist();

		shadow = Image.createCircle(3,0x000000);
		shadow.originY = -12;
		shadow.originX = -1;
		shadow.alpha = 0.2;
		image.add(shadow);

		animation = new Spritemap("graphics/TheGun_body.png",8,15);
		animation.add("stand",[0]);
		animation.add("walk",[1,2,3,4],8);
		animation.add("win",[5,6,5,6,5,6],3,false);
		animation.play("stand");
		image.add(animation);

		gunImage = new Image("graphics/TheGun_gun.png");
		indicator = Image.createRect(4,4,0xffffff);
		speed = new Vector(0,0);

		graphic = image;

		// variables
		canShoot = false;
		shootTimer = _shootTimer;
		angle = 0;

		_hasTrap = true;

		bulletContainer = 1;
		bulletRegenTimer = 0;

		type = "thegun";
		name = "thegun";

		endgame = false;
		finished = false;

		particleContainer = new Array<BulletParticle>();
		inactiveParticles = new Array<BulletParticle>();

		for (i in 0...200){
			var p : BulletParticle = new BulletParticle(0,0);
			inactiveParticles.push(p);
		}
		
	}

	override public function added()
	{
		gunEntity = scene.addGraphic(gunImage);
		gunEntity.originY = 1;

		scene.addGraphic(indicator, - 300, HXP.width / 2 + 100, HXP.height - 10);
		for (i in inactiveParticles) {
			scene.add(i);
		}
	}
	override public function update ()
	{
		// do not update anything except animations when in endgame state
		if (!endgame){

			for (p in particleContainer) {
				if (p.inactive)
				{
					particleContainer.remove(p);
					inactiveParticles.push(p);
				}
			}

			// Skill
			if (Input.joystick(Registry.theGunControllerNumber).pressed(OUYA_GAMEPAD.O_BUTTON)) doTrap();

			// bullet regen logic
			if (bulletContainer < 2){
				if (bulletRegenTimer <= 0){
					// regen bullet
					bulletContainer += 1;
					bulletRegenTimer = 90;
				} else {
					bulletRegenTimer--;
				}
			}

			canShoot = false;
			if (bulletContainer >= 1) canShoot = true;
			// Shoot
			if (canShoot){
				if (Input.joystick(Registry.theGunControllerNumber).pressed(OUYA_GAMEPAD.RB_BUTTON)){
					var b:Bullet = new entities.Bullet(x+3,y+7,Math.cos(angle) * _bulletVelocity, Math.sin(angle)*_bulletVelocity, angle, explode, emit);
					scene.add(b);
					bulletContainer--;
					shootTimer = _shootTimer;
				}
				
			}

			if (bulletContainer == 0){
				indicator.color = 0x000000;
			}else if (bulletContainer == 1){
				indicator.color = 0x555555;
			}else if (bulletContainer== 2){
				indicator.color = 0xffffff;
			}

			// aim logic
			if (Input.joystick(Registry.theGunControllerNumber).getAxis(OUYA_GAMEPAD.RIGHT_ANALOGUE_X) != 0 || Input.joystick(Registry.theGunControllerNumber).getAxis(OUYA_GAMEPAD.RIGHT_ANALOGUE_Y) != 0){
				angle = Math.atan2(Input.joystick(Registry.theGunControllerNumber).getAxis(OUYA_GAMEPAD.RIGHT_ANALOGUE_Y),
									Input.joystick(Registry.theGunControllerNumber).getAxis(OUYA_GAMEPAD.RIGHT_ANALOGUE_X));
			}

			// updating gun angle
			gunImage.angle = - angle * 180 / 3.141592;



			// position logic
			speed.x *= 0.9;
			speed.y *= 0.9;


			speed.x += Input.joystick(Registry.theGunControllerNumber).getAxis(OUYA_GAMEPAD.LEFT_ANALOGUE_X)*_acc;
			speed.y += Input.joystick(Registry.theGunControllerNumber).getAxis(OUYA_GAMEPAD.LEFT_ANALOGUE_Y)*_acc;

			if (speed.length > _maxSpeed) speed.normalize(_maxSpeed);


			// animation, VFX logic
			if (angle > Math.PI/2 || angle < -Math.PI/2 ){
				// mirror image
				animation.flipped = true;
				gunImage.flipped = true;
				// offset gun origin
				originOffset = 6;
				// mirror angle
				gunImage.angle -= 180;
			}else{
				// no mirror
				animation.flipped = false;
				gunImage.flipped = false;
				// no offset
				originOffset = 0;
			}

			// animate
			if (speed.length > 0.2){
				animation.play("walk", false);
			} else {
				animation.play("stand");
			}

			// collision with walls
			if (collide("wall",x+speed.x,y) != null){
				var i:Int = Std.int(Math.abs(speed.x)) *2;
				while(collide("wall",x+sign(speed.x)/2,y) == null){
					x+=sign(speed.x)/2;
					i--;
					if (i<0) break;
				}
				speed.x = 0;
			}
			if (collide("wall",x,y+speed.y) != null){
				var i:Int = Std.int(Math.abs(speed.y))*2;
				while(collide("wall",x,y+sign(speed.y)/2) == null){
					y+= sign(speed.y)/2;
					i--;
					if (i<0) break;
				}
				speed.y = 0;
			} 

			x += speed.x;
			y += speed.y;

			layer = Std.int(-(y+animation.height));
			gunEntity.layer = layer;

			// gun position logic
			gunEntity.x = x + 1 + originOffset;
			gunEntity.y = y + 7;

			// end game logic
			if (collide("thecloak",x,y) != null && !endgame) {
				var tc:entities.TheCloak = cast(collide("thecloak",x,y),entities.TheCloak);
				if (x>tc.x){
					tc.winGame(0);
					loseGame(0);
				}else{
					tc.winGame(1);
					loseGame(1);
				}
			}

		} else {
			gunEntity.layer = layer;
			// check if the endgame animation is complete
			if (animation.complete) finished = true;

			// still update gun position
			if (gunEntity.y < y + 10){
				gunEntity.x += speed.x;
				gunEntity.y += speed.y;

				speed.y += 0.1;
				gunImage.angle += 10;
			} else {
				gunImage.angle = 0;
			}
		}
		super.update();
	}

	private function emit(xx:Float, yy:Float)
	{
		if (inactiveParticles.length>0)
		{
			var p : BulletParticle = inactiveParticles.pop();
			particleContainer.push(p);
			p.emit(xx,yy);
			var q : BulletParticle = inactiveParticles.pop();
			particleContainer.push(q);
			q.emit(xx,yy);
		}
	}

	private function explode(xx:Float, yy:Float)
	{
		for (i in 0...20) {
			if (inactiveParticles.length>0)
			{
				var p : BulletParticle = inactiveParticles.pop();
				p.emit(xx,yy,3);
				particleContainer.push(p);
			}
		}
	}
	public function winGame(){
		endgame = true;

		//show animation
		animation.play("win");

		// thow gun away
		gunImage.originX = 4;
		gunImage.originY = 1;
		gunEntity.layer = 13;
		speed.setTo(Math.random()-0.5,-2);

		// update score
		Registry.score[Registry.theGunControllerNumber] += 1;

	}
	
	public function loseGame(dir : Int){
		visible = false;

		// play die animation, this animation has a callback
		endgame = true;

		// no animation, emit particles instead
		finished = true;	// delete this, i guess

		// no animation, emit particles instead
		for (i in 0...20) {
			var particle : BlueParticles = new BlueParticles(x+width/2,y+height/2,dir);
			scene.add(particle);
		}

		// throw the gun away, change origin to middel
		gunImage.originX = 4;
		gunImage.originY = 1;
		gunEntity.layer = 13;

		// use speed for gun
		speed.setTo(Math.random()-1,-4);
	}

	public function reset()
	{
		visible = true;
		finished = false;
		endgame = false;
		_hasTrap = true;
		angle = 0;

		gunImage.originX = 0;
		gunImage.originY = 0;
	}

	private function doTrap()
	{
		if (_hasTrap)
		{
			var trap:GunsLockTrap = new GunsLockTrap(Std.int(x+width/2), Std.int(y+height)+1);
			scene.add(trap);
			_hasTrap = false;
		} else if (collide("trap", x, y) != null){
			var trap : GunsLockTrap = cast(collide("trap", x, y), GunsLockTrap);
			scene.remove(trap);

			_hasTrap = true;
		}
	}

	private function sign(i:Dynamic):Int{
		if (i>0) return 1;
		else if (i==0) return 0;
		return -1;
	}
}