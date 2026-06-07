-- ====================================================================
-- CONFIGURATION & AUTO-SAVE LOGIC
-- ====================================================================
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Workspace = game:GetService("Workspace")
local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")

local FILE_NAME = "BoothAutoClicker_Config.json"
local _G = _G or {}
_G.AutoClickBooth = false -- Default awal jika file config belum ada

-- Fungsi untuk membaca pengaturan yang tersimpan
local function loadConfig()
    if isfile and isfile(FILE_NAME) then
        local success, data = pcall(function()
            return HttpService:JSONDecode(readfile(FILE_NAME))
        end)
        if success and type(data) == "table" then
            if data.Enabled ~= nil then
                _G.AutoClickBooth = data.Enabled
            end
        end
    end
end

-- Fungsi untuk menyimpan pengaturan
local function saveConfig()
    if writefile then
        local data = { Enabled = _G.AutoClickBooth }
        writefile(FILE_NAME, HttpService:JSONEncode(data))
    end
end

-- Load config di awal script dijalankan
loadConfig()

-- ====================================================================
-- SIMPLE GUI CREATION (Hanya 1 Tombol Toggle)
-- ====================================================================

-- Hapus UI lama jika script di-load ulang tanpa relog
if CoreGui:FindFirstChild("BoothClickerUI") then
    CoreGui.BoothClickerUI:Destroy()
end

local ScreenGui = Instance.new("ScreenGui")
local MainFrame = Instance.new("Frame")
local ToggleButton = Instance.new("TextButton")
local UICorner_Frame = Instance.new("UICorner")
local UICorner_Button = Instance.new("UICorner")

ScreenGui.Name = "BoothClickerUI"
ScreenGui.Parent = CoreGui
ScreenGui.ResetOnSpawn = false

-- Frame Utama (Bisa digeser/drag)
MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MainFrame.Position = UDim2.new(0.05, 0, 0.4, 0) -- Posisi di kiri layar
MainFrame.Size = UDim2.new(0, 160, 0, 60)
MainFrame.Active = true
MainFrame.Draggable = true -- Membuat UI bisa digeser sesuai selera

UICorner_Frame.CornerRadius = UDim.new(0, 8)
UICorner_Frame.Parent = MainFrame

-- Tombol Toggle On/Off
ToggleButton.Name = "ToggleButton"
ToggleButton.Parent = MainFrame
ToggleButton.Position = UDim2.new(0.05, 0, 0.15, 0)
ToggleButton.Size = UDim2.new(0, 142, 0, 42)
ToggleButton.Font = Enum.Font.SourceSansBold
ToggleButton.TextSize = 16

UICorner_Button.CornerRadius = UDim.new(0, 6)
UICorner_Button.Parent = ToggleButton

-- Fungsi untuk memperbarui tampilan tombol berdasarkan status
local function updateButtonDisplay()
    if _G.AutoClickBooth then
        ToggleButton.Text = "Auto Click: ON"
        ToggleButton.BackgroundColor3 = Color3.fromRGB(46, 204, 113) -- Warna Hijau
        ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    else
        ToggleButton.Text = "Auto Click: OFF"
        ToggleButton.BackgroundColor3 = Color3.fromRGB(231, 76, 60) -- Warna Merah
        ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    end
end

-- Pemicu saat tombol di klik
ToggleButton.MouseButton1Click:Connect(function()
    _G.AutoClickBooth = not _G.AutoClickBooth
    updateButtonDisplay()
    saveConfig() -- Simpan status terbaru ke storage
end)

-- Tampilkan status saat pertama kali load
updateButtonDisplay()

-- ====================================================================
-- AUTO CLICK CORE LOGIC
-- ====================================================================
local function autoClickBooth()
    -- Cek apakah fitur sedang aktif
    if not _G.AutoClickBooth then return end
    
    local character = LocalPlayer.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return end
    
    local myPos = character.HumanoidRootPart.Position
    local closestPrompt = nil
    local shortestDistance = math.huge

    -- Mencari ProximityPrompt (Tombol Edit Booth dari screenshot Last Screenshot 2026.06.07 - 22.51.12.93.jpg)
    for _, v in pairs(Workspace:GetDescendants()) do
        if v:IsA("ProximityPrompt") then
            -- Filter agar lebih fokus ke Booth (opsional)
            if v.ActionText == "Edit" or v.ObjectText == "Booth" or string.find(string.lower(v.ActionText), "booth") then
                local parent = v.Parent
                if parent and parent:IsA("BasePart") then
                    local distance = (myPos - parent.Position).Magnitude
                    if distance < shortestDistance then
                        shortestDistance = distance
                        closestPrompt = v
                    end
                end
            end
        end
    end

    -- Eksekusi klik otomatis jika berada dalam jarak jangkauan (15 studs)
    if closestPrompt and shortestDistance <= 15 then
        fireproximityprompt(closestPrompt)
    end
end

-- Loop utama yang berjalan di latar belakang setiap 0.5 detik agar lebih responsif
task.spawn(function()
    while true do
        task.wait(0.5)
        pcall(autoClickBooth)
    end
end)
