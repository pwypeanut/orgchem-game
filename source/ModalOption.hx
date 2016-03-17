package;

import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;
import flixel.group.FlxTypedGroup;
import flixel.text.FlxText;

/**
 * ...
 * @author Bradley Teo
 */
class ModalOption extends FlxSpriteGroup
{
	
	public var _txtText:FlxText;
	public var _modalOptionSprite:FlxSprite;

	public function new(MaxSize:Int=0) 
	{
		super(MaxSize);
		
		_txtText = new FlxText();
		_modalOptionSprite = new FlxSprite();
		
		this.add(_modalOptionSprite);
		this.add(_txtText);
		
	}
	
}