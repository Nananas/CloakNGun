
package entities;

import com.haxepunk.Entity;
import com.haxepunk.graphics.Image;
import com.haxepunk.math.Vector;

import entities.TheCloak;

class BulletParticle extends Entity
{
	private var image:Image;
	private var speed:Vector;
	private var _alphaVelocity:Float;
	public var inactive : Bool;

	public function new (X:Float, Y:Float)
	{
		super(X,Y);
		setHitbox(2,2);
		// randomise color a bit
		if (Math.random()*3>2)
			image = Image.createRect(2,2,0x345678);
		else if (Math.random()*2>1)
			image = Image.createRect(2,2,0x343678);
		else
			image = Image.createRect(2,2,0x346578);
			
		graphic = image;

		speed = new Vector(0,0);

		inactive = true;
	}
	
	override public function update()
	{
		if (!inactive)
		{
			if (collide("thecloak",x,y) != null){
				var tc:TheCloak = cast(collide("thecloak",x,y),TheCloak);
				tc.show();
				inactive = true;
			}

			if (collide("wall",x,y) != null){
				var e:Entity = collide("wall",x,y);
				var yy:Float = y - speed.y;
				var xx:Float = x - speed.x;
				if (yy+height>e.y && yy < e.y + e.height) {
					speed.x *= -1;
				}else if (xx+width>e.x && xx < e.x + e.width) {
					speed.y *= -1;
				}else{
					speed.x *= -1;
					speed.y *= -1;
				}
			}

			x += speed.x;
			y += speed.y;

			speed.x *= 0.90;
			speed.y *= 0.90;

			image.alpha = Math.sqrt(speed.length / _alphaVelocity);

			if (speed.length < 0.01){
			 	inactive = true;
			}

			super.update();
		} else {
			image.alpha = 0;
		}
	}

	public function emit(X:Float, Y:Float, extra:Int = 1)
	{
		x=X;
		y=Y;
		speed.setTo(Math.random()*4*extra-2*extra, Math.random()*4*extra-2*extra);
		_alphaVelocity = speed.length;
		inactive = false;
	}

}