local Workspace = game:GetService("Workspace")
local Player = game:GetService("Players").LocalPlayer
local Mouse = Player:GetMouse()
local UserInputService = game:GetService("UserInputService")
local TextService = game:GetService("TextService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local CoreGuiService = game:GetService("CoreGui")
local ContentService = game:GetService("ContentProvider")
local TeleportService = game:GetService("TeleportService")
local TweenTable = {
    Default = {
        TweenInfo.new(0.17, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, 0, false, 0)
    }
}
local CreateTween = function(name, speed, style, direction, loop, reverse, delay)
    name = tostring(name)
    if type(speed) ~= "number" or speed ~= speed or speed <= 0 then
        speed = 0.17
    end
    if typeof(style) ~= "EnumItem" then
        style = Enum.EasingStyle.Sine
    end
    if typeof(direction) ~= "EnumItem" then
        direction = Enum.EasingDirection.InOut
    end
    loop = (type(loop) == "number") and loop or 0
    reverse = (type(reverse) == "boolean") and reverse or false
    delay = (type(delay) == "number") and delay or 0
    TweenTable[name] = TweenInfo.new(speed, style, direction, loop, reverse, delay)
end
local isControlInteracting = false
local drag = function(obj, latency)
    latency = latency or 0.04
    local toggled = false
    local start = nil
    local startPos = nil
    local activeInput = nil
    local dragChangedConn = nil
    local dragEndedConn = nil
    local function updateInput(input)
        local Delta = input.Position - start
        local Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + Delta.X, startPos.Y.Scale, startPos.Y.Offset + Delta.Y)
        if latency and latency > 0 then
            TweenService:Create(obj, TweenInfo.new(latency, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position = Position}):Play()
        else
            obj.Position = Position
        end
    end
    obj.InputBegan:Connect(function(inp)
        if isControlInteracting then return end
        if (inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch) and not activeInput then
            toggled = true
            start = inp.Position
            startPos = obj.Position
            activeInput = inp
            if dragChangedConn then dragChangedConn:Disconnect() end
            if dragEndedConn then dragEndedConn:Disconnect() end
            dragChangedConn = UserInputService.InputChanged:Connect(function(changedInput)
                if isControlInteracting then
                    toggled = false
                    activeInput = nil
                    if dragChangedConn then dragChangedConn:Disconnect() dragChangedConn = nil end
                    if dragEndedConn then dragEndedConn:Disconnect() dragEndedConn = nil end
                    return
                end
                if toggled and (changedInput == activeInput or (activeInput and activeInput.UserInputType == Enum.UserInputType.MouseButton1 and changedInput.UserInputType == Enum.UserInputType.MouseMovement)) then
                    updateInput(changedInput)
                end
            end)
            dragEndedConn = UserInputService.InputEnded:Connect(function(endedInput)
                if endedInput == activeInput or (activeInput and activeInput.UserInputType == Enum.UserInputType.MouseButton1 and endedInput.UserInputType == Enum.UserInputType.MouseButton1) then
                    toggled = false
                    activeInput = nil
                    if dragChangedConn then
                        dragChangedConn:Disconnect()
                        dragChangedConn = nil
                    end
                    if dragEndedConn then
                        dragEndedConn:Disconnect()
                        dragEndedConn = nil
                    end
                end
            end)
        end
    end)
end
local applyShimmer = function(bar)
    if not bar then return end
    local existing = bar:FindFirstChild("shimmerGradient")
    if existing then return existing end
    local gradient = Instance.new("UIGradient")
    gradient.Name = "shimmerGradient"
    gradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0.00, Color3.fromRGB(159, 115, 255)),
        ColorSequenceKeypoint.new(0.25, Color3.fromRGB(159, 115, 255)),
        ColorSequenceKeypoint.new(0.50, Color3.fromRGB(225, 195, 255)),
        ColorSequenceKeypoint.new(0.75, Color3.fromRGB(159, 115, 255)),
        ColorSequenceKeypoint.new(1.00, Color3.fromRGB(159, 115, 255))
    }
    gradient.Offset = Vector2.new(-1, 0)
    gradient.Parent = bar
    local tweenInfo = TweenInfo.new(2.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true)
    local tween = TweenService:Create(gradient, tweenInfo, {Offset = Vector2.new(1, 0)})
    tween:Play()
    return gradient
