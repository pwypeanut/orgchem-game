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
class PlayState extends SandboxState
{
	static var gridHeight = 4;
	static var gridWidth = 4;
	
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
		
		optionsSelected = [for (i in 0...4) false];
		
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
								trace("splau");
								FlxG.sound.play("assets/sounds/pop.wav");
							}
						}
					}
				}
			}
			updateMolecule();
		}
		updateHydrogens();
	}

	override public function submitMolecule()
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
	
	override public function submitAnswer(optionNumber: Int) {	
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
	
	override public function toggleModal()
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

}