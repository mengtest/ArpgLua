-- Func: 查看玩家信息界面
-- Author: tuanzhang

CheckPlayerInfo = class("CheckPlayerInfo", function()
   return cc.Node:create()
end)

function CheckPlayerInfo:ctor(data)
    self.mPlayerID = data.playerId 
    self.mPlayName = data.playerName
    local widget =  GUIWidgetPool:createWidget("FriendsPlayerWindow")
    self.mRootWidget = widget
    self:addChild(self.mRootWidget)
    self.mRootWidget:setPosition(0,0)
    self.mWidth = self.mRootWidget:getChildByName("Image_Bg"):getBoundingBox().width

    self.mRootWidget:getChildByName("Label_Banghui"):setString(data.banghuiName)

    registerWidgetReleaseUpEvent(self.mRootWidget:getChildByName("Button_Add"), handler(self, self.OnAddFriend))
    registerWidgetReleaseUpEvent(self.mRootWidget:getChildByName("Button_Delete"), handler(self, self.OnDeleteFriend))
    registerWidgetReleaseUpEvent(self.mRootWidget:getChildByName("Button_Chat"), handler(self, self.OnChart))
    registerWidgetReleaseUpEvent(self.mRootWidget:getChildByName("Button_Fight"), handler(self, self.OnPK))
    registerWidgetReleaseUpEvent(self.mRootWidget:getChildByName("Button_Visit"), handler(self, self.OnVisitHome))
   -- ShaderManager:DoUIWidgetDisabled(self.mRootWidget:getChildByName("Button_Fight"), true)
    ShaderManager:DoUIWidgetDisabled(self.mRootWidget:getChildByName("Button_Visit"), true)
   -- self.mRootWidget:getChildByName("Button_Fight"):setEnabled(false)
    self.mRootWidget:getChildByName("Button_Visit"):setEnabled(false)

    if data.isfriend == 0 then
        self.mRootWidget:getChildByName("Button_Add"):setVisible(false)
        self.mRootWidget:getChildByName("Button_Delete"):setVisible(true)
    else
        self.mRootWidget:getChildByName("Button_Add"):setVisible(true)
        self.mRootWidget:getChildByName("Button_Delete"):setVisible(false)
    end
    self:ShowInfo(data)
end

function CheckPlayerInfo:ShowInfo(data)
    local playerInfoWidget = GUIWidgetPool:createWidget("PlayerInfo")
    self.mRootWidget:getChildByName("Panel_PlayInfo"):addChild(playerInfoWidget)
    playerInfoWidget:getChildByName("Image_PlayerHead_Bg"):loadTexture(FindFrameIconbyId(data.playerFrame))
    playerInfoWidget:getChildByName("Image_PlayerHead"):loadTexture(FindFrameIconbyId(data.playerIcon))
    playerInfoWidget:getChildByName("Label_Level"):setString(tostring(data.playerLevel))
    playerInfoWidget:getChildByName("Label_Name"):setString(data.playerName)
    playerInfoWidget:getChildByName("Label_Zhanli"):setString(tostring(data.playerZhanli))
    
    -- 英雄
    for i = 1, data.heroCount do
      local heroWidget = createHeroIcon(data.hero[i].heroId, data.hero[i].level, data.hero[i].quality, data.hero[i].advanceLevel)
      self.mRootWidget:getChildByName(string.format("Panel_Hero%d",i)):addChild(heroWidget)
    end
    -- 排名
    if data.playerRank > 0 then
        self.mRootWidget:getChildByName("Label_Ranking"):setString(tostring(data.playerRank))
    else
        self.mRootWidget:getChildByName("Label_Ranking"):setString("无排名")
    end
end

-- 添加好友
function CheckPlayerInfo:OnAddFriend()
    local packet = NetSystem.mNetManager:GetSPacket()
    packet:SetType(PacketTyper._PTYPE_CS_REQUEST_ADD_FRIEND_)
    packet:PushString(self.mPlayerID)
    packet:Send()
end

-- 删除好友
function CheckPlayerInfo:OnDeleteFriend()
    local packet = NetSystem.mNetManager:GetSPacket()
    packet:SetType(PacketTyper._PTYPE_CS_DELETE_FRIEND_)
    packet:PushString(self.mPlayerID)
    packet:Send()
end

-- chart
function CheckPlayerInfo:OnChart()
    if HallManager:isInUnionHall() then
        if GUISystem:GetWindowByName("UnionHallWindow").mBottomChatPanel then
            GUISystem:GetWindowByName("UnionHallWindow").mBottomChatPanel:talkToSomebody(self.mPlayerID, self.mPlayName)
        end
    else
        GUISystem:requestTalkToSomebody(self.mPlayerID,self.mPlayName) 
    end
    FightSystem.mHallManager:rmPlayerInfo()
    if GUISystem.Windows["WorldBossWindow"].mRootNode then
        GUISystem.Windows["WorldBossWindow"]:PlayerInfoTouch()
    end
end

-- pk
function CheckPlayerInfo:OnPK()
    -- local packet = NetSystem.mNetManager:GetSPacket()
    -- packet:SetType(PacketTyper._PTYPE_CS_REQUEST_PLAYER_PK_)
    -- packet:PushString(self.mPlayerID)
    -- packet:Send()
    -- GUISystem:showLoading()
    globaldata.mPkplayerId = self.mPlayerID
    PKHelper:DoPKInvite(self.mPlayerID,self.mPlayName)
    --EventSystem:PushEvent(Event.GUISYSTEM_HIDE_HOMEWINDOW)
end

-- 访问好友家
function CheckPlayerInfo:OnVisitHome()
    -- 请求服务器去好友家
    local packet = NetSystem.mNetManager:GetSPacket()
    packet:SetType(PacketTyper._PTYPE_CS_VISITHOME_FRIEND_)
    packet:PushString(self.mPlayerID)
    packet:Send()

    GUISystem:showLoading()

end

