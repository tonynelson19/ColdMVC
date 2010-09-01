/**
 * @accessors true
 * @action main
 * @extends coldmvc.Controller
 */
component {

	property bookmarkService;
	property categoryService;
	property commentService;
	property entryService;
	property rssService;
	property securityService;
	property userService;

	function pre() {

		params.isAdmin = securityService.isAuthenticated();
		params.bookmarks = bookmarkService.getBookmarks();
		params.categories = categoryService.getCategoriesWithCounts();

	}

	function bookmark() {

		var id = 0;

		if (structKeyExists(params, "bookmarkBean")) {
			return;
		}
		if (structKeyExists(params, "bookmarkID")) {
			id = val(params.bookmarkID);
		}
		if (id == 0) {
			params.bookmarkBean = bookmarkService.getNewBookmark();
		}
		else {
			params.bookmarkBean = bookmarkService.getBookmarkById(id);
		}

	}

	function category() {

		var id = 0;

		if (structKeyExists(params, "categoryBean")) {
			return;
		}
		if (structKeyExists(params, "categoryID")) {
			id = val(params.categoryID);
		}
		if (id == 0) {
			params.categoryBean = categoryService.getNewCategory();
		}
		else {
			params.categoryBean = categoryService.getCategoryById(id);
		}

	}

	function comments() {

		var id = 0;

		if (structKeyExists(params, "entryID")) {
			id = val(params.entryID);
		}
		params.entry = entryService.getEntryById(id);
		if (structKeyExists(params, "commentBean")) {
			return;
		}
		params.commentBean = commentService.getNewComment();

	}

	function deleteBookmark() {

		var id = 0;

		if (structKeyExists(params, "bookmarkID")) {
			id = val(params.bookmarkID);
		}
		bookmarkService.removeBookmark(id);
		redirect({action="main"});
	}

	function deleteCategory() {

		var id = 0;

		if (structKeyExists(params, "categoryID")) {
			id = val(params.categoryID);
		}
		categoryService.removeCategory(id);
		redirect({action="main"});
	}

	function deleteEntry() {

		var id = 0;

		if (structKeyExists(params, "entryID")) {
			id = val(params.entryID);
		}

		entryService.removeEntry(id);
		redirect({action="main"});
	}

	function doLogin() {

		var user = userService.authenticate(params.username, params.password);

		if (user.isNull()) {
			flash.message = "User not found!";
			redirect({action="login"});
		}
		else {
			redirect({action="main"});
		}

	}

	function entry() {

		var id = 0;

		if (structKeyExists(params, "entryBean")) {
			return;
		}
		if (structKeyExists(params, "entryID")) {
			id = val(params.entryID);
		}
		if (id == 0) {
			params.entryBean = entryService.getNewEntry();
		}
		else {
			params.entryBean = entryService.getEntryById(id);
		}

	}

	function logout() {

		securityService.removeUserSession();
		redirect({action="main"});

	}

	function main() {

		if (structKeyExists(params, "categoryID") and val(params.categoryID) gt 0) {
			params.entries = entryService.getEntriesByCategoryID(categoryID);
		}
		else {
			params.entries = entryService.getEntries();
		}

	}

	function rss() {

		var args = {
			blogName = "LitePost - ColdMVC Edition",
			blogURL = "http://localhost/litepost/cmvc/",
			blogDescription = "The ColdMVC Edition of LitePost",
			blogLanguage = "en_US",
			numEntries = 20,
			authorEmail = "tonynelson19@gmail.com",
			webmasterEmail = "tonynelson19@gmail.com",
			eventParameter = $.event.action(),
			args.eventLocation = "blog/comments/",
			args.generator = "LitePost"
		};

		args.blogLanguage = replace(lcase(args.blogLanguage), "_", "-", "one");

		if (structKeyExists(params, "categoryID")) {
			args.categoryId = params.categoryId;
			args.categoryName = params.categoryName;
			params.rss = rssService.getCategoryRSS(argumentCollection=args);
		}
		else {
			params.rss = rssService.getBlogRSS(argumentCollection=args);
		}

	}

	function saveBookmark() {

		var bean = bookmarkService.getBookmarkById(params.bookmarkID);
		bean.setBookmarkID(params.bookmarkID);
		bean.setName(params.name);
		bean.setURL(params.url);

		if (bean.validate()) {

			bookmarkService.saveBookmark(bean);
			redirect({action="main"});

		}
		else {

			flash.message = "Please complete the bookmark form!";
			flash.bookmarkBean = bean;
			redirect({action="bookmark"});

		}
	}

	function saveCategory() {

		var bean = categoryService.getCategoryById(params.categoryID);
		bean.setCategoryID(params.categoryID);
		bean.setCategory(params.category);

		if (bean.validate()) {

			categoryService.saveCategory(bean);
			redirect({action="main"});

		}
		else {

			flash.message = "Please complete the category form!";
			flash.categoryBean = bean;
			redirect({action="category"});

		}
	}

	function saveComment() {

		var bean = commentService.getNewComment();
		bean.setName(params.name);
		bean.setURL(params.url);
		bean.setEmail(params.email);
		bean.setComment(params.comment);
		bean.setEntryID(params.entryID);

		if (bean.validate()) {

			commentService.saveComment(bean);
			redirect({action="comments"}, "entryId=#params.entryID#");

		}
		else {

			flash.message = "Please complete the comment form!";
			flash.commentBean = bean;
			redirect({action="comments"}, "entryId=#params.entryID#");

		}
	}

	function saveEntry() {

		var bean = entryService.getEntryById(params.entryID);
		bean.setEntryID(params.entryID);
		bean.setTitle(params.title);
		bean.setCategoryID(params.categoryID);
		bean.setBody(params.body);

		if (bean.validate()) {

			entryService.saveEntry(bean);
			redirect({action="main"});

		}
		else {

			flash.message = "Please complete the entry form!";
			flash.entryBean = bean;
			redirect({action="entry"});

		}
	}

}