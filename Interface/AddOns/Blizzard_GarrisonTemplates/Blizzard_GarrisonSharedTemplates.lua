GARRISON_FOLLOWER_BUSY_COLOR = { 0, 0.06, 0.22, 0.44 };
GARRISON_FOLLOWER_INACTIVE_COLOR = { 0.22, 0.06, 0, 0.44 };

---------------------------------------------------------------------------------
--- Static Popup Dialogs                                                             ---
---------------------------------------------------------------------------------

StaticPopupDialogs["CONFIRM_FOLLOWER_UPGRADE"] = {
	text = "%s",
	button1 = YES,
	button2 = NO,
	OnAccept = function(self)
		C_Garrison.CastSpellOnFollower(self.data);
	end,
	showAlert = 1,
	timeout = 0,
	exclusive = 1,
	hideOnEscape = 1
};

StaticPopupDialogs["CONFIRM_FOLLOWER_ABILITY_UPGRADE"] = {
	text = "%s",
	button1 = YES,
	button2 = NO,
	OnAccept = function(self)
		C_Garrison.CastSpellOnFollowerAbility(self.data.followerID, self.data.abilityID);
	end,
	timeout = 0,
	exclusive = 1,
	hideOnEscape = 1
};

StaticPopupDialogs["CONFIRM_FOLLOWER_TEMPORARY_ABILITY"] = {
	text = CONFIRM_GARRISON_FOLLOWER_TEMPORARY_ABILITY,
	button1 = YES,
	button2 = NO,
	OnAccept = function(self)
		C_Garrison.CastSpellOnFollower(self.data);
	end,
	showAlert = 1,
	timeout = 0,
	exclusive = 1,
	hideOnEscape = 1
};

StaticPopupDialogs["CONFIRM_FOLLOWER_EQUIPMENT"] = {
	text = "%s",
	button1 = YES,
	button2 = NO,
	OnAccept = function(self)
		if (self.data.source == "spell") then
			C_Garrison.CastSpellOnFollowerAbility(self.data.followerID, self.data.abilityID);
		elseif (self.data.source == "item") then
			C_Garrison.CastItemSpellOnFollowerAbility(self.data.followerID, self.data.abilityID);
		end
	end,
	timeout = 0,
	exclusive = 1,
	hideOnEscape = 1
};

---------------------------------------------------------------------------------
--- Follower List                                                             ---
---------------------------------------------------------------------------------

local FOLLOWER_BUTTON_HEIGHT = 56;
local CATEGORY_BUTTON_HEIGHT = 20;
local FOLLOWER_LIST_BUTTON_OFFSET = -6;
local FOLLOWER_LIST_BUTTON_INITIAL_OFFSET = -7;
local GARRISON_FOLLOWER_LIST_BUTTON_FULL_XP_WIDTH = 205;

GarrisonFollowerList = {};

function GarrisonFollowerList:Initialize(followerType)
	self.followerCountString = GARRISON_FOLLOWER_COUNT;
	self.followerTab = self:GetParent().FollowerTab;
	if (self.followerTab) then
		self.followerTab.followerList = self;
	end
	self:Setup(self:GetParent(), followerType);
end

function GarrisonFollowerList:Setup(mainFrame, followerType, followerTemplate, initialOffsetX)
	self.followers = { };
	self.followersList = { };
	self:DirtyList();
	self.followerType = followerType;

	self.listScroll.update = function() self:UpdateData(); end;
	self.listScroll.dynamic = function(offset) return GarrisonFollowerList_GetTopButton(self, offset); end;

	if (not followerTemplate) then
		followerTemplate = "GarrisonMissionFollowerOrCategoryListButtonTemplate";
	end
	if (not initialOffsetX) then
		initialOffsetX = 7;
	end
	HybridScrollFrame_CreateButtons(self.listScroll, followerTemplate, initialOffsetX, FOLLOWER_LIST_BUTTON_INITIAL_OFFSET, nil, nil, nil, FOLLOWER_LIST_BUTTON_OFFSET);
	self.listScroll.followerFrame = mainFrame;
	
	self:UpdateFollowers();

	self:RegisterEvent("GARRISON_FOLLOWER_LIST_UPDATE");
	self:RegisterEvent("GARRISON_FOLLOWER_REMOVED");
	self:RegisterEvent("GARRISON_FOLLOWER_XP_CHANGED");
	self:RegisterEvent("GARRISON_FOLLOWER_UPGRADED");
	self:RegisterEvent("GARRISON_FOLLOWER_DURABILITY_CHANGED");
	self:RegisterEvent("CURRENT_SPELL_CAST_CHANGED");
	self:RegisterEvent("CURSOR_UPDATE");
	self:SetScript("OnEvent", GarrisonFollowerList_OnEvent);
end

function GarrisonFollowerList:OnShow()
	if (self.followerTab) then
		self.followerTab.lastUpdate = GetTime();
	end
	self:StopAnimations();

	self:DirtyList();
	self:UpdateFollowers();
	-- if there's no follower displayed in the tab, select the first one
	if (self.followerTab and not self.followerTab.followerID) then
		local index;
		-- get first valid follower
		for i = 1, #self.followersList do
			index = self.followersList[i];
			if (index ~= 0) then
				break;
			end
		end
		if (index) then
			self:ShowFollower(self.followers[index].followerID);
		else
			-- empty page
			self:ShowFollower(0);
		end
	end
	if (C_Garrison.GetNumFollowers(self.followerType) >= GarrisonFollowerOptions[self.followerType].minFollowersForThreatCountersFrame) then
		self:ShowThreatCountersFrame();
	end
end

function GarrisonFollowerList:ShowThreatCountersFrame()
	GarrisonThreatCountersFrame:Show();
end

function GarrisonFollowerList:StopAnimations()
	if (self.followerTab) then
		for i = 1, #self.followerTab.AbilitiesFrame.Abilities do
			GarrisonFollowerPageAbility_StopAnimations(self.followerTab.AbilitiesFrame.Abilities[i]);
		end
	end
end

function GarrisonFollowerList:OnHide()
	self.followers = nil;
end

GarrisonMissionFollowerDurabilityMixin = { }

