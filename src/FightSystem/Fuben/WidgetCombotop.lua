-- Func: WidgetCombotop
-- Author: lvyunlong

WidgetCombotop = class("WidgetCombotop", function()
   return cc.Node:create()
end)
WidgetCombotop.Tag = 100
function WidgetCombotop:ctor()
    --创建 生命进步条背景
    local ComboBg  = GUIWidgetPool:createWidget("Combo"):getChildByName("Image_ComBg"):clone()
    self:addChild(ComboBg)
    self:setAnchorPoint(cc.p(0.5,0.5))
    self.count = 0
    self.countMax = 0
    self:setVisible(false)
    self.Label = ComboBg:getChildByName("BitmapLabel_Combo_Num")
    self.Label:setString(tostring(self.count))
end

function WidgetCombotop:setStringNum()
    self.count = self.count + 1
    if self.countMax < self.count then
        self.countMax = self.count
    end
    if self.count >= 2 then
        self:setVisible(true)
        --
        self.Label:setString(tostring(self.count))
        local function doCleanup()
            self:setVisible(false)
            self.count = 0
        end
        self:stopAllActions()
        self:setScale(1.5)
        local act0 = cc.ScaleTo:create(0.5, 1)
        local act1 = cc.DelayTime:create(5)
        local act2 = cc.CallFunc:create(doCleanup)
        local action = cc.Sequence:create(act0, act1, act2)
        self:runAction(action) 
    end
end

function WidgetCombotop:AddCombotopTime()
    if self:isVisible() then
        local scale = self:getScale()
        local function doCleanup()
            self:setVisible(false)
            self.count = 0
        end
        self:stopAllActions()
        self:setScale(scale)
        local act0 = cc.ScaleTo:create(0.5, 1)
        local act1 = cc.DelayTime:create(9)
        local act2 = cc.CallFunc:create(doCleanup)
        local action = cc.Sequence:create(act0, act1, act2)
        self:runAction(action) 
    end
end