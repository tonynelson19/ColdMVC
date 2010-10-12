This app demonstrates how you can secure resources using the ColdSecurity plugin

<cfoutput>
<br /><br />
<a href="#linkTo({action='guest'})#">Login as a Guest</a>
<br />
Guests can only see the "Home" tab
<br />
<br />
<a href="#linkTo({action='basic'})#">Login as a Basic User</a>
<br />
Basic users have read-only access to the application
<br />
<br />
<a href="#linkTo({action='admin'})#">Login as a Super Admin</a>
<br />
Admin users have edit access to everything
</cfoutput>