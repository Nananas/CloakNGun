package entities;

import flash.geom.Rectangle;

import com.haxepunk.graphics.Image;
import com.haxepunk.Scene;
import entities.Box;

class Map
{

	private var _name : String;
	public function getName(){ return _name; };

	public var image : Image;

	private var _boxes : Array<Box>;

	public function new (n : String, i : Image = null)
	{
		_name = n;
		image = i;

		_boxes = new Array<Box>();
	}

	public function addBox(X : Float, Y : Float, W : Float, H : Float)
	{
		var b : Box = new Box(Std.int(X), Std.int(Y), Std.int(W), Std.int(H));
		_boxes.push(b);
	}

	public function build (scene : Scene)
	{
		for (i in _boxes) {
			scene.add(i);
		}
	}

	public function remove (scene : Scene)
	{
		for (i in _boxes) {
			scene.remove(i);
		}
	}
}