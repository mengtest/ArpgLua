-- Name: 	PlayerSettingWindow.lua
-- Func：	人物设置界面
-- Author:	tuanzhang
-- Data:	15-7-27

local PlayerSettingWindow = 
{
	mName		=	"PlayerSettingWindow",
	mIsLoaded   =   false,
	mRootNode	=	nil,
	mRootWidget	=	nil,

	mBornWidget =   nil,
}

function PlayerSettingWindow:Release()
end

function PlayerSettingWindow:Load(event)
	cclog("=====PlayerSettingWindow:Load=====begin")

	self.mBornWidget = event.mData

	self.mIsLoaded = true
	self.mRootNode = cc.Node:create()
	GUISystem:GetRootNode():addChild(self.mRootNode)
	self:InitLayout()

	
	
	cclog("=====PlayerSettingWindow:Load=====end")
end

function PlayerSettingWindow:InitLayout()
	self.mRootWidget = GUIWidgetPool:createWidget("SettingMain")
	self.mRootNode:addChild(self.mRootWidget)

	self.mPanelPlayer = self.mRootWidget:getChildByName("Panel_PlayerInfo") 

	self.mPanelSystem = self.mRootWidget:getChildByName("Panel_SystemSetting") 

	self.mPlayBtn = self.mRootWidget:getChildByName("Image_PlayInfo")
	self.mPlayBtn:setTag(1)
	self.mSetTag = 1
	self.mSystemBtn = self.mRootWidget:getChildByName("Image_System")
	self.mSystemBtn:setTag(2)
	registerWidgetReleaseUpEvent(self.mPlayBtn, handler(self, self.OnEventPlayerInfo))
	registerWidgetReleaseUpEvent(self.mSystemBtn, handler(self, self.OnEventSetting))
	registerWidgetReleaseUpEvent(self.mPanelSystem:getChildByName("Button_ShieldOthers"), handler(self, self.OnSheildOP))
	registerWidgetReleaseUpEvent(self.mPanelSystem:getChildByName("Button_Perform"), handler(self, self.OnPerform))
	registerWidgetReleaseUpEvent(self.mRootWidget:getChildByName("Button_Close"), handler(self, self.closeWindow))
	registerWidgetReleaseUpEvent(self.mPanelPlayer:getChildByName("Button_LogOff"), handler(self, self.backToLoginWindow))
	registerWidgetReleaseUpEvent(self.mPanelPlayer:getChildByName("Button_ChangePlayIcon"), handler(self, self.onChangeIconBtn))
