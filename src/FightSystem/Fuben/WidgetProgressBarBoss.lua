-- Func: WidgetProgressBarBoss
-- Author: lvyunlong

WidgetProgressBarBoss = class("WidgetProgressBarBoss", function()
   return cc.Node:create()
end)
WidgetProgressBarBoss.ProgressAniTag=100
WidgetProgressBarBoss.CursorTag=200
function WidgetProgressBarBoss:ctor(icon,name,type)
    --创建 生命进步条背景
    self.typeleft = type
    local typepoint = cc.p(0,1)
    if self.typeleft == "right" then
        typepoint = cc.p(0,1)
    else
        typepoint = cc.p(1,0)
    end
    local hypotenuse = 0.1

    local widget = GUIWidgetPool:createWidget("Monsterblood")
    local bg = widget:getChildByName("Image_MonsterBg_0"):clone()
    self:addChild(bg)
    --boss名字
    self.mlbName = bg:getChildByName("Label_BossName")
    self.mlbName:setString(name)

    --boss头像
    self._icon = bg:getChildByName("Image_Boss")
    self._icon:loadTexture(icon, 1)

    --血条背景
   local lifeBarbg = bg:getChildByName("Image_BloodBg")
   self.mLifeBar_bg = lifeBarbg
   self.mShanBaiZor = 10
    --血条格数
    self.mlb = bg:getChildByName("Label_bloodcount")    
    
    --血条精灵
    local xuetiao = cc.Sprite:create()
    xuetiao:setProperty("Frame", "fight_boss_blood1.png")
    self.width = xuetiao:getContentSize().width
    self.height = xuetiao:getContentSize().height

    local offsetx = (lifeBarbg:getContentSize().width - self.width)/2

    --血框背景
    local offsetx = (lifeBarbg:getContentSize().width - self.width)/2
    self.bossbar = {}
    for i=1,5 do
        local res = string.format("fight_boss_blood%d.png",i)
        local backBarbg=cc.Sprite:create()
        backBarbg:setProperty("Frame", res)
        backBarbg:setAnchorPoint(cc.p(0,0.5))
        backBarbg:setPosition(offsetx,lifeBarbg:getContentSize().height/2)
        lifeBarbg:addChild(backBarbg)
        self.bossbar[i] = backBarbg
        backBarbg:setVisible(false)
    end
    local xiedu = 0.017
     --动画进度条 黑色条
     
    local xuetiaoHei = cc.Sprite:create()
    xuetiaoHei:setProperty("Frame", "fight_boss_blood7.png")
    self.aniBar_ = cc.ProgressTimer:create(xuetiaoHei)
    --self.aniBar_:setOpacity(125)
    self.aniBar_:setType(2)
    --self.aniBar_:setSlopbarParam(1, xiedu)
    -- Setup for a bar starting from the bottom since the midpoint is 0 for the y
    self.aniBar_:setMidpoint(typepoint)
    -- Setup for a vertical bar since the bar change rate is 0 for x meaning no horizontal change
    self.aniBar_:setAnchorPoint(cc.p(0,0.5))
    self.aniBar_:setBarChangeRate(cc.p(1, 0))
    self.aniBar_:setPosition(offsetx,lifeBarbg:getContentSize().height/2)
    lifeBarbg:addChild(self.aniBar_,5)

    self.bossbar1 = {}
    for i=1,5 do
        local res = string.format("fight_boss_blood%d.png",i)
        local backBarbg=cc.Sprite:create()
        backBarbg:setProperty("Frame", res)
        backBarbg:setAnchorPoint(cc.p(0,0.5))
        backBarbg:setOpacity(125)
        backBarbg:setPosition(offsetx,lifeBarbg:getContentSize().height/2)
        lifeBarbg:addChild(backBarbg,2)
        self.bossbar1[i] = backBarbg
        backBarbg:setVisible(false)
    end

    --动画进度条2 半透条
    local xuetiao2 = cc.Sprite:create()
    xuetiao2:setProperty("Frame", "fight_boss_blood6.png")
    self.mShanbai_W = xuetiao2:getContentSize().width
    self.mShanbai_H = xuetiao2:getContentSize().height
    self.aniBar_2 = cc.ProgressTimer:create(xuetiao2)
    --self.aniBar_:setOpacity(125)
    self.aniBar_2:setType(2)
    --self.aniBar_2:setSlopbarParam(1, xiedu)
    -- Setup for a bar starting from the bottom since the midpoint is 0 for the y
    self.aniBar_2:setMidpoint(typepoint)
    -- Setup for a vertical bar since the bar change rate is 0 for x meaning no horizontal change
    self.aniBar_2:setAnchorPoint(cc.p(0,0.5))
    self.aniBar_2:setBarChangeRate(cc.p(1, 0))
    self.aniBar_2:setPosition(offsetx,lifeBarbg:getContentSize().height/2)
    lifeBarbg:addChild(self.aniBar_2,6)
    self.aniBar_2:setVisible(true)


     --动画进度条3 闪白条
     --[[
    local xuetiao1 = cc.Sprite:create("fight_boss_blood6.png")
    self.mShanbai_W = xuetiao1:getContentSize().width
    self.mShanbai_H = 19--xuetiao1:getContentSize().height
    self.aniBar_1 = cc.ProgressTimer:create(xuetiao1)
    --self.aniBar_:setOpacity(125)
    self.aniBar_1:setType(2)
    --self.aniBar_1:setSlopbarParam(1, xiedu)
    -- Setup for a bar starting from the bottom since the midpoint is 0 for the y
    self.aniBar_1:setMidpoint(typepoint)
    -- Setup for a vertical bar since the bar change rate is 0 for x meaning no horizontal change
    self.aniBar_1:setAnchorPoint(cc.p(0,0.5))
    self.aniBar_1:setBarChangeRate(cc.p(1, 0))
    self.aniBar_1:setPosition(offsetx,lifeBarbg:getContentSize().height/2)
    lifeBarbg:addChild(self.aniBar_1,7)
    self.aniBar_1:setVisible(false)
    ]]

    --实际进度条
    self.bossbar2 = {}
    for i=1,5 do
        local res = string.format("fight_boss_blood%d.png",i)
        local backBarbg=cc.Sprite:create()
        backBarbg:setProperty("Frame", res)
        backBarbg:setAnchorPoint(cc.p(0,0.5))
        backBarbg:setPosition(offsetx,lifeBarbg:getContentSize().height/2)
        lifeBarbg:addChild(backBarbg,4)
        self.bossbar2[i] = backBarbg
        backBarbg:setVisible(false)
    end


    local xuetiao2 = cc.Sprite:create()
    xuetiao2:setProperty("Frame", "fight_boss_blood1.png")
    self.actualBar_ = cc.ProgressTimer:create(xuetiao2)

    self.actualBar_:setType(2)
    --self.actualBar_:setSlopbarParam(1, xiedu)
    -- Setup for a bar starting from the bottom since the midpoint is 0 for the y
    self.actualBar_:setMidpoint(typepoint)
    -- Setup for a vertical bar since the bar change rate is 0 for x meaning no horizontal change
    self.actualBar_:setAnchorPoint(cc.p(0,0.5))
    self.actualBar_:setBarChangeRate(cc.p(1, 0))
    self.actualBar_:setPosition(offsetx,lifeBarbg:getContentSize().height/2)
    lifeBarbg:addChild(self.actualBar_,4)

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

    self.mActionList = {}
    -- 5 6 7

    ----------------------------------------------

    -- local xuetiao21 = cc.Sprite:create("fight_boss_blood6.png")
    -- local xx = 9.5--xuetiao21:getContentSize().width/2
    -- cclog("AAAAAAAAAAA+=========" ..xuetiao21:getContentSize().height)
    -- cclog("BBBBBBBBBBB=========" ..xuetiao21:getContentSize().width)

    -- local guideLayer = cc.ClippingNode:create()
    -- local drawNode = cc.DrawNode:create()
    -- guideLayer:setStencil(drawNode)

    -- guideLayer:setInverted(true)
    -- guideLayer:setAnchorPoint(cc.p(0,0.5))
    -- guideLayer:setPosition(self.mShanbai_W/2,lifeBarbg:getContentSize().height/2)

    -- local aa = -(lifeBarbg:getContentSize().width/2)+80

    -- local vertices = 
    -- {    
    --  cc.p(aa-10, -xx), 
    --  cc.p(aa, xx), 
    --  cc.p(aa+60, xx), 
    --  cc.p(aa+60-10, -xx)
    -- }
    -- drawNode:drawPolygon(vertices, table.getn(vertices), cc.c4f(1,0,0,0.5), 4, cc.c4f(0,0,1,1))

    -- guideLayer:addChild(xuetiao21)
    -- self.mLifeBar_bg:addChild(guideLayer,20)
    -- local xuetiao21 = cc.Sprite:create("fight_boss_blood6.png")
    -- xuetiao21:setScaleX(0.1)
    -- self.mLifeBar_bg:addChild(xuetiao21,20)


