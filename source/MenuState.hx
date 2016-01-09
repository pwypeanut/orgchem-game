package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.util.FlxMath;

/**
 * A FlxState which can be used for the game's menu.
 */
class MenuState extends FlxState
{
	/**
	 * Function that is called up when to state is created to set it up. 
	 */
	override public function create():Void
	{
		/*var m: Molecule = new Molecule(4, 4);
		m.adjacency[0][0][2] = 1;
		m.adjacency[0][1][6] = 1;
		m.adjacency[0][1][4] = 1;
		m.adjacency[1][1][0] = 1;
		m.adjacency[0][1][2] = 1;
		m.adjacency[0][2][6] = 1;
		m.adjacency[0][2][2] = 1;
		m.adjacency[0][3][6] = 1;
		m.adjacency[1][2][0] = 1;
		m.adjacency[0][2][4] = 1;
		m.adjacency[1][2][2] = 1;
		m.adjacency[1][3][6] = 1;
		m.adjacency[1][2][4] = 1;
		m.adjacency[2][2][0] = 1;
		m.grid[1][1] = new Unit(UnitType.CHLORINE);
		trace(m.getName());*/
		super.create();
		
		Reg.ps = new PlayState();
		FlxG.switchState(Reg.ps);
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