import com.haxepunk.HXP;
import com.haxepunk.math.Vector;



#if (!flash && !neko)
import openfl.events.JoystickEvent;
import tv.ouya.console.api.OuyaController;
import openfl.utils.JNI;

class OuyaKeyCode
{
	public inline static var KEY_O = 0;
	public inline static var KEY_U = 3;
	public inline static var KEY_Y = 4;
	public inline static var KEY_A = 1;
}

class OuyaKey
{
	public var key_o 	:Bool = false;
	public var key_u 	:Bool = false;
	public var key_y 	:Bool = false;
	public var key_a 	:Bool = false;

	public var justPressed_key_o 	:Bool = false;
	public var justPressed_key_u 	:Bool = false;
	public var justPressed_key_y 	:Bool = false;
	public var justPressed_key_a 	:Bool = false;

	public function new(){};

	public function keySet(id:Int, b:Bool = true){
		switch (id) {
			case OuyaKeyCode.KEY_O:
				key_o = b;
			case OuyaKeyCode.KEY_U:
				key_u = b;
			case OuyaKeyCode.KEY_Y:
				key_y = b;
			case OuyaKeyCode.KEY_A:
				key_a = b;
			default:
		}
	}

	public function getKey(id:Int){
		switch (id) {
			case OuyaKeyCode.KEY_O:
				return key_o;
			case OuyaKeyCode.KEY_U:
				return key_u;
			case OuyaKeyCode.KEY_Y:
				return key_y;
			case OuyaKeyCode.KEY_A:
				return key_a;
			default:
			return false;
		}
	}

	public function setJustPressed(id : Int) {
		switch (id) {
			case OuyaKeyCode.KEY_O:
				justPressed_key_o = true;
			case OuyaKeyCode.KEY_U:
				justPressed_key_u = true;
			case OuyaKeyCode.KEY_Y:
				justPressed_key_y = true;
			case OuyaKeyCode.KEY_A:
				justPressed_key_a = true;
			default:
		}
	}

	public function getJustPressed(id : Int) {
		switch (id) {
			case OuyaKeyCode.KEY_O:
				return justPressed_key_o;
			case OuyaKeyCode.KEY_U:
				return justPressed_key_u;
			case OuyaKeyCode.KEY_Y:
				return justPressed_key_y;
			case OuyaKeyCode.KEY_A:
				return justPressed_key_a;
			default:
			return false;
		}
	}

	public function resetJustPressed()
	{
		justPressed_key_o = false;
		justPressed_key_u = false;
		justPressed_key_y = false;
		justPressed_key_a = false;
	}

	public function toString():String{
		return "O: "+key_o + " |U: "+key_u+" |Y: "+key_y+" |A: "+key_a;
	}

}
class InputHandler 
{
	private static var _playerCount 	:Int;
	private static var axis 			:Array<Vector>;
	private static var axisOther 		:Array<Vector>;
	private static var _threshold 		:Float = 0.35;

	private static var initedButtons 	:Bool = false;

	private static var buttonDownFunctions:Array<Int->Void>;
	private static var buttonUpFunctions:Array<Int->Void>;
	public static var OuyaKeys 		:Array<OuyaKey>;

	public static var eventAxis 		:Array<Dynamic>;

	public static function init (pCount:Int = 1)
	{
		if (pCount < 1) trace ("pCount needs to be 1 or higher!");

		var getContext = JNI.createStaticMethod("org.haxe.nme.GameActivity", "getContext", "()Landroid/content/Context;",true);
		OuyaController.init(getContext());

		_playerCount = pCount;
		axis = new Array<Vector>();
		axisOther = new Array<Vector>();
		eventAxis = new Array<Dynamic>();
		OuyaKeys = new Array<OuyaKey>();

		for (i in 0...pCount) {
			axis[i] = new Vector(0,0);
			axisOther[i] = new Vector(0,0);
			eventAxis[i] = new Array<Float>();

			OuyaKeys[i] = new OuyaKey();
		}

		HXP.stage.addEventListener(JoystickEvent.AXIS_MOVE, onJoystickMove);

		buttonDownFunctions = new Array<Int->Void>();
		buttonUpFunctions = new Array<Int->Void>();

	}

	public static function initButtons(player:Int, funcDown:Dynamic=null, funcUp:Dynamic = null){
		
		if (!initedButtons){
			HXP.stage.addEventListener(JoystickEvent.BUTTON_DOWN, onJoystickButtonDown);
			HXP.stage.addEventListener(JoystickEvent.BUTTON_UP, onJoystickButtonUp);
			
			initedButtons = true;
		}

		buttonDownFunctions[player] = funcDown;
		buttonUpFunctions[player] = funcUp;
	}

	public static function wasButtonJustPressed(id : Int, player : Int = 0)
	{
		return OuyaKeys[player].getJustPressed(id);
	}

	public static function getAxis(player:Int, LeftOrRight:Int = 0):Vector{
		// check player number
		if (player < _playerCount){
			// whether left=0 or right=1
			if (LeftOrRight==0){
				if (axis[player].length < _threshold){
					axis[player].setTo(0,0);
				}
				return axis[player];
			}else if (LeftOrRight==1){
				if (axisOther[player].length < _threshold){
					axisOther[player].setTo(0,0);
				}
				return axisOther[player];
			}
		}
		return new Vector(0,0);
	}

	public static function checkButton(id:Int, player:Int = 0){
		return OuyaKeys[player].getKey(id);
	}

	private static function onJoystickButtonDown(e:JoystickEvent):Void{
		if (!initedButtons) 
			return;
		var player = OuyaController.getPlayerNumByDeviceId(e.device);
		/*if (buttonDownFunctions[player] == null) {
			return;
		}*/
		// adding button to list
		OuyaKeys[player].keySet(e.id);
		OuyaKeys[player].setJustPressed(e.id);
		// calling callback function
		if (buttonDownFunctions[player] != null)
		{
			buttonDownFunctions[player](e.id);
		}
	}
	private static function onJoystickButtonUp(e:JoystickEvent):Void{
		if (!initedButtons)
			return;
		var player = OuyaController.getPlayerNumByDeviceId(e.device);
		/*if (buttonUpFunctions[player] == null){
			return;
		}*/

		// removing button from list
		OuyaKeys[player].keySet(e.id, false);

		// calling callback function
		if (buttonUpFunctions[player] != null)
		{
			buttonUpFunctions[player](e.id);
		}
	}
	private static function onJoystickMove(e:JoystickEvent){
		var player = OuyaController.getPlayerNumByDeviceId(e.device);

		axis[player].x = e.x;
		axis[player].y = e.y;
		axisOther[player].x = e.axis[11];
		axisOther[player].y = e.axis[14];

		// copy axis of joystickevent
		eventAxis[player] = e.axis;
	}

	public static function update ()
	{
		OuyaKeys[0].resetJustPressed();
		OuyaKeys[1].resetJustPressed();
	}
}

#end