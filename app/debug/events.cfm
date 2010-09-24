<cfsilent>
<cfset events = coldmvc.factory.get("debugManager").getEvents() />
</cfsilent>

<cfoutput>
<h2>Events</h2>
<div class="coldmvc_debug_section">
	<table>
		<tbody>
			<cfloop array="#events#" index="event">
				<tr>
					<td class="coldmvc_label">#event.event#:</td>
					<td class="coldmvc_field">
						<cfif arrayLen(event.listeners) gt 0>
							<ul>
								<cfloop array="#event.listeners#" index="listener">
									<li>#listener.string#()</li>
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