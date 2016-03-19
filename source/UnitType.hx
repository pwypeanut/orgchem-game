class UnitType {
	public static var CARBON = new UnitType("Carbon", "C", 4, "");
	public static var FLUORINE = new UnitType("Fluorine", "F", 1, "fluoro");
	public static var CHLORINE = new UnitType("Chlorine", "Cl", 1, "chloro");
	public static var BROMINE = new UnitType("Bromine", "Br", 1, "bromo");
	public static var IODINE = new UnitType("Iodine", "I", 1, "iodo");
	public static var TYPES = [CARBON, FLUORINE, CHLORINE, BROMINE, IODINE];
	public var name: String;
	public var symbol: String;
	public var valence: Int;
	public var prefix: String;
	public function new(_name: String, _symbol: String, _valence: Int, _prefix: String) {
		this.name = _name;
		this.symbol = _symbol;
		this.valence = _valence;
		this.prefix = _prefix;
	}
}