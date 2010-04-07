<cfset add("logout", {
	pattern = "/logout",
	defaults = {
		controller="session",
		action="logout"
	}
}) />