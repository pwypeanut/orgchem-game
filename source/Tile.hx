package;

import flixel.FlxSprite;
import flixel.util.FlxPoint;
import flixel.tweens.FlxTween;

class Tile extends FlxSprite {
	public var type:UnitType;
	private var activated:Bool = false;
	public var hydrogens = new Array<HydrogenAtom>();
	private var location : FlxPoint;

	public function new(coords:FlxPoint, ?type:UnitType) {
		super(coords.x, coords.y);
		this.location = coords;
		
		this.scale.set(0.5, 0.5);
		
		this.height = 120;
		this.width = 120;
		this.alpha = 0.5;
		
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
			FlxTween.tween(this, { alpha: 0.5 }, 0.2, { type: FlxTween.ONESHOT } );
			for (atom in hydrogens) atom.fade(0);
		}
		
		if (!this.activated && activated) {
			this.activated = true;
			FlxTween.tween(this, { alpha: 1 }, 0.2, { type: FlxTween.ONESHOT } );
			for (atom in hydrogens) atom.fade(1);
		}
	}

	public function updateHydrogen(count: Int, screen: PlayState) {
		if (count < hydrogens.length) {
			// remove hydrogens
			for (i in count...hydrogens.length) {
				hydrogens[i].fade(0);
			}
			var removeCount = hydrogens.length - count;
			for (i in 0...removeCount) {
				hydrogens.pop();
			}
		} else if (count > hydrogens.length) {
			// add hydrogens
			var addCount = count - hydrogens.length;
			for (i in 0...addCount) {
				hydrogens.push(new HydrogenAtom(this.location.x, this.location.y));
				screen.add(hydrogens[hydrogens.length - 1]);
				if (this.activated) {
					hydrogens[hydrogens.length - 1].alpha = 0;
					hydrogens[hydrogens.length - 1].fade(1);
				}
				else hydrogens[hydrogens.length - 1].alpha = 0;
			}
		} else return;
		if (count == 1) {
			if (Std.random(2) == 0) {
				 hydrogens[0].move(this.location.x - 60, this.location.y);
			} else {
				hydrogens[0].move(this.location.x + 60, this.location.y);
			}
		} else if (count == 2) {
			if (Std.random(2) == 0) {
				hydrogens[0].move(this.location.x - 60 / Math.sqrt(2), this.location.y - 60 / Math.sqrt(2));
				hydrogens[1].move(this.location.x + 60 / Math.sqrt(2), this.location.y + 60 / Math.sqrt(2));
			} else {
				hydrogens[0].move(this.location.x + 60 / Math.sqrt(2), this.location.y - 60 / Math.sqrt(2));
				hydrogens[1].move(this.location.x - 60 / Math.sqrt(2), this.location.y + 60 / Math.sqrt(2));
			}
		} else if (count == 3) {
			hydrogens[0].move(this.location.x, this.location.y - 60);
			hydrogens[1].move(this.location.x - 60 / Math.sqrt(2), this.location.y + 60 / Math.sqrt(2));
			hydrogens[2].move(this.location.x + 60 / Math.sqrt(2), this.location.y + 60 / Math.sqrt(2));
		} else if (count == 4) {
			hydrogens[0].move(this.location.x - 60 / Math.sqrt(2), this.location.y - 60 / Math.sqrt(2));
			hydrogens[1].move(this.location.x + 60 / Math.sqrt(2), this.location.y - 60 / Math.sqrt(2));
			hydrogens[2].move(this.location.x - 60 / Math.sqrt(2), this.location.y + 60 / Math.sqrt(2));
			hydrogens[3].move(this.location.x + 60 / Math.sqrt(2), this.location.y + 60 / Math.sqrt(2));
		}
	}
	
}