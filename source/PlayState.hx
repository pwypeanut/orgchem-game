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
import flixel.util.FlxDestroyUtil;
import flixel.tweens.FlxTween;
import haxe.ds.GenericStack;
import haxe.ds.StringMap;
import Std.int;
import Math.random;

typedef OptionClass = {option: String, error: String};

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
	
	public var _hydrogenLayer:FlxTypedGroup<FlxTypedGroup<HydrogenAtom>>;
	
	var currentMolecule: Molecule = new Molecule(gridHeight, gridWidth);
	var undoStack = new GenericStack<Molecule>();
	var currentMouseSource : Point = new Point(-1, -1);
	var clickMouseSource: Point = new Point(-1, -1);

	var _ui:UI;
	var timeLength:Float = 120;
	var timeLeft:Float;
	var timePassing:Bool = true;
	
	var modalShown:Bool = false;
	var name:String = "";
	var errorMessage: Array<String>;
	var optionsSelected:Array<Bool>;

	var usedMolecules: Array<String> = new Array<String>();
	
	var score:Int = 0;
	
	var countdownState:Int = 3;
	
	/**
	 * Function that is called up when to state is created to set it up. 
	 */
	override public function create():Void
	{
		super.create();
		undoStack.add(currentMolecule.clone());
		
		this.bgColor = 0xffffffff;
		FlxG.debugger.drawDebug = true;
		FlxG.camera.antialiasing = true;
		
		timeLeft = timeLength;
		
		_hydrogenLayer = new FlxTypedGroup<FlxTypedGroup<HydrogenAtom>>();
		
		_grpTiles = new FlxTypedGroup<Tile>();
		
		_gridTiles = [for (i in 0...gridHeight) [for (j in 0...gridWidth) null]];
		
		optionsSelected = [for (i in 0...4) false];
		
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
		for (i in (0...gridWidth - 1)) {
			for (j in (1...gridHeight)) {
				var bond = new Bond(pointAverage(getTileCentreCoordinates(i, j), getTileCentreCoordinates(i+1, j-1)), 135);
				_gridBonds[j][i][1] = _gridBonds[j - 1][i + 1][5] = bond;
				_grpBonds.add(bond);
			}
		}
		
		
		add(_hydrogenLayer);
		
		_ui = new UI();
		add(_ui);
		_ui._modal.setAll("visible", false);
		timePassing = false;
		
		FlxTween.tween(_ui._countdownText, { alpha: 0 }, 1, { type: FlxTween.ONESHOT, complete: changeCountdown } );
		//_ui._modal.revive();
	}
	
	/**
	 * Function that is called when this state is destroyed - you might want to 
	 * consider setting all objects this state uses to null to help garbage collection.
	 */
	override public function destroy():Void
	{
		_ui = FlxDestroyUtil.destroy(_ui);
		_grpBonds = FlxDestroyUtil.destroy(_grpBonds);
		_grpTiles = FlxDestroyUtil.destroy(_grpTiles);
		super.destroy();
	}

	public function clearGrid() {
		currentMolecule = new Molecule(gridHeight, gridWidth);
		updateMolecule();
		updateName();
	}

	public function undoMove() {
		if (undoStack.isEmpty()) return;
		var latest = undoStack.first().clone();
		undoStack.pop();
		if (undoStack.isEmpty()) {
			undoStack.add(latest);
			return;
		}
		currentMolecule = undoStack.first().clone();
		undoStack.pop();
		updateMolecule(latest);
		updateName();
	}

	/**
	 * Function that is called once every frame.
	 */
	override public function update():Void
	{
		super.update();
		
		_ui._timeLeftBar.currentValue = (timeLeft / timeLength) * 100;
		if (timePassing) {
			timeLeft -= FlxG.elapsed;
		}

		if (FlxG.keys.justPressed.D) {
			// clear all
			clearGrid();
		}

		if (FlxG.keys.justPressed.U) {
			// undo last move
			undoMove();
		}
		
		_ui._txtScore.text = Std.string(score);


		if (FlxG.mouse.justPressed && !modalShown && countdownState <= 0) {
			var gridCoords = new Point(getTile(FlxG.mouse.x, FlxG.mouse.y).x, getTile(FlxG.mouse.x, FlxG.mouse.y).y);
			if (gridCoords.x != -1 && gridCoords.y != -1) {
				// they are on a unit
				if (currentMolecule.grid[gridCoords.x][gridCoords.y].type.name == "Carbon" && currentMolecule.numberBonds(gridCoords.x, gridCoords.y) < 4) {
					// they must start from a carbon
					if (currentMolecule.isActive(gridCoords.x, gridCoords.y) || currentMolecule.isEmpty()) {
						currentMouseSource = gridCoords;
					}
				}
				clickMouseSource = gridCoords;
			}
			updateMolecule();
		} 
		
		if (FlxG.mouse.justReleased && !modalShown && countdownState <= 0) {
			var gridCoords = new Point(getTile(FlxG.mouse.x, FlxG.mouse.y).x, getTile(FlxG.mouse.x, FlxG.mouse.y).y);
			if (gridCoords.x != -1 && gridCoords.y != -1) {
				if (gridCoords.x == clickMouseSource.x && gridCoords.y == clickMouseSource.y) {
					// click on a unit
					if (!currentMolecule.isActive(gridCoords.x, gridCoords.y)) {
						// not active, allow cycle through all
						for (i in 0...UnitType.TYPES.length) {
							var unitType = UnitType.TYPES[i];
							if (currentMolecule.grid[gridCoords.x][gridCoords.y].type.name == unitType.name) {
								currentMolecule.grid[gridCoords.x][gridCoords.y] = new Unit(UnitType.TYPES[(i + 1) % UnitType.TYPES.length]);
								break;
							}
						}
					} else {
						// active, allow cycle within type
						if (currentMolecule.grid[gridCoords.x][gridCoords.y].type.name == "Carbon") {
							currentMolecule.grid[gridCoords.x][gridCoords.y] = new Unit(UnitType.CARBON);
						} else if (currentMolecule.grid[gridCoords.x][gridCoords.y].type.name == "Fluorine") {
							currentMolecule.grid[gridCoords.x][gridCoords.y] = new Unit(UnitType.CHLORINE);
						} else if (currentMolecule.grid[gridCoords.x][gridCoords.y].type.name == "Chlorine") {
							currentMolecule.grid[gridCoords.x][gridCoords.y] = new Unit(UnitType.BROMINE);
						} else if (currentMolecule.grid[gridCoords.x][gridCoords.y].type.name == "Bromine") {
							currentMolecule.grid[gridCoords.x][gridCoords.y] = new Unit(UnitType.IODINE);
						} else if (currentMolecule.grid[gridCoords.x][gridCoords.y].type.name == "Iodine") {
							currentMolecule.grid[gridCoords.x][gridCoords.y] = new Unit(UnitType.FLUORINE);
						}
					}
				}
			}
			currentMouseSource = new Point(-1, -1); // cancel all previous operations
			clickMouseSource = new Point( -1, -1);
			updateMolecule();
			updateMainChain();
			updateName();
		}
		
		if (FlxG.mouse.pressed && !modalShown && countdownState <= 0) {
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
								if (currentMolecule.grid[gridCoords.x][gridCoords.y].type.name == "Carbon") currentMouseSource = gridCoords;
								else currentMouseSource = new Point(-1, -1);
							}
						}
					}
				}
			}
			updateMolecule();
		}
		updateHydrogens();
	}

	private function updateName() {
		return;
		_ui._txtName.text = currentMolecule.getName();
	}

	private function updateMainChain() {
		return;
		if (currentMolecule.isEmpty()) return;
		var mainChain = currentMolecule.getMainChain();
		var path = currentMolecule.tracePath(mainChain.source, mainChain.end, mainChain.source);
		for (i in 0...currentMolecule.height) {
			for (j in 0...currentMolecule.width) {
				if (currentMolecule.grid[i][j].type.name == "Carbon" && currentMolecule.isActive(i, j)) {
					_gridTiles[i][j].setType(new UnitType("Carbon Backbone", "C", 4, "")); // should be side chain
				}
			}
		}
		for (point in path) {
			_gridTiles[point.x][point.y].setType(new UnitType("Carbon Backbone", "C", 4, ""));
		}
	}

	private function updateHydrogens() {
		for (i in 0...currentMolecule.height) {
			for (j in 0...currentMolecule.width) {
				_gridTiles[i][j].updateHydrogen(_gridTiles[i][j].type.valence - currentMolecule.numberBonds(i, j));
			}
		}
	}

	private function updateMolecule(?lastMolecule: Molecule) {
		if (lastMolecule == null) {
			lastMolecule = undoStack.first();
		}
		if (!currentMolecule.same(lastMolecule)) {
			// current molecule has changed, update.
			for (i in 0...currentMolecule.height) {
				for (j in 0...currentMolecule.width) {
					if (currentMolecule.grid[i][j].type.name != lastMolecule.grid[i][j].type.name) {
						_gridTiles[i][j].setType(currentMolecule.grid[i][j].type);
					}
				}
			}
			for (i in 0...currentMolecule.height) {
				for (j in 0...currentMolecule.width) {
					if (currentMolecule.grid[i][j].type.name == "Carbon") {
						if (currentMolecule.isActive(i, j) && !lastMolecule.isActive(i, j)) {
							// carbon has just become active, switch from normal to side chain
							_gridTiles[i][j].setType(new UnitType("Carbon Backbone", "C", 4, "")); // should be side chain
						} else if (!currentMolecule.isActive(i, j) && lastMolecule.isActive(i, j)) {
							// carbon has just become inactive, switch to normal
							_gridTiles[i][j].setType(UnitType.CARBON);
						}
					}
				}
			}
			for (i in 0...currentMolecule.height) {
				for (j in 0...currentMolecule.width) {
					for (k in 0...4) {
						if (currentMolecule.adjacency[i][j][k] != lastMolecule.adjacency[i][j][k]) {
							if (_gridBonds[i][j][k] == null) continue;
							_gridBonds[i][j][k].hide();
							if (currentMolecule.adjacency[i][j][k] > 0) {
								_gridBonds[i][j][k].setType(currentMolecule.adjacency[i][j][k]);
								_gridBonds[i][j][k].show();
							} else {
								_gridBonds[i][j][k].fadeOut();
							}
						}
					}
					_gridTiles[i][j].setActivated(currentMolecule.isActive(i, j));
				}
			}
			updateHydrogens();
			undoStack.add(currentMolecule.clone());
		}
	}
	
	public function submitMolecule()
	{
		if (modalShown) return;
		
		var highDegree: Int = 0;
		var activeCarbons: Int = 0;
		for (i in 0...gridHeight) {
			for (j in 0...gridWidth) {
				if (!currentMolecule.isActive(i, j)) continue;
				if (currentMolecule.grid[i][j].type.symbol != "C") {
					continue;
				}
				activeCarbons++;
				if (currentMolecule.countCarbon(new Point(i, j)) > 2) highDegree++;
			}
		}
		if (activeCarbons < 2) return;

		var res = currentMolecule.getMainChain();
		var mainPath = currentMolecule.tracePath(res.source, res.end, res.source);
		for (point in mainPath) {
			if (!currentMolecule.isActive(point.x, point.y)) continue;
			if (currentMolecule.countCarbon(point) > 2) highDegree--;
		}

		if (highDegree != 0) return;

		var answers: Array<OptionClass> = new Array<OptionClass>();
		name = currentMolecule.getName();

		if (usedMolecules.indexOf(name) != -1) return;
		else usedMolecules.push(name);

		_ui._modal.setAll("visible", true);
		_ui._btnToggleModal.revive();
		_ui._toggleActive = false;
		modalShown = true;
		
		answers.push( { option: name, error: "OK!" } );
		
		if (random() < 0.4) {
			var wrongName: String = currentMolecule.getFlippedName();
			if (wrongName != name) answers.push({option: wrongName, error: "Incorrect direction of main chain!"});
		}
		if (random() < 0.7) {
			var wrongName: String = currentMolecule.getWrongMainChainName();
			if (wrongName != name) answers.push({option: wrongName, error: "Wrong main chain chosen!"});
		}

		var rem: Int = 4 - answers.length;

		for (i in 0...rem) {
			var pos: Int = Std.int(random() * 3);
			if (pos == 0) {
				var wrongName: String = currentMolecule.getMutatedComponentName();
				if (wrongName != name) answers.push({option: wrongName, error: "Recheck the numbering of side chains!"});
				else rem++;
			} else if (pos == 1) {
				var wrongName: String = currentMolecule.getMissingComponentName();
				if (wrongName != name) answers.push({option: wrongName, error: "Side chains are missing!"});
				else rem++;
			}
			else {
			 	var wrongName: String = currentMolecule.getWrongPrefixName();
			 	if (wrongName != name) answers.push({option: wrongName, error: "Wrong main chain length!"});
				else rem++;
			}
		}

		answers.sort(function(a: OptionClass, b: OptionClass) {
			if (a.option < b.option) return -1;
			else if (a.option == b.option) return 0;
			else return 1;
		});
		var disabled: Array<Int> = new Array<Int>();
		for (i in 1...4) {
			if (answers[i].option == answers[i - 1].option) {
				disabled.push(i);
			}
		}

		for (i in 0...disabled.length) answers[disabled[i]].option = answers[disabled[i]].error = "-";

		for (i in 0...30) {
			var x : Int = Std.int(random() * 4);
			var y : Int = Std.int(random() * 4);
			var tmp = answers[x];
			answers[x] = answers[y];
			answers[y] = tmp;
		}
		for (i in 0...4) {
			if (answers[i].option == "-") _ui._modal._options.members[i].setAll("visible", false);
		}
		errorMessage = new Array<String>();
		for (i in (0...4)) {
			_ui._modal._options.members[i]._txtText.text = answers[i].option;
			errorMessage.push(answers[i].error);
		}
		
	}
	
	public function submitAnswer(optionNumber: Int) {	
		var answer : String = _ui._modal._options.members[optionNumber]._txtText.text;
		optionsSelected[optionNumber] = true;
		
		if (answer != name) {
			_ui._modal._options.members[optionNumber]._txtText.alpha = 0.2;
			_ui._modal._options.members[optionNumber]._txtText.text = errorMessage[optionNumber];
		} else {
			modalShown = false;
			var attempts = 0;
			for (i in (0...4)) {
				if (optionsSelected[i]) attempts++;
				_ui._modal._options.members[i]._txtText.alpha = 1;
				_ui._modal._options.members[optionNumber].setAll("visible", true);
			}
			optionsSelected = [for (i in 0...4) false];
			score += (4 - attempts) * currentMolecule.getScore();
			_ui._modal.setAll("visible", false);
			_ui._toggleActive = false;
			_ui._btnToggleModal.kill();
			clearGrid();
		}
	}
	
	public function toggleModal()
	{
		if (!modalShown) return;
		if (_ui._toggleActive) {
			_ui._btnToggleModal.loadGraphic("assets/images/oc_Hide Button.png");
			_ui._modal.setAll("visible", true);
			for (i in 0...4) {
				if (_ui._modal._options.members[i]._txtText.text == "-") _ui._modal._options.members[i].setAll("visible", false);
			}
		} else {
			_ui._btnToggleModal.loadGraphic("assets/images/oc_Show Button.png");
			_ui._modal.setAll("visible", false);
		}
		_ui._toggleActive = !_ui._toggleActive;
	}
	
	private function changeCountdown(tween: FlxTween):Void 
	{
		_ui._countdownText.alpha = 1;
		countdownState -= 1;
		if (countdownState > 0) {
			_ui._countdownText.text = Std.string(countdownState);
			FlxTween.tween(_ui._countdownText, { alpha: 0 }, 1, { type: FlxTween.ONESHOT, complete: changeCountdown } );
		} else {
			_ui._countdownText.text = "GO";
			FlxTween.tween(_ui._countdownOverlay, { alpha: 0 }, 0.5, { type: FlxTween.ONESHOT, complete: countdownOver } );
			FlxTween.tween(_ui._countdownText, { alpha: 0 }, 0.5, { type: FlxTween.ONESHOT, complete: countdownOver } );
		}
	}
	
	private function countdownOver(tween: FlxTween) {
		_ui._countdownOverlay.kill();
		_ui._countdownText.kill();
		timePassing = true;
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
		return FlxPoint.get(99 + x * 150, 389 + y * 150);
	}
	private function getTile(x:Float, y:Float):Point {
		var retPoint = new Point(int((y - 389) / 150), int((x - 99) / 150));
		if (retPoint.x < 0 || retPoint.y < 0 || retPoint.x >= gridHeight || retPoint.y >= gridWidth) return new Point(-1, -1);
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