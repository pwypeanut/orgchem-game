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
	public var _stageWidth:Int = 768;
	public var _stageHeight:Int = 1024;
	var _btnNomenclature:FlxButton; 
	var _btnSandbox:FlxButton;
	
	override public function create():Void
	{
		super.create();
		
		this.bgColor = 0xffffffff;
		
		var _btnWidth = 600;
		var _btnHeight = 150;
		
		_btnNomenclature = new FlxButton(_stageWidth / 2 - _btnWidth / 2, _stageHeight / 2 + _btnHeight / 2);
		_btnNomenclature.loadGraphic("assets/images/oc_Challenge Button.png");
		add(_btnNomenclature);
		
		_btnSandbox = new FlxButton(_stageWidth / 2 - _btnWidth / 2, _stageHeight / 2 + 3 * _btnHeight / 2 + 20);
		_btnSandbox.loadGraphic("assets/images/oc_Sandbox Button.png");
		add(_btnSandbox);
		
		_btnNomenclature.onDown.callback = function () {
			Reg.ps = new PlayState();
			FlxG.switchState(Reg.ps);
		}
		
		_btnSandbox.onDown.callback = function () {
			Reg.ps = new SandboxState();
			FlxG.switchState(Reg.ps);
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
	}	
}