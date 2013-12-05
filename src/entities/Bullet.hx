
package entities;

import com.haxepunk.Entity;
import com.haxepunk.graphics.Image;
import com.haxepunk.HXP;

import entities.BulletParticle;
import entities.TheGun;
import entities.TheCloak;

class Bullet extends Entity
{
	private var image:Image;
	private var shadow:Image;
	private var shadowEnt:Entity;

	private var vx:Float;
	private var vy:Float;

	private var _explode : Float->Float ->Void;
	private var _emit : Float->Float ->Void;

	public function new (X:Float, Y:Float, vX:Float, vY:Float, angle:Float,exp:Dynamic,em:Dynamic)
	{
		_explode = exp;
		_emit = em;

		super(X,Y);

		setHitbox(6,6,3,3);
		originX = 3;
		originY = 3;

		image = Image.createRect(8,4,0x456789);
		image.originX =  4;
		image.originY =  2;
		image.angle = - angle * 180 / 3.141592;

		shadow = Image.createRect(4,2,0x000000,0.3);
		shadow.centerOrigin();
		shadow.angle = image.angle;

		graphic = image;

		vx = vX;
		vy = vY;

		type = "bullet";
	}

	public override function added()
	{
		shadowEnt = scene.addGraphic(shadow,layer,x,y+6);

	}
	
	override public function update()
	{
		if (collide("thecloak",x,y) != null){
			var tc:TheCloak = cast(collide("thecloak",x,y), TheCloak);
			tc.loseGame();
			var tg:TheGun = cast(scene.getInstance("thegun"),TheGun);
			tg.winGame();

			explode();

			scene.remove(this);
			scene.remove(shadowEnt);
		}

		if (collide("wall",x,y) != null){
			x -= vx;
			y -= vy;
			explode();
			scene.remove(this);
			scene.remove(shadowEnt);
		}

			setHitbox(2,2,1,1);
			if (collide("thegun", x,y) != null){
				image.alpha = 0;
			}else{
				image.alpha = 1;
			}
			setHitbox(6,6,3,3);


		// emit particles

		// var p:BulletParticle = new BulletParticle(x,y);
		// p.layer = layer;
		// scene.add(p);
		// var q:BulletParticle = new BulletParticle(x,y);
		// q.layer = layer;
		// scene.add(q);
		emit();

		x += vx;
		y += vy;
		
		if (x<-20) scene.remove(this);
		else if (x>HXP.width + 20) scene.remove(this);
		else if (y< -20) scene.remove(this);
		else if (y> HXP.height + 20) scene.remove(this);

		layer = Std.int(-y);

		// shadow
		shadowEnt.x = x;
		shadowEnt.y = y + 6;
		shadow.layer = layer+1;

		super.update();
	}

	private function explode()
	{
		// for (i in 0...20) {
		// 	var p:BulletParticle = new BulletParticle(x,y,3);
		// 	p.layer = layer;
		// 	scene.add(p);
		// }
		_explode(x,y);
			
	}

	private function emit()
	{
		_emit(x,y);
	}
}