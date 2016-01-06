package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.group.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.util.FlxMath;
import flixel.util.FlxRandom;

/**
 * A FlxState which can be used for the actual gameplay.
 */
class PlayState extends FlxState
{
	var _grpTiles:FlxTypedGroup<Tile>;
	var _gridTiles:Array<Array<Tile>>;
	/**
	 * Function that is called up when to state is created to set it up. 
	 */
	override public function create():Void
	{
		super.create();
		
		this.bgColor = 0xffffffff;
		FlxG.debugger.drawDebug = true;
		
		_grpTiles = new FlxTypedGroup<Tile>();
		
		_gridTiles = [for (i in 0...4) [for (j in 0...4) null]];
		
		for (i in (0...4)) {
			for (j in (0...4)) {
				_gridTiles[i][j] = new Tile(120 + i * 136, 410 + j * 136);
				_grpTiles.add(_gridTiles[i][j]);
			}
		}
		
		add(_grpTiles);
	}
	
	/**
	 * Function that is called when this state is destroyed - you might want to 
	 * consider setting all objects this state uses to null to help garbage collection.
	 */
	override public function destroy():Void
	{
		super.destroy();
	}

	/**
	 * Function that is called once every frame.
	 */
	override public function update():Void
	{
		super.update();
	}	
}