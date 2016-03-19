class Point {
	public var x: Int;
	public var y: Int;
	public static var directions = [
		new Point(-1, 0), // up
		new Point(-1, 1), // up-right
		new Point(0, 1), // right
		new Point(1, 1), // down-right
		new Point(1, 0), // down
		new Point(1, -1), // down-left
		new Point(0, -1), // left
		new Point(-1, -1) // top-left
	];
	public function new(_x: Int, _y: Int) {
		this.x = _x;
		this.y = _y;
	}
	public function valid(height: Int, width: Int) : Bool {
		if (this.x < 0 || this.x >= height) {
			return false;
		} else if (this.y < 0 || this.y >= width) {
			return false;
		} else return true;
	}
	public function move(direction: Int) : Point {
		return new Point(this.x + directions[direction].x, this.y + directions[direction].y);
	}
}