--	registerWidgetReleaseUpEvent(self.mPanelPlayer:getChildByName("Button_PlayerTitle"), handler(self, self.onChangeTitleBtn))

	local moveWidget = self.mRootWidget:getChildByName("Panel_Main")
	local tarSize = moveWidget:getContentSize()
	local tarPos = moveWidget:getWorldPosition()
	tarPos.x = tarPos.x + tarSize.width/2
	tarPos.y = tarPos.y + tarSize.height/2
	local bornPos = self.mBornWidget:getWorldPosition()
	moveWidget:setAnchorPoint(cc.p(0.5, 0.5))
	moveWidget:setPosition(bornPos)
	moveWidget:setScale(0.1)
	moveWidget:setOpacity(0)

	local tm = 0.2
	local act0 = cc.MoveTo:create(tm, tarPos)
	local act1 = cc.FadeIn:create(tm)
	local act2 = cc.ScaleTo:create(tm, 1)
	moveWidget:runAction(cc.Spawn:create(act0, act1, act2))

	self:setTab(self.mSetTag)
	-- 
	self:InitPlayInfo()
	self:UpdateSystemSetting()
	local function changeHeroIcon()
		local data = DB_PlayerIcon.getDataById(globaldata.playerFrame)
		local Frameres = DB_ResourceList.getDataById(data.ResourceListID).Res_path1
		self.mPanelPlayer:getChildByName("Image_PlayerBg"):loadTexture(Frameres)
		local data1 = DB_PlayerIcon.getDataById(globaldata.playerIcon)
		local Iconres = DB_ResourceList.getDataById(data1.ResourceListID).Res_path1
		self.mPanelPlayer:getChildByName("Image_PlayerIcon"):loadTexture(Iconres)
	end
	changeHeroIcon()

	----------------------------------BGM and Effect-------------------------------------
	-- 注册BGM与音效事件
	local panel_bgm = self.mPanelSystem:getChildByName("Panel_Music")
	local slider_bgm = panel_bgm:getChildByName("Slider_Music")
	local lb_bgm = panel_bgm:getChildByName("Label_Volume")
	local img_bgm = panel_bgm:getChildByName("Image_Silence")
	local panel_effect = self.mPanelSystem:getChildByName("Panel_Sound")
	local slider_effect = panel_effect:getChildByName("Slider_Sound")
	local lb_effect = panel_effect:getChildByName("Label_Volume")
	local img_effect = panel_effect:getChildByName("Image_Silence")
	local function BGMpercentChangedEvent(sender,eventType)
        if eventType == ccui.SliderEventType.percentChanged then
        	local slider = sender
        	local volume = slider:getPercent()
            if volume == 0 then
               lb_bgm:setVisible(false)
               img_bgm:setVisible(true)
            else
               lb_bgm:setVisible(true)
               img_bgm:setVisible(false)
           	   lb_bgm:setString(string.format("%d%%",volume))
           	end
           	SoundSystem:setBGMVolumeToSetting(volume)
        end
	end
	slider_bgm:addEventListener(BGMpercentChangedEvent)
	local function EffectpercentChangedEvent(sender,eventType)
        if eventType == ccui.SliderEventType.percentChanged then
        	local slider = sender
        	local volume = slider:getPercent()
            if volume == 0 then
               lb_effect:setVisible(false)
               img_effect:setVisible(true)
            else
               lb_effect:setVisible(true)
               img_effect:setVisible(false)
           	   lb_effect:setString(string.format("%d%%",volume))
           	end
           	SoundSystem:setEffectVolumeToSetting(volume)
        end
	end
	slider_effect:addEventListener(EffectpercentChangedEvent)
	-- 初始化
	local function initBGMandEffectDisplay()
		local bgm_volume = SoundSystem:getBGMVolumBySetting()
		-- 静音-1标志转为0
		if bgm_volume == -1 then bgm_volume = 0 end
		slider_bgm:setPercent(bgm_volume)
        if bgm_volume == 0 then
           lb_bgm:setVisible(false)
           img_bgm:setVisible(true)
        else
           lb_bgm:setVisible(true)
           img_bgm:setVisible(false)
       	   lb_bgm:setString(string.format("%d%%",bgm_volume))
       	end
       	local effect_volume = SoundSystem:getEffectVolumBySetting()
		-- 静音-1标志转为0
		if effect_volume == -1 then effect_volume = 0 end
		slider_effect:setPercent(effect_volume)
        if effect_volume == 0 then
           lb_effect:setVisible(false)
           img_effect:setVisible(true)
        else
           lb_effect:setVisible(true)
           img_effect:setVisible(false)
       	   lb_effect:setString(string.format("%d%%",effect_volume))
       	end	
	end
	initBGMandEffectDisplay()
	----------------------------------BGM and Effect-------------------------------------
	-----------------------------------------------------好友切磋相关(wangsd.16-3-1)(begin)-------------------------------------------------
	-- 刷新
	local function updatePkState()
		if 0 == globaldata.friendPlayerPK then
			self.mRootWidget:getChildByName("Button_Duel"):loadTextureNormal("setting_switch_on.png")
		elseif 1 == globaldata.friendPlayerPK then
			self.mRootWidget:getChildByName("Button_Duel"):loadTextureNormal("setting_switch_off.png")
		end
		GUISystem:hideLoading()
	end

	-- 回包
	local function onRequestSetPkState(msgPacket)
		globaldata.friendPlayerPK = msgPacket:GetInt()
		updatePkState()
	end
	NetSystem.mNetManager:RegisterPacketHandler(PacketTyper._PTYPE_SC_FRIEND_PK_SET, onRequestSetPkState)

	-- 请求
	local function requestSetPkState()
		local packet = NetSystem.mNetManager:GetSPacket()
		packet:SetType(PacketTyper._PTYPE_CS_FRIEND_PK_SET)

		if 0 == globaldata.friendPlayerPK then
			packet:PushInt(1)
		elseif 1 == globaldata.friendPlayerPK then
			packet:PushInt(0)
		end
		packet:Send()
		GUISystem:showLoading()
		self.mRootWidget:getChildByName("Button_Duel"):loadTextureNormal("setting_switch_mid.png")
	end
	updatePkState()
	registerWidgetPushDownEvent(self.mRootWidget:getChildByName("Button_Duel"), requestSetPkState)
	-----------------------------------------------------好友切磋相关(wangsd.16-3-1)(end)-------------------------------------------------

end

function PlayerSettingWindow:setTab(_index)
	if 1 == _index then
		self.mPlayBtn:loadTexture("setting_page_playinfo1.png")
		self.mSystemBtn:loadTexture("setting_page_system2.png")
		self.mPanelPlayer:setVisible(true)
		self.mPanelSystem:setVisible(false)
	elseif 2 == _index then
		self.mPlayBtn:loadTexture("setting_page_playinfo2.png")
		self.mSystemBtn:loadTexture("setting_page_system1.png")
		self.mPanelPlayer:setVisible(false)
		self.mPanelSystem:setVisible(true)
	end
end

