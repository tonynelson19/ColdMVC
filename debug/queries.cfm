<cfsilent>
<cfset debugManager = coldmvc.framework.getBean("debugManager") />
<cfset queries = debugManager.getQueries() />
</cfsilent>

<cfoutput>
<h2>Queries</h2>
<div class="coldmvc_debug_section">
	<cfif arrayLen(queries) gt 0>
		<ul>
			<cfloop array="#queries#" index="query">
				<li class="coldmvc_debug_query">
					#debugManager.formatQuery(query.query)#
					<cfif not structIsEmpty(query.parameters)>
						<h4>Parameters</h4>
						<ul>
							<cfloop list="#listSort(structKeyList(query.parameters), 'textnocase')#" index="parameter">
								<cfset value = query.parameters[parameter] />
								<li><span>#parameter#:</span> <cfif isSimpleValue(value)>#value#<cfelse>#serializeJSON(value)#</cfif></li>
							</cfloop>
						</ul>
					</cfif>
					<h4>Options</h4>
					<ul>
						<cfif structKeyExists(query.options, "max") and query.options.max neq "">
							<li><span>max:</span> #query.options.max#</li>
						</cfif>
						<cfif structKeyExists(query.options, "offset") and query.options.offset neq "">
							<li><span>offset:</span> #query.options.offset#</li>
						</cfif>
						<li><span>unique:</span> #query.unique#</li>
					</ul>
					<h4>Results</h4>
					<ul>
						<li><span>time:</span> #query.time# ms</li>
						<li><span>records:</span> #query.count#</li>
					</ul>
				</li>
			</cfloop>
		</ul>
	<cfelse>
		<table>
			<tbody>
				<tr>
					<td class="coldmvc_label">None</td>
					<td class="coldmvc_field">&nbsp;</td>
				</tr>
			</tbody>
		</table>
	</cfif>
</div>
</cfoutput>