end

--初始化
function WidgetProgressBarBoss:setValue(value,percount)

    self.aniBar_:stopAllActions()
    self.aniBar_2:stopAllActions()
    self.mLastcount = percount

    self:setBackBloodcolour(percount)
    self.mlb:setString(string.format("X%d",percount))
    self.actualBar_:setVisible(true)
    self.aniBar_:setVisible(true)
    self.aniBar_2:setVisible(true)
    self.actualBar_:setPercentage(value)
    self.aniBar_:setPercentage(value)
    self.aniBar_2:setPercentage(value)
    self.mIndexblood = percount
    self.mVisible = true
    self.misWhite = true
end

function WidgetProgressBarBoss:setValueClean(per,value,percount,valuecount)

    --self.actualBar_:setPercentage(value)
    self.mLastcount = valuecount
    -- if self.mPer ~= -1 then
    --     self.mValue = value
    --     self.mValuecount = valuecount
    -- else
    --     self.mPer = per
    --     self.mValue = value
    --     self.mPercount = percount
    --     self.mValuecount = valuecount
    -- end 

    if valuecount == 1  and value == 0 then
         self.mVisible = false
    end
    -- if self.Addblooding then
    --     --debugLog("NO---------------------Addblooding")
    --     return
    -- end
    -- if self.dofinish1 then 
    --     --debugLog("NO---------------------dofinish1")
    --     return
    -- end
    --debugLog("setValueClean=======per==" .. per .."=value=" .. value .."==percount=="..percount.."==valuecount=="..valuecount)
    if percount < valuecount or (percount == valuecount and per < value ) or (percount == valuecount and per == value ) then
        self:BloodRunAction(per,value,percount,valuecount)
    else
        self:FlashBlood(per,value,percount,valuecount)
    end
    -- self.mActionTable = {["per"] = per,["value"] = value,["percount"] = percount,["valuecount"] = valuecount }
    -- table.insert(self.mActionTable,action)
    -- self:BloodRunAction("push")