function PlayerSettingWindow:InitPlayInfo()
	self.mPanelPlayer:getChildByName("Label_PlayerLevel"):setString(tostring(globaldata:getPlayerBaseData("level")))
	self.mPanelPlayer:getChildByName("Label_VIP"):setString(tostring(globaldata:getPlayerBaseData("vipLevel")))
	self.mPanelPlayer:getChildByName("Label_PlayName"):setString(tostring(globaldata:getPlayerBaseData("name")))
	local exp = globaldata:getPlayerBaseData("exp")
	local maxExp = globaldata:getPlayerBaseData("maxExp")
	local value = exp/maxExp *100
	self.mPanelPlayer:getChildByName("ProgressBar_EXP"):setPercent(value)
	self.mPanelPlayer:getChildByName("Label_EXP_Stroke"):setString(string.format("%d/%d",exp,maxExp))

	-- 玩家ID
	self.mPanelPlayer:getChildByName("Label_PlayerID"):setString(globaldata.playerId)

	-- 帮会姓名
	if "" == globaldata.partyName then
		self.mPanelPlayer:getChildByName("Label_BanghuiName"):setString("未加入任何公会")
	else
		self.mPanelPlayer:getChildByName("Label_BanghuiName"):setString(tostring(globaldata.partyName))
	end

	-- 帮会ID
	if "" == globaldata.partyId then
		self.mPanelPlayer:getChildByName("Label_BanghuiID"):setString("未加入任何公会")
	else
		self.mPanelPlayer:getChildByName("Label_BanghuiID"):setString(tostring(globaldata.partyId))
	end
end

function PlayerSettingWindow:UpdateSystemSetting()
	if FightSystem:isEnabledSheildOP() then
		self.mPanelSystem:getChildByName("Button_ShieldOthers"):loadTextureNormal("setting_switch_on.png")
	else
		self.mPanelSystem:getChildByName("Button_ShieldOthers"):loadTextureNormal("setting_switch_off.png")
	end

	if FightSystem:isEnabledGameperformance() then
		self.mPanelSystem:getChildByName("Button_Perform"):loadTextureNormal("setting_switch_on.png")
	else
		self.mPanelSystem:getChildByName("Button_Perform"):loadTextureNormal("setting_switch_off.png")
	end
end

-- 屏蔽其他玩家
function PlayerSettingWindow:OnSheildOP()
	if FightSystem:isEnabledSheildOP() then
		FightSystem:enabledSheildOP(false)
	else
		FightSystem:enabledSheildOP(true)
	end
	HallManager:checkRenderAllOP()
	self:UpdateSystemSetting()
end

-- 屏蔽其他玩家
function PlayerSettingWindow:OnPerform()
	if FightSystem:isEnabledGameperformance() then
		FightSystem:enableGameperformance(false)
	else
		FightSystem:enableGameperformance(true)
	end
	self:UpdateSystemSetting()
end

function PlayerSettingWindow:OnEventPlayerInfo(widget)
	if self.mSetTag == widget:getTag() then return end
	self.mSetTag = 1
	self:setTab(self.mSetTag)

end

function PlayerSettingWindow:OnEventSetting(widget)
	if self.mSetTag == widget:getTag() then return end
	self.mSetTag = 2
	self:setTab(self.mSetTag)
end

-- 关闭设置窗口
function PlayerSettingWindow:closeWindow()
	local function actEnd()
		EventSystem:PushEvent(Event.GUISYSTEM_HIDE_PLAYERSETTINGWINDOW)
	end

	local moveWidget = self.mRootWidget:getChildByName("Panel_Main")
	local tarPos = self.mBornWidget:getWorldPosition()

	local tm = 0.2
	local act0 = cc.MoveTo:create(tm, tarPos)
	local act1 = cc.FadeOut:create(tm)
	local act2 = cc.ScaleTo:create(tm, 0.5)
	local act3 = cc.Spawn:create(act0, act1, act2)
	local act4 = cc.CallFunc:create(actEnd)

	moveWidget:runAction(cc.Sequence:create(act3, act4))

	local panel_bgm = self.mPanelSystem:getChildByName("Panel_Music")
	local panel_effect = self.mPanelSystem:getChildByName("Panel_Sound")
	panel_bgm:setVisible(false)
	panel_effect:setVisible(false)
end

-- 更换头像按钮
function PlayerSettingWindow:onChangeIconBtn()
	EventSystem:PushEvent(Event.GUISYSTEM_SHOW_CHANGEHEROICONWINDOW)
end

-- 换英雄称号
function PlayerSettingWindow:onChangeTitleBtn()
	GUISystem:goTo("herotitle")
end


-- 退出游戏
function PlayerSettingWindow:backToLoginWindow()
	NetManager:ForceDisconnectGameServer()
	GUISystem:BackToLoginWindow()
	PKHelper:CancelInvite()
end

function PlayerSettingWindow:Destroy()
	if not self.mIsLoaded then return end
	self.mIsLoaded = false
	self.mRootNode:removeFromParent(true)
	self.mRootNode = nil
	self.mRootWidget = nil
	self.mPanelPlayer = nil
	self.mPanelSystem = nil
	self.mTakeCardlist = {}
	self.Heroexplist = {}
	self.mRewardCardList = {}
	self.mTrueCard = nil
	self.mPosTurnCardList = {}
	self.misFlagFinishCard = false
	---------
	CommonAnimation:clearAllTextures()
	cclog("=====BattleResult_WinWindow:Destroy=====")
end

function PlayerSettingWindow:onEventHandler(event)
	if event.mAction == Event.WINDOW_SHOW then
		self:Load(event)
	elseif event.mAction == Event.WINDOW_HIDE then
		self:Destroy()
	end
end

return PlayerSettingWindow