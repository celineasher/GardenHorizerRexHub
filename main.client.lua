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
-- GEARS TAB (TOOL SCANNER VERSION)
---------------------------------------------------------------------

local TabGears = Window:Tab({
    Title = "Gears",
    Icon = "solar:settings-bold",
})

local GearSection = TabGears:Section({
    Title = "Gear Shop",
})

local ToolsFolder = ReplicatedStorage
    :WaitForChild("Gears")
    :WaitForChild("Tools")

local PurchaseRemote = ReplicatedStorage
    :WaitForChild("RemoteEvents")
    :WaitForChild("PurchaseShopItem")

---------------------------------------------------------------------
-- SETTINGS
---------------------------------------------------------------------

local AutoBuy = {}
local BuyAmount = {}

local function BuyGear(toolName, amount)
    for i = 1, amount do
        PurchaseRemote:InvokeServer("GearShop", toolName)
        task.wait(0.15)
    end
end

---------------------------------------------------------------------
-- CREATE UI FROM TOOL NAMES
---------------------------------------------------------------------

for _, category in pairs(ToolsFolder:GetChildren()) do
    for _, tool in pairs(category:GetChildren()) do
        
        local toolName = tool.Name
        AutoBuy[toolName] = false
        BuyAmount[toolName] = 1

        local GearBox = GearSection:Section({
            Title = toolName,
            Box = true,
            Opened = false,
        })

        -----------------------------------------------------------------
        -- AMOUNT
        -----------------------------------------------------------------

        GearBox:Slider({
            Title = "Amount",
            Step = 1,
            Value = {
                Min = 1,
                Max = 50,
                Default = 1,
            },
            Callback = function(v)
                BuyAmount[toolName] = v
            end
        })

        GearBox:Space()

        -----------------------------------------------------------------
        -- BUY ONCE
        -----------------------------------------------------------------

        GearBox:Button({
            Title = "Buy",
            Justify = "Center",
            Callback = function()
                BuyGear(toolName, BuyAmount[toolName])
            end
        })

        GearBox:Space()

        -----------------------------------------------------------------
        -- AUTO BUY
        -----------------------------------------------------------------

        GearBox:Toggle({
            Title = "Auto Buy",
            Callback = function(state)
                AutoBuy[toolName] = state

                if state then
                    task.spawn(function()
                        while AutoBuy[toolName] do
                            BuyGear(toolName, BuyAmount[toolName])
                            task.wait(1)
                        end
                    end)
                end
            end
        })

    end
end

---------------------------------------------------------------------
-- PLANTS TAB (CLEAN LAYOUT)
---------------------------------------------------------------------

local TabPlants = Window:Tab({
    Title = "Plants",
    Icon = "solar:leaf-bold",
})

local PlantSection = TabPlants:Section({
    Title = "Seed Shop",
})

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local PlantsFolder = ReplicatedStorage:WaitForChild("Plants"):WaitForChild("Models")
local PurchaseRemote = ReplicatedStorage.RemoteEvents:WaitForChild("PurchaseShopItem")
local PlantRemote = ReplicatedStorage.RemoteEvents:WaitForChild("PlantSeed")

---------------------------------------------------------------------
-- AUTO PLANTER (ONLY ONCE)
---------------------------------------------------------------------

local AutoPlant = false
local AutoPlantDelay = 1

local PlanterBox = PlantSection:Section({
    Title = "Auto Planter",
    Box = true,
    Opened = true,
})

local function GetHeldPlant()
    local char = LocalPlayer.Character
    if not char then return end
    local tool = char:FindFirstChildOfClass("Tool")
    if not tool then return end
    return tool.Name:gsub(" Seed","")
end

local function GetPlantPosition()
    local char = LocalPlayer.Character
    if not char then return end

    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    return Vector3.new(hrp.Position.X, 185.6, hrp.Position.Z)
end

local function PlantOnce()
    local plantName = GetHeldPlant()
    if not plantName then return end

    local pos = GetPlantPosition()
    if not pos then return end

    PlantRemote:InvokeServer(plantName, pos)
end

PlanterBox:Button({
    Title = "Plant Held Seed",
    Justify = "Center",
    Callback = function()
        pcall(PlantOnce)
    end
})

PlanterBox:Space()

PlanterBox:Toggle({
    Title = "Auto Planter",
    Callback = function(state)
        AutoPlant = state

        if AutoPlant then
            task.spawn(function()
                while AutoPlant do
                    pcall(PlantOnce)
                    task.wait(AutoPlantDelay)
                end
            end)
        end
    end
})

PlanterBox:Slider({
    Title = "Plant Delay",
    Step = 0.1,
    Value = {
        Min = 0.1,
        Max = 5,
        Default = 1,
    },
    Callback = function(v)
        AutoPlantDelay = v
    end
})

---------------------------------------------------------------------
-- PLANT BUY SECTIONS (LOOP)
---------------------------------------------------------------------

for _, plant in pairs(PlantsFolder:GetChildren()) do

    local plantName = plant.Name

    local PlantBox = PlantSection:Section({
        Title = plantName,
        Box = true,
        Opened = false,
    })

    local amount = 1
    local autoBuy = false

    PlantBox:Slider({
        Title = "Amount",
        Step = 1,
        Value = { Min = 1, Max = 50, Default = 1 },
        Callback = function(v)
            amount = v
        end
    })

    PlantBox:Button({
        Title = "Buy Seed",
        Justify = "Center",
        Callback = function()
            for i = 1, amount do
                PurchaseRemote:InvokeServer("SeedShop", plantName.." Seed")
                task.wait(0.15)
            end
        end
    })

    PlantBox:Toggle({
        Title = "Auto Buy",
        Callback = function(state)
            autoBuy = state
            if autoBuy then
                task.spawn(function()
                    while autoBuy do
                        PurchaseRemote:InvokeServer("SeedShop", plantName.." Seed")
                        task.wait(1)
                    end
                end)
            end
        end
    })

end
