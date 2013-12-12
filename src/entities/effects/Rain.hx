package entities.effects;

import com.haxepunk.Entity;
import com.haxepunk.graphics.Image;
import com.haxepunk.HXP;
import com.haxepunk.graphics.Emitter;

class Rain extends WeatherEffect
{
	private var _speed : Float;
	private var _emitter : Emitter;
	private var _timer : Int;

	public function new ()
	{

		_timer = 0;

		_emitter = new Emitter("graphics/Rain.png",1,8);

		_emitter.newType("normal");

		_emitter.setMotion("normal", 260, 40, 1, 10, HXP.height+60, 1);
		_emitter.setAlpha("normal", 0.5, 0);

		super(_emitter);

		layer = -400;
	}

	public override function tick ()
	{
		_timer --;
		if (_timer < 0)
		{
			_timer = 5;
			emit();
			emit();
			emit();
		}
	}

	private function emit()
	{
		_emitter.emit("normal", Math.random()*HXP.width, 0);
	}
}