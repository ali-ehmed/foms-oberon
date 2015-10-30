currentActiveLink = (elem) ->
	elem.find("a[href=\"#{@location.pathname}\"]").parent().addClass "active"

$(document).on "page:change", ->
	currentActiveLink($(".navbar-nav"))