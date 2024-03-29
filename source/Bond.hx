package;

import flixel.FlxSprite;
import flixel.util.FlxPoint;
import flixel.util.FlxAngle;
import flixel.tweens.FlxTween;

/**
 * ...
 * @author Bradley Teo
 */
class Bond extends FlxSprite {
	
	var degrees:Int = 0;
	var type:Int = 1;
	
	var centreCoords:FlxPoint;

	public function new(coords:FlxPoint, degrees:Int) {
		
		this.centreCoords = coords;
		super(centreCoords.x, centreCoords.y);
		
		this.scale.set(0.5, 0.5);
		
		setAngle(degrees);
		setType(1);
		this.alpha = 0;
	}
	
	public function setAngle(degrees:Int) {
		this.degrees = degrees;
		this.angle = degrees;
		updateHitbox();
	}
	
	public function setType(type:Int) {
		this.type = type;
		if (type == 1) {
			loadGraphic("assets/images/oc_Single Bond.png");
		} else if (type == 2) {
			loadGraphic("assets/images/oc_Double Bond.png");
		}
		
		this.x = this.centreCoords.x - this.width / 4;
		this.y = this.centreCoords.y - this.height / 4;
		updateHitbox();
	}
	
	public function getType() {
		return type;
	}
	
	public function fadeIn() {
		this.alpha = 0;
		FlxTween.tween(this, { alpha: 1 }, 0.4, { type: FlxTween.ONESHOT } );
	}
	
	public function fadeOut() {
		FlxTween.tween(this, { alpha: 0 }, 0.1, { type: FlxTween.ONESHOT } );
	}
	
	public function hide() {
		this.alpha = 0;
	}
	
	public function show() {
		this.alpha = 1;
	}
}