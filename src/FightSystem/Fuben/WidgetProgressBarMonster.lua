-- Func: WidgetProgressBarMonster
-- Author: lvyunlong

WidgetProgressBarMonster = class("WidgetProgressBarMonster", function()
   return cc.Node:create()
end)
WidgetProgressBarMonster.ProgressAniTag=100
WidgetProgressBarMonster.CursorTag=200
function WidgetProgressBarMonster:ctor(type)
    --创建 生命进步条背景
    self.typeleft = type
    local typepoint = cc.p(0,1)
    if self.typeleft == "right" then
        typepoint = cc.p(0,1)
    else
        typepoint = cc.p(1,0)
    end

    local widget = GUIWidgetPool:createWidget("Monsterblood")
    local bg = widget:getChildByName("Image_MonsterBg_0"):clone()

    self:addChild(bg)

    --boss名字
    self.mlbName = bg:getChildByName("Label_BossName")
    --boss头像
    self._icon = bg:getChildByName("Image_Boss")
    --血条背景
   local lifeBarbg = bg:getChildByName("Image_BloodBg")

    --血条格数
    self.mlb = bg:getChildByName("Label_bloodcount")    
    
    --血条精灵
    local xuetiao = cc.Sprite:create("fight_boss_blood7.png")
    self.width = xuetiao:getContentSize().width
    self.height = xuetiao:getContentSize().height

   

    local offsetx = (lifeBarbg:getContentSize().width - self.width)/2
    self.bossbar = {}
    for i=1,5 do
        local res = string.format("fight_boss_blood%d.png",i)
        local backBarbg=cc.Sprite:create(res)
        backBarbg:setAnchorPoint(cc.p(0,0.5))
        backBarbg:setPosition(offsetx,lifeBarbg:getContentSize().height/2)
        lifeBarbg:addChild(backBarbg)
        self.bossbar[i] = backBarbg
        backBarbg:setVisible(false)
    end

     --动画进度条 黑色条
    self.aniBar_ = cc.ProgressTimer:create(xuetiao)
    --self.aniBar_:setOpacity(125)
    self.aniBar_:setType(1)
    --self.aniBar_:setSlopbarParam(1, 0.1)
    -- Setup for a bar starting from the bottom since the midpoint is 0 for the y
    self.aniBar_:setMidpoint(typepoint)
    -- Setup for a vertical bar since the bar change rate is 0 for x meaning no horizontal change
    self.aniBar_:setAnchorPoint(cc.p(0,0.5))
    self.aniBar_:setBarChangeRate(cc.p(1, 0))
    self.aniBar_:setPosition(offsetx,lifeBarbg:getContentSize().height/2)
    lifeBarbg:addChild(self.aniBar_)

    self.bossbar1 = {}
    for i=1,5 do
        local res = string.format("fight_boss_blood%d.png",i)
        local backBarbg=cc.Sprite:create(res)
        backBarbg:setAnchorPoint(cc.p(0,0.5))
        backBarbg:setOpacity(125)
        backBarbg:setPosition(offsetx,lifeBarbg:getContentSize().height/2)
        lifeBarbg:addChild(backBarbg)
        self.bossbar1[i] = backBarbg
        backBarbg:setVisible(false)
    end

    --动画进度条2 半透条
    local xuetiao2 = cc.Sprite:create("fight_boss_blood6.png")
    self.aniBar_2 = cc.ProgressTimer:create(xuetiao2)
    --self.aniBar_:setOpacity(125)
    self.aniBar_2:setType(1)
    --self.aniBar_2:setSlopbarParam(1, 0.1)
    -- Setup for a bar starting from the bottom since the midpoint is 0 for the y
    self.aniBar_2:setMidpoint(typepoint)
    -- Setup for a vertical bar since the bar change rate is 0 for x meaning no horizontal change
    self.aniBar_2:setAnchorPoint(cc.p(0,0.5))
    self.aniBar_2:setBarChangeRate(cc.p(1, 0))
    self.aniBar_2:setPosition(offsetx,lifeBarbg:getContentSize().height/2)
    lifeBarbg:addChild(self.aniBar_2)
    self.aniBar_2:setVisible(true)


     --动画进度条3 闪白条
    local xuetiao1 = cc.Sprite:create("fight_boss_blood6.png")
    self.aniBar_1 = cc.ProgressTimer:create(xuetiao1)
    --self.aniBar_:setOpacity(125)
    self.aniBar_1:setType(1)
    --self.aniBar_1:setSlopbarParam(1, 0.1)
    -- Setup for a bar starting from the bottom since the midpoint is 0 for the y
    self.aniBar_1:setMidpoint(typepoint)
    -- Setup for a vertical bar since the bar change rate is 0 for x meaning no horizontal change
    self.aniBar_1:setAnchorPoint(cc.p(0,0.5))
    self.aniBar_1:setBarChangeRate(cc.p(1, 0))
    self.aniBar_1:setPosition(offsetx,lifeBarbg:getContentSize().height/2)
    lifeBarbg:addChild(self.aniBar_1)
    self.aniBar_1:setVisible(false)

    --实际进度条

    local xuetiao2 = cc.Sprite:create("fight_boss_blood1.png")
    self.actualBar_ = cc.ProgressTimer:create(xuetiao2)

    self.actualBar_:setType(1)
    --self.actualBar_:setSlopbarParam(1, 0.1)
    -- Setup for a bar starting from the bottom since the midpoint is 0 for the y
    self.actualBar_:setMidpoint(typepoint)
    -- Setup for a vertical bar since the bar change rate is 0 for x meaning no horizontal change
    self.actualBar_:setAnchorPoint(cc.p(0,0.5))
    self.actualBar_:setBarChangeRate(cc.p(1, 0))
    self.actualBar_:setPosition(offsetx,lifeBarbg:getContentSize().height/2)
    lifeBarbg:addChild(self.actualBar_)

    self.cursor=cc.Sprite:create("fight_bloodtiltle.png")
    self.cursor:setAnchorPoint(cc.p(0.5,0.5))
    self.cursor:setPosition(cc.p(0,self.height/2))
    self.aniBar_:addChild(self.cursor,100)
    self.cursor:setVisible(false)

    --存action的table
    self.mActionTable = {}

    --当前怪物的instanceID
    self.mInstanceID = 0

    --当前血量
    self.mIndexblood = 0
    self.mPer = -1
    self.mValue = -1
    self.mPercount = -1
    self.mValuecount = -1
    -- 隐藏
    self.mVisible = true
    -- 闪白是否完成
    self.misWhite = true
