--// Sell Tab
local TabSell = Window:Tab({
    Title = "Sell",
    Icon = "solar:tag-price-bold",
})

TabSell:Section({
    Title = "Sell Items",
    Desc = "Quick sell actions",
})

local SellGroup = TabSell:Group()

SellGroup:Button({
    Title = "Sell All",
    Justify = "Center",
    Icon = "solar:cart-large-2-bold",
    IconAlign = "Left",
    Size = "Small",
    Callback = function()
        local args = {
            "SellAll"
        }

        game:GetService("ReplicatedStorage")
            :WaitForChild("RemoteEvents")
            :WaitForChild("SellItems")
            :InvokeServer(unpack(args))

        WindUI:Notify({
            Title = "Sell",
            Content = "SellAll invoked"
        })
    end,
})
