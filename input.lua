input = {
    newButton = function(name, icon)
        button = {}

        button.now = false  --Is the button presently held
        button.last = false --Was the button being held last frame

        button.name = name --Name of the button to use if it is referenced in plaintext
        button.icon = icon --Image of the button to use if it is rendered in the gui

        return button
    end
}

input.update = function()
    for _,button in pairs(input) do
        button.last = button.now
        button.now = false --TODO
    end
end,

return input