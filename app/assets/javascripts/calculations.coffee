class window.Calculations
	nonHourlyAmount: (rates, billing, no_of_days, total_days, unpaid_leaves) ->
		term_1 = (parseFloat(rates) * parseFloat(billing) / 100) * (parseInt(no_of_days) / total_days)
		term_2 = ((parseFloat(unpaid_leaves) * parseFloat(rates) * parseFloat(billing)) / 100) / total_days
		console.log term_1
		console.log term_2
		recalculateAmount = term_1 - term_2
		recalculateAmount

	hourlyAmount: (rates, hours) ->
		recalculateAmount = parseFloat(hours) * parseFloat(rates)
		recalculateAmount

	nonHourlyRates: (amount, total_days, no_of_days, billing) ->
		term_1 = amount * total_days * 100
		term_2 = parseInt(no_of_days) * parseFloat(billing)
		recalculateRates = term_1 / term_2
		recalculateRates

	hourlyRates: (amount, hours) ->
		recalculateRates = amount * parseFloat(hours)
		recalculateRates
