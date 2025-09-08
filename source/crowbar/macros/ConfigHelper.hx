package crowbar.macros;

#if macro
import Sys;
import haxe.macro.*;
import haxe.macro.Context;
import haxe.macro.Expr;

using haxe.macro.MacroStringTools;
#end

using StringTools;

/**
 * Contains helpers for settings along with macros to save settings
 * @author @Ne_Eo
**/
class ConfigHelper {
	/** Returns the actual save path for settings. **/
	public static var savePath(get, default):String = "crowbar";

	@:noCompletion @:dox(hide)
	static function get_savePath():String {
		var companyName:String = lime.app.Application.current.meta["company"];
		return '${companyName}/${lime.app.Application.current.meta["file"]}/${savePath}';
	}

	#if macro // Macro Variables and Functions go here!

	/**
	 * a Macro that saves your settings
	**/
	public static function buildSaveMacro():Array<Field> {
		var fields = Context.getBuildFields();
		var savedFields = [];
		var map:Array<Expr> = [];

		for (field in fields) {
			switch (field.kind) {
				case FVar(type, expr): // this doesnt find functions btw
					var name = field.name;
					if (!name.startsWith("_")) { // prevents saving internal or final variables
						if (!savedFields.contains(name)) {
							savedFields.push(name);
							var doc = field.doc ?? "";
							var arr = doc.trim().replace("\r\n", "\n").split("\n");
							for (i => text in arr) {
								text = text.trim();
								if (text.startsWith("*"))
									text = text.substr(1);
								arr[i] = text.trim();
							}

							map.push(macro $v{name} => $v{arr.join("\n")});
						}
					}
				default:
					continue;
			}

			/*
				for (meta in field.meta) {
					if (meta.name == ":unused") {
						Sys.println('[WARNING] Setting "${field.name}" is unused in the code');
					}
				}
			 */
		}

		// find flush and load fields
		for (field in fields) {
			switch (field.kind) {
				case FFun(fun):
					if (field.name == "load") {
						var arr = [(macro flixel.FlxG.save.bind("Settings", crowbar.macros.ConfigHelper.savePath))];
						for (name in savedFields) {
							arr.push(macro {
								if (flixel.FlxG.save.data.$name != null)
									$i{name} = flixel.FlxG.save.data.$name;
							});
						}
						arr.push(macro {
							crowbar.Settings.update();
						});
						fun.expr = macro $b{arr};
					}

					if (field.name == "flush") {
						var arr = [(macro flixel.FlxG.save.bind("Settings", crowbar.macros.ConfigHelper.savePath))];
						// i have 0 clue if this even works, it did work first try
						for (name in savedFields) {
							arr.push(macro {
								flixel.FlxG.save.data.$name = $i{name};
							});
						}
						arr.push(macro {
							flixel.FlxG.save.flush();

							crowbar.Settings.masterVolume = Std.int(flixel.FlxG.sound.volume * 100.0);
							crowbar.Settings.update();
						});
						fun.expr = macro $b{arr};
					}

				default:
					continue;
			}
		}

		fields.push({
			pos: Context.currentPos(),
			name: "descriptions",
			meta: null,
			kind: FieldType.FVar(macro :Map<String, String>, macro $a{map}),
			doc: null,
			access: [Access.APublic, Access.AStatic]
		});

		return fields;
	}
	#end
}