end

--初始化
function WidgetProgressBarMonster:setValue(value,percount)

    self.aniBar_:stopAllActions()
    self.aniBar_1:stopAllActions()
    self.aniBar_2:stopAllActions()
    self.cursor:stopAllActions()

   -- self.cursor:setVisible(true) 
    self:setBackBloodcolour(percount)
    self.mlb:setString(string.format("X%d",percount))
    self.actualBar_:setVisible(true)
    self.aniBar_:setVisible(true)
    self.aniBar_2:setVisible(true)
    self.aniBar_1:setVisible(false)
    self.actualBar_:setPercentage(value)
    self.aniBar_:setPercentage(value)
    self.aniBar_1:setPercentage(value)
    self.aniBar_2:setPercentage(value)
    self.mIndexblood = percount
    self.mVisible = true
    self.misWhite = true
end

function WidgetProgressBarMonster:SetcursorPos(per,value,percount,valuecount)
    local x = 0
    local y = 0
    --cclog("cursor == true")
    self.cursor:setVisible(true)
     if percount == valuecount then
        if self.typeleft == "right" then
             x = self.width*per/100
             y = self.width*value/100
        else
             x = self.width*(100-per)/100
             y = self.width*(100-value)/100
        end
        self.cursor:setPositionX(x)
        local to = cc.MoveTo:create(1, cc.p(y,self.height/2))
        self.cursor:runAction(to)
    else
        local pos_100 = 0
        local pos_0 = 0
        if self.typeleft == "right" then
             pos_100 = self.width
             pos_0 = 0
             x = self.width*per/100
             y = self.width*value/100
        else
             pos_100 = 0
             pos_0 = self.width
             x = self.width*(100-per)/100
             y = self.width*(100-value)/100
        end
        self.cursor:setPositionX(x)
        local time = percount - valuecount
        local action_list = {}
        local pertime = 1/(2+time-1)

        local to1 = cc.MoveTo:create(pertime, cc.p(pos_0,self.height/2))
        table.insert(action_list,to1)
        
        for i=2,time,1 do
            local place = cc.Place:create(cc.p(pos_100, self.height/2))
            local to = cc.MoveTo:create(pertime, cc.p(pos_0,self.height/2))
            local tabletime = cc.Sequence:create(place,to)
            table.insert(action_list,tabletime)
        end

        local place1 = cc.Place:create(cc.p(pos_100, self.height/2))
        local to1 = cc.MoveTo:create(pertime, cc.p(y,self.height/2))
        local table2 = cc.Sequence:create(place1,to1)
        table.insert(action_list,table2)
        local _seq = cc.Sequence:create(action_list)
        self.cursor:runAction(_seq)
        --cclog("cursor == true")
    end
