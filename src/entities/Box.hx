
package entities;

import com.haxepunk.Entity;
import com.haxepunk.graphics.Graphiclist;
import com.haxepunk.graphics.Image;


class Box extends Entity
{
	private var image:Graphiclist;

	public function new (X:Int, Y:Int, w:Int, h:Int)
	{
		super(X,Y);

		image = new Graphiclist();
		var i:Image = Image.createRect(w,h,0x000000);
		i.originY = -6;
		image.add(i);

		var i:Image = Image.createRect(w,h,0x666666);
		i.originY = 6;
		image.add(i);

		graphic = image;

		setHitbox(w, h);

		type = "wall";

		layer = Std.int(-(y+h));

		active = false;
	}
	

}