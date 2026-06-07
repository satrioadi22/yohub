local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")

local FILE_NAME = "BoothClickerConfig.json"
_G.AutoClickBooth = false

-- Load config
local function loadConfig()
    if isfile and isfile(FILE_NAME) then
        local ok, data = pcall(function()
            return HttpService:JSONDecode(readfile(FILE_NAME))
        end)
        if ok and type(data) == "table" and data.Enabled ~= nil then
            _G.AutoClickBooth = data.Enabled
        end
    end
end

-- Save config
local function saveConfig()
    if writefile then
        writefile(FILE_NAME, HttpService:JSONEncode({ Enabled = _G.AutoClickBooth }))
    end
end

loadConfig()

-- =====================
-- GUI
-- =====================
if CoreGui:FindFirstChild("BoothUI") then
    CoreGui.BoothUI:Destroy()
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "BoothUI"
ScreenGui.Parent = CoreGui
ScreenGui.ResetOnSpawn = false

local Frame = Instance.new("Frame")
Frame.Parent = ScreenGui
Frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
Frame.Position = UDim2.new(0.05, 0, 0.4, 0)
Frame.Size = UDim2.new(0, 170, 0, 80)
Frame.Active = true
Frame.Draggable = true
Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 10)

-- Label judul
local Title = Instance.new("TextLabel")
Title.Parent = Frame
Title.BackgroundTransparency = 1
Title.Position = UDim2.new(0, 0, 0, 5)
Title.Size = UDim2.new(1, 0, 0, 20)
Title.Text = "Booth Auto Click"
Title.TextColor3 = Color3.fromRGB(180, 180, 180)
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 13

-- Tombol toggle
local Toggle = Instance.new("TextButton")
Toggle.Parent = Frame
Toggle.Position = UDim2.new(0.08, 0, 0, 30)
Toggle.Size = UDim2.new(0, 142, 0, 38)
Toggle.Font = Enum.Font.SourceSansBold
Toggle.TextSize = 15
Instance.new("UICorner", Toggle).CornerRadius = UDim.new(0, 8)

local function updateUI()
    if _G.AutoClickBooth then
        Toggle.Text = "Auto Click: ON"
        Toggle.BackgroundColor3 = Color3.fromRGB(46, 204, 113)
    else
        Toggle.Text = "Auto Click: OFF"
        Toggle.BackgroundColor3 = Color3.fromRGB(231, 76, 60)
    end
    Toggle.TextColor3 = Color3.fromRGB(255, 255, 255)
end

Toggle.MouseButton1Click:Connect(function()
    _G.AutoClickBooth = not _G.AutoClickBooth
    updateUI()
    saveConfig()
end)

updateUI()

-- =====================
-- AUTO CLICK LOOP
-- =====================
task.spawn(function()
    while true do
        task.wait(8)
        if _G.AutoClickBooth then
            pcall(function()
                local btn = LocalPlayer.PlayerGui.Teleport_UI.TradePlaza.Booth
                if btn then
                    btn.MouseButton1Click:Fire()
                    print("Booth clicked!")
                end
            end)
        end
    end
end)
