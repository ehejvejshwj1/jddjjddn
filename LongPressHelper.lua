local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

local Window = WindUI:CreateWindow({
    Title = "长按互动助手",
    Icon = "rbxassetid://10734898176",
    Author = "你",
    Folder = "LongPressHelper",
    Size = UDim2.fromOffset(480, 320),
    Transparent = true,
    Theme = "Dark",
    SideBarWidth = 180,
    HasOutline = true,
    MobileButtons = true,
})

local MainTab = Window:Tab({
    Title = "主功能",
    Icon = "rbxassetid://10734924532",
})

local SettingsTab = Window:Tab({
    Title = "设置",
    Icon = "rbxassetid://10734924532",
})

local statusGui = Instance.new("ScreenGui")
statusGui.Name = "StatusOverlay"
statusGui.ResetOnSpawn = false
statusGui.Parent = game.CoreGui

local statusFrame = Instance.new("Frame")
statusFrame.Size = UDim2.new(0, 220, 0, 90)
statusFrame.Position = UDim2.new(0, 15, 0.15, 0)
statusFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
statusFrame.BackgroundTransparency = 0.2
statusFrame.Parent = statusGui

local statusCorner = Instance.new("UICorner")
statusCorner.CornerRadius = UDim.new(0, 8)
statusCorner.Parent = statusFrame

local statusTitle = Instance.new("TextLabel")
statusTitle.Size = UDim2.new(1, -16, 0, 22)
statusTitle.Position = UDim2.new(0, 8, 0, 4)
statusTitle.BackgroundTransparency = 1
statusTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
statusTitle.Text = "状态"
statusTitle.TextScaled = true
statusTitle.Font = Enum.Font.GothamBold
statusTitle.TextXAlignment = Enum.TextXAlignment.Left
statusTitle.Parent = statusFrame

local statusBind = Instance.new("TextLabel")
statusBind.Size = UDim2.new(1, -16, 0, 20)
statusBind.Position = UDim2.new(0, 8, 0, 28)
statusBind.BackgroundTransparency = 1
statusBind.TextColor3 = Color3.fromRGB(200, 200, 200)
statusBind.Text = "绑定: 无"
statusBind.TextScaled = true
statusBind.Font = Enum.Font.Gotham
statusBind.TextXAlignment = Enum.TextXAlignment.Left
statusBind.TextTruncate = Enum.TextTruncate.AtEnd
statusBind.Parent = statusFrame

local statusDist = Instance.new("TextLabel")
statusDist.Size = UDim2.new(1, -16, 0, 20)
statusDist.Position = UDim2.new(0, 8, 0, 48)
statusDist.BackgroundTransparency = 1
statusDist.TextColor3 = Color3.fromRGB(255, 255, 100)
statusDist.Text = "距离: --"
statusDist.TextScaled = true
statusDist.Font = Enum.Font.Gotham
statusDist.TextXAlignment = Enum.TextXAlignment.Left
statusDist.Parent = statusFrame

local statusCount = Instance.new("TextLabel")
statusCount.Size = UDim2.new(1, -16, 0, 20)
statusCount.Position = UDim2.new(0, 8, 0, 68)
statusCount.BackgroundTransparency = 1
statusCount.TextColor3 = Color3.fromRGB(100, 255, 100)
statusCount.Text = "触发次数: 0"
statusCount.TextScaled = true
statusCount.Font = Enum.Font.Gotham
statusCount.TextXAlignment = Enum.TextXAlignment.Left
statusCount.Parent = statusFrame

local dragging, dragStart, startPos
statusFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = statusFrame.Position
    end
end)
statusFrame.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement) then
        local delta = input.Position - dragStart
        statusFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)
statusFrame.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

local progressGui = Instance.new("ScreenGui")
progressGui.Name = "ProgressOverlay"
progressGui.ResetOnSpawn = false
progressGui.Parent = game.CoreGui

local progressFrame = Instance.new("Frame")
progressFrame.Size = UDim2.new(0, 200, 0, 50)
progressFrame.Position = UDim2.new(0.5, -100, 0.7, 0)
progressFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
progressFrame.BackgroundTransparency = 0.2
progressFrame.Visible = false
progressFrame.Parent = progressGui

local progressCorner = Instance.new("UICorner")
progressCorner.CornerRadius = UDim.new(0, 8)
progressCorner.Parent = progressFrame

