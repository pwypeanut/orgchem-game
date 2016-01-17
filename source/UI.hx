package;

import flixel.FlxSprite;
import flixel.group.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.util.FlxGradient;
import flixel.util.FlxColor;

using flixel.util.FlxSpriteUtil;

class UI extends FlxTypedGroup<FlxSprite>
{
	public var _stageWidth:Int = 768;
	public var _stageHeight:Int = 1024;
	
	public var _txtName:FlxText;
	public var _sprMainBox:FlxSprite;

	public function new(MaxSize:Int=0) 
	{
		super(MaxSize);
		
		var _boxWidth = 550, _boxHeight = 270, _borderWidth = 12;
		
		_sprMainBox = new FlxSprite((_stageWidth - _boxWidth) / 2, 50);
		_sprMainBox.makeGraphic(_boxWidth + _borderWidth, _boxHeight + _borderWidth);
		_sprMainBox.drawRoundRect(_borderWidth / 2, _borderWidth / 2, _boxWidth, _boxHeight, 25, 25, 0xfff0f0f0, { thickness: _borderWidth, color: 0xff333333 });
		add(_sprMainBox);
		
		_txtName = new FlxText(0, 200, _stageWidth, "");
		_txtName.setFormat(null, 20, 0);
		_txtName.alignment = "center";
		add(_txtName);
	}
	
}