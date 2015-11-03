#= require Charts/canvasjs
#= require Charts/excanvas
#= require Charts/jquery.canvasjs
#= require_tree .

$(document).on "page:change", ->
	get_curr_url = "/#{@location.pathname.split("/")[1]}/#{@location.pathname.split("/")[2]}"
	$.each $('.reports-list-group').find('a'), ->
		if get_curr_url == $(this).attr("href")
			$(this).addClass 'active-list'
			false