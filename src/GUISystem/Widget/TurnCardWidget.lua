-- Name: 	TurnCardWidget.lua
-- Func：	翻卡控件
-- Author:	tuanzhang
-- Data:	15-3-18

TurnCardWidget = class("TurnCardWidget", function()
   return cc.Node:create()
end)

function TurnCardWidget:ctor(index, visible, heroShow,heroId,quality)

	local widget = GUIWidgetPool:createWidget("BattleResult_TurnCard")
	self.canTouch = false
	local Cardfront = widget:getChildByName("Image_Front"):clone()
	self:addChild(Cardfront)
	self.mCardfront = Cardfront

	self.notVisible = visible

	-- ccs.ArmatureDataManager:getInstance():addArmatureFileInfo("Ani_CardSaoguang.ExportJson")
	-- local armature = ccs.Armature:create("Ani_CardSaoguang")
	-- armature:getAnimation():play("Animation1")
	-- armature:setPosition(cc.p(0, 0))
	self.select = Cardfront:getChildByName("Image_Selectframe")
	--self.select:addChild(armature, 100)
	local Cardback = widget:getChildByName("Image_Back"):clone()
	self:addChild(Cardback)
	self.mCardback = Cardback
	self.isgetReward = nil
	self.mIndex = index
	registerWidgetReleaseUpEvent(self.mCardback,handler(self, self.onTouch))

	self.heroPanel = Cardfront:getChildByName("Panel_HeroLottery")
	self.heroImage = Cardfront:getChildByName("Image_Hero")

	if heroShow then
		self.heroPanel:setVisible(true)
		-- 英雄图
		local heroData = DB_HeroConfig.getDataById(heroId)
		local resData = DB_ResourceList.getDataById(heroData.QPicID)
		local heroImage  = resData.Res_path1
		self.heroImage:loadTexture(heroImage, 1)
		-- 显示星星
		if quality then
			for i = 1, 3 do
				if i <= quality then
					self.heroPanel:getChildByName("Image_Star_"..i):setVisible(true)
				else
					self.heroPanel:getChildByName("Image_Star_"..i):setVisible(false)
				end
			end
		end
	else
		self.heroPanel:setVisible(false)
	end  

end

function TurnCardWidget:setTurnCard(_flag)
	local front = nil
	local back = nil
	if _flag then
		if nil == self.notVisible then
			self.select:setVisible(true)
		end
	else
		self.select:setVisible(false)
	end
	if self.mCardback:isVisible() then
		cclog("CARD===1")
		self.mCardfront:setScaleX(-1)
		self.mCardback:setScaleX(1)
		front = self.mCardfront
		back = self.mCardback
	else
		self.mCardfront:setScaleX(1)
		self.mCardback:setScaleX(-1)
		front = self.mCardback
		back = self.mCardfront
		cclog("CARD===2")
	end

	local pBackSeq = cc.Sequence:create(cc.DelayTime:create(0.125),cc.Hide:create())
	local  pScaleBack = cc.ScaleTo:create(0.25,-(back:getScaleX()),1)
 	local  pSpawnBack = cc.Spawn:create(pBackSeq,pScaleBack)
 	back:runAction(pSpawnBack)


 	local function onActEnd()
 	-- 	if not PveWinGuide:isFinished() then
	 -- 		-- PveWin指引第一步
		-- 	local size = GUISystem:GetWindowByName("BattleResult_WinWindow").mRootWidget:getChildByName("Panel_Btn"):getChildByName("Button_Check"):getContentSize()
		--  	local pos = GUISystem:GetWindowByName("BattleResult_WinWindow").mRootWidget:getChildByName("Panel_Btn"):getChildByName("Button_Check"):getWorldPosition()
		--  	pos.x = pos.x - size.width/2
		-- 	pos.y = pos.y - size.height/2
		-- 	local touchRect = cc.rect(pos.x, pos.y, size.width, size.height)
		-- 	PveWinGuide:step(3, touchRect)
		-- end
		-- -- PveWin指引
	 -- 	if not PveWinGuide:isFinished() then
		-- 	PveWinGuide:resume()
		-- end
 	end
 	
 	local pFrontSeq=cc.Sequence:create(cc.DelayTime:create(0.125),cc.Show:create())
 	local pScaleFront = cc.ScaleTo:create(0.25,-(front:getScaleX()),1)
 	local pSpawnFront = cc.Spawn:create(pFrontSeq,pScaleFront)
 	local act0 = cc.CallFunc:create(onActEnd)
 	front:runAction(cc.Sequence:create(pSpawnFront, act0))

 -- 	-- PveWin指引
 -- 	if not PveWinGuide:isFinished() then
	-- 	PveWinGuide:pause()
	-- end
end

function TurnCardWidget:setItemIcon(itemtype,id,num,isget)
	self.isgetReward = isget
	local c1 = self.mCardfront:getChildByName("Image_Item")
	c1:setVisible(false)
	if itemtype == 0 or itemtype == 1 or itemtype == 10 then
		local widget = createCommonWidget(itemtype,id,num)
		widget:getChildByName("Label_Count_Stroke"):setVisible(false)
		local itemData = DB_ItemConfig.getDataById(id)
		self.mCardfront:getChildByName("Label_Item_Num"):setVisible(true)
		self.mCardfront:getChildByName("Label_Item_Num"):setString(string.format("%s X %d",getDictionaryText(itemData.Name),num))
		local a = self.mCardfront:getChildByName("Panel_Item")
		a:addChild(widget)
	elseif itemtype == 8 then
		local widget = createDiamondWidget(id,num)
		local a = self.mCardfront:getChildByName("Panel_Item")
		a:addChild(widget)
	else
		c1:setVisible(true)
		c1:loadTexture(getImgNameByTypeAndId(itemtype))
		self.mCardfront:getChildByName("Label_Item_Num"):setVisible(true)
		self.mCardfront:getChildByName("Label_Item_Num"):setString(num)
	end
end

function TurnCardWidget:setCardfront(flag,flag1)
	self.mCardfront:setVisible(flag)
	self.mCardback:setVisible(not flag)
	self.mCardfront:setScaleX(1)
	self.mCardback:setScaleX(1)
	
	if flag1 then
		self.select:setVisible(true)
	else
		self.select:setVisible(false)
	end
end

function TurnCardWidget:setCanTouch(_flag)
	self.canTouch = _flag
end

function TurnCardWidget:onTouch()
	if self.canTouch then
		self.canTouch = false
		if self.Callback then
			self.Callback(self.mIndex)
		else
			self:setTurnCard(false)
		end
	end
end

function TurnCardWidget:CallTouchback(func)
	self.Callback = func
end





