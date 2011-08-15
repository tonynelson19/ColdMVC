component implements="cfide.orm.INamingStrategy" {

	public string function getTableName(string tableName) {
	
		return uncamelize(arguments.tableName);
	
	}

	public string function getColumnName(string columnName) {
	
		return uncamelize(arguments.columnName);
	
	}

	private string function uncamelize(required string name) {

		var array = [];
		var i = "";

		for (i = 1; i <= len(arguments.name); i++) {

			var char = mid(arguments.name, i, 1);

			if (i == 1) {
    			
    				arrayAppend(array, ucase(char));
   			
   			} else {
    			
    			if (reFind("[A-Z]", char)) {
     				arrayAppend(array, "_" & char);
   				} else {
     				arrayAppend(array, lcase(char));
    			}
   			
   			}
  		
  		}

  		var newName = arrayToList(array, "");

  		if (newName == "Id" || newName == "I_D") {
   			newName = "ID";
  		} else if (right(newName, 3) == "_Id") {
   			newName = left(newName, len(newName) - 3) & "_ID";
  		}
  		
  		newName = replace(newName, "__", "_", "all");

  		return newName;

	}

}