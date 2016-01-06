package;

import flixel.FlxSprite;
import flixel.tweens.FlxTween;

class Tile extends FlxSprite {
	public var type:UnitType;
	private var activated:Bool = false;

	public function new(X:Float=0, Y:Float=0, ?type:UnitType) {
		super(X, Y);
		
		this.scale.set(0.5, 0.5);
		
		this.height = 120;
		this.width = 120;
		
		if (type == null) {
			setType(UnitType.CARBON);
		} else {
			setType(type);
		}
	}
	
	public function setType(type:UnitType):Void {
		this.type = type;
		loadGraphic("assets/images/oc_" + type.name + ".png");
		this.updateHitbox();
	}
	
	public function getActivated():Bool {
		return this.activated;
	}
	
	public function setActivated(activated:Bool) {
		if (this.activated && !activated) {
			this.activated = false;
			trace(this.alpha);
			FlxTween.tween(this, { alpha: 0.5 }, 0.2, { type: FlxTween.ONESHOT } );
		}
		
		if (!this.activated && activated) {
			this.activated = true;
			FlxTween.tween(this, { alpha: 1 }, 0.2, { type: FlxTween.ONESHOT } );
		}
	}
	
}