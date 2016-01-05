typedef ElementCount = {element: String, count: Int};

class MolecularFormula {
	public var elements = new Array<ElementCount>();
	public function new() {

	}
	public function add(targetElement: String) { // adds an element to the molecule
		for (element in elements) {
			if (element.element == targetElement) {
				element.count++;
				return;
			}
		}
		elements.push({element: targetElement, count: 1});
	}
	public function sort() {
		var newElements = new Array<ElementCount>();

		// sort molecular formula by C, H, then in alphabetical order
		for (element in elements) {
			if (element.element == "C") {
				newElements.push(element);
			}
		}
		for (element in elements) {
			if (element.element == "H") {
				newElements.push(element);
			}
		}

		elements.sort(function(a: ElementCount, b: ElementCount) {
			if (a.element < b.element) return -1;
			else if (a.element > b.element) return 1;
			else return 0;
		});

		for (element in elements) {
			if (element.element != "C" && element.element != "H") {
				newElements.push(element);
			}
		}

		elements = newElements;
	}
}