
package entities;

import com.haxepunk.Entity;
import entities.Trap;

class GunsLockTrap extends Trap
{
	private var lockTimer 	:Int;
	private var locked 		:Bool;
	private var target 		:TheCloak;

	public function new (X:Int, Y:Int)
	{
		super (X,Y,"thecloak");
		trace(trackType);
		locked = false;
		lockTimer = 60;
	}	

	public override function update()
	{
		super.update();

		if (locked && target != null){
			lockTimer -= 1;
			target.lock();
		}

		if (lockTimer < 0) {
			target.unlock();
			scene.remove(this);
			// explode?
		}
	}

	private override function activate(e:Entity)
	{
		target = cast(e,TheCloak);
		trace ("locking position of object "+e);

		locked = true;

	}

}