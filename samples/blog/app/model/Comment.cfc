/**
* @extends coldmvc.Model
* @persistent true
*/
component  {

	property id;
	property author;
	property body;
	property date;
	property email;
	property website;
	property post;
	
	function preInsert() {
		setDate(now());
	}
	
	function displayDate() {
		
		var date = this.date();
		
		return dateFormat(date, 'mmmm') & " " & $.string.toOrdinal(dateFormat(date, 'd')) & ", " & dateFormat(date, 'yyyy') & " at " & timeFormat(date, 'h:mm tt');
	
	}
	
}