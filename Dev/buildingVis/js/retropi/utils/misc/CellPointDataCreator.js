(function() {
	
	retropi.createClass("utils.misc", "CellPointDataCreator", null, function(aClassObject, aClassPrototype, aClassName){

		var p = aClassPrototype;

		p.init = function() {



		};

		p.createData = function(aSource, aMaxPointsPerCell, aRangeConversionFunction){

			var numCellsAcross = aSource[0].length;
			var numCellsDown = aSource.length;

			var cellSize = 1 / numCellsAcross;

			var pointData = [];
			var numPointsInThisCell = 0;
			var refX, refY =0;

			for (var i=0; i< aSource.length; i++){
				
				for (var j=0; j < aSource[i].length; j++){

					if (!aRangeConversionFunction)
						numPointsInThisCell = aMaxPointsPerCell * aSource[i][j];
					else
						numPointsInThisCell = aRangeConversionFunction.call(this, aMaxPointsPerCell, aSource[i][j]);

					refY = i * cellSize;
					refX = j * cellSize;

					for (var k=0; k < numPointsInThisCell; k++){

						var newPoint = {};
						newPoint.x = refX + (this.getGaussianRandomNumber() * cellSize);
						newPoint.y = refY + (this.getGaussianRandomNumber() * cellSize);

						pointData.push(newPoint);

					}

				}
			}

			return pointData;


		};

		p.getGaussianRandomNumber = function() {

			var num_components = 2;
			var normal =0;
			for(var i=0; i<num_components;i++){
				normal += Math.random();
			}

			return normal / num_components;

			// return ((Math.random()*2-1)+(Math.random()*2-1)+(Math.random()*2-1)) * aStandardDeviation + aMean;
		};


	});

	


})();