
NUM_WORLDMAP_POIS = 0;
NUM_WORLDMAP_WORLDEFFECT_POIS = 0;
NUM_WORLDMAP_SCENARIO_POIS = 0;
NUM_WORLDMAP_TASK_POIS = 0;
NUM_WORLDMAP_GRAVEYARDS = 0;
NUM_WORLDMAP_OVERLAYS = 0;
NUM_WORLDMAP_DEBUG_ZONEMAP = 0;
NUM_WORLDMAP_DEBUG_OBJECTS = 0;

WORLDMAP_COSMIC_ID = 946;
WORLDMAP_AZEROTH_ID = 947;
WORLDMAP_OUTLAND_ID = 101;
WORLDMAP_DRAENOR_ID = 572;
WORLDMAP_BROKEN_ISLES_ID = 619;
WORLDMAP_ARGUS_ID = 905;

MAELSTROM_ZONES_ID = { TheMaelstrom = 737, Deepholm = 640, Kezan = 605, TheLostIsles = 544 };
MAELSTROM_ZONES_LEVELS = {
				TheMaelstrom = {minLevel = 0, maxLevel = 0},
				Deepholm = {minLevel = 82, maxLevel = 83, petMinLevel= 22, petMaxLevel = 23},
				Kezan = {minLevel = 1, maxLevel = 5},
				TheLostIsles = {minLevel = 5, maxLevel = 12} };
WORLDMAP_WINTERGRASP_ID = 501;
WORLDMAP_WINTERGRASP_POI_AREAID = 4197;
WORLDMAP_WINDOWED_SIZE = 0.695;		-- size corresponds to ratio value
WORLDMAP_FULLMAP_SIZE = 1.0;
local EJ_QUEST_POI_MINDIS_SQR = 2500;

local QUEST_POI_FRAME_INSET = 12;		-- roughly half the width/height of a POI icon
local QUEST_POI_FRAME_WIDTH;
local QUEST_POI_FRAME_HEIGHT;

local PLAYER_ARROW_SIZE_WINDOW = 40;
local PLAYER_ARROW_SIZE_FULL_WITH_QUESTS = 38;
local PLAYER_ARROW_SIZE_FULL_NO_QUESTS = 28;
local GROUP_MEMBER_SIZE_WINDOW = 16;
local RAID_MEMBER_SIZE_WINDOW = GROUP_MEMBER_SIZE_WINDOW * 0.75;
local GROUP_MEMBER_SIZE_FULL = 10;
local RAID_MEMBER_SIZE_FULL = GROUP_MEMBER_SIZE_FULL * 0.75;

local BATTLEFIELD_ICON_SIZE_FULL = 36;
local BATTLEFIELD_ICON_SIZE_WINDOW = 30;

AREA_NAME_FONT_COLOR = CreateColor(1.0, 0.9294, 0.7607);
AREA_DESCRIPTION_FONT_COLOR = HIGHLIGHT_FONT_COLOR;

INVASION_FONT_COLOR = CreateColor(0.78, 1, 0);
INVASION_DESCRIPTION_FONT_COLOR = CreateColor(1, 0.973, 0.035);

WORLD_MAP_MAX_ALPHA = 1;
WORLD_MAP_MIN_ALPHA = 0.2;

BAD_BOY_UNITS = {};
BAD_BOY_COUNT = 0;

local STORYLINE_FRAMES = { };

MAP_VEHICLES = {};

WORLDMAP_DEBUG_ICON_INFO = {};
WORLDMAP_DEBUG_ICON_INFO[1] = { size =  6, r = 0.0, g = 1.0, b = 0.0 };
WORLDMAP_DEBUG_ICON_INFO[2] = { size = 16, r = 1.0, g = 1.0, b = 0.5 };
WORLDMAP_DEBUG_ICON_INFO[3] = { size = 32, r = 1.0, g = 1.0, b = 0.5 };
WORLDMAP_DEBUG_ICON_INFO[4] = { size = 64, r = 1.0, g = 0.6, b = 0.0 };

WORLDMAP_SETTINGS = {
	opacity = 0,
	locked = true,
	size = WORLDMAP_FULLMAP_SIZE,

};

WORLD_MAP_POI_FRAME_LEVEL_OFFSETS = {
	DUNGEON_ENTRANCE = 100,
	LANDMARK = 200,
	MAP_LINK = 201,
	TAXINODE = 300,

	BONUS_OBJECTIVE = 500,
	INVASION = 700,

	SCENARIO = 1000,
	STORY_LINE = 1000,

	TRACKED_QUEST = 1200,
	WORLD_QUEST = 1200,
}

--=======================================================================================================

TempCompatibilityWorldMapMixin = CreateFromMixins(QuestLogOwnerMixin)

function TempCompatibilityWorldMapMixin:SetHighlightedQuestID(questID)
	self.highlightedQuestID = questID;
	if not IsQuestComplete(questID) then
		WorldMapBlobFrame:DrawBlob(questID, true);
	end
end

function TempCompatibilityWorldMapMixin:GetHighlightedQuestID()
	return self.highlightedQuestID;
end

function TempCompatibilityWorldMapMixin:ClearHighlightedQuestID()
	if not self.highlightedQuestID then
		return;
	end
	if GetSuperTrackedQuestID() ~= self.highlightedQuestID and not IsQuestComplete(self.highlightedQuestID) then
		WorldMapBlobFrame:DrawBlob(self.highlightedQuestID, false);
	end
	self.highlightedQuestID = nil;
end

function TempCompatibilityWorldMapMixin:SetFocusedQuestID(questID)
	self.focusedQuestID = questID;
end

function TempCompatibilityWorldMapMixin:GetFocusedQuestID()
	return self.focusedQuestID;
end

function TempCompatibilityWorldMapMixin:ClearFocusedQuestID()
	self.focusedQuestID = nil;
end

function TempCompatibilityWorldMapMixin:CanDisplayQuestLog()
	return WorldMapFrame_InWindowedMode();
end

function TempCompatibilityWorldMapMixin:OnQuestLogShow()
	WorldMapFrame:SetWidth(992);
	WorldMapFrame.BorderFrame:SetWidth(992);
	WorldMapFrame.UIElementsFrame.OpenQuestPanelButton:Hide();
	WorldMapFrame.UIElementsFrame.CloseQuestPanelButton:Show();

	if ( TutorialFrame.id == 1 or TutorialFrame.id == 55 or TutorialFrame.id == 57 ) then
		TutorialFrame_Hide();
	end
end

function TempCompatibilityWorldMapMixin:OnQuestLogHide()
	WorldMapFrame:SetWidth(702);
	WorldMapFrame.BorderFrame:SetWidth(702);
	WorldMapFrame.UIElementsFrame.OpenQuestPanelButton:Show();
	WorldMapFrame.UIElementsFrame.CloseQuestPanelButton:Hide();	
end

function TempCompatibilityWorldMapMixin:OnQuestLogOpen()
	WorldMapFrame.questLogMode = true;
	if ( not WorldMapFrame_InWindowedMode() ) then
		WorldMapFrame_ToggleWindowSize();
	end	
end

function TempCompatibilityWorldMapMixin:OnQuestLogUpdate()
	local poiTable = { };
	if GetCVarBool("questPOI") then
		GetQuestPOIs(poiTable);
	end
	WorldMapPOIFrame_Update(poiTable);
end

function TempCompatibilityWorldMapMixin:GetMapID()
	return C_Map.GetCurrentMapID();
end

function TempCompatibilityWorldMapMixin:NavigateToMap(mapID)
	SetMapByID(mapID);
end

--========================================================================================================

local WorldEffectPOITooltips = {};
local ScenarioPOITooltips = {};

local WorldMapOverlayHighlights = {};

function SetMapTooltipPosition(tooltipFrame, owner, useMouseAnchor)
	local centerX = WorldMapScrollFrame:GetCenter();
	local comparisonX;

	if useMouseAnchor then
		comparisonX = GetCursorPosition();
		comparisonX = comparisonX / UIParent:GetEffectiveScale();
	else
		comparisonX = owner:GetCenter();
	end

	if ( comparisonX > centerX ) then
		tooltipFrame:SetOwner(owner, useMouseAnchor and "ANCHOR_CURSOR_LEFT" or "ANCHOR_LEFT");
	else
		tooltipFrame:SetOwner(owner, useMouseAnchor and "ANCHOR_CURSOR_RIGHT" or "ANCHOR_RIGHT");
	end
end

function OpenWorldMap(mapID)
	if not WorldMapFrame:IsShown() then
		ToggleWorldMap();
	end
	if ( mapID ) then
		WorldMapFrame:NavigateToMap(mapID);
	end
end

function ToggleWorldMap()
	WorldMapFrame.questLogMode = nil;
	local shouldBeWindowed = GetCVarBool("miniWorldMap");
	local isWindowed = WorldMapFrame_InWindowedMode();
	if ( WorldMapFrame:IsShown() ) then
		if ( isWindowed == shouldBeWindowed ) then
			if ( QuestMapFrame:IsShown() and not GetCVarBool("questLogOpen") ) then
				QuestMapFrame_Close();
			else
				ToggleFrame(WorldMapFrame);
			end
		elseif ( isWindowed ) then
			ToggleFrame(WorldMapFrame);
			WorldMap_ToggleSizeUp();
			ToggleFrame(WorldMapFrame);
		else
			ToggleFrame(WorldMapFrame);
		end
	else
		QuestMapFrame_Close();
		if ( shouldBeWindowed ) then
			if ( not isWindowed ) then
				WorldMap_ToggleSizeDown();
			end
		else
			WorldMap_ToggleSizeUp();
		end
		ToggleFrame(WorldMapFrame);
		if ( GetCVarBool("questLogOpen") and WorldMapFrame_InWindowedMode() ) then
			QuestMapFrame_Open();
		end
	end
	WorldMapFrame_SyncMaximizeMinimizeButton(WorldMapFrame.BorderFrame.MaximizeMinimizeFrame);
end

function WorldMapFrame_IsVindicaarTextureKit(textureKitPrefix)
	return textureKitPrefix == "FlightMaster_VindicaarArgus" or textureKitPrefix == "FlightMaster_VindicaarStygianWake" or textureKitPrefix == "FlightMaster_VindicaarMacAree";
end

function WorldMapFrame_InWindowedMode()
	return WORLDMAP_SETTINGS.size == WORLDMAP_WINDOWED_SIZE;
end

function WorldMapFrame_OnLoad(self)
	self:RegisterEvent("PLAYER_ENTERING_WORLD");
	self:RegisterEvent("WORLD_MAP_UPDATE");
	self:RegisterEvent("VARIABLES_LOADED");
	self:RegisterEvent("DISPLAY_SIZE_CHANGED");
	self:RegisterEvent("REQUEST_CEMETERY_LIST_RESPONSE");
	self:RegisterEvent("PORTRAITS_UPDATED");
	self:RegisterEvent("RESEARCH_ARTIFACT_DIG_SITE_UPDATED");
	self:RegisterEvent("SUPER_TRACKED_QUEST_CHANGED");
	self:RegisterEvent("PLAYER_STARTED_MOVING");
	self:RegisterEvent("PLAYER_STOPPED_MOVING");
	self:RegisterEvent("QUESTLINE_UPDATE");
	self:RegisterEvent("QUEST_LOG_UPDATE");
	self:RegisterEvent("WORLD_QUEST_COMPLETED_BY_SPELL");
	self:RegisterEvent("MINIMAP_UPDATE_TRACKING");
	self:RegisterEvent("DYNAMIC_GOSSIP_POI_UPDATED");

	self:SetClampRectInsets(0, 0, 0, -60);				-- don't overlap the xp/rep bars
	self.poiHighlight = nil;
	self.areaName = nil;

	-- RE: Bug ID: 345647 - Texture errors occur after entering the Nexus and relogging.
	-- The correct GetUIMapInfo() data is not yet available here, so don't try preloading incorrect map textures.
	--WorldMapFrame_Update();

	--[[ Hide the world behind the map when we're in widescreen mode
	local width = GetScreenWidth();
	local height = GetScreenHeight();

	if ( width / height < 4 / 3 ) then
		width = width * 1.25;
		height = height * 1.25;
	end

	BlackoutWorld:SetWidth( width );
	BlackoutWorld:SetHeight( height );
	]]

	-- setup the zone minimap button
	WorldMapLevelDropDown_Update();

	local homeData = {
		name = WORLD,
		OnClick = WorldMapNavBar_OnButtonClick,
		id = WORLDMAP_COSMIC_ID,
	}
	NavBar_Initialize(self.NavBar, "NavButtonTemplate", homeData, self.navBar.home, self.navBar.overflow);

	ButtonFrameTemplate_HidePortrait(WorldMapFrame.BorderFrame);
	WorldMapFrame.BorderFrame.TitleText:SetText(MAP_AND_QUEST_LOG);
	WorldMapFrame.BorderFrame.portrait:SetTexture("Interface\\QuestFrame\\UI-QuestLog-BookIcon");
	WorldMapFrame.BorderFrame.CloseButton:SetScript("OnClick", function() HideUIPanel(WorldMapFrame); end);

	QUEST_POI_FRAME_WIDTH = WorldMapDetailFrame:GetWidth() * WORLDMAP_FULLMAP_SIZE;
	QUEST_POI_FRAME_HEIGHT = WorldMapDetailFrame:GetHeight() * WORLDMAP_FULLMAP_SIZE;
	QuestPOI_Initialize(WorldMapPOIFrame, WorldMapPOIButton_Init);

	WorldMapFrame.UIElementsFrame.ActionButton:SetOnCastChangedCallback(WorldMapFrame_SetBonusObjectivesDirty);

	WorldMapUnitPositionFrame:SetPlayerPingTexture(1, "Interface\\minimap\\UI-Minimap-Ping-Center", 32, 32);
	WorldMapUnitPositionFrame:SetPlayerPingTexture(2, "Interface\\minimap\\UI-Minimap-Ping-Expand", 32, 32);
	WorldMapUnitPositionFrame:SetPlayerPingTexture(3, "Interface\\minimap\\UI-Minimap-Ping-Rotate", 70, 70);

	WorldMapUnitPositionFrame:SetMouseOverUnitExcluded("player", true);
	WorldMapUnitPositionFrame:SetPinTexture("player", "Interface\\WorldMap\\WorldMapArrow");

	local WORLD_QUEST_NUM_CELLS_HIGH = 75;
	local WORLD_QUEST_NUM_CELLS_WIDE = math.ceil(WORLD_QUEST_NUM_CELLS_HIGH * 1002/668);

	self.poiQuantizer = CreateFromMixins(WorldMapPOIQuantizerMixin);
	self.poiQuantizer:OnLoad(WORLD_QUEST_NUM_CELLS_WIDE, WORLD_QUEST_NUM_CELLS_HIGH);

	self.flagsPool = CreateFramePool("FRAME", WorldMapButton, "WorldMapFlagTemplate");
end

function WorldMapFrame_SetBonusObjectivesDirty()
	WorldMapFrame.bonusObjectiveUpdateTimeLeft = 0;
end

function WorldMapFrame_OnShow(self)
	if ( WORLDMAP_SETTINGS.size ~= WORLDMAP_WINDOWED_SIZE ) then
		SetupFullscreenScale(self);
		-- pet battle level size adjustment
		WorldMapFrameAreaPetLevels:SetFontObject("TextStatusBarTextLarge")
	else
		-- pet battle level size adjustment
		WorldMapFrameAreaPetLevels:SetFontObject("SubZoneTextFont");
	end

	-- check to show the help plate
	if ( (not NewPlayerExperience or not NewPlayerExperience.IsActive) and not GetCVarBitfield("closedInfoFrames", LE_FRAME_TUTORIAL_WORLD_MAP_FRAME) ) then
		local helpPlate = WorldMapFrame_HelpPlate;
		if ( helpPlate and not HelpPlate_IsShowing(helpPlate) ) then
			HelpPlate_ShowTutorialPrompt( helpPlate, WorldMapFrame.MainHelpButton );
			SetCVarBitfield( "closedInfoFrames", LE_FRAME_TUTORIAL_WORLD_MAP_FRAME, true );
		end
	end

	UpdateMicroButtons();
	if (not WorldMapFrame.toggling) then
		SetMapToCurrentZone();
	else
		WorldMapFrame.toggling = false;
	end
	PlaySound(SOUNDKIT.IG_QUEST_LOG_OPEN);
	CloseDropDownMenus();
	DoEmote("READ", nil, true);

	WorldMapFrame.fadeOut = false;
end

function WorldMapFrame_OnHide(self)
	HelpPlate_Hide();
	UpdateMicroButtons();
	CloseDropDownMenus();
	PlaySound(SOUNDKIT.IG_QUEST_LOG_CLOSE);
	if ( not self.toggling ) then
		if ( QuestMapFrame:IsShown() ) then
			QuestMapFrame_CheckTutorials();
		end
		QuestMapFrame_CloseQuestDetails();
	end
	if ( WorldMapScrollFrame.zoomedIn ) then
		WorldMapScrollFrame_ResetZoom();
	end
	WorldMapUnitPositionFrame:StopPlayerPing();
	if ( self.showOnHide ) then
		ShowUIPanel(self.showOnHide);
		self.showOnHide = nil;
	end
	-- forces WatchFrame event via the WORLD_MAP_UPDATE event, needed to restore the POIs in the tracker to the current zone
	if (not WorldMapFrame.toggling) then
		WorldMapFrame.hasBosses = false;
		SetMapToCurrentZone();
	end
	CancelEmote();
	self.mapID = nil;
	self.dungeonLevel = nil;

	self.AnimAlphaOut:Stop();
	self.AnimAlphaIn:Stop();
	self:SetAlpha(WORLD_MAP_MAX_ALPHA);

	self.bonusObjectiveUpdateTimeLeft = nil;

	WorldMapOverlayHighlights = {};

	self.UIElementsFrame.ActionButton:SetMapAreaID(nil);
	self.UIElementsFrame.ActionButton:SetHasWorldQuests(false);

	WorldMapPOIFrame.POIPing:Stop();
end

function WorldMapFrame_OnEvent(self, event, ...)
	if ( event == "PLAYER_ENTERING_WORLD" ) then
		if ( self:IsShown() ) then
			HideUIPanel(WorldMapFrame);
		end
	elseif ( event == "WORLD_MAP_UPDATE" or event == "REQUEST_CEMETERY_LIST_RESPONSE" or event == "QUESTLINE_UPDATE" or event == "MINIMAP_UPDATE_TRACKING" or event == "DYNAMIC_GOSSIP_POI_UPDATED" ) then
		local mapID = C_Map.GetCurrentMapID();

		WorldMapBlobFrame:SetMapID(mapID);
		ScenarioPOIFrame:SetMapID(mapID);

		if ( not self.blockWorldMapUpdate and self:IsShown() ) then
			-- if we are exiting a micro dungeon we should update the world map
			WorldMapFrame_UpdateMap(mapID == self.mapID);
		end
		if ( event == "WORLD_MAP_UPDATE" ) then
			if ( self:IsShown() ) then
				if ( mapID ~= self.mapID) then
					self.mapID = mapID;

					if WorldMap_DoesCurrentMapHideMapIcons() then
						WorldMapUnitPositionFrame:Hide();
					else
						WorldMapUnitPositionFrame:Show();
						WorldMapUnitPositionFrame:StartPlayerPing(2, .25);
					end
				end
			end
			if ( WorldMapScrollFrame.zoomedIn ) then
				if ( WorldMapScrollFrame.mapID ~= mapID ) then
					WorldMapScrollFrame_ResetZoom();
				end
			end
		end
	elseif ( event == "RESEARCH_ARTIFACT_DIG_SITE_UPDATED" ) then
		if ( self:IsShown() ) then
			C_Map.SetMap(C_Map.GetCurrentMapID());
		end
	elseif ( event == "VARIABLES_LOADED" ) then
		WORLD_MAP_MIN_ALPHA = tonumber(GetCVar("mapAnimMinAlpha"));
		if ( GetCVarBool("miniWorldMap") ) then
			WorldMap_ToggleSizeDown();
		else
			WorldMap_ToggleSizeUp();
		end
	elseif ( event == "DISPLAY_SIZE_CHANGED" ) then
		WorldMapFrame_ResetPOIHitTranslations();
		--if ( WatchFrame.showObjectives and self:IsShown() ) then
		--	WorldMapFrame_UpdateQuests();
		--end
	elseif ( event == "PORTRAITS_UPDATED" ) then
		EncounterJournal_UpdateMapButtonPortraits();
	elseif ( event == "SUPER_TRACKED_QUEST_CHANGED" ) then
		local questID = ...;
		WorldMapFrame_SetBonusObjectivesDirty();
		WorldMapPOIFrame_SelectPOI(questID);
	elseif ( event == "PLAYER_STARTED_MOVING" ) then
		if ( GetCVarBool("mapFade") ) then
			WorldMapFrame_AnimAlphaOut(self, true);
			WorldMapFrame.fadeOut = true;
		end
	elseif ( event == "PLAYER_STOPPED_MOVING" ) then
		WorldMapFrame_AnimAlphaIn(self, true);
		WorldMapFrame.fadeOut = false;
	elseif ( event == "QUEST_LOG_UPDATE" ) then
		if WorldMapFrame:IsVisible() then
			WorldMap_UpdateQuestBonusObjectives();
			WorldMapFrame_UpdateOverlayLocations();
		end
	elseif ( event == "WORLD_QUEST_COMPLETED_BY_SPELL" ) then
		if WorldMapFrame:IsVisible() then
			WorldMapFrame_SetBonusObjectivesDirty();
		end
	end
