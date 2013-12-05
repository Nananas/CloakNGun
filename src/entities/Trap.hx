
package entities;

import com.haxepunk.Entity;
import com.haxepunk.graphics.Image;
import com.haxepunk.graphics.Spritemap;

class Trap extends Entity
{
	private var image 		:Spritemap;
	private var trackType 	:String;

	public function new (X:Int, Y:Int, track:String)
	{
		super(X,Y);
		image = new Spritemap("graphics/Trap.png", 14, 14);
		image.frame = 0;
		image.centerOrigin();

		graphic = image;

		setHitbox(15,10);
		centerOrigin();

		trackType = track;
		type = "trap";
		layer = 0;
	}

	public override function update()
	{
		// check collision with entity
		if (collide(trackType,x,y) != null){
			// check if close enough
			var e:Entity = cast(collide(trackType,x,y), Entity);
			if (checkDistance(e))
			{
				activate(e);
			}
		} else  if (collide("ghost", x,y) != null)
		{
			var e:Entity = cast(collide("ghost",x,y), entities.CloakGhost);
			if (checkDistance(e))
			{
				activate();
			}
		}

		super.update();
	}

	private function activate(e:Entity = null){
		image.frame = 1;
	}

	private function checkDistance(e:Entity)
	{
		return (e.x-e.originX+e.width/2-x)*(e.x-e.originX+e.width/2-x) + (e.y + e.height/2-y)*(e.y+e.height/2-y) < height*height/2;
	}
}