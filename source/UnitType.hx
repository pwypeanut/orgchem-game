class UnitType {
	public static var CARBON = new UnitType("Carbon", "C", 4);
	public static var FLOURINE = new UnitType("Flourine", "F", 1);
	public static var CHLORINE = new UnitType("Chlorine", "Cl", 1);
	public static var BROMINE = new UnitType("Bromine", "Br", 1);
	public static var IODINE = new UnitType("Iodine", "I", 1);
	public var name: String;
	public var symbol: String;
	public var valence: Int;
	public function new(_name: String, _symbol: String, _valence: Int) {
		this.name = _name;
		this.symbol = _symbol;
		this.valence = _valence;
	}
}