-- [[ LOAD RAYFIELD UI LIBRARY ]] --
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- [[ WINDOW INITIALIZATION ]] --
local Window = Rayfield:CreateWindow({
   Name = "YoHub | Grow a Garden",
   LoadingTitle = "Loading YoHub...",
   LoadingSubtitle = "by satrioadi22",
   ConfigurationSaving = {
      Enabled = false
   },
   KeySystem = false
})

-- [[ VARIABLES & CONFIG ]] --
local _G = getgenv and getgenv() or _G
_G.AutoHopEnabled = false
_G.WaktuTunggu = 1200 -- Default 20 menit (dalam detik)
_G.SisaWaktuDetik = 1200

-- Variabel untuk Auto Stock
_G.AutoStockEnabled = false
_G.FruitYangDijual = "Apple" -- Default nama buah
_G.HargaJual = 100 -- Default harga

local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")

shared.VisitedServers = shared.VisitedServers or {}
table.insert(shared.VisitedServers, game.JobId)

-- [[ LABELS UNTUK MONITORING ]] --
local MainTab = Window:CreateTab("Main Features", 4483362458)
local StatusLabel = MainTab:CreateLabel("Status: Auto Hop Mati", 4483362458)
local TimerLabel = MainTab:CreateLabel("Sisa Waktu: --:--", 4483362458)

-- [[ FUNCTION FORMAT WAKTU ]] --
local function formatWaktu(totalDetik)
    local menit = math.floor(totalDetik / 60)
    local detik = totalDetik % 60
    return string.format("%02d:%02d", menit, detik)
end