end

function WorldMapFrame_OnUserChangedSuperTrackedQuest(questID)
	if ( WorldMapFrame:IsShown() ) then
		local mapID = GetQuestUiMapID(questID);
		if ( mapID ~= 0 ) then
			SetMapByID(mapID);
		end
	end
end

function WorldMapFrame_AnimAlphaIn(self, useStartDelay)
	WorldMapFrame_AnimateAlpha(self, useStartDelay, self.AnimAlphaIn, self.AnimAlphaOut, WORLD_MAP_MIN_ALPHA, WORLD_MAP_MAX_ALPHA);
end

function WorldMapFrame_AnimAlphaOut(self, useStartDelay)
	WorldMapFrame_AnimateAlpha(self, useStartDelay, self.AnimAlphaOut, self.AnimAlphaIn, WORLD_MAP_MAX_ALPHA, WORLD_MAP_MIN_ALPHA);
end

function WorldMapFrame_AnimateAlpha(self, useStartDelay, anim, otherAnim, startAlpha, endAlpha)
	if ( not WorldMapFrame_InWindowedMode() or not self:IsShown() ) then
		return;
	end

	if ( anim:IsPlaying() or self:GetAlpha() == endAlpha ) then
		otherAnim:Stop();
		return;
	end

	local startDelay = 0;
	if ( useStartDelay ) then
		startDelay = tonumber(GetCVar("mapAnimStartDelay"));
	end

	if ( otherAnim:IsPlaying() ) then
		startDelay = 0;
		startAlpha = self:GetAlpha();
		otherAnim:Stop();
		self:SetAlpha(startAlpha);
	end

	local duration = ((endAlpha - startAlpha) / (WORLD_MAP_MAX_ALPHA - WORLD_MAP_MIN_ALPHA)) * tonumber(GetCVar("mapAnimDuration"));
	anim.Alpha:SetFromAlpha(startAlpha);
	anim.Alpha:SetToAlpha(endAlpha);
	anim.Alpha:SetDuration(abs(duration));
	anim.Alpha:SetStartDelay(startDelay);
	anim:Play();
end

local TIME_BETWEEN_BONUS_OBJECTIVE_REFRESH_SECS = 10;
function WorldMapFrame_OnUpdate(self, elapsed)

	local nextBattleTime = C_PvP.GetOutdoorPvPWaitTime(C_Map.GetCurrentMapID());
	if ( nextBattleTime and not IsInInstance()) then
		local battleSec = mod(nextBattleTime, 60);
		local battleMin = mod(floor(nextBattleTime / 60), 60);
		local battleHour = floor(nextBattleTime / 3600);
		WorldMapZoneInfo:SetFormattedText(NEXT_BATTLE, battleHour, battleMin, battleSec);
		WorldMapZoneInfo:Show();
	else
		WorldMapZoneInfo:Hide();
	end

	if ( WorldMapFrame_InWindowedMode() and IsPlayerMoving() and GetCVarBool("mapFade") and WorldMapFrame.fadeOut ) then
		if ( self:IsMouseOver() ) then
			WorldMapFrame_AnimAlphaIn(self);
			self.wasMouseOver = true;
		elseif ( self.wasMouseOver ) then
			WorldMapFrame_AnimAlphaOut(self);
			self.wasMouseOver = nil;
		end
	end

	self.bonusObjectiveUpdateTimeLeft = (self.bonusObjectiveUpdateTimeLeft or TIME_BETWEEN_BONUS_OBJECTIVE_REFRESH_SECS) - elapsed;
	if ( self.bonusObjectiveUpdateTimeLeft <= 0 ) then
		WorldMap_UpdateQuestBonusObjectives();
		self.bonusObjectiveUpdateTimeLeft = TIME_BETWEEN_BONUS_OBJECTIVE_REFRESH_SECS;
	end
end

function WorldMapFrame_OnKeyDown(self, key)
	local binding = GetBindingFromClick(key)
	if ((binding == "TOGGLEWORLDMAP") or (binding == "TOGGLEGAMEMENU")) then
		RunBinding("TOGGLEWORLDMAP");
	elseif ( binding == "SCREENSHOT" ) then
		RunBinding("SCREENSHOT");
	elseif ( binding == "MOVIE_RECORDING_STARTSTOP" ) then
		RunBinding("MOVIE_RECORDING_STARTSTOP");
	elseif ( binding == "TOGGLEWORLDMAPSIZE" ) then
		RunBinding("TOGGLEWORLDMAPSIZE");
	elseif ( binding == "TOGGLEQUESTLOG" ) then
		RunBinding("TOGGLEQUESTLOG");
	end
end

-----------------------------------------------------------------
-- Draw quest bonus objectives
-----------------------------------------------------------------
local function ApplyTextureToPOI(texture, width, height)
	texture:SetTexCoord(0, 1, 0, 1);
	texture:ClearAllPoints();
	texture:SetPoint("CENTER", texture:GetParent());
	texture:SetSize(width or 32, height or 32);
end

local function ApplyAtlasTexturesToPOI(button, normal, pushed, highlight, width, height)
	button:SetSize(20, 20);
	button:SetNormalAtlas(normal);
	ApplyTextureToPOI(button:GetNormalTexture(), width, height);

	button:SetPushedAtlas(pushed);
	ApplyTextureToPOI(button:GetPushedTexture(), width, height);

	button:SetHighlightAtlas(highlight);
	ApplyTextureToPOI(button:GetHighlightTexture(), width, height);

	if button.SelectedGlow then
		button.SelectedGlow:SetAtlas(pushed);
		ApplyTextureToPOI(button.SelectedGlow, width, height);
	end
end

local function ApplyStandardTexturesToPOI(button, selected)
	button:SetSize(20, 20);
	button:SetNormalTexture("Interface/WorldMap/UI-QuestPoi-NumberIcons");
	ApplyTextureToPOI(button:GetNormalTexture());
	if selected then
		button:GetNormalTexture():SetTexCoord(0.500, 0.625, 0.375, 0.5);
	else
		button:GetNormalTexture():SetTexCoord(0.875, 1, 0.375, 0.5);
	end


	button:SetPushedTexture("Interface/WorldMap/UI-QuestPoi-NumberIcons");
	ApplyTextureToPOI(button:GetPushedTexture());
	if selected then
		button:GetPushedTexture():SetTexCoord(0.375, 0.500, 0.375, 0.5);
	else
		button:GetPushedTexture():SetTexCoord(0.750, 0.875, 0.375, 0.5);
	end

	button:SetHighlightTexture("Interface/WorldMap/UI-QuestPoi-NumberIcons");
	ApplyTextureToPOI(button:GetHighlightTexture());
	button:GetHighlightTexture():SetTexCoord(0.625, 0.750, 0.875, 1);
end

WORLD_QUEST_ICONS_BY_PROFESSION = {
	[129] = "worldquest-icon-firstaid",
	[164] = "worldquest-icon-blacksmithing",
	[165] = "worldquest-icon-leatherworking",
	[171] = "worldquest-icon-alchemy",
	[182] = "worldquest-icon-herbalism",
	[186] = "worldquest-icon-mining",
	[202] = "worldquest-icon-engineering",
	[333] = "worldquest-icon-enchanting",
	[755] = "worldquest-icon-jewelcrafting",
	[773] = "worldquest-icon-inscription",
	[794] = "worldquest-icon-archaeology",
	[356] = "worldquest-icon-fishing",
	[185] = "worldquest-icon-cooking",
	[197] = "worldquest-icon-tailoring",
	[393] = "worldquest-icon-skinning",
};

function WorldMap_IsWorldQuestEffectivelyTracked(questID)
	return IsWorldQuestHardWatched(questID) or (IsWorldQuestWatched(questID) and GetSuperTrackedQuestID() == questID);
end

function WorldMap_SetupWorldQuestButton(button, worldQuestType, rarity, isElite, tradeskillLineIndex, inProgress, selected, isCriteria, isSpellTarget, isEffectivelyTracked)
	button.Glow:SetShown(selected);

	if rarity == LE_WORLD_QUEST_QUALITY_COMMON then
		ApplyStandardTexturesToPOI(button, selected);
	elseif rarity == LE_WORLD_QUEST_QUALITY_RARE then
		ApplyAtlasTexturesToPOI(button, "worldquest-questmarker-rare", "worldquest-questmarker-rare-down", "worldquest-questmarker-rare", 18, 18);
	elseif rarity == LE_WORLD_QUEST_QUALITY_EPIC then
		ApplyAtlasTexturesToPOI(button, "worldquest-questmarker-epic", "worldquest-questmarker-epic-down", "worldquest-questmarker-epic", 18, 18);
	end

	if ( button.SelectedGlow ) then
		button.SelectedGlow:SetShown(rarity ~= LE_WORLD_QUEST_QUALITY_COMMON and selected);
	end

	if ( isElite ) then
		button.Underlay:SetAtlas("worldquest-questmarker-dragon");
		button.Underlay:Show();
	else
		button.Underlay:Hide();
	end

	local tradeskillLineID = tradeskillLineIndex and select(7, GetProfessionInfo(tradeskillLineIndex));
	if ( worldQuestType == LE_QUEST_TAG_TYPE_PVP ) then
		if ( inProgress ) then
			button.Texture:SetAtlas("worldquest-questmarker-questionmark");
			button.Texture:SetSize(10, 15);
		else
			button.Texture:SetAtlas("worldquest-icon-pvp-ffa", true);
		end
	elseif ( worldQuestType == LE_QUEST_TAG_TYPE_PET_BATTLE ) then
		if ( inProgress ) then
			button.Texture:SetAtlas("worldquest-questmarker-questionmark");
			button.Texture:SetSize(10, 15);
		else
			button.Texture:SetAtlas("worldquest-icon-petbattle", true);
		end
	elseif ( worldQuestType == LE_QUEST_TAG_TYPE_PROFESSION and WORLD_QUEST_ICONS_BY_PROFESSION[tradeskillLineID] ) then
		if ( inProgress ) then
			button.Texture:SetAtlas("worldquest-questmarker-questionmark");
			button.Texture:SetSize(10, 15);
		else
			button.Texture:SetAtlas(WORLD_QUEST_ICONS_BY_PROFESSION[tradeskillLineID], true);
		end
	elseif ( worldQuestType == LE_QUEST_TAG_TYPE_DUNGEON ) then
		if ( inProgress ) then
			button.Texture:SetAtlas("worldquest-questmarker-questionmark");
			button.Texture:SetSize(10, 15);
		else
			button.Texture:SetAtlas("worldquest-icon-dungeon", true);
		end
	elseif ( worldQuestType == LE_QUEST_TAG_TYPE_RAID ) then
		if ( inProgress ) then
			button.Texture:SetAtlas("worldquest-questmarker-questionmark");
			button.Texture:SetSize(10, 15);
		else
			button.Texture:SetAtlas("worldquest-icon-raid", true);
		end
	elseif ( worldQuestType == LE_QUEST_TAG_TYPE_INVASION ) then
		if ( inProgress ) then
			button.Texture:SetAtlas("worldquest-questmarker-questionmark");
			button.Texture:SetSize(10, 15);
		else
			button.Texture:SetAtlas("worldquest-icon-burninglegion", true);
		end
	else
		if ( inProgress ) then
			button.Texture:SetAtlas("worldquest-questmarker-questionmark");
			button.Texture:SetSize(10, 15);
		else
			button.Texture:SetAtlas("worldquest-questmarker-questbang");
			button.Texture:SetSize(6, 15);
		end
	end

	if ( button.TimeLowFrame ) then
		button.TimeLowFrame:Hide();
	end

	if ( button.CriteriaMatchRing ) then
		button.CriteriaMatchRing:SetShown(isCriteria);
	end

	if ( button.TrackedCheck ) then
		button.TrackedCheck:SetShown(isEffectivelyTracked);
	end

	if ( button.SpellTargetGlow ) then
		button.SpellTargetGlow:SetShown(isSpellTarget);
	end
end

WORLD_QUEST_REWARD_TYPE_FLAG_GOLD = 0x0001;
WORLD_QUEST_REWARD_TYPE_FLAG_ORDER_RESOURCES = 0x0002;
WORLD_QUEST_REWARD_TYPE_FLAG_ARTIFACT_POWER = 0x0004;
WORLD_QUEST_REWARD_TYPE_FLAG_MATERIALS = 0x0008;
WORLD_QUEST_REWARD_TYPE_FLAG_EQUIPMENT = 0x0010;
function WorldMap_GetWorldQuestRewardType(questID)
	if ( not HaveQuestRewardData(questID) ) then
		C_TaskQuest.RequestPreloadRewardData(questID);
		return false;
	end

	local worldQuestRewardType = 0;
	if ( GetQuestLogRewardMoney(questID) > 0 ) then
		worldQuestRewardType = bit.bor(worldQuestRewardType, WORLD_QUEST_REWARD_TYPE_FLAG_GOLD);
	end

	if ( GetQuestLogRewardArtifactXP(questID) > 0 ) then
		worldQuestRewardType = bit.bor(worldQuestRewardType, WORLD_QUEST_REWARD_TYPE_FLAG_ARTIFACT_POWER);
	end

	local ORDER_RESOURCES_CURRENCY_ID = 1220;
	local numQuestCurrencies = GetNumQuestLogRewardCurrencies(questID);
	for i = 1, numQuestCurrencies do
		if ( select(4, GetQuestLogRewardCurrencyInfo(i, questID)) == ORDER_RESOURCES_CURRENCY_ID ) then
			worldQuestRewardType = bit.bor(worldQuestRewardType, WORLD_QUEST_REWARD_TYPE_FLAG_ORDER_RESOURCES);
			break;
		end
	end

	local numQuestRewards = GetNumQuestLogRewards(questID);
	for i = 1, numQuestRewards do
		local itemName, itemTexture, quantity, quality, isUsable, itemID = GetQuestLogRewardInfo(i, questID);
		if ( itemID ) then
			local itemName, itemLink, itemRarity, itemLevel, itemMinLevel, itemType, itemSubType, itemStackCount, itemEquipLoc, itemTexture, sellPrice, classID, subclassID = GetItemInfo(itemID);
			if ( classID == LE_ITEM_CLASS_WEAPON or classID == LE_ITEM_CLASS_ARMOR or (classID == LE_ITEM_CLASS_GEM and subclassID == LE_ITEM_GEM_ARTIFACTRELIC) ) then
				worldQuestRewardType = bit.bor(worldQuestRewardType, WORLD_QUEST_REWARD_TYPE_FLAG_EQUIPMENT);
			end

			if ( IsArtifactPowerItem(itemID) ) then
				worldQuestRewardType = bit.bor(worldQuestRewardType, WORLD_QUEST_REWARD_TYPE_FLAG_ARTIFACT_POWER);
			end

			if ( classID == LE_ITEM_CLASS_TRADEGOODS ) then
				worldQuestRewardType = bit.bor(worldQuestRewardType, WORLD_QUEST_REWARD_TYPE_FLAG_MATERIALS);
			end
		end
	end

	return true, worldQuestRewardType;
end

function WorldMap_DoesWorldQuestInfoPassFilters(info, ignoreTypeFilters)
	local tagID, tagName, worldQuestType, rarity, isElite, tradeskillLineIndex, displayTimeLeft = GetQuestTagInfo(info.questId);

	if ( not ignoreTypeFilters ) then
		if ( worldQuestType == LE_QUEST_TAG_TYPE_PROFESSION ) then
			local prof1, prof2, arch, fish, cook, firstAid = GetProfessions();

			if ( tradeskillLineIndex == prof1 or tradeskillLineIndex == prof2 ) then
				if ( not GetCVarBool("primaryProfessionsFilter") ) then
					return false;
				end
			end

			if ( tradeskillLineIndex == fish or tradeskillLineIndex == cook or tradeskillLineIndex == firstAid ) then
				if ( not GetCVarBool("secondaryProfessionsFilter") ) then
					return false;
				end
			end
		elseif ( worldQuestType == LE_QUEST_TAG_TYPE_PET_BATTLE ) then
			if ( not GetCVarBool("showTamers") ) then
				return false;
			end
		else
			local dataLoaded, worldQuestRewardType = WorldMap_GetWorldQuestRewardType(info.questId);

			if ( not dataLoaded ) then
				return false;
			end

			local typeMatchesFilters = false;
			if ( GetCVarBool("worldQuestFilterGold") and bit.band(worldQuestRewardType, WORLD_QUEST_REWARD_TYPE_FLAG_GOLD) ~= 0 ) then
				typeMatchesFilters = true;
			elseif ( GetCVarBool("worldQuestFilterOrderResources") and bit.band(worldQuestRewardType, WORLD_QUEST_REWARD_TYPE_FLAG_ORDER_RESOURCES) ~= 0 ) then
				typeMatchesFilters = true;
			elseif ( GetCVarBool("worldQuestFilterArtifactPower") and bit.band(worldQuestRewardType, WORLD_QUEST_REWARD_TYPE_FLAG_ARTIFACT_POWER) ~= 0 ) then
				typeMatchesFilters = true;
			elseif ( GetCVarBool("worldQuestFilterProfessionMaterials") and bit.band(worldQuestRewardType, WORLD_QUEST_REWARD_TYPE_FLAG_MATERIALS) ~= 0 ) then
				typeMatchesFilters = true;
			elseif ( GetCVarBool("worldQuestFilterEquipment") and bit.band(worldQuestRewardType, WORLD_QUEST_REWARD_TYPE_FLAG_EQUIPMENT) ~= 0 ) then
				typeMatchesFilters = true;
			end

			-- We always want to show quests that do not fit any of the enumerated reward types.
			if ( worldQuestRewardType ~= 0 and not typeMatchesFilters ) then
				return false;
			end
		end
	end

	return true;
end

function WorldMap_TryCreatingWorldQuestPOI(info, taskIconIndex)
	if ( WorldMap_IsWorldQuestSuppressed(info.questId) or not WorldMap_DoesWorldQuestInfoPassFilters(info) ) then
		return nil;
	end

	local tagID, tagName, worldQuestType, rarity, isElite, tradeskillLineIndex, displayTimeLeft = GetQuestTagInfo(info.questId);

	local taskPOI = WorldMap_GetOrCreateTaskPOI(taskIconIndex);
	local selected = info.questId == GetSuperTrackedQuestID();

	local isCriteria = WorldMapFrame.UIElementsFrame.BountyBoard:IsWorldQuestCriteriaForSelectedBounty(info.questId);
	local isSpellTarget = SpellCanTargetQuest() and IsQuestIDValidSpellTarget(info.questId);
	local isEffectivelyTracked = WorldMap_IsWorldQuestEffectivelyTracked(info.questId);

	taskPOI.worldQuest = true;
	taskPOI.Texture:SetDrawLayer("OVERLAY");

	WorldMap_SetupWorldQuestButton(taskPOI, worldQuestType, rarity, isElite, tradeskillLineIndex, info.inProgress, selected, isCriteria, isSpellTarget, isEffectivelyTracked);

	C_TaskQuest.RequestPreloadRewardData(info.questId);

	return taskPOI;
end

