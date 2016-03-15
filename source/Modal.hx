package;

import flixel.group.FlxSpriteGroup;
import flixel.group.FlxTypedGroup;
import flixel.FlxSprite;
import flixel.util.FlxColor;

using flixel.util.FlxSpriteUtil;
/**
 * ...
 * @author Bradley Teo
 */
class Modal extends FlxSprite
{
	public var _height = 900;
	public var _width = 600;
	
	public function new(MaxSize:Int=0) 
	{
		super(MaxSize);
		
		height = _height;
		width = _width;
		
		x = (Reg.gameWidth - _width)/2;
		y = (Reg.gameHeight - _height) / 2;
		
		makeGraphic(_width, _height, 0);
		this.drawRoundRect(12, 12, _width-24, _height-24, 50, 50, FlxColor.WHITE, {color: 0xff333333, thickness:12} );
	}
	
}