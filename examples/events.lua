print(event)

function render(tick)
	-- print(event.key("space").state, event.key("space").interval)
	print(event.pointer("0").state, event.pointer("0").count, event.pointer("0").interval)
end
