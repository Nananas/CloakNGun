
package entities.effects;

import com.haxepunk.Entity;
import com.haxepunk.graphics.Emitter;

class WeatherEffect extends Entity
{

	public var shouldEmit : Bool;

	public function new (emitter : Emitter)
	{
		shouldEmit = true;
		layer = -400;

		super (0,0,emitter);
	}

	public override function update()
	{
		if (shouldEmit)
		{
			tick();
		}
	}

	public function toggle()
	{
		shouldEmit = !shouldEmit;
	}

	private function tick()
	{
		// override this
	}
}