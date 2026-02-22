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
