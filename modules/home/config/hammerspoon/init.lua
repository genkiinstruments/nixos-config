local hyper = { "cmd", "alt", "ctrl", "shift" }

-- Window management
hs.window.animationDuration = 0

-- Select west (left) window
hs.hotkey.bind(hyper, "[", function()
	local win = hs.window.focusedWindow()
	if win then
		win:focusWindowWest()
	end
end)

-- Select east (right) window
hs.hotkey.bind(hyper, "]", function()
	local win = hs.window.focusedWindow()
	if win then
		win:focusWindowEast()
	end
end)