local progressLabel = Instance.new("TextLabel")
progressLabel.Size = UDim2.new(1, -20, 0, 20)
progressLabel.Position = UDim2.new(0, 10, 0, 4)
progressLabel.BackgroundTransparency = 1
progressLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
progressLabel.Text = "长按中... 0%"
progressLabel.TextScaled = true
progressLabel.Font = Enum.Font.GothamBold
progressLabel.TextXAlignment = Enum.TextXAlignment.Left
progressLabel.Parent = progressFrame

local barBg = Instance.new("Frame")
barBg.Size = UDim2.new(1, -20, 0, 12)
barBg.Position = UDim2.new(0, 10, 0, 30)
barBg.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
barBg.BorderSizePixel = 0
barBg.Parent = progressFrame

local barBgCorner = Instance.new("UICorner")
barBgCorner.CornerRadius = UDim.new(0, 6)
barBgCorner.Parent = barBg

local barFill = Instance.new("Frame")
barFill.Size = UDim2.new(0, 0, 1, 0)
barFill.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
barFill.BorderSizePixel = 0
barFill.Parent = barBg

local barFillCorner = Instance.new("UICorner")
barFillCorner.CornerRadius = UDim.new(0, 6)
barFillCorner.Parent = barFill

local pDragging, pDragStart, pStartPos
progressFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        pDragging = true
        pDragStart = input.Position
        pStartPos = progressFrame.Position
    end
end)
progressFrame.InputChanged:Connect(function(input)
    if pDragging and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement) then
        local delta = input.Position - pDragStart
        progressFrame.Position = UDim2.new(pStartPos.X.Scale, pStartPos.X.Offset + delta.X, pStartPos.Y.Scale, pStartPos.Y.Offset + delta.Y)
    end
end)
progressFrame.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        pDragging = false
    end
end)

local boundPrompt = nil
local isTriggering = false
local autoMode = false
local quickMode = false
local quickConn = nil
local autoThread = nil
local showProgress = true
local instantMode = false
local loopDelay = 0.2
local triggerCount = 0
local showStatus = true
local afkMode = false
local afkConn = nil

