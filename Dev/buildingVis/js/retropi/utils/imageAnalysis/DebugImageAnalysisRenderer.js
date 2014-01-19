(function() {
	
	retropi.createClass("utils.imageAnalysis", "DebugImageAnalysisRenderer", function(aClassObject, aClassPrototype, aClassName){

		var p = aClassPrototype;

		p.init = function() {

			this._sourceImageWidth = 0;
			this._sourceImageHeight = 0;
			this._cellSize = 0;

			this._debugCanvas = null;
			this._ctx = null;

			this._renderData = null;

		};


		p.render = function(aSourceImage, aDebugCanvas, aCellSize, aData) {

			this._sourceImageHeight = aSourceImage.height;
			this._sourceImageWidth = aSourceImage.width;

			this._debugCanvas = aDebugCanvas;
			this._ctx = this._debugCanvas.getContext("2d");
			this._debugCanvas.width = this._sourceImageWidth;
			this._debugCanvas.height = this._sourceImageHeight;

			this._cellSize = aCellSize;

			this._renderData = aData;

			var drawX = 0;
			var drawY = 0;

			var dataValue = 0;


			for (var i=0; i< this._renderData.length; i++){

				for (var j=0; j < this._renderData[i].length; j++){

					drawX = j * this._cellSize;
					drawY = i * this._cellSize;

					dataValue = this._renderData[i][j] / 255;

					this._ctx.fillStyle = "rgba(255,0,255," + dataValue + ")";

					this._ctx.fillRect(drawX, drawY, this._cellSize, this._cellSize);

					// this._ctx.fillStyle = "red";

					// this._ctx.fillText(dataValue.toString().substr(0,3), drawX, drawY);


				}

			}


		};

	});

	


})();