end

-- 计算掉血
function WidgetProgressBarBoss:ChangeBlood(per,value,percount,valuecount)
    local Tagnum = self.aniBar_:getActionManager():getNumberOfRunningActionsInTarget(self.aniBar_)
    if Tagnum ~= 0 then
        self.aniBar_:stopAllActions()
        self.aniBar_2:stopAllActions()
        per = self.aniBar_2:getPercentage()
        percount = self.mIndexblood
    end
    self.mChangeper = per
    self.mChangevalue = value
    self.mChangepercount = percount
    self.mChangevaluecount = valuecount
     local function doNextBlood()
        local num = 1
        if percount < valuecount then
            num = -1
        end
        self.mIndexblood = self.mIndexblood - num

        self.mlb:setString("X" ..(self.mIndexblood))
        self:setBackBloodcolour(self.mIndexblood)
    end    
    local bloodspeed = 0.3
    if self.mChangepercount == self.mChangevaluecount then
        if self.mChangeper < self.mChangevalue then
            --加血
            self.dofinish1 = false
            self.misWhite = true
            local to2 = cc.ProgressTo:create(0.1, self.mChangevalue)
            --local act1 = cc.CallFunc:create(doFinishAddblood)
            self.actualBar_:runAction(cc.Sequence:create(to2))
            self.aniBar_:setVisible(false)
            self.aniBar_2:setVisible(false)
            self.aniBar_:setPercentage(self.mChangevalue)
            self.aniBar_2:setPercentage(self.mChangevalue)
            self.Addblooding = true
        else
            local function doFinishAction()
                if not self.mVisible then
                    self.mVisible = true
                    self.mlb:setVisible(false)
                end 
            end
            self.aniBar_:setPercentage(self.mChangeper)
            self.aniBar_2:setPercentage(self.mChangeper)
            self.aniBar_:setVisible(true)
            local to2 = cc.ProgressTo:create(bloodspeed, self.mChangevalue)
            local act1 = cc.CallFunc:create(doFinishAction)
            self.aniBar_:runAction(cc.Sequence:create(to2,act1))
            self.aniBar_2:setVisible(true)
            local to21 = cc.ProgressTo:create(bloodspeed, self.mChangevalue)
            self.aniBar_2:runAction(to21)
        end  
    else
        local function doFinishAction1()
            if not self.mVisible then
                self.mVisible = true
                self.mlb:setVisible(false)
            end 
        end
        local num = 0
        local num1 = 100
        if self.mChangepercount < self.mChangevaluecount then
            num = 100
            num1 = 0
        end
        if self.mChangepercount < self.mChangevaluecount then
            --加血
        else
            self.misWhite = true
            local time = math.abs(self.mChangepercount - self.mChangevaluecount) 
            local fristLong = (self.mChangeper/100)*self.mShanbai_W
            local lastLong = ((100-self.mChangevalue)/100)*self.mShanbai_W
            local totalblood = (time - 1 )*self.mShanbai_W + fristLong + lastLong
            local speed1 = totalblood/bloodspeed
            if speed1 > 1666 then
                speed1 = 1666
            end

            local action_list = {}
            local action_list_1 = {}
            local action_list_2 = {}

            local to1 = cc.ProgressTo:create(fristLong/speed1, num)
            local act1 = cc.CallFunc:create(doNextBlood)
            local table1 = cc.Sequence:create(to1,act1)
            table.insert(action_list,table1)
            table.insert(action_list_1,to1:clone())
             for i=2,time,1 do
                local to = cc.ProgressFromTo:create(self.mShanbai_W/speed1,num1,num)
                local act = cc.CallFunc:create(doNextBlood)
                local table3 = cc.Sequence:create(to,act)
                table.insert(action_list,table3)
                table.insert(action_list_1,to:clone())
             end

            local to2 = cc.ProgressFromTo:create(lastLong/speed1, num1,self.mChangevalue)
            local act2 = cc.CallFunc:create(doFinishAction1)
            local table2 = cc.Sequence:create(to2,act2)
            table.insert(action_list,table2)
            table.insert(action_list_1,to2:clone())
           

            local _seq = cc.Sequence:create(action_list)
            local _seq2 = cc.Sequence:create(action_list_1)
            self.aniBar_:setPercentage(self.mChangeper)
            self.aniBar_2:setPercentage(self.mChangeper)
            self.aniBar_:setVisible(true)
            self.aniBar_2:setVisible(true)
            self.aniBar_:runAction(_seq)
            self.aniBar_2:runAction(_seq2)

            -- local  function Showbar()
            --     -- 实际血条
            --     self.actualBar_:setVisible(true)
            --     self.actualBar_:setPercentage(self.mChangevalue)
            --     self.aniBar_:setVisible(false)
            --     self.aniBar_2:setVisible(false)

            -- end
            -- local _ac2 = cc.DelayTime:create(pertime*(time+1))
            -- local act_show = cc.CallFunc:create(Showbar)
            -- self.actualBar_:runAction(cc.Sequence:create(_ac2,act_show)) 
        end
    end
