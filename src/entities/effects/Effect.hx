
package entities.effects;

import com.haxepunk.Entity;

class Effect extends Entity
{
	private var _currentEffect : WeatherEffect;
	private var _effectList : Array<WeatherEffect>;

	public function new (type : Effects)
	{
		super(0,0);

		_effectList = new Array<WeatherEffect>();

		var snow : Snow = new Snow();
		var rain : Rain = new Rain();

		_effectList.push(snow);
		_effectList.push(rain);

		// randomise effect to be used
		switch (type) {
			case SNOW:
				_currentEffect = new Snow();
			case RAIN:
				_currentEffect = new Rain();
		}

	}

	override public function added ()
	{
		scene.add(_currentEffect);
	}

	public override function update()
	{
		// update current effects
		_currentEffect.update();

		// this can be extended to show multiple different effects
	}
	
	private function switchEffect()
	{
		for (i in _effectList) {
			i.toggle();
		}
	}

}

enum Effects
{
	SNOW;
	RAIN;
}