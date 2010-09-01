<cfsilent>
	<cfset title = "LitePost - Login" />
	<cfparam name="message" default="" />
</cfsilent>

<cfoutput>
	<h1>Please Log In</h1>

	<cfif len(message)>
		<p style="color:red;font-weight:bold;" align="center">#message#</p>
	</cfif>

	<form action="#linkTo({action='doLogin'})#" method="post">
	  	<label>Username<br />
	  	<input name="userName" type="text" maxlength="30" />
		</label>
		<label>Password<br />
		<input name="password" type="password" maxlength="30" />
		</label>
		<input type="submit" name="submit" value="Log In" class="adminbutton" />
	</form>
</cfoutput>