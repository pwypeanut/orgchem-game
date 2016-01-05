class Molecule {
	public var height : Int;
	public var width : Int;
	public var grid : Array< Array<Unit> >;
	public var adjacency : Array< Array< Array<Int> > >; // a height * width * 8 array representing the adjacency of units
	public function new(_height: Int, _width: Int) {
		this.height = _height;
		this.width = _width;
		this.grid = new Array< Array<Unit> >();
		for (var i = 0; i < this.height; i++) {
			var row = new Array<Unit>();
			for (var j = 0; j < this.width; j++) {

			}
		}
	}
}