function GarrisonMissionFollowerDurabilityMixin:SetDurability(durability, maxDurability, durabilityLoss)
	local heartWidth = 12;
	local spacing = 2;

	durability = Clamp(durability, 0, maxDurability);
	durabilityLoss = Clamp(durabilityLoss or 0, 0, durability);
	durability = durability - durabilityLoss;
	while ((self.durability and #self.durability or 0) < maxDurability) do
		local durabilityTexture = self:CreateTexture(nil, "ARTWORK", "GarrisonMissionFollowerButtonDurabilityTemplate");
		durabilityTexture:ClearAllPoints();
		if (#self.durability == 1) then
			durabilityTexture:SetPoint("TOPLEFT");
		else
			durabilityTexture:SetPoint("TOPLEFT", self.durability[#self.durability - 1], "TOPRIGHT", spacing, 0);
		end
	end

	for i = 1, durability do
		self.durability[i]:Show();
		self.durability[i]:SetAtlas("GarrisonTroops-Health");
		self.durability[i]:SetDesaturated(false);
	end
	for i = durability + 1, durability + durabilityLoss do
		self.durability[i]:Show();
		self.durability[i]:SetAtlas("GarrisonTroops-Health-Consume");
		self.durability[i]:SetDesaturated(false);
	end
	for i = durability + durabilityLoss + 1, maxDurability do
		self.durability[i]:Show();
		self.durability[i]:SetAtlas("GarrisonTroops-Health");
		self.durability[i]:SetDesaturated(true);
	end
	for i = maxDurability + 1, (self.durability and #self.durability or 0) do
		self.durability[i]:Hide();
	end

	local width = max(1, maxDurability * heartWidth + spacing * (maxDurability - 1));
	self:SetWidth(width);
end

GarrisonFollowerListButton = { };

function GarrisonFollowerListButton:GetFollowerList()
	return self:GetParent():GetParent():GetParent();
end

GarrisonMissionFollowerOrCategoryListButtonMixin = { }

function GarrisonMissionFollowerOrCategoryListButtonMixin:GetFollowerList()
	return self:GetParent():GetParent():GetParent():GetParent();
end


function GarrisonFollowerList_OnEvent(self, event, ...)
	if (event == "GARRISON_FOLLOWER_LIST_UPDATE" or event == "GARRISON_FOLLOWER_XP_CHANGED" or event == "GARRISON_FOLLOWER_DURABILITY_CHANGED") then
		local followerTypeID = ...;
		if (followerTypeID == self.followerType) then
			if (self.followerTab and self.followerTab.followerID and self.followerTab:IsVisible()) then
				self:ShowFollower(self.followerTab.followerID);
			end
			
			if (self:IsVisible()) then
				self:DirtyList();
				self:UpdateFollowers();
			end
			
			if (self.followerTab and self.followerTab.followerID and self.followerTab:IsVisible()) then
				if (C_Garrison.GetNumFollowers(self.followerType) >= GarrisonFollowerOptions[self.followerType].minFollowersForThreatCountersFrame) then
					self:ShowThreatCountersFrame();
				end
			end
		end
		return true;
	elseif (event == "GARRISON_FOLLOWER_REMOVED") then
		local followerTypeID = ...;
		if (followerTypeID == self.followerType and self.followerTab and self.followerTab.followerID and self.followerTab:IsVisible() and not C_Garrison.GetFollowerInfo(self.followerTab.followerID) and self.followers) then
			-- viewed follower got removed, pick someone else
			local index = self.followersList[1];
			if (index and self.followers[index].followerID ~= self.followerTab.followerID) then
				self:ShowFollower(self.followers[index].followerID);
			else
				-- try the 2nd follower
				index = self.followersList[2];
				if (index) then
					self:ShowFollower(self.followers[index].followerID);
				else
					-- empty page
					self:ShowFollower(0);
				end
			end
		end
		self:DirtyList();
		return true;
	elseif (event == "GARRISON_FOLLOWER_UPGRADED") then
		if ( self.followerTab and self.followerTab.Model and self.followerTab:IsVisible() ) then
			local followerID = ...;
			if ( followerID == self.followerTab.Model.followerID ) then
				self.followerTab.Model:SetSpellVisualKit(6375);	-- level up visual
				PlaySound("UI_Garrison_CommandTable_Follower_LevelUp");
			end
		end
	elseif (event == "CURRENT_SPELL_CAST_CHANGED" or event == "CURSOR_UPDATE") then
		if (self.followerTab and self.followerTab.followerID and self:IsVisible()) then
			local followerID = self.followerTab.followerID;
			local followerInfo = C_Garrison.GetFollowerInfo(followerID);
			if (followerInfo) then
				followerInfo.abilities = C_Garrison.GetFollowerAbilities(followerID);
				self:UpdateValidSpellHighlight(followerID, followerInfo);
			end
		end
	end

	return false;
end

function GarrisonFollowListEditBox_OnTextChanged(self)
	SearchBoxTemplate_OnTextChanged(self);
	self:GetParent():UpdateFollowers();
end

function GarrisonFollowerList:DoesFollowerMatchFilters(follower, searchString)
	if (not follower.isCollected and not self.showUncollected) then
		return false;
	end
	if (searchString ~= "" and not C_Garrison.SearchForFollower(follower.followerID, searchString)) then
		return false;
	end
	if (self.filter and not self.filter(follower)) then
		return false;
	end

	return true;
end

function GarrisonFollowerList:UpdateFollowers()

	if ( self.dirtyList ) then
		self.followers = C_Garrison.GetFollowers(self.followerType) or {};
		self.dirtyList = nil;
	end

	if ( not self.followers ) then
		return;
	end

	self.followersList = { };
	self.followersLabels = { };

	local searchString = "";
	if ( self.SearchBox ) then
		searchString = self.SearchBox:GetText();
	end
	
	local numActive = 0;
	local numTroops = 0;
	local numInactive = 0;
	local numUncollected = 0;
	for i = 1, #self.followers do
		if self:DoesFollowerMatchFilters(self.followers[i], searchString) then
			tinsert(self.followersList, i);
			if (not self.followers[i].isCollected) then
				numUncollected = numUncollected + 1;
			elseif (self.followers[i].isTroop) then
				numTroops = numTroops + 1;
			elseif (self.followers[i].status == GARRISON_FOLLOWER_INACTIVE) then
				numInactive = numInactive + 1;
			else
				numActive = numActive + 1;
			end
		end
	end

	if ( self.followerTab ) then
		local maxFollowers = C_Garrison.GetFollowerSoftCap(self.followerType);
		local numActiveFollowers = C_Garrison.GetNumActiveFollowers(self.followerType) or 0;
		if ( self.isLandingPage ) then
			local countColor = HIGHLIGHT_FONT_COLOR_CODE;
			if ( numActiveFollowers > maxFollowers ) then
				countColor = RED_FONT_COLOR_CODE;
			end
			self.followerTab.NumFollowers:SetText(countColor..numActiveFollowers.."/"..maxFollowers..FONT_COLOR_CODE_CLOSE);
		else
			local countColor = NORMAL_FONT_COLOR_CODE;
			if ( numActiveFollowers > maxFollowers ) then
				countColor = RED_FONT_COLOR_CODE;
			end
			self.followerTab.NumFollowers:SetText(format(self.followerCountString, countColor, numActiveFollowers, maxFollowers, FONT_COLOR_CODE_CLOSE));
		end
	end

	GarrisonFollowerList_SortFollowers(self);

	if (GarrisonFollowerOptions[self.followerType].showCategoriesInFollowerList) then
		-- The sort above will yield the following sort order: Active followers, troops, inactive followers. Insert new entries for the appropriate
		-- category labels at the correct locations. Category labels will have "followerID" set to 0.

	    local additionalOffset = 0;

		additionalOffset = additionalOffset + 1;
		tinsert(self.followersList, 0 + additionalOffset, 0);
		self.followersLabels[0 + additionalOffset] = FOLLOWERLIST_LABEL_CHAMPIONS;

		additionalOffset = additionalOffset + 1;
		tinsert(self.followersList, numActive + additionalOffset, 0);
		self.followersLabels[numActive + additionalOffset] = FOLLOWERLIST_LABEL_TROOPS;

	    if ( numInactive > 0 ) then
		    additionalOffset = additionalOffset + 1;
		    tinsert(self.followersList, numActive + numTroops + additionalOffset, 0);
		    self.followersLabels[numActive + numTroops + additionalOffset] = FOLLOWERLIST_LABEL_INACTIVE;
	    end
		if ( numUncollected > 0 ) then
		    additionalOffset = additionalOffset + 1;
			tinsert(self.followersList, numActive + numTroops + numInactive + additionalOffset, 0)
		    self.followersLabels[numActive + numTroops + numInactive + additionalOffset] = FOLLOWERLIST_LABEL_UNCOLLECTED;
		end
	end
	self:UpdateData();
end

function GarrisonFollowerList_GetTopButton(self, offset)
	local followerFrame = self;
	local buttonHeight = followerFrame.listScroll.buttonHeight;
	local expandedFollower = followerFrame.expandedFollower;
	local followers = followerFrame.followers;
	local sortedList = followerFrame.followersList;
	local totalHeight = 0;
	for i = 1, #sortedList do
		local height;
		if ( sortedList[i] == 0 ) then
			height = CATEGORY_BUTTON_HEIGHT - FOLLOWER_LIST_BUTTON_OFFSET;
		elseif ( followers[sortedList[i]].followerID == expandedFollower ) then
			height = followerFrame.expandedFollowerHeight;
		else
			height = FOLLOWER_BUTTON_HEIGHT - FOLLOWER_LIST_BUTTON_OFFSET;
		end
		totalHeight = totalHeight + height;
		if ( totalHeight > offset ) then
			return i - 1, height + offset - totalHeight;
		end
	end

	--We're scrolled completely off the bottom
	return #followers, 0;
end

function GarrisonFollowerList_SetButtonMode(followerList, button, mode)
	if (mode == "CATEGORY") then
		followerList:CollapseButton(button.Follower);
		button:SetHeight(CATEGORY_BUTTON_HEIGHT);
	else
		button:SetHeight(FOLLOWER_BUTTON_HEIGHT);
	end

	button.mode = mode;
	button.Follower:SetShown(mode == "FOLLOWER");
	button.Category:SetShown(mode == "CATEGORY");
end

function GarrisonFollowerList:UpdateData()
	local followerFrame = self:GetParent();
	local followers = self.followers;
	local followersList = self.followersList;
	local categoryLabels = self.followersLabels;
	local numFollowers = #followersList;
	local scrollFrame = self.listScroll;
	local offset = HybridScrollFrame_GetOffset(scrollFrame);
	local buttons = scrollFrame.buttons;
	local numButtons = #buttons;
	local showCounters = self.showCounters;
	local canExpand = self.canExpand;
	local totalHeight = -FOLLOWER_LIST_BUTTON_INITIAL_OFFSET;

	for i = 1, numButtons do
		local button = buttons[i];
		local index = offset + i; -- adjust index
		if ( index <= numFollowers and followersList[index] == 0 ) then
			GarrisonFollowerList_SetButtonMode(self, button, "CATEGORY");
			button.Category:SetText(categoryLabels[index]);
			button:Show();
		elseif ( index <= numFollowers ) then
			local follower = followers[followersList[index]];

			GarrisonFollowerList_SetButtonMode(self, button, "FOLLOWER");
			button.Follower.ILevel:SetShown(not follower.isTroop);
			button.Follower.DurabilityFrame:SetShown(follower.isTroop);

			button.Follower.id = follower.followerID;
			button.Follower.info = follower;
			button.Follower.Name:SetText(follower.name);
			button.Follower.Class:SetAtlas(follower.classAtlas);
			button.Follower.Status:SetText(follower.status);
			if ( follower.status == GARRISON_FOLLOWER_INACTIVE ) then
				button.Follower.Status:SetTextColor(1, 0.1, 0.1);
			else
				button.Follower.Status:SetTextColor(0.698, 0.941, 1);
			end
			button.Follower.PortraitFrame:SetupPortrait(follower);
			if ( follower.isCollected ) then
				-- have this follower
				button.Follower.isCollected = true;
				button.Follower.Name:SetTextColor(NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b);
				button.Follower.Class:SetDesaturated(false);
				button.Follower.Class:SetAlpha(0.2);
				button.Follower.PortraitFrame.PortraitRingQuality:Show();
				button.Follower.PortraitFrame.Portrait:SetDesaturated(false);
				if ( follower.status == GARRISON_FOLLOWER_INACTIVE ) then
					button.Follower.PortraitFrame.PortraitRingCover:Show();
					button.Follower.PortraitFrame.PortraitRingCover:SetAlpha(0.5);
					button.Follower.BusyFrame:Show();
					button.Follower.BusyFrame.Texture:SetColorTexture(unpack(GARRISON_FOLLOWER_INACTIVE_COLOR));
				elseif ( follower.status ) then
					button.Follower.PortraitFrame.PortraitRingCover:Show();
					button.Follower.PortraitFrame.PortraitRingCover:SetAlpha(0.5);
					button.Follower.BusyFrame:Show();
					button.Follower.BusyFrame.Texture:SetColorTexture(unpack(GARRISON_FOLLOWER_BUSY_COLOR));
					-- get time remaining for follower
					if ( follower.status == GARRISON_FOLLOWER_ON_MISSION ) then
						if (follower.isMaxLevel) then
							button.Follower.Status:SetText(C_Garrison.GetFollowerMissionTimeLeft(follower.followerID));
						else
							button.Follower.Status:SetFormattedText(GARRISON_FOLLOWER_ON_MISSION_WITH_DURATION, C_Garrison.GetFollowerMissionTimeLeft(follower.followerID));
						end
					end
				else
					button.Follower.PortraitFrame.PortraitRingCover:Hide();
					button.Follower.BusyFrame:Hide();
				end
				if ( canExpand ) then
					button.Follower.DownArrow:SetAlpha(1);
				else
					button.Follower.DownArrow:SetAlpha(0);
				end
				-- adjust text position if we have additional text to show below name
				if (follower.isMaxLevel or follower.status) then
					button.Follower.Name:SetPoint("LEFT", button.Follower.PortraitFrame, "LEFT", 66, 8);
				else
					button.Follower.Name:SetPoint("LEFT", button.Follower.PortraitFrame, "LEFT", 66, 0);
				end
				-- show iLevel for max level followers	
				if (ShouldShowILevelInFollowerList(follower)) then
					button.Follower.ILevel:SetText(ITEM_LEVEL_ABBR.." "..follower.iLevel);
					button.Follower.Status:SetPoint("TOPLEFT", button.ILevel, "TOPRIGHT", 4, 0);
				else
					button.Follower.ILevel:SetText(nil);
					button.Follower.Status:SetPoint("TOPLEFT", button.ILevel, "TOPRIGHT", 0, 0);
				end
				if (follower.xp == 0 or follower.levelXP == 0) then 
					button.Follower.XPBar:Hide();
				else
					button.Follower.XPBar:Show();
					button.Follower.XPBar:SetWidth((follower.xp/follower.levelXP) * GARRISON_FOLLOWER_LIST_BUTTON_FULL_XP_WIDTH);
				end
			else
				-- don't have this follower
				button.Follower.isCollected = nil;
				button.Follower.Name:SetTextColor(0.25, 0.25, 0.25);
				button.Follower.ILevel:SetText(nil);
				button.Follower.Status:SetPoint("TOPLEFT", button.ILevel, "TOPRIGHT", 0, 0);
				button.Follower.Class:SetDesaturated(true);
				button.Follower.Class:SetAlpha(0.1);
				button.Follower.PortraitFrame.PortraitRingQuality:Hide();
				button.Follower.PortraitFrame.Portrait:SetDesaturated(true);
				button.Follower.PortraitFrame.PortraitRingCover:Show();
				button.Follower.PortraitFrame.PortraitRingCover:SetAlpha(0.6);
				button.Follower.PortraitFrame:SetQuality(0);
				button.Follower.XPBar:Hide();
				button.Follower.DownArrow:SetAlpha(0);
				button.Follower.BusyFrame:Hide();
			end

			GarrisonFollowerButton_UpdateCounters(self:GetParent(), button.Follower, follower, showCounters, followerFrame.lastUpdate);

			if (canExpand and button.Follower.id == self.expandedFollower and button.Follower.id == followerFrame.selectedFollower) then
				self:ExpandButton(button.Follower, self);
			else
				self:CollapseButton(button.Follower);
			end
			button:SetHeight(button.Follower:GetHeight());
			if ( button.Follower.id == followerFrame.selectedFollower ) then
				button.Follower.Selection:Show();
			else
				button.Follower.Selection:Hide();
			end

			if (follower.isTroop) then
				button.Follower.DurabilityFrame:SetDurability(follower.durability, follower.maxDurability);
			end

			button:Show();
		else
			button:Hide();
		end
	end
	
	-- calculate the total height to pass to the HybridScrollFrame
	for i = 1, numFollowers do
		if (followersList[i] == 0) then
			totalHeight = totalHeight + CATEGORY_BUTTON_HEIGHT - FOLLOWER_LIST_BUTTON_OFFSET;
		else
			totalHeight = totalHeight + FOLLOWER_BUTTON_HEIGHT - FOLLOWER_LIST_BUTTON_OFFSET;
		end
	end
	if (self.expandedFollower) then
		totalHeight = totalHeight + self.expandedFollowerHeight - (FOLLOWER_BUTTON_HEIGHT - FOLLOWER_LIST_BUTTON_OFFSET);
	end

	local displayedHeight = numButtons * scrollFrame.buttonHeight;
	HybridScrollFrame_Update(scrollFrame, totalHeight, displayedHeight);

	followerFrame.lastUpdate = GetTime();
end

function GarrisonFollowerButton_UpdateCounters(frame, button, follower, showCounters, lastUpdate)
	local numShown = 0;
	if ( showCounters and button.isCollected and follower.status ~= GARRISON_FOLLOWER_INACTIVE ) then
		--if a mission is being viewed, show mechanics this follower can counter
		--for followers you have, show counters if they are or could be on the mission
		local counters = frame.followerCounters and frame.followerCounters[follower.followerID];
		if ( counters ) then
			if ( follower.followerTypeID == LE_FOLLOWER_TYPE_SHIPYARD_6_2 ) then
				table.sort(counters, function(left, right) return left.factor > right.factor; end);
			end
			for i = 1, #counters do
				-- max of 4 icons
				if ( numShown == 4 ) then
					break;
				end			
				numShown = numShown + 1;
				GarrisonFollowerButton_SetCounterButton(button, follower.followerID, numShown, counters[i], lastUpdate, follower.followerTypeID);
			end
		end
		local traits = frame.followerTraits and frame.followerTraits[follower.followerID];
		if ( traits ) then
			for i = 1, #traits do
				-- max of 4 icons
				if ( numShown == 4 ) then
					break;
				end
				numShown = numShown + 1;
				GarrisonFollowerButton_SetCounterButton(button, follower.followerID, numShown, traits[i], lastUpdate, follower.followerTypeID);
			end
		end
	end
	if ( numShown == 1 or numShown == 2 or follower.followerTypeID == LE_FOLLOWER_TYPE_SHIPYARD_6_2 ) then
		button.Counters[1]:SetPoint("TOPRIGHT", -8, -16);
	else
		button.Counters[1]:SetPoint("TOPRIGHT", -8, -4);
	end
	for i = numShown + 1, #button.Counters do
		button.Counters[i].info = nil;
		button.Counters[i]:Hide();
	end
end

function GarrisonFollowerButton_SetCounterButton(button, followerID, index, info, lastUpdate, followerTypeID)
	local counter = button.Counters[index];
	if ( not counter ) then
		button.Counters[index] = CreateFrame("Frame", nil, button, "GarrisonMissionAbilityCounterTemplate");
		if ( followerTypeID == LE_FOLLOWER_TYPE_SHIPYARD_6_2 ) then
			button.Counters[index]:SetPoint("RIGHT", button.Counters[index-1], "LEFT", -6, 0);
		else
			if (index % 2 == 0) then
				button.Counters[index]:SetPoint("RIGHT", button.Counters[index-1], "LEFT", -6, 0);
			else
				button.Counters[index]:SetPoint("TOP", button.Counters[index-2], "BOTTOM", 0, -6);
			end
		end
		counter = button.Counters[index];
	end
	counter.info = info;

	counter.followerTypeID = followerTypeID;
	if ( info.traitID ) then
		counter.tooltip = nil;
		counter.info.showCounters = false;
		counter.Icon:SetTexture(info.icon);
		counter.Border:Hide();

		if ( GarrisonFollowerAbilities_IsNew(lastUpdate, followerID, info.traitID, GARRISON_FOLLOWER_ABILITY_TYPE_TRAIT ) ) then
			counter.AbilityFeedbackGlowAnim.traitID = info.traitID;
			counter.AbilityFeedbackGlowAnim:Play();
		elseif ( counter.AbilityFeedbackGlowAnim.traitID ~= info.traitID ) then
			counter.AbilityFeedbackGlowAnim.traitID = nil;
			counter.AbilityFeedbackGlowAnim:Stop();
		end
	else
		counter.tooltip = info.name;
		counter.info.showCounters = true;
		if (GarrisonFollowerOptions[followerTypeID].displayCounterAbilityInPlaceOfMechanic and info.counterID) then
			local abilityInfo = C_Garrison.GetFollowerAbilityInfo(info.counterID);
			counter.Icon:SetTexture(abilityInfo.icon);
			counter.Border:SetShown(ShouldShowFollowerAbilityBorder(followerTypeID, abilityInfo));
		else
			counter.Icon:SetTexture(info.icon);
			counter.Border:Show();

			if ( counter.info.factor <= GARRISON_HIGH_THREAT_VALUE and followerTypeID == LE_FOLLOWER_TYPE_SHIPYARD_6_2 ) then
				counter.Border:SetAtlas("GarrMission_WeakEncounterAbilityBorder");
			else
				counter.Border:SetAtlas("GarrMission_EncounterAbilityBorder");
			end		
		end

		counter.AbilityFeedbackGlowAnim.traitID = nil;
		counter.AbilityFeedbackGlowAnim:Stop();
	end
	counter:Show();
end

function GarrisonFollowerList:ExpandButton(button, followerListFrame)
	local abHeight = self:ExpandButtonAbilities(button, false);
	if (abHeight == -1) then
		return;
	end
	
	button.UpArrow:Show();
	button.DownArrow:Hide();
	button:SetHeight(51 + abHeight);
	followerListFrame.expandedFollowerHeight = 51 + abHeight + 6;
end

function GarrisonFollowerList:ExpandButtonAbilities(button, traitsFirst)
	if ( not button.isCollected ) then
		return -1;
	end

	local abHeight = 0;
	if (not button.info.abilities) then
		button.info.abilities = C_Garrison.GetFollowerAbilities(button.info.followerID);
	end

	local buttonCount = 0;
	for i=1, #button.info.abilities do
		if ( traitsFirst == button.info.abilities[i].isTrait and button.info.abilities[i].icon ) then
			buttonCount = buttonCount + 1;
			abHeight = abHeight + GarrisonFollowerButton_AddAbility(button, buttonCount, button.info.abilities[i], self.followerType);
		end
	end
	for i=1, #button.info.abilities do
		if ( traitsFirst ~= button.info.abilities[i].isTrait and button.info.abilities[i].icon ) then
			buttonCount = buttonCount + 1;
			abHeight = abHeight + GarrisonFollowerButton_AddAbility(button, buttonCount, button.info.abilities[i], self.followerType);
		end
	end

	for i=(#button.info.abilities + 1), #button.Abilities do
		button.Abilities[i]:Hide();
	end
	if (abHeight > 0) then
		abHeight = abHeight + 8;
		button.AbilitiesBG:Show();
		button.AbilitiesBG:SetHeight(abHeight);
	else
		button.AbilitiesBG:Hide();
	end
	return abHeight;
end

function GarrisonFollowerButton_AddAbility(self, index, ability, followerType)
	if (not self.Abilities[index]) then
		self.Abilities[index] = CreateFrame("Frame", nil, self, "GarrisonFollowerListButtonAbilityTemplate");
		self.Abilities[index]:SetPoint("TOPLEFT", self.Abilities[index-1], "BOTTOMLEFT", 0, -2);
	end
	local Ability = self.Abilities[index];
	Ability.followerTypeID = followerType;
	Ability.abilityID = ability.id;
	Ability.Name:SetText(ability.name);
	Ability.Icon:SetTexture(ability.icon);
	Ability.tooltip = ability.description;
	Ability:Show();
	return Ability:GetHeight() + 3;
end

function GarrisonFollowerList:CollapseButton(button)
	self:CollapseButtonAbilities(button);
	button.UpArrow:Hide();
	button.DownArrow:Show();
	button:SetHeight(FOLLOWER_BUTTON_HEIGHT);
end

function GarrisonFollowerList:CollapseButtonAbilities(button)
	button.AbilitiesBG:Hide();
	for i=1, #button.Abilities do
		button.Abilities[i]:Hide();
	end
end

function GarrisonFollowerListButton_OnClick(self, button)
	if (self.mode == "CATEGORY") then
		return;
	end

	local followerList = self:GetFollowerList();
	local followerFrame = followerList.listScroll.followerFrame;
	if ( button == "LeftButton" ) then
		PlaySound("UI_Garrison_CommandTable_SelectFollower");
		followerFrame.selectedFollower = self.id;

		if ( self.isCollected and followerList.canCastSpellsOnFollowers and SpellCanTargetGarrisonFollower() ) then
			GarrisonFollower_DisplayUpgradeConfirmation(self.id);
		end
		
		if ( followerList.canExpand ) then
			if ( self.isCollected ) then
				if (followerList.expandedFollower == self.id) then
					followerList.expandedFollower = nil;
					PlaySound("UI_Garrison_CommandTable_FollowerAbilityClose");
				else
					followerList.expandedFollower = self.id;
					PlaySound("UI_Garrison_CommandTable_FollowerAbilityOpen");
				end
			else
				followerList.expandedFollower = nil;
				PlaySound("UI_Garrison_CommandTable_FollowerAbilityClose");
			end
		else
			if ( not followerList.canExpand and followerList.expandedFollower ~= self.id ) then
				followerList.expandedFollower = nil;
			end
		end
		followerList:UpdateData();
		if ( followerList.followerTab ) then
			followerList:ShowFollower(self.id);
		end
		CloseDropDownMenus();
	-- Don't show right click follower menu in landing page
	elseif ( button == "RightButton" and not followerList.isLandingPage) then
		if ( self.isCollected ) then
			if ( followerList.OptionDropDown.followerID ~= self.id ) then
				CloseDropDownMenus();
			end
			followerList.OptionDropDown.followerID = self.id;
			ToggleDropDownMenu(1, nil, followerList.OptionDropDown, "cursor", 0, 0);
		else
			followerList.OptionDropDown.followerID = nil;
			CloseDropDownMenus();
		end
	end
end

function GarrisonFollowerListButton_OnModifiedClick(self, button)
	if (self.mode == "CATEGORY") then
		return;
	end
	if ( IsModifiedClick("CHATLINK") ) then
		local followerLink;
		if (self.info.isCollected) then
			followerLink = C_Garrison.GetFollowerLink(self.info.followerID);
		else
			followerLink = C_Garrison.GetFollowerLinkByID(self.info.followerID);
		end
		
		if ( followerLink ) then
			ChatEdit_InsertLink(followerLink);
		end
	end
end

---------------------------------------------------------------------------------
--- Follower filtering and searching                                          ---
---------------------------------------------------------------------------------
function GarrisonFollowerList:DirtyList()
	self.dirtyList = true;
end

local statusPriority = {
	[GARRISON_FOLLOWER_IN_PARTY] = 1,
	[GARRISON_FOLLOWER_WORKING] = 2,
	[GARRISON_FOLLOWER_ON_MISSION] = 3,
	[GARRISON_FOLLOWER_EXHAUSTED] = 4,
	[GARRISON_FOLLOWER_INACTIVE] = 5,
}

function GarrisonFollowerList_InitializeDefaultSort(self, followers)
	local mainFrame = self:GetParent();

	for i = 1, #followers do
		local follower = followers[i];
		follower.sortStatus = follower.status;
		-- treat IN_PARTY status as no status
		if (follower.sortStatus == GARRISON_FOLLOWER_IN_PARTY ) then
			follower.sortStatus = nil;
		end
		follower.sortILevel = follower.isMaxLevel and follower.iLevel or 0;	-- item level is only relevant at max level for this sort
	end
end

-- sorting: level > item level > quality
function GarrisonFollowerList_DefaultSort(self, follower1, follower2)
	if ( follower1.sortStatus and not follower2.sortStatus ) then
		return false;
	elseif ( not follower1.sortStatus and follower2.sortStatus ) then
		return true;
	end
	if ( follower1.sortStatus ~= follower2.sortStatus ) then
		return statusPriority[follower1.sortStatus] < statusPriority[follower2.sortStatus];
	end

	if (follower1.level ~= follower2.level) then
		return follower1.level > follower2.level;
	end

	if (follower1.sortILevel ~= follower2.sortILevel) then
		return follower1.sortILevel > follower2.sortILevel;
	end

	if ( follower1.quality ~= follower2.quality ) then
		return follower1.quality > follower2.quality;
	end

	return nil;
end

function GarrisonFollowerList_InitializeDefaultMissionSort(self, followers)
	local mainFrame = self:GetParent();

	local mentorLevel = mainFrame.MissionTab.MissionPage.mentorLevel or 0;
	local mentorItemLevel = mainFrame.MissionTab.MissionPage.mentorItemLevel or 0;

	local missionID = mainFrame:HasMission() and mainFrame.MissionTab.MissionPage.missionInfo.missionID or nil;

	if (missionID) then
		for i = 1, #followers do
			local follower = followers[i];
			follower.sortStatus = follower.status;
			-- treat IN_PARTY status as no status
			if (follower.sortStatus == GARRISON_FOLLOWER_IN_PARTY ) then
				follower.sortStatus = nil;
			end
			local relevantForMission = not follower.sortStatus and follower.isCollected;
			follower.sortNumCounters = relevantForMission and mainFrame.followerCounters[follower.followerID] and #mainFrame.followerCounters[follower.followerID] or 0;
			follower.sortNumTraits = relevantForMission and mainFrame.followerTraits[follower.followerID] and #mainFrame.followerTraits[follower.followerID] or 0;
			follower.sortLevel = max(follower.level, mentorLevel);
			follower.sortILevel = follower.isMaxLevel and max(follower.iLevel, mentorItemLevel) or 0;	-- item level is only relevant at max level for this sort
		end
	end
end

-- sorting: level > item level > (num counters for mission) > (num traits for mission) > quality
function GarrisonFollowerList_DefaultMissionSort(self, follower1, follower2)

	if ( follower1.sortStatus and not follower2.sortStatus ) then
		return false;
	elseif ( not follower1.sortStatus and follower2.sortStatus ) then
		return true;
	end
	if ( follower1.sortStatus ~= follower2.sortStatus ) then
		return statusPriority[follower1.sortStatus] < statusPriority[follower2.sortStatus];
	end

	if (follower1.sortLevel ~= follower2.sortLevel) then
		return follower1.sortLevel > follower2.sortLevel;
	end

	if (follower1.sortILevel ~= follower2.sortILevel) then
		return follower1.sortILevel > follower2.sortILevel;
	end

	if (follower1.sortNumCounters ~= follower2.sortNumCounters) then
		return follower1.sortNumCounters > follower2.sortNumCounters;
	end

	if (follower1.sortNumTraits ~= follower2.sortNumTraits) then
		return follower1.sortNumTraits > follower2.sortNumTraits;
	end

	if ( follower1.quality ~= follower2.quality ) then
		return follower1.quality > follower2.quality;
	end

	return nil;
end

function GarrisonFollowerList_InitializePrioritizeSpecializationAbilityMissionSort(self, followers)
	local mainFrame = self:GetParent();

	local missionID = mainFrame:HasMission() and mainFrame.MissionTab.MissionPage.missionInfo.missionID or nil;

	if (missionID) then
		for i = 1, #followers do
			local follower = followers[i];
			follower.sortStatus = follower.status;
			-- treat IN_PARTY status as no status
			if (follower.sortStatus == GARRISON_FOLLOWER_IN_PARTY ) then
				follower.sortStatus = nil;
			end
			local relevantForMission = not follower.sortStatus and follower.isCollected and C_Garrison.GetFollowerBiasForMission(missionID, follower.followerID) > -1;
			follower.sortNumCounters = relevantForMission and mainFrame.followerCounters[follower.followerID] and #mainFrame.followerCounters[follower.followerID] or 0;
			follower.sortNumTraits = relevantForMission and mainFrame.followerTraits[follower.followerID] and #mainFrame.followerTraits[follower.followerID] or 0;
			follower.sortHasSpecCounter = false;
			if (relevantForMission) then
				for i=1, follower.sortNumCounters do
					if (mainFrame.followerCounters[follower.followerID][i].isSpecialization) then
						follower.sortHasSpecCounter = true;
						break;
					end
				end
			end
		end
	end
end

-- sorting: hasSpecCounter > (num counters for mission) > (num traits for mission) > quality
function GarrisonFollowerList_PrioritizeSpecializationAbilityMissionSort(self, follower1, follower2)
	
	if ( follower1.sortStatus and not follower2.sortStatus ) then
		return false;
	elseif ( not follower1.sortStatus and follower2.sortStatus ) then
		return true;
	end
	if ( follower1.sortStatus ~= follower2.sortStatus ) then
		return statusPriority[follower1.sortStatus] < statusPriority[follower2.sortStatus];
	end

	if ( follower1.sortHasSpecCounter ~= follower2.sortHasSpecCounter ) then
		return follower1.sortHasSpecCounter;
	end
	
	if (follower1.sortNumCounters ~= follower2.sortNumCounters) then
		return follower1.sortNumCounters > follower2.sortNumCounters;
	end

	if (follower1.sortNumTraits ~= follower2.sortNumTraits) then
		return follower1.sortNumTraits > follower2.sortNumTraits;
	end

	if ( follower1.quality ~= follower2.quality ) then
		return follower1.quality > follower2.quality;
	end

	return nil;
end

function GarrisonFollowerList_SortFollowers(self)
	local followers = self.followers;
	local comparison = function(index1, index2)
		local follower1 = followers[index1];
		local follower2 = followers[index2];
		local follower1Active = follower1.status ~= GARRISON_FOLLOWER_INACTIVE;
		local follower2Active = follower2.status ~= GARRISON_FOLLOWER_INACTIVE;

		-- collected > troops > inactive is always the primary sort order; the category names rely on this.
		if ( follower1.isCollected ~= follower2.isCollected ) then
			return follower1.isCollected;
		end
		if ( follower1Active ~= follower2Active ) then
			return follower1Active;
		end
		if ( follower1.isTroop ~= follower2.isTroop ) then
			return follower2.isTroop;
		end

		-- run use-specific sort function
		if self.sortFunc then
			local result = self.sortFunc(self, follower1, follower2);
			if (result ~= nil) then
				return result;
			end
		end

		-- last resort; all else being equal sort by name, and then followerID
		local strCmpResult = strcmputf8i(follower1.name, follower2.name);
		if (strCmpResult ~= 0) then
			return strCmpResult < 0;
		end

		return follower1.followerID < follower2.followerID;
	end
	if (self.sortInitFunc) then
		self.sortInitFunc(self, self.followers);
	end
	table.sort(self.followersList, comparison);
end

---------------------------------------------------------------------------------
--- Models                                                                    ---
---------------------------------------------------------------------------------
function GarrisonMission_SetFollowerModel(modelFrame, followerID, displayID)
	if ( not displayID or displayID == 0 ) then
		modelFrame:ClearModel();
		modelFrame:Hide();
		modelFrame.followerID = nil;
	else
		modelFrame:Show();
		modelFrame:SetDisplayInfo(displayID);
		modelFrame.followerID = followerID;
		GarrisonMission_SetFollowerModelItems(modelFrame);
	end
end

function GarrisonMission_SetFollowerModelItems(modelFrame)
	if ( modelFrame.followerID ) then
		modelFrame:UnequipItems();
		local follower =  C_Garrison.GetFollowerInfo(modelFrame.followerID);
		if ( follower and follower.isCollected ) then
			local modelItems = C_Garrison.GetFollowerModelItems(modelFrame.followerID);
			for i = 1, #modelItems do
				modelFrame:EquipItem(modelItems[i]);
			end
		end
	end
end

function GarrisonCinematicModelBase_OnLoad(self)
	self:RegisterEvent("UI_SCALE_CHANGED");
	self:RegisterEvent("DISPLAY_SIZE_CHANGED");
end

function GarrisonCinematicModelBase_OnEvent(self)
	self:RefreshCamera();
end

---------------------------------------------------------------------------------
--- Follower Page                                                             ---
---------------------------------------------------------------------------------
GARRISON_FOLLOWER_PAGE_HEIGHT_MULTIPLIER = .65;
GARRISON_FOLLOWER_PAGE_SCALE_MULTIPLIER = 1.3

function GarrisonFollowerPageItemButton_OnEvent(self, event)
	if ( not self:IsShown() and self.itemID ) then
		GarrisonFollowerPage_SetItem(self, self.itemID, self.itemLevel);
	end
end

function GarrisonFollowerPage_SetItem(itemFrame, itemID, itemLevel)
	if ( itemID and itemID > 0 ) then
		itemFrame.itemID = itemID;
		itemFrame.itemLevel = itemLevel;
		local itemName, _, itemQuality, _, _, _, _, _, _, itemTexture = GetItemInfo(itemID);
		if ( itemName ) then
			itemFrame.Icon:SetTexture(itemTexture);
			itemFrame.Name:SetTextColor(GetItemQualityColor(itemQuality));
			itemFrame.ItemLevel:SetFormattedText(GARRISON_FOLLOWER_ITEM_LEVEL, itemLevel);
			itemFrame:Show();			
			return;
		end
	else
		itemFrame.itemID = nil;
		itemFrame.itemLevel = nil;
	end
	itemFrame:Hide();
end

function GarrisonFollowerList:UpdateValidSpellHighlight(followerID, followerInfo, hideCounters)
	self.followerTab:UpdateValidSpellHighlight(followerID, followerInfo, hideCounters)
end

function GarrisonFollowerList:ShowFollower(followerID)
	local followerList = self;
	self.followerTab:ShowFollower(followerID, followerList);
end

function GarrisonFollowerList:SetSortFuncs(sortFunc, sortInitFunc)
	self.sortFunc = sortFunc;
	self.sortInitFunc = sortInitFunc;
end

function GarrisonFollowerPage_AnchorAbility(abilityFrame, lastAnchor, headerString, isLandingPage)
	abilityFrame:ClearAllPoints();
	if ( lastAnchor ) then
		abilityFrame:SetPoint("LEFT", lastAnchor);
		abilityFrame:SetPoint("TOP", lastAnchor, "BOTTOM", 0, isLandingPage and 13 or 0);			
	else
		abilityFrame:SetPoint("TOPLEFT", headerString, "BOTTOMLEFT", 2, isLandingPage and -5 or -12);
	end
	return abilityFrame;
end

function GarrisonFollowerPageModel_OnMouseDown(self, button)
	local followerList = self:GetParent().followerList;
	if ( button == "LeftButton" and followerList.canCastSpellsOnFollowers and SpellCanTargetGarrisonFollower() ) then
		-- no rotation if you can upgrade this follower
		local followerID = self.followerID;
		local followerInfo = followerID and C_Garrison.GetFollowerInfo(followerID);
		if ( followerInfo and followerInfo.isCollected and followerInfo.status ~= GARRISON_FOLLOWER_ON_MISSION ) then
			return;
		end
	end
	Model_OnMouseDown(self, button);
end

function GarrisonFollowerPageModel_OnMouseUp(self, button)
	local followerList = self:GetParent().followerList;
	if ( button == "LeftButton" and followerList.canCastSpellsOnFollowers and SpellCanTargetGarrisonFollower() ) then
		-- no rotation if you can upgrade this follower, bring up confirmation dialog
		if ( GarrisonFollower_DisplayUpgradeConfirmation(self.followerID) ) then
			return;
		end
	end
	Model_OnMouseUp(self, button);
end

function GarrisonFollowerPageModelUpgrade_OnLoad(self)
	self:RegisterEvent("CURRENT_SPELL_CAST_CHANGED");
end

function GarrisonFollowerPageModelUpgrade_OnEvent(self, event)
	GarrisonFollowerPageModelUpgrade_Update(self);
end

function GarrisonFollowerPageModelUpgrade_Update(self)
	if ( SpellCanTargetGarrisonFollower() ) then
		local followerID = self:GetParent().followerID;
		local followerInfo = followerID and C_Garrison.GetFollowerInfo(followerID);
		if ( followerInfo and followerInfo.isCollected and followerInfo.status ~= GARRISON_FOLLOWER_ON_MISSION and (not C_Garrison.TargetSpellHasFollowerTemporaryAbility() or C_Garrison.CanSpellTargetFollowerIDWithAddAbility(followerID)) ) then
			local isValidTarget = (followerInfo.isMaxLevel or not C_Garrison.TargetSpellHasFollowerItemLevelUpgrade());
			self.Text:SetShown(isValidTarget);
			self.Icon:SetShown(isValidTarget);
			self.TextInvalid:SetShown(not isValidTarget);
			self:Show();
			return;
		end
	end
	self:Hide();
end

function GarrisionFollowerPageUpgradeTarget_OnLoad(self)
	self:SetFrameLevel(self:GetParent():GetFrameLevel() + 5);
	self:RegisterEvent("CURRENT_SPELL_CAST_CHANGED");
end

function GarrisionFollowerPageUpgradeTarget_OnEvent(self, event)
	if (event == "CURRENT_SPELL_CAST_CHANGED") then
		if ( SpellCanTargetGarrisonFollower() ) then
			local followerID = self:GetParent().followerID;
			local followerInfo = followerID and C_Garrison.GetFollowerInfo(followerID);
			if ( followerInfo and followerInfo.isCollected and followerInfo.status ~= GARRISON_FOLLOWER_ON_MISSION and (followerInfo.isMaxLevel or not C_Garrison.TargetSpellHasFollowerItemLevelUpgrade()) ) then
				if ( not C_Garrison.TargetSpellHasFollowerTemporaryAbility() or C_Garrison.CanSpellTargetFollowerIDWithAddAbility(followerID) ) then
					self:Show();
					return;
				end
			end
		end
		self:Hide();
	end
end

function GarrisonFollower_DisplayUpgradeConfirmation(followerID)
	local followerInfo = followerID and C_Garrison.GetFollowerInfo(followerID);
	if ( followerInfo and followerInfo.isCollected and followerInfo.status ~= GARRISON_FOLLOWER_ON_MISSION and (followerInfo.isMaxLevel or not C_Garrison.TargetSpellHasFollowerItemLevelUpgrade()) ) then
		local name = ITEM_QUALITY_COLORS[followerInfo.quality].hex..followerInfo.name..FONT_COLOR_CODE_CLOSE;
		if ( C_Garrison.TargetSpellHasFollowerTemporaryAbility() ) then
			if ( C_Garrison.CanSpellTargetFollowerIDWithAddAbility(followerID) ) then
				StaticPopup_Show("CONFIRM_FOLLOWER_TEMPORARY_ABILITY", name, nil, followerID);
				return true;
			end
		else
			local text;
			local hasReroll, rerollAbilities, rerollTraits = C_Garrison.TargetSpellHasFollowerReroll();
			if ( hasReroll ) then
				if ( rerollAbilities and rerollTraits ) then
					text = CONFIRM_GARRISON_FOLLOWER_REROLL_ALL;
				elseif ( rerollAbilities ) then
					text = CONFIRM_GARRISON_FOLLOWER_REROLL_ABILITIES;
				else
					text = CONFIRM_GARRISON_FOLLOWER_REROLL_TRAITS;
				end
				text = string.format(text, name);
			else
				text = string.format(CONFIRM_GARRISON_FOLLOWER_UPGRADE, name);
			end
			StaticPopup_Show("CONFIRM_FOLLOWER_UPGRADE", text, nil, followerID);
			return true;
		end
	end
	return false;
end


--- GarrisonFollowerTab

GarrisonFollowerTabMixin = { }

function GarrisonFollowerTabMixin:UpdateValidSpellHighlightOnAbilityFrame(abilityFrame, followerID, followerInfo, hideCounters)
	local ability = abilityFrame.ability;
	if ( followerInfo and followerInfo.isCollected 
		and followerInfo.status ~= GARRISON_FOLLOWER_WORKING and followerInfo.status ~= GARRISON_FOLLOWER_ON_MISSION 
		and ability and SpellCanTargetGarrisonFollowerAbility(followerID, ability.id) ) then
		abilityFrame.IconButton.ValidSpellHighlight:Show();
		if ( not ability.temporary ) then
			abilityFrame.IconButton.OldIcon:SetTexture(ability.icon);
			abilityFrame.IconButton.OldIcon:SetAlpha(0);
		end
	else
		abilityFrame.IconButton.ValidSpellHighlight:Hide();
	end
end


function GarrisonFollowerTabMixin:UpdateValidSpellHighlight(followerID, followerInfo, hideCounters)
	for i=1, #self.AbilitiesFrame.Abilities do
		self:UpdateValidSpellHighlightOnAbilityFrame(self.AbilitiesFrame.Abilities[i], followerID, followerInfo, hideCounters);
	end
end


function GarrisonFollowerTabMixin:ShowFollower(followerID, followerList)

	local lastUpdate = self.lastUpdate;
	local followerInfo = C_Garrison.GetFollowerInfo(followerID);

	if (followerInfo) then
		self.followerID = followerID;
		self.NoFollowersLabel:Hide();
		self.PortraitFrame:Show();
		self.Model:SetAlpha(0);
		GarrisonMission_SetFollowerModel(self.Model, followerInfo.followerID, followerInfo.displayID);
		if (followerInfo.displayHeight) then
			self.Model:SetHeightFactor(followerInfo.displayHeight);
		end
		if (followerInfo.displayScale) then
			self.Model:InitializeCamera(followerInfo.displayScale);
		end		
	else
		self.followerID = nil;
		self.NoFollowersLabel:Show();
		followerInfo = { };
		followerInfo.quality = 1;
		followerInfo.abilities = { };
		followerInfo.followerTypeID = followerList.followerType;
		self.PortraitFrame:Hide();
		self.Model:ClearModel();
	end

	GarrisonFollowerPageModelUpgrade_Update(self.Model.UpgradeFrame);

	GarrisonMissionPortrait_SetFollowerPortrait(self.PortraitFrame, followerInfo);
	self.Name:SetText(followerInfo.name);
	local color = ITEM_QUALITY_COLORS[followerInfo.quality];	
	self.Name:SetVertexColor(color.r, color.g, color.b);
	self.ClassSpec:SetText(followerInfo.className);
	self.Class:SetAtlas(followerInfo.classAtlas);
	if ( followerInfo.isCollected ) then
		-- Follower cannot be upgraded anymore
		if (followerInfo.isMaxLevel and followerInfo.quality >= GARRISON_FOLLOWER_MAX_UPGRADE_QUALITY) then
			self.XPLabel:Hide();
			self.XPBar:Hide();
			self.XPText:Hide();
			self.XPText:SetText("");
		else
			if (followerInfo.isMaxLevel) then
				self.XPLabel:SetText(GARRISON_FOLLOWER_XP_UPGRADE_STRING);
			else
				self.XPLabel:SetText(GARRISON_FOLLOWER_XP_STRING);
			end
			self.XPLabel:SetWidth(0);
			self.XPLabel:SetFontObject("GameFontHighlight");
			self.XPLabel:SetPoint("TOPRIGHT", self.XPText, "BOTTOMRIGHT", 0, -4);
			self.XPLabel:Show();
			-- If the XPLabel text does not fit within 100 pixels, shrink the font. If it wraps to 2 lines, move the text up.
			if (self.XPLabel:GetWidth() > 100) then
				self.XPLabel:SetWidth(100);
				self.XPLabel:SetFontObject("GameFontWhiteSmall");
				if (self.XPLabel:GetNumLines() > 1) then
					self.XPLabel:SetPoint("TOPRIGHT", self.XPText, "BOTTOMRIGHT", -1, 0);
				end
			end
			self.XPBar:Show();
			self.XPBar:SetMinMaxValues(0, followerInfo.levelXP);
			self.XPBar.Label:SetFormattedText(GARRISON_FOLLOWER_XP_BAR_LABEL, BreakUpLargeNumbers(followerInfo.xp), BreakUpLargeNumbers(followerInfo.levelXP));
			self.XPBar:SetValue(followerInfo.xp);
			local xpLeft = followerInfo.levelXP - followerInfo.xp;
			self.XPText:SetText(format(GARRISON_FOLLOWER_XP_LEFT, xpLeft));
			self.XPText:Show();
		end
	else
		self.XPText:Hide();
		self.XPLabel:Hide();
		self.XPBar:Hide();
	end
	GarrisonTruncationFrame_Check(self.Name);

	if ( ENABLE_COLORBLIND_MODE == "1" ) then
		self.QualityFrame:Show();
		self.QualityFrame.Text:SetText(_G["ITEM_QUALITY"..followerInfo.quality.."_DESC"]);
	else
		self.QualityFrame:Hide();
	end

	self.AbilitiesFrame.TraitsText:ClearAllPoints();
	if (not followerInfo.abilities) then
		followerInfo.abilities = C_Garrison.GetFollowerAbilities(followerID);
	end
	local lastAbilityAnchor, lastTraitAnchor;
	local numCounters = 0;

	for i=1, #followerInfo.abilities do
		local ability = followerInfo.abilities[i];

		local abilityFrame = self.AbilitiesFrame.Abilities[i];
		if ( not abilityFrame ) then
			abilityFrame = CreateFrame("Frame", nil, self.AbilitiesFrame, "GarrisonFollowerPageAbilityTemplate");
			self.AbilitiesFrame.Abilities[i] = abilityFrame;
		end

		abilityFrame.isSpecialization = ability.isSpecialization;
		abilityFrame.followerTypeID = followerInfo.followerTypeID;
		if ( self.isLandingPage ) then
			abilityFrame.Category:SetText("");
			abilityFrame.Name:SetFontObject("GameFontHighlightMed2");
			abilityFrame.Name:ClearAllPoints();
			abilityFrame.Name:SetPoint("LEFT", abilityFrame.IconButton, "RIGHT", 8, 0);
			abilityFrame.Name:SetWidth(150);
		else
			local categoryText = "";
			if ( ability.isTrait ) then
				if ( ability.temporary ) then
					categoryText = GARRISON_TEMPORARY_CATEGORY_FORMAT:format(ability.category or "");
				else
					categoryText = ability.category or "";
				end
			end
			abilityFrame.Category:SetText(categoryText);
			abilityFrame.Name:SetFontObject("GameFontNormalLarge2");
			abilityFrame.Name:ClearAllPoints();
			abilityFrame.Name:SetPoint("TOPLEFT", abilityFrame.IconButton, "TOPRIGHT", 8, 0);
			abilityFrame.Name:SetWidth(240);
		end
		if ( followerInfo.isCollected and GarrisonFollowerAbilities_IsNew(lastUpdate, followerInfo.followerID, ability.id, GARRISON_FOLLOWER_ABILITY_TYPE_TRAIT) ) then			
			if ( ability.temporary ) then
				abilityFrame.LargeAbilityFeedbackGlowAnim:Play();
				PlaySoundKitID(51324);
			else
				abilityFrame.IconButton.Icon:SetAlpha(0);
				abilityFrame.IconButton.OldIcon:SetAlpha(1);
				abilityFrame.AbilityOverwriteAnim:Play();		
			end
		else
			GarrisonFollowerPageAbility_StopAnimations(abilityFrame);
		end
		abilityFrame.Name:SetText(ability.name);
		abilityFrame.IconButton.Icon:SetTexture(ability.icon);
		abilityFrame.IconButton.abilityID = ability.id;
		abilityFrame.ability = ability;

		local hasCounters = false;
		if ( ability.counters and not ability.isTrait and not self.isLandingPage ) then
			for id, counter in pairs(ability.counters) do
				numCounters = numCounters + 1;
				local counterFrame = self.AbilitiesFrame.Counters[numCounters];
				if ( not counterFrame ) then
					counterFrame = CreateFrame("Frame", nil, self.AbilitiesFrame, "GarrisonMissionMechanicTemplate");
					self.AbilitiesFrame.Counters[numCounters] = counterFrame;
				end
				counterFrame.mainFrame = self:GetParent();
				counterFrame.Icon:SetTexture(counter.icon);
				counterFrame.tooltip = counter.name;
				counterFrame:ClearAllPoints();
				if ( hasCounters ) then			
					counterFrame:SetPoint("LEFT", self.AbilitiesFrame.Counters[numCounters - 1], "RIGHT", 10, 0);
				else
					counterFrame:SetPoint("LEFT", abilityFrame.CounterString, "RIGHT", 2, -2);
				end
				counterFrame:Show();
				counterFrame.info = counter;
				counterFrame.followerTypeID = followerInfo.followerTypeID;
				hasCounters = true;
			end
		end
		if ( hasCounters ) then
			abilityFrame.CounterString:Show();
		else
			abilityFrame.CounterString:Hide();
		end
		-- anchor ability
		if ( ability.isTrait ) then
			lastTraitAnchor = GarrisonFollowerPage_AnchorAbility(abilityFrame, lastTraitAnchor, self.AbilitiesFrame.TraitsText, self.isLandingPage);
		else
			lastAbilityAnchor = GarrisonFollowerPage_AnchorAbility(abilityFrame, lastAbilityAnchor, self.AbilitiesFrame.AbilitiesText, self.isLandingPage);
		end
		abilityFrame:Show();
	end
	followerList:UpdateValidSpellHighlight(followerID, followerInfo);

	if ( lastAbilityAnchor ) then
		self.AbilitiesFrame.AbilitiesText:Show();
	else
		self.AbilitiesFrame.AbilitiesText:Hide();
	end
	if ( lastTraitAnchor ) then
		self.AbilitiesFrame.TraitsText:Show();
		if ( lastAbilityAnchor ) then
			self.AbilitiesFrame.TraitsText:SetPoint("LEFT", self.AbilitiesFrame.AbilitiesText, "LEFT");
			if ( self.isLandingPage ) then
				self.AbilitiesFrame.TraitsText:SetPoint("TOP", lastAbilityAnchor, "BOTTOM", 0, 0);
			else
				self.AbilitiesFrame.TraitsText:SetPoint("TOP", lastAbilityAnchor, "BOTTOM", 0, -16);
			end
		else
			self.AbilitiesFrame.TraitsText:SetPoint("TOPLEFT", self.AbilitiesFrame.AbilitiesText, "TOPLEFT");
		end
	else
		self.AbilitiesFrame.TraitsText:Hide();
	end
	
	for i = #followerInfo.abilities + 1, #self.AbilitiesFrame.Abilities do
		self.AbilitiesFrame.Abilities[i]:Hide();
	end
	for i = numCounters + 1, #self.AbilitiesFrame.Counters do
		self.AbilitiesFrame.Counters[i]:Hide();
	end
	
	-- gear	/ source
	if ( followerInfo.isCollected and not self.isLandingPage ) then
		local weaponItemID, weaponItemLevel, armorItemID, armorItemLevel = C_Garrison.GetFollowerItems(followerInfo.followerID);
		GarrisonFollowerPage_SetItem(self.ItemWeapon, weaponItemID, weaponItemLevel);
		GarrisonFollowerPage_SetItem(self.ItemArmor, armorItemID, armorItemLevel);
		if ( followerInfo.isMaxLevel ) then
			self.ItemAverageLevel.Level:SetText(ITEM_LEVEL_ABBR .. " " .. followerInfo.iLevel);
			self.ItemAverageLevel.Level:Show();
		else
			self.ItemWeapon:Hide();
			self.ItemArmor:Hide();
			self.ItemAverageLevel.Level:Hide();
		end
		self.Source.SourceText:Hide();
	else
		self.ItemWeapon:Hide();
		self.ItemArmor:Hide();
		self.ItemAverageLevel.Level:Hide();		

		self.Source.SourceText:SetText(C_Garrison.GetFollowerSourceTextByID(followerID));		
		self.Source.SourceText:Show();
	end

	self.lastUpdate = self:IsShown() and GetTime() or nil;
end

function GarrisonFollowerTabMixin:GetFollowerList()
	return self:GetParent():GetFollowerList();
end

function GarrisionFollowerPageUpgradeTarget_OnClick(self, button)
	GarrisonFollower_DisplayUpgradeConfirmation(self:GetParent().followerID);
end

function GarrisonFollowerPageAbility_OnClick(self, button)
	if ( IsModifiedClick("CHATLINK") ) then
		local abilityLink = C_Garrison.GetFollowerAbilityLink(self.abilityID);
		if (abilityLink) then
			ChatEdit_InsertLink(abilityLink);
		end
	else
		local followerTab = self:GetParent():GetParent():GetParent();
		local followerList = followerTab.followerList;
		local followerID = followerTab.followerID;	
		if ( button == "LeftButton" and followerList.canCastSpellsOnFollowers and SpellCanTargetGarrisonFollowerAbility(followerID, self.abilityID) ) then
			local followerInfo = followerID and C_Garrison.GetFollowerInfo(followerID);
			if ( not followerInfo or not followerInfo.isCollected or followerInfo.status == GARRISON_FOLLOWER_ON_MISSION or followerInfo.status == GARRISON_FOLLOWER_WORKING ) then
				return;
			end
			
			local popupData = {};
			popupData.followerID = followerID;
			popupData.abilityID = self.abilityID;
			GarrisonConfirmFollowerAbilityUpgradeFrame.Name:SetText(C_Garrison.GetFollowerAbilityName(self.abilityID));
			GarrisonConfirmFollowerAbilityUpgradeFrame.Icon:SetTexture(C_Garrison.GetFollowerAbilityIcon(self.abilityID));
			local text = CONFIRM_GARRISON_FOLLOWER_ABILITY_REPLACE;
			if ( C_Garrison.GetFollowerAbilityIsTrait(self.abilityID) ) then
				text = CONFIRM_GARRISON_FOLLOWER_TRAIT_REPLACE;
			end
			StaticPopup_Show("CONFIRM_FOLLOWER_ABILITY_UPGRADE", NORMAL_FONT_COLOR_CODE..text..FONT_COLOR_CODE_CLOSE, nil, popupData, GarrisonConfirmFollowerAbilityUpgradeFrame);
		end	
	end
end

function GarrisonFollowerPageAbility_StopAnimations(self)
	self.LargeAbilityFeedbackGlowAnim:Stop();
	if ( self.AbilityOverwriteAnim:IsPlaying() ) then
		self.AbilityOverwriteAnim:Stop();
		self.IconButton.Icon:SetAlpha(1);
		self.IconButton.OldIcon:SetAlpha(0);
	end
end

---------------------------------------------------------------------------------
--- Equipment Utils
---------------------------------------------------------------------------------

function GarrisonEquipment_AddEquipment(self)
	local followerList = self:GetParent():GetFollowerList();
	local followerTab = self:GetParent():GetFollowerTab();
	if ( followerList.canCastSpellsOnFollowers ) then
		local followerID = followerTab.followerID;
		local popupData = {};
		local equipmentName;
		if ( SpellCanTargetGarrisonFollowerAbility(followerID, self.abilityID) ) then
			popupData.source = "spell";
			equipmentName = GetEquipmentNameFromSpell();
		elseif ( ItemCanTargetGarrisonFollowerAbility(followerID, self.abilityID) ) then
			popupData.source = "item";
			local itemType, itemID = GetCursorInfo();
			equipmentName = GetItemInfo(itemID);
		else
			return;
		end
		local followerInfo = followerID and C_Garrison.GetFollowerInfo(followerID);
		if ( not followerInfo or not followerInfo.isCollected or followerInfo.status == GARRISON_FOLLOWER_ON_MISSION or followerInfo.status == GARRISON_FOLLOWER_WORKING ) then
			return;
		end
		
		popupData.followerID = followerID;
		popupData.abilityID = self.abilityID;
		local text = format(GarrisonFollowerOptions[followerList.followerType].strings.CONFIRM_EQUIPMENT, equipmentName);
		StaticPopup_Show("CONFIRM_FOLLOWER_EQUIPMENT", text, nil, popupData);
	end
end


---------------------------------------------------------------------------------
--- Abilities Frame
---------------------------------------------------------------------------------
GarrisonAbilitiesFrameMixin = { }

function GarrisonAbilitiesFrameMixin:GetFollowerTab()
	return self:GetParent();
end

function GarrisonAbilitiesFrameMixin:GetFollowerList()
	return self:GetParent():GetFollowerList();
end

---------------------------------------------------------------------------------
--- Mission Sorting                                                           ---
---------------------------------------------------------------------------------

function Garrison_SortMissions(missionsList)
	local comparison = function(mission1, mission2)
		if ( mission1.followerTypeID ~= mission2.followerTypeID ) then
			return mission1.followerTypeID > mission2.followerTypeID;
		end
		
		if ( mission1.level ~= mission2.level ) then
			return mission1.level > mission2.level;
		end

		if ( mission1.isMaxLevel ) then	-- mission 2 level is same as 1's at this point
			if ( mission1.iLevel ~= mission2.iLevel ) then
				return mission1.iLevel > mission2.iLevel;
			end		
		end

		if ( mission1.durationSeconds ~= mission2.durationSeconds ) then
			return mission1.durationSeconds < mission2.durationSeconds;
		end
		
		if ( mission1.isRare ~= mission2.isRare ) then
			return mission1.isRare;
		end

		return strcmputf8i(mission1.name, mission2.name) < 0;
	end

	table.sort(missionsList, comparison);
end

---------------------------------------------------------------------------------
--- Truncation		                                                          ---
---------------------------------------------------------------------------------

function GarrisonTruncationFrame_Check(fontString)
	local self = GarrisonTruncationFrame;
	-- force a resize so IsTruncated will be correct, otherwise it might change a frame later depending on pending resizes
	fontString:GetRect();
	if ( fontString:IsTruncated() ) then
		self:SetParent(fontString:GetParent());
		self:SetPoint("TOPLEFT", fontString);
		self:SetPoint("BOTTOMRIGHT", fontString);
		self:Show();
		self.tooltip = fontString:GetText();
	else
		self:Hide();
		self.tooltip = nil;
	end
end

function GarrisonTruncationFrame_OnEnter(self)
	if ( self.tooltip ) then
		GameTooltip:SetOwner(self, "ANCHOR_TOP");
		GameTooltip:SetText(self.tooltip);
	end
end

function GarrisonTruncationFrame_OnLeave(self)
	GameTooltip:Hide();
end

---------------------------------------------------------------------------------
--- Threat Counters                                                           ---
---------------------------------------------------------------------------------
local weatherIds = {77, 78, 79, 80};
local function IsWeatherThreat(id)
	for i = 1, #weatherIds do
		if ( weatherIds[i] == id ) then
			return true;
		end
	end
	
	return false;
end

function GarrisonThreatCountersFrame_OnLoad(self, followerType, tooltipString)
	if (followerType == nil) then
		followerType = LE_FOLLOWER_TYPE_GARRISON_6_0;
	end
	self.followerType = followerType;
	if (tooltipString == nil) then
		tooltipString = GARRISON_THREAT_COUNTER_TOOLTIP;
	end
	self.tooltipString = tooltipString;
	local mechanics = C_Garrison.GetAllEncounterThreats(followerType);
	-- sort reverse alphabetical because we'll be anchoring buttons right to left
	if ( followerType == LE_FOLLOWER_TYPE_SHIPYARD_6_2 ) then
		-- sort high threats to the left, weather based threats to the right, other wise sort alphabetic
		table.sort(mechanics, function(m1, m2)
			local m1Weather = IsWeatherThreat(m1.id);
			if ( m1Weather ~= IsWeatherThreat(m2.id) ) then
				return m1Weather;
			elseif ( m1.factor == m2.factor ) then
				return strcmputf8i(m1.name, m2.name) > 0;
			else
				return m1.factor < m2.factor;
			end
		end);
	else
		table.sort(mechanics, function(m1, m2) return strcmputf8i(m1.name, m2.name) > 0; end);
	end
	for i = 1, #mechanics do
		local frame = self.ThreatsList[i];
		if ( not frame ) then
			frame = CreateFrame("Button", nil, self, "GarrisonThreatCounterTemplate");
			frame:SetPoint("RIGHT", self.ThreatsList[i-1], "LEFT", -14, 0);
			self.ThreatsList[i] = frame;
		end
		frame.Icon:SetTexture(mechanics[i].icon);
		frame.name = mechanics[i].name;
		frame.id = mechanics[i].id;
		if ( mechanics[i].factor and  mechanics[i].factor <= GARRISON_HIGH_THREAT_VALUE and followerType == LE_FOLLOWER_TYPE_SHIPYARD_6_2 ) then
			frame.Border:SetAtlas("GarrMission_WeakEncounterAbilityBorder");
		else
			frame.Border:SetAtlas("GarrMission_EncounterAbilityBorder");
		end
	end
	self:RegisterEvent("GARRISON_FOLLOWER_LIST_UPDATE");
end

function GarrisonThreatCountersFrame_OnEvent(self, event, ...)
	if ( self:IsVisible() ) then
		GarrisonThreatCountersFrame_Update(self);
	end
end

function GarrisonThreatCountersFrame_Update(self)
	for i = 1, #self.ThreatsList do
		self.ThreatsList[i].Count:SetText(C_Garrison.GetNumFollowersForMechanic(self.followerType, self.ThreatsList[i].id));
	end
end

function GarrisonThreatCounter_OnEnter(self)
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	local text = string.format(self:GetParent().tooltipString, C_Garrison.GetNumFollowersForMechanic(self:GetParent().followerType, self.id), self.name);
	GameTooltip:SetText(text, nil, nil, nil, nil, true);
end

---------------------------------------------------------------------------------
--- Follower Abilities                                                          ---
---------------------------------------------------------------------------------

GARRISON_FOLLOWER_ABILITY_TYPE_ABILITY = 1;
GARRISON_FOLLOWER_ABILITY_TYPE_TRAIT = 2;
GARRISON_FOLLOWER_ABILITY_TYPE_EITHER = 3;

local function IsNewHelper(lastUpdate, abilityIdToTest, ...)
	for i = 1, select("#", ...), 2 do
		local abilityID = select(i, ...);
		local timeGained = select(i + 1, ...);
		if ( timeGained >= lastUpdate and abilityIdToTest == abilityID ) then
			return true;
		end
	end
	return false;
end

function GarrisonFollowerAbilities_IsNew(lastUpdate, followerID, abilityIdToTest, abilityType)
	if ( lastUpdate and followerID and followerID ~= "" ) then
		abilityType = abilityType or GARRISON_FOLLOWER_ABILITY_TYPE_EITHER;

		if ( abilityType == GARRISON_FOLLOWER_ABILITY_TYPE_ABILITY or abilityType == GARRISON_FOLLOWER_ABILITY_TYPE_EITHER ) then
			if ( IsNewHelper(lastUpdate, abilityIdToTest, C_Garrison.GetFollowerRecentlyGainedAbilityIDs(followerID)) ) then
				return true;
			end
		end

		if ( abilityType == GARRISON_FOLLOWER_ABILITY_TYPE_TRAIT or abilityType == GARRISON_FOLLOWER_ABILITY_TYPE_EITHER ) then
			if ( IsNewHelper(lastUpdate, abilityIdToTest, C_Garrison.GetFollowerRecentlyGainedTraitIDs(followerID)) ) then
				return true;
			end
		end
	end

	return false;
end