/**
* @extends coldmvc.Model
* @persistent true
*/
component  {

	property id;

	/**
	 * @NotNull
	 */
	property title;

	/**
	 * @NotNull
	 */
	property body;
	property date;
	property link;
	property categories;
	property comments;

	function preInsert() {
		setDate(now());
		setLink(createLink());
	}

	private function createLink() {

		var link = [];
		var date = this.date();

		link[1] = year(date);
		link[2] = month(date);
		link[3] = day(date);

		// convert "Hello, World" to "hello-world"
		link[4] = $.string.slugify(getTitle());

		// convert it back to a valid URL like "2010/1/15/hello-world"
		link = arrayToList(link, "/");

		// check to see if there are any posts with the same link already
		var links = this.findAllByLinkStartsWith(link);

		// if there are posts with the same link, append the count to the end
		if (arrayLen(links) > 0) {
			link = link & "--" & arrayLen(links)+1;
		}

		return link;

	}

	function displayDate() {

		var date = this.date();

		return dateFormat(date, 'mmmm') & " " & $.string.toOrdinal(dateFormat(date, 'd')) & ", " & dateFormat(date, 'yyyy') & " at " & timeFormat(date, 'h:mm tt');

	}

	function categoryList() {

		var array = [];
		var categories = this.categories();
		var i = "";

		for (i = 1; i <= arrayLen(categories); i++) {
			arrayAppend(array, categories[i].name());
		}

		return arrayToList(array, ", ");

	}

}