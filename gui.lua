local input = require "input"

gui = {

    grabbed = false,

    update = function()
        if input.obj.press(testCard) then
            gui.grabbed = true
        elseif input.cursor.release then
            gui.grabbed = false
        end

        if gui.grabbed then
            gui.slideCard(testCard)
        end
    end,

    slideCard = function(card)
        card.tx = card.tx + input.cursor.dx
        card.x = math.min(math.max(card.tx,0), cfg.bs.w - 32)
        card.ty = card.ty + input.cursor.dy
        card.y = math.min(math.max(card.ty,0), cfg.bs.h - 48)
    end,
}

return gui