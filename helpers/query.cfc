/**
 * @extends coldmvc.Helper
 */
component {
	
	public struct function toStruct(required query query, numeric row="1") {
		
		var result = {};
		var columns = listToArray(lcase(query.columnList));
		var i = "";
		
		for (i=1; i <= arrayLen(columns); i++) {
			
			result[columns[i]] = trim(query[columns[i]][row]);
			
		}
		
		return result;
		
	}
	
}