-- farebox/src/farebox.lua
-- Farebox node
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

minetest.register_node("farebox:farebox", {
    description = S("Farebox"),
    tiles = {
        "default_steel_block.png", "default_steel_block.png",
        "default_steel_block.png", "default_steel_block.png",
        "default_steel_block.png", "farebox_front.png"
    },
    paramtype2 = "facedir",
    groups = { cracky = 2, farebox = 1 },
    legacy_facedir_simple = true,
    is_ground_content = false,
    sounds = default.node_sound_stone_defaults(),
    mesecons = {
        receptor = {
            state = mesecon.state.off,
            rules = farebox.mesecon_rules
        }
    },
    can_dig = farebox.can_dig,
    after_place_node = function(pos, player, _)
        local meta = minetest.get_meta(pos)
        local player_name = player:get_player_name()

        meta:set_string("owner", player_name)
        meta:set_string("infotext", S("@1 (Owned by @2)",
            S("Farebox"), player_name
        ))

        local inv = meta:get_inventory()
        inv:set_size("request", 1)
        inv:set_size("main", 32)
    end,
    allow_metadata_inventory_put = farebox.allow_metadata_inventory_take_put,
    allow_metadata_inventory_take = farebox.allow_metadata_inventory_take_put,
    allow_metadata_inventory_move = farebox.allow_metadata_inventory_move,
    on_rightclick = function(pos, node, player, itemstack, pointed_thing)
        farebox.show_formspec(pos, player)
    end,

    _farebox_open = function(pos)
        mesecon.receptor_on(pos, farebox.mesecon_rules)

        local timer = minetest.get_node_timer(pos)
        timer:start(1)
    end,
    on_timer = function(pos)
        mesecon.receptor_off(pos, farebox.mesecon_rules)
    end,
})
