<cfsilent>
<cfset debugStartingTickCount = getTickCount() />
<cfset templates = coldmvc.framework.getBean("debugManager").getTemplates() />
</cfsilent>

<style type="text/css">
	div#coldmvc_debug {
		background-color: #fff !important;
		color: #333 !important;
		font-size: 14px !important;
		margin-top: 30px !important;
		padding: 5px 30px !important;
		line-height: 20px !important;
		font-family: Arial, Verdana, Helvetica, sans-serif !important;
		border-top: 1px solid #666 !important;
		text-align: left !important;
	}

	div#coldmvc_debug * {
		padding: 0 !important;
		margin: 0 !important;
		text-align: left !important;
		color: #555 !important;
		line-height: 20px !important;
	}

	div#coldmvc_debug h2 {
		font-weight: bold !important;
		padding: 5px !important;
		font-size: 14px !important;
	}

	div#coldmvc_debug div.coldmvc_debug_section {
		padding-left: 5px !important;
		padding-bottom: 5px !important;
		border-bottom: 1px solid #bbb !important;
	}

	div#coldmvc_debug td.coldmvc_label,
	div#coldmvc_debug td.coldmvc_field {
		vertical-align: top !important;
		border: 0 !important;
	}

	div#coldmvc_debug td.coldmvc_label {
		width: 220px !important;
		padding-right: 3px !important;
	}

	div#coldmvc_debug td.coldmvc_label.coldmvc_field {
		width: auto !important;
	}

	div#coldmvc_debug h4 {
		font-weight: bold !important;
	}

	div#coldmvc_debug ul li {
		list-style-type: none !important;
	}

	div#coldmvc_debug ul li.coldmvc_debug_query {
		padding-bottom: 20px !important;
	}

	div#coldmvc_debug ul li.coldmvc_debug_query h4 {
		padding-top: 5px !important;
		padding-left: 20px !important;
	}

	div#coldmvc_debug ul li.coldmvc_debug_query ul {
		padding-left: 30px !important;
	}

	div#coldmvc_debug ul li.coldmvc_debug_query ul li span {
		color: #777 !important;
	}

	div#coldmvc_debug div#coldmvc_debug_time {
		padding: 5px !important;
	}

	table.cfdebug table.cfdebug {
		padding: 0 !important;
	}

	table.cfdebug {
		padding: 5px 30px !important;
		line-height: 20px !important;
		width: 100%;
	}

	/* friendly neighbor */
	table.cfdebug * {
		font-family: Arial, Verdana, Helvetica, sans-serif !important;
		font-size: 14px;
		color: #555;
	}

	table.cfdebug hr {
		border: 0;
		border-top: 1px solid #bbb;
	}
</style>

<cfoutput>
<div id="coldmvc_debug">
	<cfloop array="#templates#" index="template">
		<cfinclude template="#template#" />
	</cfloop>
	<cfset debugEndingTickCount = getTickCount() />
	<div id="coldmvc_debug_time">
		ColdMVC Debug Rendering Time: #(debugEndingTickCount - debugStartingTickCount)# ms
	</div>
</div>
</cfoutput>