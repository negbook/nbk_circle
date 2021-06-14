minimap={posX=-0.0045		,posY=0.002		,sizeX=0.150		,sizeY=0.188888*1.33}
minimap_mask={posX=0.020		,posY=0.032 	 	,sizeX=0.111		,sizeY=0.159*1.33}
minimap_blur={posX=-0.03		,posY=0.022		,sizeX=0.266		,sizeY=0.237*1.33}

Citizen.CreateThread(function()
	RequestStreamedTextureDict("circlemap", false)
	while not HasStreamedTextureDictLoaded("circlemap") do
		Wait(100)
	end

	AddReplaceTexture("platform:/textures/graphics", "radarmasksm", "circlemap", "radarmasksm")

	SetMinimapClipType(1)
	SetMinimapComponentPosition('minimap', 'L', 'B', minimap.posX, minimap.posY, minimap.sizeX, minimap.sizeY)
	SetMinimapComponentPosition('minimap_mask', 'L', 'B', minimap_mask.posX, minimap_mask.posY, minimap_mask.sizeX, minimap_mask.sizeY)
    SetMinimapComponentPosition('minimap_blur', 'L', 'B', minimap_blur.posX, minimap_blur.posY, minimap_blur.sizeX, minimap_blur.sizeY)

    local minimap = RequestScaleformMovie("minimap")
    SetRadarBigmapEnabled(true, false)
    Wait(0)
    SetRadarBigmapEnabled(false, false)

    while true do
        Wait(0)
        BeginScaleformMovieMethod(minimap, "SETUP_HEALTH_ARMOUR")
        ScaleformMovieMethodAddParamInt(3)
        EndScaleformMovieMethod()
    end
end)


