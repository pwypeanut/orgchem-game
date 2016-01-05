public static class UnitType {
	public static var unitTypes = new Array<UnitType>(
		UnitType("Carbon", "C", 4),
		UnitType("Chlorine", "Cl", 1),
		UnitType("Bromine", "Br", 1),
		UnitType("Iodine", "I", 1)
	);
	public var name : String;
	public var symbol : String;
	public var valence : Int;
	public function new(_name: String, _symbol: String, _valence: Int) {
		this.name = _name;
		this.symbol = _symbol;
		this.valence = _valence;
	}
}