end

-- 计算闪白块
function WidgetProgressBarBoss:CreateShanbai(per,value,percount,valuecount)
    self.actualBar_:setPercentage(value) 
    self:setBackBloodcolour1(valuecount)
    -- if self.mIndexblood ~= percount then
    --     self:ChangeBlood(per,value,percount,valuecount)
    --     return
    -- end
    local ss = 0.05
    if percount == valuecount then

        local x1 =self.mShanbai_W - self.mShanbai_W*(per/100)

        local imgWidget = ccui.ImageView:create()
        imgWidget:loadTexture("fight_boss_blood6.png",1)
        imgWidget:setScale9Enabled(true)
        local contentSize = imgWidget:getContentSize()

        imgWidget:setCapInsets(cc.rect(1, 0, contentSize.width -1, contentSize.height))
        local xx = contentSize.width*(per-value)/100
        imgWidget:setContentSize(cc.size(xx, 19)) 
        self.mShanBaiZor = self.mShanBaiZor + 1

        imgWidget:setAnchorPoint(cc.p(0,0.5))
        imgWidget:setPosition(x1,self.mLifeBar_bg:getContentSize().height/2)

        self.mLifeBar_bg:addChild(imgWidget,self.mShanBaiZor)

        local function doWhite(_imgWidget)
            if self.mActionList[_imgWidget] then
                self.mActionList[_imgWidget] = nil
                _imgWidget:removeFromParent(true)
            end
            self:ChangeBlood(per,value,percount,valuecount)
        end
        local _ac1 = cc.FadeIn:create(ss)
        local _ac3 = cc.FadeOut:create(ss)
        local _ac4 = cc.CallFunc:create(doWhite)
        imgWidget:runAction(cc.Sequence:create(_ac1,_ac3,_ac4)) 
        self.mActionList[imgWidget] = imgWidget        
    elseif percount - valuecount == 1 then
        -- 进度条 1
        local x1 =self.mShanbai_W - self.mShanbai_W*(per/100)
        local imgWidget = ccui.ImageView:create()
        imgWidget:loadTexture("fight_boss_blood6.png",1)
        imgWidget:setScale9Enabled(true)
        local contentSize = imgWidget:getContentSize()
        imgWidget:setCapInsets(cc.rect(1, 0, contentSize.width -1, contentSize.height))
        local xx = contentSize.width*(per)/100
        imgWidget:setContentSize(cc.size(xx, 19)) 
        self.mShanBaiZor = self.mShanBaiZor + 1
        imgWidget:setAnchorPoint(cc.p(0,0.5))
        imgWidget:setPosition(x1,self.mLifeBar_bg:getContentSize().height/2)

        self.mLifeBar_bg:addChild(imgWidget,self.mShanBaiZor)

        local function doWhite(_imgWidget)
            if self.mActionList[_imgWidget] then
                self.mActionList[_imgWidget] = nil
                _imgWidget:removeFromParent(true)
            end
            self:ChangeBlood(per,value,percount,valuecount)
        end
        local _ac1 = cc.FadeIn:create(ss)
        local _ac3 = cc.FadeOut:create(ss)
        local _ac4 = cc.CallFunc:create(doWhite)
        imgWidget:runAction(cc.Sequence:create(_ac1,_ac3,_ac4)) 
        self.mActionList[imgWidget] = imgWidget  
        --  闪白进度条 2
        local imgWidget1 = ccui.ImageView:create()
        imgWidget1:loadTexture("fight_boss_blood6.png",1)
        imgWidget1:setScale9Enabled(true)
        local contentSize = imgWidget1:getContentSize()
        imgWidget1:setCapInsets(cc.rect(1, 0, contentSize.width -1, contentSize.height))
        local xx = contentSize.width*(100-value)/100
        imgWidget1:setContentSize(cc.size(xx, 19)) 
        self.mShanBaiZor = self.mShanBaiZor + 1
        imgWidget1:setAnchorPoint(cc.p(0,0.5))
        imgWidget1:setPosition(0,self.mLifeBar_bg:getContentSize().height/2)
        self.mLifeBar_bg:addChild(imgWidget1,self.mShanBaiZor)
        local function doWhite(_imgWidget1)
            if self.mActionList[_imgWidget1] then
                self.mActionList[_imgWidget1] = nil
                _imgWidget1:removeFromParent(true)
            end
        end
        local _ac1 = cc.FadeIn:create(ss)
        local _ac3 = cc.FadeOut:create(ss)
        local _ac4 = cc.CallFunc:create(doWhite)
        imgWidget1:runAction(cc.Sequence:create(_ac1,_ac3,_ac4)) 
        self.mActionList[imgWidget1] = imgWidget1

    else
        -- 至少两管血
        local xuetiao21 = cc.Sprite:create()
        xuetiao21:setProperty("Frame", "fight_boss_blood6.png")
        self.mLifeBar_bg:addChild(xuetiao21,20)
        xuetiao21:setAnchorPoint(0.0,0.5)
        xuetiao21:setPosition(0,self.mLifeBar_bg:getContentSize().height/2)
        
        local function doWhite()
            self:ChangeBlood(per,value,percount,valuecount)
            xuetiao21:removeFromParent(true)
        end
        local _ac1 = cc.FadeIn:create(ss)
        local _ac3 = cc.FadeOut:create(ss)
        local _ac4 = cc.CallFunc:create(doWhite)
        xuetiao21:runAction(cc.Sequence:create(_ac1,_ac3,_ac4))
    end
