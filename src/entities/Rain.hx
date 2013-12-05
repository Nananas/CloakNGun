package entities;

import com.haxepunk.Entity;
import com.haxepunk.graphics.Image;
import com.haxepunk.HXP;
import com.haxepunk.graphics.Emitter;

class Rain extends Entity
{
	private var _speed : Float;
	private var _emitter : Emitter;
	private var _timer : Int;

	public function new ()
	{

		_timer = 0;

		_emitter = new Emitter("graphics/Rain.png",2,6);

		_emitter.newType("name");

		_emitter.setMotion("name", 260, 40, 5, 10, HXP.height+60, 10);
		_emitter.setAlpha("name", 1, 0);

		super(0,0,_emitter);

		layer = -400;
	}

	public override function update ()
	{
		_timer --;
		if (_timer < 0)
		{
			_timer = 5;
			emit();
		}
	}

	private function emit()
	{
		_emitter.emit("name", Math.random()*HXP.width, 0);
	}
}