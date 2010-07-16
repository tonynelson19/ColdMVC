<cfif thisTag.executionMode eq "start">

<cfparam name="attributes.lang" default="en-US" />
<cfparam name="attributes.xmllang" default="en-US" />
<cfparam name="attributes.xmlns" default="http://www.w3.org/1999/xhtml" />

<cfoutput>
<html lang="#attributes.lang#" xml:lang="#attributes.xmllang#" xmlns="#attributes.xmlns#">
</cfoutput>

<cfelse>
</html>
</cfif>