end


-- 新显示血条
function WidgetProgressBarBoss:FlashBlood(per,value,percount,valuecount)
    self:CreateShanbai(per,value,percount,valuecount)
    --[[
    if percount == valuecount then
        local function doWhite()
            self.misWhite = true
            self.aniBar_1:setPercentage(value)
            self:BloodRunAction("push")
        end
        self.aniBar_1:stopAllActions()
        self.aniBar_1:setVisible(true)
        local _ac1 = cc.FadeIn:create(1)
        local _ac3 = cc.FadeOut:create(1)
        local _ac4 = cc.CallFunc:create(doWhite)
        self.aniBar_1:setPercentage(per)
        self.aniBar_1:runAction(cc.Sequence:create(_ac1,_ac3,_ac4))

        -- 实际进度条
        self.actualBar_:setVisible(true)
        self.actualBar_:setPercentage(value)
    else
        local function doWhite()
            self.misWhite = true
            self.aniBar_1:setPercentage(value)
            self:BloodRunAction("push")
        end
        self.dofinish1 = true
        --debugLog("self.dofinish1=============truetruetruetruetruetrue")
        local _ac1_white = cc.FadeIn:create(0.05)
        local _ac2_white = cc.FadeOut:create(0.05)
        local _call_white = cc.CallFunc:create(doWhite)
        self.aniBar_1:setVisible(true)
        local _ac3_white = cc.Sequence:create(_ac1_white,_ac2_white,_call_white)
        self.aniBar_1:runAction(_ac3_white)
        self.actualBar_:setVisible(false)
    end
    ]]
