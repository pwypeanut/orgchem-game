public static class UnitType {
	public static var CARBON = UnitType("Cardbon", "C", 4);
	public static var CHLORINE = UnitType("Chlorine", "Cl", 1);
	public static var BROMINE = UnitType("Bromine", "Br", 1);
	public static var IODINE = UnitType("Iodine", "I", 1);
	public var name: String;
	public var symbol: String;
	public var valence: Int;
	public function new(_name: String, _symbol: String, _valence: Int) {
		this.name = _name;
		this.symbol = _symbol;
		this.valence = _valence;
	}
}