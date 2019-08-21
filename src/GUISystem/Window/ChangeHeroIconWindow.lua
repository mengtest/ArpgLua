-- Name: 	ChangeHeroIconWindow
-- Func：	英雄换头像界面
-- Author:	tuanzhang
-- Data:	16-01-21

local ChangeHeroIconWindow = 
{
	mName					=	"ChangeHeroIconWindow",
	mRootNode				=	nil,
	mRootWidget				=	nil,
	----------------------------------------
		
}

function ChangeHeroIconWindow:Release()

end

function ChangeHeroIconWindow:Load()
	cclog("=====ChangeHeroIconWindow:Load=====begin")

	self.mRootNode = cc.Node:create()
	GUISystem:GetRootNode():addChild(self.mRootNode)
	self.mIconTotal = #DB_PlayerIcon.PlayerIcon

	------

	self:InitLayout()

	cclog("=====ChangeHeroIconWindow:Load=====end")
end

function ChangeHeroIconWindow:InitLayout()

	self.mRootWidget = GUIWidgetPool:createWidget("Setting_PlayerIconReplace")
	self.mRootNode:addChild(self.mRootWidget)

	self.mPanelBottom = self.mRootWidget:getChildByName("Panel_Bottom")

	self.mFrame = globaldata.playerFrame
	self.mHeroiconId = globaldata.playerIcon

	self:InitClickBtn()

	-- --更换英雄
	-- registerWidgetReleaseUpEvent(self.mTeamWidget:getChildByName("Button_ChangeHero"),handler(self,self.ChangeheroBtn))
	-- -- 组队战斗
	-- registerWidgetReleaseUpEvent(self.mMainWidget:getChildByName("Button_Fight"),handler(self,self.TeamFight))
	-- -- 关主队界面
	-- registerWidgetReleaseUpEvent(self.mTeamWidget:getChildByName("Button_Close"),handler(self,self.TeamFightClose))
	-- -- 创建队伍
	-- registerWidgetReleaseUpEvent(self.mTeamWidget:getChildByName("Button_CreatTeam"),handler(self,self.CreatTeam))
	-- -- 离开队伍
	-- registerWidgetReleaseUpEvent(self.mTeamWidget:getChildByName("Button_LeaveTeam"),handler(self,self.LeaveTeam))
	-- -- 准备
	-- registerWidgetReleaseUpEvent(self.mTeamWidget:getChildByName("Button_GetReady"),handler(self,self.onGetReady))

	registerWidgetReleaseUpEvent(self.mPanelBottom:getChildByName("Button_Save"),handler(self,self.onSave))
	registerWidgetReleaseUpEvent(self.mRootWidget:getChildByName("Button_Close"),handler(self,self.onCancel))

	NetSystem.mNetManager:RegisterPacketHandler(PacketTyper._PTYPE_SC_CHANGE_ICON_, handler(self,self.onRequestIcon))

end

function ChangeHeroIconWindow:InitClickBtn()

	local function HaveIcon(icondata)
		cclog("HaveIconID============================="..icondata.ID)
		local panel = self.mRootWidget:getChildByName(string.format("Panel_icon_%d",icondata.ID))
		local skillIcon = DB_ResourceList.getDataById(icondata.ResourceListID).Res_path1
		panel:getChildByName("Image_Icon"):loadTexture(skillIcon)
		panel:setTag(icondata.ID)
		registerWidgetReleaseUpEvent(panel,handler(self,self.onClickPanel))
		if self.mFrame == icondata.ID or self.mHeroiconId == icondata.ID then
			panel:getChildByName("Image_Chose"):setVisible(true)
		end
	end

	local function NoneIcon(icondata)
		cclog("NoneIcon============================="..icondata.ID)
		local panel = self.mRootWidget:getChildByName(string.format("Panel_icon_%d",icondata.ID))
		local skillIcon = DB_ResourceList.getDataById(icondata.ResourceListID).Res_path1
		panel:getChildByName("Image_Icon"):loadTexture(skillIcon)
		panel:setTag(icondata.ID)
		ShaderManager:DoUIWidgetDisabled(panel:getChildByName("Image_Icon"), true)
		registerWidgetReleaseUpEvent(panel,handler(self,self.onClickNonePanel))
	end

	for k,v in pairs(DB_PlayerIcon.PlayerIcon) do
		local TableData = DB_PlayerIcon.getDataById(k)
		if TableData.Type == 1 then
			if TableData.VIP == 0  or TableData.VIP <= globaldata:getPlayerBaseData("vipLevel") then
				HaveIcon(TableData)
			else
				NoneIcon(TableData)
			end
		else
			if TableData.VIP == 0 and TableData.HeroID == 0 then
				HaveIcon(TableData)
			elseif TableData.VIP == 0 and TableData.HeroID ~= 0 then
				if globaldata:isHeroIdExist(TableData.HeroID) then
					HaveIcon(TableData)
				else
					NoneIcon(TableData)
				end
			elseif TableData.VIP <= globaldata:getPlayerBaseData("vipLevel") then
				HaveIcon(TableData)
			else
				NoneIcon(TableData)
			end
		end	
	end
