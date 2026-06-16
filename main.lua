-- // AUTO HOP SERVER V3 (TANPA SAVE FILE - ANTI ERROR DELTA) \\ --

local Players = game:GetService("Players")
local TS = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")

local MIN_PLAYERS = 5

-- Langsung TRUE biar auto jalan tanpa pencet tombol
local isToggled = true 
local isHopping = false

-- // FUNGSI TELEPORT BYPASS DELTA \\ --
local function teleportTo(placeId, jobId)
    pcall(function()
        if getconnections then
            for _, conn in pairs(getconnections(TS.InternalTeleport)) do
                conn:Enable()
            end
        end
    end)
    
    if jobId then
        TS:TeleportToPlaceInstance(placeId, jobId, Players.LocalPlayer)
    else
        TS:Teleport(placeId, Players.LocalPlayer)
    end
end

-- // FUNGSI CARI SERVER (DENGAN FALLBACK) \\ --
local function findNewServer()
    if isHopping then return end
    isHopping = true
    StatusLabel.Text = "Status: Mencari server..."
    StatusLabel.TextColor3 = Color3.fromRGB(255, 255, 0)

    local placeId = game.PlaceId
    local foundServer = false
    
    -- CARA 1: Pake API Roblox
    local apiSuccess = pcall(function()
        local cursor = nil
        while true do
            local url = cursor and ("https://games.roblox.com/v1/games/" .. placeId .. "/servers/Public?sortOrder=Desc&limit=100&cursor=" .. cursor) or ("https://games.roblox.com/v1/games/" .. placeId .. "/servers/Public?sortOrder=Desc&limit=100")
            
            local response = HttpService:JSONDecode(game:HttpGet(url))
            
            for _, server in pairs(response.data) do
                if type(server.playing) == "number" and server.playing >= MIN_PLAYERS and server.id ~= game.JobId then
                    StatusLabel.Text = "Status: Hopping via API!"
                    StatusLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
                    teleportTo(placeId, server.id)
                    foundServer = true
                    return
                end
            end
            
            cursor = response.nextPageCursor
            if not cursor then break end
            task.wait(1)
        end
    end)
    
    -- CARA 2: Fallback kalau API error/blokir
    if not foundServer then
        warn("[HOP] API Gagal, menggunakan Fallback Teleport...")
        StatusLabel.Text = "Status: Fallback Hop..."
        StatusLabel.TextColor3 = Color3.fromRGB(255, 100, 0)
        task.wait(1)
        teleportTo(placeId, nil)
    end
    
    task.wait(5)
    isHopping = false
end

-- // BIKIN UI \\ --
local ScreenGui = Instance.new("ScreenGui")
local MainFrame = Instance.new("Frame")
local TitleLabel = Instance.new("TextLabel")
local ToggleBtn = Instance.new("TextButton")
local StatusLabel = Instance.new("TextLabel")

-- Hapus UI lama kalau ada
pcall(function()
    if game.CoreGui:FindFirstChild("AutoHopUI") then
        game.CoreGui:FindFirstChild("AutoHopUI"):Destroy()
    end
end)

ScreenGui.Name = "AutoHopUI"
ScreenGui.Parent = game.CoreGui
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MainFrame.Position = UDim2.new(0.02, 0, 0.4, 0)
MainFrame.Size = UDim2.new(0, 180, 0, 130)
MainFrame.Active = true
MainFrame.Draggable = true

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 6)
UICorner.Parent = MainFrame

TitleLabel.Name = "Title"
TitleLabel.Parent = MainFrame
TitleLabel.BackgroundTransparency = 1
TitleLabel.Size = UDim2.new(1, 0, 0, 30)
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.Text = "AUTO HOP"
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.TextSize = 16

ToggleBtn.Name = "ToggleBtn"
ToggleBtn.Parent = MainFrame
ToggleBtn.BackgroundColor3 = Color3.fromRGB(50, 200, 50) -- Langsung HIJAU
ToggleBtn.Position = UDim2.new(0.1, 0, 0.25, 0)
ToggleBtn.Size = UDim2.new(0.8, 0, 0, 35)
ToggleBtn.Font = Enum.Font.GothamBold
ToggleBtn.Text = "ON" -- Langsung ON
ToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleBtn.TextSize = 14
ToggleBtn.AutoButtonColor = true

local BtnCorner = Instance.new("UICorner")
BtnCorner.CornerRadius = UDim.new(0, 6)
BtnCorner.Parent = ToggleBtn

StatusLabel.Name = "Status"
StatusLabel.Parent = MainFrame
StatusLabel.BackgroundTransparency = 1
StatusLabel.Position = UDim2.new(0, 0, 0.65, 0)
StatusLabel.Size = UDim2.new(1, 0, 0, 35)
StatusLabel.Font = Enum.Font.Gotham
StatusLabel.Text = "Status: Aktif (Auto)"
StatusLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
StatusLabel.TextSize = 11
StatusLabel.TextWrapped = true

-- // LOGIKA TOMBOL (Masih bisa diclick OFF kalau mau matiin) \\ --
ToggleBtn.MouseButton1Click:Connect(function()
    isToggled = not isToggled
    
    if isToggled then
        ToggleBtn.Text = "ON"
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
        StatusLabel.Text = "Status: Aktif"
        StatusLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
    else
        ToggleBtn.Text = "OFF"
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        StatusLabel.Text = "Status: Mati"
        StatusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    end
end)

-- // LOOPING UTAMA \\ --
task.spawn(function()
    while task.wait(3) do
        if isToggled and not isHopping then
            local playerCount = #Players:GetPlayers()
            if playerCount < MIN_PLAYERS then
                findNewServer()
            else
                StatusLabel.Text = "Status: Aman ("..playerCount.." Pemain)"
                StatusLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
            end
        end
    end
end)
