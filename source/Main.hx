package;

import flixel.FlxGame;
import flixel.FlxState;
import openfl.display.Sprite;
import crowbar.states.DefaultState;

import crowbar.ui.CrowbarConsole;
import crowbar.ui.CrowbarOverlay;

import openfl.display.Sprite;

typedef GameClient = #if CRASH_HANDLER external.crash.CrowbarGame #else flixel.FlxGame #end;

class Main extends Sprite
{
	public static final initialFramerate:Int = 60;
	public static final initialState = crowbar.states.DefaultState;
	public static final version:String = "1.0.0-ALPHA";

	public static var self:Main;
	public static var noGpuBitmaps:Bool = false;

	private var gameClient:GameClient;
	public var overlay:OverlayContainer;

	public function new()
	{
		super();
		self = this;

		addChild(gameClient = new GameClient(0, 0, Init, initialFramerate, initialFramerate, true));
		addChild(overlay = new OverlayContainer());
	}

	/*
	private function onResizeGame(width:Int, height:Int):Void {
		if (FlxG.cameras == null)
			return;

		for (cam in FlxG.cameras.list) {
			@:privateAccess
			if (cam != null && (cam._filters != null && cam._filters.length > 0)) {
				var sprite:Sprite = cam.flashSprite; // @Ne_Eo
				if (sprite != null) {
					sprite.__cacheBitmap = null;
					sprite.__cacheBitmapData = null;
					sprite.__cacheBitmapData2 = null;
					sprite.__cacheBitmapData3 = null;
					sprite.__cacheBitmapColorTransform = null;
				}
			}
		}
	}
	*/

	
	private function onStateCreate(state:FlxState):Void {
		@:privateAccess AssetHelper.clearCacheEntirely(true);
	}
	

	public function switchState()
	{
		
	}
}
