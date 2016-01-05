typedef NodeDistance = {node: Point, distance: Int};

class Molecule {
	public var height: Int;
	public var width: Int;
	public var grid: Array< Array<Unit> >;
	public var adjacency: Array< Array< Array<Int> > >; // a height * width * 8 array representing the adjacency of units

	public function new(_height: Int, _width: Int) {
		this.height = _height;
		this.width = _width;
		this.grid = new Array< Array<Unit> >();
		this.adjacency = new Array< Array< Array<Int> > >();

		// create a height*width grid of CARBON
		for (i in 0...this.height) {
			var row = new Array<Unit>();
			for (j in 0...this.width) {
				row.push(new Unit(UnitType.CARBON));
			}
			grid.push(row);
		}

		// form no bonds with all adjacent grid
		for (i in 0...this.height) {
			var row = new Array< Array<Int> >();
			for (j in 0...this.width) {
				var adj = new Array<Int>();
				for (k in 0...8) {
					adj.push(0);
				}
				row.push(adj);
			}
			adjacency.push(row);
		}
	}

	public function numberBonds(x: Int, y: Int) : Int {
		var sum: Int = 0;
		for (i in 0...8) {
			sum += adjacency[x][y][i];
		}
		return sum;
	}

	private function dfs(point: Point, prev: Point,  distance: Int) : NodeDistance {
		var currentMaximum: NodeDistance = {node: point, distance: distance};
		for (i in 0...8) {
			var newpoint: Point = point.move(i);
			if (!newpoint.valid(this.height, this.width)) {
				continue;
			}
			if (this.grid[newpoint.x][newpoint.y].type.name != "Carbon" || (newpoint.x == prev.x && newpoint.y == prev.y)) {
				continue;
			}
			if (adjacency[point.x][point.y][i] == 0) {
				continue;
			}
			var branch: NodeDistance = dfs(newpoint, point, distance + 1);
			if (branch.distance > currentMaximum.distance) {
				currentMaximum = branch;
			}
		}
		return currentMaximum;
	}

	private function tracePath(point: Point, targetPoint: Point, prev: Point): Array<Point> {
		var currentPath = new Array<Point>();
		for (i in 0...8) {
			var newpoint: Point = point.move(i);
			if (!newpoint.valid(this.height, this.width)) {
				continue;
			}
			if (this.grid[newpoint.x][newpoint.y].type.name != "Carbon" || (newpoint.x == prev.x && newpoint.y == prev.y)) {
				continue;
			}
			if (adjacency[point.x][point.y][i] == 0) {
				continue;
			}
			var branch = tracePath(newpoint, targetPoint, point);
			if (branch.length != 0) {
				currentPath = branch;
			}
		}
		if (point.x == targetPoint.x && point.y == targetPoint.y) {
			currentPath.push(point);
		}
		return currentPath;
	}

	public function findLongestChain() : Array<Point> {
		var root: Point = new Point(-1, -1);
		for (i in 0...this.height) {
			for (j in 0...this.width) {
				if (numberBonds(i, j) != 0) {
					root = new Point(i, j);
				}
			}
		}
		// find "diameter of graph"
		var furthestUnit = dfs(root, new Point(-1, -1), 0);
		var secondFurthest = dfs(furthestUnit.node, new Point(-1, -1), 0);

		return tracePath(furthestUnit.node, secondFurthest.node, new Point(-1, -1));
	}

	public function getMolecularFormula(): MolecularFormula {
		var result = new MolecularFormula();
		for (i in 0...this.height) {
			for (j in 0...this.width) {
				if (numberBonds(i, j) != 0) {
					result.add(this.grid[i][j].type.symbol);
				}
			}
		}
		return result;
	}
}