end
local library = {
    Creator = "namedadude",
    Author = "namedadude",
    creator = "namedadude",
    author = "namedadude",
    ApplyShimmer = applyShimmer,
    version = "2.0.2",
    title = title or "xsx " .. tostring(math.random(1,366)),
    fps = 0,
    rank = "private"
}
function library:GetCreator()
    return "namedadude"
end
function library:GetAuthor()
    return "namedadude"
end
coroutine.wrap(function()
    RunService.RenderStepped:Connect(function(v)
        library.fps =  math.round(1/v)
    end)
end)()
function library:RoundNumber(int, float)
    return tonumber(string.format("%." .. (int or 0) .. "f", float))
end
function library:GetUsername()
    return Player.DisplayName or Player.Name
end
function library:GetDisplayName()
    return Player.DisplayName or Player.Name
end
function library:CheckIfLoaded()
    if game:IsLoaded() then
        return true
    else
        return false
    end
end
function library:GetUserId()
    return Player.UserId
end
function library:GetPlaceId()
    return game.PlaceId
end
function library:GetJobId()
    return game.JobId
end
function library:Rejoin()
    TeleportService:TeleportToPlaceInstance(library:GetPlaceId(), library:GetJobId(), library:GetUserId())
end
function library:Copy(input) 
    if syn then
        syn.write_clipboard(input)
    end
end
function library:GetDay(type)
    if type == "word" then 
        return os.date("%A")
    elseif type == "short" then 
        return os.date("%a")
    elseif type == "month" then 
        return os.date("%d")
    elseif type == "year" then 
        return os.date("%j")
    end
end
function library:GetTime(type)
    if type == "24h" then 
        return os.date("%H")
    elseif type == "12h" then 
        return os.date("%I")
    elseif type == "minute" then 
        return os.date("%M")
    elseif type == "half" then 
        return os.date("%p")
    elseif type == "second" then 
        return os.date("%S")
    elseif type == "full" then 
        return os.date("%X")
    elseif type == "ISO" then 
        return os.date("%z")
    elseif type == "zone" then 
        return os.date("%Z") 
    end
end
function library:GetMonth(type)
    if type == "word" then 
        return os.date("%B")
    elseif type == "short" then 
        return os.date("%b")
    elseif type == "digit" then 
        return os.date("%m")
    end
end
function library:GetWeek(type)
    if type == "year_S" then 
        return os.date("%U")
    elseif type == "day" then 
        return os.date("%w")
    elseif type == "year_M" then 
        return os.date("%W")
    end
end
function library:GetYear(type)
    if type == "digits" then 
        return os.date("%y")
    elseif type == "full" then 
        return os.date("%Y")
    end
end
function library:UnlockFps(new) 
    if syn then
        setfpscap(new)
    end
