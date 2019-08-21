-- Func: WidgetProgressBar
-- Author: lvyunlong

WidgetProgressBar = class("WidgetProgressBar", function()
   return cc.Node:create()
end)
WidgetProgressBar.ProgressAniTag=100
WidgetProgressBar.CursorTag=200
function WidgetProgressBar:ctor(aniBar,baseboard,type)
    --创建 生命进步条背景
    self.typeleft = type
    local typepoint = cc.p(0,1)
    if self.typeleft == "right" then
        typepoint = cc.p(0,1)
    else
        typepoint = cc.p(1,0)
    end

    local lifeBarbg=cc.Sprite:create()
    lifeBarbg:setProperty("Frame", baseboard)
    lifeBarbg:setAnchorPoint(cc.p(0,0))
    self:addChild(lifeBarbg)

    local xuetiao = cc.Sprite:create()
    xuetiao:setProperty("Frame", aniBar)
    self.width = xuetiao:getContentSize().width
    self.height = xuetiao:getContentSize().height

    local offsetx = (lifeBarbg:getContentSize().width - self.width)/2
    local bossbar = {}

    --动画进度条
    self.aniBar_ = cc.ProgressTimer:create(xuetiao)
    self.aniBar_:setOpacity(125)
    self.aniBar_:setType(1)
   -- self.aniBar_:setSlopbarParam(4, 0.1)
    -- Setup for a bar starting from the bottom since the midpoint is 0 for the y
    self.aniBar_:setMidpoint(typepoint)
    -- Setup for a vertical bar since the bar change rate is 0 for x meaning no horizontal change
    self.aniBar_:setAnchorPoint(cc.p(0,0.5))
    self.aniBar_:setBarChangeRate(cc.p(1, 0))
    self.aniBar_:setPosition(offsetx,lifeBarbg:getContentSize().height/2)
    lifeBarbg:addChild(self.aniBar_)
   
    --实际进度条
    self.actualBar_ = cc.ProgressTimer:create(xuetiao)

    self.actualBar_:setType(1)
    --self.actualBar_:setSlopbarParam(4, 0.1)
    -- Setup for a bar starting from the bottom since the midpoint is 0 for the y
    self.actualBar_:setMidpoint(typepoint)
    -- Setup for a vertical bar since the bar change rate is 0 for x meaning no horizontal change
    self.actualBar_:setAnchorPoint(cc.p(0,0.5))
    self.actualBar_:setBarChangeRate(cc.p(1, 0))
    self.actualBar_:setPosition(offsetx,lifeBarbg:getContentSize().height/2)
    lifeBarbg:addChild(self.actualBar_)

    self.cursor=cc.Sprite:create()
    self.cursor:setProperty("Frame", "fight_bloodtiltle.png")
    
    self.cursor:setAnchorPoint(cc.p(0.5,0.5))
    self.cursor:setPosition(cc.p(0,self.height/2))
    self.actualBar_:addChild(self.cursor,100)
    self.cursor:setVisible(false)

end

function WidgetProgressBar:setValue(per,value,bAni)
    self.actualBar_:setPercentage(value)
    self.actualBar_:setColor(getBloodColor(value))
    if bAni then
        self.aniBar_:stopActionByTag(WidgetProgressBar.ProgressAniTag)
        local to2 = cc.ProgressTo:create(0.5, value)
        to2:setTag(WidgetProgressBar.ProgressAniTag)
        self.aniBar_:runAction(to2)

        self:SetcursorPos(per,value)
    else
        self.aniBar_:setPercentage(value)
    end
end

function WidgetProgressBar:SetcursorPos(per,value)
    local x = 0
    local y = 0
    if self.typeleft == "right" then
         x = self.width*per/100
         y = self.width*value/100
    else
         x = self.width*(100-per)/100
         y = self.width*(100-value)/100
    end
    self.cursor:stopActionByTag(WidgetProgressBar.CursorTag)
    self.cursor:setVisible(true)
    self.cursor:setPositionX(x)
    local function doCleanup()
        self.cursor:setVisible(false)
    end
    local to = cc.MoveTo:create(0.5, cc.p(y,self.height/2))
    local act = cc.CallFunc:create(doCleanup)
    local action = cc.Sequence:create( to, act )
    action:setTag(WidgetProgressBar.CursorTag)
    self.cursor:runAction(action)

end  

function WidgetProgressBar:setValueClean(per,value,bAni)
    self.actualBar_:setPercentage(value)
    if bAni then
        self.aniBar_:stopActionByTag(WidgetProgressBar.ProgressAniTag)
        local to2 = cc.ProgressTo:create(0.5, value)
        to2:setTag(WidgetProgressBar.ProgressAniTag)
       
        if value <= 0 then
          local function doCleanup()
               self:setVisible(false)
          end
        local act1 = cc.CallFunc:create(doCleanup)
        self.aniBar_:runAction(cc.Sequence:create( to2, act1 ))
        else
            self.aniBar_:runAction(to2)
        end   
        self:SetcursorPos(per,value)
    else
        self.aniBar_:setPercentage(value)
    end  
end