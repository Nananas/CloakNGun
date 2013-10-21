
package entities;

import com.haxepunk.Entity;
import com.haxepunk.graphics.Image;
import com.haxepunk.graphics.Spritemap;
import com.haxepunk.graphics.Graphiclist;
import com.haxepunk.math.Vector;
import com.haxepunk.HXP;
import com.haxepunk.utils.Input;
import com.haxepunk.graphics.Emitter;

import entities.Bullet;

class TheGun extends Entity
{
	private var _bulletVelocity:Float = 6;
	private var _acc:Float = 1;
	private var _maxSpeed:Float = 1;

	private var animation:Spritemap;
	private var speed:Vector;

	private var angle:Float;

	private var image:Graphiclist;
	private var gunImage:Image;
	private var gunEntity:Entity;
	private var shadow:Image;

	private var shootTimer:Float;
	private var _shootTimer:Float = 1.5;
	private var canShoot:Bool;

	private var originOffset:Int;

	private var bulletContainer:Int;
	private var bulletRegenTimer:Int;

	private var indicator:Image;

	// end game flag
	private var endgame:Bool;
	public var finished:Bool;

	public var controllerNumber:Int = 0;

	public function new (X:Float, Y:Float)
	{
		super (X,Y);
		setHitbox(7,14);
		originOffset = 0;	// used for offsetting the origin of the gun when flipping

		// images
		shadow = Image.createCircle(3,0x000000);
		shadow.originY = -12;
		shadow.originX = -1;
		shadow.alpha = 0.7;
		animation = new Spritemap("graphics/TheGun_body.png",8,15);

		
		animation.add("stand",[0]);
		animation.add("walk",[1,2,3,4],8);
		animation.add("win",[5,6,5,6,5,6],3,false);
		animation.play("stand");


		image = new Graphiclist([shadow,animation]);

		gunImage = new Image("graphics/TheGun_gun.png");
		indicator = Image.createRect(4,4,0xffffff);
		speed = new Vector(0,0);

		graphic = image;

		// variables
		canShoot = false;
		shootTimer = _shootTimer;
		angle = 0;


		bulletContainer = 1;
		bulletRegenTimer = 0;

		var Fdown = function (id:Int){
			if (id==7){
				if (canShoot && !endgame){
					var b:Bullet = new entities.Bullet(x+3,y+7,Math.cos(angle) * _bulletVelocity, Math.sin(angle)*_bulletVelocity, angle);
					scene.add(b);
					bulletContainer--;
					shootTimer = _shootTimer;
				}
			}
		}

		InputHandler.initButtons(Registry.theGunControllerNumber, Fdown);

		type = "thegun";
		name = "thegun";

		endgame = false;
		finished = false;
	}

	override public function added()
	{
		gunEntity = scene.addGraphic(gunImage);
		gunEntity.originY = 1;

		scene.addGraphic(indicator, - 300, HXP.width / 2 - 10, HXP.height - 20);
	}
	override public function update ()
	{
		// do not update anything except animations when in endgame state
		if (!endgame){

			// bullet regen logic
			if (bulletContainer < 2){
				if (bulletRegenTimer <= 0){
					// regen bullet
					bulletContainer += 1;
					bulletRegenTimer = 180;
				} else {
					bulletRegenTimer--;
				}
			}

			canShoot = false;
			if (bulletContainer >= 1) canShoot = true;

			if (bulletContainer == 0){
				indicator.color = 0x000000;
			}else if (bulletContainer == 1){
				indicator.color = 0x555555;
			}else if (bulletContainer== 2){
				indicator.color = 0xffffff;
			}

			// aim logic
			if (InputHandler.getAxis(Registry.theGunControllerNumber,1).length > 0.20){
				angle = Math.atan2(InputHandler.getAxis(Registry.theGunControllerNumber,1).y, InputHandler.getAxis(Registry.theGunControllerNumber,1).x);
			}

			// updating gun angle
			gunImage.angle = - angle * 180 / 3.141592;



			// position logic
			speed.x *= 0.9;
			speed.y *= 0.9;


			speed.x += InputHandler.getAxis(Registry.theGunControllerNumber).x*_acc;
			speed.y += InputHandler.getAxis(Registry.theGunControllerNumber).y*_acc;

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
			if (speed.length > 0.5){
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
			gunImage.layer = layer;

			// gun position logic
			gunEntity.x = x + 1 + originOffset;
			gunEntity.y = y + 7;

			// end game logic
			if (collide("thecloak",x,y) != null) {
				var tc:entities.TheCloak = cast(collide("thecloak",x,y),entities.TheCloak);
				if (x>tc.x){
					tc.winGame(0);
				}else{
					tc.winGame(1);
				}
				loseGame();
			}

		} else {
			gunImage.layer = layer;
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

	public function winGame(){
		endgame = true;

		//show animation
		animation.play("win");

		// thow gun away
		gunImage.originX = 4;
		gunImage.originY = 1;
		gunImage.layer = 13;
		speed.setTo(Math.random()-0.5,-2);

		// update score
		Registry.score[Registry.theGunControllerNumber] += 1;

	}
	
	public function loseGame(){
		// play die animation, this animation has a callback
		endgame = true;

		// no animation, emit particles instead
		finished = true;	// delete this, i guess

		// throw the gun away, change origin to middel
		gunImage.originX = 4;
		gunImage.originY = 1;
		gunImage.layer = 13;

		// use speed
		speed.setTo(Math.random()-0.5,-2);
	}

	private function sign(i:Dynamic):Int{
		if (i>0) return 1;
		else if (i==0) return 0;
		return -1;
	}
}