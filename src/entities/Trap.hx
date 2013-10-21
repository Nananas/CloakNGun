
package entities;

import com.haxepunk.Entity;
import com.haxepunk.graphics.Image;


class Trap extends Entity
{
	private var image 		:Image;
	private var trackType 	:String;

	public function new (X:Int, Y:Int, track:String)
	{
		super(X,Y);
		image = Image.createCircle(10,0x000000,0.5);
		image.centerOrigin();
		image.originY = -5;

		graphic = image;

		setHitbox(2,2);
		centerOrigin();

		trackType = track;
		type = "trap";
	}

	public override function update()
	{
		// check collision with entity
		if (collide(trackType,x,y) != null){
			var e:Entity = cast(collide(trackType,x,y), Entity);
			activate(e);
		}

		super.update();
	}

	private function activate(e:Entity){ 
		trace("activated trap");
	}

}