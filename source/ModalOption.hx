package;

import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;
import flixel.group.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.plugin.MouseEventManager;

/**
 * ...
 * @author Bradley Teo
 */
class ModalOption extends FlxSpriteGroup
{
	
	public var _txtText:FlxText;
	public var _modalOptionSprite:FlxSprite;
	public var _optionNumber:Int;

	public function new(MaxSize:Int=0) 
	{
		super(MaxSize);
		
		_txtText = new FlxText();
		_modalOptionSprite = new FlxSprite();
		
		this.add(_modalOptionSprite);
		this.add(_txtText);
		
		MouseEventManager.add(this, onMouseDown);
	}
	
	function onMouseDown(object:FlxObject)
	{
		Reg.ps.submitAnswer(_optionNumber);
	}
}