local function startAntiAFK()
    local VirtualUser = game:GetService("VirtualUser")
    afkConn = game:GetService("Players").LocalPlayer.Idled:Connect(function()
        VirtualUser:Button2Down(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
        task.wait(1)
        VirtualUser:Button2Up(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
    end)
end

local function stopAntiAFK()
    if afkConn then
        afkConn:Disconnect()
        afkConn = nil
    end
end

local function findNearestHoldPrompt()
    local char = game.Players.LocalPlayer.Character
    if not char then return nil, 0 end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return nil, 0 end

    local nearest, minDist = nil, math.huge
    for _, v in ipairs(workspace:GetDescendants()) do
        if v:IsA("ProximityPrompt") and v.Enabled and v.HoldDuration > 0 then
            local part = v.Parent
            if part and part:IsA("BasePart") then
                local d = (root.Position - part.Position).Magnitude
                if d < minDist then
                    minDist = d
                    nearest = v
                end
            end
        end
    end
    return nearest, minDist
end

local function getCurrentDistance()
    if not boundPrompt then return nil end
    local char = game.Players.LocalPlayer.Character
    if not char then return nil end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return nil end
    local part = boundPrompt.Parent
    if not part or not part:IsA("BasePart") then return nil end
    return (root.Position - part.Position).Magnitude
end

local function refreshStatus()
    if boundPrompt then
        local name = boundPrompt:GetFullName()
        if #name > 30 then name = "..." .. name:sub(-27) end
        statusBind.Text = "绑定: " .. name
        statusBind.TextColor3 = Color3.fromRGB(200, 255, 200)
    else
        statusBind.Text = "绑定: 无"
        statusBind.TextColor3 = Color3.fromRGB(200, 200, 200)
    end

    local dist = getCurrentDistance()
    if dist then
        statusDist.Text = string.format("距离: %.1f 米", dist)
    else
        statusDist.Text = "距离: --"
    end

    statusCount.Text = "触发次数: " .. triggerCount
end

task.spawn(function()
    while true do
        if showStatus then
            statusFrame.Visible = true
            refreshStatus()
        else
            statusFrame.Visible = false
        end
        task.wait(0.5)
    end
end)

local function triggerOnce(callback)
    if not boundPrompt or isTriggering then
        if callback then callback() end
        return
    end
    isTriggering = true

    if instantMode then
        pcall(function()
            fireproximityprompt(boundPrompt)
        end)
        triggerCount = triggerCount + 1
        isTriggering = false
        if callback then callback() end
        return
    end

    if showProgress then
        progressFrame.Visible = true
        barFill.Size = UDim2.new(0, 0, 1, 0)
        barFill.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
    end

    local duration = boundPrompt.HoldDuration
    if duration <= 0 then duration = 0.1 end

    local startTime = tick()
    local conn
    conn = game:GetService("RunService").Heartbeat:Connect(function()
        local percent = math.clamp((tick() - startTime) / duration, 0, 1)
        if showProgress then
            barFill.Size = UDim2.new(percent, 0, 1, 0)
            progressLabel.Text = string.format("长按中... %d%%", math.floor(percent * 100))
        end
        if percent >= 1 then
            conn:Disconnect()
            pcall(function()
                fireproximityprompt(boundPrompt)
            end)
            triggerCount = triggerCount + 1
            if showProgress then
                progressLabel.Text = "完成！"
                barFill.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
                task.wait(0.3)
                progressFrame.Visible = false
            end
            isTriggering = false
            if callback then callback() end
        end
    end)
end

MainTab:Button({
    Title = "绑定最近的长按互动",
    Desc = "走到要互动的东西旁边，点这个",
    Callback = function()
        local prompt, dist = findNearestHoldPrompt()
        if not prompt then
            WindUI:Notify({Title = "绑定失败", Content = "附近没有长按互动", Duration = 3})
            return
        end
        boundPrompt = prompt
        WindUI:Notify({Title = "绑定成功", Content = "距离 " .. math.floor(dist) .. " 米", Duration = 3})
        refreshStatus()
    end,
})

MainTab:Button({
    Title = "手动触发一次",
    Desc = "点一下触发绑定的互动",
    Callback = function()
        if not boundPrompt then
            WindUI:Notify({Title = "没绑定", Content = "请先绑定一个长按互动", Duration = 3})
            return
        end
        triggerOnce()
    end,
})

MainTab:Toggle({
    Title = "全自动触发",
    Desc = "循环触发绑定的互动",
    Value = false,
    Callback = function(state)
        autoMode = state
        if state then
            autoThread = task.spawn(function()
                while autoMode do
                    if boundPrompt then
                        triggerOnce()
                        while isTriggering and autoMode do
                            task.wait(0.05)
                        end
                        task.wait(loopDelay)
                    else
                        task.wait(0.5)
                    end
                end
            end)
        end
    end,
})

MainTab:Toggle({
    Title = "快速互动",
    Desc = "把长按变成瞬发（按住瞬间完成）",
    Value = false,
    Callback = function(state)
        quickMode = state
        if state then
            if quickConn then
                quickConn:Disconnect()
                quickConn = nil
            end
            quickConn = game:GetService("ProximityPromptService").PromptButtonHoldBegan:Connect(function(prompt)
                prompt.HoldDuration = 0
            end)
            WindUI:Notify({Title = "快速互动", Content = "已开启", Duration = 2})
        else
            if quickConn then
                quickConn:Disconnect()
                quickConn = nil
            end
            WindUI:Notify({Title = "快速互动", Content = "已关闭", Duration = 2})
        end
    end,
})

SettingsTab:Toggle({
    Title = "防AFK",
    Desc = "防止挂机被踢（模拟按键）",
    Value = false,
    Callback = function(state)
        afkMode = state
        if state then
            startAntiAFK()
            WindUI:Notify({Title = "防AFK", Content = "已开启", Duration = 2})
        else
            stopAntiAFK()
            WindUI:Notify({Title = "防AFK", Content = "已关闭", Duration = 2})
        end
    end,
})

SettingsTab:Toggle({
    Title = "显示状态框",
    Desc = "显示绑定信息、距离、触发次数",
    Value = true,
    Callback = function(state)
        showStatus = state
    end,
})

SettingsTab:Toggle({
    Title = "显示进度条",
    Desc = "关掉后触发时不显示进度框",
    Value = true,
    Callback = function(state)
        showProgress = state
        if not state then
            progressFrame.Visible = false
        end
    end,
})

SettingsTab:Toggle({
    Title = "自动触发瞬发",
    Desc = "自动触发时不走进度条，直接秒触发",
    Value = false,
    Callback = function(state)
        instantMode = state
    end,
})

SettingsTab:Slider({
    Title = "全自动间隔",
    Desc = "每轮触发之间等待的秒数",
    Value = {
        Min = 0.05,
        Max = 2,
        Default = 0.2,
    },
    Callback = function(value)
        loopDelay = value
    end,
})

SettingsTab:Button({
    Title = "重置触发计数",
    Desc = "把触发次数清零",
    Callback = function()
        triggerCount = 0
        refreshStatus()
        WindUI:Notify({Title = "已重置", Content = "触发计数归零", Duration = 2})
    end,
})