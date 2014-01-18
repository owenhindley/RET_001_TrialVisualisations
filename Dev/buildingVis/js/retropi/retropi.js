(function() {
	
	var retropi = {};
	if (!window.retropi) window.retropi = retropi;

	retropi.getNamespace = function(aNamespace){

		var components = aNamespace.split('.');
		var namespaceObj = retropi;
		for (var i=0; i < components.length; i++){
			if (namespaceObj[components[i]]) namespaceObj[components[i]] = {};
			namespaceObj = namespaceObj[components[i]];
		}
		return namespaceObj;
	};



	retropi.createClass = function(aNamespace, aClassName, aDefinitionFunction){

		var namespace = retropi.getNamespace(aNamespace);
		namespace[aClassName] = new function() {};
		var classObject = namespace[aClassName];
		var prototype = namespace[aClassName].prototype;

		aDefinitionFunction.call(this, classObject, prototype, aClassName);

	};


})();