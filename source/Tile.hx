package;

import flixel.FlxSprite;
import flixel.group.FlxTypedGroup;
import flixel.util.FlxPoint;
import flixel.tweens.FlxTween;

class Tile extends FlxSprite {
	public var type:UnitType;
	private var activated:Bool = false;
	public var hydrogens = new FlxTypedGroup<HydrogenAtom>();
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
		
		var diagonalLength:Float = 60 / Math.sqrt(2);
		var midpoint = this.getMidpoint();
		
		hydrogens.add(new HydrogenAtom(midpoint.x - diagonalLength, midpoint.y - diagonalLength));
		hydrogens.add(new HydrogenAtom(midpoint.x - diagonalLength, midpoint.y + diagonalLength));
		hydrogens.add(new HydrogenAtom(midpoint.x + diagonalLength, midpoint.y + diagonalLength));
		hydrogens.add(new HydrogenAtom(midpoint.x + diagonalLength, midpoint.y - diagonalLength));
		
		hydrogens.forEach(function(hydrogen) {
			hydrogen.hide();
		});
		
		Reg.ps._hydrogenLayer.add(hydrogens);
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
			for (atom in hydrogens) atom.fadeOut();
		}
		
		if (!this.activated && activated) {
			this.activated = true;
			FlxTween.tween(this, { alpha: 1 }, 0.2, { type: FlxTween.ONESHOT } );
			for (atom in hydrogens) atom.fadeIn();
		}
	}

	public function updateHydrogen(count: Int) {
		// add hydrogens
		for (i in 0...4) {
			if (this.activated && i < count) {
				hydrogens.members[i].fadeIn();
			} else hydrogens.members[i].hide();
		}
	}
	
}