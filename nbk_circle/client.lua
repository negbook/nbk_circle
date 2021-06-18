--negbook 24*30 hours made it 
local minimap_main_pixel_width = 191- 10
local minimap_main_pixel_height = 136 - 10

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
        if isCircleReady and not IsPauseMenuActive() then 
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
        if isCircleInited and not IsPauseMenuActive() then 
        BeginScaleformMovieMethod(minimap, "HIDE_SATNAV")
        EndScaleformMovieMethod()
        BeginScaleformMovieMethod(minimap, "SETUP_HEALTH_ARMOUR")
        ScaleformMovieMethodAddParamInt(3)
        EndScaleformMovieMethod()
        end 
    end
    isCircleInited = false 
end)
local function InitCircle(offsetx,offsety,noblur,scale)
    offsetx = offsetx or 0.0 
    offsety = offsety or 0.0
    isCircleReady = false
    isCircleMode = true 
    scale = scale or 1.0
    CreateThread(function()
        RequestStreamedTextureDict("nbk_radarmasksm_full", false)
        while not HasStreamedTextureDictLoaded("nbk_radarmasksm_full") do
            Wait(100)
        end
        
        AddReplaceTexture("platform:/textures/graphics", "radarmasksm", "nbk_radarmasksm_full", noblur and 'radarmasksm_circle_noblur' or "radarmasksm_circle_blur")
                                                                                                --radarmasksm,radarmasksm_circle_blur,radarmasksm_circle_noblur
        SetMinimapClipType(1)
      
        SetMinimapComponentPosition('minimap', 'L', 'B', minimap_main.posX        + offsetx  , minimap_main.posY   +offsety, scale * minimap_main.sizeX, scale * minimap_main.sizeY*(minimap_main_pixel_width/minimap_main_pixel_height))
        SetMinimapComponentPosition('minimap_mask', 'L', 'B', minimap_mask.posX   + offsetx, minimap_mask.posY     +offsety, scale * minimap_mask.sizeX, scale * minimap_mask.sizeY*(minimap_main_pixel_width/minimap_main_pixel_height))
        SetMinimapComponentPosition('minimap_blur', 'L', 'B', minimap_blur.posX   + offsetx, minimap_blur.posY     +offsety, scale * minimap_blur.sizeX, scale * minimap_blur.sizeY*(minimap_main_pixel_width/minimap_main_pixel_height))
        isCircleReady = true 
        return 
    end)
end 
local function InitNormal()
    isCircleReady = false
    isCircleMode = true 
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

        isCircleReady = true 
        return
    end)
end 
local function GetMinimapAnchor(offsetx,offsety,scale) --https://forum.cfx.re/t/release-utility-minimap-anchor-script/81912
--MINIMAP ANCHOR BY GLITCHDETECTOR (Feb 16 2018 version)
    -- Safezone goes from 1.0 (no gap) to 0.9 (5% gap (1/20))
    -- 0.05 * ((safezone - 0.9) * 10)
    offsetx = offsetx or 0.0 
    offsety = offsety or 0.0
    
    --negbook 24*3 hours made it 
    local safezone = GetSafeZoneSize()
    local safezone_x = 1.0 / 20.0
    local safezone_y = 1.0 / 20.0
    local aspect_ratio = GetAspectRatio(0)
    local res_x, res_y = GetActiveScreenResolution()
    local xscale = 1.0 / res_x
    local yscale = 1.0 / res_y
    local Minimap = {}
    k1 = scale == 1.0 and 3.75 or 3.75 - scale * minimap_main.sizeX
    k2 = scale == 1.0 and 5.8 or 5.8 + scale * minimap_main.sizeY
    Minimap.width = scale * xscale * (res_x / (k1 * aspect_ratio))
    Minimap.height = scale * yscale * (res_y / k2) * (isCircleMode and (minimap_main_pixel_width/minimap_main_pixel_height) or 1.00)
    SetScriptGfxAlign(string.byte('L'), string.byte('B')) 
    --https://forum.cfx.re/t/useful-snippet-getting-the-top-left-of-the-minimap-in-screen-coordinates/712843
    --https://cookbook.fivem.net/2019/08/12/useful-snippet-getting-the-top-left-of-the-minimap-in-screen-coordinates/
    Minimap.left_x, Minimap.top_y = GetScriptGfxPosition(minimap_main.posX+offsetx*(Minimap.width/(scale * minimap_main.sizeX)), (offsety + (minimap_main.posY) + ((-scale * minimap_main.sizeY)* (isCircleMode and (minimap_main_pixel_width/minimap_main_pixel_height) or 1.00))) )
    --negbook 24*3 hours made it 
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

function GetHudDimensionsByMinimapAnchor(inputWidth,inputHeight,offsetx,offsety,scale)
    offsetx = offsetx or 0.0 
    offsety = offsety or 0.0
    local mui = GetMinimapAnchor(offsetx,offsety,scale)
    local Hud = {}
    
    Hud.width = inputWidth/((minimap_main_pixel_width)/mui.width)
    Hud.height = inputHeight/((minimap_main_pixel_height)/mui.height)
    Hud.x = mui.x-((Hud.width-mui.width)/2) + Hud.width/2
    Hud.y = mui.y-((Hud.height-mui.height)/2) + Hud.height/2
    return Hud
end 

RegisterNetEvent("nbk_circle:RequestHudDimensionsFromMyUI")
AddEventHandler('nbk_circle:RequestHudDimensionsFromMyUI', function(inputWidth,inputHeight,cb,offsetx,offsety,noblur,scale)
    offsetx = offsetx or 0.0 
    offsety = offsety or 0.0
    InitCircle(offsetx,offsety,noblur,scale)
    cb(GetHudDimensionsByMinimapAnchor(inputWidth,inputHeight,offsetx,offsety,scale))
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
    InitCircle()
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


--]]