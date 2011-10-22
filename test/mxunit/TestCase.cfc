/**
 * @extends mxunit.framework.TestCase
 */
component {

	private void function assertStructEquals(required struct expected, required any actual) {

		assertIsStruct(arguments.actual);
		assertEquals(structCount(arguments.expected), structCount(arguments.actual));

		var key = "";
		for (key in arguments.expected) {
			assertTrue(structKeyExists(arguments.actual, key), "Key '#lcase(key)#' does not exist.");
			assertEqualsCase(arguments.expected[key], arguments.actual[key], "Key '#lcase(key)#' does not match.");
		}

	}

	private void function assertStringContainsCountEquals(required numeric expected, required string substring, required string string) {

		var matches = findAll(arguments.substring, arguments.string);

		assertEquals(arguments.expected, arrayLen(matches));

	}

	/**
	 * http://www.cflib.org/udf/findAll
	 * Finds all occurrences of a substring in a string.
	 * Fix by RCamden to make start optional.
	 *
	 * @param substring String to search for. (Required)
	 * @param string String to parse. (Required)
	 * @param start Starting position. Defaults to 1. (Optional)
	 * @return Returns an array.
	 * @author Jeremy Rottman (rottmanj@hsmove.com)
	 * @version 2, July 29, 2008
	 */
	private array function findAll(required string substring, required string string, numeric start=1) {

		var result = [];
	    var current = find(arguments.substring, arguments.string, arguments.start);
	    var i = 1;

	    if (current > 0){

			result[i] = current;

			while (current > 0) {

				current = current + 1;

				var next = find(arguments.substring, arguments.string, current);

				if (next > 0) {
	                i = i + 1;
	                result[i] = next;
	                current = next;
	            } else {
	                current = 0;
	            }
	        }

	    }

	    return result;
	}

}