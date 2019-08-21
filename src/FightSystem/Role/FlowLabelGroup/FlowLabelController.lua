-- Name: FlowLabelController
-- Func: 文字漂浮控制器
-- Author: Johny

FlowLabelController = class("FlowLabelController")
require  "FightSystem/Role/FlowLabelGroup/FlowSpineEffect"

function FlowLabelController:ctor(_role)
	self.mRole = _role
    self.mShowSkillStateDuring = 0
    --
    local _lb = ccui.Text:create()
    _lb:setLocalZOrder(FightConfig.TILED_ZORDER.SKILLSTATE)
    FightSystem.mSceneManager:GetTiledLayer(self.mRole.mSceneIndex):addChild(_lb)
    self.mSkillStateLabel = _lb
    self.FlowList = {}
end

function FlowLabelController:Destroy()
    self.mRole = nil
    self.mShowSkillStateDuring = 0
    self.mSkillStateLabel:removeFromParent()
    self.mSkillStateLabel = nil
    self.FlowList = nil
end

function FlowLabelController:Tick(delta)
    if self.mShowSkillStateDuring > 0 then
       self.mShowSkillStateDuring = self.mShowSkillStateDuring -1
       if self.mShowSkillStateDuring == 0 then
          self.mSkillStateLabel:setVisible(false)
       end
    end
end

