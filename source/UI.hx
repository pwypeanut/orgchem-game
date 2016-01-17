package;

import flixel.FlxSprite;
import flixel.group.FlxTypedGroup;
import flixel.text.FlxText;

class UI extends FlxTypedGroup<FlxSprite>
{
	public var _txtName:FlxText;

	public function new(MaxSize:Int=0) 
	{
		super(MaxSize);
		
		_txtName = new FlxText(0, 0, 1000, "");
		_txtName.setFormat(null, 20, 0);
		add(_txtName);
	}
	
}