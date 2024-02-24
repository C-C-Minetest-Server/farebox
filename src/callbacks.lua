-- farebox/src/callbacks.lua
-- Regoster Minetest Engine callbacks
--[[
    ISC License

    Copyright (c) 2017 Gabriel Pérez-Cerezo
    Copyright (c) 2024 1F616EMO

    Permission to use, copy, modify, and/or distribute this software for any
    purpose with or without fee is hereby granted, provided that the above
    copyright notice and this permission notice appear in all copies.

    THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES WITH
    REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF MERCHANTABILITY
    AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY SPECIAL, DIRECT,
    INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING FROM
    LOSS OF USE, DATA OR PROFITS, WHETHER IN AN ACTION OF CONTRACT, NEGLIGENCE
    OR OTHER TORTIOUS ACTION, ARISING OUT OF OR IN CONNECTION WITH THE USE OR
    PERFORMANCE OF THIS SOFTWARE.
]]

local S = minetest.get_translator("farebox")
local POSS = minetest.pos_to_string

minetest.register_on_player_receive_fields(function(player, formname, pressed)
    if string.sub(formname, 1, 16) ~= "farebox:farebox_" then
        return -- Not My Job
    end

    local pos = minetest.string_to_pos(string.sub(formname, 17))
    local nodename = minetest.get_node(pos).name
    if minetest.get_item_group(nodename, "farebox") == 0 then return end

    -- Anticheat: avoid interacting with node too far away
    -- 10 is already more than enough (creative hand reaches about 6.2 nodes)
    local ppos = player:get_pos()
    if math.hypot(math.abs(pos.x - ppos.x), math.abs(pos.y - ppos.y)) > 10 then
        return
    end

    local pname = player:get_player_name()
    local pinv = player:get_inventory()

    local meta = minetest.get_meta(pos)
    local inv = meta:get_inventory()
    local owner = meta:get_string("owner")
    local open = false

    if pressed.buy then
        local request = inv:get_stack("request", 1)
        if pinv:contains_item("main", request) then
            if inv:room_for_item("main", request) then
                if not (creative and creative.is_enabled_for(pname)) then
                    pinv:remove_item("main", request)
                end
                inv:add_item("main", request)
                open = true
                minetest.chat_send_player(pname, S("Payment accepted."))
                minetest.log("action", "[farebox] " .. pname .. " paid at " .. POSS(pos, 0))
            else
                minetest.chat_send_player(pname, S("Owner's inventory is full."))
            end
        else
            minetest.chat_send_player(pname, S("You don't have enough items to complete the payment."))
        end
    end

    if pressed.open and pname == owner then
        minetest.log("action", "[farebox] " .. pname .. " opened the farebox at " .. POSS(pos, 0))
        open = true
    end

    if open then
        local def = minetest.registered_nodes[nodename]
        def._farebox_open(pos)
    end

    -- TODO: use item_image_button_exit once avaliable
    minetest.close_formspec(pname, formname)
end)
