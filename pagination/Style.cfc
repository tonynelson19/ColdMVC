/**
 * @accessors true
 */
component {

	/**
	 * @inject coldmvc
	 */
	property router;

	private string function linkTo(required struct options) {

		return router.generate(params=arguments.options);

	}

	private string function generateLink(required struct params, required numeric page) {

		var pageParams = duplicate(params);
		pageParams.page = arguments.page;

		return linkTo(pageParams);

	}

}