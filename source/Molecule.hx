typedef AdjInfo = {carbon: Int, unit: Point, source: Point};
typedef StrComponent = {type: String, position: Int};
typedef ChainInfo = {sideChains: Array<AdjInfo>, source: Point, end: Point};

class Molecule {
	private var chainPrefixes: Array<String> = ["meth", "eth", "prop", "but", "pent", "hex", "hept", "oct", "non", "dec", "undec", "dodec", "tridec", "tetradec", "pentadec", "hexadec"];
	private var countPrefixes: Array<String> = ["", "di", "tri", "tetra", "penta", "hexa", "hepta", "octa", "nona", "deca", "undeca", "dodeca", "trideca", "tetradeca", "pentadeca", "hexadeca"];
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
		if (point.x == targetPoint.x && point.y == targetPoint.y || currentPath.length > 0) {
			currentPath.push(point);
		}
		if (point.x == prev.x && point.y == prev.y) {
			currentPath.reverse();
		}
		return currentPath;
	}

	private function processStringComponents(strComponents: Array<StrComponent>, chainLength: Int): String {
		strComponents.sort(function(a: StrComponent, b: StrComponent) {
			if (a.type != b.type) {
				if (a.type < b.type) return -1;
				else return 1;
			}
			else {
				if (a.position < b.position) return -1;
				else if (a.position == b.position) return 0;
				else return 1;
			}
		});

		var resultantString = "";
		var currentPositions = new Array<Int>();
		var firstComponent = false;
		if (strComponents.length > 0) {
			for (i in 0...strComponents.length + 1) {
				if (i == strComponents.length || (i != 0 && strComponents[i].type != strComponents[i - 1].type)) {
					var countPrefix = countPrefixes[currentPositions.length - 1];
					var componentString = "";
					if (!firstComponent) {
						firstComponent = true;
					} else componentString += "-";

					for (j in 0...currentPositions.length) {
						if (j != 0) {
							componentString += ",";
						}
						componentString += currentPositions[j] + 1;
					}
					componentString += "-" + countPrefix + strComponents[i - 1].type;
					resultantString += componentString;
					currentPositions = new Array<Int>();
				}
				if (i != strComponents.length) currentPositions.push(strComponents[i].position);
			}

			if (!(strComponents[strComponents.length - 1].type == "chloro" ||
				strComponents[strComponents.length - 1].type == "fluoro" ||
				strComponents[strComponents.length - 1].type == "iodo" ||
				strComponents[strComponents.length - 1].type == "bromo")) {

				resultantString += " ";
			}
		}

		resultantString += chainPrefixes[chainLength - 1];

		return resultantString;
	}

	private function countCarbon(point: Point): Int {
		var numberCarbon = 0;
		for (m in 0...8) {
			var newPoint = point.move(m);
			if (!newPoint.valid(this.height, this.width)) {
				continue;
			}
			if (adjacency[point.x][point.y][m] == 0) {
				continue;
			}
			if (grid[newPoint.x][newPoint.y].type.name == "Carbon") {
				numberCarbon++;
			}
		}
		return numberCarbon;
	}

	private function nameSideBranch(starting: Point, source: Point): String {
		var bestMain = new Array<AdjInfo>();
		var sourceMain = new Point(0, 0);
		var endMain = new Point(0, 0);
		for (i in 0...this.height) {
			for (j in 0...this.width) {
				if (i == starting.x && j == starting.y) {
					continue;
				}
				if (numberBonds(i, j) == 0) {
					continue;
				}
				if (countCarbon(new Point(i, j)) > 1) {
					continue;
				}
				if (grid[i][j].type.name != "Carbon") {
					continue;
				}
				var path: Array<Point> = tracePath(starting, new Point(i, j), starting);
				if (path[1].x == source.x && path[1].y == source.y) {
					// not in this side chain
					continue;
				}

				// find path and find branches
				var path = tracePath(starting, new Point(i, j), starting);
				var sideBranches = new Array<AdjInfo>();
				var count = 0;
				for (point in path) {
					for (m in 0...8) {
						var newPoint = point.move(m);
						if (newPoint.x == source.x && newPoint.y == source.y) {
							continue;
						}
						if (!newPoint.valid(this.height, this.width)) {
							continue;
						}
						if (adjacency[point.x][point.y][m] == 0) {
							continue;
						}
						if (grid[newPoint.x][newPoint.y].type.name != "Carbon") {
							sideBranches.push({carbon: count, unit: newPoint, source: point});
						} else {
							if (count != 0 && path[count - 1].x == newPoint.x && path[count - 1].y == newPoint.y) {
								continue;
							}
							if (count != path.length - 1 && path[count + 1].x == newPoint.x && path[count + 1].y == newPoint.y) {
								continue;
							}
							sideBranches.push({carbon: count, unit: newPoint, source: point});
						}
					}
					count++;
				}

				// compare by longest length, then number of side chains, then lex order of side chains
				var originalLength = tracePath(sourceMain, endMain, sourceMain).length;
				var newLength = path.length;
				if (newLength != originalLength) {
					if (newLength < originalLength) {
						continue;
					} else {
						bestMain = sideBranches;
						sourceMain = starting;
						endMain = new Point(i, j);
					}
				} else if (sideBranches.length != bestMain.length) {
					if (sideBranches.length < bestMain.length) {
						continue;
					} else {
						bestMain = sideBranches;
						sourceMain = starting;
						endMain = new Point(i, j);
					}
				} else {
					for (m in 0...sideBranches.length) {
						if (sideBranches[m].carbon != bestMain[m].carbon) {
							if (sideBranches[m].carbon < bestMain[m].carbon) {
								bestMain = sideBranches;
								sourceMain = starting;
								endMain = new Point(i, j);
								break;
							} else break;
						}
					}
				}
			}
		}

		var strComponents = new Array<StrComponent>();
		for (i in 0...bestMain.length) {
			if (grid[bestMain[i].unit.x][bestMain[i].unit.y].type.name == "Carbon") {
				strComponents.push({type: nameSideBranch(bestMain[i].unit, bestMain[i].source), position: bestMain[i].carbon});
			} else strComponents.push({type: grid[bestMain[i].unit.x][bestMain[i].unit.y].type.prefix, position: bestMain[i].carbon});
		}

		return "(" + processStringComponents(strComponents, tracePath(sourceMain, endMain, sourceMain).length) + "yl)";
	}

	public function getMainChain(): ChainInfo {
		var bestMain = new Array<AdjInfo>();
		var sourceMain = new Point(0, 0);
		var endMain = new Point(0, 0);
		for (i in 0...this.height) {
			for (j in 0...this.width) {
				for (k in 0...this.height) {
					for (l in 0...this.width) {
						var source = new Point(i, j);
						var end = new Point(k, l);

						// ensure source, end are "selected"
						if (numberBonds(source.x, source.y) == 0) {
							continue;
						}

						if (numberBonds(end.x, end.y) == 0) {
							continue;
						}

						if (grid[source.x][source.y].type.name != "Carbon" || grid[end.x][end.y].type.name != "Carbon") {
							continue;
						}


						// ensure source, end are leaf nodes (pruning)
						if (!(countCarbon(source) <= 1 && countCarbon(end) <= 1) || (source.x == end.x && source.y == end.y)) {
							continue;
						}

						// find path and find branches
						var path = tracePath(source, end, source);
						var sideBranches = new Array<AdjInfo>();
						var count = 0;
						for (point in path) {
							for (m in 0...8) {
								var newPoint = point.move(m);
								if (!newPoint.valid(this.height, this.width)) {
									continue;
								}
								if (adjacency[point.x][point.y][m] == 0) {
									continue;
								}
								if (grid[newPoint.x][newPoint.y].type.name != "Carbon") {
									sideBranches.push({carbon: count, unit: newPoint, source: point});
								} else {
									if (count != 0 && path[count - 1].x == newPoint.x && path[count - 1].y == newPoint.y) {
										continue;
									}
									if (count != path.length - 1 && path[count + 1].x == newPoint.x && path[count + 1].y == newPoint.y) {
										continue;
									}
									sideBranches.push({carbon: count, unit: newPoint, source: point});
								}
							}
							count++;
						}

						// compare by longest length, then number of side chains, then lex order of side chains
						var originalLength = tracePath(sourceMain, endMain, sourceMain).length;
						var newLength = path.length;
						if (newLength != originalLength) {
							if (newLength < originalLength) {
								continue;
							} else {
								bestMain = sideBranches;
								sourceMain = source;
								endMain = end;
							}
						} else if (sideBranches.length != bestMain.length) {
							if (sideBranches.length < bestMain.length) {
								continue;
							} else {
								bestMain = sideBranches;
								sourceMain = source;
								endMain = end;
							}
						} else {
							for (m in 0...sideBranches.length) {
								if (sideBranches[m].carbon != bestMain[m].carbon) {
									if (sideBranches[m].carbon < bestMain[m].carbon) {
										bestMain = sideBranches;
										sourceMain = source;
										endMain = end;
										break;
									} else break;
								}
							}
						}
					}
				}
			}
		}
		return {sideChains: bestMain, source: sourceMain, end: endMain};
	}

	public function getName(): String {
		var mainChain: ChainInfo = getMainChain();
		var bestMain: Array<AdjInfo> = mainChain.sideChains;
		var sourceMain: Point = mainChain.source;
		var endMain: Point = mainChain.end;

		var strComponents = new Array<StrComponent>();
		for (i in 0...bestMain.length) {
			if (grid[bestMain[i].unit.x][bestMain[i].unit.y].type.name == "Carbon") {
				strComponents.push({type: nameSideBranch(bestMain[i].unit, bestMain[i].source), position: bestMain[i].carbon});
			} else strComponents.push({type: grid[bestMain[i].unit.x][bestMain[i].unit.y].type.prefix, position: bestMain[i].carbon});
		}

		return processStringComponents(strComponents, tracePath(sourceMain, endMain, sourceMain).length) + "ane";
	}
}