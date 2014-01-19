(function() {
	
	retropi.createClass("utils.imageAnalysis", "ImageAverageAnalyser", function(aClassObject, aClassPrototype, aClassName){

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
				
				

				var debugCanvas = document.getElementById("debugCanvas");
				var ctx = debugCanvas.getContext("2d");

				ctx.strokeStyle = "rgba(255,0,255, 0.5)";

				var imageData = null;
				var blockAverages = [];
				var cellAverage = 0;
				var pixelAverage = 0;
				var totalAverage = 0;
				for (var i = 0; i < numCellsDown; i++){

					blockAverages[i] = [];
					for (var j = 0; j < numCellsAcross; j++){

						// console.log("sampling : " + (j * aCellSize) + ", " + (i * aCellSize) + " to " + ((j * aCellSize) + aCellSize) + ", " + ((i * aCellSize) + aCellSize));

						imageData = this._analysisCtx.getImageData( j * aCellSize, i * aCellSize , aCellSize , aCellSize ).data;
						
						

						cellAverage = 0;
						pixelAverage = 0;
						var channelCount = 0;

						for (var idx = 0; idx < imageData.length; idx+= 4){

							pixelAverage += imageData[idx];
							pixelAverage += imageData[idx+1];
							pixelAverage += imageData[idx+2];
							pixelAverage /= 3;

							cellAverage += pixelAverage;
						}
						
						cellAverage = Math.floor(cellAverage / (imageData.length / 4));

						blockAverages[i][j] = cellAverage;

						ctx.fillStyle = "rgba(" + cellAverage + ", " + 0 + ", " + 0 +  ", 0.5)";

						ctx.fillStyle = (cellAverage > 40) ? "red" : "black";

						ctx.fillRect(j * aCellSize, i * aCellSize , (j * aCellSize) + aCellSize , (i * aCellSize) + aCellSize);
						ctx.strokeRect(j * aCellSize, i * aCellSize , (j * aCellSize) + aCellSize , (i * aCellSize) + aCellSize);
						totalAverage += blockAverages[i][j];
					}	

				}

				totalAverage /= (numCellsDown * numCellsAcross);

				console.log("ImageAverageAnalyser :: Complete, totalAverage : ", totalAverage, " no. of cells : ", this._lastNumberOfCells);
				this._lastData = blockAverages;

				// this._analysisCanvas = null;
				this._completeCallback.call(this, this._lastData);


			}.bind(this);
			this._sourceImage.src = aImageSource;


		};

	});

	


})();