end

--显示主血条背景
function WidgetProgressBarBoss:setBackBloodcolour1(percount)
    
   -- debugLog("setBackBloodcolour1111111111111======" .. percount)

    if percount == self.mIndexblood -1 then
        --debugLog("AAAAAAA====percount==" .. percount .. "===mLastcount==" .. self.mLastcount)
        self.aniBar_2:setLocalZOrder(7)
        self.aniBar_:setLocalZOrder(6)
        self.actualBar_:setLocalZOrder(5)
        self.actualBar_:setVisible(true)
    elseif percount == self.mIndexblood then
        --debugLog("BBBBBBB====percount==" .. percount .. "===mLastcount==" .. self.mLastcount)
        self.aniBar_2:setLocalZOrder(6)
        self.aniBar_:setLocalZOrder(5)
        self.actualBar_:setLocalZOrder(7)
        self.actualBar_:setVisible(true)
    else
        --debugLog("CCCCCCC====percount==" .. percount .. "===mLastcount==" .. self.mLastcount)
        self.aniBar_2:setLocalZOrder(6)
        self.aniBar_:setLocalZOrder(5)
        self.actualBar_:setLocalZOrder(7)
        self.actualBar_:setVisible(false)
    end

    if percount == 1 then
        -- for i=1,5 do
        --     self.bossbar[i]:setVisible(false)     
        -- end
        -- self.actualBar_:setSprite(self.bossbar2[1])
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
        self.bossbar[tag]:setVisible(true)
        self.actualBar_:setSprite(self.bossbar2[tag2])
    end
end