function WorldMap_TryCreatingBonusObjectivePOI(info, taskIconIndex)
	local taskPOI = WorldMap_GetOrCreateTaskPOI(taskIconIndex);
	taskPOI:SetSize(24, 24);
	taskPOI:SetNormalTexture(nil);
	taskPOI:SetPushedTexture(nil);
	taskPOI:SetHighlightTexture(nil);
	taskPOI.Underlay:Hide();
	taskPOI.Texture:SetAtlas("QuestBonusObjective");
	taskPOI.Texture:SetSize(24, 24);
	taskPOI.Texture:SetDrawLayer("BACKGROUND");
	taskPOI.TimeLowFrame:Hide();
	taskPOI.CriteriaMatchRing:Hide();
	taskPOI.TrackedCheck:Hide();
	taskPOI.SpellTargetGlow:Hide();
	taskPOI.Glow:Hide();
	taskPOI.SelectedGlow:Hide();
	taskPOI.worldQuest = false;

	return taskPOI;
end

function WorldMap_GetActiveTaskPOIForQuestID(questID)
	for i = 1, NUM_WORLDMAP_TASK_POIS do
		local taskPOI = _G["WorldMapFrameTaskPOI"..i];
		if taskPOI and taskPOI.questID == questID and taskPOI:IsShown() then
			return taskPOI;
		end
	end
end

function WorldMap_ShouldShowTask(mapID, info)
	if (mapID == info.mapID) then
		return true;
	else
		return false;
	end
end