end

function ChangeHeroIconWindow:SendIcon()
	local packet = NetSystem.mNetManager:GetSPacket()
	packet:SetType(PacketTyper._PTYPE_CS_CHANGE_ICON_)
	packet:PushInt(self.mFrame)
	packet:PushInt(self.mHeroiconId)
	packet:Send()
	GUISystem:showLoading()
end

function ChangeHeroIconWindow:onRequestIcon(msgPacket)
	GUISystem:hideLoading()
	local result = msgPacket:GetChar()
	if result == 0 then
		local Frame = msgPacket:GetInt()
		local heroIcon = msgPacket:GetInt()
		globaldata.playerFrame = Frame
		globaldata.playerIcon = heroIcon
		if GUISystem:GetWindowByName("HomeWindow").mRootWidget then
			local data = DB_PlayerIcon.getDataById(heroIcon)
			local skillIcon = DB_ResourceList.getDataById(data.ResourceListID).Res_path1
			GUISystem:GetWindowByName("HomeWindow").mRootWidget:getChildByName("Panel_PlayerInfo"):getChildByName("Image_PlayerHead"):loadTexture(skillIcon)
		end

		if GUISystem:GetWindowByName("PlayerSettingWindow").mPanelPlayer then
			local setpanel =  GUISystem:GetWindowByName("PlayerSettingWindow").mPanelPlayer
			local Frameres = FindFrameIconbyId(Frame)
			setpanel:getChildByName("Image_PlayerBg"):loadTexture(Frameres)
			local Iconres = FindFrameIconbyId(heroIcon)
			setpanel:getChildByName("Image_PlayerIcon"):loadTexture(Iconres)
		end
	end
	EventSystem:PushEvent(Event.GUISYSTEM_HIDE_CHANGEHEROICONWINDOW)
end

function ChangeHeroIconWindow:onClickNonePanel(widget)
	local tag = widget:getTag()
	local data = DB_PlayerIcon.getDataById(tag)
	MessageBox:showMessageBox1(getDictionaryText(data.Tips))
end

function ChangeHeroIconWindow:onClickPanel(widget)
	local tag = widget:getTag()
	if self.mFrame == tag or self.mHeroiconId == tag then
		return
	end
	local data = DB_PlayerIcon.getDataById(tag)
	if data.Type == 1 then
		local panel = self.mRootWidget:getChildByName(string.format("Panel_icon_%d",self.mFrame))
		panel:getChildByName("Image_Chose"):setVisible(false)
		self.mFrame = tag
		local panel = self.mRootWidget:getChildByName(string.format("Panel_icon_%d",self.mFrame))
		panel:getChildByName("Image_Chose"):setVisible(true)
	else
		local panel = self.mRootWidget:getChildByName(string.format("Panel_icon_%d",self.mHeroiconId))
		panel:getChildByName("Image_Chose"):setVisible(false)
		self.mHeroiconId = tag
		local panel = self.mRootWidget:getChildByName(string.format("Panel_icon_%d",self.mHeroiconId))
		panel:getChildByName("Image_Chose"):setVisible(true)
	end
end

function ChangeHeroIconWindow:onSave()
	if globaldata.playerFrame == self.mFrame and globaldata.playerIcon == self.mHeroiconId then
		EventSystem:PushEvent(Event.GUISYSTEM_HIDE_CHANGEHEROICONWINDOW)
	else
		self:SendIcon()
	end
end

function ChangeHeroIconWindow:onCancel()
	EventSystem:PushEvent(Event.GUISYSTEM_HIDE_CHANGEHEROICONWINDOW)
end

function ChangeHeroIconWindow:Destroy()
	self.mRootNode:removeFromParent(true)
	self.mRootNode = nil
	self.mRootWidget = nil

	CommonAnimation.clearAllTextures()
end

function ChangeHeroIconWindow:onEventHandler(event)
	if event.mAction == Event.WINDOW_SHOW then
		if GUISystem:canShow(self.mName) then
			self:Load(event)
		end
	elseif event.mAction == Event.WINDOW_HIDE then
		self:Destroy()
	end
end

return ChangeHeroIconWindow