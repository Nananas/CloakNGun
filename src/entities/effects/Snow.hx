package entities.effects;

import com.haxepunk.Entity;
import com.haxepunk.graphics.Image;
import com.haxepunk.HXP;
import com.haxepunk.graphics.Emitter;

class Snow extends WeatherEffect
{
	private var _speed : Float;
	private var _emitter : Emitter;
	private var _timer : Int;

	public function new ()
	{

		_timer = 0;

		_emitter = new Emitter("graphics/Snow.png",4,4);

		_emitter.newType("one", [0]);
		_emitter.newType("two", [1]);
		_emitter.newType("three", [2]);

		_emitter.setMotion("one", 260, 40, 5, 20, HXP.height+60, 10);
		_emitter.setAlpha("one", 0.7, 0);
		_emitter.setMotion("two", 260, 40, 5, 20, HXP.height+60, 10);
		_emitter.setAlpha("two", 0.6, 0);
		_emitter.setMotion("three", 260, 40, 5, 20, HXP.height+60, 10);
		_emitter.setAlpha("three", 0.7, 0);

		super(_emitter);

		layer = -400;
		
	}

	public override function tick ()
	{
		_timer --;
		if (_timer < 0)
		{
			_timer = 3;
			emit();
		}
	}

	private function emit()
	{
		var rand : Float = Math.random();
		if (rand > 0.6)	_emitter.emit("one", Math.random()*HXP.width, 0);
		else if (rand > 0.3) _emitter.emit("two", Math.random()*HXP.width, 0);
		else _emitter.emit("three", Math.random()*HXP.width, 0);
	}
}