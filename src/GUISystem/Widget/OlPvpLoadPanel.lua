-- Func: PVP加载进度界面
-- Author: tuanzhang

OlPvpLoadPanel = class("OlPvpLoadPanel", function()
   return cc.Node:create()
end)

function OlPvpLoadPanel:ctor()
    local widget = nil 
    if globaldata.olpvpType == 1 or globaldata.olpvpType == 2 then
       widget = GUIWidgetPool:createWidget("Fight_KOF3v3_LoadingPrograss")
    else
       widget = GUIWidgetPool:createWidget("Fight_KOF_LoadingPrograss")
    end
    self.mWidget = widget
    self:addChild(self.mWidget)
    self.mWidget:setPosition(0,0)
    if globaldata.olpvpType == 1 or globaldata.olpvpType == 2 then
        self:setPanel3v3()
    else
        self:setPanel1v1()
    end

    local function doAdapter()
        -- 背景适配
        local winSize = cc.Director:getInstance():getVisibleSize()
        local oldSize = self.mWidget:getChildByName("Image_Loading_Bg"):getContentSize()
        oldSize.width = winSize.width
        self.mWidget:getChildByName("Image_Loading_Bg"):setContentSize(oldSize)
    end
    doAdapter()
end

function OlPvpLoadPanel:setPanel1v1()
    self.mPanelSelf = self.mWidget:getChildByName("Panel_Self")
    self.mPanelEnemy = self.mWidget:getChildByName("Panel_Enemy")
    self.mPanelSelf:getChildByName("ProgressBar_Loading"):setPercent(0)
    self.mPanelEnemy:getChildByName("ProgressBar_Loading"):setPercent(0)
    
    local name = globaldata:getBattleFormationInfoByIndexAndKey(1, "playerName")
    local name1 = globaldata:getBattleEnemyFormationInfoByIndexAndKey(1, "playerName")
    self.mPanelSelf:getChildByName("Label_PlayerName_Stroke"):setString(name)
    self.mPanelEnemy:getChildByName("Label_PlayerName_Stroke"):setString(name1)

end

function OlPvpLoadPanel:setPanel3v3()
    for i=1,3 do
        local mypanel = self.mWidget:getChildByName("Panel_Self_"..i)
        mypanel:getChildByName("ProgressBar_Loading"):setPercent(0)
        local name = globaldata:getBattleFormationInfoByIndexAndKey(i, "playerName")
        mypanel:getChildByName("Label_PlayerName_Stroke"):setString(name)
        local enemypanel = self.mWidget:getChildByName("Panel_Enemy_"..i)
        enemypanel:getChildByName("ProgressBar_Loading"):setPercent(0)
        local name1 = globaldata:getBattleEnemyFormationInfoByIndexAndKey(i, "playerName")
        enemypanel:getChildByName("Label_PlayerName_Stroke"):setString(name1)
    end
end


function OlPvpLoadPanel:setPercentByIndex(index,percent)
    local index1 = index%2
    if globaldata.olHoldindex == index1 then
        self.mPanelSelf:getChildByName("Label_Loading"):setString(tostring(percent))
        self.mPanelSelf:getChildByName("ProgressBar_Loading"):setPercent(percent)
    else
        self.mPanelEnemy:getChildByName("Label_Loading"):setString(tostring(percent))
        self.mPanelEnemy:getChildByName("ProgressBar_Loading"):setPercent(percent)
    end
end

function OlPvpLoadPanel:setPercent3v3ByIndex(index,percent)
    local index , team = globaldata:convertOlindex(index)
    if team == "friend" then
        local mypanel = self.mWidget:getChildByName("Panel_Self_"..index)
        mypanel:getChildByName("Label_Loading"):setString(tostring(percent))
        mypanel:getChildByName("ProgressBar_Loading"):setPercent(percent)
    else
        local enemypanel = self.mWidget:getChildByName("Panel_Enemy_"..index)
        enemypanel:getChildByName("Label_Loading"):setString(tostring(percent))
        enemypanel:getChildByName("ProgressBar_Loading"):setPercent(percent)
    end
end 
