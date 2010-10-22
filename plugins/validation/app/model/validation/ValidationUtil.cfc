<cfcomponent output="false" accessors="true">

	<cffunction name="renderScript" access="public" output="false" returntype="string">
		<cfargument name="validation" required="true" type="struct" />

		<cfset var html = "" />

		<cfsavecontent variable="html">
			<script type="text/javascript">
				<!--
					$(function(){
						// alert('here');
					});
				//-->
			</script>
		</cfsavecontent>

		<cfreturn html />

	</cffunction>

</cfcomponent>