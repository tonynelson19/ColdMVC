<cfsilent>
<cfset events = coldmvc.framework.getBean("debugManager").getEvents() />

<cfset items = [] />

<cfloop array="#events#" index="event">
	
	<cfset item = {} />
	<cfset item.name = event.event />
	<cfset item.listeners = [] />
	
	<cfloop array="#event.listeners#" index="listener">
		<cfif isSimpleValue(listener.bean)>
			<cfset arrayAppend(item.listeners, "#listener.bean#.#listener.method#()") />	
		</cfif>									
	</cfloop>
	
	<cfset arrayAppend(items, item) />
	
</cfloop>
</cfsilent>

<cfoutput>
<h2>Events</h2>
<div class="coldmvc_debug_section">
	<table>
		<tbody>
			<cfloop array="#items#" index="item">
				<tr>
					<td class="coldmvc_label">#item.name#:</td>
					<td class="coldmvc_field">
						<cfif arrayLen(item.listeners) gt 0>
							<ul>
								<cfloop array="#item.listeners#" index="listener">
									<li>#listener#</li>							
								</cfloop>
							</ul>
						<cfelse>
							None
						</cfif>
					</td>
				</tr>
			</cfloop>
		</tbody>
	</table>
</div>
</cfoutput>