-- 飘BUFF文字
function FlowLabelController:FlowBuffName(name)
    local _lb = ccui.Text:create()
    _lb:setFontName("res/fonts/font_3.ttf")
    _lb:setFontSize(30)
    _lb:setString(name)
    _lb:setAnchorPoint(cc.p(0.5,0.5))
    _lb:setPosition(self.mRole:getPositionX(), self.mRole:getPositionY() + self.mRole.mSize.height * 0.5)
    _lb:setScale(0)
    _lb:setOpacity(255)
    _lb:setLocalZOrder(self.mRole:getLocalZOrder() + 10)
    _lb:setColor(cc.c3b(102,217,239))
    LabelManager:outline(_lb,G_COLOR_C4B.BLACK)
    FightSystem.mSceneManager:GetTiledLayer(self.mRole.mSceneIndex):addChild(_lb)
    --
    local function ActionCallBack( sender )
        sender:removeFromParent()
    end
    --
    -- 计算偏移参数
    local function getActionMove1(_hiter)
        --+(self.mRole.mInstanceID%10 *30
        local _disX = math.cos(math.rad(53.75)) * 93
        local _disY = math.sin(math.rad(53.75)) * 93
        local _during = 1/10
        if _hiter and _hiter.IsFaceLeft then
            --cclog("攻击者面向左")
           _disX = - _disX
        elseif not _hiter then
            if not self.mRole.IsFaceLeft then
                _disX = - _disX
            end
        end
        local _actionMove = cc.MoveBy:create(_during, cc.p(_disX, _disY))
        local _actionStyle = cc.ScaleTo:create(_during, 1)
        local _tb = {_actionMove, _actionStyle}

        return cc.Spawn:create(_tb)
    end
    -- 计算飘逸参数
    local function getActionMove2()
        local _disY = 60
        local _during = 4/3
        local _actionMove = cc.MoveBy:create(_during, cc.p(0, _disY))
        local _actionFadeOut = cc.FadeOut:create(_during)
        return _actionFadeOut
    end

    local _ac1 = getActionMove1(_hiter)
    local _ac3 = getActionMove2()
    local _ac4 = cc.CallFunc:create(ActionCallBack)
    local _actionSeq = cc.Sequence:create({_ac1, _ac3, _ac4})
    _lb:runAction(_actionSeq)
end

-- 飘伤害
function FlowLabelController:CreateNumFnt(_num, type)

    local strnum = tostring(_num)
    local lennum = string.len(strnum)
    local node = cc.Node:create()
    node:setAnchorPoint(cc.p(0.5,0.5))
    local len = 0
    local height = 0
    local numlist = {}
    for i=1,lennum do
        local min = _num%10
        local shu0 = cc.Sprite:create()
        shu0:setProperty("Frame", string.format("fight_%s_%d.png",type,min))
        shu0:setAnchorPoint(cc.p(1,0))
        shu0:setPosition(cc.p(len,0))
        node:addChild(shu0)
        len = len - shu0:getContentSize().width
        height = shu0:getContentSize().height
        _num = math.floor(_num/10)
        table.insert(numlist,shu0)
    end
    local x = math.abs(len)/2
    for k,v in pairs(numlist) do
        v:setPositionX(v:getPositionX()+x)
        v:setPositionY(v:getPositionY()-height/2)
    end
    return node
end

-- 飘伤害
function FlowLabelController:FlowDamage(_tp, _num, _hiter)
    if _num == 0 then return end
    _num = math.ceil(_num)
    local path = "font_red"
    if self.mRole.mGroup == "monster" or self.mRole.mGroup == "enemyplayer" then
        if _tp == "crit" then
            path = "font_orange"
        else
            path = "font_yellow"
        end
    end
    -- local _lb = CocosCacheManager:getLabelBMFont(path)
    -- _lb:setString(string.format("%d", _num))
    -- _lb:setAnchorPoint(cc.p(0.5,0.5))
   

   local node = self:CreateNumFnt(_num,path)

    node:setPosition(self.mRole:getPositionX(), self.mRole:getPositionY() + self.mRole.mSize.height * 0.5)
    node:setScale(0)
    node:setOpacity(255)
    node:setLocalZOrder(self.mRole:getLocalZOrder() + 1)
    FightSystem.mSceneManager:GetTiledLayer(self.mRole.mSceneIndex):addChild(node)
    --
    local function ActionDoac1( sender )
        local _y = sender:getPositionY() + sender:getBoundingBox().width/2
        for k,v in pairs(FightSystem.mRoleManager:GetEnemyTable(self.mRole.mSceneIndex)) do
            local label = v.mFlowLabelCon:GetFlowLable()
            if label then
                local y = label:getPositionY() - label:getBoundingBox().width/2
                if y - _y < 0 then
                    v.mFlowLabelCon:setFlowLableDis(20)
                end
            end
        end  
        if self.mRole.mGroup == "monster" or self.mRole.mGroup == "enemyplayer" then
            self.FlowList[sender] = sender
            sender:setTag(1)
        end
    end

    local function ActionCallBack( sender )
        sender:removeFromParent()
    end
    --
    -- 计算偏移参数
    local function getActionMove1(_hiter)
        --+(self.mRole.mInstanceID%10 *30
        local _disX = math.cos(math.rad(53.75)) * 93
        local _disY = math.sin(math.rad(53.75)) * 93
        local _during = 1/10
        if _hiter and _hiter.IsFaceLeft then
            --cclog("攻击者面向左")
           _disX = - _disX
        elseif not _hiter then
            if not self.mRole.IsFaceLeft then
                _disX = - _disX
            end
        end

        local scale = 0.5
        if _tp == "crit" then
            scale = 1
        end

        local _actionMove = cc.MoveBy:create(_during, cc.p(_disX, _disY))
        local _actionStyle = cc.ScaleTo:create(_during,scale)
        local _tb = {_actionMove, _actionStyle}

        return cc.Spawn:create(_tb)
    end
    -- 计算飘逸参数
    local function getActionMove2()
        local _disY = 60
        local _during = 4/3
        local _actionMove = cc.MoveBy:create(_during, cc.p(0, _disY))
        if _tp == "crit" then
            local _actionStyle = cc.ScaleTo:create(1/10, 0.7)
            local _actionSpawn = cc.Spawn:create({_actionMove, _actionStyle})
            local _actionFadeOut = cc.FadeOut:create(_during)
            return cc.Spawn:create({_actionSpawn, _actionFadeOut})
        else
            local _actionFadeOut = cc.FadeOut:create(_during)
            return cc.Spawn:create({_actionMove, _actionFadeOut})
        end
    end

    local _ac1 = getActionMove1(_hiter)
    local _ac3 = getActionMove2()
    local _ac4 = cc.CallFunc:create(ActionCallBack)
    local _actionSeq = cc.Sequence:create({_ac1, _ac3, _ac4})
    node:runAction(_actionSeq)
end

-- 播放受击文件
function FlowLabelController:FlowDamageEffect(_hiter,_hitAnimation)

    local con = false
    if _hiter.mGroup == "friend" and _hiter.IsKeyRole then
        con = true
    end
    if not con and self.mRole.mGroup == "friend" and self.mRole.IsKeyRole then
        con = true
    end
    if not con then return end
    local root = FightSystem.mSceneManager:GetTiledLayer(self.mRole.mSceneIndex)
    local spine = FlowSpineEffect.new(_hitAnimation,root)

    local _disX = math.cos(math.rad(53.75)) * 93
    local _disY = math.sin(math.rad(53.75)) * 93
    local _during = 1/6
    if _hiter.IsFaceLeft then
       _disX = - _disX
    end
    spine.mSpine:setPosition(self.mRole:getPositionX()+_disX, self.mRole:getPositionY() + self.mRole.mSize.height * 0.5+_disY)

    spine.mSpine:setLocalZOrder(self.mRole:getLocalZOrder() + 1)
end

function FlowLabelController:GetFlowLable()
    local temp = 10000
    local obj = nil
    for i,v in pairs(self.FlowList) do
        if temp > v:getPositionY() then
            temp = v:getPositionY()
            obj = v
        end
    end
    return obj
end

function FlowLabelController:setFlowLableDis(_dis)
    for k,v in pairs(self.FlowList) do
        if v:getTag() == 1 then
            v:setPositionY(v:getPositionY()+_dis)
        end
    end
end

-- 飘加血
function FlowLabelController:FlowAddBlood(_num)
    if _num == 0 then return end
    -- if FightConfig.__DEBUG_DAMAGE_FONTNUM  then
        _num = math.ceil(_num)
        local node = self:CreateNumFnt(_num,"font_green")
        node:setPosition(self.mRole:getPositionX(), self.mRole:getPositionY() + self.mRole.mSize.height * 0.5)
        node:setScale(0)
        node:setLocalZOrder(self.mRole:getLocalZOrder() + 1)
        FightSystem.mSceneManager:GetTiledLayer(self.mRole.mSceneIndex):addChild(node)
        --
        local function ActionCallBack( sender )
            --cclog("销毁label")
            sender:removeFromParent()
        end
        --
        -- 计算偏移参数
        local function getActionMove1()
            local _disX = math.cos(math.rad(53.75)) * 93
            local _disY = math.sin(math.rad(53.75)) * 93
            local _during = 1/10
            local _actionMove = cc.MoveBy:create(_during, cc.p(_disX, _disY))
            local _actionStyle = cc.ScaleTo:create(_during, 0.5)
            local _tb = {_actionMove, _actionStyle}

            return cc.Spawn:create(_tb)
        end
        -- 计算飘逸参数
        local function getActionMove2()
            local _disY = 60
            local _during = 4/3
            local _actionMove = cc.MoveBy:create(_during, cc.p(0, _disY))
          
            local _actionFadeOut = cc.FadeOut:create(_during)
            return cc.Spawn:create({_actionMove, _actionFadeOut})
        end

        local _ac1 = getActionMove1()
        local _ac2 = getActionMove2()
        local _ac3 = cc.CallFunc:create(ActionCallBack)
        local _actionSeq = cc.Sequence:create({_ac1, _ac2, _ac3})
        node:runAction(_actionSeq)
    -- else
    --     local root = FightSystem.mSceneManager:GetTiledLayer(self.mRole.mSceneIndex)
    --     local spine = FlowSpineEffect.new(2301,root)

    --     local _disX = math.cos(math.rad(53.75)) * 93
    --     local _disY = math.sin(math.rad(53.75)) * 93
    --     local _during = 1/6
    --     if self.mRole.IsFaceLeft then
    --        _disX = - _disX
    --     end
    --     spine.mSpine:setPosition(self.mRole:getPositionX()+_disX, self.mRole:getPositionY() + self.mRole.mSize.height * 0.5+_disY)

    --     spine.mSpine:setLocalZOrder(self.mRole:getLocalZOrder() + 1)
    -- end










    --[[
    _num = math.ceil(_num)
    local  _lb = cc.LabelBMFont:create(string.format("%d", _num),  "res/fonts/font_fight_green.fnt")
    _lb:setAnchorPoint(cc.p(0.5,0.5))
    _lb:setPosition(self.mRole:getPositionX(), self.mRole:getPositionY() + self.mRole.mSize.height * 0.5)
    _lb:setScale(0)
    _lb:setLocalZOrder(self.mRole:getLocalZOrder() + 1)
    FightSystem.mSceneManager:GetTiledLayer(self.mRole.mSceneIndex):addChild(_lb)
    --
    local function ActionCallBack( sender )
        --cclog("销毁label")
        sender:removeFromParent()
    end
    --
    -- 计算偏移参数
    local function getActionMove1()
        local _disX = math.cos(math.rad(53.75)) * 93
        local _disY = math.sin(math.rad(53.75)) * 93
        local _during = 1/6
        local _actionMove = cc.MoveBy:create(_during, cc.p(_disX, _disY))
        local _actionStyle = cc.ScaleTo:create(_during, 0.5)
        local _tb = {_actionMove, _actionStyle}

        return cc.Spawn:create(_tb)
    end
    -- 计算飘逸参数
    local function getActionMove2()
        local _disY = 60
        local _during = 4/3
        local _actionMove = cc.MoveBy:create(_during, cc.p(0, _disY))
      
        local _actionFadeOut = cc.FadeOut:create(_during)
        return cc.Spawn:create({_actionMove, _actionFadeOut})
    end

    local _ac1 = getActionMove1()
    local _ac2 = getActionMove2()
    local _ac3 = cc.CallFunc:create(ActionCallBack)
    local _actionSeq = cc.Sequence:create({_ac1, _ac2, _ac3})
    _lb:runAction(_actionSeq)
    ]]
end

function FlowLabelController:FlowSkillState(_stateNameID, _hiter)
   -- cclog("显示技能状态====" .. _stateNameID)
    self.mShowSkillStateDuring = 45 + 1
    local _dbText = DB_Text.getDataById(_stateNameID)
    local function getShowPos(_hiter)
        local _disX = math.cos(math.rad(60)) * 90
        local _disY = math.sin(math.rad(60)) * 90
        if _hiter.IsFaceLeft then
           _disX = - _disX
        end
        local _y = self.mRole.mSize.height * 0.5 + _disY + self.mRole:getPositionY()

        --cclog("_disX  ====" .. _disX)
        return cc.p(self.mRole:getPositionX() + _disX, _y)
    end
    --
    self.mSkillStateLabel:setString(_dbText[GAME_LANGUAGE])
    self.mSkillStateLabel:setFontSize(_dbText.Text_CNSize)
    self.mSkillStateLabel:setPosition(getShowPos(_hiter))
    self.mSkillStateLabel:setVisible(true)

end

function FlowLabelController:flowDamageStatus(_stringID, _hiter)
    --[[
    if not _stringID then return end
    --cclog("显示伤害状态====" .. _stringID)
    self.mShowSkillStateDuring = 45 + 1
    local _dbText = DB_Text.getDataById(_stringID)
    local function getShowPos(_hiter)
        local _disX = math.cos(math.rad(60)) * 90
        local _disY = math.sin(math.rad(60)) * 90
        if _hiter.IsFaceLeft then
           _disX = - _disX
        end
        local _y = self.mRole.mSize.height * 0.5 + _disY + self.mRole:getPositionY()

        return cc.p(self.mRole:getPositionX() + _disX, _y)
    end
    --
    self.mSkillStateLabel:setString(_dbText[GAME_LANGUAGE])
    self.mSkillStateLabel:setFontSize(_dbText.Text_CNSize)
    self.mSkillStateLabel:setPosition(getShowPos(_hiter))
    self.mSkillStateLabel:setVisible(true)
    ]]
end