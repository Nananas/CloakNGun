
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
		locked = false;
		lockTimer = 60;
	}	

	public override function update()
	{
		super.update();

		if (locked && target != null){
			lockTimer -= 1;
			target.lock();
		} else if (locked) {
			lockTimer -= 1;
		}

		if (lockTimer < 0 && target != null) {
			target.unlock();
			scene.remove(this);
			// explode?
		} else if (lockTimer < 0) {
			scene.remove(this);
		}
	}

	private override function activate(e:Entity = null)
	{
		super.activate();
		
		if (e != null)
		{
			target = cast(e,TheCloak);
			trace ("locking position of object "+e);

			locked = true;
			
		} else {
			trace("hoho");
			locked = true;
		}

	}

}