--显示血条背景
function WidgetProgressBarBoss:setBackBloodcolour(percount)
   -- debugLog("setBackBloodcolourAAAAAAAAAAAAAAAAAAAAAAAA======" .. percount)
    if percount == self.mLastcount then
        --debugLog("AAAAAAA====percount==" .. percount .. "===mLastcount==" .. self.mLastcount)
        self.aniBar_2:setLocalZOrder(6)
        self.aniBar_:setLocalZOrder(5)
        self.actualBar_:setLocalZOrder(7)
        self.actualBar_:setVisible(true)
    elseif self.mLastcount == percount -1 then
        --debugLog("BBBBBBB====percount==" .. percount .. "===mLastcount==" .. self.mLastcount)
        self.aniBar_2:setLocalZOrder(7)
        self.aniBar_:setLocalZOrder(6)
        self.actualBar_:setLocalZOrder(5)
        self.actualBar_:setVisible(true)
    else
        --debugLog("CCCCCCC====percount==" .. percount .. "===mLastcount==" .. self.mLastcount)
        self.aniBar_2:setLocalZOrder(6)
        self.aniBar_:setLocalZOrder(5)
        self.actualBar_:setLocalZOrder(7)
        self.actualBar_:setVisible(false)
    end

    if percount == 1 then
        for i=1,5 do
            self.bossbar[i]:setVisible(false)     
        end
        self.aniBar_2:setSprite(self.bossbar1[1])
        --self.aniBar_:setOpacity(125)
        self.actualBar_:setSprite(self.bossbar2[1])
    else
        for i=1,5 do
            self.bossbar[i]:setVisible(false)
            self.bossbar1[i]:setVisible(false)
            self.bossbar2[i]:setVisible(false)  
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
        self.actualBar_:setSprite(self.bossbar2[tag2])
        self.bossbar[tag]:setVisible(true)
    end
end

