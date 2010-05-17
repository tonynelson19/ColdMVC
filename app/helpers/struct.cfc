/**
 * @extends coldmvc.Helper
 */
component {

	public string function toQueryString(required struct data) {
		
		return $.data.toQueryString(data);
		
	}
	
}