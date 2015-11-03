currentActiveLink = (elem) ->
	elem.find("a[href=\"#{@location.pathname}\"]").parent().addClass "active"

$(document).on "page:change", ->
	currentActiveLink($(".navbar-nav"))
	
	# Rails Best in place
	jQuery(".best_in_place").best_in_place()

	jQuery(".best_in_place").unbind().on "ajax:error", ->
  	$('.purr').prepend("<span class='glyphicon glyphicon-exclamation-sign'></span> ")

	$('[data-toggle="tooltip"]').tooltip()