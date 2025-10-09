import flixel.FlxG;
import flixel.FlxState;
import flixel.addons.transition.FlxTransitionSprite;
import flixel.addons.transition.FlxTransitionableState;
import flixel.addons.transition.TransitionData;
import flixel.graphics.FlxGraphic;
import flixel.input.keyboard.FlxKey;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.system.ui.FlxSoundTray;
import haxe.ds.StringMap;

class Init extends FlxState 
{
    override function create():Void 
    {
        super.create();

        setupDefaults();
		setupTransition();
		precacheAssets();

        FlxG.save.bind('Settings', "yigar/CrowbarEngine/settings");
		if (FlxG.save.data != null)
		{
			FlxG.sound.muted = FlxG.save.data.mute ?? false;
			FlxG.sound.volume = FlxG.save.data.volume ?? 1.0;
			//retrieve saved controls
			var m:Map<String, Array<FlxKey>> = FlxG.save.data.savedControls;
			if(m != null)
				Controls.current.setControlsFromMap(m);
		}

		FlxG.save.flush();


		FlxG.switchState(Type.createInstance(Main.initialState, []));
    }

    function precacheAssets():Void {
        //can add these later; maybe put in cache folders, or ascribe a file listing which audio/visual files to cache
    }

    function setupDefaults():Void {
        FlxG.mouse.useSystemCursor = true; //hides the engine cursor
        FlxG.game.focusLostFramerate = 10;
        FlxG.mouse.visible = false; //hides the cursor

        crowbar.Settings.load();
        flixel.FlxSprite.defaultAntialiasing = crowbar.Settings.globalAntialias;
        //setup controls here ******
		crowbar.Controls.current = new crowbar.ControlsManager();

        #if DISCORD 
        //crowbar.core.DiscordWrapper.initialize("1325211048801992715"); 
        #end
    }

    function setupTransition():Void {
		var graphic:FlxGraphic = FlxGraphic.fromClass(GraphicTransTileDiamond);
		graphic.destroyOnNoUse = false;
		graphic.persist = true;

		final transition:TransitionTileData = {
			asset: graphic,
			width: 32,
			height: 32,
			frameRate: 24
		};
		final transitionArea:FlxRect = FlxRect.get(-200, -200, FlxG.width * 2.0, FlxG.height * 2.0);

		FlxTransitionableState.defaultTransIn = new TransitionData(FADE, 0xFF000000, 0.4, FlxPoint.get(0, 0), transition, transitionArea);
		FlxTransitionableState.defaultTransOut = new TransitionData(FADE, 0xFF000000, 0.4, FlxPoint.get(0, 0), transition, transitionArea);
	}
}