end
function library:Watermark(text)
    for i,v in pairs(CoreGuiService:GetChildren()) do
        if v.Name == "watermark" then
            v:Destroy()
        end
    end
    tetx = text or "xsx v2"
    local watermark = Instance.new("ScreenGui")
    local watermarkPadding = Instance.new("UIPadding")
    local watermarkLayout = Instance.new("UIListLayout")
    local edge = Instance.new("Frame")
    local edgeCorner = Instance.new("UICorner")
    local background = Instance.new("Frame")
    local barFolder = Instance.new("Folder")
    local bar = Instance.new("Frame")
    local barCorner = Instance.new("UICorner")
    local barLayout = Instance.new("UIListLayout")
    local backgroundGradient = Instance.new("UIGradient")
    local backgroundCorner = Instance.new("UICorner")
    local waterText = Instance.new("TextLabel")
    local waterPadding = Instance.new("UIPadding")
    local backgroundLayout = Instance.new("UIListLayout")
    watermark.Name = "watermark"
    watermark.Parent = CoreGuiService
    watermark.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    watermarkLayout.Name = "watermarkLayout"
    watermarkLayout.Parent = watermark
    watermarkLayout.FillDirection = Enum.FillDirection.Horizontal
    watermarkLayout.SortOrder = Enum.SortOrder.LayoutOrder
    watermarkLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
    watermarkLayout.Padding = UDim.new(0, 4)
    watermarkPadding.Name = "watermarkPadding"
    watermarkPadding.Parent = watermark
    watermarkPadding.PaddingBottom = UDim.new(0, 6)
    watermarkPadding.PaddingLeft = UDim.new(0, 6)
    edge.Name = "edge"
    edge.Parent = watermark
    edge.AnchorPoint = Vector2.new(0.5, 0.5)
    edge.BackgroundColor3 = Color3.fromRGB(42, 42, 46)
    edge.Position = UDim2.new(0.5, 0, -0.03, 0)
    edge.Size = UDim2.new(0, 0, 0, 26)
    edge.BackgroundTransparency = 1
    edgeCorner.CornerRadius = UDim.new(0, 2)
    edgeCorner.Name = "edgeCorner"
    edgeCorner.Parent = edge
    background.Name = "background"
    background.Parent = edge
    background.AnchorPoint = Vector2.new(0.5, 0.5)
    background.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    background.BackgroundTransparency = 1
    background.ClipsDescendants = true
    background.Position = UDim2.new(0.5, 0, 0.5, 0)
    background.Size = UDim2.new(0, 0, 0, 24)
    barFolder.Name = "barFolder"
    barFolder.Parent = background
    bar.Name = "bar"
    bar.Parent = barFolder
    applyShimmer(bar)
    bar.BackgroundColor3 = Color3.fromRGB(159, 115, 255)
    bar.BackgroundTransparency = 0
    bar.Size = UDim2.new(0, 0, 0, 1)
    barCorner.CornerRadius = UDim.new(0, 2)
    barCorner.Name = "barCorner"
    barCorner.Parent = bar
    barLayout.Name = "barLayout"
    barLayout.Parent = barFolder
    barLayout.SortOrder = Enum.SortOrder.LayoutOrder
    backgroundGradient.Color = ColorSequence.new{ColorSequenceKeypoint.new(0.00, Color3.fromRGB(16, 16, 18)), ColorSequenceKeypoint.new(1.00, Color3.fromRGB(16, 16, 18))}
    backgroundGradient.Rotation = 90
    backgroundGradient.Name = "backgroundGradient"
    backgroundGradient.Parent = background
    backgroundCorner.CornerRadius = UDim.new(0, 2)
    backgroundCorner.Name = "backgroundCorner"
    backgroundCorner.Parent = background
    waterText.Name = "notifText"
    waterText.Parent = background
    waterText.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    waterText.BackgroundTransparency = 1.000
    waterText.Position = UDim2.new(0, 0, -0.0416666679, 0)
    waterText.Size = UDim2.new(0, 0, 0, 24)
    waterText.Font = Enum.Font.Code
    waterText.Text = text
    waterText.TextColor3 = Color3.fromRGB(198, 198, 198)
    waterText.TextTransparency = 1
    waterText.TextSize = 14.000
    waterText.RichText = true
    local NewSize = TextService:GetTextSize(waterText.Text, waterText.TextSize, waterText.Font, Vector2.new(math.huge, math.huge))
    waterText.Size = UDim2.new(0, NewSize.X + 8, 0, 24)
    waterPadding.Name = "notifPadding"
    waterPadding.Parent = waterText
    waterPadding.PaddingBottom = UDim.new(0, 4)
    waterPadding.PaddingLeft = UDim.new(0, 4)
    waterPadding.PaddingRight = UDim.new(0, 4)
    waterPadding.PaddingTop = UDim.new(0, 4)
    backgroundLayout.Name = "backgroundLayout"
    backgroundLayout.Parent = background
    backgroundLayout.SortOrder = Enum.SortOrder.LayoutOrder
    backgroundLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    CreateTween("wm", 0.24)
    CreateTween("wm_2", 0.04)
    coroutine.wrap(function()
        TweenService:Create(edge, TweenTable["wm"], {BackgroundTransparency = 0}):Play()
        TweenService:Create(edge, TweenTable["wm"], {Size = UDim2.new(0, NewSize.x + 10, 0, 26)}):Play()
        TweenService:Create(background, TweenTable["wm"], {BackgroundTransparency = 0}):Play()
        TweenService:Create(background, TweenTable["wm"], {Size = UDim2.new(0, NewSize.x + 8, 0, 24)}):Play()
        wait(.2)
        TweenService:Create(bar, TweenTable["wm"], {Size = UDim2.new(0, NewSize.x + 8, 0, 1)}):Play()
        wait(.1)
        TweenService:Create(waterText, TweenTable["wm"], {TextTransparency = 0}):Play()
    end)()
    local WatermarkFunctions = {}
    function WatermarkFunctions:AddWatermark(text)
        tetx = text or "xsx v2"
        local edge = Instance.new("Frame")
        local edgeCorner = Instance.new("UICorner")
        local background = Instance.new("Frame")
        local barFolder = Instance.new("Folder")
        local bar = Instance.new("Frame")
        local barCorner = Instance.new("UICorner")
        local barLayout = Instance.new("UIListLayout")
        local backgroundGradient = Instance.new("UIGradient")
        local backgroundCorner = Instance.new("UICorner")
        local waterText = Instance.new("TextLabel")
        local waterPadding = Instance.new("UIPadding")
        local backgroundLayout = Instance.new("UIListLayout")
        edge.Name = "edge"
        edge.Parent = watermark
        edge.AnchorPoint = Vector2.new(0.5, 0.5)
        edge.BackgroundColor3 = Color3.fromRGB(42, 42, 46)
        edge.Position = UDim2.new(0.5, 0, -0.03, 0)
        edge.Size = UDim2.new(0, 0, 0, 26)
        edge.BackgroundTransparency = 1
        edgeCorner.CornerRadius = UDim.new(0, 2)
        edgeCorner.Name = "edgeCorner"
        edgeCorner.Parent = edge
        background.Name = "background"
        background.Parent = edge
        background.AnchorPoint = Vector2.new(0.5, 0.5)
        background.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        background.BackgroundTransparency = 1
        background.ClipsDescendants = true
        background.Position = UDim2.new(0.5, 0, 0.5, 0)
        background.Size = UDim2.new(0, 0, 0, 24)
        barFolder.Name = "barFolder"
        barFolder.Parent = background
        bar.Name = "bar"
        bar.Parent = barFolder
    applyShimmer(bar)
        bar.BackgroundColor3 = Color3.fromRGB(159, 115, 255)
        bar.BackgroundTransparency = 0
        bar.Size = UDim2.new(0, 0, 0, 1)
        barCorner.CornerRadius = UDim.new(0, 2)
        barCorner.Name = "barCorner"
        barCorner.Parent = bar
        barLayout.Name = "barLayout"
        barLayout.Parent = barFolder
        barLayout.SortOrder = Enum.SortOrder.LayoutOrder
        backgroundGradient.Color = ColorSequence.new{ColorSequenceKeypoint.new(0.00, Color3.fromRGB(16, 16, 18)), ColorSequenceKeypoint.new(1.00, Color3.fromRGB(16, 16, 18))}
        backgroundGradient.Rotation = 90
        backgroundGradient.Name = "backgroundGradient"
        backgroundGradient.Parent = background
        backgroundCorner.CornerRadius = UDim.new(0, 2)
        backgroundCorner.Name = "backgroundCorner"
        backgroundCorner.Parent = background
        waterText.Name = "notifText"
        waterText.Parent = background
        waterText.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        waterText.BackgroundTransparency = 1.000
        waterText.Position = UDim2.new(0, 0, -0.0416666679, 0)
        waterText.Size = UDim2.new(0, 0, 0, 24)
        waterText.Font = Enum.Font.Code
        waterText.Text = text
        waterText.TextColor3 = Color3.fromRGB(198, 198, 198)
        waterText.TextTransparency = 1
        waterText.TextSize = 14.000
        waterText.RichText = true
        local NewSize = TextService:GetTextSize(waterText.Text, waterText.TextSize, waterText.Font, Vector2.new(math.huge, math.huge))
        waterText.Size = UDim2.new(0, NewSize.X + 8, 0, 24)
        waterPadding.Name = "notifPadding"
        waterPadding.Parent = waterText
        waterPadding.PaddingBottom = UDim.new(0, 4)
        waterPadding.PaddingLeft = UDim.new(0, 4)
        waterPadding.PaddingRight = UDim.new(0, 4)
        waterPadding.PaddingTop = UDim.new(0, 4)
        backgroundLayout.Name = "backgroundLayout"
        backgroundLayout.Parent = background
        backgroundLayout.SortOrder = Enum.SortOrder.LayoutOrder
        backgroundLayout.VerticalAlignment = Enum.VerticalAlignment.Center
        coroutine.wrap(function()
            TweenService:Create(edge, TweenTable["wm"], {BackgroundTransparency = 0}):Play()
            TweenService:Create(edge, TweenTable["wm"], {Size = UDim2.new(0, NewSize.x + 10, 0, 26)}):Play()
            TweenService:Create(background, TweenTable["wm"], {BackgroundTransparency = 0}):Play()
            TweenService:Create(background, TweenTable["wm"], {Size = UDim2.new(0, NewSize.x + 8, 0, 24)}):Play()
            wait(.2)
            TweenService:Create(bar, TweenTable["wm"], {Size = UDim2.new(0, NewSize.x + 8, 0, 1)}):Play()
            wait(.1)
            TweenService:Create(waterText, TweenTable["wm"], {TextTransparency = 0}):Play()
        end)()
        local NewWatermarkFunctions = {}
        function NewWatermarkFunctions:Hide()
            edge.Visible = false
            return NewWatermarkFunctions
        end
        function NewWatermarkFunctions:Show()
            edge.Visible = true
            return NewWatermarkFunctions
        end
        function NewWatermarkFunctions:Text(new)
            new = new or text
            waterText.Text = new
            local NewSize = TextService:GetTextSize(waterText.Text, waterText.TextSize, waterText.Font, Vector2.new(math.huge, math.huge))
            waterText.Size = UDim2.new(0, NewSize.X + 8, 0, 24)
            coroutine.wrap(function()
                TweenService:Create(edge, TweenTable["wm_2"], {Size = UDim2.new(0, NewSize.x + 10, 0, 26)}):Play()
                TweenService:Create(background, TweenTable["wm_2"], {Size = UDim2.new(0, NewSize.x + 8, 0, 24)}):Play()
                TweenService:Create(bar, TweenTable["wm_2"], {Size = UDim2.new(0, NewSize.x + 8, 0, 1)}):Play()
                TweenService:Create(waterText, TweenTable["wm_2"], {Size = UDim2.new(0, NewSize.x + 8, 0, 1)}):Play()
            end)()
            return NewWatermarkFunctions
        end
        function NewWatermarkFunctions:Remove()
            Watermark:Destroy()
            return NewWatermarkFunctions
        end
        return NewWatermarkFunctions
    end
    function WatermarkFunctions:Hide()
        edge.Visible = false
        return WatermarkFunctions
    end
    function WatermarkFunctions:Show()
        edge.Visible = true
        return WatermarkFunctions
    end
    function WatermarkFunctions:Text(new)
        new = new or text
        waterText.Text = new
        local NewSize = TextService:GetTextSize(waterText.Text, waterText.TextSize, waterText.Font, Vector2.new(math.huge, math.huge))
        coroutine.wrap(function()
            TweenService:Create(edge, TweenTable["wm_2"], {Size = UDim2.new(0, NewSize.x + 10, 0, 26)}):Play()
            TweenService:Create(background, TweenTable["wm_2"], {Size = UDim2.new(0, NewSize.x + 8, 0, 24)}):Play()
            TweenService:Create(bar, TweenTable["wm_2"], {Size = UDim2.new(0, NewSize.x + 8, 0, 1)}):Play()
            TweenService:Create(waterText, TweenTable["wm_2"], {Size = UDim2.new(0, NewSize.x + 8, 0, 1)}):Play()
        end)()
        return WatermarkFunctions
    end
    function WatermarkFunctions:Remove()
        Watermark:Destroy()
        return WatermarkFunctions
    end
    return WatermarkFunctions
