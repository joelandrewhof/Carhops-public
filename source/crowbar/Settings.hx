package crowbar;

import flixel.input.keyboard.FlxKey;
import haxe.ds.StringMap;
import openfl.filters.BitmapFilter;
import openfl.filters.ColorMatrixFilter;

class Settings
{

    public static var savedControls:Map<String, Array<FlxKey>> = [];
    
    //Auto-pause on unfocused window?
    public static var autoPause:Bool = false;

    //Global game volume
    public static var masterVolume:Int = 100;

    //Framerate cap
    public static var maxFramerate:Int = 60;

    //Anti-aliasing
    public static var globalAntialias:Bool = true;

    /** Check this if you want the game to use the gpu more often to render sprites (experimental). **/
	public static var vramSprites:Bool = false;

    /*
     *   COMMANDS
    */

    /**
     * managed by macros at `crowbar.macros.ConfigHelper`.
    **/
    public static function flush():Void {}

    public static function load():Void {}

    public static function update():Void 
    {
        FlxG.autoPause = Settings.autoPause;
        if (FlxG.drawFramerate != Settings.maxFramerate)
			Tools.changeMaxFramerate(Settings.maxFramerate);
    }


}