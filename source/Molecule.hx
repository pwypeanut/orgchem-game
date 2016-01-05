class Molecule {
	public var height: Int;
	public var width: Int;
	public var grid: Array< Array<Unit> >;
	public var adjacency: Array< Array< Array<Int> > >; // a height * width * 8 array representing the adjacency of units

	public function new(_height: Int, _width: Int) {
		this.height = _height;
		this.width = _width;
		this.grid = new Array< Array<Unit> >();

		// create a height*width grid of CARBON
		for (var i in 0...height) {
			var row = new Array<Unit>();
			for (var j in 0...width) {
				row.push(Unit(UnitType.CARBON));
			}
			grid.push(row);
		}

		// form no bonds with all adjacent grid
		for (var i in 0...height) {
			var row = new Array< Array<Int> >();
			for (var j in 0...width) {
				var adj = new Array<Int>();
				for (var k in 0...8) {
					adj.push(0);
				}
				row.push(adj);
			}
			adjacency.push(row);
		}
	}
}