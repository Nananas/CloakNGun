
package entities;

import com.haxepunk.Entity;
import com.haxepunk.graphics.Image;
import flash.geom.Point;

class BlueParticles extends Entity
{
	private var image : Image;
	private var speed : Point;

	public function new (X:Float, Y:Float, direction:Int)
	{
		var rand : Float = Math.random();
		if (rand > 0.3)
		{
			if (rand > 0.6)	image = Image.createRect(2,2, 0x1f35ae);
			else {
				image = Image.createRect(3,3,0xff0000);
				image.alpha = 0.6;
			}

		} else {
			image = Image.createRect(2,2, 0x808fe2);
		}

		super(X,Y,image);

		speed = new Point(0,0);

		fly(direction);	

	}

	public override function update()
	{
		speed.x *= 0.95;
		speed.y *= 0.95;

		x += speed.x;
		y += speed.y;

		super.update();
	}

	private function fly(dir : Int)
	{
		if (dir == 1)	// left
		{
			speed.x = -1;
			speed.y = Math.random()*2-1;
		}
		else if (dir == 0) 		// right
		{
			speed.x = 1;
			speed.y = Math.random()*2-1;
		}

		speed.normalize(Math.random()*6);
	}

}