function WidgetProgressBarBoss:BloodRunAction(per,value,percount,valuecount)
    for k,v in pairs(self.mActionList) do
        v:stopAllActions()
        v:removeFromParent(true)
    end
    self.mActionList = {}
    self.actualBar_:setPercentage(value) 
    self.mIndexblood = valuecount
    self.aniBar_:stopAllActions()
    self.aniBar_2:stopAllActions()
    self.aniBar_:setPercentage(value)
    self.aniBar_2:setPercentage(value)
    self.aniBar_:setVisible(true)
    self.aniBar_2:setVisible(true)
    self.mlb:setString("X" ..(self.mIndexblood))
    self:setBackBloodcolour1(self.mIndexblood)
    
    --[[
    if self.mPer == -1 then 
        return 
    end
    if self.Addblooding then
        return
    end


    local Tagnum = self.aniBar_:getActionManager():getNumberOfRunningActionsInTarget(self.aniBar_)
    local Tagnum1 = self.actualBar_:getActionManager():getNumberOfRunningActionsInTarget(self.actualBar_)
    local con = false
    if _type == "done" then
        con = true
    elseif _type == "push" then
        if Tagnum == 0 and Tagnum1 == 0 then
             con = true
        end   
    end
    if not con then 
        return 
    end

    self.misWhite = false
    self.mTempPer = self.mPer
    self.mTempValue = self.mValue 
    self.mTempPercount = self.mPercount
    self.mTempValuecount = self.mValuecount
    local Percount = self.mPercount
    local Valuecount = self.mValuecount
    local function doNextBlood()
        local num = 1
        if Percount < Valuecount then
            num = -1
        end
        self.mIndexblood = self.mIndexblood - num
        self.mlb:setString("X" ..(self.mIndexblood))
        self:setBackBloodcolour(self.mIndexblood)
    end    

    local function doFinishAddblood()
        if not self.mVisible then
            self:setVisible(false)
            self.mVisible = true
        end
        self.Addblooding = false
        self:BloodRunAction("push")
    end

    local function doFinishAction()
        if not self.mVisible then
            self:setVisible(false)
            self.mVisible = true
        end 
        self:BloodRunAction("push")
    end

    local function doFinishAction1()
        if not self.mVisible then
            self:setVisible(false)
            self.mVisible = true
        end
        self.dofinish1 = false
        self:BloodRunAction("push")
    end
    if self.mPercount == self.mValuecount then
        if self.mTempPer < self.mTempValue then
            --加血
            self.dofinish1 = false
            self.misWhite = true
            local to2 = cc.ProgressTo:create(0.1, self.mTempValue)
            local act1 = cc.CallFunc:create(doFinishAddblood)
            self.actualBar_:runAction(cc.Sequence:create(to2,act1))
            self.aniBar_:setVisible(false)
            self.aniBar_2:setVisible(false)
            self.aniBar_1:setVisible(false)
            self.aniBar_:setPercentage(self.mTempValue)
            self.aniBar_2:setPercentage(self.mTempValue)
            self.aniBar_1:setPercentage(self.mTempValue)
            self.Addblooding = true
        else
            self.aniBar_:setVisible(true)
            local to2 = cc.ProgressTo:create(2, self.mTempValue)
            local act1 = cc.CallFunc:create(doFinishAction)
            self.aniBar_:runAction(cc.Sequence:create(to2,act1))
            self.aniBar_2:setVisible(true)
            local to21 = cc.ProgressTo:create(2, self.mTempValue)
            self.aniBar_2:runAction(to21)
        end  
    else
        local num = 0
        local num1 = 100
        if self.mTempPercount < self.mTempValuecount then
            num = 100
            num1 = 0
        end
        if self.mTempPercount < self.mTempValuecount then
            --加血
            self.dofinish1 = false
            self.misWhite = true
            self.aniBar_:setVisible(false)
            self.aniBar_2:setVisible(false)
            self.aniBar_1:setVisible(false)
            self.aniBar_:setPercentage(self.mTempValue)
            self.aniBar_2:setPercentage(self.mTempValue)
            self.aniBar_1:setPercentage(self.mTempValue)
            local action_list = {}

            local time = math.abs(self.mTempPercount - self.mTempValuecount) 
            local pertime = 0.5/(2+time-1)
            local to1 = cc.ProgressTo:create(pertime, num)
            local act1 = cc.CallFunc:create(doNextBlood)
            local table1 = cc.Sequence:create(to1,act1)
            table.insert(action_list,table1)
             for i=2,time,1 do
                local to = cc.ProgressFromTo:create(pertime,num1,num)
                local act = cc.CallFunc:create(doNextBlood)
                local table3 = cc.Sequence:create(to,act)
                table.insert(action_list,table3)
             end

            local to2 = cc.ProgressFromTo:create(pertime, num1,self.mTempValue)
            local act2 = cc.CallFunc:create(doFinishAddblood)
            local table2 = cc.Sequence:create(to2,act2)
            table.insert(action_list,table2)           
            local _seq = cc.Sequence:create(action_list)
            self.actualBar_:runAction(_seq)
            self.Addblooding = true
        else
            self.misWhite = true
            self.aniBar_1:setPercentage(self.mTempValue)

            local time = math.abs(self.mTempPercount - self.mTempValuecount) 
            local pertime = 0.5/(2+time-1)

            local action_list = {}
            local action_list_1 = {}
            local action_list_2 = {}

            local to1 = cc.ProgressTo:create(pertime, num)
            local act1 = cc.CallFunc:create(doNextBlood)
            local table1 = cc.Sequence:create(to1,act1)
            table.insert(action_list,table1)
            table.insert(action_list_1,to1:clone())
             for i=2,time,1 do
                local to = cc.ProgressFromTo:create(pertime,num1,num)
                local act = cc.CallFunc:create(doNextBlood)
                local table3 = cc.Sequence:create(to,act)
                table.insert(action_list,table3)
                table.insert(action_list_1,to:clone())
             end

			local to2 = cc.ProgressFromTo:create(pertime, num1,self.mTempValue)
            local act2 = cc.CallFunc:create(doFinishAction1)
            local table2 = cc.Sequence:create(to2,act2)
            table.insert(action_list,table2)
            table.insert(action_list_1,to2:clone())
           

            local _seq = cc.Sequence:create(action_list)
            local _seq2 = cc.Sequence:create(action_list_1)
            
            self.aniBar_:setVisible(true)
            self.aniBar_2:setVisible(true)
           self.aniBar_:runAction(_seq)
           self.aniBar_2:runAction(_seq2)

            local  function Showbar()
                -- 实际血条
                self.actualBar_:setVisible(true)
                self.actualBar_:setPercentage(self.mTempValue)
                self.aniBar_:setVisible(false)
                self.aniBar_2:setVisible(false)

            end
            local _ac2 = cc.DelayTime:create(pertime*(time+1))
            local act_show = cc.CallFunc:create(Showbar)
            self.actualBar_:runAction(cc.Sequence:create(_ac2,act_show)) 
        end
    end

    self.mPer = -1
    self.mValue = -1
    self.mPercount = -1
    self.mValuecount = -1
    ]]
end

function WidgetProgressBarBoss:seticon(icon)
    self._icon:loadTexture(icon, 1)
end

function WidgetProgressBarBoss:setName(name)
    self.mlbName:setString(name)
end