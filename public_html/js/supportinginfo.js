/* jshint strict: true */
/* global $ */
/* global Handlebars */
/* global console */
$( document ).ready( function () {
	"use strict";
	var templatePromise = $.ajax( {
		url: "templates/supporting.html"
	});

	var metadataPromise = $.ajax( {
		url: "data/metadata.json"
	});

	$.when(templatePromise, metadataPromise).done( function ( templateAjax, metadataAjax ) {
		var template = Handlebars.compile ( templateAjax[0] );
		var metadata = metadataAjax[0];
		
		var metadataIds = $.map ( metadata, function ( element, index ) {
			return index;
		} );
		$( '.supportinginfo' ).each ( function ( index, element ) {
			var context = {
				metadata: []
			};
			$.each ( metadataIds, function ( index, value ) {
				if ( $(element).hasClass(value) ) {
					context.metadata.push ( metadata[value] );
				}
			} );
			var html = template ( context );
			$(element).click ( function () {
				// Show popup
			} );
		} );
	});
} );