-- [[ FUNCTION AUTO HOP ]] --
local function doAutoHop()
   if not _G.AutoHopEnabled then return end
   StatusLabel:Set("Status: Mencari Server Baru...")
   
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
               if server.id == visitedId then
                   isVisited = true
                   break
               end
           end
           
           if not isVisited and server.playing < server.maxPlayers then
               table.insert(validServers, server.id)
           end
       end
       
       if #validServers > 0 and _G.AutoHopEnabled then
           local randomServerId = validServers[math.random(1, #validServers)]
           Rayfield:Notify({
              Title = "YoHub",
              Content = "Server baru ketemu! Berpindah server...",
              Duration = 5,
              Image = 4483362458,
           })
           task.wait(1)
           TeleportService:TeleportToPlaceInstance(placeId, randomServerId, Players.LocalPlayer)
       else
           StatusLabel:Set("Status: Server penuh/sudah dikunjungi, mengulang...")
           shared.VisitedServers = {game.JobId}
           task.wait(5)
           doAutoHop()
       end
   else
       StatusLabel:Set("Status: Gagal mengambil data server")
   end
end

-- [[ FUNCTION AUTO STOCK ]] --
local function doAutoStock()
    task.spawn(function()
        while _G.AutoStockEnabled do
            -- CATATAN: Ini adalah logika blueprint/contoh umum.
            -- Jika game menggunakan RemoteEvent untuk stok barang, lu perlu scan pake Remote Spy
            -- Lalu ganti atau masukkan kodenya di bawah sini, contoh:
            -- game:GetService("ReplicatedStorage").Remotes.StockItem:FireServer(_G.FruitYangDijual, _G.HargaJual)
            
            print("YoHub: Mencoba auto stock buah: " .. _G.FruitYangDijual .. " dengan harga: " .. _G.HargaJual)
            
            task.wait(5) -- Mengulang cek stok setiap 5 detik
        end
    end)
end

-- [[ BACKGROUND LOOP TIMER AUTO HOP ]] --
task.spawn(function()
   while true do
      task.wait(1)
      if _G.AutoHopEnabled then
         if _G.SisaWaktuDetik > 0 then
            _G.SisaWaktuDetik = _G.SisaWaktuDetik - 1
            TimerLabel:Set("Sisa Waktu: " .. formatWaktu(_G.SisaWaktuDetik))
         else
            TimerLabel:Set("Sisa Waktu: WAKTU HABIS!")
            doAutoHop()
         end
      else
         TimerLabel:Set("Sisa Waktu: --:--")
      end
   end
end)


-- [[ UI ELEMENTS - SEKSI AUTO HOP ]] --
MainTab:CreateSection("Auto Hop Configuration")

-- Toggle Auto Hop
local HopToggle = MainTab:CreateToggle({
   Name = "Aktifkan Auto Hop",
   CurrentValue = false,
   Flag = "AutoHopToggle",
   Callback = function(Value)
      _G.AutoHopEnabled = Value
      if Value then
         _G.SisaWaktuDetik = _G.WaktuTunggu
         StatusLabel:Set("Status: Auto Hop Berjalan")
         Rayfield:Notify({
            Title = "YoHub",
            Content = "Auto Hop Aktif! Server akan pindah setiap " .. (_G.WaktuTunggu / 60) .. " menit.",
            Duration = 5,
            Image = 4483362458,
         })
      else
         StatusLabel:Set("Status: Auto Hop Mati")
         Rayfield:Notify({
            Title = "YoHub",
            Content = "Auto Hop Dinonaktifkan.",
            Duration = 3,
            Image = 4483362458,
         })
      end
   end,
})

-- Slider Atur Menit
local TimeSlider = MainTab:CreateSlider({
   Name = "Atur Menit Tunggu",
   Min = 1,
   Max = 60,
   CurrentValue = 20,
   Flag = "WaktuSlider",
   Callback = function(Value)
      _G.WaktuTunggu = Value * 60
      if _G.AutoHopEnabled then
         _G.SisaWaktuDetik = _G.WaktuTunggu
      end
   end,
})

-- Tombol Reset Timer
MainTab:CreateButton({
   Name = "Reset Timer Hitung Mundur",
   Callback = function()
      _G.SisaWaktuDetik = _G.WaktuTunggu
      Rayfield:Notify({
         Title = "YoHub",
         Content = "Timer di-reset kembali ke " .. (_G.WaktuTunggu / 60) .. " menit.",
         Duration = 3,
         Image = 4483362458,
      })
   end,
})

-- Tombol Instant Hop
MainTab:CreateButton({
   Name = "Instant Hop Sekarang (Tanpa Nunggu)",
   Callback = function()
      _G.AutoHopEnabled = true
      doAutoHop()
   end,
})


-- [[ UI ELEMENTS - SEKSI AUTO STOCK ]] --
MainTab:CreateSection("Auto Stock Market")

-- Toggle Aktifkan Auto Stock
MainTab:CreateToggle({
   Name = "Aktifkan Auto Stock",
   CurrentValue = false,
   Flag = "AutoStockToggle",
   Callback = function(Value)
      _G.AutoStockEnabled = Value
      if Value then
          Rayfield:Notify({
             Title = "YoHub",
             Content = "Auto Stock Aktif! Menyetok: " .. _G.FruitYangDijual .. " ($" .. _G.HargaJual .. ")",
             Duration = 4,
             Image = 4483362458,
          })
          doAutoStock()
      else
          Rayfield:Notify({
             Title = "YoHub",
             Content = "Auto Stock Dinonaktifkan.",
             Duration = 3,
             Image = 4483362458,
          })
      end
   end,
})

-- Input Teks Nama Buah
MainTab:CreateInput({
   Name = "Nama Buah / Fruit",
   PlaceholderText = "Misal: Apple, Banana, DragonFruit",
   RemoveTextAfterFocusLost = false,
   Callback = function(Text)
      _G.FruitYangDijual = Text
   end,
})

-- Input Angka Harga Buah
MainTab:CreateInput({
   Name = "Harga Jual (Price)",
   PlaceholderText = "Masukkan Angka Harga",
   RemoveTextAfterFocusLost = false,
   Callback = function(Text)
      local angka = tonumber(Text)
      if angka then
          _G.HargaJual = angka
      else
          _G.HargaJual = 0
      end
   end,
})
