ColdMVC.validation = {

	validators: {},
	
	getValidator: function(form){
	
		if (!ColdMVC.structKeyExists(this.validators, form)) {		
			var validator = new ColdMVC.validation.validator(form);
			this.validators[form] = validator;			
		}
		
		return this.validators[form];
		
	},
	
	rules: {

		NotEmpty: function(value) {
			return !this.optional(value);
		},
		
		Min: function(value, data) {
			return this.optional(value) || value.length >= data.value;
		},
		
		Max: function(value, data) {
			return this.optional(value) || value.length <= data.value;
		},
		
		Date: function(value) {
			return this.optional(value) || !/Invalid|NaN/.test(new Date(value));
		}

	},
	
	addRule: function(name, method) {
		
		if (!ColdMVC.structKeyExists(this.rules, name)) {
			this.rules[name] = method;
		}
	
	},
	
	optional: function(value) {
		return value == '';
	}

}

ColdMVC.validation.validator = function(form) {
	
	this.form = form;
	var instance = this;
	
	if ($('#'+form).length) {
		instance.init();
	}
	else {
		$(document).ready(function() {
			if ($('#' + form).length) {			
				instance.init();			
			}
		});
	}
	
	return this;
}

$.extend(ColdMVC.validation.validator.prototype, {
		
	errors: [],
	rules: [],
	functions: [],
	
	init: function() {

		var instance = this;
		var formObj = $('#'+this.form).get(0);		
		var fn = formObj.onsubmit;

		if (typeof(fn) == 'function') {
			this.addFunction(fn);
		}

		formObj.onsubmit = function() {
		
			instance.clearErrors();
			instance.validate();
			
			if (instance.hasErrors()) {
			
				var errors = instance.getErrors();
				var html = [];
				
				$.each(errors, function(i, error){
					html.push(error.message);
				});
				
				html = ColdMVC.arrayToList(html, '<br />');

				// make more dynamic
				if (!$('#validation').length) {
					$('#'+instance.form).before('<div id="validation"></div>');
				}
				
				$('#validation').html(html);
				
				return false;
				
			}
			
			return true;
			
		}

	},
	
	validate: function() {
		
		var data = this.getData();
		
		for (var i in this.rules) {
			
			var rule = this.rules[i];
			var value = '';
			
			if (ColdMVC.structKeyExists(data, rule.property)) {
				value = data[rule.property];
			}
			
			if (!rule.method(value, rule.data)) {
				this.addError(rule.property, rule.message);
			}
			
		}
		
		// loop over custom functions?
		
	},
	
	addError: function(property, message) {
		
		this.errors.push({
            property: property,
			message: message
        });
		
	},

	clearErrors: function() {
		this.errors = [];
	},

	hasErrors: function() {
		return this.errors.length > 0;
	},

	getErrors: function() {
		return this.errors;
	},		
	
	addRule: function(rule) {
		
		var defaults = {
			property: '',
			message: '',
			method: $.noop,
			data: {}
		}
		
		rule = $.extend(defaults, rule);
			
		this.rules.push(rule);		
	},
	
	addFunction: function(fn) {
		this.functions.push(fn);		
	},
	
	getData: function() {
		return ColdMVC.serializeForm('#'+this.form);
	}

});