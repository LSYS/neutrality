cap program drop beepme

program beepme
	args nbeeps
	if missing("`nbeeps'") {
		local nbeeps = 3
	}
	forval n = 1/`nbeeps' {
		beep
		sleep 1000
	}
end

// beepme 5
