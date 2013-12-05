
package entities;

import com.haxepunk.Entity;
import com.haxepunk.graphics.Spritemap;

class CloakGhost extends Entity
{
	private var _timer : Int = 60;
	private var _image : Spritemap;

	private var speedX : Float;
	private var speedY : Float;

	private var _active : Bool;

	public function new ()
	{
		super(0,0);
		_image = new Spritemap("graphics/TheCloak_20x20x14.png", 20, 20);
		_image.add("run", [1,2,3,4,5,6,7,8], 8);
		_image.play("run");

		_image.alpha = 0.5;
		_image.originX = 2;
		_image.originY = 5;

		graphic = _image;

		_active = false;

		speedX = 0;
		speedY = 0;

		setHitbox(12,13);
		originX = -4;
		type = "ghost";
	}

	public override function update()
	{
		if (_active){
			visible = true;
			_timer --;

			if (_timer < 0)
			{
				_active = false;
			}

			x += speedX;
			y += speedY;

			if (collide("wall", x, y) != null)
			{
				_active = false;
				// animation or something
			}

			layer = Std.int(-y);

			super.update();
		} else {
			visible = false;
		}
	}

	public function shoot (X:Float, Y:Float, spX:Float, spY:Float)
	{
		trace("shooting");
		x = X;
		y = Y;

		speedX = spX;
		speedY = spY;

		_timer = 20;
		_active = true;

		if (speedX < 0){
			_image.flipped = false;
			_image.originX = 3;
		}else if (speedX > 0){
			_image.flipped = true;
			_image.originX = -2;
		}
	}
}