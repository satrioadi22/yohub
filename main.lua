-- [[ LOAD KAVO UI LIBRARY ]] --
local Kavo = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
local Window = Kavo.CreateLib("YoHub | Grow a Garden", "BloodTheme")

-- [[ VARIABLES & CONFIG ]] --
local _G = getgenv and getgenv() or _G
_G.AutoHopEnabled = false
_G.WaktuTunggu = 1200
_G.SisaWaktuDetik = 1200

_G.AutoStockEnabled = false
_G.FruitYangDijual = ""
_G.HargaJual = 100 -- Kita kasih harga bawaan 100 biar langsung jalan kalau belum diubah

local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local localPlayer = Players.LocalPlayer

shared.VisitedServers = shared.VisitedServers or {}
table.insert(shared.VisitedServers, game.JobId)

-- [[ UI TABS ]] --
local MainTab = Window:NewTab("Main Features")
local UIConfigTab = Window:NewTab("UI Settings")

local HopSection = MainTab:NewSection("Auto Hop Server")
local StockSection = MainTab:NewSection("Auto Stock Booth")
local ConfigSection = UIConfigTab:NewSection("Tampilan UI")

-- [[ LABELS MONITORING ]] --
local StatusLabel = HopSection:NewLabel("Status: Auto Hop Mati")
local TimerLabel = HopSection:NewLabel("Sisa Waktu: --:--")
local InfoStockLabel = StockSection:NewLabel("Target: Belum Pilih | Harga: 100")

-- [[ FUNCTION SCAN INVENTORY ]] --
local function getInventoryFruits()
    local fruits = {}
    local backpack = localPlayer:FindFirstChild("Backpack")
    if backpack then
        for _, item in ipairs(backpack:GetChildren()) do
            if not table.find(fruits, item.Name) then
                table.insert(fruits, item.Name)
            end
        end
    end
    local char = localPlayer.Character
    if char then
        for _, item in ipairs(char:GetChildren()) do
            if item:IsA("Tool") and not table.find(fruits, item.Name) then
                table.insert(fruits, item.Name)
            end
        end
    end
    if #fruits == 0 then
        table.insert(fruits, "Inventory Kosong / Pegang Buah Lu")
    end
    return fruits
end

-- [[ FUNCTION AUTO STOCK ]] --
local function doAutoStock()
    task.spawn(function()
        while _G.AutoStockEnabled do
            if _G.FruitYangDijual ~= "" and _G.FruitYangDijual ~= "Inventory Kosong / Pegang Buah Lu" then
                pcall(function()
                    -- Kirim data ke Remote asli game
                    ReplicatedStorage.GameEvents.UpdateStock:FireServer(_G.FruitYangDijual, _G.HargaJual, 1, 1)
                    ReplicatedStorage.GameEvents.UpdateStock:FireServer(_G.FruitYangDijual, _G.HargaJual)
                end)
            end
            task.wait(5)
        end
    end)
end

-- [[ FUNCTION AUTO HOP ]] --
local function doAutoHop()
   if not _G.AutoHopEnabled then return end
   StatusLabel:UpdateLabel("Status: Mencari Server Baru...")
   local placeId = game.PlaceId
   local url = "https://games.roblox.com/v1/games/" .. placeId .. "/servers/Public?sortOrder=Asc&limit=100"
   
   local success, result = pcall(function()
       return HttpService:JSONDecode(game:HttpGet(url))
   end)
   
   if success and result and result.data then
       local validServers = {}
       for _, server in ipairs(result.data) do
           local isVisited = false
           for _, visitedId in ipairs(shared.VisitedServers) do
               if server.id == visitedId then isVisited = true break end
           end
           if not isVisited and server.playing < server.maxPlayers then
               table.insert(validServers, server.id)
           end
       end
       
       if #validServers > 0 and _G.AutoHopEnabled then
           local randomServerId = validServers[math.random(1, #validServers)]
           StatusLabel:UpdateLabel("Status: Server Ketemu! Teleporting...")
           task.wait(1)
           TeleportService:TeleportToPlaceInstance(placeId, randomServerId, Players.LocalPlayer)
       else
           StatusLabel:UpdateLabel("Status: Server penuh, mengulang...")
           shared.VisitedServers = {game.JobId}
           task.wait(5)
           doAutoHop()
       end
   end
end

-- TIMER LOOP
task.spawn(function()
   while true do
      task.wait(1)
      if _G.AutoHopEnabled then
         if _G.SisaWaktuDetik > 0 then
            _G.SisaWaktuDetik = _G.SisaWaktuDetik - 1
            TimerLabel:UpdateLabel("Sisa Waktu: " .. string.format("%02d:%02d", math.floor(_G.SisaWaktuDetik / 60), _G.SisaWaktuDetik % 60))
         else
            doAutoHop()
         end
      end
   end
end)

-- [[ UI LOGIC - HOP ]] --
HopSection:NewToggle("Aktifkan Auto Hop", "Otomatis pindah server", function(Value)
    _G.AutoHopEnabled = Value
    _G.SisaWaktuDetik = _G.WaktuTunggu
    StatusLabel:UpdateLabel(Value and "Status: Auto Hop Berjalan" or "Status: Auto Hop Mati")
end)

HopSection:NewSlider("Atur Menit Tunggu", "Geser menit", 60, 1, function(Value)
    _G.WaktuTunggu = Value * 60
    _G.SisaWaktuDetik = _G.WaktuTunggu
end)

HopSection:NewButton("Instant Hop Sekarang", "Pindah langsung", function()
    _G.AutoHopEnabled = true
    doAutoHop()
end)

-- [[ UI LOGIC - STOCK ]] --
StockSection:NewToggle("Aktifkan Auto Stock", "Otomatis isi booth", function(Value)
    _G.AutoStockEnabled = Value
    if Value then doAutoStock() end
end)

local FruitDropdown = StockSection:NewDropdown("Pilih Buah Jualan", "Buah di inven", getInventoryFruits(), function(currentOption)
    _G.FruitYangDijual = currentOption
    InfoStockLabel:UpdateLabel("Target: " .. _G.FruitYangDijual .. " | Harga: " .. tostring(_G.HargaJual))
end)

StockSection:NewButton("🔄 Refresh Daftar Buah", "Update list info buah", function()
    FruitDropdown:Refresh(getInventoryFruits())
end)

-- SOLUSI FIX: GANTI PAKE SLIDER HARGA (BIAR GAK NYANGKUT DI KEYBOARD HP)
StockSection:NewSlider("Atur Harga Jual", "Geser buat nentuin harga (10 - 2000)", 2000, 10, function(Value)
    _G.HargaJual = Value
    InfoStockLabel:UpdateLabel("Target: " .. _G.FruitYangDijual .. " | Harga: " .. tostring(_G.HargaJual))
end)

-- BUTTON QUICKSET BIAR JUALAN MAHAL LANGSUNG KELIK
StockSection:NewDropdown("Set Harga Cepat (Alternatif)", "Pilih harga instan", {"50", "100", "250", "500", "1000", "5000"}, function(HargaPilihan)
    _G.HargaJual = tonumber(HargaPilihan)
    InfoStockLabel:UpdateLabel("Target: " .. _G.FruitYangDijual .. " | Harga: " .. tostring(_G.HargaJual))
end)

-- HIDE MENU
ConfigSection:NewKeybind("Tombol Hide UI", "F3 untuk close/open", Enum.KeyCode.F3, function()
    Kavo:ToggleUI()
end)
