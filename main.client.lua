--// Load Services
local cloneref = (cloneref or clonereference or function(i) return i end)
local ReplicatedStorage = cloneref(game:GetService("ReplicatedStorage"))
local RunService = cloneref(game:GetService("RunService"))

--// Load WindUI
local WindUI
do
    local ok, result = pcall(function()
        return require("./src/Init")
    end)

    if ok then
        WindUI = result
    else
        if RunService:IsStudio() then
            WindUI = require(ReplicatedStorage:WaitForChild("WindUI"):WaitForChild("Init"))
        else
            WindUI = loadstring(game:HttpGet(
                "https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"
            ))()
        end
    end
end

---------------------------------------------------------------------
-- WINDOW
---------------------------------------------------------------------

local Window = WindUI:CreateWindow({
    Title = "Sell Hub",
    Icon = "solar:tag-price-bold",
    Folder = "SellHub",
    NewElements = true,
    HideSearchBar = false,
})

---------------------------------------------------------------------
-- SELL TAB (ONLY TAB)
---------------------------------------------------------------------

local TabSell = Window:Tab({
    Title = "Sell",
    Icon = "solar:cart-large-2-bold",
})

local SellSection = TabSell:Section({
    Title = "Auto Selling",
})

---------------------------------------------------------------------
-- VARIABLES
---------------------------------------------------------------------

local AutoSell = false
local AutoSellDelay = 5
local AutoSellThread

---------------------------------------------------------------------
-- SELL FUNCTION
---------------------------------------------------------------------

local function SellAll()
    local args = { "SellAll" }

    ReplicatedStorage
        :WaitForChild("RemoteEvents")
        :WaitForChild("SellItems")
        :InvokeServer(unpack(args))
end

---------------------------------------------------------------------
-- BUTTON : SELL ALL
---------------------------------------------------------------------

SellSection:Button({
    Title = "Sell All",
    Justify = "Center",
    Icon = "solar:cart-large-2-bold",
    Callback = function()
        pcall(SellAll)

        WindUI:Notify({
            Title = "Sell",
            Content = "SellAll invoked"
        })
    end
})

SellSection:Space()

---------------------------------------------------------------------
-- TOGGLE : AUTO SELL
---------------------------------------------------------------------

SellSection:Toggle({
    Title = "Auto Sell",
    Value = false,
    Callback = function(state)
        AutoSell = state

        if AutoSell then
            if AutoSellThread then return end

            AutoSellThread = task.spawn(function()
                while AutoSell do
                    pcall(SellAll)
                    task.wait(AutoSellDelay)
                end
                AutoSellThread = nil
            end)
        end
    end
})

---------------------------------------------------------------------
-- SLIDER : DELAY
---------------------------------------------------------------------

SellSection:Slider({
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

---------------------------------------------------------------------
-- GEARS TAB
---------------------------------------------------------------------

local TabGears = Window:Tab({
    Title = "Gears",
    Icon = "solar:settings-bold",
})

local GearSection = TabGears:Section({
    Title = "Gear Shop",
})

-- load GearDefinitions module
local GearModule = require(
    ReplicatedStorage:WaitForChild("Definitions"):WaitForChild("GearDefinitions")
)

local GearList = GearModule.Gears

---------------------------------------------------------------------
-- SETTINGS
---------------------------------------------------------------------

local AutoBuyStates = {}
local BuyAmounts = {}

-- ⚠️ change this remote if your game uses another one
local BuyRemote = ReplicatedStorage
    :WaitForChild("RemoteEvents")
    :WaitForChild("BuyGear")

local function BuyGear(gearName, amount)
    for i = 1, amount do
        BuyRemote:InvokeServer(gearName)
        task.wait(0.1)
    end
end

---------------------------------------------------------------------
-- CREATE UI FOR EACH GEAR AUTOMATICALLY
---------------------------------------------------------------------

for gearName, data in pairs(GearList) do

    AutoBuyStates[gearName] = false
    BuyAmounts[gearName] = 1

    local GearBox = GearSection:Section({
        Title = gearName .. " (" .. data.Rarity .. ")",
        Box = true,
        Opened = false,
    })

    -----------------------------------------------------------------
    -- Amount Slider
    -----------------------------------------------------------------

    GearBox:Slider({
        Title = "Amount",
        Step = 1,
        Value = {
            Min = 1,
            Max = 50,
            Default = 1,
        },
        Callback = function(value)
            BuyAmounts[gearName] = value
        end
    })

    GearBox:Space()

    -----------------------------------------------------------------
    -- Single Buy Button
    -----------------------------------------------------------------

    GearBox:Button({
        Title = "Buy Once",
        Icon = "solar:cart-large-2-bold",
        Justify = "Center",
        Callback = function()
            BuyGear(gearName, BuyAmounts[gearName])
        end
    })

    GearBox:Space()

    -----------------------------------------------------------------
    -- Auto Buy Toggle
    -----------------------------------------------------------------

    GearBox:Toggle({
        Title = "Auto Buy",
        Value = false,
        Callback = function(state)
            AutoBuyStates[gearName] = state

            if state then
                task.spawn(function()
                    while AutoBuyStates[gearName] do
                        BuyGear(gearName, BuyAmounts[gearName])
                        task.wait(1)
                    end
                end)
            end
        end
    })

end
