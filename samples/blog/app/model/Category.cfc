/**
* @extends coldmvc.Model
* @persistent true
*/
component  {

	property id;
	property name;
	property link;
	property url;
	property posts;
	
	function preInsert() {
		setLink(createLink());
	}
	
	function postLoad() {
		setURL();
	}
	
	private function setURL() {
		variables.url = "category/#getLink()#";
	}
	
	private function createLink() {
		
		var link = $.string.slugify(getName());
		
		// check to see if there are any posts with the same link already
		var links = this.findAllByLinkStartsWith(link);
		
		// if there are posts with the same link, append the count to the end
		if (arrayLen(links) > 0) {
			link = link & "--" & arrayLen(links)+1;
		}
		
		return link;
		
	}
	
}