--frontend.xml
local minimap_main={posX=-0.0045		,posY=0.002		,sizeX=0.150		,sizeY=0.188888}
local minimap_mask={posX=0.020		,posY=0.032 	 	,sizeX=0.111		,sizeY=0.159}
local minimap_blur={posX=-0.03		,posY=0.022		,sizeX=0.266		,sizeY=0.237}
local olddata,newdata = {},{}
local isCircleMode = true 
local isCircleReady = false 
local isCircleInited = false 
local minimap = nil 

CreateThread(function()
    while true do 
        Wait(0)
        if isCircleReady then 
            minimap = RequestScaleformMovie("minimap")
            Wait(32)
            SetRadarBigmapEnabled(true, false)
            Wait(32)
            SetRadarBigmapEnabled(false, false)
            Wait(32)
            isCircleReady = false 
            isCircleInited = true 
        end 
    end 
end)
CreateThread(function()
    while true do 
        Wait(0)
        minimap = RequestScaleformMovie("minimap")
        Wait(32)
        SetRadarBigmapEnabled(true, false)
        Wait(32)
        SetRadarBigmapEnabled(false, false)
        Wait(32)
        
        while true do
            Wait(0)
            if isCircleInited then 
            BeginScaleformMovieMethod(minimap, "HIDE_SATNAV")
            EndScaleformMovieMethod()
            BeginScaleformMovieMethod(minimap, "SETUP_HEALTH_ARMOUR")
            ScaleformMovieMethodAddParamInt(3)
            EndScaleformMovieMethod()
            end 
        end
        isCircleInited = false 
    end 
end)
local function InitCircle(offsetx,offsety)
    offsetx = offsetx or 0.0 
    offsety = offsety or 0.0
    isCircleReady = false
    isCircleMode = true 
    CreateThread(function()
        RequestStreamedTextureDict("nbk_radarmasksm_full", false)
        while not HasStreamedTextureDictLoaded("nbk_radarmasksm_full") do
            Wait(100)
        end
        
        AddReplaceTexture("platform:/textures/graphics", "radarmasksm", "nbk_radarmasksm_full", "radarmasksm_circle_blur")
                                                                                                --radarmasksm,radarmasksm_circle_blur,radarmasksm_circle_noblur
        SetMinimapClipType(1)
      
        SetMinimapComponentPosition('minimap', 'L', 'B', minimap_main.posX        + offsetx  , minimap_main.posY   +offsety, minimap_main.sizeX, minimap_main.sizeY*1.33)
        SetMinimapComponentPosition('minimap_mask', 'L', 'B', minimap_mask.posX   + offsetx, minimap_mask.posY     +offsety, minimap_mask.sizeX, minimap_mask.sizeY*1.33)
        SetMinimapComponentPosition('minimap_blur', 'L', 'B', minimap_blur.posX   + offsetx, minimap_blur.posY     +offsety, minimap_blur.sizeX, minimap_blur.sizeY*1.33)
        isCircleReady = true 
        return 
    end)
end 
local function InitNormal()
    isCircleMode = false 
    CreateThread(function()
        RequestStreamedTextureDict("nbk_radarmasksm_full", false)
        while not HasStreamedTextureDictLoaded("nbk_radarmasksm_full") do
            Wait(100)
        end
        
        AddReplaceTexture("platform:/textures/graphics", "radarmasksm", "nbk_radarmasksm_full", "radarmasksm")
                                                                                                --radarmasksm,radarmasksm_circle_blur,radarmasksm_circle_noblur
        SetMinimapClipType(1)
        SetMinimapComponentPosition('minimap', 'L', 'B', minimap_main.posX, minimap_main.posY, minimap_main.sizeX, minimap_main.sizeY)
        SetMinimapComponentPosition('minimap_mask', 'L', 'B', minimap_mask.posX, minimap_mask.posY, minimap_mask.sizeX, minimap_mask.sizeY)
        SetMinimapComponentPosition('minimap_blur', 'L', 'B', minimap_blur.posX, minimap_blur.posY, minimap_blur.sizeX, minimap_blur.sizeY)

        
        local minimap = RequestScaleformMovie("minimap")
        Wait(32)
        SetRadarBigmapEnabled(true, false)
        Wait(32)
        SetRadarBigmapEnabled(false, false)
        Wait(32)
        return
    end)