end
function library:InitNotifications(text, duration, callback)
    for i,v in next, CoreGuiService:GetChildren() do
        if v.name == "Notifications" then
            v:Destroy()
        end
    end
    local Notifications = Instance.new("ScreenGui")
    local notificationsLayout = Instance.new("UIListLayout")
    local notificationsPadding = Instance.new("UIPadding")
    Notifications.Name = "Notifications"
    Notifications.Parent = CoreGuiService
    Notifications.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    notificationsLayout.Name = "notificationsLayout"
    notificationsLayout.Parent = Notifications
    notificationsLayout.FillDirection = Enum.FillDirection.Vertical
    notificationsLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
    notificationsLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
    notificationsLayout.SortOrder = Enum.SortOrder.LayoutOrder
    notificationsLayout.Padding = UDim.new(0, 4)
    notificationsPadding.Name = "notificationsPadding"
    notificationsPadding.Parent = Notifications
    notificationsPadding.PaddingRight = UDim.new(0, 12)
    notificationsPadding.PaddingBottom = UDim.new(0, 12)
    notificationsPadding.PaddingLeft = UDim.new(0, 0)
    notificationsPadding.PaddingTop = UDim.new(0, 0)
    local Notification = {}
    function Notification:Notify(text, duration, notifType, callback)
        CreateTween("notification_load", 0.2)
        text = tostring(text or "please wait.")
        if typeof(duration) ~= "number" or duration ~= duration or duration <= 0 then
            duration = 3
        end
        if typeof(notifType) ~= "string" then
            notifType = "notification"
        end
        callback = (typeof(callback) == "function") and callback or function() end
        local edge = Instance.new("Frame")
        local edgeCorner = Instance.new("UICorner")
        local background = Instance.new("Frame")
        local barFolder = Instance.new("Folder")
        local bar = Instance.new("Frame")
        local barCorner = Instance.new("UICorner")
        local barLayout = Instance.new("UIListLayout")
        local backgroundGradient = Instance.new("UIGradient")
        local backgroundCorner = Instance.new("UICorner")
        local notifText = Instance.new("TextLabel")
        local notifPadding = Instance.new("UIPadding")
        local backgroundLayout = Instance.new("UIListLayout")
        edge.Name = "edge"
        edge.Parent = Notifications
        edge.BackgroundColor3 = Color3.fromRGB(42, 42, 46)
        edge.BackgroundTransparency = 1.000
        edge.Size = UDim2.new(0, 0, 0, 26)
        edgeCorner.CornerRadius = UDim.new(0, 2)
        edgeCorner.Name = "edgeCorner"
        edgeCorner.Parent = edge
        background.Name = "background"
        background.Parent = edge
        background.AnchorPoint = Vector2.new(0.5, 0.5)
        background.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        background.BackgroundTransparency = 1.000
        background.ClipsDescendants = true
        background.Position = UDim2.new(0.5, 0, 0.5, 0)
        background.Size = UDim2.new(0, 0, 0, 24)
        barFolder.Name = "barFolder"
        barFolder.Parent = background
        bar.Name = "bar"
        bar.Parent = barFolder
        applyShimmer(bar)
        bar.BackgroundColor3 = Color3.fromRGB(159, 115, 255)
        bar.BackgroundTransparency = 0.200
        bar.Size = UDim2.new(0, 0, 0, 1)
        if notifType == "notification" then
            bar.BackgroundColor3 = Color3.fromRGB(159, 115, 255)
        elseif notifType == "alert" then
            bar.BackgroundColor3 = Color3.fromRGB(255, 246, 112)
        elseif notifType == "error" then
            bar.BackgroundColor3 = Color3.fromRGB(255, 74, 77)
        elseif notifType == "success" then
            bar.BackgroundColor3 = Color3.fromRGB(131, 255, 103)
        elseif notifType == "information" then
            bar.BackgroundColor3 = Color3.fromRGB(159, 115, 255)
        end
        barCorner.CornerRadius = UDim.new(0, 2)
        barCorner.Name = "barCorner"
        barCorner.Parent = bar
        barLayout.Name = "barLayout"
        barLayout.Parent = barFolder
        barLayout.SortOrder = Enum.SortOrder.LayoutOrder
        backgroundGradient.Color = ColorSequence.new{ColorSequenceKeypoint.new(0.00, Color3.fromRGB(16, 16, 18)), ColorSequenceKeypoint.new(1.00, Color3.fromRGB(16, 16, 18))}
        backgroundGradient.Rotation = 90
        backgroundGradient.Name = "backgroundGradient"
        backgroundGradient.Parent = background
        backgroundCorner.CornerRadius = UDim.new(0, 2)
        backgroundCorner.Name = "backgroundCorner"
        backgroundCorner.Parent = background
        notifText.Name = "notifText"
        notifText.Parent = background
        notifText.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        notifText.BackgroundTransparency = 1.000
        notifText.Size = UDim2.new(0, 230, 0, 26)
        notifText.Font = Enum.Font.Code
        notifText.Text = text
        notifText.TextColor3 = Color3.fromRGB(198, 198, 198)
        notifText.TextSize = 14.000
        notifText.TextTransparency = 1.000
        notifText.TextXAlignment = Enum.TextXAlignment.Left
        notifText.RichText = true
        notifPadding.Name = "notifPadding"
        notifPadding.Parent = notifText
        notifPadding.PaddingBottom = UDim.new(0, 4)
        notifPadding.PaddingLeft = UDim.new(0, 4)
        notifPadding.PaddingRight = UDim.new(0, 4)
        notifPadding.PaddingTop = UDim.new(0, 4)
        backgroundLayout.Name = "backgroundLayout"
        backgroundLayout.Parent = background
        backgroundLayout.SortOrder = Enum.SortOrder.LayoutOrder
        backgroundLayout.VerticalAlignment = Enum.VerticalAlignment.Center
        local NewSize = TextService:GetTextSize(notifText.Text, notifText.TextSize, notifText.Font, Vector2.new(math.huge, math.huge))
        CreateTween("notification_wait", duration, Enum.EasingStyle.Quad)
        local IsRunning = false
        coroutine.wrap(function()
            IsRunning = true
            TweenService:Create(edge, TweenTable["notification_load"], {BackgroundTransparency = 0}):Play()
            TweenService:Create(background, TweenTable["notification_load"], {BackgroundTransparency = 0}):Play()
            TweenService:Create(notifText, TweenTable["notification_load"], {TextTransparency = 0}):Play()
            TweenService:Create(edge, TweenTable["notification_load"], {Size = UDim2.new(0, NewSize.X + 10, 0, 26)}):Play()
            TweenService:Create(background, TweenTable["notification_load"], {Size = UDim2.new(0, NewSize.X + 8, 0, 24)}):Play()
            TweenService:Create(notifText, TweenTable["notification_load"], {Size = UDim2.new(0, NewSize.X + 8, 0, 24)}):Play()
            wait()
            TweenService:Create(bar, TweenTable["notification_wait"], {Size = UDim2.new(0, NewSize.X + 8, 0, 1)}):Play()
            repeat wait() until bar.Size == UDim2.new(0, NewSize.X + 8, 0, 1)
            IsRunning = false
            TweenService:Create(edge, TweenTable["notification_load"], {BackgroundTransparency = 1}):Play()
            TweenService:Create(background, TweenTable["notification_load"], {BackgroundTransparency = 1}):Play()
            TweenService:Create(notifText, TweenTable["notification_load"], {TextTransparency = 1}):Play()
            TweenService:Create(bar, TweenTable["notification_load"], {BackgroundTransparency = 1}):Play()
            TweenService:Create(edge, TweenTable["notification_load"], {Size = UDim2.new(0, 0, 0, 26)}):Play()
            TweenService:Create(background, TweenTable["notification_load"], {Size = UDim2.new(0, 0, 0, 24)}):Play()
            TweenService:Create(notifText, TweenTable["notification_load"], {Size = UDim2.new(0, 0, 0, 24)}):Play()
            TweenService:Create(bar, TweenTable["notification_load"], {Size = UDim2.new(0, 0, 0, 1)}):Play()
            wait(.2)
            edge:Destroy()
        end)()
        CreateTween("notification_reset", 0.4)
        local NotificationFunctions = {}
        function NotificationFunctions:Text(new)
            new = new or text
            notifText.Text = new
            NewSize = TextService:GetTextSize(notifText.Text, notifText.TextSize, notifText.Font, Vector2.new(math.huge, math.huge))
            local NewSize_2 = NewSize
            if IsRunning then
                TweenService:Create(edge, TweenTable["notification_load"], {Size = UDim2.new(0, NewSize.X + 10, 0, 26)}):Play()
                TweenService:Create(background, TweenTable["notification_load"], {Size = UDim2.new(0, NewSize.X + 8, 0, 24)}):Play()
                TweenService:Create(notifText, TweenTable["notification_load"], {Size = UDim2.new(0, NewSize.X + 8, 0, 24)}):Play()
                wait()
                TweenService:Create(bar, TweenTable["notification_reset"], {Size = UDim2.new(0, 0, 0, 1)}):Play()
                wait(.4)
                TweenService:Create(bar, TweenTable["notification_wait"], {Size = UDim2.new(0, NewSize.X + 8, 0, 1)}):Play()
            end
            return NotificationFunctions
        end
        return NotificationFunctions
    end
    return Notification
