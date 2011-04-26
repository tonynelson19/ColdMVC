/**
 * @extends coldmvc.Scope
 * @scope session
 */
component {

	public void function clearOldRequests() {

		var counter = getCounter()-2;
		var requests = getRequests();

		structDelete(requests, counter);

	}

	public void function incrementCounter() {

		var flashScope = super.getScope();
		flashScope.counter = getCounter()+1;

	}

	public numeric function getCounter() {

		var flashScope = super.getScope();

		if (!structKeyExists(flashScope, "counter")) {
			flashScope.counter = 0;
		}

		return flashScope.counter;

	}

	public struct function getCurrentRequest() {

		return getRequest(getCounter());

	}

	public struct function getPreviousRequest() {

		return getRequest(getCounter()-1);

	}

	private struct function getRequest(required numeric counter) {

		var requests = getRequests();

		if (!structKeyExists(requests, counter)) {
			requests[counter] = {};
		}

		return requests[counter];

	}

	private struct function getRequests() {

		var flashScope = super.getScope();

		if (!structKeyExists(flashScope, "requests")) {
			flashScope.requests = {};
		}

		return flashScope.requests;

	}

	private struct function getScope() {

		var counter = getCounter();
		var requests = getRequests();

		if (!structKeyExists(requests, counter)) {
			requests[counter] = {};
		}

		return requests[counter];

	}

	public void function setCurrentRequest(required struct data) {

		setRequest(getCounter(), data);

	}

	private void function setRequest(required numeric counter, required struct data) {

		var requests = getRequests();

		requests[counter] = data;

	}

}