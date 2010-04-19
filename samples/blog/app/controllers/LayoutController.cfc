/**
 * @accessors true
 * @extends coldmvc.LayoutController
 */
component {

	property _Category;

	function index() {

		params.categories = _Category.findAllWithPosts({
			sort = "name"
		});

	}

}