end  

function WidgetProgressBarMonster:setValueClean(per,value,percount,valuecount)

    --self.actualBar_:setPercentage(value)
    if self.mPer ~= -1 then
        self.mValue = value
        self.mValuecount = valuecount
    else
        self.mPer = per
        self.mValue = value
        self.mPercount = percount
        self.mValuecount = valuecount
    end 

    -- self.mActionTable = {["per"] = per,["value"] = value,["percount"] = percount,["valuecount"] = valuecount }
    -- table.insert(self.mActionTable,action)
    self:BloodRunAction("push")
end

--显示血条背景
function WidgetProgressBarMonster:setBackBloodcolour(percount)
    if percount == 1 then
        for i=1,5 do
            self.bossbar[i]:setVisible(false)     
        end
        self.aniBar_2:setSprite(self.bossbar1[1])
        --self.aniBar_:setOpacity(125)
        self.actualBar_:setSprite(self.bossbar[1])
    else
        for i=1,5 do
            self.bossbar[i]:setVisible(false)     
        end
        local tag = percount%5 
        local tag2 = percount%5
        if tag2 == 0 then
            tag2 = 5
        end   
        if tag == 0 then
            tag = 4
        elseif tag == 1 then
            tag = 5
        else
            tag = tag -1 
        end
        self.aniBar_2:setSprite(self.bossbar1[tag2])
        --self.aniBar_2:setOpacity(125)
        self.actualBar_:setSprite(self.bossbar[tag2])
        self.bossbar[tag]:setVisible(true)
    end
end

