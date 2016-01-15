package;

import flixel.FlxSprite;
import flixel.util.FlxPoint;
import flixel.tweens.FlxTween;

class HydrogenAtom extends FlxSprite {
	public function new(x: Float, y: Float) {
		super(x, y);
		loadGraphic("assets/images/oc_Hydrogen.png");
		this.scale.set(0.5, 0.5);
	}
	public function move(x: Float, y: Float) {
		FlxTween.tween(this, {x: x + 15, y: y + 15}, 0.2, { type: FlxTween.ONESHOT });
	}
	public function fade(alpha: Float) {
		FlxTween.tween(this, {alpha: alpha}, 0.2, { type: FlxTween.ONESHOT });
	}
}