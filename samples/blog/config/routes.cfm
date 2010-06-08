<cfset add("/:year/:month/:day/:slug", {
	name = "post",
	defaults = {
		controller = "post",
		action = "show"
	},
	requirements = {
		year = "\d{4}"
	},
	computed = {
		link = ":year/:month/:day/:slug"
	},
	model = "post",
	generates = "/:id.link()"
}) />

<cfset add("/category/:link", {
	name = "category",
	defaults = {
		controller = "post",
		action = "category"
	},
	model = "category",
	generates = "/category/:id.link()"
}) />