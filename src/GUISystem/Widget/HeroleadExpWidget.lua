-- Name: 	HeroleadExpWidget.lua
-- Func：	英雄主角加经验控件
-- Author:	tuanzhang
-- Data:	15-3-21

HeroleadExpWidget = class("HeroleadExpWidget", function()
   return cc.Node:create()
end)

function HeroleadExpWidget:ctor(widget,lv,initValue)
	self.widget = widget
	self.blood_bg = widget:getChildByName("Image_EXP_Bg")

	--动画进度条
	local xuetiao = cc.Sprite:create("battleresults_playerexp_bar.png")
    self.aniBar_ = cc.ProgressTimer:create(xuetiao)
    self.aniBar_:setType(2)
    self.aniBar_:setSlopbarParam(4, 0.025)
    -- Setup for a bar starting from the bottom since the midpoint is 0 for the y
    self.aniBar_:setMidpoint(cc.p(0,1))
    -- Setup for a vertical bar since the bar change rate is 0 for x meaning no horizontal change
    self.aniBar_:setAnchorPoint(cc.p(0,0))
    self.aniBar_:setBarChangeRate(cc.p(1, 0))
    self.aniBar_:setPosition(1,1)
    self.blood_bg:addChild(self.aniBar_) 

	self:heroIcon(lv)
	self:setPercen(initValue)
end

function HeroleadExpWidget:heroIcon(_lv)
	self.Level = _lv

	self.widget:getChildByName("Label_PlayerLevel_Stroke"):setString("Lv".._lv)
	self.widget:setVisible(true)
end

function HeroleadExpWidget:setPercen(value)
	self.aniBar_:setPercentage(value)
end

function HeroleadExpWidget:setRunProgress(preLevel,afterLevel,value,addExp)
	self:FlowLabel(addExp)
	local function doNextBlood()
		self.Level = self.Level + 1
		self.widget:getChildByName("Label_PlayerLevel_Stroke"):setString("Lv"..self.Level)
	end 

	if preLevel == afterLevel then
		local to1 = cc.ProgressTo:create(0.5, value)
		self.aniBar_:runAction(cc.Sequence:create( to1))
	else
		local action_list = {}
		local time = afterLevel - preLevel
		local to1 = cc.ProgressTo:create(0.5, 100)
		local act1 = cc.CallFunc:create(doNextBlood)
		local table_1 = cc.Sequence:create(to1,act1)
		table.insert(action_list,table_1)
		for i=2,time,1 do
			local to = cc.ProgressFromTo:create(0.5,0,100)
			local act = cc.CallFunc:create(doNextBlood)
			local table1 = cc.Sequence:create(to,act)
			table.insert(action_list,table1)
		end
		local to2 = cc.ProgressFromTo:create(0.5,0,value)
		local table2 = cc.Sequence:create(to2)
		table.insert(action_list,table2)
		self.aniBar_:runAction(cc.Sequence:create(action_list))
	end
end

function HeroleadExpWidget:FlowLabel(_num)
	_num = math.ceil(_num)
	local  _lb = cc.LabelBMFont:create(string.format("%d", _num),  "res/fonts/font_arena_ranking1.fnt")
	_lb:setAnchorPoint(cc.p(0.5,0.5))
	_lb:setPosition(cc.p(self.blood_bg:getBoundingBox().width/2,self.blood_bg:getBoundingBox().height/2))
    _lb:setLocalZOrder(100)
    self.blood_bg:addChild(_lb)
    local _during = 0.5
    local _actionMove = cc.MoveBy:create(_during, cc.p(0, 30))      
	local _actionFadeOut = cc.FadeOut:create(_during)
	_lb:runAction(cc.Sequence:create(_actionMove,_actionFadeOut))
end