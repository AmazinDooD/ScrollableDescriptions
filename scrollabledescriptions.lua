local scr = SMODS.current_mod

local ahp = Card.align_h_popup
function Card:align_h_popup()
    local ret = ahp(self)
    if not self.scr then self.scr = {x=0,y=0} end
    ret.offset.x = ret.offset.x + self.scr.x
    ret.offset.y = ret.offset.y + self.scr.y
    return ret
end

---Move a card's hover popup by the amount given in dir. dir should be a table with an x key and a y key.
---@param card Card
---@param dir table
function move_popup(card, dir)
    if not card or not dir then return end
    if not card.scr then card.scr = card.config.h_popup_config.offset and card.config.h_popup_config.offset or {x=0,y=0} end
    card.scr.x = card.scr.x + dir.x
    card.scr.y = card.scr.y + dir.y
end

function G.FUNCS.scr_switch_move_distance(arg)
    scr.config.move_distance = arg.to_key
    SMODS.save_mod_config(scr)
end

function scr.config_tab()
    local config_nodes =
    {n=G.UIT.ROOT, config = {align = "cm", colour = G.C.L_BLACK, minw = 4, minh = 4}, nodes = {
        {n = G.UIT.C, config = {align = "cm"}, nodes = {}}
    }}
    config_nodes.nodes[1].nodes[1] = create_option_cycle{
        label = "Move Distance",
        w = 6.3,
        scale = 0.9,
        options = {
            "0.1",
            "0.2",
            "0.3",
            "0.4",
            "0.5",
            "0.6",
            "0.7",
            "0.8",
            "0.9",
            "1.0"
        },
        opt_callback = "scr_switch_move_distance",
        current_option = scr.config.move_distance
    }
    return config_nodes
end

SMODS.Keybind {
    key_pressed = "up",
    event = "pressed",
    action = function(self) 
        local hovered = G and G.CONTROLLER and (G.CONTROLLER.focused.target or G.CONTROLLER.hovering.target)
        if hovered then move_popup(hovered, {x=0,y=0 - scr.config.move_distance / 10}) end
    end
}

SMODS.Keybind {
    key_pressed = "down",
    event = "pressed",
    action = function(self) 
        local hovered = G and G.CONTROLLER and (G.CONTROLLER.focused.target or G.CONTROLLER.hovering.target)
        if hovered then move_popup(hovered, {x=0,y=scr.config.move_distance / 10}) end
    end
}

SMODS.Keybind {
    key_pressed = "left",
    event = "pressed",
    action = function(self) 
        local hovered = G and G.CONTROLLER and (G.CONTROLLER.focused.target or G.CONTROLLER.hovering.target)
        if hovered then move_popup(hovered, {x=0 - scr.config.move_distance / 10,y=0}) end
    end
}

SMODS.Keybind {
    key_pressed = "right",
    event = "pressed",
    action = function(self) 
        local hovered = G and G.CONTROLLER and (G.CONTROLLER.focused.target or G.CONTROLLER.hovering.target)
        if hovered then move_popup(hovered, {x=scr.config.move_distance / 10,y=0}) end
    end
}

SMODS.Keybind {
    key_pressed = "home",
    action = function(self)
        local hovered = G and G.CONTROLLER and (G.CONTROLLER.focused.target or G.CONTROLLER.hovering.target)
        if hovered then hovered.scr = {x=0,y=0} end
    end
}

SMODS.Atlas {
    key = "modicon",
    path = "modicon.png",
    px = 34,
    py = 34

}
