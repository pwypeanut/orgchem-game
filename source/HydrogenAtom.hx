package;

import flixel.FlxSprite;
import flixel.util.FlxPoint;
import flixel.tweens.FlxTween;

class HydrogenAtom extends FlxSprite {
	
	private var _hidden = true;
	
	public function new(x: Float, y: Float) {
		super(x, y);
		loadGraphic("assets/images/oc_Hydrogen.png");
		this.scale.set(0.5, 0.5);
		this.updateHitbox();
		this.x -= this.width / 2;
		this.y -= this.height / 2;
	}
	
	public function move(x: Float, y: Float) {
		FlxTween.tween(this, {x: x + 15, y: y + 15}, 0.2, { type: FlxTween.ONESHOT });
	}
	
	public function fadeIn() {
		if (this._hidden) {
			_hidden = false;
			FlxTween.tween(this, { alpha: 1 }, 0.2, { type: FlxTween.ONESHOT } );
		}
	
	}
	
	public function fadeOut() {
		if (!this._hidden) {
			_hidden = true;
			FlxTween.tween(this, { alpha: 0 }, 0.2, { type: FlxTween.ONESHOT } );
		}
	}
	
	public function show() {
		this._hidden = false;
		this.alpha = 1;
	}
	
	public function hide() {
		this._hidden = true;
		this.alpha = 0;
	}
}