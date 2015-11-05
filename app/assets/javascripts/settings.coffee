currentActiveLink = (elem) ->
	elem.find("a[href=\"#{@location.pathname}\"]").parent().addClass "active"

$(document).on 'page:change', ->
  currentActiveLink $('.navbar-nav')
  $('.best_in_place').best_in_place()
  $('.best_in_place').bind().on 'ajax:error', ->
    $('.purr').prepend '<span class=\'glyphicon glyphicon-exclamation-sign\'></span> '
    return
  $('[data-toggle="tooltip"]').tooltip()
  return