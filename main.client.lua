--// Sell Tab
local TabSell = Window:Tab({
    Title = "Sell",
    Icon = "solar:tag-price-bold",
})

TabSell:Section({
    Title = "Selling",
    Desc = "Manual and automatic selling",
})

local SellGroup = TabSell:Group()

--// variables
local AutoSell = false
local AutoSellDelay = 5
local SellingThread

--// function to invoke sell
local function SellAll()
    local args = {"SellAll"}
    game:GetService("ReplicatedStorage")
        :WaitForChild("RemoteEvents")
        :WaitForChild("SellItems")
        :InvokeServer(unpack(args))
end

--// Manual Sell Button
SellGroup:Button({
    Title = "Sell All",
    Justify = "Center",
    Icon = "solar:cart-large-2-bold",
    IconAlign = "Left",
    Size = "Small",
    Callback = function()
        SellAll()
        WindUI:Notify({
            Title = "Sell",
            Content = "SellAll invoked"
        })
    end,
})

SellGroup:Space({Columns = 1})

--// Auto Sell Toggle
SellGroup:Toggle({
    Title = "Auto Sell",
    Value = false,
    Callback = function(state)
        AutoSell = state

        if AutoSell then
            SellingThread = task.spawn(function()
                while AutoSell do
                    SellAll()
                    task.wait(AutoSellDelay)
                end
            end)
        end
    end,
})

--// Auto Sell Delay Slider
SellGroup:Slider({
    Title = "Auto Sell Delay",
    Step = 1,
    Value = {
        Min = 1,
        Max = 60,
        Default = 5,
    },
    Callback = function(value)
        AutoSellDelay = value
    end
})
