package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.group.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.util.FlxMath;
import flixel.util.FlxPoint;
import flixel.util.FlxRandom;
import haxe.ds.GenericStack;

/**
 * A FlxState which can be used for the actual gameplay.
 */
class PlayState extends FlxState
{
	var _grpTiles:FlxTypedGroup<Tile>;
	var _gridTiles:Array<Array<Tile>>;
	
	var _grpBonds:FlxTypedGroup<Bond>;
	var _gridBonds:Array<Array<Array<Bond>>>;
	var currentMolecule: Molecule = new Molecule(4, 4);
	var undoStack = new GenericStack<Molecule>();
	/**
	 * Function that is called up when to state is created to set it up. 
	 */
	override public function create():Void
	{
		super.create();
		undoStack.add(currentMolecule.clone());
		
		this.bgColor = 0xffffffff;
		//FlxG.debugger.drawDebug = true;
		FlxG.camera.antialiasing = true;
		
		_grpTiles = new FlxTypedGroup<Tile>();
		
		_gridTiles = [for (i in 0...4) [for (j in 0...4) null]];
		
		for (i in (0...4)) {
			for (j in (0...4)) {
				_gridTiles[j][i] = new Tile(getTileCoordinates(i, j));
				_grpTiles.add(_gridTiles[j][i]);
			}
		}
		
		_grpBonds = new FlxTypedGroup<Bond>();
		add(_grpBonds);
		add(_grpTiles);
		
		_gridBonds = [for (i in 0...4) [for (j in 0...4) [for (k in 0...8) null]]];
		
		// Up/Down Bonds
		for (i in (0...4)) {
			for (j in (0...3)) {
				var bond = new Bond(pointAverage(getTileCentreCoordinates(i, j), getTileCentreCoordinates(i, j+1)), 90);
				_gridBonds[j][i][4] = _gridBonds[j + 1][i][0] = bond;
				_grpBonds.add(bond);
			}
		}
		
		// Left/Right Bonds
		for (i in (0...3)) {
			for (j in (0...4)) {
				var bond = new Bond(pointAverage(getTileCentreCoordinates(i, j), getTileCentreCoordinates(i+1, j)), 0);
				_gridBonds[j][i][2] = _gridBonds[j][i + 1][6] = bond;
				_grpBonds.add(bond);
			}
		}
		
		// Top Left/Bottom Right Bonds
		for (i in (0...3)) {
			for (j in (0...3)) {
				var bond = new Bond(pointAverage(getTileCentreCoordinates(i, j), getTileCentreCoordinates(i+1, j+1)), 45);
				_gridBonds[j][i][3] = _gridBonds[j + 1][i + 1][7] = bond;
				_grpBonds.add(bond);
			}
		}
		
		// Top Right/Bottom Left Bonds
		for (i in (1...4)) {
			for (j in (1...4)) {
				var bond = new Bond(pointAverage(getTileCentreCoordinates(i, j), getTileCentreCoordinates(i-1, j-1)), 135);
				_gridBonds[j][i][1] = _gridBonds[j - 1][i - 1][5] = bond;
				_grpBonds.add(bond);
			}
		}
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
		currentMolecule.grid[0][1] = new Unit(UnitType.CHLORINE);
		currentMolecule.adjacency[0][0][2] = currentMolecule.adjacency[0][1][6] = 1;
		var lastMolecule: Molecule = undoStack.first();
		if (!currentMolecule.same(undoStack.first())) {
			// current molecule has changed, update.
			for (i in 0...currentMolecule.height) {
				for (j in 0...currentMolecule.width) {
					if (currentMolecule.grid[i][j].type.name != lastMolecule.grid[i][j].type.name) {
						_grpTiles.remove(_gridTiles[i][j]);
						_gridTiles[i][j] = new Tile(getTileCoordinates(j, i), currentMolecule.grid[i][j].type);
						_grpTiles.add(_gridTiles[i][j]);
					}
				}
			}
			for (i in 0...currentMolecule.height) {
				for (j in 0...currentMolecule.width) {
					for (k in 0...4) {
						if (currentMolecule.adjacency[i][j][k] != lastMolecule.adjacency[i][j][k]) {
							_grpBonds.remove(_gridBonds[i][j][k]);
							_gridBonds[i][j][k] = _gridBonds[i + Point.directions[k].x][j + Point.directions[k].y][(k + 4) % 8] = new Bond(pointAverage(getTileCentreCoordinates(j, i), getTileCentreCoordinates(j + Point.directions[k].y, i + Point.directions[k].x)), bondAngle(k));
							if (currentMolecule.adjacency[i][j][k] > 0) {
								_gridBonds[i][j][k].setType(currentMolecule.adjacency[i][j][k]);
								_gridBonds[i + Point.directions[k].x][j + Point.directions[k].y][(k + 4) % 8].setType(currentMolecule.adjacency[i][j][k]);
							}
							if (currentMolecule.adjacency[i][j][k] > 0) {
								_gridBonds[i][j][k].showBond();
								_gridBonds[i + Point.directions[k].x][j + Point.directions[k].y][(k + 4) % 8].showBond();
							} else {
								_gridBonds[i][j][k].hideBond();
								_gridBonds[i + Point.directions[k].x][j + Point.directions[k].y][(k + 4) % 8].hideBond();
							}
							_grpBonds.add(_gridBonds[i][j][k]);
						}
					}
				}
			}
			undoStack.add(currentMolecule.clone());
		}
	}

	private function bondAngle(x: Int): Int 
	{
		if (x % 4 == 0) return 90;
		else if (x % 4 == 1) return 135;
		else if (x % 4 == 2) return 0;
		else return 45;
	}
	private function getTileCoordinates(x:Int, y:Int):FlxPoint
	{
		return FlxPoint.get(120 + x * 136, 410 + y * 136);
	}
	
	private function getTileCentreCoordinates(x:Int, y:Int):FlxPoint
	{
		return getTileCoordinates(x, y).add(60, 60);
	}
	
	private function pointAverage(p1:FlxPoint, p2:FlxPoint):FlxPoint
	{
		var sum = p1.addPoint(p2);
		return FlxPoint.get(sum.x / 2, sum.y / 2);
	}
}