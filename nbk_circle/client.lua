--frontend.xml
minimap={posX=-0.0045		,posY=0.002		,sizeX=0.150		,sizeY=0.188888}
minimap_mask={posX=0.020		,posY=0.032 	 	,sizeX=0.111		,sizeY=0.159}
minimap_blur={posX=-0.03		,posY=0.022		,sizeX=0.266		,sizeY=0.237}

CreateThread(function()
    RequestStreamedTextureDict("nbk_circlemap_full", false)
	while not HasStreamedTextureDictLoaded("nbk_circlemap_full") do
		Wait(100)
	end
    
	AddReplaceTexture("platform:/textures/graphics", "radarmasksm", "nbk_circlemap_full", "radarmasksm_circle_noblur")
                                                                                            --radarmasksm,radarmasksm_circle_blur,radarmasksm_circle_noblur
	SetMinimapClipType(1)
	SetMinimapComponentPosition('minimap', 'L', 'B', minimap.posX, minimap.posY, minimap.sizeX, minimap.sizeY*1.33)
	SetMinimapComponentPosition('minimap_mask', 'L', 'B', minimap_mask.posX, minimap_mask.posY, minimap_mask.sizeX, minimap_mask.sizeY*1.33)
    SetMinimapComponentPosition('minimap_blur', 'L', 'B', minimap_blur.posX, minimap_blur.posY, minimap_blur.sizeX, minimap_blur.sizeY*1.33)

    
    local minimap = RequestScaleformMovie("minimap")
    Wait(32)
    SetRadarBigmapEnabled(true, false)
    Wait(32)
    SetRadarBigmapEnabled(false, false)
    Wait(32)

        while true do
            Wait(0)
            BeginScaleformMovieMethod(minimap, "SETUP_HEALTH_ARMOUR")
            ScaleformMovieMethodAddParamInt(3)
            EndScaleformMovieMethod()
        end

end)

function GetMinimapAnchor()
    -- Safezone goes from 1.0 (no gap) to 0.9 (5% gap (1/20))
    -- 0.05 * ((safezone - 0.9) * 10)
    local safezone = GetSafeZoneSize()
    local safezone_x = 1.0 / 20.0
    local safezone_y = 1.0 / 20.0
    local aspect_ratio = GetAspectRatio(0)
    local res_x, res_y = GetActiveScreenResolution()
    local xscale = 1.0 / res_x
    local yscale = 1.0 / res_y
    local Minimap = {}
    Minimap.width = xscale * (res_x / (3.9 * aspect_ratio))
    Minimap.height = yscale * (res_y / 6.0) *1.33
    SetScriptGfxAlign(string.byte('L'), string.byte('B')) --https://forum.cfx.re/t/useful-snippet-getting-the-top-left-of-the-minimap-in-screen-coordinates/712843
    Minimap.left_x, Minimap.top_y = GetScriptGfxPosition(-0.0045+0.002, (0.002 + (-0.188888)+0.002)*1.33)
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


