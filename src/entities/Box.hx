
package entities;

import com.haxepunk.Entity;
import com.haxepunk.graphics.Graphiclist;
import com.haxepunk.graphics.Image;

import openfl.Assets;

import flash.display.BitmapData;
import flash.geom.Rectangle;

class Box extends Entity
{
	private var image:Graphiclist;
	private var _maxHeight : Int = 40;
	private var _maxWidth : Int = 400;

	public function new (X:Int, Y:Int, w:Int, h:Int)
	{
		super(X,Y);
		trace("haha");
		loadImage(w,h);

		setHitbox(w, h);

		type = "wall";

		layer = Std.int(-(y+h));

		active = false;
	}
	

	private function loadImage(w : Int, h : Int)
	{
		image = new Graphiclist();
		

		// var i:Image = Image.createRect(w,h,0x000000);	
		// i.originY = -6;

		// top
		var data : BitmapData = new BitmapData(w,h,false);
		var hh : Int = h;

		while (hh>_maxHeight)
		{
			hh -= _maxHeight;
			var rect : Rectangle = new Rectangle (Std.int(Math.random()*(_maxWidth - w)),0,w,_maxHeight);
			data.copyPixels(Registry.tiles_Top, rect, new flash.geom.Point(0, hh));
		}

		var rect : Rectangle = new Rectangle (Std.int(Math.random()*(_maxWidth - w)),0,w,hh);
		data.copyPixels(Registry.tiles_Top, rect, new flash.geom.Point(0, 0));

		var i : Image = new Image(data);
		i.originY = 6;
		image.add(i);
		

		// wall
		var data : BitmapData = new BitmapData(w,13,false);
		var rect : Rectangle = new Rectangle(Std.int(Math.random()*(_maxWidth - w)),0,w,13);
		data.copyPixels(Registry.tiles_Wall, rect, new flash.geom.Point(0,0));

		var i : Image = new Image(data);
		i.originY = -h + 7;
		image.add(i);

		// var i:Image = Image.createRect(w,h,0x666666);	
		// i.originY = 6;
		// image.add(i);

		// shadow
		var i:Image = Image.createRect(w,6,0x000000);
		i.alpha = 0.1;
		i.originY = -6 - h;
		image.add(i);

		graphic = image;
	}
}