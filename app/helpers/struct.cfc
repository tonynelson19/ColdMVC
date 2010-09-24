/**
 * @extends coldmvc.Helper
 */
component {

	public string function toQueryString(required struct data) {
		
		return coldmvc.data.toQueryString(data);
		
	}
	
}