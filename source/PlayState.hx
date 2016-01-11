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
import Std.int;

/**
 * A FlxState which can be used for the actual gameplay.
 */
class PlayState extends FlxState
{
	static var gridHeight = 4;
	static var gridWidth = 4;
	var _grpTiles:FlxTypedGroup<Tile>;
	var _gridTiles:Array<Array<Tile>>;
	
	var _grpBonds:FlxTypedGroup<Bond>;
	var _gridBonds:Array<Array<Array<Bond>>>;
	var currentMolecule: Molecule = new Molecule(4, 4);
	var undoStack = new GenericStack<Molecule>();
	var currentMouseSource : Point = new Point(-1, -1);
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
		
		_gridTiles = [for (i in 0...gridHeight) [for (j in 0...gridWidth) null]];
		
		for (i in (0...gridWidth)) {
			for (j in (0...gridHeight)) {
				_gridTiles[j][i] = new Tile(getTileCoordinates(i, j));
				_grpTiles.add(_gridTiles[j][i]);
			}
		}
		
		_grpBonds = new FlxTypedGroup<Bond>();
		add(_grpBonds);
		add(_grpTiles);
		
		_gridBonds = [for (i in 0...gridHeight) [for (j in 0...gridWidth) [for (k in 0...8) null]]];
		
		// Up/Down Bonds
		for (i in (0...gridWidth)) {
			for (j in (0...gridHeight - 1)) {
				var bond = new Bond(pointAverage(getTileCentreCoordinates(i, j), getTileCentreCoordinates(i, j+1)), 90);
				_gridBonds[j][i][4] = _gridBonds[j + 1][i][0] = bond;
				_grpBonds.add(bond);
			}
		}
		
		// Left/Right Bonds
		for (i in (0...gridWidth - 1)) {
			for (j in (0...gridHeight)) {
				var bond = new Bond(pointAverage(getTileCentreCoordinates(i, j), getTileCentreCoordinates(i+1, j)), 0);
				_gridBonds[j][i][2] = _gridBonds[j][i + 1][6] = bond;
				_grpBonds.add(bond);
			}
		}
		
		// Top Left/Bottom Right Bonds
		for (i in (0...gridWidth - 1)) {
			for (j in (0...gridHeight - 1)) {
				var bond = new Bond(pointAverage(getTileCentreCoordinates(i, j), getTileCentreCoordinates(i+1, j+1)), 45);
				_gridBonds[j][i][3] = _gridBonds[j + 1][i + 1][7] = bond;
				_grpBonds.add(bond);
			}
		}
		
		// Top Right/Bottom Left Bonds
		for (i in (1...gridWidth)) {
			for (j in (1...gridHeight)) {
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

		if (FlxG.mouse.justPressed) {
			var gridCoords = new Point(getTile(FlxG.mouse.x, FlxG.mouse.y).x, getTile(FlxG.mouse.x, FlxG.mouse.y).y);
			if (gridCoords.x != -1 && gridCoords.y != -1) {
				// they are on a unit
				if (currentMolecule.grid[gridCoords.x][gridCoords.y].type.name == "Carbon" && currentMolecule.numberBonds(gridCoords.x, gridCoords.y) < 4) {
					// they must start from a carbon
					if (currentMolecule.isActive(gridCoords.x, gridCoords.y) || currentMolecule.isEmpty()) {
						currentMouseSource = gridCoords;
					}
				}
			}
		} 
		if (FlxG.mouse.justReleased) {
			currentMouseSource = new Point(-1, -1); // cancel all previous operations
			trace(currentMolecule.getName());
		}
		if (FlxG.mouse.pressed) {
			var gridCoords = new Point(getTile(FlxG.mouse.x, FlxG.mouse.y).x, getTile(FlxG.mouse.x, FlxG.mouse.y).y);
			if (currentMouseSource.x != -1 && currentMouseSource.y != -1) {
				if (gridCoords.x != -1 && gridCoords.y != -1) {
					// they are on a unit
					if (!(currentMouseSource.x == gridCoords.x && currentMouseSource.y == gridCoords.y)) {
						// they are neighbours
						if (Math.abs(currentMouseSource.x - gridCoords.x) <= 1 && Math.abs(currentMouseSource.y - gridCoords.y) <= 1) {
							// the end unit is not active
							if (!currentMolecule.isActive(gridCoords.x, gridCoords.y)) {
								var dx: Int = gridCoords.x - currentMouseSource.x;
								var dy: Int = gridCoords.y - currentMouseSource.y;
								var d: Int = 0;
								for (i in 0...8) {
									if (Point.directions[i].x == dx && Point.directions[i].y == dy) {
										d = i;
									}
								}
								currentMolecule.adjacency[currentMouseSource.x][currentMouseSource.y][d] = 1;
								currentMolecule.adjacency[gridCoords.x][gridCoords.y][(d + 4) % 8] = 1;
								currentMouseSource = gridCoords;
							}
						}
					}
				}
			}
		}

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
	private function getTile(x:Float, y:Float):Point {
		var retPoint = new Point(int((y - 410) / 136), int((x - 120) / 136));
		if (retPoint.x < 0 || retPoint.y < 0 || retPoint.x >= 4 || retPoint.y >= 4) return new Point(-1, -1);
		var error = FlxMath.getDistance(getTileCentreCoordinates(retPoint.y, retPoint.x), new FlxPoint(x, y));
		if (error > 60) return new Point(-1, -1);
		else return retPoint;
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