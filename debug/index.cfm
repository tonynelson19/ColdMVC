<style type="text/css">
	div#coldmvc_debug {
		color: #555;
		font-size: 14px;
		padding: 5px 30px;
		line-height: 20px;
		font-family: Arial, Verdana, Helvetica, sans-serif;
		border-top: 1px solid #666;
	}

	div#coldmvc_debug * {
		padding: 0;
		margin: 0;
	}

	div#coldmvc_debug h2 {
		font-weight: bold;
		padding: 5px;
		font-size: 14px;
	}

	div#coldmvc_debug div.coldmvc_debug_section {
		padding-left: 15px;
		padding-bottom: 5px;
		border-bottom: 1px solid #bbb;
	}

	div#coldmvc_debug td.coldmvc_label,
	div#coldmvc_debug td.coldmvc_field {
		vertical-align: top;
	}

	div#coldmvc_debug td.coldmvc_label {
		width: 200px;
		color: #777;
		padding-right: 3px;
	}

	div#coldmvc_debug h4 {
		font-weight: bold;
	}

	div#coldmvc_debug ul li {
		list-style-type: none;
	}

	div#coldmvc_debug ul li.coldmvc_debug_query {
		padding-bottom: 20px;
	}

	div#coldmvc_debug ul li.coldmvc_debug_query h4 {
		padding-top: 5px;
		padding-left: 20px;
	}

	div#coldmvc_debug ul li.coldmvc_debug_query ul {
		padding-left: 30px;
	}

	div#coldmvc_debug ul li.coldmvc_debug_query ul li span {
		color: #777;
	}
</style>

<cfoutput>
<div id="coldmvc_debug">
	<cfinclude template="info.cfm" />
	<cfinclude template="queries.cfm" />
	<cfinclude template="events.cfm" />
	<cfinclude template="beans.cfm" />
	<cfinclude template="config.cfm" />
	<cfinclude template="params.cfm" />
</div>
</cfoutput>