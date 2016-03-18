package;

import flixel.FlxSprite;
import flixel.group.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.ui.FlxBar;
import flixel.ui.FlxButton;
import flixel.util.FlxGradient;
import flixel.util.FlxColor;
import flixel.util.FlxDestroyUtil;

using flixel.util.FlxSpriteUtil;

class SandboxUI extends FlxTypedGroup<FlxSprite>
{
	public var _stageWidth:Int = 768;
	public var _stageHeight:Int = 1024;
	
	public var _txtName:FlxText;
	public var _sprMainBox:FlxSprite;
	public var _btnClear:FlxButton;
	public var _btnUndo:FlxButton;
	
	public var _txtScore:FlxText;
	
	public var _btnConfirm:FlxButton;
	public var _timeLeftBar:FlxBar;
	
	public var _modal:Modal;
	public var _btnToggleModal:FlxButton;
	public var _toggleActive:Bool = false;
	
	public var _countdownOverlay:FlxSprite;
	public var _countdownText:FlxText;

	public function new(MaxSize:Int=0) 
	{
		super(MaxSize);

		var _boxWidth = 550, _boxHeight = 270, _borderWidth = 12;
		
		_sprMainBox = new FlxSprite((_stageWidth - _boxWidth - _borderWidth) / 2, 50);
		_sprMainBox.makeGraphic(_boxWidth + _borderWidth, _boxHeight + _borderWidth);
		_sprMainBox.drawRoundRect(_borderWidth / 2, _borderWidth / 2, _boxWidth, _boxHeight, 25, 25, 0xfff0f0f0, { thickness: _borderWidth, color: 0xff111111 });
		add(_sprMainBox);
		
		var _btnWidth = 158 / 2;
		
		_btnClear = new FlxButton((_stageWidth - _boxWidth) / 2 - _btnWidth + 20, 50 + _boxHeight - _btnWidth - 20);
		_btnClear.loadGraphic("assets/images/oc_Cancel Button.png", false, 158, 158);
		_btnClear.scale.set(0.5, 0.5);
		_btnClear.updateHitbox();
		_btnClear.onUp.callback = Reg.ps.clearGrid;
		add(_btnClear);
		
		_btnUndo = new FlxButton((_stageWidth - _boxWidth) / 2 - _btnWidth + 20, 50 + _boxHeight - _btnWidth * 2 - 30);
		_btnUndo.loadGraphic("assets/images/oc_Undo Button.png", false, 158, 158);
		_btnUndo.scale.set(0.5, 0.5);
		_btnUndo.updateHitbox();
		_btnUndo.onUp.callback = Reg.ps.undoMove;
		add(_btnUndo);
		
		_txtName = new FlxText(0, 200, _stageWidth, "");
		_txtName.setFormat(null, 20, 0);
		_txtName.alignment = "center";
		add(_txtName);
	}
	
	override public function destroy()
	{
		_sprMainBox = FlxDestroyUtil.destroy(_sprMainBox);
		_btnClear = FlxDestroyUtil.destroy(_btnClear);
		_btnUndo = FlxDestroyUtil.destroy(_btnUndo);
		_txtName = FlxDestroyUtil.destroy(_txtName);
		
		super.destroy();
	}
	
}