function WidgetProgressBarMonster:BloodRunAction(type)

    --cclog("self.mPercount ====" .. self.mPercount)
    --cclog("self.mValuecount====" .. self.mValuecount)
    if self.mPer == -1 then 
        --cclog("OVER 1")
        return 
    end

    if not self.misWhite then return end

    local Tagnum = self.aniBar_:getActionManager():getNumberOfRunningActionsInTarget(self.aniBar_)
    local con = false
    if type == "done" then
        con = true
    elseif type == "push" then
        if Tagnum == 0 then
             con = true
        end   
    end
    
    if not con then 
        --cclog("OVER 2")
        return 
    end

    local function doNextBlood()
       
        self.mIndexblood = self.mIndexblood - 1
        self.mlb:setString(string.format("X%d",self.mIndexblood))
        self:setBackBloodcolour(self.mIndexblood)
    end    

    local function doFinishAction()
        self.cursor:setVisible(false)
        if not self.mVisible then
            self:setVisible(false)
            self.mVisible = true
        end 
        self:BloodRunAction("done")
    end

   -- cclog("sssss===" .. self.mPercount .. "mmmmm===" .. self.mValuecount)

    if self.mValuecount == 1  and self.mValue == 0 then
         self.mVisible = false
    end

    self.misWhite = false

    self.mTempPer = self.mPer
    self.mTempValue = self.mValue 
    self.mTempPercount = self.mPercount
    self.mTempValuecount = self.mValuecount

    if self.mPercount == self.mValuecount then
        -- 黑色条
        --闪白条
        local function doWhite()
            self.misWhite = true
            self.aniBar_1:setPercentage(self.mTempValue)
            local to2 = cc.ProgressTo:create(0.5, self.mTempValue)
            local act1 = cc.CallFunc:create(doFinishAction)
           -- local action = cc.Sequence:create(to2,act1)
            self.aniBar_:runAction(cc.Sequence:create(to2,act1))

            local to21 = cc.ProgressTo:create(0.5, self.mTempValue)
            self.aniBar_2:runAction(to21)
            --self.aniBar_2:setVisible(false)
        end
        self.aniBar_1:setVisible(true)
        local _ac1 = cc.FadeIn:create(0.5/5)
        local _ac3 = cc.FadeOut:create(0.5/5)
        local _ac4 = cc.CallFunc:create(doWhite)
        self.aniBar_1:runAction(cc.Sequence:create(_ac1,_ac3,_ac4))
        -- 半透条
        self.actualBar_:setPercentage(self.mValue)
    else
        local function doWhite()
              self.misWhite = true
              self.aniBar_1:setPercentage(self.mTempValue)

                local time = self.mTempPercount - self.mTempValuecount
                local pertime = 1/(2+time-1)


                local action_list = {}
                local action_list_1 = {}
                local action_list_2 = {}



                local to1 = cc.ProgressTo:create(pertime, 0)
                local act1 = cc.CallFunc:create(doNextBlood)
                local table1 = cc.Sequence:create(to1,act1)
                table.insert(action_list,table1)
                table.insert(action_list_1,to1:clone())
                 for i=2,time,1 do
                    local to = cc.ProgressFromTo:create(pertime,100,0)
                    local act = cc.CallFunc:create(doNextBlood)
                    local table3 = cc.Sequence:create(to,act)
                    table.insert(action_list,table3)
                    table.insert(action_list_1,to:clone())
                 end

                local to2 = cc.ProgressFromTo:create(pertime, 100,self.mTempValue)
                local act2 = cc.CallFunc:create(doFinishAction)
                local table2 = cc.Sequence:create(to2,act2)
                table.insert(action_list,table2)
                table.insert(action_list_1,to2:clone())
               

                local _seq = cc.Sequence:create(action_list)
                local _seq2 = cc.Sequence:create(action_list_1)
                
                self.aniBar_:runAction(_seq)
                self.aniBar_2:runAction(_seq2)

                local  function Showbar()
                    self.actualBar_:setVisible(true)
                    self.actualBar_:setPercentage(self.mTempValue)
                end
                local _ac2 = cc.DelayTime:create(pertime*time)
                local act_show = cc.CallFunc:create(Showbar)
                self.actualBar_:runAction(cc.Sequence:create(_ac2,act_show))
        end

        local _ac1_white = cc.FadeIn:create(0.1)
        local _ac2_white = cc.FadeOut:create(0.1)
        local _call_white = cc.CallFunc:create(doWhite)
        self.aniBar_1:setVisible(true)
        local _ac3_white = cc.Sequence:create(_ac1_white,_ac2_white,_call_white)
        self.aniBar_1:runAction(_ac3_white)
        self.actualBar_:setVisible(false)

    end

    --self:SetcursorPos(self.mPer,self.mValue,self.mPercount,self.mValuecount)

    self.mPer = -1
    self.mValue = -1
    self.mPercount = -1
    self.mValuecount = -1
end

function WidgetProgressBarMonster:seticon(icon)
    self._icon:loadTexture(icon)
end

function WidgetProgressBarMonster:setName(name)
    self.mlbName:setString(name)
end