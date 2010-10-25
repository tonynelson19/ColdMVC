<cfcomponent output="false" accessors="true">

	<cfproperty name="validator" />

	<cffunction name="renderScript" access="public" output="false" returntype="string">
		<cfargument name="validation" required="true" type="struct" />

		<cfset var html = "" />

		<cfoutput>
		<cfsavecontent variable="html">
			<script type="text/javascript">
				<!--
					$(document).ready(function() {

						<cfloop collection="#validation.forms#" item="local.form">

							var validator = ColdMVC.validation.getValidator('#local.form#');

							<cfloop array="#validation.forms[local.form]#" index="local.property">

								<cfloop array="#local.property.rules#" index="local.rule">

									validator.addRule({
										property: '#local.property.field#',
										rule: '#local.rule.name#',
										message: '#jsStringFormat(local.rule.message)#'
									});

								</cfloop>

							</cfloop>

						</cfloop>

					});
				//-->
			</script>
		</cfsavecontent>
		</cfoutput>

		<cfreturn html />

	</cffunction>

</cfcomponent>