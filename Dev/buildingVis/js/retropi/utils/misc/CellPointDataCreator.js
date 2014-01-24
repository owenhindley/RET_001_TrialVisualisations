(function() {
	
	retropi.createClass("utils.misc", "CellPointDataCreator", function(aClassObject, aClassPrototype, aClassName){

		var p = aClassPrototype;

		p.init = function() {



		};

		p.createData = function(aSource, aMaxPointsPerCell){

			var numCellsAcross = aSource[0].length;
			var numCellsDown = aSource.length;

			var cellSize = 1 / numCellsAcross;

			var pointData = [];
			var numPointsInThisCell = 0;
			var refX, refY =0;

			for (var i=0; i< aSource.length; i++){
				
				for (var j=0; j < aSource[i].length; j++){

					numPointsInThisCell = aMaxPointsPerCell * aSource[i][j];

					refX = i * cellSize;
					refY = j * cellSize;

					for (var k=0; k < numPointsInThisCell; k++){

						var newPoint = {};
						newPoint.x = refX + (Math.random() * cellSize);
						newPoint.y = refY + (Math.random() * cellSize);

						pointData.push(newPoint);

					}

				}
			}


		};


	});

	


})();