function WorldMap_UpdateQuestBonusObjectives()
	local showOnlyInvasionWorldQuests = false;
	if ( WorldMapFrame:GetFocusedQuestID() ) then
		-- Hide all task POIs while the player looks at quest details.
		-- but for invasion quests we're gonna show all the invasion world quests
		if ( IsQuestInvasion(WorldMapFrame:GetFocusedQuestID()) ) then
			showOnlyInvasionWorldQuests = true;
		else
			for i = 1, NUM_WORLDMAP_TASK_POIS do
				_G["WorldMapFrameTaskPOI"..i]:Hide();
			end
			return;
		end
	end

	local mapID = C_Map.GetCurrentMapID();
	local taskInfo = C_TaskQuest.GetQuestsForPlayerByMapID(mapID);
	local numTaskPOIs = 0;
	if(taskInfo ~= nil) then
		numTaskPOIs = #taskInfo;
	end

	local taskIconIndex = 1;
	local worldQuestPOIs = {};
	if ( numTaskPOIs > 0 ) then
		for i, info  in ipairs(taskInfo) do
			if ( WorldMap_ShouldShowTask(mapID, info) and HaveQuestData(info.questId) ) then
				local taskPOI;
				local isWorldQuest = QuestUtils_IsQuestWorldQuest(info.questId);
				if ( isWorldQuest ) then
					local showThisWorldQuest = true;
					if ( showOnlyInvasionWorldQuests ) then
						local _, _, worldQuestType = GetQuestTagInfo(info.questId);
						if ( worldQuestType ~= LE_QUEST_TAG_TYPE_INVASION ) then
							showThisWorldQuest = false;
						end
					end
					if ( showThisWorldQuest ) then
						taskPOI = WorldMap_TryCreatingWorldQuestPOI(info, taskIconIndex);
					end
				elseif ( not showOnlyInvasionWorldQuests ) then
					taskPOI = WorldMap_TryCreatingBonusObjectivePOI(info, taskIconIndex);
				end

				if ( taskPOI ) then
					taskPOI.x = info.x;
					taskPOI.y = info.y;
					taskPOI.quantizedX = nil;
					taskPOI.quantizedY = nil;
					taskPOI.questID = info.questId;
					taskPOI.numObjectives = info.numObjectives;
					taskPOI:Show();

					taskIconIndex = taskIconIndex + 1;

					if ( isWorldQuest ) then
						worldQuestPOIs[#worldQuestPOIs + 1] = taskPOI;
					else
						WorldMapPOIFrame_AnchorPOI(taskPOI, info.x, info.y, WORLD_MAP_POI_FRAME_LEVEL_OFFSETS.BONUS_OBJECTIVE);
					end

					WorldMapPing_UpdatePing(taskPOI, info.questId);
				end
			end
		end
	end

	-- Hide unused icons in the pool
	for i = taskIconIndex, NUM_WORLDMAP_TASK_POIS do
		_G["WorldMapFrameTaskPOI"..i]:Hide();
	end

	WorldMapFrame.UIElementsFrame.ActionButton:SetHasWorldQuests(#worldQuestPOIs > 0);
	WorldMap_QuantizeWorldQuestPOIs(worldQuestPOIs);
end

function WorldMap_QuantizeWorldQuestPOIs(worldQuestPOIs)
	WorldMapFrame.poiQuantizer:Clear();
	WorldMapFrame.poiQuantizer:Quantize(worldQuestPOIs);

	for i, worldQuestPOI in ipairs(worldQuestPOIs) do
		WorldMapPOIFrame_AnchorPOI(worldQuestPOI, worldQuestPOI.quantizedX or worldQuestPOI.x, worldQuestPOI.quantizedY or worldQuestPOI.y, WORLD_MAP_POI_FRAME_LEVEL_OFFSETS.WORLD_QUEST);
	end
end

function WorldMap_DrawWorldEffects()
	-----------------------------------------------------------------
	-- Draw quest POI world effects
	-----------------------------------------------------------------
	-- Removed by DWilliams 11/9/2017 - disabled since 6/7/2012 see rev 370983 for last version

	-----------------------------------------------------------------
	-- Draw scenario POIs
	-----------------------------------------------------------------
	local mapID = C_Map.GetCurrentMapID();
	local scenarioIconInfo = C_Scenario.GetScenarioIconInfo(mapID);
	local numScenarioPOIs = 0;
	if(scenarioIconInfo ~= nil) then
		numScenarioPOIs = #scenarioIconInfo;
	end

	--Ensure the button pool is big enough for all the world effect POI's
	if ( NUM_WORLDMAP_SCENARIO_POIS < numScenarioPOIs ) then
		for i=NUM_WORLDMAP_SCENARIO_POIS+1, numScenarioPOIs do
			WorldMap_CreateScenarioPOI(i);
		end
		NUM_WORLDMAP_SCENARIO_POIS = numScenarioPOIs;
	end

	-- Draw scenario icons
	local scenarioIconCount = 1;
	if( GetCVarBool("questPOI") and (scenarioIconInfo ~= nil))then
		for _, info  in pairs(scenarioIconInfo) do

			--textureIndex, x, y, name
			local textureIndex = info.index;
			local x = info.x;
			local y = info.y;
			local name = info.description;

			local scenarioPOIName = "WorldMapFrameScenarioPOI"..scenarioIconCount;
			local scenarioPOI = _G[scenarioPOIName];

			local x1, x2, y1, y2 = GetObjectIconTextureCoords(textureIndex);
			_G[scenarioPOIName.."Texture"]:SetTexCoord(x1, x2, y1, y2);
			WorldMapPOIFrame_AnchorPOI(scenarioPOI, x, y, WORLD_MAP_POI_FRAME_LEVEL_OFFSETS.SCENARIO);
			scenarioPOI.name = scenarioPOIName;
			scenarioPOI:Show();
			ScenarioPOITooltips[scenarioPOIName] = name;

			scenarioIconCount = scenarioIconCount + 1;
		end
	end

	-- Hide unused icons in the pool
	for i=scenarioIconCount, NUM_WORLDMAP_SCENARIO_POIS do
		local scenarioPOIName = "WorldMapFrameScenarioPOI"..i;
		local scenarioPOI = _G[scenarioPOIName];
		scenarioPOI:Hide();
	end
end

function WorldMap_ShouldShowLandmark(landmarkType)
	if not landmarkType then
		return false;
	end

	if landmarkType == LE_MAP_LANDMARK_TYPE_DIGSITE then
		return GetCVarBool("digSites");
	end

	if landmarkType == LE_MAP_LANDMARK_TYPE_TAMER then
		return GetCVarBool("showTamers");
	end

	return true;
end

function WorldMapPOI_ShouldShowAreaLabel(poi)
	if poi.landmarkType == LE_MAP_LANDMARK_TYPE_CONTRIBUTION or poi.landmarkType == LE_MAP_LANDMARK_TYPE_INVASION or poi.useMouseOverTooltip then
		return false;
	end
	if poi.poiID and C_AreaPoiInfo.IsAreaPOITimed(poi.poiID) then
		return false;
	end

	return true;
end

function WorldMap_GetFrameLevelForLandmark(landmarkType)
	if landmarkType == LE_MAP_LANDMARK_TYPE_INVASION then
		return WORLD_MAP_POI_FRAME_LEVEL_OFFSETS.INVASION;
	elseif landmarkType == LE_MAP_LANDMARK_TYPE_DUNGEON_ENTRANCE then
		return WORLD_MAP_POI_FRAME_LEVEL_OFFSETS.DUNGEON_ENTRANCE;
	elseif landmarkType == LE_MAP_LANDMARK_TYPE_TAXINODE then
		return WORLD_MAP_POI_FRAME_LEVEL_OFFSETS.TAXINODE;
	elseif landmarkType == LE_MAP_LANDMARK_TYPE_MAP_LINK then
		return WORLD_MAP_POI_FRAME_LEVEL_OFFSETS.MAP_LINK
	end
	return WORLD_MAP_POI_FRAME_LEVEL_OFFSETS.LANDMARK;
end

function WorldMap_DoesCurrentMapHideMapIcons(mapID)
	local isArgusContinent = C_Map.GetCurrentMapID() == 1184;
	return isArgusContinent;
end

local areaPOIBannerLabelTextureInfo = {};

function WorldMap_UpdateLandmarks()
	if WorldMap_DoesCurrentMapHideMapIcons() then
		for i = 1, NUM_WORLDMAP_POIS do
			local worldMapPOI = _G["WorldMapFramePOI"..i];
			worldMapPOI:Hide();
		end
		return;
	end

	local numPOIs = GetNumMapLandmarks();
	if ( NUM_WORLDMAP_POIS < numPOIs ) then
		for i=NUM_WORLDMAP_POIS+1, numPOIs do
			WorldMap_CreatePOI(i);
		end
		NUM_WORLDMAP_POIS = numPOIs;
	end
	local numGraveyards = 0;
	local currentGraveyard = GetCemeteryPreference();
	local mapID = C_Map.GetCurrentMapID();
	WorldMapFrame_ClearAreaLabel(WORLDMAP_AREA_LABEL_TYPE.AREA_POI_BANNER);
	WorldMapAreaPOIBannerOverlay:Hide();

	if WorldMapFrame.mapLinkPingInfo and mapID ~= WorldMapFrame.mapLinkPingInfo.mapID then
		WorldMapFrame.mapLinkPingInfo = nil;
	end

	for i=1, NUM_WORLDMAP_POIS do
		local worldMapPOIName = "WorldMapFramePOI"..i;
		local worldMapPOI = _G[worldMapPOIName];
		if ( i <= numPOIs ) then
			local landmarkInfo = C_WorldMap.GetMapLandmarkInfo(i);
			if( not landmarkInfo or not WorldMap_ShouldShowLandmark(landmarkInfo.landmarkType) or (mapID ~= WORLDMAP_WINTERGRASP_ID and landmarkInfo.areaID == WORLDMAP_WINTERGRASP_POI_AREAID) or landmarkInfo.displayAsBanner ) then
				worldMapPOI:Hide();
			else
				WorldMapPOIFrame_AnchorPOI(worldMapPOI, landmarkInfo.x, landmarkInfo.y, WorldMap_GetFrameLevelForLandmark(landmarkInfo.landmarkType));
					WorldMap_ResetPOI(worldMapPOI, false, landmarkInfo.atlasName, landmarkInfo.textureKitPrefix);

					if (not landmarkInfo.atlasName) then
						local x1, x2, y1, y2 = GetPOITextureCoords(landmarkInfo.textureIndex);
						worldMapPOI.Texture:SetTexCoord(x1, x2, y1, y2);
						worldMapPOI.HighlightTexture:SetTexCoord(x1, x2, y1, y2);
					else
						worldMapPOI.Texture:SetTexCoord(0, 1, 0, 1);
						worldMapPOI.HighlightTexture:SetTexCoord(0, 1, 0, 1);
					end

					worldMapPOI.name = landmarkInfo.name;
					worldMapPOI.description = landmarkInfo.description;
					worldMapPOI.mapLinkID = landmarkInfo.mapLinkID;
					worldMapPOI.poiID = landmarkInfo.poiID;
					worldMapPOI.landmarkType = landmarkInfo.landmarkType;
					worldMapPOI.textureKitPrefix = landmarkInfo.textureKitPrefix;
					worldMapPOI.useMouseOverTooltip = landmarkInfo.useMouseOverTooltip;
					if ( landmarkInfo.graveyardID and landmarkInfo.graveyardID > 0 ) then
						worldMapPOI.graveyard = landmarkInfo.graveyardID;
						numGraveyards = numGraveyards + 1;
						local graveyard = WorldMap_GetGraveyardButton(numGraveyards);
						graveyard:SetPoint("CENTER", worldMapPOI);
						graveyard:SetFrameLevel(worldMapPOI:GetFrameLevel() - 1);
						graveyard:Show();
						if ( currentGraveyard == landmarkInfo.graveyardID ) then
							graveyard.texture:SetTexture("Interface\\WorldMap\\GravePicker-Selected");
						else
							graveyard.texture:SetTexture("Interface\\WorldMap\\GravePicker-Unselected");
						end
					else
						worldMapPOI.graveyard = nil;
					end
					worldMapPOI:Hide();		-- lame way to force tooltip redraw
					worldMapPOI:Show();

					local pingInfo = WorldMapFrame.mapLinkPingInfo;
					if pingInfo and landmarkInfo.landmarkType == LE_MAP_LANDMARK_TYPE_MAP_LINK then
						WorldMapPing_StartPingPOI(worldMapPOI);
					end
			end

			if (landmarkInfo and landmarkInfo.displayAsBanner) then
				local timeLeftMinutes = C_AreaPoiInfo.GetAreaPOITimeLeft(landmarkInfo.poiID);
				local descriptionLabel = nil;
				if (timeLeftMinutes) then
					local hoursLeft = math.floor(timeLeftMinutes / 60);
					local minutesLeft = timeLeftMinutes % 60;
					descriptionLabel = INVASION_TIME_FORMAT:format(hoursLeft, minutesLeft)
				end

				local x1, x2, y1, y2;
				if (not landmarkInfo.atlasName) then
					x1, x2, y1, y2 = GetPOITextureCoords(landmarkInfo.textureIndex);
				else
					x1, x2, y1, y2 = 0, 1, 0, 1;
				end

				areaPOIBannerLabelTextureInfo.x1 = x1;
				areaPOIBannerLabelTextureInfo.x2 = x2;
				areaPOIBannerLabelTextureInfo.y1 = y1;
				areaPOIBannerLabelTextureInfo.y2 = y2;
				areaPOIBannerLabelTextureInfo.texture = WorldMapFrameAreaLabelTexture;
				areaPOIBannerLabelTextureInfo.atlasIcon = landmarkInfo.atlasName;
				areaPOIBannerLabelTextureInfo.isObjectIcon = false;

				WorldMapFrame_SetAreaLabel(WORLDMAP_AREA_LABEL_TYPE.AREA_POI_BANNER, landmarkInfo.name, descriptionLabel, INVASION_FONT_COLOR, INVASION_DESCRIPTION_FONT_COLOR, WorldMapFrame_OnAreaPOIBannerVisibilityChanged);
				WorldMapAreaPOIBannerOverlay:Show();
			end
		else
			worldMapPOI:Hide();
		end
	end
	if ( numGraveyards > NUM_WORLDMAP_GRAVEYARDS ) then
		NUM_WORLDMAP_GRAVEYARDS = numGraveyards;
	else
		for i = numGraveyards + 1, NUM_WORLDMAP_GRAVEYARDS do
			_G["WorldMapFrameGraveyard"..i]:Hide();
		end
	end

	WorldMapFrame.mapLinkPingInfo = nil;
end

function WorldMapFrame_Update()
	local mapID = C_Map.GetCurrentMapID();
	local mapInfo = C_Map.GetMapInfo(mapID);

	local mapWidth = WorldMapDetailFrame:GetWidth();
	local mapHeight = WorldMapDetailFrame:GetHeight();

	local textures = C_Map.GetMapArtLayerTextures(mapID, 1);
	for i, texture in ipairs(textures) do
		local tile = _G["WorldMapDetailTile"..i];
		if (tile) then
			tile:SetTexture(texture);
		end
	end

	WorldMap_UpdateLandmarks();
	WorldMap_DrawWorldEffects();
	WorldMapFrame.UIElementsFrame.ActionButton:SetMapAreaID(mapID);
	WorldMapPOIFrame.FogOfWar:SetUiMapID(mapID);
	WorldMapFrame_UpdateOverlayLocations();
	WorldMap_UpdateQuestBonusObjectives();

	-- Setup the overlays
	local textureCount = 0;
	WorldMapOverlayHighlights = {};

	for i=1, 0 do
		local textureWidth, textureHeight, offsetX, offsetY, isShownByMouseOver, textureInfo = GetMapOverlayInfo(i);
		if ( textureInfo ) then
			local numTexturesWide = ceil(textureWidth/256);
			local numTexturesTall = ceil(textureHeight/256);
			local neededTextures = textureCount + (numTexturesWide * numTexturesTall);
			if ( neededTextures > NUM_WORLDMAP_OVERLAYS ) then
				for j=NUM_WORLDMAP_OVERLAYS+1, neededTextures do
					WorldMapDetailFrame:CreateTexture("WorldMapOverlay"..j, "ARTWORK");
				end
				NUM_WORLDMAP_OVERLAYS = neededTextures;
			end
			local texturePixelWidth, textureFileWidth, texturePixelHeight, textureFileHeight;
			for j=1, numTexturesTall do
				if ( j < numTexturesTall ) then
					texturePixelHeight = 256;
					textureFileHeight = 256;
				else
					texturePixelHeight = mod(textureHeight, 256);
					if ( texturePixelHeight == 0 ) then
						texturePixelHeight = 256;
					end
					textureFileHeight = 16;
					while(textureFileHeight < texturePixelHeight) do
						textureFileHeight = textureFileHeight * 2;
					end
				end
				for k=1, numTexturesWide do
					textureCount = textureCount + 1;
					local texture = _G["WorldMapOverlay"..textureCount];
					if ( k < numTexturesWide ) then
						texturePixelWidth = 256;
						textureFileWidth = 256;
					else
						texturePixelWidth = mod(textureWidth, 256);
						if ( texturePixelWidth == 0 ) then
							texturePixelWidth = 256;
						end
						textureFileWidth = 16;
						while(textureFileWidth < texturePixelWidth) do
							textureFileWidth = textureFileWidth * 2;
						end
					end
					texture:SetWidth(texturePixelWidth);
					texture:SetHeight(texturePixelHeight);
					texture:SetTexCoord(0, texturePixelWidth/textureFileWidth, 0, texturePixelHeight/textureFileHeight);
					texture:SetPoint("TOPLEFT", offsetX + (256 * (k-1)), -(offsetY + (256 * (j - 1))));
					texture:SetTexture(textureInfo[((j - 1) * numTexturesWide) + k]);

					if isShownByMouseOver == true then
						-- keep track of the textures to show by mouseover
						texture:SetDrawLayer("ARTWORK", 1);
						texture:Hide();
						if ( not WorldMapOverlayHighlights[i] ) then
							WorldMapOverlayHighlights[i] = { };
						end
						table.insert(WorldMapOverlayHighlights[i], texture);
					else
						texture:SetDrawLayer("ARTWORK", 0);
						texture:Show();
					end

				end
			end
		end
	end
	for i=textureCount+1, NUM_WORLDMAP_OVERLAYS do
		_G["WorldMapOverlay"..i]:Hide();
	end

	-- Setup any debug objects
	local baseLevel = WorldMapButton:GetFrameLevel() + 1;
	local numDebugObjects = 0;
	if ( NUM_WORLDMAP_DEBUG_OBJECTS < numDebugObjects ) then
		for i=NUM_WORLDMAP_DEBUG_OBJECTS+1, numDebugObjects do
			CreateFrame("Frame", "WorldMapDebugObject"..i, WorldMapButton, "WorldMapDebugObjectTemplate");
		end
		NUM_WORLDMAP_DEBUG_OBJECTS = numDebugObjects;
	end
	textureCount = 0;
	local mapID = C_Map.GetCurrentMapID();
	for i=1, numDebugObjects do
		local name, size, x, y = GetMapDebugObjectInfo(i);
		if ( (x ~= 0 or y ~= 0) and (size > 1 or mapID ~= WORLDMAP_AZEROTH_ID) ) then
			textureCount = textureCount + 1;
			local frame = _G["WorldMapDebugObject"..textureCount];
			frame.index = i;
			frame.name = name;

			local info = WORLDMAP_DEBUG_ICON_INFO[size];
			if ( mapID == WORLDMAP_AZEROTH_ID ) then
				frame:SetWidth(info.size / 2);
				frame:SetHeight(info.size / 2);
			else
				frame:SetWidth(info.size);
				frame:SetHeight(info.size);
			end
			frame.texture:SetVertexColor(info.r, info.g, info.b, 0.5);

			x = x * mapWidth;
			y = -y * mapHeight;
			frame:SetFrameLevel(baseLevel + (4 - size));
			frame:SetPoint("CENTER", "WorldMapDetailFrame", "TOPLEFT", x, y);
			frame:Show();
		end
	end
	for i=textureCount+1, NUM_WORLDMAP_DEBUG_OBJECTS do
		_G["WorldMapDebugObject"..i]:Hide();
	end

	EncounterJournal_AddMapButtons();

	-- position storyline quests, but not on continent or "world" maps
	local numUsedStoryLineFrames = 0;
	if (mapInfo.mapType ~= Enum.UIMapType.Continent) and (mapInfo.mapType ~= Enum.UIMapType.World) and (mapInfo.mapType ~= Enum.UIMapType.Cosmic) then
		for _, questLineInfo in pairs(C_QuestLine.GetAvailableQuestLines(mapID)) do
			if ( not questLineInfo.isHidden or IsTrackingHiddenQuests() ) then
				numUsedStoryLineFrames = numUsedStoryLineFrames + 1;
				local frame = STORYLINE_FRAMES[numUsedStoryLineFrames];
				if ( not frame ) then
					frame = CreateFrame("FRAME", "WorldMapStoryLine"..numUsedStoryLineFrames, WorldMapPOIFrame, "WorldMapStoryLineTemplate");
					STORYLINE_FRAMES[numUsedStoryLineFrames] = frame;
				end
				frame.questID = questLineInfo.questID;
				frame.mapID = mapID;
				WorldMapPOIFrame_AnchorPOI(frame, questLineInfo.x, questLineInfo.y, WORLD_MAP_POI_FRAME_LEVEL_OFFSETS.STORY_LINE);
				if ( questLineInfo.isLegendary ) then
					frame.Texture:SetAtlas("QuestLegendary", true);
				elseif ( questLineInfo.isHidden ) then
					frame.Texture:SetAtlas("TrivialQuests", true);
				else
					frame.Texture:SetAtlas("QuestNormal", true);
				end
				frame.Below:SetShown(questLineInfo.floorLocation == Enum.QuestLineFloorLocation.Below);
				frame.Above:SetShown(questLineInfo.floorLocation == Enum.QuestLineFloorLocation.Above);
				frame.Texture:SetDesaturated(questLineInfo.floorLocation ~= Enum.QuestLineFloorLocation.Same);
				frame:Show();
			end
		end
	end
	for i = numUsedStoryLineFrames + 1, #STORYLINE_FRAMES do
		STORYLINE_FRAMES[i]:Hide();
	end

	WorldMapFrame_UpdateInvasion();
end

function WorldMapFrame_SetOverlayLocation(frame, location)
	frame:ClearAllPoints();
	if location == LE_MAP_OVERLAY_DISPLAY_LOCATION_BOTTOM_LEFT then
		frame:SetPoint("BOTTOMLEFT", 15, 15);
	elseif location == LE_MAP_OVERLAY_DISPLAY_LOCATION_TOP_LEFT then
		frame:SetPoint("TOPLEFT", 15, -15);
	elseif location == LE_MAP_OVERLAY_DISPLAY_LOCATION_BOTTOM_RIGHT then
		frame:SetPoint("BOTTOMRIGHT", -18, 15);
	elseif location == LE_MAP_OVERLAY_DISPLAY_LOCATION_TOP_RIGHT then
		frame:SetPoint("TOPRIGHT", -15, -15);
	end
end

function WorldMapFrame_UpdateOverlayLocations()
	local bountyBoard = WorldMapFrame.UIElementsFrame.BountyBoard;
	local bountyBoardLocation = bountyBoard:GetDisplayLocation();
	if bountyBoardLocation then
		WorldMapFrame_SetOverlayLocation(bountyBoard, bountyBoardLocation);
	end

	local actionButton = WorldMapFrame.UIElementsFrame.ActionButton;
	local useAlternateLocation = bountyBoardLocation == LE_MAP_OVERLAY_DISPLAY_LOCATION_BOTTOM_RIGHT;
	local actionButtonLocation = actionButton:GetDisplayLocation(useAlternateLocation);
	if actionButtonLocation then
		WorldMapFrame_SetOverlayLocation(actionButton, actionButtonLocation);
	end
end

function WorldMapFrame_OnAreaPOIBannerVisibilityChanged(visible)
	if (visible) then
		WorldMap_SetupAreaPOIBannerTexture(areaPOIBannerLabelTextureInfo.texture, areaPOIBannerLabelTextureInfo.isObjectIcon, areaPOIBannerLabelTextureInfo.atlasIcon);
		areaPOIBannerLabelTextureInfo.texture:Show();
	else
		areaPOIBannerLabelTextureInfo.texture:Hide();
	end
end

function WorldMapFrame_OnInvasionLabelVisibilityChanged(visible)
	if visible then
		WorldMapFrameAreaLabelTexture:SetAtlas("legioninvasion-map-icon-portal-large");
		WorldMapFrameAreaLabelTexture:SetSize(77, 81);
		WorldMapFrameAreaLabelTexture:Show();
	else
		WorldMapFrameAreaLabelTexture:Hide();
	end
end

function WorldMapFrame_UpdateInvasion()
	local mapID = C_Map.GetCurrentMapID();
	local invasionID = MapUtil.IsMapTypeZone(mapID) and C_InvasionInfo.GetInvasionForUiMapID(mapID);

	if invasionID then
		WorldMapInvasionOverlay:Show();
		local timeLeftMinutes = C_InvasionInfo.GetInvasionTimeLeft(invasionID);
		local descriptionLabel;
		if timeLeftMinutes and mapID ~= C_Map.GetBestMapForUnit("player") then -- only show the timer if you're not in that zone
			local hoursLeft = math.floor(timeLeftMinutes / 60);
			local minutesLeft = timeLeftMinutes % 60;
			descriptionLabel = INVASION_TIME_FORMAT:format(hoursLeft, minutesLeft)
		end
		WorldMapFrame_SetAreaLabel(WORLDMAP_AREA_LABEL_TYPE.INVASION, MAP_UNDER_INVASION, descriptionLabel, INVASION_FONT_COLOR, INVASION_DESCRIPTION_FONT_COLOR, WorldMapFrame_OnInvasionLabelVisibilityChanged);
	else
		WorldMapInvasionOverlay:Hide();
		WorldMapFrame_ClearAreaLabel(WORLDMAP_AREA_LABEL_TYPE.INVASION);
	end
end

WORLDMAP_AREA_LABEL_TYPE = {
	-- Where their value is the priority (lower numbers are trumped by larger)
	INVASION = 1,
	AREA_POI_BANNER = 2,
	AREA_NAME = 3,
	POI = 4,
};

do
	local areaLabelInfoByType = {};
	local areaLabelsDirty = false;
	function WorldMapFrame_SetAreaLabel(areaLabelType, name, description, nameColor, descriptionColor, callback)
		if not areaLabelInfoByType[areaLabelType] then
			areaLabelInfoByType[areaLabelType] = {};
		end

		local areaLabelInfo = areaLabelInfoByType[areaLabelType];
		if areaLabelInfo.name ~= name or areaLabelInfo.description ~= description or not AreColorsEqual(areaLabelInfo.nameColor, nameColor) or not AreColorsEqual(areaLabelInfo.descriptionColor, descriptionColor) or areaLabelInfo.callback ~= callback then
			areaLabelInfo.name = name;
			areaLabelInfo.description = description;
			areaLabelInfo.nameColor = nameColor;
			areaLabelInfo.descriptionColor = descriptionColor;
			areaLabelInfo.callback = callback;

			areaLabelsDirty = true;
		end
	end

	function WorldMapFrame_ClearAreaLabel(areaLabelType)
		if areaLabelInfoByType[areaLabelType] then
			WorldMapFrame_SetAreaLabel(areaLabelType, nil);
		end
	end

	local pendingOnHideCallback;
	function WorldMapFrame_EvaluateAreaLabels()
		if not areaLabelsDirty then
			return;
		end
		areaLabelsDirty = false;

		local highestPriorityAreaLabelType;

		for areaLabelName, areaLabelType in pairs(WORLDMAP_AREA_LABEL_TYPE) do
			local areaLabelInfo = areaLabelInfoByType[areaLabelType];
			if areaLabelInfo and areaLabelInfo.name then
				if not highestPriorityAreaLabelType or areaLabelType > highestPriorityAreaLabelType then
					highestPriorityAreaLabelType = areaLabelType;
				end
			end
		end

		if pendingOnHideCallback then
			pendingOnHideCallback(false);
			pendingOnHideCallback = nil;
		end

		if highestPriorityAreaLabelType then
			local areaLabelInfo = areaLabelInfoByType[highestPriorityAreaLabelType];
			WorldMapFrameAreaLabel:SetText(areaLabelInfo.name);
			WorldMapFrameAreaDescription:SetText(areaLabelInfo.description);

			if areaLabelInfo.nameColor then
				WorldMapFrameAreaLabel:SetVertexColor(areaLabelInfo.nameColor:GetRGB());
			else
				WorldMapFrameAreaLabel:SetVertexColor(AREA_NAME_FONT_COLOR:GetRGB());
			end

			if areaLabelInfo.descriptionColor then
				WorldMapFrameAreaDescription:SetVertexColor(areaLabelInfo.descriptionColor:GetRGB());
			else
				WorldMapFrameAreaDescription:SetVertexColor(AREA_DESCRIPTION_FONT_COLOR:GetRGB());
			end

			if areaLabelInfo.callback then
				areaLabelInfo.callback(true);
				pendingOnHideCallback = areaLabelInfo.callback;
			end
		else
			WorldMapFrameAreaLabel:SetText("");
			WorldMapFrameAreaDescription:SetText("");
		end
	end
end

function WorldMap_DoesLandMarkTypeShowHighlights(landmarkType, textureKitPrefix)
	if WorldMapFrame_IsVindicaarTextureKit(textureKitPrefix) then
		return false;
	end

	return landmarkType == LE_MAP_LANDMARK_TYPE_NORMAL
		or landmarkType == LE_MAP_LANDMARK_TYPE_TAMER
		or landmarkType == LE_MAP_LANDMARK_TYPE_GOSSIP
		or landmarkType == LE_MAP_LANDMARK_TYPE_TAXINODE
		or landmarkType == LE_MAP_LANDMARK_TYPE_VIGNETTE
		or landmarkType == LE_MAP_LANDMARK_TYPE_INVASION
		or landmarkType == LE_MAP_LANDMARK_TYPE_CONTRIBUTION
		or landmarkType == LE_MAP_LANDMARK_TYPE_MAP_LINK;
end

function WorldMapPOI_AddContributionsToTooltip(tooltip, ...)
	for i = 1, select("#", ...) do
		local contributionID = select(i, ...);
		local contributionName = C_ContributionCollector.GetName(contributionID);
		local state, stateAmount, timeOfNextStateChange = C_ContributionCollector.GetState(contributionID);
		local appearanceData = CONTRIBUTION_APPEARANCE_DATA[state];

		if i ~= 1 then
			tooltip:AddLine(" ");
		end

		tooltip:AddLine(contributionName, HIGHLIGHT_FONT_COLOR:GetRGB());

		local tooltipLine = appearanceData.tooltipLine;
		if tooltipLine then
			if timeOfNextStateChange and appearanceData.tooltipUseTimeRemaining then
				local time = math.max(timeOfNextStateChange - GetServerTime(), 60); -- Never display times below one minute
				tooltipLine = tooltipLine:format(SecondsToTime(time, true, true, 1));
			else
				tooltipLine = tooltipLine:format(FormatPercentage(stateAmount));
			end

			tooltip:AddLine(tooltipLine, appearanceData.stateColor:GetRGB());
		end
	end
end

function WorldMapPOI_AddPOITimeLeftText(anchor, areaPoiID, name, description)
	if WarfrontTooltipController:HandleTooltip(WorldMapTooltip, anchor, areaPoiID, name, description) then
		return;
	end
	if name and #name > 0 and description and #description > 0 and C_AreaPoiInfo.IsAreaPOITimed(areaPoiID) then
		WorldMapTooltip:SetOwner(anchor, "ANCHOR_RIGHT");
		WorldMapTooltip:SetText(HIGHLIGHT_FONT_COLOR:WrapTextInColorCode(name));
		WorldMapTooltip:AddLine(NORMAL_FONT_COLOR:WrapTextInColorCode(description));
		local timeLeftMinutes = C_AreaPoiInfo.GetAreaPOITimeLeft(areaPoiID);
		if timeLeftMinutes then
			local timeString = SecondsToTime(timeLeftMinutes * 60);
			WorldMapTooltip:AddLine(BONUS_OBJECTIVE_TIME_LEFT:format(timeString), NORMAL_FONT_COLOR:GetRGB());
		end
		WorldMapTooltip:Show();
	end
end

function WorldMapPOI_OnEnter(self)
	WorldMapFrame.poiHighlight = true;
	if ( self.specialPOIInfo and self.specialPOIInfo.onEnter ) then
		self.specialPOIInfo.onEnter(self, self.specialPOIInfo);
	else
		self.HighlightTexture:SetShown(WorldMap_DoesLandMarkTypeShowHighlights(self.landmarkType, self.textureKitPrefix));

		if ( WorldMapPOI_ShouldShowAreaLabel(self) ) then
			WorldMapFrame_SetAreaLabel(WORLDMAP_AREA_LABEL_TYPE.POI, self.name, self.description);
		end

		if ( self.graveyard ) then
			WorldMapTooltip:SetOwner(self, "ANCHOR_RIGHT");
			local r, g, b = HIGHLIGHT_FONT_COLOR:GetRGB();

			if ( self.graveyard == GetCemeteryPreference() ) then
				WorldMapTooltip:SetText(GRAVEYARD_SELECTED);
				WorldMapTooltip:AddLine(GRAVEYARD_SELECTED_TOOLTIP, r, g, b, true);
			else
				WorldMapTooltip:SetText(GRAVEYARD_ELIGIBLE);
				WorldMapTooltip:AddLine(GRAVEYARD_ELIGIBLE_TOOLTIP, r, g, b, true);
			end

			WorldMapTooltip:Show();
		end

		if self.landmarkType == LE_MAP_LANDMARK_TYPE_INVASION then
			local invasionInfo = C_InvasionInfo.GetInvasionInfo(self.poiID);
			local timeLeftMinutes = C_InvasionInfo.GetInvasionTimeLeft(self.poiID);

			WorldMapTooltip:SetOwner(self, "ANCHOR_RIGHT");
			WorldMapTooltip:SetText(invasionInfo.name, HIGHLIGHT_FONT_COLOR:GetRGB());

			if timeLeftMinutes and timeLeftMinutes > 0 then
				local timeString = SecondsToTime(timeLeftMinutes * 60);
				WorldMapTooltip:AddLine(BONUS_OBJECTIVE_TIME_LEFT:format(timeString), NORMAL_FONT_COLOR:GetRGB());
			end

			if invasionInfo.rewardQuestID then
				if not HaveQuestData(invasionInfo.rewardQuestID) then
					WorldMapTooltip:AddLine(RETRIEVING_DATA, RED_FONT_COLOR:GetRGB());
				else
					GameTooltip_AddQuestRewardsToTooltip(WorldMapTooltip, invasionInfo.rewardQuestID);
				end
			end

			WorldMapTooltip:Show();
		elseif self.landmarkType == LE_MAP_LANDMARK_TYPE_CONTRIBUTION then
			WorldMapTooltip:SetOwner(self, "ANCHOR_RIGHT");
			WorldMapTooltip:SetText(self.name, HIGHLIGHT_FONT_COLOR:GetRGB());
			WorldMapTooltip:AddLine(" ");

			WorldMapPOI_AddContributionsToTooltip(WorldMapTooltip, C_ContributionCollector.GetManagedContributionsForCreatureID(self.mapLinkID));

			WorldMapTooltip:Show();
		elseif self.landmarkType == LE_MAP_LANDMARK_TYPE_VIGNETTE and self.useMouseOverTooltip then
			WorldMapTooltip:SetOwner(self, "ANCHOR_RIGHT");
			WorldMapTooltip:SetText(HIGHLIGHT_FONT_COLOR:WrapTextInColorCode(self.name));
			if ( self.description ) then
				WorldMapTooltip:AddLine(NORMAL_FONT_COLOR:WrapTextInColorCode(self.description));
			end
			WorldMapTooltip:Show();
		else
			WorldMapPOI_AddPOITimeLeftText(self, self.poiID, self.name, self.description);
		end
	end
end

function WorldMapPOI_OnLeave(self)
	WorldMapFrame.poiHighlight = nil;
	if ( self.specialPOIInfo and self.specialPOIInfo.onLeave ) then
		self.specialPOIInfo.onLeave(self, self.specialPOIInfo);
	else
		WorldMapFrame_ClearAreaLabel(WORLDMAP_AREA_LABEL_TYPE.POI);
		WorldMapTooltip:Hide();
	end

	self.HighlightTexture:Hide();
end

function WorldEffectPOI_OnEnter(self)
	if(WorldEffectPOITooltips[self.name] ~= nil) then
		WorldMapTooltip:SetOwner(self, "ANCHOR_RIGHT");
		WorldMapTooltip:SetText(WorldEffectPOITooltips[self.name]);
		WorldMapTooltip:Show();
	end
end

function WorldEffectPOI_OnLeave()
	WorldMapTooltip:Hide();
end

local g_supressedWorldQuestTimeStamps = {};
function WorldMap_AddWorldQuestSuppression(questID)
	g_supressedWorldQuestTimeStamps[questID] = GetTime();
	WorldMapFrame_SetBonusObjectivesDirty();
end

local WORLD_QUEST_SUPPRESSION_TIME_SECS = 60.0;
function WorldMap_IsWorldQuestSuppressed(questID)
	local lastSuppressedTime = g_supressedWorldQuestTimeStamps[questID];
	if lastSuppressedTime then
		if GetTime() - lastSuppressedTime < WORLD_QUEST_SUPPRESSION_TIME_SECS then
			return true;
		end
		g_supressedWorldQuestTimeStamps[questID] = nil;
	end
	return false;
end

function WorldMap_OnWorldQuestCompletedBySpell(questID)
	local mapID = C_Map.GetCurrentMapID();
	local x, y = C_TaskQuest.GetQuestLocation(questID, mapID);
	if x and y then
		WorldMap_AddWorldQuestSuppression(questID);
		local spellID, spellVisualKitID = GetWorldMapActionButtonSpellInfo();
		if spellVisualKitID then
			WorldMapPOIFrame_AnchorPOI(WorldMapPOIFrame.WorldQuestCompletedBySpellModel, x, y, 5000);
			WorldMapPOIFrame.WorldQuestCompletedBySpellModel:SetCameraTarget(0, 0, 0);
			WorldMapPOIFrame.WorldQuestCompletedBySpellModel:SetCameraPosition(0, 0, 25);
			WorldMapPOIFrame.WorldQuestCompletedBySpellModel:SetSpellVisualKit(spellVisualKitID);
		end
	end
end

function WorldMap_AddQuestTimeToTooltip(questID)
	local timeLeftMinutes = C_TaskQuest.GetQuestTimeLeftMinutes(questID);
	if ( timeLeftMinutes and timeLeftMinutes > 0 ) then
		local color = NORMAL_FONT_COLOR;
		if ( timeLeftMinutes <= WORLD_QUESTS_TIME_CRITICAL_MINUTES ) then
			color = RED_FONT_COLOR;
		end

		local timeString;
		if timeLeftMinutes <= 60 then
			timeString = SecondsToTime(timeLeftMinutes * 60);
		elseif timeLeftMinutes < 24 * 60  then
			timeString = D_HOURS:format(math.floor(timeLeftMinutes) / 60);
		else
			timeString = D_DAYS:format(math.floor(timeLeftMinutes) / 1440);
		end

		WorldMapTooltip:AddLine(BONUS_OBJECTIVE_TIME_LEFT:format(timeString), color.r, color.g, color.b);
	end
end

function TaskPOI_OnEnter(self)
	WorldMapTooltip:SetOwner(self, "ANCHOR_RIGHT");

	if ( not HaveQuestData(self.questID) ) then
		WorldMapTooltip:SetText(RETRIEVING_DATA, RED_FONT_COLOR.r, RED_FONT_COLOR.g, RED_FONT_COLOR.b);
		WorldMapTooltip:Show();
		return;
	end

	local title, factionID, capped = C_TaskQuest.GetQuestInfoByQuestID(self.questID);
	if ( self.worldQuest ) then
		local tagID, tagName, worldQuestType, rarity, isElite, tradeskillLineIndex, displayTimeLeft = GetQuestTagInfo(self.questID);
		local color = WORLD_QUEST_QUALITY_COLORS[rarity];
		WorldMapTooltip:SetText(title, color.r, color.g, color.b);
		QuestUtils_AddQuestTypeToTooltip(WorldMapTooltip, self.questID, NORMAL_FONT_COLOR);

		if ( factionID ) then
			local factionName = GetFactionInfoByID(factionID);
			if ( factionName ) then
				if (capped) then
					WorldMapTooltip:AddLine(factionName, GRAY_FONT_COLOR:GetRGB());
				else
					WorldMapTooltip:AddLine(factionName);
				end
			end
		end

		if displayTimeLeft then
			WorldMap_AddQuestTimeToTooltip(self.questID);
		end
	else
		WorldMapTooltip:SetText(title);
	end

	for objectiveIndex = 1, self.numObjectives do
		local objectiveText, objectiveType, finished = GetQuestObjectiveInfo(self.questID, objectiveIndex, false);
		if ( objectiveText and #objectiveText > 0 ) then
			local color = finished and GRAY_FONT_COLOR or HIGHLIGHT_FONT_COLOR;
			WorldMapTooltip:AddLine(QUEST_DASH .. objectiveText, color.r, color.g, color.b, true);
		end
	end

	local percent = C_TaskQuest.GetQuestProgressBarInfo(self.questID);
	if ( percent ) then
		GameTooltip_InsertFrame(WorldMapTooltip, WorldMapTaskTooltipStatusBar);
		WorldMapTaskTooltipStatusBar.Bar:SetValue(percent);
		WorldMapTaskTooltipStatusBar.Bar.Label:SetFormattedText(PERCENTAGE_STRING, percent);
	end

	GameTooltip_AddQuestRewardsToTooltip(WorldMapTooltip, self.questID);

	if ( self.worldQuest and WorldMapTooltip.AddDebugWorldQuestInfo ) then
		WorldMapTooltip:AddDebugWorldQuestInfo(self.questID);
	end

	WorldMapTooltip:Show();
	WorldMapTooltip.recalculatePadding = true;
end

function TaskPOI_OnLeave(self)
	WorldMapTooltip:Hide();
end

function TaskPOI_OnClick(self, button)
	if self.worldQuest then
		if SpellCanTargetQuest() then
			if IsQuestIDValidSpellTarget(self.questID) then
				UseWorldMapActionButtonSpellOnQuest(self.questID);
				-- Assume success for responsiveness
				WorldMap_OnWorldQuestCompletedBySpell(self.questID);
			else
				UIErrorsFrame:AddMessage(WORLD_QUEST_CANT_COMPLETE_BY_SPELL, RED_FONT_COLOR.r, RED_FONT_COLOR.g, RED_FONT_COLOR.b);
			end
		else
			if ( not ChatEdit_TryInsertQuestLinkForQuestID(self.questID) ) then
				PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);

				if IsShiftKeyDown() then
					if IsWorldQuestHardWatched(self.questID) or (IsWorldQuestWatched(self.questID) and GetSuperTrackedQuestID() == self.questID) then
						BonusObjectiveTracker_UntrackWorldQuest(self.questID);
					else
						BonusObjectiveTracker_TrackWorldQuest(self.questID, true);
					end
				else
					if IsWorldQuestHardWatched(self.questID) then
						SetSuperTrackedQuestID(self.questID);
					else
						BonusObjectiveTracker_TrackWorldQuest(self.questID);
					end
				end
			end
		end
	end
end

function TaskPOI_OnHide(self)
	WorldMapPing_StopPing(self);
end

function ScenarioPOI_OnEnter(self)
	if(ScenarioPOITooltips[self.name] ~= nil) then
		WorldMapTooltip:SetOwner(self, "ANCHOR_RIGHT");
		WorldMapTooltip:SetText(ScenarioPOITooltips[self.name]);
		WorldMapTooltip:Show();
	end
end

function ScenarioPOI_OnLeave()
	WorldMapTooltip:Hide();
end

function WorldMapPOI_OnClick(self, button)
	if self.landmarkType == LE_MAP_LANDMARK_TYPE_MAP_LINK then
		-- We need to cache this data in advance because it can change when we change map IDs.
		local currentMapID = C_Map.GetCurrentMapID();
		local mapID = self.mapLinkID;
		if mapID then
			WorldMapFrame.mapLinkPingInfo = { mapID = currentMapID, floorIndex = currentFloorIndex };
			SetMapByID(mapID);
		end

		PlaySound(SOUNDKIT.IG_QUEST_LOG_OPEN);
	elseif ( self.mapLinkID and self.landmarkType ~= LE_MAP_LANDMARK_TYPE_CONTRIBUTION ) then
		if self.landmarkType == LE_MAP_LANDMARK_TYPE_DUNGEON_ENTRANCE then
			if not EncounterJournal or not EncounterJournal:IsShown() then
				if not ToggleEncounterJournal() then
					return;
				end
			end
			EncounterJournal_ListInstances();
			EncounterJournal_DisplayInstance(self.mapLinkID);
		else
			ClickLandmark(self.mapLinkID);
		end
	elseif ( self.graveyard ) then
		SetCemeteryPreference(self.graveyard);
		WorldMapFrame_Update();
	else
		WorldMapButton_OnClick(WorldMapButton, button);
	end
end

function WorldMap_CreatePOI(index, isObjectIcon, atlasIcon)
	local button = CreateFrame("Button", "WorldMapFramePOI"..index, WorldMapPOIFrame);
	button:RegisterForClicks("LeftButtonUp", "RightButtonUp");
	button:SetScript("OnEnter", WorldMapPOI_OnEnter);
	button:SetScript("OnLeave", WorldMapPOI_OnLeave);
	button:SetScript("OnClick", WorldMapPOI_OnClick);

	button.UpdateTooltip = WorldMapPOI_OnEnter;

	button.Texture = button:CreateTexture(button:GetName().."Texture", "BACKGROUND");
	button.HighlightTexture = button:CreateTexture(button:GetName().."HighlightTexture", "HIGHLIGHT");
	button.HighlightTexture:SetBlendMode("ADD");
	button.HighlightTexture:SetAlpha(.4);
	button.HighlightTexture:SetAllPoints(button.Texture);

	WorldMap_ResetPOI(button, isObjectIcon, atlasIcon);
end

function WorldMap_SetupAreaPOIBannerTexture(texture, isObjectIcon, atlasIcon)
	if (atlasIcon) then
		texture:SetAtlas(atlasIcon);
	elseif (isObjectIcon == true) then
		texture:SetTexture("Interface\\Minimap\\ObjectIconsAtlas");
	else
		texture:SetTexture("Interface\\Minimap\\POIIcons");
	end
	texture:SetSize(77, 81);
end

local ATLAS_WITH_TEXTURE_KIT_PREFIX = "%s-%s";
function WorldMap_ResetPOI(button, isObjectIcon, atlasIcon, textureKitPrefix)
	if (atlasIcon) then
		if (textureKitPrefix) then
			atlasIcon = ATLAS_WITH_TEXTURE_KIT_PREFIX:format(textureKitPrefix, atlasIcon);
		end
		button.Texture:SetAtlas(atlasIcon, true);
		if button.HighlightTexture then
			button.HighlightTexture:SetAtlas(atlasIcon, true);
		end

		local sizeX, sizeY = button.Texture:GetSize();
		if (textureKitPrefix == "FlightMaster_Argus") then
			sizeX = 21;
			sizeY = 18;
		end
		button.Texture:SetSize(sizeX, sizeY);
		button.HighlightTexture:SetSize(sizeX, sizeY);
		button:SetSize(sizeX, sizeY);
		button.Texture:SetPoint("CENTER", 0, 0);
	elseif (isObjectIcon == true) then
		button:SetWidth(32);
		button:SetHeight(32);
		button.Texture:SetWidth(28);
		button.Texture:SetHeight(28);
		button.Texture:SetPoint("CENTER", 0, 0);
		button.Texture:SetTexture("Interface\\Minimap\\ObjectIconsAtlas");
		if button.HighlightTexture then
			button.HighlightTexture:SetTexture("Interface\\Minimap\\ObjectIconsAtlas");
		end
	else
		button:SetWidth(32);
		button:SetHeight(32);
		button.Texture:SetWidth(16);
		button.Texture:SetHeight(16);
		button.Texture:SetPoint("CENTER", 0, 0);
		button.Texture:SetTexture("Interface\\Minimap\\POIIcons");
		if button.HighlightTexture then
			button.HighlightTexture:SetTexture("Interface\\Minimap\\POIIcons");
		end
	end

	button.specialPOIInfo = nil;
end

function WorldMap_CreateWorldEffectPOI(index)
	local button = CreateFrame("Button", "WorldMapFrameWorldEffectPOI"..index, WorldMapPOIFrame);
	button:SetWidth(32);
	button:SetHeight(32);
	button:SetScript("OnEnter", WorldEffectPOI_OnEnter);
	button:SetScript("OnLeave", WorldEffectPOI_OnLeave);

	local texture = button:CreateTexture(button:GetName().."Texture", "BACKGROUND");
	texture:SetWidth(16);
	texture:SetHeight(16);
	texture:SetPoint("CENTER", 0, 0);
	texture:SetTexture("Interface\\Minimap\\ObjectIconsAtlas");
end

function WorldMap_GetOrCreateTaskPOI(index)
	local existingButton = _G["WorldMapFrameTaskPOI"..index];
	if existingButton then
		return existingButton;
	end

	if (NUM_WORLDMAP_TASK_POIS < index) then
		NUM_WORLDMAP_TASK_POIS = index;
	end

	local button = CreateFrame("Button", "WorldMapFrameTaskPOI"..index, WorldMapPOIFrame);
	button:SetFlattensRenderLayers(true);
	button:RegisterForClicks("LeftButtonUp", "RightButtonUp");
	button:SetScript("OnEnter", TaskPOI_OnEnter);
	button:SetScript("OnLeave", TaskPOI_OnLeave);
	button:SetScript("OnClick", TaskPOI_OnClick);
	button:SetScript("OnHide", TaskPOI_OnHide);

	button.UpdateTooltip = TaskPOI_OnEnter;

	button.Texture = button:CreateTexture(button:GetName().."Texture", "OVERLAY");

	button.Glow = button:CreateTexture(button:GetName().."Glow", "BACKGROUND", nil, -2);
	button.Glow:SetSize(50, 50);
	button.Glow:SetPoint("CENTER");
	button.Glow:SetTexture("Interface/WorldMap/UI-QuestPoi-IconGlow.tga");
	button.Glow:SetBlendMode("ADD");

	button.SelectedGlow = button:CreateTexture(button:GetName().."SelectedGlow", "OVERLAY", nil, 2);
	button.SelectedGlow:SetBlendMode("ADD");

	button.CriteriaMatchRing = button:CreateTexture(button:GetName().."CriteriaMatchRing", "BACKGROUND", nil, 2);
	button.CriteriaMatchRing:SetAtlas("worldquest-emissary-ring", true)
	button.CriteriaMatchRing:SetPoint("CENTER", 0, 0)

	button.SpellTargetGlow = button:CreateTexture(button:GetName().."SpellTargetGlow", "OVERLAY", nil, 1);
	button.SpellTargetGlow:SetAtlas("worldquest-questmarker-abilityhighlight", true);
	button.SpellTargetGlow:SetAlpha(.6);
	button.SpellTargetGlow:SetBlendMode("ADD");
	button.SpellTargetGlow:SetPoint("CENTER", 0, 0);

	button.Underlay = button:CreateTexture(button:GetName().."Underlay", "BACKGROUND");
	button.Underlay:SetWidth(34);
	button.Underlay:SetHeight(34);
	button.Underlay:SetPoint("CENTER", 0, -1);

	button.TimeLowFrame = CreateFrame("Frame", nil, button);
	button.TimeLowFrame:SetSize(22, 22);
	button.TimeLowFrame:SetPoint("CENTER", -10, -10);
	button.TimeLowFrame.Texture = button.TimeLowFrame:CreateTexture(nil, "OVERLAY");
	button.TimeLowFrame.Texture:SetAllPoints(button.TimeLowFrame);
	button.TimeLowFrame.Texture:SetAtlas("worldquest-icon-clock");

	button.TrackedCheck = button:CreateTexture(button:GetName().."TrackedCheck", "OVERLAY", nil, 1);
	button.TrackedCheck:SetAtlas("worldquest-emissary-tracker-checkmark", true);
	button.TrackedCheck:SetPoint("BOTTOM", button, "BOTTOMRIGHT", 0, -2);

	WorldMap_ResetPOI(button, true, false);

	return button;
end

function WorldMap_CreateScenarioPOI(index)
	local button = CreateFrame("Button", "WorldMapFrameScenarioPOI"..index, WorldMapPOIFrame);
	button:SetWidth(32);
	button:SetHeight(32);
	button:SetScript("OnEnter", ScenarioPOI_OnEnter);
	button:SetScript("OnLeave", ScenarioPOI_OnLeave);

	local texture = button:CreateTexture(button:GetName().."Texture", "BACKGROUND");
	texture:SetWidth(16);
	texture:SetHeight(16);
	texture:SetPoint("CENTER", 0, 0);
	texture:SetTexture("Interface\\Minimap\\ObjectIconsAtlas");
end

function WorldMap_GetGraveyardButton(index)
	local frameName = "WorldMapFrameGraveyard"..index;
	local button = _G[frameName];
	if ( not button ) then
		button = CreateFrame("Button", frameName, WorldMapPOIFrame);
		button:SetWidth(32);
		button:SetHeight(32);
		button:RegisterForClicks("LeftButtonUp", "RightButtonUp");
		button:SetScript("OnEnter", nil);
		button:SetScript("OnLeave", nil);
		button:SetScript("OnClick", nil);

		local texture = button:CreateTexture(button:GetName().."Texture", "ARTWORK");
		texture:SetWidth(48);
		texture:SetHeight(48);
		texture:SetPoint("CENTER", 0, 0);
		button.texture = texture;
	end
	return button;
end

function WorldMapLevelDropDown_Update()
	UIDropDownMenu_Initialize(WorldMapLevelDropDown, WorldMapLevelDropDown_Initialize);
	UIDropDownMenu_SetWidth(WorldMapLevelDropDown, 130);

	local mapID = C_Map.GetCurrentMapID();
	local mapGroupID = C_Map.GetMapGroupID(mapID);
	if ( not mapGroupID ) then
		UIDropDownMenu_ClearAll(WorldMapLevelDropDown);
		WorldMapLevelDropDown:Hide();
	else
		-- find the current floor in the list of levels, that's its ID in the dropdown
		local mapGroupMembersInfo = C_Map.GetMapGroupMembersInfo(mapGroupID);
		local levelID = 1;
		for id, mapGroupMemberInfo in ipairs(mapGroupMembersInfo) do
			if (mapID == mapGroupMemberInfo.mapID) then
				levelID = id;
			end
		end

		UIDropDownMenu_SetSelectedID(WorldMapLevelDropDown, levelID);
		WorldMapLevelDropDown:Show();
	end
end

function WorldMapLevelDropDown_Initialize()
	local info = UIDropDownMenu_CreateInfo();
	local mapID = C_Map.GetCurrentMapID();
	local mapGroupID = C_Map.GetMapGroupID(mapID);
	if not mapGroupID then
		return;
	end

	local mapGroupMembersInfo = C_Map.GetMapGroupMembersInfo(mapGroupID);
	for i, mapGroupMemberInfo in ipairs(mapGroupMembersInfo) do
		info.text = mapGroupMemberInfo.name;
		info.func = WorldMapLevelButton_OnClick;
		info.checked = (mapID == mapGroupMemberInfo.mapID);
		UIDropDownMenu_AddButton(info);
	end
end

function WorldMapLevelButton_OnClick(self)
	local dropDownID = self:GetID();
	UIDropDownMenu_SetSelectedID(WorldMapLevelDropDown, dropDownID);

	local mapID = C_Map.GetCurrentMapID();
	local mapGroupID = C_Map.GetMapGroupID(mapID);
	if not mapGroupID then
		return;
	end

	local mapGroupMembersInfo = C_Map.GetMapGroupMembersInfo(mapGroupID);
	if (dropDownID <= #mapGroupMembersInfo) then
		local uiMapID = mapGroupMembersInfo[dropDownID].mapID;
		SetMapByID(uiMapID);
		WorldMapScrollFrame_ResetZoom();
	end
end

function WorldMapZoomOutButton_OnClick()
	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
	WorldMapTooltip:Hide();

	-- check if code needs to zoom out before going to the continent map
	local mapInfo = C_Map.GetMapInfo(C_Map.GetCurrentMapID());
	if mapInfo then
		SetMapByID(mapInfo.parentMapID);
	end
end

function WorldMapButton_OnClick(button, mouseButton)
	if ( WorldMapButton.ignoreClick ) then
		WorldMapButton.ignoreClick = false;
		return;
	end
	CloseDropDownMenus();

	-- If currently over units then see if they should handle the click before moving on to the zoom
	if ( WorldMap_HandleUnitClick(WorldMapUnitPositionFrame:GetCurrentMouseOverUnits(), mouseButton) ) then
		return;
	elseif ( mouseButton == "LeftButton" ) then
		local x, y = GetCursorPosition();
		x = x / button:GetEffectiveScale();
		y = y / button:GetEffectiveScale();

		local centerX, centerY = button:GetCenter();
		local width = button:GetWidth();
		local height = button:GetHeight();
		local adjustedY = (centerY + (height/2) - y) / height;
		local adjustedX = (x - (centerX - (width/2))) / width;
		ProcessMapClick( adjustedX, adjustedY);
	elseif ( mouseButton == "RightButton" ) then
		WorldMapZoomOutButton_OnClick();
	elseif ( GetBindingFromClick(mouseButton) ==  "TOGGLEWORLDMAP" ) then
		ToggleWorldMap();
	end
end

function WorldMapFakeButton_OnClick(button, mouseButton)
	if ( WorldMapButton.ignoreClick ) then
		WorldMapButton.ignoreClick = false;
		return;
	end
	if ( mouseButton == "LeftButton" ) then
		SetMapByID(button.uiMapID);
	else
		WorldMapZoomOutButton_OnClick();
	end
end

function WorldMapButton_OnUpdate(self, elapsed)
	local x, y = GetCursorPosition();
	if ( WorldMapScrollFrame.panning ) then
		WorldMapScrollFrame_OnPan(x, y);
	end
	x = x / self:GetEffectiveScale();
	y = y / self:GetEffectiveScale();

	local centerX, centerY = self:GetCenter();
	local width = self:GetWidth();
	local height = self:GetHeight();
	local adjustedY = (centerY + (height/2) - y ) / height;
	local adjustedX = (x - (centerX - (width/2))) / width;

	local name, fileDataID, texPercentageX, texPercentageY, textureX, textureY, scrollChildX, scrollChildY, minLevel, maxLevel, petMinLevel, petMaxLevel
	if ( WorldMapScrollFrame:IsMouseOver() ) then

	end

	WorldMapFrameAreaPetLevels:SetText(""); --make sure pet level is cleared

	local effectiveAreaName = name;
	WorldMapFrame_ClearAreaLabel(WORLDMAP_AREA_LABEL_TYPE.AREA_NAME);

	if ( not WorldMapFrame.poiHighlight ) then
		WorldMapFrame_UpdateInvasion();

		if ( WorldMapFrame.maelstromZoneText ) then
			effectiveName = WorldMapFrame.maelstromZoneText;

			minLevel = WorldMapFrame.minLevel;
			name = WorldMapFrame.maelstromZone
			maxLevel = WorldMapFrame.maxLevel;
			petMinLevel = WorldMapFrame.petMinLevel;
			petMaxLevel = WorldMapFrame.petMaxLevel;
		end
		if (name and minLevel and maxLevel and minLevel > 0 and maxLevel > 0) then
			local playerLevel = UnitLevel("player");
			local color;
			if (playerLevel < minLevel) then
				color = GetQuestDifficultyColor(minLevel);
			elseif (playerLevel > maxLevel) then
				--subtract 2 from the maxLevel so zones entirely below the player's level won't be yellow
				color = GetQuestDifficultyColor(maxLevel - 2);
			else
				color = QuestDifficultyColors["difficult"];
			end
			color = ConvertRGBtoColorString(color);
			if (minLevel ~= maxLevel) then
				effectiveAreaName = effectiveAreaName..color.." ("..minLevel.."-"..maxLevel..")"..FONT_COLOR_CODE_CLOSE;
			else
				effectiveAreaName = effectiveAreaName..color.." ("..maxLevel..")"..FONT_COLOR_CODE_CLOSE;
			end
		end

		WorldMapFrame_SetAreaLabel(WORLDMAP_AREA_LABEL_TYPE.AREA_NAME, effectiveAreaName);

		local _, _, _, _, locked = C_PetJournal.GetPetLoadOutInfo(1);
		if (not locked and GetCVarBool("showTamers")) then --don't show pet levels for people who haven't unlocked battle petting
			if (petMinLevel and petMaxLevel and petMinLevel > 0 and petMaxLevel > 0) then
				local teamLevel = C_PetJournal.GetPetTeamAverageLevel();
				local color
				if (teamLevel) then
					if (teamLevel < petMinLevel) then
						--add 2 to the min level because it's really hard to fight higher level pets
						color = GetRelativeDifficultyColor(teamLevel, petMinLevel + 2);
					elseif (teamLevel > petMaxLevel) then
						color = GetRelativeDifficultyColor(teamLevel, petMaxLevel);
					else
						--if your team is in the level range, no need to call the function, just make it yellow
						color = QuestDifficultyColors["difficult"];
					end
				else
					--If you unlocked pet battles but have no team, level ranges are meaningless so make them grey
					color = QuestDifficultyColors["header"];
				end
				color = ConvertRGBtoColorString(color);
				if (petMinLevel ~= petMaxLevel) then
					WorldMapFrameAreaPetLevels:SetText(WORLD_MAP_WILDBATTLEPET_LEVEL..color.."("..petMinLevel.."-"..petMaxLevel..")"..FONT_COLOR_CODE_CLOSE);
				else
					WorldMapFrameAreaPetLevels:SetText(WORLD_MAP_WILDBATTLEPET_LEVEL..color.."("..petMaxLevel..")"..FONT_COLOR_CODE_CLOSE);
				end
			end
		end
	end
	if ( fileDataID and (fileDataID > 0) ) then
		WorldMapHighlight:SetTexCoord(0, texPercentageX, 0, texPercentageY);
		WorldMapHighlight:SetTexture(fileDataID);
		textureX = textureX * width;
		textureY = textureY * height;
		scrollChildX = scrollChildX * width;
		scrollChildY = -scrollChildY * height;
		if ( (textureX > 0) and (textureY > 0) ) then
			WorldMapHighlight:SetWidth(textureX);
			WorldMapHighlight:SetHeight(textureY);
			WorldMapHighlight:SetPoint("TOPLEFT", "WorldMapDetailFrame", "TOPLEFT", scrollChildX, scrollChildY);
			WorldMapHighlight:Show();
			--WorldMapFrameAreaLabel:SetPoint("TOP", "WorldMapHighlight", "TOP", 0, 0);
		end

	else
		WorldMapHighlight:Hide();
	end

	WorldMapUnitPositionFrame:UpdatePlayerPins();

	-- Position flags
	do
		local flagSize = WorldMapFrame_InWindowedMode() and BATTLEFIELD_ICON_SIZE_WINDOW or BATTLEFIELD_ICON_SIZE_FULL;
		local flagScale = 1 / WorldMapDetailFrame:GetScale();

		WorldMapFrame.flagsPool:ReleaseAll();
		for flagIndex = 1, GetNumBattlefieldFlagPositions() do
			local flagX, flagY, flagToken = GetBattlefieldFlagPosition(flagIndex);
			if flagX ~= 0 or flagY ~= 0 then
				local flagFrame = WorldMapFrame.flagsPool:Acquire();

				flagX = flagX * WorldMapDetailFrame:GetWidth();
				flagY = -flagY * WorldMapDetailFrame:GetHeight();
				flagFrame:SetPoint("CENTER", WorldMapDetailFrame, "TOPLEFT", flagX / flagScale, flagY / flagScale);
				flagFrame.Texture:SetTexture("Interface\\WorldStateFrame\\"..flagToken);

				flagFrame:SetSize(flagSize, flagSize);
				flagFrame:SetScale(flagScale);
				flagFrame:Show();
			end
		end
	end

	if WorldMap_DoesCurrentMapHideMapIcons() then
		WorldMapCorpse:Hide();
		WorldMapDeathRelease:Hide();
	else
		-- Position corpse
		local corpsePosition = C_DeathInfo.GetCorpseMapPosition(C_Map.GetCurrentMapID());
		if ( not corpsePosition ) then
			WorldMapCorpse:Hide();
		else
			local corpseX = corpsePosition.x * WorldMapDetailFrame:GetWidth();
			local corpseY = -corpsePosition.y * WorldMapDetailFrame:GetHeight();

			WorldMapCorpse:SetPoint("CENTER", "WorldMapDetailFrame", "TOPLEFT", corpseX, corpseY);
			if ( WorldMapFrame_InWindowedMode() ) then
				WorldMapCorpse:SetFrameStrata("DIALOG");
			else
				WorldMapCorpse:SetFrameStrata("FULLSCREEN_DIALOG");
			end
			WorldMapCorpse:Show();
		end

		-- Position Death Release marker
		local deathReleasePosition = C_DeathInfo.GetDeathReleasePosition(C_Map.GetCurrentMapID());
		if (not deathReleasePosition or UnitIsGhost("player")) then
			WorldMapDeathRelease:Hide();
		else
			local deathReleaseX = deathReleasePosition.x * WorldMapDetailFrame:GetWidth();
			local deathReleaseY = -deathReleasePosition.y * WorldMapDetailFrame:GetHeight();

			WorldMapDeathRelease:SetPoint("CENTER", "WorldMapDetailFrame", "TOPLEFT", deathReleaseX, deathReleaseY);
			WorldMapDeathRelease:SetFrameStrata("DIALOG");
			WorldMapDeathRelease:Show();
		end
	end

	-- position vehicles
	local numVehicles;
	if ( MapUtil.IsMapTypeZone(C_Map.GetCurrentMapID()) ) then
		-- only show vehicles on zone maps
		numVehicles = GetNumBattlefieldVehicles();
	else
		numVehicles = 0;
	end

	local totalVehicles = #MAP_VEHICLES;
	local playerBlipFrameLevel = WorldMapUnitPositionFrame:GetFrameLevel();
	local index = 0;
	for i=1, numVehicles do
		if (i > totalVehicles) then
			local vehicleName = "WorldMapVehicles"..i;
			MAP_VEHICLES[i] = CreateFrame("FRAME", vehicleName, WorldMapPOIFrame, "WorldMapVehicleTemplate");
			MAP_VEHICLES[i].texture = _G[vehicleName.."Texture"];
		end
		local vehicleX, vehicleY, unitName, isPossessed, vehicleType, orientation, isPlayer, isAlive = GetBattlefieldVehicleInfo(i, C_Map.GetCurrentMapID());
		if ( vehicleX and isAlive and not isPlayer and VehicleUtil.IsValidVehicleType(vehicleType) ) then
			local vehicleInfo = VehicleUtil.GetVehicleInfo(vehicleType);
			local mapVehicleFrame = MAP_VEHICLES[i];
			vehicleX = vehicleX * WorldMapDetailFrame:GetWidth() * WorldMapDetailFrame:GetScale();
			vehicleY = -vehicleY * WorldMapDetailFrame:GetHeight() * WorldMapDetailFrame:GetScale();
			mapVehicleFrame.texture:SetRotation(orientation);
			mapVehicleFrame.texture:SetTexture(WorldMap_GetVehicleTexture(vehicleType, isPossessed));
			mapVehicleFrame:SetPoint("CENTER", "WorldMapDetailFrame", "TOPLEFT", vehicleX, vehicleY);
			mapVehicleFrame:SetWidth(vehicleInfo:GetWidth());
			mapVehicleFrame:SetHeight(vehicleInfo:GetHeight());
			mapVehicleFrame.name = unitName;
			if ( vehicleInfo:ShouldDrawBelowPlayerBlips() ) then
				mapVehicleFrame:SetFrameLevel(playerBlipFrameLevel - 1);
			else
				mapVehicleFrame:SetFrameLevel(playerBlipFrameLevel + 1);
			end
			mapVehicleFrame:Show();
			index = i;	-- save for later
		else
			MAP_VEHICLES[i]:Hide();
		end

	end
	if (index < totalVehicles) then
		for i=index+1, totalVehicles do
			MAP_VEHICLES[i]:Hide();
		end
	end

	WorldMapFrame_EvaluateAreaLabels();

	WorldMapUnitPositionFrame:UpdateTooltips(WorldMapTooltip);
end

function WorldMap_UpdateBattlefieldFlagSizes(size)
	for flagFrame in WorldMapFrame.flagsPool:EnumerateActive() do
		flagFrame:SetSize(size, size);
	end
end

function WorldMap_UpdateBattlefieldFlagScales()
	local newScale = 1 / WorldMapDetailFrame:GetScale();
	for flagFrame in WorldMapFrame.flagsPool:EnumerateActive() do
		flagFrame:SetScale(newScale);
	end
end

function WorldMap_GetVehicleTexture(vehicleType, isPossessed)
	if ( not vehicleType ) then
		return;
	end
	if ( not isPossessed ) then
		isPossessed = 1;
	else
		isPossessed = 2;
	end
	if ( not VehicleUtil.IsValidVehicleType(vehicleType) ) then
		return nil;
	end
	return VehicleUtil.GetVehicleInfo(vehicleType):GetTexture(isPossessed);
end

function WorldMapUnit_OnEnter(self, motion)
	-- Adjust the tooltip based on which side the unit button is on
	SetMapTooltipPosition(WorldMapTooltip, self);

	-- See which POI's are in the same region and include their names in the tooltip
	local unitButton;
	local newLineString = "";
	local tooltipText = "";

	-- Check Vehicles
	local numVehicles = GetNumBattlefieldVehicles();
	for _, v in pairs(MAP_VEHICLES) do
		if ( v:IsVisible() and v:IsMouseOver() ) then
			if ( v.name ) then
				tooltipText = tooltipText..newLineString..v.name;
			end
			newLineString = "\n";
		end
	end
	-- Check debug objects
	for i = 1, NUM_WORLDMAP_DEBUG_OBJECTS do
		unitButton = _G["WorldMapDebugObject"..i];
		if ( unitButton:IsVisible() and unitButton:IsMouseOver() ) then
			tooltipText = tooltipText..newLineString..unitButton.name;
			newLineString = "\n";
		end
	end
	WorldMapTooltip:SetText(tooltipText);
	WorldMapTooltip:Show();
end

function WorldMapUnit_OnLeave(self, motion)
	WorldMapTooltip:Hide();
end

function WorldMap_HandleUnitClick(mouseOverUnits, mouseButton)
	BAD_BOY_COUNT = 0;

	if ( GetCVarBool("enablePVPNotifyAFK") and mouseButton == "RightButton" ) then
		local _, instanceType = IsInInstance();
		if ( instanceType == "pvp" or  IsInActiveWorldPVP() ) then
			local timeNowSeconds = GetTime();
			for unit in pairs(mouseOverUnits) do
				if ( not GetIsPVPInactive(unit, timeNowSeconds) ) then
					BAD_BOY_COUNT = BAD_BOY_COUNT + 1;
					BAD_BOY_UNITS[BAD_BOY_COUNT] = unit;
				end
			end
		end

		if ( BAD_BOY_COUNT > 0 ) then
			UIDropDownMenu_Initialize( WorldMapUnitDropDown, WorldMapUnitDropDown_Initialize, "MENU");
			ToggleDropDownMenu(1, nil, WorldMapUnitDropDown, "cursor", 0, -5);
			return true;
		end
	end

	return false;
end

function WorldMapUnitDropDown_Initialize()
	local info = UIDropDownMenu_CreateInfo();
	info.text = PVP_REPORT_AFK;
	info.notClickable = 1;
	info.isTitle = 1;
	info.notCheckable = true;
	UIDropDownMenu_AddButton(info);

	if ( BAD_BOY_COUNT > 0 ) then
		for i=1, BAD_BOY_COUNT do
			info = UIDropDownMenu_CreateInfo();
			info.func = WorldMapUnitDropDown_OnClick;
			info.arg1 = BAD_BOY_UNITS[i];
			info.text = UnitName( BAD_BOY_UNITS[i] );
			info.notCheckable = true;
			UIDropDownMenu_AddButton(info);
		end

		if ( BAD_BOY_COUNT > 1 ) then
			info = UIDropDownMenu_CreateInfo();
			info.func = WorldMapUnitDropDown_ReportAll_OnClick;
			info.text = PVP_REPORT_AFK_ALL;
			info.notCheckable = true;
			UIDropDownMenu_AddButton(info);
		end
	end

	info = UIDropDownMenu_CreateInfo();
	info.text = CANCEL;
	info.notCheckable = true;
	UIDropDownMenu_AddButton(info);
end

function WorldMapUnitDropDown_OnClick(self, unit)
	ReportPlayerIsPVPAFK(unit);
end

function WorldMapUnitDropDown_ReportAll_OnClick()
	if ( BAD_BOY_COUNT > 0 ) then
		for i=1, BAD_BOY_COUNT do
			ReportPlayerIsPVPAFK(BAD_BOY_UNITS[i]);
		end
	end
end

function WorldMapFrame_SyncMaximizeMinimizeButton(maximizeMinimizeFrame)
	if (WorldMapFrame_InWindowedMode()) then
		maximizeMinimizeFrame.MinimizeButton:Hide();
		maximizeMinimizeFrame.MaximizeButton:Show();
	else
		maximizeMinimizeFrame.MinimizeButton:Show();
		maximizeMinimizeFrame.MaximizeButton:Hide();
	end
end

function WorldMapFrame_ToggleWindowSize()
	-- close the frame first so the UI panel system can do its thing
	WorldMapFrame.toggling = true;
	ToggleFrame(WorldMapFrame);
	-- apply magic
	if ( WorldMapFrame_InWindowedMode() ) then
		if ( not WorldMapFrame.questLogMode ) then
			SetCVar("miniWorldMap", 0);
		end
		WorldMap_ToggleSizeUp();
	else
		if ( not WorldMapFrame.questLogMode ) then
			SetCVar("miniWorldMap", 1);
		end
		WorldMap_ToggleSizeDown();
		if ( GetCVarBool("questLogOpen") or WorldMapFrame.questLogMode ) then
			QuestMapFrame_Show();
		end
	end
	-- reopen the frame
	WorldMapFrame.blockWorldMapUpdate = true;
	ToggleFrame(WorldMapFrame);
	WorldMapFrame.blockWorldMapUpdate = nil;
	WorldMapFrame_UpdateMap();
	QuestMapFrame_UpdateAll();
	WorldMapFrame_SyncMaximizeMinimizeButton(WorldMapFrame.BorderFrame.MaximizeMinimizeFrame);
end

function WorldMap_ToggleSizeUp()
	QuestMapFrame_Hide();
	WorldMapFrame.UIElementsFrame.OpenQuestPanelButton:Hide();
	HelpPlate_Hide();
	WorldMapFrame.MainHelpButton:Hide();
	WORLDMAP_SETTINGS.size = WORLDMAP_FULLMAP_SIZE;
	-- adjust main frame
	WorldMapFrame:SetParent(nil);
	WorldMapFrame:SetFrameStrata("FULLSCREEN");
	WorldMapTooltip:SetFrameStrata("TOOLTIP");
	WorldMapCompareTooltip1:SetFrameStrata("TOOLTIP");
	WorldMapCompareTooltip2:SetFrameStrata("TOOLTIP");
	WorldMapFrame:ClearAllPoints();
	WorldMapFrame:SetAllPoints();
	SetUIPanelAttribute(WorldMapFrame, "area", "full");
	SetUIPanelAttribute(WorldMapFrame, "allowOtherPanels", false);
	WorldMapFrame:EnableKeyboard(true);
	-- adjust map frames
	WorldMapDetailFrame:SetScale(WORLDMAP_FULLMAP_SIZE);
	WorldMapFrame.BorderFrame:SetSize(1022, 766);
	WorldMapFrameAreaFrame:SetScale(WORLDMAP_FULLMAP_SIZE);
	WorldMapUnitPositionFrame:SetScale(WORLDMAP_FULLMAP_SIZE);
	WorldMapFrame_ResetPOIHitTranslations();
	QUEST_POI_FRAME_WIDTH = WorldMapDetailFrame:GetWidth() * WORLDMAP_FULLMAP_SIZE;
	QUEST_POI_FRAME_HEIGHT = WorldMapDetailFrame:GetHeight() * WORLDMAP_FULLMAP_SIZE;
	-- show big window elements
	BlackoutWorld:Show();

	WorldMapFrame.BorderFrame.Inset:SetPoint("TOPLEFT", 5, -63);
	WorldMapFrame.BorderFrame.Inset:SetPoint("BOTTOMRIGHT", -7, 28);
	WorldMapScrollFrame:ClearAllPoints();
	WorldMapScrollFrame:SetPoint("TOP", 0, -68);
	WorldMapScrollFrame:SetSize(1002, 668);

	ButtonFrameTemplate_HidePortrait(WorldMapFrame.BorderFrame);
	WorldMapFrame.NavBar:SetPoint("TOPLEFT", WorldMapFrame.BorderFrame, 10, -23);
	WorldMapFrame.NavBar:SetWidth(1000);
	-- hide small window elements
	WorldMapTitleButton:Hide();
	ToggleMapFramerate();
	-- floor dropdown
	--WorldMapLevelDropDown:SetPoint("TOPLEFT", WorldMapDetailFrame, -18, 2);
	-- tiny adjustments

	if (GetCVarBool("questPOI")) then
		WorldMapUnitPositionFrame:SetPinSize("player", PLAYER_ARROW_SIZE_FULL_WITH_QUESTS);
	else
		WorldMapUnitPositionFrame:SetPinSize("player", PLAYER_ARROW_SIZE_FULL_NO_QUESTS);
	end

	WorldMapUnitPositionFrame:SetPinSize("party", GROUP_MEMBER_SIZE_FULL);
	WorldMapUnitPositionFrame:SetPinSize("raid", RAID_MEMBER_SIZE_FULL);
	WorldMap_UpdateBattlefieldFlagSizes(BATTLEFIELD_ICON_SIZE_FULL);
	WorldMap_UpdateBattlefieldFlagScales();
end

function WorldMap_ToggleSizeDown()
	WorldMapFrame.UIElementsFrame.OpenQuestPanelButton:Show();
	WorldMapFrame.MainHelpButton:Show();
	WORLDMAP_SETTINGS.size = WORLDMAP_WINDOWED_SIZE;
	-- adjust main frame
	WorldMapFrame:SetParent(UIParent);
	WorldMapFrame:SetFrameStrata("HIGH");
	WorldMapTooltip:SetFrameStrata("TOOLTIP");
	WorldMapCompareTooltip1:SetFrameStrata("TOOLTIP");
	WorldMapCompareTooltip2:SetFrameStrata("TOOLTIP");
	WorldMapFrame:EnableKeyboard(false);
	-- adjust map frames
	WorldMapDetailFrame:SetScale(WORLDMAP_WINDOWED_SIZE);
	WorldMapFrameAreaFrame:SetScale(WORLDMAP_WINDOWED_SIZE);
	WorldMapUnitPositionFrame:SetScale(WORLDMAP_WINDOWED_SIZE);
	WorldMapFrame_ResetPOIHitTranslations();
	QUEST_POI_FRAME_WIDTH = WorldMapDetailFrame:GetWidth() * WORLDMAP_WINDOWED_SIZE;
	QUEST_POI_FRAME_HEIGHT = WorldMapDetailFrame:GetHeight() * WORLDMAP_WINDOWED_SIZE;
	-- hide big window elements
	BlackoutWorld:Hide();
	ToggleMapFramerate();
	-- show small window elements
	WorldMapTitleButton:Show();
	-- floor dropdown
	--WorldMapLevelDropDown:SetPoint("TOPLEFT", WorldMapDetailFrame, "TOPLEFT", -18, 2);

	-- tiny adjustments
	-- pet battle level size adjustment
	WorldMapFrameAreaPetLevels:SetFontObject("SubZoneTextFont");
	-- user-movable
	WorldMapFrame:ClearAllPoints();
	SetUIPanelAttribute(WorldMapFrame, "area", "center");
	SetUIPanelAttribute(WorldMapFrame, "allowOtherPanels", true);
	WorldMapFrame:SetMovable(true);
	WorldMapFrame:SetSize(702, 534);
	WorldMapFrame.BorderFrame:SetSize(702, 534);

	WorldMapFrame.BorderFrame.Inset:SetPoint("TOPLEFT", 0, -63);
	WorldMapFrame.BorderFrame.Inset:SetPoint("BOTTOMRIGHT", -2, 1);
	ButtonFrameTemplate_ShowPortrait(WorldMapFrame.BorderFrame);
	WorldMapFrame.NavBar:SetPoint("TOPLEFT", WorldMapFrame.BorderFrame, 64, -23);
	WorldMapFrame.NavBar:SetWidth(628);

	WorldMapFrame:SetPoint("TOPLEFT", WorldMapScreenAnchor, 0, 0);
	WorldMapScrollFrame:ClearAllPoints();
	WorldMapScrollFrame:SetPoint("TOPLEFT", 3, -68);
	WorldMapScrollFrame:SetSize(696, 464);
	WorldMapUnitPositionFrame:SetPinSize("player", PLAYER_ARROW_SIZE_WINDOW);
	WorldMapUnitPositionFrame:SetPinSize("party", GROUP_MEMBER_SIZE_WINDOW);
	WorldMapUnitPositionFrame:SetPinSize("raid", RAID_MEMBER_SIZE_WINDOW);
	WorldMap_UpdateBattlefieldFlagSizes(BATTLEFIELD_ICON_SIZE_WINDOW);
	WorldMap_UpdateBattlefieldFlagScales();
end

function WorldMapFrame_UpdateMap(skipDropDownUpdate)
	WorldMapFrame_Update();
	if (not skipDropDownUpdate) then
		WorldMapLevelDropDown_Update();
		WorldMapNavBar_Update();
	end
end

function ScenarioPOIFrame_OnUpdate(self)
	ScenarioPOIFrame:DrawNone();
	if( GetCVarBool("questPOI") ) then
		ScenarioPOIFrame:DrawAll();
	end

	local canUpdateTooltip, mouseX, mouseY = WorldMapFrame_POITooltipUpdate(self);

	if ( not canUpdateTooltip ) then
		return;
	end

	local hasScenarioTooltip = self:UpdateMouseOverTooltip(mouseX, mouseY);
	if ( hasScenarioTooltip ) then
		WorldMapScenarioPOI_SetTooltip(self);
	else
		WorldMapTooltip:Hide();
	end
end

function WorldMapFrame_POITooltipUpdate(self,tooltipOwner)
	if ( not self:IsMouseOver() ) then
		return false;
	end
	if ( WorldMapTooltip:IsShown() and WorldMapTooltip:GetOwner() ~= (tooltipOwner or self) ) then
		return false;
	end

	if ( not self.scale ) then
		WorldMapFrame_CalculateHitTranslations(self);
	end

	local cursorX, cursorY = GetCursorPosition();
	local frameX = cursorX / self.scale - self.offsetX;
	local frameY = - cursorY / self.scale + self.offsetY;
	local adjustedX = frameX / QUEST_POI_FRAME_WIDTH;
	local adjustedY = frameY / QUEST_POI_FRAME_HEIGHT;

	return true, adjustedX, adjustedY;
end

function WorldMapScenarioPOI_SetTooltip(self)
	WorldMapTooltip:SetOwner(self, "ANCHOR_CURSOR_RIGHT", 5, 2);
	local description = self:GetScenarioTooltipText();
	WorldMapTooltip:SetText(description);
	WorldMapTooltip:Show();
end

function WorldMapQuestPOI_SetTooltip(poiButton, questLogIndex, numObjectives)
	local title, _, _, _, _, _, _, questID = GetQuestLogTitle(questLogIndex);
	WorldMapTooltip:SetOwner(poiButton or WorldMapPOIFrame, "ANCHOR_CURSOR_RIGHT", 5, 2);
	WorldMapTooltip:SetText(title);
	QuestUtils_AddQuestTypeToTooltip(WorldMapTooltip, questID, NORMAL_FONT_COLOR);

	if ( poiButton and poiButton.style ~= "numeric" ) then
		local completionText = GetQuestLogCompletionText(questLogIndex) or QUEST_WATCH_QUEST_READY;
		WorldMapTooltip:AddLine("- "..completionText, 1, 1, 1, true);
	else
		local text, finished, objectiveType;
		local numItemDropTooltips = GetNumQuestItemDrops(questLogIndex);
		if(numItemDropTooltips and numItemDropTooltips > 0) then
			for i = 1, numItemDropTooltips do
				text, objectiveType, finished = GetQuestLogItemDrop(i, questLogIndex);
				if ( text and not finished ) then
					WorldMapTooltip:AddLine(QUEST_DASH..text, 1, 1, 1, true);
				end
			end
		else
			local numPOITooltips = WorldMapBlobFrame:GetNumTooltips();
			numObjectives = numObjectives or GetNumQuestLeaderBoards(questLogIndex);
			for i = 1, numObjectives do
				if(numPOITooltips and (numPOITooltips == numObjectives)) then
					local questPOIIndex = WorldMapBlobFrame:GetTooltipIndex(i);
					text, objectiveType, finished = GetQuestPOILeaderBoard(questPOIIndex, questLogIndex);
				else
					text, objectiveType, finished = GetQuestLogLeaderBoard(i, questLogIndex);
				end
				if ( text and not finished ) then
					WorldMapTooltip:AddLine(QUEST_DASH..text, 1, 1, 1, true);
				end
			end
		end
	end
	WorldMapTooltip:Show();
end

function WorldMapQuestPOI_AppendTooltip(poiButton, questLogIndex)
	local title = GetQuestLogTitle(questLogIndex);
	WorldMapTooltip:AddLine(" ");
	WorldMapTooltip:AddLine(title);
	if ( poiButton and poiButton.style ~= "numeric" ) then
		local completionText = GetQuestLogCompletionText(questLogIndex) or QUEST_WATCH_QUEST_READY;
		WorldMapTooltip:AddLine("- "..completionText, 1, 1, 1, true);
	else
		local text, finished, objectiveType;
		local numItemDropTooltips = GetNumQuestItemDrops(questLogIndex);
		if(numItemDropTooltips and numItemDropTooltips > 0) then
			for i = 1, numItemDropTooltips do
				text, objectiveType, finished = GetQuestLogItemDrop(i, questLogIndex);
				if ( text and not finished ) then
					WorldMapTooltip:AddLine(QUEST_DASH..text, 1, 1, 1, true);
				end
			end
		else
			local numPOITooltips = WorldMapBlobFrame:GetNumTooltips();
			local numObjectives = GetNumQuestLeaderBoards(questLogIndex);
			for i = 1, numObjectives do
				if(numPOITooltips and (numPOITooltips == numObjectives)) then
					local questPOIIndex = WorldMapBlobFrame:GetTooltipIndex(i);
					text, objectiveType, finished = GetQuestPOILeaderBoard(questPOIIndex, questLogIndex);
				else
					text, objectiveType, finished = GetQuestLogLeaderBoard(i, questLogIndex);
				end
				if ( text and not finished ) then
					WorldMapTooltip:AddLine(QUEST_DASH..text, 1, 1, 1, true);
				end
			end
		end
	end
	WorldMapTooltip:Show();
end

function WorldMapBlobFrame_OnLoad(self)
	self:SetFillTexture("Interface\\WorldMap\\UI-QuestBlob-Inside");
	self:SetBorderTexture("Interface\\WorldMap\\UI-QuestBlob-Outside");
	self:SetFillAlpha(128);
	self:SetBorderAlpha(192);
	self:SetBorderScalar(1.0);
end

-- for when we need to wait a frame
function WorldMapBlobFrame_DelayedUpdateBlobs()
	WorldMapBlobFrame.updateBlobs = true;
end

function WorldMapBlobFrame_OnUpdate(self)
	if ( self.updateBlobs ) then
		WorldMapBlobFrame_UpdateBlobs();
		self.updateBlobs = nil;
	end

	local canUpdateTooltip, mouseX, mouseY = WorldMapFrame_POITooltipUpdate(self,WorldMapPOIFrame);

	if ( not canUpdateTooltip ) then
		return;
	end

	local questLogIndex, numObjectives = self:UpdateMouseOverTooltip(mouseX, mouseY);
	if ( numObjectives ) then
		WorldMapQuestPOI_SetTooltip(nil, questLogIndex, numObjectives);
	else
		WorldMapTooltip:Hide();
	end
end

function WorldMapFrame_ResetPOIHitTranslations()
	WorldMapBlobFrame.scale = nil;
	ScenarioPOIFrame.scale = nil;
end

function WorldMapFrame_CalculateHitTranslations(self)
	if ( WorldMapFrame_InWindowedMode() ) then
		self.scale = UIParent:GetScale();
	else
		self.scale = WorldMapFrame:GetScale();
	end
	self.offsetX = WorldMapScrollFrame:GetLeft() - WorldMapScrollFrame:GetHorizontalScroll();
	self.offsetY = WorldMapScrollFrame:GetTop() + WorldMapScrollFrame:GetVerticalScroll();
end

function WorldMapFrame_ResetQuestColors()
	-- FIXME
end

--- advanced options ---

function WorldMapTitleButton_OnLoad(self)
	self:RegisterForClicks("LeftButtonDown", "LeftButtonUp", "RightButtonUp");
	self:RegisterForDrag("LeftButton");
	UIDropDownMenu_Initialize(WorldMapTitleDropDown, WorldMapTitleDropDown_Initialize, "MENU");
end

function WorldMapTitleButton_OnClick(self, button)
	PlaySound(SOUNDKIT.U_CHAT_SCROLL_BUTTON);

	-- If Rightclick bring up the options menu
	if ( button == "RightButton" ) then
		ToggleDropDownMenu(1, nil, WorldMapTitleDropDown, "cursor", 0, 0);
		return;
	end

	-- Close all dropdowns
	CloseDropDownMenus();
end

function WorldMapTitleButton_OnDragStart()
	if ( not WORLDMAP_SETTINGS.locked ) then
		WorldMapScreenAnchor:ClearAllPoints();
		WorldMapFrame:ClearAllPoints();
		WorldMapFrame:StartMoving();
	end
end

function WorldMapTitleButton_OnDragStop()
	if ( not WORLDMAP_SETTINGS.locked ) then
		WorldMapFrame:StopMovingOrSizing();
		WorldMapFrame_ResetPOIHitTranslations();
		-- move the anchor
		WorldMapScreenAnchor:StartMoving();
		WorldMapScreenAnchor:SetPoint("TOPLEFT", WorldMapFrame);
		WorldMapScreenAnchor:StopMovingOrSizing();
	end
end

function WorldMapTitleDropDown_Initialize()
	local checked;
	local info = UIDropDownMenu_CreateInfo();
	info.isNotRadio = true;
	info.notCheckable = true;
	-- Lock/Unlock
	info.func = WorldMapTitleDropDown_ToggleLock;
	if ( WORLDMAP_SETTINGS.locked ) then
		info.text = UNLOCK_FRAME;
	else
		info.text = LOCK_FRAME;
	end
	UIDropDownMenu_AddButton(info, UIDROPDOWNMENU_MENU_LEVEL);
	-- Reset
	info.func = WorldMapTitleDropDown_ResetPosition;
	info.text = RESET_POSITION;
	UIDropDownMenu_AddButton(info, UIDROPDOWNMENU_MENU_LEVEL);
end

function WorldMapTitleDropDown_ToggleLock()
	WORLDMAP_SETTINGS.locked = not WORLDMAP_SETTINGS.locked;
	if ( WORLDMAP_SETTINGS.locked ) then
		SetCVar("lockedWorldMap", 1);
	else
		SetCVar("lockedWorldMap", 0);
	end
end

function WorldMapTitleDropDown_ResetPosition()
	WorldMapFrame:ClearAllPoints();
	WorldMapFrame:SetPoint("TOPLEFT", 10, -118);
	WorldMapScreenAnchor:ClearAllPoints();
	WorldMapScreenAnchor:StartMoving();
	WorldMapScreenAnchor:SetPoint("TOPLEFT", WorldMapFrame);
	WorldMapScreenAnchor:StopMovingOrSizing();
end

-- *****************************************************************************************************
-- ***** PAN AND ZOOM
-- *****************************************************************************************************
local MAX_ZOOM = 1.495;

function WorldMapScrollFrame_OnMouseWheel(self, delta)
	local scrollFrame = WorldMapScrollFrame;

	-- get the mouse position on the frame, with 0,0 at top left
	local cursorX, cursorY = GetCursorPosition();
	local relativeFrame;
	if ( WorldMapFrame_InWindowedMode() ) then
		relativeFrame = UIParent;
	else
		relativeFrame = WorldMapFrame;
	end
	local frameX = cursorX / relativeFrame:GetScale() - scrollFrame:GetLeft();
	local frameY = scrollFrame:GetTop() - cursorY / relativeFrame:GetScale();

	WorldMapScrollFrame_OnMouseWheelAtPosition(self, delta, GetCursorPosition());
end

function WorldMapScrollFrame_OnMouseWheelAtPosition(self, delta, frameX, frameY)
	local scrollFrame = WorldMapScrollFrame;
	local oldScrollH = scrollFrame:GetHorizontalScroll();
	local oldScrollV = scrollFrame:GetVerticalScroll();

	local oldScale = WorldMapDetailFrame:GetScale();
	local newScale = oldScale + delta * 0.3;
	newScale = max(WORLDMAP_SETTINGS.size, newScale);
	newScale = min(MAX_ZOOM, newScale);
	WorldMapDetailFrame:SetScale(newScale);
	QUEST_POI_FRAME_WIDTH = WorldMapDetailFrame:GetWidth() * newScale;
	QUEST_POI_FRAME_HEIGHT = WorldMapDetailFrame:GetHeight() * newScale;

	scrollFrame.maxX = QUEST_POI_FRAME_WIDTH - 1002 * WORLDMAP_SETTINGS.size;
	scrollFrame.maxY = QUEST_POI_FRAME_HEIGHT - 668 * WORLDMAP_SETTINGS.size;
	scrollFrame.zoomedIn = abs(WorldMapDetailFrame:GetScale() - WORLDMAP_SETTINGS.size) > 0.05;
	scrollFrame.mapID = C_Map.GetCurrentMapID();

	-- figure out new scroll values
	local scaleChange = newScale / oldScale;
	local newScrollH = scaleChange * ( frameX + oldScrollH ) - frameX;
	local newScrollV = scaleChange * ( frameY + oldScrollV ) - frameY;
	-- clamp scroll values
	newScrollH = min(newScrollH, scrollFrame.maxX);
	newScrollH = max(0, newScrollH);
	newScrollV = min(newScrollV, scrollFrame.maxY);
	newScrollV = max(0, newScrollV);
	-- set scroll values
	scrollFrame:SetHorizontalScroll(newScrollH);
	scrollFrame:SetVerticalScroll(newScrollV);

	WorldMapFrame_Update();
	WorldMapScrollFrame_ReanchorQuestPOIs();
	WorldMapFrame_ResetPOIHitTranslations();
	WorldMapBlobFrame_DelayedUpdateBlobs();
	WorldMap_UpdateBattlefieldFlagScales();
end

function WorldMapScrollFrame_ResetZoom()
	WorldMapScrollFrame.panning = false;
	WorldMapDetailFrame:SetScale(WORLDMAP_SETTINGS.size);
	QUEST_POI_FRAME_WIDTH = WorldMapDetailFrame:GetWidth() * WORLDMAP_SETTINGS.size;
	QUEST_POI_FRAME_HEIGHT = WorldMapDetailFrame:GetHeight() * WORLDMAP_SETTINGS.size;
	WorldMapScrollFrame:SetHorizontalScroll(0);
	WorldMapScrollFrame:SetVerticalScroll(0);
	WorldMapScrollFrame.zoomedIn = false;
	WorldMapFrame_Update();
	WorldMapScrollFrame_ReanchorQuestPOIs();
	WorldMapFrame_ResetPOIHitTranslations();
	WorldMapBlobFrame_DelayedUpdateBlobs();
end

function WorldMapScrollFrame_ReanchorQuestPOIs()
	for _, poiType in pairs(WorldMapPOIFrame.poiTable) do
		for _, poiButton in pairs(poiType) do
			if ( poiButton.used ) then
				local _, posX, posY = QuestPOIGetIconInfo(poiButton.questID);
				WorldMapPOIFrame_AnchorPOI(poiButton, posX, posY, WORLD_MAP_POI_FRAME_LEVEL_OFFSETS.TRACKED_QUEST);
			end
		end
	end
end

function WorldMapScrollFrame_OnPan(cursorX, cursorY)
	local dx = WorldMapScrollFrame.cursorX - cursorX;
	local dy = cursorY - WorldMapScrollFrame.cursorY;
	if ( abs(dx) >= 1 or abs(dy) >= 1 ) then
		WorldMapScrollFrame.moved = true;
		local x = max(0, dx + WorldMapScrollFrame.x);
		x = min(x, WorldMapScrollFrame.maxX);
		WorldMapScrollFrame:SetHorizontalScroll(x);
		local y = max(0, dy + WorldMapScrollFrame.y);
		y = min(y, WorldMapScrollFrame.maxY);
		WorldMapScrollFrame:SetVerticalScroll(y);
		WorldMapFrame_ResetPOIHitTranslations();
		WorldMapBlobFrame_DelayedUpdateBlobs();
	end
end

function WorldMapButton_OnMouseDown(self, button)
	if ( button == "LeftButton" and WorldMapScrollFrame.zoomedIn ) then
		WorldMapScrollFrame.panning = true;
		local x, y = GetCursorPosition();
		WorldMapScrollFrame.cursorX = x;
		WorldMapScrollFrame.cursorY = y;
		WorldMapScrollFrame.x = WorldMapScrollFrame:GetHorizontalScroll();
		WorldMapScrollFrame.y = WorldMapScrollFrame:GetVerticalScroll();
		WorldMapScrollFrame.moved = false;
	end
end

function WorldMapButton_OnMouseUp(self, button)
	if ( button == "LeftButton" and WorldMapScrollFrame.panning ) then
		WorldMapScrollFrame.panning = false;
		if ( WorldMapScrollFrame.moved ) then
			WorldMapButton.ignoreClick = true;
		end
	end
end

-- *****************************************************************************************************
-- ***** POI FRAME
-- *****************************************************************************************************

function WorldMapPOIFrame_AnchorPOI(poiButton, posX, posY, frameLevelOffset)
	if ( posX and posY ) then
		posX = posX * QUEST_POI_FRAME_WIDTH;
		posY = posY * QUEST_POI_FRAME_HEIGHT;
		-- keep outlying POIs within map borders
		if ( posY < QUEST_POI_FRAME_INSET ) then
			posY = QUEST_POI_FRAME_INSET;
		elseif ( posY > QUEST_POI_FRAME_HEIGHT - 12 ) then
			posY = QUEST_POI_FRAME_HEIGHT - 12;
		end
		if ( posX < QUEST_POI_FRAME_INSET ) then
			posX = QUEST_POI_FRAME_INSET;
		elseif ( posX > QUEST_POI_FRAME_WIDTH - 12 ) then
			posX = QUEST_POI_FRAME_WIDTH - 12;
		end
		poiButton:SetPoint("CENTER", WorldMapPOIFrame, "TOPLEFT", posX, -posY);

		if ( WarfrontTooltipController:IsRelatedPOI(poiButton.poiID) ) then
			frameLevelOffset = frameLevelOffset + 1;
		end

		poiButton:SetFrameLevel(poiButton:GetParent():GetFrameLevel() + frameLevelOffset);
	end
end

function WorldMapPOIFrame_Update(poiTable)
	QuestPOI_ResetUsage(WorldMapPOIFrame);
	local focusedQuestID = WorldMapFrame:GetFocusedQuestID();
	local poiButton;
	for index, questID in pairs(poiTable) do
		if ( not focusedQuestID or questID == focusedQuestID ) then
			local _, posX, posY = QuestPOIGetIconInfo(questID);
			if ( posX and posY ) then
				if ( IsQuestComplete(questID) ) then
					poiButton = QuestPOI_GetButton(WorldMapPOIFrame, questID, "map", nil);
				else
					local shownIndex = index;

					-- if a quest is being viewed there is only going to be one POI and we need to match it to the ObjectiveTracker's index for that quest.
					if ( focusedQuestID ) then
						shownIndex = 1;
						for trackerIndex, poi in ipairs(ObjectiveTrackerFrame.BlocksFrame.poiTable["numeric"]) do
							if ( poi:IsShown() ) then
								if ( focusedQuestID == poi.questID ) then
									shownIndex = trackerIndex;
									break;
								else
									shownIndex = shownIndex + 1;
								end
							end
						end
					end
					poiButton = QuestPOI_GetButton(WorldMapPOIFrame, questID, "numeric", shownIndex);
				end
				WorldMapPOIFrame_AnchorPOI(poiButton, posX, posY, WORLD_MAP_POI_FRAME_LEVEL_OFFSETS.TRACKED_QUEST);
			end
		end
	end
	WorldMapPOIFrame_SelectPOI(GetSuperTrackedQuestID());
	QuestPOI_HideUnusedButtons(WorldMapPOIFrame);
end

function WorldMapPOIFrame_SelectPOI(questID)
	-- POIs can overlap each other, bring the selection to the top
	local poiButton = QuestPOI_FindButton(WorldMapPOIFrame, questID);
	if ( poiButton ) then
		QuestPOI_SelectButton(poiButton);
		poiButton:Raise();
	else
		QuestPOI_ClearSelection(WorldMapPOIFrame);
	end
	WorldMapBlobFrame_UpdateBlobs();
end

function WorldMapBlobFrame_UpdateBlobs()
	WorldMapBlobFrame:DrawNone();
	-- always draw the blob for either the quest being viewed or the supertracked
	local questID = WorldMapFrame:GetFocusedQuestID() or GetSuperTrackedQuestID();
	-- see if there is a poiButton for it (no button == not on viewed map)
	local poiButton = QuestPOI_FindButton(WorldMapPOIFrame, questID);
	if ( poiButton and not IsQuestComplete(questID) ) then
		WorldMapBlobFrame:DrawBlob(questID, true);
	end
end

function WorldMapPOIButton_Init(self)
	self:SetScript("OnEnter", WorldMapPOIButton_OnEnter);
	self:SetScript("OnLeave", WorldMapPOIButton_OnLeave);
end

BLOB_OVERLAP_DELTA = math.pow(0.005, 2);

function WorldMapPOIButton_OnEnter(self)
	WorldMapQuestPOI_SetTooltip(self, GetQuestLogIndexByID(self.questID));

	local _, posX, posY = QuestPOIGetIconInfo(self.questID);
	for _, poiType in pairs(WorldMapPOIFrame.poiTable) do
		for _, poiButton in pairs(poiType) do
			if ( poiButton ~= self and poiButton.used ) then
				local _, otherPosX, otherPosY = QuestPOIGetIconInfo(poiButton.questID);

				if ((math.pow(posX - otherPosX, 2) + math.pow(posY - otherPosY, 2)) < BLOB_OVERLAP_DELTA) then
					WorldMapQuestPOI_AppendTooltip(poiButton, GetQuestLogIndexByID(poiButton.questID));
				end
			end
		end
	end
end

function WorldMapPOIButton_OnLeave(self)
	WorldMapTooltip:Hide();
end

function WorldMap_HijackTooltip(owner)
	WorldMapTooltip:SetParent(owner);
	WorldMapTooltip:SetFrameStrata("TOOLTIP");

	for i, tooltip in ipairs(WorldMapTooltip.ItemTooltip.Tooltip.shoppingTooltips) do
		tooltip:SetParent(owner);
		tooltip:SetFrameStrata("TOOLTIP");
	end
end

function WorldMap_RestoreTooltip()
	for i, tooltip in ipairs(WorldMapTooltip.ItemTooltip.Tooltip.shoppingTooltips) do
		tooltip:SetParent(WorldMapFrame);
		tooltip:SetFrameStrata("TOOLTIP");
	end

	WorldMapTooltip:SetParent(WorldMapFrame);
	WorldMapTooltip:SetFrameStrata("TOOLTIP");
end

-- *****************************************************************************************************
-- ***** ENCOUNTER JOURNAL STUFF
-- *****************************************************************************************************

function EncounterJournal_AddMapButtons()
	local left = WorldMapBossButtonFrame:GetLeft();
	local right = WorldMapBossButtonFrame:GetRight();
	local top = WorldMapBossButtonFrame:GetTop();
	local bottom = WorldMapBossButtonFrame:GetBottom();

	if not left or not right or not top or not bottom then
		--This frame is resizing
		WorldMapBossButtonFrame.ready = false;
		WorldMapBossButtonFrame:SetScript("OnUpdate", EncounterJournal_AddMapButtons);
		return;
	else
		WorldMapBossButtonFrame:SetScript("OnUpdate", nil);
	end

	local numEncounters = 0;
	if CanShowEncounterJournal() then
		local width = WorldMapDetailFrame:GetWidth();
		local height = WorldMapDetailFrame:GetHeight();

		local mapEncounters = C_EncounterJournal.GetEncountersOnMap(C_Map.GetCurrentMapID());
		numEncounters = #mapEncounters;
		for index, mapEncounterInfo in ipairs(mapEncounters) do
			local bossButton = _G["EJMapButton"..index];
			if not bossButton then
				bossButton = CreateFrame("Button", "EJMapButton"..index, WorldMapBossButtonFrame, "EncounterMapButtonTemplate");
			end

			local name, description, encounterID, rootSectionID, link, instanceID = EJ_GetEncounterInfo(mapEncounterInfo.encounterID);
			bossButton.instanceID = instanceID;
			bossButton.encounterID = encounterID;
			bossButton.tooltipTitle = name;
			bossButton.tooltipText = description;
			bossButton:SetPoint("CENTER", WorldMapBossButtonFrame, "BOTTOMLEFT", mapEncounterInfo.mapX*width, (1.0 - mapEncounterInfo.mapY)*height);
			local _, _, _, displayInfo = EJ_GetCreatureInfo(1, encounterID);
			bossButton.displayInfo = displayInfo;
			if ( displayInfo ) then
				SetPortraitTextureFromCreatureDisplayID(bossButton.bgImage, displayInfo);
			else
				bossButton.bgImage:SetTexture("DoesNotExist");
			end
			bossButton:Show();
		end
	end

	WorldMapFrame.hasBosses = numEncounters > 0;
	index = numEncounters + 1;
	local bossButton = _G["EJMapButton"..index];
	while bossButton do
		bossButton:Hide();
		index = index + 1;
		bossButton = _G["EJMapButton"..index];
	end

	WorldMapBossButtonFrame.ready = true;
	EncounterJournal_CheckQuestButtons();
end

function EncounterJournal_UpdateMapButtonPortraits()
	if ( WorldMapFrame:IsShown() ) then
		local index = 1;
		local bossButton = _G["EJMapButton"..index];
		while ( bossButton and bossButton:IsShown() ) do
			SetPortraitTextureFromCreatureDisplayID(bossButton.bgImage, bossButton.displayInfo);
			index = index + 1;
			bossButton = _G["EJMapButton"..index];
		end
	end
end

function EncounterJournal_CheckQuestButtons()
	if not WorldMapBossButtonFrame.ready then
		return;
	end

	--Validate that there are no quest button intersection
	local questI, bossI = 1, 1;
	local bossButton = _G["EJMapButton"..bossI];
	local questPOI = _G["poiWorldMapPOIFrame1_"..questI];
	while bossButton and bossButton:IsShown() do
		while questPOI and questPOI:IsShown() do
			local qx,qy = questPOI:GetCenter();
			local bx,by = bossButton:GetCenter();
			if not qx or not qy or not bx or not by then
				_G["EJMapButton1"]:SetScript("OnUpdate", EncounterJournal_CheckQuestButtons);
				return;
			end

			local xdis = abs(bx-qx);
			local ydis = abs(by-qy);
			local disSqr = xdis*xdis + ydis*ydis;

			if EJ_QUEST_POI_MINDIS_SQR > disSqr then
				questPOI:SetPoint("CENTER", bossButton, "BOTTOMRIGHT",  -15, 15);
			end
			questI = questI + 1;
			questPOI = _G["poiWorldMapPOIFrame1_"..questI];
		end
		questI = 1;
		bossI = bossI + 1;
		bossButton = _G["EJMapButton"..bossI];
		questPOI = _G["poiWorldMapPOIFrame1_"..questI];
	end
	if _G["EJMapButton1"] then
		_G["EJMapButton1"]:SetScript("OnUpdate", nil);
	end
end

-- *****************************************************************************************************
-- ***** MAP TRACKING DROPDOWN
-- *****************************************************************************************************

function WorldMapTrackingOptionsDropDown_Initialize()
	local info = UIDropDownMenu_CreateInfo();

	info.isTitle = true;
	info.notCheckable = true;
	info.text = WORLD_MAP_FILTER_TITLE;
	UIDropDownMenu_AddButton(info);

	info.isTitle = nil;
	info.disabled = nil;
	info.notCheckable = nil;
	info.isNotRadio = true;
	info.keepShownOnClick = true;
	info.func = WorldMapTrackingOptionsDropDown_OnClick;

	info.text = SHOW_QUEST_OBJECTIVES_ON_MAP_TEXT;
	info.value = "quests";
	info.checked = GetCVarBool("questPOI");
	UIDropDownMenu_AddButton(info);

	local prof1, prof2, arch, fish, cook, firstAid = GetProfessions();
	if arch then
		info.text = ARCHAEOLOGY_SHOW_DIG_SITES;
		info.value = "digsites";
		info.checked = GetCVarBool("digSites");
		UIDropDownMenu_AddButton(info);
	end

	if CanTrackBattlePets() then
		info.text = SHOW_PET_BATTLES_ON_MAP_TEXT;
		info.value = "tamers";
		info.checked = GetCVarBool("showTamers");
		UIDropDownMenu_AddButton(info);
	end

	-- If we aren't on a map with world quests don't show the world quest reward filter options.
	if not WorldMapFrame.UIElementsFrame.BountyBoard or not WorldMapFrame.UIElementsFrame.BountyBoard:AreBountiesAvailable() then
		return;
	end

	if prof1 or prof2 then
		info.text = SHOW_PRIMARY_PROFESSION_ON_MAP_TEXT;
		info.value = "primaryProfessionsFilter";
		info.checked = GetCVarBool("primaryProfessionsFilter");
		UIDropDownMenu_AddButton(info);
	end

	if fish or cook or firstAid then
		info.text = SHOW_SECONDARY_PROFESSION_ON_MAP_TEXT;
		info.value = "secondaryProfessionsFilter";
		info.checked = GetCVarBool("secondaryProfessionsFilter");
		UIDropDownMenu_AddButton(info);
	end

	UIDropDownMenu_AddSeparator();

	info = UIDropDownMenu_CreateInfo();
	info.isTitle = true;
	info.notCheckable = true;
	info.text = WORLD_QUEST_REWARD_FILTERS_TITLE;
	UIDropDownMenu_AddButton(info);
	info.text = nil;

	info.isTitle = nil;
	info.disabled = nil;
	info.notCheckable = nil;
	info.isNotRadio = true;
	info.keepShownOnClick = true;
	info.func = WorldMapTrackingOptionsDropDown_OnClick;

	info.text = WORLD_QUEST_REWARD_FILTERS_ORDER_RESOURCES;
	info.value = "worldQuestFilterOrderResources";
	info.checked = GetCVarBool("worldQuestFilterOrderResources");
	UIDropDownMenu_AddButton(info);

	info.text = WORLD_QUEST_REWARD_FILTERS_ARTIFACT_POWER;
	info.value = "worldQuestFilterArtifactPower";
	info.checked = GetCVarBool("worldQuestFilterArtifactPower");
	UIDropDownMenu_AddButton(info);

	info.text = WORLD_QUEST_REWARD_FILTERS_PROFESSION_MATERIALS;
	info.value = "worldQuestFilterProfessionMaterials";
	info.checked = GetCVarBool("worldQuestFilterProfessionMaterials");
	UIDropDownMenu_AddButton(info);

	info.text = WORLD_QUEST_REWARD_FILTERS_GOLD;
	info.value = "worldQuestFilterGold";
	info.checked = GetCVarBool("worldQuestFilterGold");
	UIDropDownMenu_AddButton(info);

	info.text = WORLD_QUEST_REWARD_FILTERS_EQUIPMENT;
	info.value = "worldQuestFilterEquipment";
	info.checked = GetCVarBool("worldQuestFilterEquipment");
	UIDropDownMenu_AddButton(info);
end

function WorldMapTrackingOptionsDropDown_OnClick(self)
	local checked = self.checked;
	local value = self.value;

	if (checked) then
		PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
	else
		PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_OFF);
	end

	if (value == "quests") then
		SetCVar("questPOI", checked and "1" or "0");
		QuestMapFrame_UpdateAll();
	elseif (value == "digsites") then
		SetCVar("digSites", checked and "1" or "0");
		WorldMapFrame_Update();
	elseif (value == "tamers") then
		SetCVar("showTamers", checked and "1" or "0");
		WorldMapFrame_Update();
	elseif (value == "primaryProfessionsFilter" or value == "secondaryProfessionsFilter") then
		SetCVar(value, checked and "1" or "0");
		WorldMapFrame_Update();
	elseif (value == "worldQuestFilterOrderResources" or value == "worldQuestFilterArtifactPower" or
			value == "worldQuestFilterProfessionMaterials" or value == "worldQuestFilterGold" or
			value == "worldQuestFilterEquipment") then
		-- World quest reward filter cvars
		SetCVar(value, checked and "1" or "0");
		WorldMap_UpdateQuestBonusObjectives();
	end
end

-- *****************************************************************************************************
-- ***** NAV BAR
-- *****************************************************************************************************

function WorldMapNavBar_OnButtonClick(self, button)
	C_Map.SetMap(self.data.id);
end

function WorldMapNavBar_OnDropDownEntryClick(self, mapID, navBar)
	C_Map.SetMap(mapID);
end

local function IsMapValidForDropDown(mapInfo)
	return mapInfo.mapType == Enum.UIMapType.World or mapInfo.mapType == Enum.UIMapType.Continent or mapInfo.mapType == Enum.UIMapType.Zone;
end

function WorldMapNavBar_GetDropDownList(self)
	local list = { };
	local mapInfo = C_Map.GetMapInfo(self.data.id);
	if ( mapInfo ) then
		local children = C_Map.GetMapChildrenInfo(mapInfo.parentMapID);
		if ( children ) then
			for i, childInfo in ipairs(children) do
				if ( IsMapValidForDropDown(childInfo) ) then
					local entry = { text = childInfo.name, id = childInfo.mapID, func = WorldMapNavBar_OnDropDownEntryClick };
					tinsert(list, entry);
				end
			end
			table.sort(list, function(entry1, entry2) return entry1.text < entry2.text; end);
		end
	end
	return list;
end

function WorldMapNavBar_Update()
	local hierarchy = { };
	local mapInfo = C_Map.GetMapInfo(C_Map.GetCurrentMapID());
	while mapInfo and mapInfo.parentMapID > 0 do
		local buttonData = {
			name = mapInfo.name,
			id = mapInfo.mapID,
			OnClick = WorldMapNavBar_OnButtonClick,
		};
		if ( IsMapValidForDropDown(mapInfo) ) then
			buttonData.listFunc = WorldMapNavBar_GetDropDownList;
		end
		tinsert(hierarchy, 1, buttonData);
		mapInfo = C_Map.GetMapInfo(mapInfo.parentMapID);
	end

	NavBar_Reset(WorldMapFrame.NavBar);
	for i, buttonData in ipairs(hierarchy) do
		NavBar_AddButton(WorldMapFrame.NavBar, buttonData);
	end
end

-- *****************************************************************************************************
-- ***** HELP PLATE STUFF
-- *****************************************************************************************************

WorldMapFrame_HelpPlate = {
	FramePos = { x = 4,	y = -40 },
	FrameSize = { width = 985, height = 500	},
	[1] = { ButtonPos = { x = 350,	y = -180 }, HighLightBox = { x = 0, y = -30, width = 695, height = 470 },		ToolTipDir = "DOWN",		ToolTipText = WORLD_MAP_TUTORIAL1 },
	[2] = { ButtonPos = { x = 350,	y = 16 }, HighLightBox = { x = 50, y = 16, width = 645, height = 44 },	ToolTipDir = "DOWN",	ToolTipText = WORLD_MAP_TUTORIAL4 },
}

function WorldMapFrame_ToggleTutorial()
	local helpPlate = WorldMapFrame_HelpPlate;

	if ( QuestMapFrame:IsShown() ) then
		helpPlate[3] = { ButtonPos = { x = 810,	y = -180 }, HighLightBox = { x = 700, y = -30, width = 285, height = 470 },	ToolTipDir = "DOWN",	ToolTipText = WORLD_MAP_TUTORIAL2 };
		helpPlate[4] = { ButtonPos = { x = 810,	y = 16 }, HighLightBox = { x = 700, y = 16, width = 285, height = 44 },	ToolTipDir = "DOWN",	ToolTipText = WORLD_MAP_TUTORIAL3 };
	else
		helpPlate[3] = nil;
		helpPlate[4] = nil;
	end

	if ( helpPlate and not HelpPlate_IsShowing(helpPlate) and WorldFrame:IsShown()) then
		HelpPlate_Show( helpPlate, WorldMapFrame, WorldMapFrame.MainHelpButton, true );
		SetCVarBitfield( "closedInfoFrames", LE_FRAME_TUTORIAL_WORLD_MAP_FRAME, true );
	else
		HelpPlate_Hide(true);
	end
end

WorldMapPingMixin = {};

function WorldMapPingMixin:PlayOnFrame(frame, contextData)
	if self.targetFrame ~= frame then
		if frame and frame:IsVisible() then
			self:ClearAllPoints();
			self:SetPoint("CENTER", frame);

			self:Stop();
			self:SetTargetFrame(frame);
			self:SetContextData(contextData);
			self:Play();
		else
			self:Stop();
		end
	end
end

function WorldMapPingMixin:SetTargetFrame(frame)
	-- Stop this ping from playing on any previous target
	if self.targetFrame then
		self.targetFrame.worldMapPing = nil;
	end

	-- This ping is now targeting a new frame (or nothing)
	self.targetFrame = frame;

	-- Clear out context data, it's meaningless with a new frame
	self:SetContextData(nil);

	-- If that frame is a valid target, then let it know that a ping is attached
	if frame then
		frame.worldMapPing = self;

		-- Layer this behind the frame that's targeted (could make this dynamic)
		-- Might need to reparent, this currently works because it's only operating
		-- on TaskPOI pins.
		self:SetFrameLevel(frame:GetFrameLevel() + 1);
	end
end

function WorldMapPingMixin:SetContextData(contextData)
	self.contextData = contextData;
end

function WorldMapPingMixin:GetContextData()
	return self.contextData;
end

function WorldMapPingMixin:Play()
	self.DriverAnimation:Play();
end

function WorldMapPingMixin:Stop()
	self.DriverAnimation:Stop();
end

WorldMapPingAnimationMixin = {};

function WorldMapPingAnimationMixin:OnPlay()
	local ping = self:GetParent();
	ping.ScaleAnimation:Play();
end

function WorldMapPingAnimationMixin:OnStop()
	local ping = self:GetParent();
	ping:SetTargetFrame(nil);
	ping.ScaleAnimation:Stop();
end

function WorldMapPing_StartPingQuest(questID)
	if WorldMapFrame:IsVisible() then
		local ping = WorldMapPOIFrame.POIPing;
		local target = WorldMap_GetActiveTaskPOIForQuestID(questID);
		ping:PlayOnFrame(target, questID);
	end
end

function WorldMapPing_StartPingPOI(poiFrame)
	if WorldMapFrame:IsVisible() then
		WorldMapPOIFrame.POIPing:PlayOnFrame(poiFrame);
	end
end

function WorldMapPing_StopPing(frame)
	if frame.worldMapPing then
		frame.worldMapPing:Stop();
	end
end

function WorldMapPing_UpdatePing(frame, contextData)
	if frame.worldMapPing and frame.worldMapPing:GetContextData() ~= contextData then
		frame.worldMapPing:Stop();
	end
end

function WorldMapFrame_MaximizeMinimizeFrame_OnLoad(self)
	-- We don't have the mixin handle the CVar because we use specialized logic for setting it.
	self:SetOnMaximizedCallback(WorldMapFrame_ToggleWindowSize);
	self:SetOnMinimizedCallback(WorldMapFrame_ToggleWindowSize);
end