# window.onload = ->
#   chart = new (CanvasJS.Chart)('chartContainer',
#     title: text: 'Top Categoires of New Year\'s Resolution'
#     exportFileName: 'Pie Chart'
#     exportEnabled: true
#     animationEnabled: true
#     legend:
#       verticalAlign: 'bottom'
#       horizontalAlign: 'center'
#     data: [ {
#       type: 'pie'
#       showInLegend: true
#       toolTipContent: '{legendText}: <strong>{y}%</strong>'
#       indexLabel: '{label} {y}%'
#       dataPoints: [
#         {
#           y: 35
#           legendText: 'Health'
#           exploded: true
#           label: 'Health'
#         }
#         {
#           y: 20
#           legendText: 'Finance'
#           label: 'Finance'
#         }
#         {
#           y: 18
#           legendText: 'Career'
#           label: 'Career'
#         }
#         {
#           y: 15
#           legendText: 'Education'
#           label: 'Education'
#         }
#         {
#           y: 5
#           legendText: 'Family'
#           label: 'Family'
#         }
#         {
#           y: 7
#           legendText: 'Real Estate'
#           label: 'Real Estate'
#         }
#       ]
#     } ])
#   chart.render()
#   return

$(document).on "page:change", ->
  $('#report_month').datepicker(
	  format: 'm - yyyy'
	  orientation: 'bottom left'
	  minViewMode: 1
	).on 'changeDate', (e) ->
	  $(this).datepicker 'hide'

