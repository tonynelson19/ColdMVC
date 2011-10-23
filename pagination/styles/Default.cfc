<cfcomponent extends="coldmvc.pagination.Style" output="false">

	<cffunction name="init" access="public" output="false" returntype="any">

		<cfreturn this />

	</cffunction>

	<cffunction name="render" access="public" output="false" returntype="string">
		<cfargument name="end" required="true" type="numeric" />
		<cfargument name="page" required="true" type="numeric" />
		<cfargument name="pageCount" required="true" type="numeric" />
		<cfargument name="params" required="true" type="struct" />
		<cfargument name="recordCount" required="true" type="numeric" />
		<cfargument name="start" required="true" type="numeric" />
		<cfargument name="options" required="true" type="struct" />

		<cfset var result = "" />
		<cfset var i = "" />
		<cfset var pageParams = {} />

		<cfset var range = arguments.options.page.range />

		<cfif range gt arguments.pageCount>
			<cfset range = arguments.pageCount />
		</cfif>

		<cfset var delta = ceiling(range / 2) />

		<cfif arguments.page - delta gt arguments.pageCount - range>

            <cfset var lowerBound = arguments.pageCount - range + 1 />
            <cfset var upperBound = arguments.pageCount />

	   	<cfelse>

            <cfif arguments.page - delta lt 0>
                <cfset delta = arguments.page />
            </cfif>

            <cfset var offset     = arguments.page - delta />
            <cfset var lowerBound = offset + 1 />
            <cfset var upperBound = offset + range />

		</cfif>

		<cfoutput>
		<cfsavecontent variable="result">
			<#arguments.options.wrapper.tag# class="#arguments.options.wrapper.class#">
				<cfif arguments.options.records.display>
					<div class="#arguments.options.records.class#">
						#arguments.options.records.text# #numberFormat(arguments.start)#-#numberFormat(arguments.end)# of #numberFormat(arguments.recordCount)#
					</div>
				</cfif>
				<ul>
					<cfif arguments.options.first.display>
						<cfif arguments.page eq 1>
							<li class="#arguments.options.first.class# disabled">#arguments.options.first.text#</li>
						<cfelse>
							<li class="#arguments.options.first.class#"><a href="#generateLink(arguments.params, 1)#">#arguments.options.first.text#</a></li>
						</cfif>
					</cfif>
					<cfif arguments.options.previous.display>
						<cfif arguments.page eq 1>
							<li class="#arguments.options.previous.class# disabled">#arguments.options.previous.text#</li>
						<cfelse>
							<li class="#arguments.options.previous.class#"><a href="#generateLink(arguments.params, arguments.page - 1)#">#arguments.options.previous.text#</a></li>
						</cfif>
					</cfif>
					<cfloop from="#lowerBound#" to="#upperBound#" index="i">
						<cfset link = generateLink(arguments.params, i) />
						<li><a href="#link#" <cfif arguments.page eq i> class="active"</cfif>>#i#</a></li>
					</cfloop>
					<cfif arguments.options.next.display>
						<cfif arguments.page eq arguments.pageCount>
							<li class="#arguments.options.next.class# disabled">#arguments.options.next.text#</li>
						<cfelse>
							<li class="#arguments.options.next.class#"><a href="#generateLink(arguments.params, arguments.page + 1)#">#arguments.options.next.text#</a></li>
						</cfif>
					</cfif>
					<cfif arguments.options.last.display>
						<cfif arguments.page eq arguments.pageCount>
							<li class="#arguments.options.last.class# disabled">#arguments.options.last.text#</li>
						<cfelse>
							<li class="#arguments.options.last.class#"><a href="#generateLink(arguments.params, arguments.pageCount)#">#arguments.options.last.text#</a></li>
						</cfif>
					</cfif>
				</ul>
			</#arguments.options.wrapper.tag#>
		</cfsavecontent>
		</cfoutput>

		<cfreturn result />

	</cffunction>

</cfcomponent>