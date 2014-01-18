(function() {
	
	retropi.createClass("utils", "ImageAverageAnalyser", function(aClassObject, aClassPrototype, aClassName){

		var p = aClassPrototype;

		p.init = function() {

			this._sourceImage = null;
			this._analysisCanvas = null;
			this._analysisCtx = null;

			this._lastData = [];
			this._lastNumberOfCells = 0;

			this._completeCallback = null;

		};


		p.analyse = function(aImageSource, aCellSize, aMaxValue, aCallbackMethod) {

			this._completeCallback = aCallbackMethod;
			this._sourceImage = new Image();
			this._sourceImage.onload = function() {

				var numCellsAcross = Math.floor(this._sourceImage.width / aCellSize);
				var numCellsDown = Math.floor(this._sourceImage.height / aCellSize);

				this._lastNumberOfCells = numCellsAcross * numCellsDown;

				this._analysisCanvas = document.createElement("canvas");
				this._analysisCtx = this._analysisCanvas.getContext("2d");
				this._analysisCanvas.width = this._sourceImage.width;
				this._analysisCanvas.height = this._sourceImage.height;

				this._analysisCtx.drawImage(this._sourceImage, 0, 0);

				var imageData = null;
				var blockAverages = [];
				var cellAverage = 0;
				var totalAverage = 0;
				for (var i = 0; i < numCellsDown; i++){

					blockAverages[i] = [];
					for (var j = 0; j < numCellsAcross; j++){

						imageData = this._analysisCtx.getImageData( i * aCellSize, j * aCellSize , (i * aCellSize) + aCellSize , (j * aCellSize) + aCellSize ).data;
						cellAverage = 0;
						for (var idx = 0; idx < imageData.length; idx += 4){

							cellAverage += imageData[idx];
							
						}
						blockAverages[i][j] = Math.floor(cellAverage / (imageData.length / 4));
						totalAverage += blockAverages[i][j];
					}	

				}

				totalAverage /= (numCellsDown * numCellsAcross);

				console.log("ImageAverageAnalyser :: Complete, totalAverage : ", totalAverage, " no. of cells : ", this._lastNumberOfCells);
				this._lastData = blockAverages;

				this._analysisCanvas = null;
				this._completeCallback.call(this, this._lastData);


			}.bind(this);
			this._sourceImage.src = aImageSource;


		};

	});

	


})();