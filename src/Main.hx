import com.haxepunk.Engine;
import com.haxepunk.HXP;

class Main extends Engine
{

	override public function init()
	{
#if debug
		HXP.console.enable();
#end
		Registry.loadScenes();
		HXP.scene = Registry.selectScene;
	}

	public static function main() { new Main(400,225,60); }

}