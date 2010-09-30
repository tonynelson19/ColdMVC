<cfset add("/:controller/:action/:id", {
	computed = {
		":controllerID" = ":id"
	}
}) />

<cfset add("/:controller/:action") />

<cfset add("/:controller") />