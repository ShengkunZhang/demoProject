+(function () {
	/**
	 * Command handler that generates the QR code from the current tab's URL.
	 *
	 * @param event
	 */
	function updateCode(event) {
		if (event.target.identifier === 'de.retiolum.safari.qrify.popover.code') {
			var currentUrl = safari.application.activeBrowserWindow.activeTab.url;
			console.log(safari.extension.settings['de.retiolum.safari.qrify.settings.errorCorrection']);
			if (currentUrl) {
				var qr = new QRious({
					background: '#ebebec',
					foreground: '#000',
					level: safari.extension.settings['de.retiolum.safari.qrify.settings.errorCorrection'],
					size: 200,
					mime: 'image/png',
					value: currentUrl
				});
				safari.extension.popovers[0].contentWindow.updateCode(qr.toDataURL(), currentUrl);
			}
		}
	}

	/**
	 * Validation function that disables the toolbar item if the current tab does not have a URL.
	 *
	 * @param event
	 */
	function validateToolbarItem(event) {
		if (event.target.identifier === 'de.retiolum.safari.qrify.toolbarItem.create') {
			event.target.disabled = !safari.application.activeBrowserWindow.activeTab.url;
		}
	}

	// Register event handlers.
	safari.application.addEventListener('popover', updateCode, false);
	safari.application.addEventListener('validate', validateToolbarItem, false);
})();
