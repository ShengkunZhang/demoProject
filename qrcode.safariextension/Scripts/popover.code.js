+(function () {
	/**
	 * Update the QR code image in the page.
	 */
	function updateCode(data, url) {
		var image = document.querySelector('.image > img');
		image.setAttribute('src', data);
		image.setAttribute('alt', url);
	}
	window.updateCode = updateCode;
})();
