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
        card.x = card.x + input.cursor.dx
        card.y = card.y + input.cursor.dy
    end,
}

return gui