end
function library:Introduction()
    for _,v in next, CoreGuiService:GetChildren() do
        if v.Name == "screen" then
            v:Destroy()
        end
    end
    CreateTween("introduction",0.175)
    local introduction = Instance.new("ScreenGui")
    local edge = Instance.new("Frame")
    local edgeCorner = Instance.new("UICorner")
    local background = Instance.new("Frame")
    local backgroundGradient = Instance.new("UIGradient")
    local backgroundCorner = Instance.new("UICorner")
    local barFolder = Instance.new("Folder")
    local bar = Instance.new("Frame")
    local barCorner = Instance.new("UICorner")
    local barLayout = Instance.new("UIListLayout")
    local xsxLogo = Instance.new("ImageLabel")
    local hashLogo = Instance.new("ImageLabel")
    local xsx = Instance.new("TextLabel")
    local text = Instance.new("TextLabel")
    local pageLayout = Instance.new("UIListLayout")
    introduction.Name = "introduction"
    introduction.Parent = CoreGuiService
    introduction.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    edge.Name = "edge"
    edge.Parent = introduction
    edge.AnchorPoint = Vector2.new(0.5, 0.5)
    edge.BackgroundColor3 = Color3.fromRGB(42, 42, 46)
    edge.BackgroundTransparency = 1
    edge.Position = UDim2.new(0.511773348, 0, 0.5, 0)
    edge.Size = UDim2.new(0, 300, 0, 308)
    edgeCorner.CornerRadius = UDim.new(0, 2)
    edgeCorner.Name = "edgeCorner"
    edgeCorner.Parent = edge
    background.Name = "background"
    background.Parent = edge
    background.AnchorPoint = Vector2.new(0.5, 0.5)
    background.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    background.BackgroundTransparency = 1
    background.ClipsDescendants = true
    background.Position = UDim2.new(0.5, 0, 0.5, 0)
    background.Size = UDim2.new(0, 298, 0, 306)
    backgroundGradient.Color = ColorSequence.new{ColorSequenceKeypoint.new(0.00, Color3.fromRGB(16, 16, 18)), ColorSequenceKeypoint.new(1.00, Color3.fromRGB(16, 16, 18))}
    backgroundGradient.Rotation = 90
    backgroundGradient.Name = "backgroundGradient"
    backgroundGradient.Parent = background
    backgroundCorner.CornerRadius = UDim.new(0, 2)
    backgroundCorner.Name = "backgroundCorner"
    backgroundCorner.Parent = background
    barFolder.Name = "barFolder"
    barFolder.Parent = background
    bar.Name = "bar"
    bar.Parent = barFolder
    applyShimmer(bar)
    bar.BackgroundColor3 = Color3.fromRGB(159, 115, 255)
    bar.BackgroundTransparency = 0.200
    bar.Size = UDim2.new(0, 0, 0, 1)
    barCorner.CornerRadius = UDim.new(0, 2)
    barCorner.Name = "barCorner"
    barCorner.Parent = bar
    barLayout.Name = "barLayout"
    barLayout.Parent = barFolder
    barLayout.HorizontalAlignment = Enum.HorizontalAlignment.C
