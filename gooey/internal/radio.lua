local core = require "gooey.internal.core"

local M = {}

local radiobuttons = {}

local groups = {}



local RADIOBUTTON = {
	set_selected = function(radio, selected)
		radio.selected = selected
		if radio.refresh_fn then radio.refresh_fn(radio) end
	end,
	refresh = function(radio)
		if radio.refresh_fn then radio.refresh_fn(radio) end
	end,
	set_visible = function(radio, visible)
		gui.set_enabled(radio.node, visible)
	end,
}


function M.button(node_id, group_id, action_id, action, fn, refresh_fn)
	node_id = core.to_hash(node_id)
	group_id = core.to_hash(group_id)
	local node = gui.get_node(node_id)
	assert(node)

	local radio = core.instance(node_id, radiobuttons, RADIOBUTTON)
	radio.enabled = core.is_enabled(node)
	radio.node = node
	radio.group = group_id and core.to_key(group_id)
	radio.refresh_fn = refresh_fn

	if not action then
		radio.refresh()
		return radio
	end
	
	core.clickable(radio, action_id, action)
	if radio.clicked then
		radio.selected = true
		fn(radio)
	end

	radio.refresh()
	return radio
end


function M.group(group_id, action_id, action, fn)
	local group_id = core.to_hash(group_id)

	fn(group_id, action_id, action)

	-- get the group and empty it
	local group = core.instance(group_id, groups)
	for k,_ in pairs(group) do
		group[k] = nil
	end

	local selected_radio
	local group_key = core.to_key(group_id)
	for _,radio in pairs(radiobuttons) do
		radio = radio.data
		if radio.group == group_key then
			if radio.released_now and radio.selected then
				selected_radio = radio
			end
			table.insert(group, radio)
		end
	end

	if selected_radio then
		-- deselect others
		for _,radio in ipairs(group) do
			if radio ~= selected_radio then
				radio.selected = false
				radio.refresh()
			end
		end
	end
	return group
end



setmetatable(M, {
	__call = function(_, ...)
		return M.button(...)
	end
})

return M