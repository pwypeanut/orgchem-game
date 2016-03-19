package;

import flixel.group.FlxSpriteGroup;
import flixel.group.FlxTypedGroup;
import flixel.group.FlxTypedSpriteGroup;
import flixel.FlxSprite;
import flixel.util.FlxColor;

using flixel.util.FlxSpriteUtil;
/**
 * ...
 * @author Bradley Teo
 */
class Modal extends FlxSpriteGroup
{
	public var _height = 900;
	public var _width = 600;
	public var _modalBox:FlxSprite;
	public var _options:FlxTypedGroup<ModalOption>;
	
	public function new(MaxSize:Int=0) 
	{
		super(MaxSize);
		
		_modalBox = new FlxSprite();
		
		_modalBox.height = _height;
		_modalBox.width = _width;
		
		_modalBox.x = (Reg.gameWidth - _width)/2;
		_modalBox.y = (Reg.gameHeight - _height) / 2;
		
		_modalBox.makeGraphic(_width, _height, 0);
		_modalBox.drawRoundRect(12, 12, _width - 24, _height - 24, 50, 50, FlxColor.WHITE, { color: 0xff333333, thickness:12 } );
		
		add(_modalBox);
		
		_options = new FlxTypedGroup<ModalOption>();
		
		for (i in (0...4)) {
			var modalOption = new ModalOption();
			_options.add(modalOption);
			
			var modalPadding = 50;
			var modalHeight:Int = Std.int((_height - (modalPadding * 5)) / 4);
			var modalWidth = (_width - modalPadding * 2);
			var textPadding = 20;
			modalOption.y = modalPadding + i * (modalHeight + modalPadding);
			modalOption.x = modalPadding;
			
			modalOption.y += _modalBox.y;
			modalOption.x += _modalBox.x;
			
			modalOption._txtText.setFormat("assets/fonts/OpenSans-Regular.ttf", 24, 0xff000000);
			modalOption._txtText.x += textPadding;
			modalOption._txtText.y += textPadding;
			
			modalOption._modalOptionSprite.height = modalHeight;
			modalOption._modalOptionSprite.width = modalWidth;
			modalOption._modalOptionSprite.makeGraphic(modalWidth, modalHeight, 0xffeeeeee);
			
			modalOption._optionNumber = i;
			add(modalOption);
		}
	}
}