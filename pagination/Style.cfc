/**
 * @accessors true
 */
component {

	/**
	 * @inject coldmvc
	 */
	property router;

	/**
	 * @inject coldmvc
	 */
	property coldmvc;

	private string function linkTo(required struct options) {

		return router.generate(params=arguments.options);

	}

	private string function generateLink(required struct params, required string queryString, required numeric page) {

		var pageParams = duplicate(params);
		pageParams.page = arguments.page;

		var link = linkTo(pageParams);

		return coldmvc.url.appendQueryString(link, arguments.queryString);

	}

}