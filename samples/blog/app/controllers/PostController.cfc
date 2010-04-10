/**
 * @accessors true
 * @action list
 * @extends coldmvc.Controller
 */
component {

	property _Category;
	property _Comment;

	function addComment() {

		var post = _Post.get(params.comment.postID);

		var comment = _Comment.new(params.comment);
		comment.save();

		flash.message = "Comment added successfully";

		redirect(url="#post.url()####arrayLen(post.comments())#");

	}

	function category() {

		if (!structKeyExists(params, "id")) {
			params.category = _Category.findByLink(params.link);
			params.id = params.category.id();
		}

		var paging = $.paging.options();

		params.posts = _Post.findAllByCategoryID(params.id, {
			sort = "date",
			order = "asc",
			max = paging.max,
			offset = paging.offset
		});

		var count = _Post.countByCategoryID(params.id);

		params.page = paging.page;
		params.pages = $.paging.pages(count);

	}

	function show() {
		params.post = _Post.findByLink(params.link);
	}

	function list() {

		var paging = $.paging.options();

		params.posts = _Post.list({
			sort = "date",
			order = "desc",
			max = paging.max,
			offset = paging.offset
		});

		params.page = paging.page;
		params.pages = $.paging.pages(_Post.count());

	}

	private array function parseCategories(string categories) {

		categories = $.string.toArray(categories);

		var result = [];
		var i = "";

		for (i=1; i <= arrayLen(categories); i++) {

			var name = categories[i];
			var category = _Category.findByName(name);

			if (!category.exists()) {
				category.name(name);
				category.save();
			}

			arrayAppend(result, category);

		}

		return result;

	}

	function save() {

		var post = _Post.new();
		params.post.categories = parseCategories(params.post.categories);
		post.populate(params.post);
		post.save();

		redirect({action="show", id=post});

	}

	function update() {

		var post = _Post.get(params.post.id);
		params.post.categories = parseCategories(params.post.categories);
		post.populate(params.post);
		post.save();

		redirect({action="show", id=post});

	}

}