end 
local function GetMinimapAnchor(offsetx,offsety) --https://forum.cfx.re/t/release-utility-minimap-anchor-script/81912
    -- Safezone goes from 1.0 (no gap) to 0.9 (5% gap (1/20))
    -- 0.05 * ((safezone - 0.9) * 10)
    offsetx = offsetx or 0.0 
    offsety = offsety or 0.0
    local safezone = GetSafeZoneSize()
    local safezone_x = 1.0 / 20.0
    local safezone_y = 1.0 / 20.0
    local aspect_ratio = GetAspectRatio(0)
    local res_x, res_y = GetActiveScreenResolution()
    local xscale = 1.0 / res_x
    local yscale = 1.0 / res_y
    local Minimap = {}
    Minimap.width = xscale * (res_x / (3.8 * aspect_ratio))
    Minimap.height = yscale * (res_y / 5.8) * (isCircleMode and 1.33 or 1.00)
    SetScriptGfxAlign(string.byte('L'), string.byte('B')) --https://forum.cfx.re/t/useful-snippet-getting-the-top-left-of-the-minimap-in-screen-coordinates/712843
    Minimap.left_x, Minimap.top_y = GetScriptGfxPosition(minimap_main.posX+offsetx, (minimap_main.posY+offsety + (-minimap_main.sizeY))* (isCircleMode and 1.33 or 1.00))
    ResetScriptGfxAlign()
    --Minimap.left_x = xscale * (res_x * (safezone_x * ((math.abs(safezone - 1.0)) * 10)))
    Minimap.bottom_y = 1.0 - yscale * (res_y * (safezone_y * ((math.abs(safezone - 1.0)) * 10)))
    Minimap.right_x = Minimap.left_x + Minimap.width
    --Minimap.top_y = Minimap.bottom_y - Minimap.height
    Minimap.x = Minimap.left_x
    Minimap.y = Minimap.top_y
    Minimap.xunit = xscale
    Minimap.yunit = yscale
    return Minimap
end

function GetHudDimensionsByMinimapAnchor(inputWidth,inputHeight,offsetx,offsety)
    offsetx = offsetx or 0.0 
    offsety = offsety or 0.0
    local mui = GetMinimapAnchor(offsetx,offsety)
    local Hud = {}
    
    Hud.width = inputWidth/(191/mui.width)
    Hud.height = inputHeight/(136/mui.height)
    Hud.x = mui.x-((Hud.width-mui.width)/2) + Hud.width/2
    Hud.y = mui.y-((Hud.height-mui.height)/2) + Hud.height/2
    return Hud
end 

RegisterNetEvent("nbk_circle:RequestHudDimensionsFromMyUI")
AddEventHandler('nbk_circle:RequestHudDimensionsFromMyUI', function(inputWidth,inputHeight,cb,offsetx,offsety)
    offsetx = offsetx or 0.0 
    offsety = offsety or 0.0
    InitCircle(offsetx,offsety)
    cb(GetHudDimensionsByMinimapAnchor(inputWidth,inputHeight,offsetx,offsety))
end)

local oldResolution1 = nil 
local oldResolution2 = nil 
local oldAR = nil 
local oldBigmapActive = nil 
local oldMinimapRendering = nil 
function CheckChanges()
	local ASR1,ASR2 = GetActiveScreenResolution()
    local AR = GetAspectRatio(0)
    local nowResolution1  = ASR1
    local nowResolution2  = ASR2
    local nowAR  = AR
    
    local nowBigmapActive  = IsBigmapActive()
    local nowMinimapRendering  = IsMinimapRendering()
    local update = function()
        oldResolution1 = nowResolution1
        oldResolution2 = nowResolution2
        oldAR = nowAR
        oldBigmapActive = nowBigmapActive
        oldMinimapRendering = nowMinimapRendering
		TriggerEvent('nbk_circle:OnMinimapRefresh',nowBigmapActive,nowMinimapRendering)
    end 
	if oldResolution1 ~= nowResolution1 then 
		update()
	elseif oldResolution2 ~= nowResolution2 then 
		update()
    elseif oldAR ~= nowAR then 
		update()
    elseif oldBigmapActive ~= nowBigmapActive then 
		update()
    elseif oldMinimapRendering ~= nowMinimapRendering then 
		update()
	end 
end
CreateThread(function()
    
    while true do Wait(332)
        CheckChanges()
    end 
end)

--[[
function drawRct(x, y, width, height, r, g, b, a)
    DrawRect(x + width/2, y + height/2, width, height, r, g, b, a)
end
Citizen.CreateThread(function()
    while true do
        Wait(0)
        local ui = GetMinimapAnchor()
        local thickness = 1 -- Defines how many pixels wide the border is
        drawRct(ui.x, ui.y, ui.width, thickness * ui.yunit, 0, 0, 0, 255)
        drawRct(ui.x, ui.y + ui.height, ui.width, -thickness * ui.yunit, 0, 0, 0, 255)
        drawRct(ui.x, ui.y, thickness * ui.xunit, ui.height, 0, 0, 0, 255)
        drawRct(ui.x + ui.width, ui.y, -thickness * ui.xunit, ui.height, 0, 0, 0, 255)
    end
end)
]]--

