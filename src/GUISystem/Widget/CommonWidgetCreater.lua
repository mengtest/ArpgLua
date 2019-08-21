-- Name: 	CommonWidgetCreater
-- Func：	创建公共控件
-- Author:	WangShengdong
-- Data:	14-11-26


local glod_point = nil
-- 获取黄金坐标(屏幕左下方)
function getGoldPosition()
	if not glod_point then
		local director = cc.Director:getInstance()
		local viewPortRect = director:getOpenGLView():getViewPortRect()

		cclog("viewPortRect.width == " .. viewPortRect.width)
		cclog("viewPortRect.height == " .. viewPortRect.height)

		cclog("viewPortRect.x == " .. viewPortRect.x)
		cclog("viewPortRect.y == " .. viewPortRect.y)

		local scaleY = director:getOpenGLView():getScaleY()
		local scaleX = director:getOpenGLView():getScaleX()

		cclog("scaleY == " .. scaleY)
		cclog("scaleX == " .. scaleX)

		local winSize = director:getOpenGLView():getFrameSize()
		local posY = (viewPortRect.y/scaleY) 
		local posX = (viewPortRect.x/scaleX)
		glod_point = cc.p(-posX, -posY)
	end
	return glod_point
end

local glod_fightpoint_leftdown = nil

-- 获取战斗黄金坐标(屏幕左下方)
function getGoldFightPosition_LD()
	if not glod_fightpoint_leftdown then
		local director = cc.Director:getInstance()
		local viewPortRect = director:getOpenGLView():getViewPortRect()
		local scaleY = director:getOpenGLView():getScaleY()
		local scaleX = director:getOpenGLView():getScaleX()
		local winSize = director:getOpenGLView():getFrameSize()
		local posY = (viewPortRect.y/scaleY) 
		local posX = (viewPortRect.x/scaleX)
		glod_fightpoint_leftdown = cc.p(-posX, -posY)
	end
	return glod_fightpoint_leftdown
end

local glod_fightpoint_leftup = nil

-- 获取战斗黄金坐标(屏幕左上方)
function getGoldFightPosition_LU()
	if not glod_fightpoint_leftup then
		local director = cc.Director:getInstance()
		local viewPortRect = director:getOpenGLView():getViewPortRect()
		local scaleY = director:getOpenGLView():getScaleY()
		local scaleX = director:getOpenGLView():getScaleX()
		local winSize = director:getOpenGLView():getFrameSize()
		local posY = (viewPortRect.y/scaleY) 
		local posX = (viewPortRect.x/scaleX)
		local temppos = cc.p(-posX, -posY)

		glod_fightpoint_leftup = cc.p(temppos.x,_RESOURCE_DESIGN_RESOLUTION_H_ -  math.abs(posY))
	end
	return glod_fightpoint_leftup
end


local glod_fightpoint_rightup = nil
-- 获取战斗黄金坐标(屏幕右上方)
function getGoldFightPosition_RU()
	if not glod_fightpoint_rightup then
		local director = cc.Director:getInstance()
		local viewPortRect = director:getOpenGLView():getViewPortRect()
		local scaleY = director:getOpenGLView():getScaleY()
		local scaleX = director:getOpenGLView():getScaleX()
		local posY = (viewPortRect.y/scaleY) 
		local posX = (viewPortRect.x/scaleX)
		glod_fightpoint_rightup = cc.p(_RESOURCE_DESIGN_RESOLUTION_W_ - math.abs(posX),_RESOURCE_DESIGN_RESOLUTION_H_ -  math.abs(posY))
	end
	return glod_fightpoint_rightup
end

local glod_fightpoint_rightdown = nil
-- 获取战斗黄金坐标(屏幕右下方)
function getGoldFightPosition_RD()
	if not glod_fightpoint_rightdown then
		local director = cc.Director:getInstance()
		local viewPortRect = director:getOpenGLView():getViewPortRect()
		local scaleY = director:getOpenGLView():getScaleY()
		local scaleX = director:getOpenGLView():getScaleX()
		local posY = (viewPortRect.y/scaleY) 
		local posX = (viewPortRect.x/scaleX)
		glod_fightpoint_rightdown = cc.p(_RESOURCE_DESIGN_RESOLUTION_W_ - math.abs(posX), math.abs(posY))
	end
	return glod_fightpoint_rightdown
end

-- 获取战斗中间坐标(屏幕正中间)
function getGoldFightPosition_Middle()
	local x =  getGoldFightPosition_LD().x + (getGoldFightPosition_RD().x - getGoldFightPosition_LD().x)/2
	local y =  getGoldFightPosition_LD().y + (getGoldFightPosition_RU().y - getGoldFightPosition_LD().y)/2
	return cc.p(x,y)
end

-- 获取战斗(屏幕宽)
function getGoldFightScreenWidth()
	return getGoldFightPosition_RD().x - getGoldFightPosition_LD().x
end

local glod_coefficient_width = nil
--获取当期缩放比例
function getcoefficientwidth()
	if not glod_coefficient_width then
  		local screenSize = GG_GetSceenSize()
  		local winSize = GG_GetWinSize()
  		glod_coefficient_width = winSize.width/screenSize.width
	end
	return glod_coefficient_width
end

local isshake = false
function shakeNode(node,pos,time,shakecounts)
	shakeFallRestore()
	if isshake then return end
	local shakedis = 0
	local _time = 0
	if pos then
		shakedis = pos
	else
		shakedis = 5
	end
	if time then
		_time = time/5
	else
		_time = 0.01
	end
	local function shakefinish()
		isshake = false
	end
	local posX = node:getPositionX()
	local posY = node:getPositionY()
	local action_list = {}
	if not shakecounts then
		shakecounts = 1
	end

	for i=1,shakecounts do
		local shakedis = shakedis*math.sqrt(1/i)
		local leftTop 		= cc.MoveTo:create(_time, cc.p(posX-shakedis, posY+shakedis))
		local bottomLeft	= cc.MoveTo:create(_time, cc.p(posX+shakedis, posY+shakedis))
		local bottomRight	= cc.MoveTo:create(_time, cc.p(posX-shakedis, posY-shakedis))
		local topRight		= cc.MoveTo:create(_time, cc.p(posX+shakedis, posY-shakedis))
		local srcPos		= cc.MoveTo:create(_time, cc.p(posX, posY))
		table.insert(action_list,leftTop)
		table.insert(action_list,bottomLeft)
		table.insert(action_list,bottomRight)
		table.insert(action_list,topRight)
		table.insert(action_list,srcPos)
	end
	local call = cc.CallFunc:create(shakefinish)
	table.insert(action_list,call)
	local act0 = cc.Sequence:create(action_list)
	node:runAction(act0)
	isshake = true
end

function shakeNodeType1(node,pos,time,shakecounts)
	shakeFallRestore()
	if isshake then return end
	local shakedis = 0
	local _time = 0
	if pos then
		shakedis = pos
	else
		shakedis = 5
	end
	if time then
		_time = time/5
	else
		_time = 0.01
	end
	local function shakefinish()
		isshake = false
	end
	local posX = node:getPositionX()
	local posY = node:getPositionY()
	local action_list = {}
	if not shakecounts then
		shakecounts = 1
	end
	for i=1,shakecounts do
		local shakedis = shakedis*math.sqrt(1/i)
		local leftTop 		= cc.MoveTo:create(_time, cc.p(posX, posY+shakedis))
		local bottomLeft	= cc.MoveTo:create(_time, cc.p(posX, posY-2*shakedis))
		local bottomRight	= cc.MoveTo:create(_time, cc.p(posX, posY+1.5*shakedis))
		local topRight		= cc.MoveTo:create(_time, cc.p(posX, posY-shakedis))
		local srcPos		= cc.MoveTo:create(_time, cc.p(posX, posY))
		table.insert(action_list,leftTop)
		table.insert(action_list,bottomLeft)
		table.insert(action_list,bottomRight)
		table.insert(action_list,topRight)
		table.insert(action_list,srcPos)
	end
	local call = cc.CallFunc:create(shakefinish)
	table.insert(action_list,call)
	local act0 = cc.Sequence:create(action_list)
	node:runAction(act0)
	isshake = true
end

function shakeNodeType2(node,pos,time,shakecounts)
	shakeFallRestore()
	if isshake then return end
	local shakedis = 0
	local _time = 0
	if pos then
		shakedis = pos
	else
		shakedis = 5
	end
	if time then
		_time = time/5
	else
		_time = 0.01
	end
	local function shakefinish()
		isshake = false
	end
	local posX = node:getPositionX()
	local posY = node:getPositionY()
	local action_list = {}
	if not shakecounts then
		shakecounts = 1
	end
	for i=1,shakecounts do
		local shakedis = shakedis*math.sqrt(1/i)
		local leftTop 		= cc.MoveTo:create(_time, cc.p(posX+shakedis, posY))
		local bottomLeft	= cc.MoveTo:create(_time, cc.p(posX-2*shakedis, posY))
		local bottomRight	= cc.MoveTo:create(_time, cc.p(posX+1.5*shakedis, posY))
		local topRight		= cc.MoveTo:create(_time, cc.p(posX-shakedis, posY))
		local srcPos		= cc.MoveTo:create(_time, cc.p(posX, posY))
		table.insert(action_list,leftTop)
		table.insert(action_list,bottomLeft)
		table.insert(action_list,bottomRight)
		table.insert(action_list,topRight)
		table.insert(action_list,srcPos)
	end
	local call = cc.CallFunc:create(shakefinish)
	table.insert(action_list,call)
	local act0 = cc.Sequence:create(action_list)
	node:runAction(act0)
	isshake = true
end

local isshake2 = false
local node_fall = nil
local posX_fall = nil
local posY_fall = nil
local shakeTag = 1000

function InitFallData()
	isshake2 = false
	node_fall = nil
	posX_fall = nil
	posY_fall = nil
	shakeTag = 1000
end

function shakeFallNodeType1(node,pos,time)
	if isshake then return end
	if isshake2 then return end
	local shakedis = 0
	local _time = 0
	if pos then
		shakedis = pos
	else
		shakedis = 5
	end
	if time then
		_time = time/5
	else
		_time = 0.01
	end
	local function shakefinish()
		isshake2 = false
		node_fall = nil
	end
	node_fall = node
	posX_fall = node:getPositionX()
	posY_fall = node:getPositionY()
	local posX = node:getPositionX()
	local posY = node:getPositionY()
	local leftTop 		= cc.MoveTo:create(_time, cc.p(posX, posY+shakedis))
	local bottomLeft	= cc.MoveTo:create(_time, cc.p(posX, posY-2*shakedis))
	local bottomRight	= cc.MoveTo:create(_time, cc.p(posX, posY+1.5*shakedis))
	local topRight		= cc.MoveTo:create(_time, cc.p(posX, posY-shakedis))
	local srcPos		= cc.MoveTo:create(_time, cc.p(posX, posY))
	local call = cc.CallFunc:create(shakefinish)
	
	local act0 = cc.Sequence:create(leftTop, bottomLeft, bottomRight, topRight, srcPos ,call)
	act0:setTag(shakeTag)
	node:runAction(act0)
	isshake2 = true
end

function shakeFallRestore()
	if isshake2 then
		isshake2 = false
		if node_fall then
			node_fall:stopActionByTag(shakeTag)
			node_fall:setPosition(posX_fall,posY_fall)
			node_fall = nil
		end
	end
end

function quickCreate9ImageView(_src, _w, _h)
	local imgWidget = ccui.ImageView:create()
	imgWidget:loadTexture(_src, 1)
	imgWidget:setScale9Enabled(true)
	local contentSize = imgWidget:getContentSize()
	imgWidget:setCapInsets(cc.rect(5, 5, contentSize.width - 10, contentSize.height - 10))
	imgWidget:setContentSize(cc.size(_w, _h)) 

	return imgWidget
end


local actionWidgetMap = {}
function widgetDoGradualAction(widget, preVal, curVal)
--[[
	print("curVal", curVal)
	if not preVal then
		widget:setString(tostring(curVal))
		return
	end
	if preVal == curVal then
		widget:setString(tostring(curVal))
		return
	end
	local scheduler = cc.Director:getInstance():getScheduler()
	if actionWidgetMap[widget] then
		scheduler:unscheduleScriptEntry(actionWidgetMap[widget])
		actionWidgetMap[widget] = nil
	end

	local baseVal = preVal
	local deltaVal = (curVal-preVal)/30
	deltaVal = math.floor(deltaVal)
	print(curVal)
	local function doAction()
		baseVal = baseVal + deltaVal
		if preVal < curVal then -- 做增
			if baseVal > curVal then
				widget:setString(tostring(curVal))
				scheduler:unscheduleScriptEntry(actionWidgetMap[widget])
				actionWidgetMap[widget] = nil
				globaldata:finishGradualEffect()
				return
			end
		else -- 做减
			if baseVal < curVal then
				widget:setString(tostring(curVal))
				scheduler:unscheduleScriptEntry(actionWidgetMap[widget])
				actionWidgetMap[widget] = nil
				globaldata:finishGradualEffect()
				return
			end
		end
		widget:setString(tostring(baseVal))
	end
	actionWidgetMap[widget] = scheduler:scheduleScriptFunc(doAction, 0, false)
]]
	widget:setString(tostring(curVal))	
end



-- 创建商品
function createGoodsWidget(shopType, goodsType, goodsId, currencyType, goodsPrice, goodsIndex, goodsMaxNum, leftCount, srcWidget)
	local resultWidget = nil
	if srcWidget then
		resultWidget = srcWidget
	else
		resultWidget = GUIWidgetPool:createWidget("ShopItem")
	end

	local itemData = nil

--	print("物品类型:", goodsType, "物品ID:", goodsId)

	if 0 == goodsType then -- 物品
		itemData = DB_ItemConfig.getDataById(goodsId)
	elseif 8 == goodsType then -- 宝石
		itemData = DB_Diamond.getDataById(goodsId)
	elseif 1 == goodsType then -- 装备
		itemData = DB_EquipmentConfig.getDataById(goodsId)
	end

	-- 显示名字
	
	local itemIconId = itemData.IconID
	local itemNameId = itemData.Name
	local textData = DB_Text.getDataById(itemNameId)
	local itemName = textData[GAME_LANGUAGE]
	local goodsName = itemName.."  X"..tostring(leftCount)
	resultWidget:getChildByName("Label_Name_Num"):setString(goodsName)

	if leftCount <= 0 then
		resultWidget:getChildByName("Image_Nothing"):setVisible(true)
		resultWidget:getChildByName("Panel_ShopItem"):setOpacity(150)
	else
		resultWidget:getChildByName("Image_Nothing"):setVisible(false)
		resultWidget:getChildByName("Panel_ShopItem"):setOpacity(255)
	end

	-- 显示物品
	local itemWidget = resultWidget:getChildByName("Panel_Item"):getChildren()[1]

	if itemWidget then
		createCommonWidget(goodsType, goodsId, nil, itemWidget, true)
	else
		itemWidget = createCommonWidget(goodsType, goodsId, nil, nil, true)
		resultWidget:getChildByName("Panel_Item"):addChild(itemWidget)
	end
	itemWidget:getChildByName("Label_Count_Stroke"):setVisible(false)
	itemWidget:setTouchEnabled(false)

	-- 更换货币图片
	if 0 == currencyType then -- 金币
		resultWidget:getChildByName("Image_Price"):loadTexture("public_gold.png")
	elseif 1 == currencyType then -- 钻石
		resultWidget:getChildByName("Image_Price"):loadTexture("public_diamond.png")
	elseif 2 == currencyType then -- 声望
		resultWidget:getChildByName("Image_Price"):loadTexture("public_currency_arena.png")
	elseif 3 == currencyType then -- 神秘
		resultWidget:getChildByName("Image_Price"):loadTexture("public_coin.png")
	elseif 5 == currencyType then -- 神秘
		resultWidget:getChildByName("Image_Price"):loadTexture("public_currency_guild.png")
	elseif 6 == currencyType then -- 制霸币
		resultWidget:getChildByName("Image_Price"):loadTexture("public_currency_tianti.png")
	elseif 7 == currencyType then -- 制霸币
		resultWidget:getChildByName("Image_Price"):loadTexture("public_currency_tower.png")
	end

	-- 显示货币价格
	resultWidget:getChildByName("Label_Price"):setString(goodsPrice)
	-- 显示剩余最大数量

	local function doBuy()
		Event.GUISYSTEM_SHOW_PURCHASEWINDOW.mData = {goodsType, goodsIndex, goodsId, currencyType, goodsPrice, itemName, shopType, leftCount, resultWidget}
		EventSystem:PushEvent(Event.GUISYSTEM_SHOW_PURCHASEWINDOW)
	end
	registerWidgetReleaseUpEvent(resultWidget:getChildByName("Button_Bg"), doBuy)

	if leftCount <= 0 then
		resultWidget:getChildByName("Button_Bg"):setTouchEnabled(false)
	else
		resultWidget:getChildByName("Button_Bg"):setTouchEnabled(true)
	end

	resultWidget:setTag(goodsId)

	return resultWidget
end

-- 创建怪物头像
function createMonsterIcon(id)
	local iconWidget = GUIWidgetPool:createWidget("HeroIcon")
	local monsterData = DB_MonsterConfig.getDataById(id)
	local imgId = monsterData.Monster_Icon
	local imgName = DB_ResourceList.getDataById(imgId).Res_path1
	iconWidget:getChildByName("Image_HeroHead"):loadTexture(imgName, 1)

	if 1 == monsterData.Monster_Grade then
		iconWidget:getChildByName("Image_Quality"):loadTexture("icon_hero_quality1.png", 1)
	elseif 2 == monsterData.Monster_Grade then
		iconWidget:getChildByName("Image_Quality"):loadTexture("icon_hero_quality3.png", 1)
	elseif 3 == monsterData.Monster_Grade then
		iconWidget:getChildByName("Image_Quality"):loadTexture("icon_hero_quality5.png", 1)
	elseif 4 == monsterData.Monster_Grade then
		iconWidget:getChildByName("Image_Quality"):loadTexture("icon_hero_quality7.png", 1)
	else
		iconWidget:getChildByName("Image_Quality"):setVisible(false)
	end

	iconWidget:getChildByName("Image_SuperHero"):setVisible(false)

	-- 职业
	iconWidget:getChildByName("Image_Group"):loadTexture("icon_hero_group"..monsterData.Monster_Group..".png",1)

	iconWidget:getChildByName("Panel_Star"):setVisible(false)

	iconWidget:getChildByName("Label_Level_Stroke"):setVisible(false)

	--iconWidget:getChildByName("Panel_LevelBg"):setVisible(false)

	return iconWidget
end

-- 创建人物头像
function createHeroIcon(id, level, starLevel, colorLevel, srcWidget)
	local iconWidget = nil
	if srcWidget then
		iconWidget = srcWidget
	else
		iconWidget = GUIWidgetPool:createWidget("HeroIcon")
	end

	local heroData = DB_HeroConfig.getDataById(id)
	local imgId = heroData.IconID
	local imgName = DB_ResourceList.getDataById(imgId).Res_path1

	-- 职业
	iconWidget:getChildByName("Image_Group"):loadTexture("icon_hero_group"..heroData.HeroGroup..".png",1)

	-- 级别
	if level ~= 0 then
		iconWidget:getChildByName("Label_Level_Stroke"):setVisible(true)
		--iconWidget:getChildByName("Image_LeveBg"):setVisible(true)  
		iconWidget:getChildByName("Label_Level_Stroke"):setString(tostring(level))
	else
		iconWidget:getChildByName("Label_Level_Stroke"):setVisible(false)
		--iconWidget:getChildByName("Image_LeveBg"):setVisible(false)  
		iconWidget:getChildByName("Label_Level_Stroke"):setString("缘")
	end
	iconWidget:getChildByName("Image_HeroHead"):loadTexture(imgName, 1)

	if 1 == heroData.QualityB then
	--	local animNode = AnimManager:createAnimNode(8066)
	--	iconWidget:getChildByName("Panel_SuperHero_Animation"):setVisible(true)
	--	iconWidget:getChildByName("Panel_SuperHero_Animation"):addChild(animNode:getRootNode(), 100)
	--	animNode:play("heroicon_superhero", true)
		iconWidget:getChildByName("Image_SuperHero"):loadTexture("icon_hero_super_1.png",1)
	else
		iconWidget:getChildByName("Image_SuperHero"):loadTexture("icon_hero_super_0.png",1)
	end

	-- 星级
	-- if starLevel then
	-- 	for i = 1, 6 do
	-- 		if i <= starLevel then
	-- 			iconWidget:getChildByName("Image_Star_"..i):setVisible(true)
	-- 		else
	-- 			iconWidget:getChildByName("Image_Star_"..i):setVisible(false)
	-- 		end
	-- 	end
	-- end

	for i = 1, 6 do
		iconWidget:getChildByName("Image_Star_"..i):setVisible(false)
	end

	if starLevel then
		if 0 == starLevel then

		elseif starLevel >= 1 and starLevel <= 6 then
			for i = 1, starLevel do
				local starWidget = iconWidget:getChildByName("Image_Star_"..tostring(i))
				starWidget:loadTexture("icon_hero_star1.png",1)
				starWidget:setVisible(true)
			end
		elseif starLevel >= 7 and starLevel <= 12 then
			for i = 1, 6 do
				local starWidget = iconWidget:getChildByName("Image_Star_"..tostring(i))
				starWidget:setVisible(true)
				starWidget:loadTexture("icon_hero_star1.png",1)
			end

			for i = 1, starLevel - 6 do
				local starWidget = iconWidget:getChildByName("Image_Star_"..tostring(i))
				starWidget:setVisible(true)
				starWidget:loadTexture("icon_hero_star2.png",1)
			end
		end
	end

	if colorLevel then
		-- 换品质图片
		iconWidget:getChildByName("Image_Quality"):loadTexture("icon_hero_quality"..colorLevel..".png", 1)
	end

	-- 设置英雄id
	iconWidget:setTag(id)

	return iconWidget
end

-- 创建打工人物头像
function createWorkHeroIcon(id, level, starLevel, colorLevel)
	local iconWidget = GUIWidgetPool:createWidget("HeroIcon")
	local heroData = DB_HeroConfig.getDataById(id)
	local imgId = heroData.IconID
	local imgName = DB_ResourceList.getDataById(imgId).Res_path1

	iconWidget:getChildByName("Image_LeveBg"):setVisible(false)
	iconWidget:getChildByName("Panel_Star"):setVisible(false)
	if colorLevel then
		-- 换品质图片
		iconWidget:getChildByName("Image_Quality"):loadTexture("icon_hero_quality"..colorLevel..".png", 1)
	else
		iconWidget:getChildByName("Image_Quality"):loadTexture("icon_hero_quality0.png", 1)
	end

	iconWidget:getChildByName("Image_HeroHead"):loadTexture(imgName, 1)


	return iconWidget
end

-- 创建背包中物品
function createItemWidget(id, count, srcWidget)
	local resultWidget = nil
	if srcWidget then
		resultWidget = srcWidget
	else
		resultWidget = GUIWidgetPool:createWidget("ItemWidget")
	end
	
	if not id then
		resultWidget:getChildByName("Image_Quality"):loadTexture("icon_item_quality1.png", 1)
		resultWidget:getChildByName("Image_Quality"):setVisible(true)
		return resultWidget
	end

	local itemData = DB_ItemConfig.getDataById(id)
	local itemIconId = itemData.IconID
	local itemQuality = itemData.Quality

	local itemData = DB_ItemConfig.getDataById(id)

	resultWidget:getChildByName("Image_HeroIcon"):setVisible(false)

	-- 碎片标志
	resultWidget:getChildByName("Image_HeroPiece"):setVisible(false)

	if 1 == itemData.Type then -- 英雄碎片
		resultWidget:getChildByName("Image_Item"):setVisible(false)
		-- 碎片标志
		resultWidget:getChildByName("Image_HeroPiece"):setVisible(true)
		-- 换物品图片
		local itemIconId = itemData.IconID
		local imgName = DB_ResourceList.getDataById(itemIconId).Res_path1
		resultWidget:getChildByName("Image_HeroIcon"):loadTexture(imgName, 1)
		resultWidget:getChildByName("Image_HeroIcon"):setVisible(true)
		-- 换品质图片
	--	local quality = itemData.Quality
		local quality = 1
		resultWidget:getChildByName("Image_Quality"):loadTexture("icon_item_quality"..tostring(quality)..".png",1)
		resultWidget:getChildByName("Image_Quality_Bg"):loadTexture("icon_item_quality_bg"..tostring(quality)..".png",1)

	--	if 5 == itemData.Quality then
		--	local animNode = AnimManager:createAnimNode(8067)
		--	resultWidget:getChildByName("Panel_SuperHero_Animation"):addChild(animNode:getRootNode(), 100)
		--	animNode:play("item_superhero", true)
			resultWidget:getChildByName("Image_SuperHero"):loadTexture("hero_super_1.png")
	--	else
	--		resultWidget:getChildByName("Image_SuperHero"):loadTexture("hero_super_0.png")
	--	end
		resultWidget:getChildByName("Image_SuperHero"):setVisible(false)
	elseif 3 == itemData.Type then -- 装备碎片
		-- 换物品图片
		local itemIconId = itemData.IconID
		local imgName = DB_ResourceList.getDataById(itemIconId).Res_path1
		resultWidget:getChildByName("Image_Item"):loadTexture(imgName, 1)
		resultWidget:getChildByName("Image_HeroIcon"):setVisible(false)
		resultWidget:getChildByName("Image_Item"):setVisible(true)
		-- 换品质图片
		local quality = itemData.Quality
		resultWidget:getChildByName("Image_Quality"):loadTexture("icon_item_quality"..tostring(quality)..".png",1)
		resultWidget:getChildByName("Image_Quality_Bg"):loadTexture("icon_item_quality_bg"..tostring(quality)..".png",1)
		-- 显示碎片标记
		resultWidget:getChildByName("Image_HeroIcon"):setVisible(true)
	else
		-- 换品质图片
		resultWidget:getChildByName("Image_Quality"):loadTexture("icon_item_quality"..tostring(itemQuality)..".png",1)
		resultWidget:getChildByName("Image_Quality_Bg"):loadTexture("icon_item_quality_bg"..tostring(itemQuality)..".png",1)
		-- 换物品图片
		local imgName = DB_ResourceList.getDataById(itemIconId).Res_path1
		resultWidget:getChildByName("Image_Item"):loadTexture(imgName, 1)
		resultWidget:getChildByName("Image_HeroIcon"):setVisible(false)
		resultWidget:getChildByName("Image_Item"):setVisible(true)
	end

	-- 更换碎片图片
--	resultWidget:getChildByName("Image_Piece"):loadTexture("icon_piece.png", 1)

	-- 数量
	if -1 == count then
		resultWidget:getChildByName("Label_Count_Stroke"):setVisible(false)
	elseif nil ~= count then
		resultWidget:getChildByName("Label_Count_Stroke"):setVisible(true)	
	 	resultWidget:getChildByName("Label_Count_Stroke"):setString(tostring(count))
	end 

	return resultWidget
end

-- 创建宝石
function createDiamondWidget(id, count, srcWidget)
	local resultWidget = nil

	if srcWidget == nil then  
		resultWidget = GUIWidgetPool:createWidget("ItemWidget")
	else
		resultWidget = srcWidget
	end

	resultWidget:setTag(id)
	local diamondData = DB_Diamond.getDataById(id)
	local diamondIconId = diamondData.Icon

	resultWidget:getChildByName("Image_HeroIcon"):setVisible(false)

	-- 换品质图片
	local quality = diamondData.Quality
	resultWidget:getChildByName("Image_Quality"):loadTexture("icon_item_quality"..tostring(quality)..".png", 1)
--	resultWidget:getChildByName("Image_Quality"):setVisible(false)
	resultWidget:getChildByName("Image_Quality_Bg"):loadTexture("icon_item_quality_bg"..tostring(quality)..".png", 1)
	-- 换物品图片
	local imgName = DB_ResourceList.getDataById(diamondIconId).Res_path1
	resultWidget:getChildByName("Image_Item"):loadTexture(imgName, 1)
	resultWidget:getChildByName("Image_Item"):setVisible(true)
	if count then
		-- 显示数量
		if count > 1 then
			resultWidget:getChildByName("Label_Count_Stroke"):setVisible(true)
			resultWidget:getChildByName("Label_Count_Stroke"):setString(tostring(count))
		end
	end

	resultWidget:getChildByName("Image_Quality"):setVisible(true)

	return resultWidget
end

CommonTipsWidget = {}

function CommonTipsWidget:new()
	local o = 
	{
		mRootWidget 		= 	nil,
		mPanelMain			=	nil,
		mPanelWidth 		=	0,
		mSchedulerHandler 	=	nil,
		mTipsList 			=	{},
		mLabelWidget		=	nil,

	}
	o = newObject(o, CommonTipsWidget)
	return o
end

function CommonTipsWidget:init()
	self.mRootWidget = GUIWidgetPool:createWidget("CommonTips")
	self.mPanelMain = self.mRootWidget:getChildByName("Panel_Main")
	self.mPanelMain:setClippingEnabled(true)
	self.mLabelWidget = self.mRootWidget:getChildByName("Label_Tips")
	self.mPanelWidth = self.mPanelMain:getContentSize().width
	GUISystem.RootNode:addChild(self.mRootWidget, 500)
	self.mRootWidget:setPositionY(500)
	self.mRootWidget:setVisible(false)
	self:doTick(true)
end

function CommonTipsWidget:doTick(boolVal)
	local scheduler = cc.Director:getInstance():getScheduler()
	if boolVal then
		self.mSchedulerHandler = scheduler:scheduleScriptFunc(handler(self, self.checkTips), 0, false)
	else
		scheduler:unscheduleScriptEntry(self.mSchedulerHandler)
	end

end

function CommonTipsWidget:checkTips()
	for k, v in pairs(self.mTipsList) do
		self:showTips(k)
		break
	end
end

function CommonTipsWidget:showTips(k)
	self:doTick(false)

	local function finishAction()
		self.mTipsList[k] = nil
		self:doTick(true)
		self.mRootWidget:setVisible(false)
	end

	local function doAction()
		self.mLabelWidget:setString(k)
		local textWidth = self.mLabelWidget:getStringLength() * 40
		local srcX, srcY = self.mLabelWidget:getPosition() 
		local moveWidth = self.mPanelWidth + textWidth
		local act0 = cc.MoveBy:create(10, cc.p(-moveWidth, 0))
	    local act1 = cc.Place:create(cc.p(srcX, srcY))
	    local act2 = cc.CallFunc:create(finishAction)
	    self.mLabelWidget:runAction(cc.Sequence:create(act0, act1, act2))
	    self.mRootWidget:setVisible(true)
	end
	doAction()
end

function CommonTipsWidget:pushTips(tips)
	self.mTipsList[tips] = tips
end

function CommonTipsWidget:destroy()

end

-- 创建进阶消耗项
function createJinjieConsumeWidget(itemType, itemId, itemNum)
	local rootWidget = GUIWidgetPool:createWidget("JinjieConsumeItem")
	if 0 == itemType then	-- 物品
		local itemData = DB_ItemConfig.getDataById(itemId)
		local itemIconId = itemData.IconID
		local itemNameId = itemData.Name
		local imgName = DB_ResourceList.getDataById(itemIconId).Res_path1
		rootWidget:getChildByName("Image_Type"):loadTexture(imgName)
		rootWidget:getChildByName("Label_Name"):setString("消耗"..getDictionaryText(itemNameId))

	elseif 1 == itemType then -- 装备
		local equipInfo = DB_EquipmentConfig.getDataById(id)
		local iconId = equipInfo.IconID
		local nameId = equipInfo.Name
		local ImgData = DB_ResourceList.getDataById(iconId)
		local imgName = ImgData.Res_path1
		rootWidget:getChildByName("Image_Type"):loadTexture(imgName)
		rootWidget:getChildByName("Label_Name"):setString("消耗"..getDictionaryText(nameId))
	elseif 2 == itemType then -- 金币
		rootWidget:getChildByName("Image_Type"):loadTexture("public_gold.png")
	elseif 3 == itemType then -- 钻石
		rootWidget:getChildByName("Image_Type"):loadTexture("public_diamond.png")	
	end
	rootWidget:getChildByName("Label_Count"):setString(tostring(itemNum))
	return rootWidget
end

-- 创建装备
function createEquipWidget(id, equipQuality,wgtCount,srcWidget)
	local rootWidget = nil
	if srcWidget == nil then
		rootWidget = GUIWidgetPool:createWidget("ItemWidget")
	else
		rootWidget = srcWidget
	end

	local equipInfo = DB_EquipmentConfig.getDataById(id)
	local iconId = equipInfo.IconID
--	local equipQuality = equipInfo.Quality
	local ImgData = DB_ResourceList.getDataById(iconId)
	local imgName = ImgData.Res_path1

	rootWidget:getChildByName("Image_Item"):loadTexture(imgName)
	rootWidget:setTag(id)
	rootWidget:getChildByName("Image_Quality"):loadTexture("icon_item_quality"..tostring(equipQuality)..".png", 1)
	rootWidget:getChildByName("Image_Quality_Bg"):loadTexture("icon_item_quality_bg"..tostring(equipQuality)..".png", 1)
	rootWidget:getChildByName("Image_Item"):setVisible(true)

	rootWidget:setTouchEnabled(false)

	-- if lv then
	-- 	rootWidget:getChildByName("Label_Level"):setString(tostring(lv))
	-- else
	-- 	rootWidget:getChildByName("Label_Level"):setString("")
	-- end

	if wgtCount then
		if wgtCount > 1 then 
			rootWidget:getChildByName("Label_Count_Stroke"):setVisible(true)
			rootWidget:getChildByName("Label_Count_Stroke"):setString(tostring(wgtCount))
		else
			rootWidget:getChildByName("Label_Count_Stroke"):setVisible(false)
		end
	end

	return rootWidget
end

-- 创建装备洗练项
function createEquipXilianWidget(equipObj, func, srcWidget)
	local rootWidget = nil
	if srcWidget then
		rootWidget = srcWidget
	else
		rootWidget = GUIWidgetPool:createWidget("Equip_Xiangqian")
	end
	
	-- 显示装备图标
	local equipWidget = createEquipWidget(equipObj:getKeyValue("id"), equipObj:getKeyValue("quality"))
	rootWidget:getChildByName("Panel_EquipItem"):removeAllChildren()
	rootWidget:getChildByName("Panel_EquipItem"):addChild(equipWidget, 100)

	-- 名字
	local equipInfo = DB_EquipmentConfig.getDataById(equipObj:getKeyValue("id"))
	local equipNameId = equipInfo.Name
	local equipName = getDictionaryText(equipNameId)
	rootWidget:getChildByName("Label_EquipName"):setString(equipName)

	-- 名字颜色
	local nameWidget = rootWidget:getChildByName("Label_EquipName")
	nameWidget:setString(equipName)
	if 1 == equipObj.quality then
		nameWidget:setColor(cc.c3b(0,0,0))
	elseif 2 == equipObj.quality then
		nameWidget:setColor(cc.c3b(0,166,62))
	elseif 3 == equipObj.quality then
		nameWidget:setColor(cc.c3b(0,150,255))
	elseif 4 == equipObj.quality then
		nameWidget:setColor(cc.c3b(288,0,255))
	elseif 5 == equipObj.quality then
		nameWidget:setColor(cc.c3b(255,144,0))
	end

	local qualityWidget = rootWidget:getChildByName("Label_EquipQulity_Stroke")

	if equipObj.qualityAddValue <= 0 then
		qualityWidget:setVisible(false)
	else
		qualityWidget:setVisible(true)
		if 1 == equipObj.qualityAddValue then
			qualityWidget:setColor(cc.c3b(255,255,255))
		elseif 2 == equipObj.qualityAddValue then
			qualityWidget:setColor(cc.c3b(16,222,0))
		elseif 3 == equipObj.qualityAddValue then
			qualityWidget:setColor(cc.c3b(0,150,255))
		elseif 4 == equipObj.qualityAddValue then
			qualityWidget:setColor(cc.c3b(288,0,255))
		elseif 5 == equipObj.qualityAddValue then
			qualityWidget:setColor(cc.c3b(255,144,0))
		end
		qualityWidget:setString("+"..equipObj.qualityAddValue)
	end


	-- 级别
	rootWidget:getChildByName("Label_EquipLevel"):setString("Lv."..tostring(equipObj:getKeyValue("level")))

	-- 回调
	if func then
		equipWidget:setTouchEnabled(true)
		registerWidgetReleaseUpEvent(equipWidget, func)
	end

	return rootWidget
end

-- 创建更换装备项
function createEquipExchangeWidget(equipObj, battleIndex, preCombat, heroId, advanceLv)
	local widget = GUIWidgetPool:createWidget("HeroEquipReplace")
	-- 装备图标
	local equipIcon = createEquipWidget(equipObj:getKeyValue("id"), equipObj:getKeyValue("quality"))
	widget:getChildByName("Panel_EquipItem"):addChild(equipIcon)
	-- 名字
	local equipInfo = DB_EquipmentConfig.getDataById(equipObj:getKeyValue("id"))
	local equipNameId = equipInfo.Name
	local equipName = getDictionaryText(equipNameId)
	widget:getChildByName("Label_EquipName"):setString(equipName.." Lv."..tostring(equipObj:getKeyValue("level")))
	
	-- 穿装备请求
	local function requestEquipPuton()
		local packet = NetSystem.mNetManager:GetSPacket()
   		packet:SetType(PacketTyper._PTYPE_CS_EQUIP_PUTON_)
    	packet:PushString(equipObj:getKeyValue("guid"))
    	packet:PushInt(equipObj:getKeyValue("type"))
    	packet:PushInt(battleIndex)
    	packet:Send()
    	GUISystem:showLoading()
	end
	registerWidgetReleaseUpEvent(widget:getChildByName("Button_GetOn"), requestEquipPuton)

	local deltaCombat = equipObj:getKeyValue("combat") - preCombat
	if deltaCombat >= 0 then
		widget:getChildByName("Image_Arrow"):loadTexture("public_arrow2.png")
	else
		widget:getChildByName("Image_Arrow"):loadTexture("public_arrow3.png")
	end
	widget:getChildByName("Label_ZhanliChange"):setString(tostring(deltaCombat))

	-- 玩家
	if heroId then
		local colorTable = {}
		colorTable[0] = cc.c3b(0,0,0)
		colorTable[1] = cc.c3b(0,143,63)
		colorTable[2] = cc.c3b(0,143,63)
		colorTable[3] = cc.c3b(0,72,143)
		colorTable[4] = cc.c3b(0,72,143)
		colorTable[5] = cc.c3b(140,0,143)
		colorTable[6] = cc.c3b(140,0,143)
		colorTable[7] = cc.c3b(255,110,0)

		widget:getChildByName("Panel_PreOwner"):setVisible(true)
		local heroData = DB_HeroConfig.getDataById(heroId)
		local heroNameId = heroData.Name
		local heroName = getDictionaryText(heroNameId)
		widget:getChildByName("Label_HeroName"):setString(heroName)
		widget:getChildByName("Label_HeroName"):setColor(colorTable[advanceLv])
	else
		widget:getChildByName("Panel_PreOwner"):setVisible(false)
	end	

	return widget
end

-- 创建强化装备项
function createEquipStrengthenWidget(heroId, equipObj, notForStrengthen, func, srcWidget)
	local rootWidget = nil
	if srcWidget then
		rootWidget = srcWidget
	else
		rootWidget = GUIWidgetPool:createWidget("Equip_Qianghua")
	end
	-- 设置装备类型
	rootWidget:setTag(equipObj.type)

	local equipInfo = DB_EquipmentConfig.getDataById(equipObj:getKeyValue("id"))
	local equipNameId = equipInfo.Name
	local equipName = getDictionaryText(equipNameId)
--	rootWidget:getChildByName("Label_EquipNameLevel"):setString(string.format("%s Lv.%d", equipName, equipObj:getKeyValue("level")))
	rootWidget:getChildByName("Label_EquipLevel"):setString("Lv."..equipObj:getKeyValue("level"))

	-- 字体字号
	rootWidget:getChildByName("Button_Qianghua"):setTitleFontName("font_3.ttf")
	rootWidget:getChildByName("Button_Qianghua"):setTitleFontSize(20)

	local function updateQianghuaText()
		if 0 == math.fmod(equipObj:getKeyValue("level"), 20) then
		--	rootWidget:getChildByName("Button_Qianghua"):setTitleText("进阶")
		--	rootWidget:getChildByName("Image_Jinjie"):loadTexture("item_equip_jinjie_"..tostring(equipObj:getKeyValue("type"))..".png", 1)
		else
		--	rootWidget:getChildByName("Button_Qianghua"):setTitleText("强化")
		end
	end
--	updateQianghuaText()

	-- 显示装备图标
	local equipWidget = createEquipWidget(equipObj:getKeyValue("id"), equipObj:getKeyValue("quality"))
	rootWidget:getChildByName("Panel_EquipItem"):removeAllChildren()
	rootWidget:getChildByName("Panel_EquipItem"):addChild(equipWidget, 100)

	if func then
		equipWidget:setTouchEnabled(true)
		registerWidgetReleaseUpEvent(equipWidget, func)
	end

	-- 显示材料
--	rootWidget:getChildByName("Image_Qianghua"):loadTexture("item_equip_stone.png", 1)

	-- 显示信息小窗口
--	MessageBox:setTouchShowInfoEx(rootWidget:getChildByName("Panel_QianghuaCost"), rootWidget:getChildByName("Image_Qianghua"), 0, 40007)

	-- 更新信息
	local function freshInfo(data)
		updateQianghuaText()
		local strengthGoodList = data:getKeyValue("strengthGoodList")
		-- 名字颜色
		local nameWidget = rootWidget:getChildByName("Label_EquipName")
		nameWidget:setString(equipName)
		if 1 == data.quality then
			nameWidget:setColor(cc.c3b(0,0,0))
		elseif 2 == data.quality then
			nameWidget:setColor(cc.c3b(0,166,62))
		elseif 3 == data.quality then
			nameWidget:setColor(cc.c3b(0,150,255))
		elseif 4 == data.quality then
			nameWidget:setColor(cc.c3b(288,0,255))
		elseif 5 == data.quality then
			nameWidget:setColor(cc.c3b(255,144,0))
		end

		local qualityWidget = rootWidget:getChildByName("Label_EquipQulity_Stroke")

		if data.qualityAddValue <= 0 then
			qualityWidget:setVisible(false)
		else
			qualityWidget:setVisible(true)
			if 1 == data.quality then
				qualityWidget:setColor(cc.c3b(255,255,255))
			elseif 2 == data.quality then
				qualityWidget:setColor(cc.c3b(16,222,0))
			elseif 3 == data.quality then
				qualityWidget:setColor(cc.c3b(0,150,255))
			elseif 4 == data.quality then
				qualityWidget:setColor(cc.c3b(288,0,255))
			elseif 5 == data.quality then
				qualityWidget:setColor(cc.c3b(255,144,0))
			end
			qualityWidget:setString("+"..data.qualityAddValue)
		end

		-- if #strengthGoodList > 0 then
		-- 	-- 强化材料
		-- 	local price0 = strengthGoodList[1].mCount
		-- --	rootWidget:getChildByName("Panel_QianghuaCost"):getChildByName("Label_Cost"):setString(tostring(price0))
		-- end

		-- if #strengthGoodList > 1 then
		-- 	-- 进阶材料
		-- 	local price1 = strengthGoodList[2].mCount
		-- 	local priceId = strengthGoodList[2].mId
		-- 	local itemData = DB_ItemConfig.getDataById(priceId)
		-- 	local itemIconId = itemData.IconID
		-- 	local imgName = DB_ResourceList.getDataById(itemIconId).Res_path1
		-- 	rootWidget:getChildByName("Image_Jinjie"):loadTexture(imgName, 1)
		-- --	rootWidget:getChildByName("Panel_JinjieCost"):getChildByName("Label_Cost"):setString(tostring(globaldata:getItemOwnCount(priceId)).."/"..tostring(price1))
		-- --	rootWidget:getChildByName("Panel_NeedItem_1")

		-- 	-- 显示信息小窗口
		-- --	MessageBox:setTouchShowInfoEx(rootWidget:getChildByName("Panel_JinjieCost"), rootWidget:getChildByName("Image_Jinjie"), 0, priceId)
		-- end

		-- 移除之前的物品
		for j = 1, 2 do 
			rootWidget:getChildByName("Panel_NeedItem_"..j):setVisible(false)
			rootWidget:getChildByName("Panel_NeedItem_"..j):getChildByName("Panel_Item"):removeAllChildren()
		end

		for i = 1, 2 do
			rootWidget:getChildByName("Panel_NeedItem_"..i):getChildByName("Image_Add"):setVisible(false)
		end

		local index = 0
		for i = 1, #strengthGoodList do
			local itemCnt = strengthGoodList[i].mCount
			local itemId = strengthGoodList[i].mId
			local itemType = strengthGoodList[i].mType

			if 2 == itemType then -- 金钱
				local goldWidget =  createCommonWidget(2, nil, "")
				rootWidget:getChildByName("Panel_Gold"):getChildByName("Panel_Item"):addChild(goldWidget)
				rootWidget:getChildByName("Panel_Gold"):getChildByName("Label_Num_Stroke"):setString(itemCnt)
			else
				index = index + 1
				local parentNode = rootWidget:getChildByName("Panel_NeedItem_"..index)
				parentNode:setVisible(true)
				local itemWidget = createCommonWidget(itemType, itemId, itemCnt, nil, true)
				itemWidget:getChildByName("Label_Count_Stroke"):setVisible(false)	
			--	itemWidget:getChildByName("Image_Quality"):loadTexture("icon_item_quality"..tostring(data:getKeyValue("quality"))..".png", 1)
			--	itemWidget:getChildByName("Image_Quality_Bg"):loadTexture("icon_item_quality_bg"..tostring(data:getKeyValue("quality"))..".png", 1)
				parentNode:getChildByName("Panel_Item"):addChild(itemWidget)
				parentNode:setVisible(true)
				itemWidget:setTag(1990)
				-- 显示数量
				parentNode:getChildByName("Label_Num_Stroke"):setString(tostring(globaldata:getItemOwnCount(itemId)).."/"..tostring(itemCnt))
				if globaldata:getItemOwnCount(itemId) >= itemCnt then -- 足够
				--	MessageBox:setTouchShowInfo(itemWidget, itemType, itemId)
					MessageBox:showHowToGetMessage(itemWidget, itemType, itemId)
					parentNode:getChildByName("Image_Add"):setVisible(false)
				else
					MessageBox:showHowToGetMessage(itemWidget, itemType, itemId)
					parentNode:getChildByName("Image_Add"):setVisible(true)
				end
			end
		end

		-- 进阶
		rootWidget:getChildByName("Panel_EquipItem"):getChildren()[1]:getChildByName("Image_Quality"):loadTexture("icon_item_quality"..tostring(equipObj:getKeyValue("quality"))..".png", 1)
		rootWidget:getChildByName("Panel_EquipItem"):getChildren()[1]:getChildByName("Image_Quality_Bg"):loadTexture("icon_item_quality_bg"..tostring(equipObj:getKeyValue("quality"))..".png", 1)
	--	rootWidget:getChildByName("Label_EquipNameLevel"):setString(string.format("%s Lv.%d", equipName, equipObj:getKeyValue("level")))

		rootWidget:getChildByName("Label_EquipName"):setString(equipName)
		rootWidget:getChildByName("Label_EquipLevel"):setString("Lv."..equipObj:getKeyValue("level"))
	end
	freshInfo(equipObj)

	-- 装备强化成功
	local function onStrengthenSuccess(data, propTbl)
		freshInfo(data)
		GUISystem:hideLoading()
		-- 刷新
		EquipNoticeInnerImpl:doUpdate()

		if EquipGuideOne:canGuide() then
			local guideBtn = GUISystem:GetWindowByName("EquipInfoWindow").mRootWidget:getChildByName("Button_AutoQianghua")
			local size = guideBtn:getContentSize()
			local pos = guideBtn:getWorldPosition()
			pos.x = pos.x - size.width/2
			pos.y = pos.y - size.height/2
			local touchRect = cc.rect(pos.x, pos.y, size.width, size.height)
			EquipGuideOne:step(6, touchRect)
		end
	end

	-- 穿装备请求
	local function requestEquipPuton()
		local packet = NetSystem.mNetManager:GetSPacket()
   		packet:SetType(PacketTyper._PTYPE_CS_EQUIP_PUTON_)
    	packet:PushString(equipObj:getKeyValue("guid"))
    	packet:PushInt(equipObj:getKeyValue("type"))
    	packet:PushInt(battleIndex)
    	packet:Send()
	end

	-- 装备自动强化请求
	local function requestDoAutoStrengthen()
		globaldata.onEquipStrengthenSucessHandler = onStrengthenSuccess
		local packet = NetSystem.mNetManager:GetSPacket()
   		packet:SetType(PacketTyper._PTYPE_CS_REQUEST_EQUIP_AUTOSTRENGTHEN_)
    	packet:PushString(equipObj:getKeyValue("guid"))
    	packet:PushInt(equipObj:getKeyValue("id"))
    	packet:Send()
    	GUISystem:showLoading()
	end

	-- 判断强化材料是否满足
	local function isItemEnough()
		local isEnough = false
		local strengthGoodList = equipObj:getKeyValue("strengthGoodList")
		if #strengthGoodList > 0 then 

		end
	end

	-- 装备强化请求
	local function requestDoStrengthen()
		globaldata.onEquipStrengthenSucessHandler = onStrengthenSuccess
		local packet = NetSystem.mNetManager:GetSPacket()
		local equipLevel = equipObj:getKeyValue("level")
   		packet:SetType(PacketTyper._PTYPE_CS_REQUEST_EQUIP_STRENGTHEN_)
   		packet:PushInt(heroId)
   		packet:PushChar(equipObj:getKeyValue("type"))
    --	packet:PushString(equipObj:getKeyValue("guid"))
    --	packet:PushInt(equipObj:getKeyValue("id"))
    --	packet:PushInt(equipLevel)
    --	packet:PushInt(globaldata:getQianghuaPrice(equipLevel))
    	packet:Send()
    	GUISystem:showLoading()
	end

	if notForStrengthen then
		-- -- 做穿装操作
		-- rootWidget:getChildByName("Button_Auto"):setVisible(false)
		-- -- 文字
		-- rootWidget:getChildByName("Panel_Puton"):setVisible(true)
		-- -- 隐藏
		-- rootWidget:getChildByName("Panel_Info"):setVisible(false)
		-- registerWidgetReleaseUpEvent(rootWidget:getChildByName("Button_Custom"), requestEquipPuton)
		-- -- 战力信息显示
		-- rootWidget:getChildByName("Panel_Replace"):setVisible(true)

		-- local deltaCombat = equipObj:getKeyValue("combat") - preCombat
		-- if deltaCombat >= 0 then
		-- 	rootWidget:getChildByName("Image_Arrow"):loadTexture("public_arrow2.png")
		-- else
		-- 	rootWidget:getChildByName("Image_Arrow"):loadTexture("public_arrow3.png")
		-- end
		-- rootWidget:getChildByName("Label_ZhanliChange"):setString(tostring(deltaCombat))	
	else
		-- 做强化操作
	--	registerWidgetReleaseUpEvent(rootWidget:getChildByName("Button_Equip_Jinjie"), requestDoAutoStrengthen)
		registerWidgetReleaseUpEvent(rootWidget:getChildByName("Button_Qianghua"), requestDoStrengthen)
		-- 文字
	--	rootWidget:getChildByName("Panel_Puton"):setVisible(false)
		-- 隐藏
	--	rootWidget:getChildByName("Panel_Info"):setVisible(true)
		freshInfo(equipObj)
		-- 战力信息不显示
	--	rootWidget:getChildByName("Panel_Replace"):setVisible(false)
	end
	return rootWidget
end


-- 顶部人物信息面板

ROLE_TITLE_TYPE = {	TITLE_PARTY = 1,TITLE_DEPOSIT = 2,TITLE_SHOP = 3,
					TITLE_DATE = 4,TITLE_MAIL = 5,TITLE_EQUIP = 6,
					TITLE_WEALTH = 7,TITLE_RANK = 8,TITLE_WELFARE = 9,
					TITLE_ARENA = 10,TITLE_LADDER = 11,TITLE_BAG = 12,
					TITLE_PVE = 13,TITLE_FRIEND = 14,TITLE_HERO = 15,
			  		TITLE_TOWER = 16,TITLE_TASK = 17,TITLE_LOTTERY = 18,
			  		TITLE_PARTY_SHOP = 19, TITLE_ARENA_SHOP = 20, TITLE_TIANTI_SHOP = 21,
			  		TITLE_BLACKMARKET = 22,TITLE_FACTION = 23, TITLE_UNION = 24,
			  		TITLE_GANGWARS = 25,TITLE_TECHNOLOGY = 26,TITLE_PARTY_BUILD = 27,
			  		TITLE_PARTY_HELLO = 28,TITLE_PARTY_SKILL = 29,TITLE_PARTY_JOIN = 30,
			  		TITLE_WORLDBOSS = 31,TITLE_TOWEREX = 32,TITLE_COLORCHANGE = 33,
			  		TITLE_FASHIONEQUIP = 34,TITLE_HEROSKILL = 35,TITLE_BADGE = 36,
			  		TITLE_HEROTITLE = 37,
}

ROLE_TITLE_PICNAME = {	"roleinfo_title_guildmain.png","roleinfo_title_deposit.png","roleinfo_title_shop.png",
				 		"roleinfo_title_date.png","roleinfo_title_mail.png","roleinfo_title_equip.png",
				    	"roleinfo_title_wealth.png","roleinfo_title_rankinglist.png","roleinfo_title_welfare.png",
				    	"roleinfo_title_arena.png","roleinfo_title_tianti.png","roleinfo_title_bagpack.png",
				    	"roleinfo_title_pve.png","roleinfo_title_friends.png","roleinfo_title_hero.png",
				    	"roleinfo_title_tower.png","roleinfo_title_task.png","roleinfo_title_lottery.png",
				    	"roleinfo_title_guildshop.png", "roleinfo_title_arenashop.png", "roleinfo_title_tiantishop.png",
				    	"roleinfo_title_blackmarket.png","","roleinfo_title_guildhall.png",
				    	"roleinfo_title_guildwar.png","roleinfo_title_technology.png","roleinfo_title_guildbuild.png",
				    	"roleinfo_title_guildhello.png","roleinfo_title_guildskill.png","roleinfo_title_guildjoin.png",
				    	"roleinfo_title_worldboss.png","roleinfo_title_dayup.png","roleinfo_title_colorchange.png",
				    	"roleinfo_title_mountsguns.png","roleinfo_title_skill.png","roleinfo_title_badge.png",
				    	"roleinfo_title_playertitle.png",
}

TopRoleInfoPanel = {}

function TopRoleInfoPanel:new()
	local o = 
	{
		mTopWidget 			=   nil,
		mRemoveHandler		=	nil,
		mAnimNode1 			=	nil,
		mAnimNode2			=	nil,
		mAnimNode3			=	nil,
	}
	o = newObject(o, TopRoleInfoPanel)
	return o
end 

function TopRoleInfoPanel:resetExitBtnCallFunc(func)
	if func and "function"==type(func) then
		local btnBack = self.mTopWidget:getChildByName("Button_Back")
		registerWidgetReleaseUpEvent(btnBack, func)
	end
end

function TopRoleInfoPanel:init(rootWidget,titleType,func)
--	local topWidget = GUIWidgetPool:createWidget("RoleInfoPanel")
--	self.mTopWidget = topWidget:getChildByName("Image_roleInfoBg"):clone()

	self.mTopWidget = GUIWidgetPool:createWidget("RoleInfoPanel")

	local contentSize = rootWidget:getContentSize()
	rootWidget:addChild(self.mTopWidget, 100)
	self.mTopWidget:setPosition(cc.p(getGoldFightPosition_LU().x, getGoldFightPosition_LU().y - self.mTopWidget:getContentSize().height))
	
	self.mRemoveHandler = function()
		self:updateTopRoleInfo()
	end

	self.mTopWidget:getChildByName("Image_Title"):loadTexture(ROLE_TITLE_PICNAME[titleType])

	GUIEventManager:registerEvent("roleBaseInfoChanged", self, self.mRemoveHandler)

	local panel = self.mTopWidget:getChildByName("Panel_BtnList")
	local function doAdapter()
		local contentSize = panel:getContentSize()
		panel:setPositionX(getGoldFightPosition_RU().x - contentSize.width - self.mTopWidget:getPositionX())
		-- 放在这里防止野指针发生
		local btnBack = self.mTopWidget:getChildByName("Button_Back")
		if func and "function"==type(func) then
			registerWidgetReleaseUpEvent(btnBack, func)
		end
	end
	doAdapter()

	registerWidgetReleaseUpEvent(self.mTopWidget:getChildByName("Button_Tili"), handler(self, self.PurchaseEvent))
    self.mTopWidget:getChildByName("Button_Tili"):setTag(0)
--    registerWidgetReleaseUpEvent(self.mTopWidget:getChildByName("Button_Gold"), handler(self, self.PurchaseEvent))
--    self.mTopWidget:getChildByName("Button_Gold"):setTag(2)

	-- 点金请求
	local function doGoldenFinger()
		GUISystem:goTo("goldenfinger")
	end
	registerWidgetReleaseUpEvent(self.mTopWidget:getChildByName("Button_Gold"), doGoldenFinger)

	-- 体力信息
	local function showTiliInfo(widget)
		MessageBox:showMessageBox_TiliInfo(widget)
	end
	registerWidgetReleaseUpEvent(self.mTopWidget:getChildByName("Panel_Tili"), showTiliInfo)

	self:updateTopRoleInfo()

	self.mAnimNode1 = AnimManager:createAnimNode(8009) -- 体力
	self.mTopWidget:getChildByName("Panel_Tili"):getChildByName("Panel_Animation"):addChild(self.mAnimNode1:getRootNode(), 100)
	self.mAnimNode1:play("roleinfo_tili", true)

	self.mAnimNode2 = AnimManager:createAnimNode(8010) -- 钻石
	self.mTopWidget:getChildByName("Panel_Diamond"):getChildByName("Panel_Animation"):addChild(self.mAnimNode2:getRootNode(), 100)
	self.mAnimNode2:play("roleinfo_diamond", true)

	self.mAnimNode3 = AnimManager:createAnimNode(8011) -- 金币
	self.mTopWidget:getChildByName("Panel_Gold"):getChildByName("Panel_Animation"):addChild(self.mAnimNode3:getRootNode(), 100)
	self.mAnimNode3:play("roleinfo_gold", true)

	return self.mTopWidget
end

function TopRoleInfoPanel:setVisible(visible)
	self.mTopWidget:setVisible(visible)
end

function TopRoleInfoPanel:PurchaseEvent(widget)
	local goodsType  = widget:getTag() -- 0:体力 1:耐力 2:点金
	local packet = NetSystem.mNetManager:GetSPacket()
    packet:SetType(PacketTyper._PTYPE_CS_REQUEST_BUYCONSUME_)
--    packet:PushChar(goodsType)
--    packet:PushInt(1)
    packet:Send()
    GUISystem:showLoading()
end

function TopRoleInfoPanel:doAdapter()
	local panel = self.mTopWidget:getChildByName("Panel_BtnList")
	local contentSize = panel:getContentSize()
	panel:setPositionX(getGoldFightPosition_RU().x - contentSize.width)
end

function TopRoleInfoPanel:updateTopRoleInfo()
	if self.mTopWidget then
		self.mTopWidget:getChildByName("Label_Tili"):setString(tostring(globaldata:getPlayerBaseData("vatality")).."/"..tostring(globaldata:getPlayerBaseData("maxVatality")))
--		self.mTopWidget:getChildByName("Label_huoli"):setString(tostring(globaldata:getPlayerBaseData("naili")).."/"..tostring(globaldata:getPlayerBaseData("maxNaili")))

		-- 钻石改变
		local preDiamond = globaldata:getPlayerPreBaseData("diamond")
		local curDiamond = globaldata:getPlayerBaseData("diamond")
		widgetDoGradualAction(self.mTopWidget:getChildByName("Label_Diamond"), preDiamond, curDiamond)

		-- 金币改变
		local preGold = globaldata:getPlayerPreBaseData("money")
		local curGold = globaldata:getPlayerBaseData("money")
		widgetDoGradualAction(self.mTopWidget:getChildByName("Label_Gold"), preGold, curGold)

		-- 姓名
		--self.mTopWidget:getChildByName("Label_PlayerName"):setString(tostring(globaldata:getPlayerBaseData("name")))

		-- 战力
		--self.mTopWidget:getChildByName("Label_Zhanli"):setString(tostring(globaldata:getTeamCombat()))

		-- 等级
		--self.mTopWidget:getChildByName("Label_PlayerLevel"):setString(tostring(globaldata:getPlayerBaseData("level")))
	end	
end

function TopRoleInfoPanel:destroy()
	GUIEventManager:unregister("roleBaseInfoChanged", self.mRemoveHandler)

	self.mAnimNode1:destroy()
	self.mAnimNode2:destroy()
	self.mAnimNode3:destroy()

	self.mTopWidget = nil
end

-- 创建活动事件
function createDateEventItem(dateObject)
	--print("**********************",dateObject.dateId,dateObject.dateOpen,dateObject.dateStatus)
	local widget = GUIWidgetPool:createWidget("DateEvent")
	
	widget:setTouchSwallowed(false)
	widget:setScale(0.5)
	widget:setVisible(false)
	widget:getChildByName("Button_Bg"):setTag(dateObject.dateId) -- 设置活动Id

	local strTmp = nil 
	local c3b    = nil 

	if dateObject.dateOpen == 0 and dateObject.dateStatus == 0 then 
		c3b = G_COLOR_C3B.RED 
		strTmp = "已完成"
	elseif dateObject.dateOpen == 0 and dateObject.dateStatus == 1 then 
		c3b = G_COLOR_C3B.BLUE 
		strTmp = "已开启" 
	elseif dateObject.dateOpen == 1 then
		c3b = G_COLOR_C3B.RED 
		strTmp = "未开放"
	end

	widget:getChildByName("Label_Condition"):setString(strTmp)
	widget:getChildByName("Label_Condition"):setColor(c3b)
	-- 名字
	local dateInfo     = DB_EventTotal.getDataById(dateObject.dateId)
	local dateNameId   = dateInfo.Event_TotalText
	local dateNameData = DB_ResourceList.getDataById(dateNameId)
	local dateImgName  = dateNameData.Res_path1
	widget:getChildByName("Image_Title"):loadTexture(dateImgName)

	-- 背景图
	--local dateBgId = dateInfo.Event_TotalBackground
	--local dateBgData = DB_ResourceList.getDataById(dateBgId)
	--local dateImgBg = dateBgData.Res_path1
	--widget:getChildByName("Image_EventPic"):loadTexture(dateImgBg)

	--开放时间
	local timeData  = DB_EventTotal.getDataById(dateObject.dateId)
	local timeBegin = timeData.Event_Time_Begin
	local timeEnd   = timeData.Event_Time_End

	widget:getChildByName("Label_OpenTime"):setString(string.format("%d:00~%d:00",timeBegin,timeEnd))

	-- 英雄图
	local dateHeroId   = dateInfo.Event_TotalImage
	local dateHeroData = DB_ResourceList.getDataById(dateHeroId)
	local dateImgHero  = dateHeroData.Res_path1
	widget:getChildByName("Image_Hero"):loadTexture(dateImgHero)

	return widget
end
-- 创建活动人物
function createDateObjectItem(objId,favorLv,favorExp,favorMaxExp)
	local widget    = GUIWidgetPool:createWidget("DateHero")
	local objInfo   = DB_EventObject.getDataById(objId)

	local objNameId = objInfo.Event_ObjectName
	local objName   = getDictionaryText(objNameId)

	local resID     = objInfo.Event_ObjectBust
	local resData   = DB_ResourceList.getDataById(resID)
	local resUrl    = resData.Res_path1

	-- 名字
	widget:getChildByName("Label_HeroName"):setString(objName)
	widget:getChildByName("Image_HeroPic"):loadTexture(resUrl)

	widget:getChildByName("Label_Level"):setString(tostring(favorLv))
	widget:getChildByName("Label_12"):setString(string.format("%d/%d",favorExp,favorMaxExp))
	widget:getChildByName("ProgressBar_Level"):setPercent(favorExp / favorMaxExp * 100 )
	
	return widget
end

-- 创建邮件
function createMailWidget(mailObj)
	local widget = GUIWidgetPool:createWidget("MailLetter")
	-- 标题
	widget:getChildByName("Label_LetterTitle"):setString(mailObj:getKeyValue("mailTile"))
	-- 日期
	--widget:getChildByName("Label_LetterTime"):setString(mailObj:getKeyValue("mailDate"))
	-- 附件
	if 0 == mailObj:getKeyValue("mailItem") then
		widget:getChildByName("Image_Gift"):setVisible(false)
	elseif 1 == mailObj:getKeyValue("mailItem") then
		widget:getChildByName("Image_Gift"):setVisible(true)
	end
	-- 是否阅读
	if 0 == mailObj:getKeyValue("mailRead") then
		--widget:getChildByName("Image_Condition"):setVisible(true)
		widget:getChildByName("Image_Condition"):loadTexture("mail_logounread.png")
	elseif 1 == mailObj:getKeyValue("mailRead") then
		--widget:getChildByName("Image_Condition"):setVisible(false)
		widget:getChildByName("Image_Condition"):loadTexture("mail_logoread.png")
	end
	

	return widget
end

-- 根据英雄ID和星级显示出来新英雄
function createNewHeroPanelByID(heroid, root, callFun, _num)
	local _infoDB = DB_HeroConfig.getDataById(heroid)
	if not _infoDB then return end
	local ItemID = _infoDB.Fragment
	local itemdata = DB_ItemConfig.getDataById(ItemID)
	if not itemdata then return end
	local newHeroPanel = GUIWidgetPool:createWidget("Lottery_Hero")
	local AnimflowerID = 8046
	local AnimflowerPlay1 = "lottery_hero_1"
	local AnimflowerPlay2 = "lottery_hero_2"

	local AnimHeroCard = 8047
	local AnimHeroCardPlay1 = "lottery_herocard_1"
	local AnimHeroCardPlay2 = "lottery_herocard_2"

	if itemdata.Quality == 5 then
		AnimflowerID = 8059
		AnimflowerPlay1 = "lottery2_hero_1"
		AnimflowerPlay2 = "lottery2_hero_2"

		AnimHeroCard = 8060
		AnimHeroCardPlay1 = "lottery2_herocard_1"
		AnimHeroCardPlay2 = "lottery2_herocard_2"

	else
		newHeroPanel:getChildByName("Panel_Card"):getChildByName("Image_SuperHero"):loadTexture("hero_super_0.png")
	end
	local Animflower = AnimManager:createAnimNode(AnimflowerID)
	newHeroPanel:getChildByName("Panel_FlowerAnimation"):addChild(Animflower:getRootNode(), 100)

	local AnimheroCard1 = nil
	local HeroAnimNode = nil
	local function CloseWindow()
		if HeroAnimNode then
			SpineDataCacheManager:collectFightSpineByAtlas(HeroAnimNode)
			HeroAnimNode = nil
		end
		if callFun then
			callFun()
			callFun = nil
		end
		newHeroPanel:removeFromParent()
	end
	local function showSpine()
		newHeroPanel:getChildByName("Panel_HeroSpine"):setVisible(true)
		HeroAnimNode = SpineDataCacheManager:getSimpleSpineByHeroID(heroid, newHeroPanel:getChildByName("Panel_HeroSpine"))
		HeroAnimNode:setSkeletonRenderType(cc.RENDER_TYPE_HERO)
		HeroAnimNode:setAnimation(0,"stand",true)
		-- 显示原画大图
		local heroData = DB_HeroConfig.getDataById(heroid)
		HeroAnimNode:setScale(heroData.UIResouceZoom)
	end

	local function CardFinish1( ... )
	end
	local function CardEvent(evt)
		if evt == "1" then
			-- 
			newHeroPanel:getChildByName("Panel_Card"):setVisible(true)
			newHeroPanel:getChildByName("Panel_Card"):getChildByName("Image_Group"):loadTexture(string.format("worldboss_group%d.png",_infoDB.HeroGroup))
			newHeroPanel:getChildByName("Panel_Card"):getChildByName(string.format("Image_Hero_%d",heroid)):setVisible(true)
			newHeroPanel:getChildByName("Panel_Card"):getChildByName(string.format("Image_Hero_%d",heroid)):loadTexture(DB_ResourceList.getDataById(_infoDB.PicID).Res_path1)
			newHeroPanel:getChildByName("Label_HeroName_Stroke"):setVisible(true)
			if _num then
				newHeroPanel:getChildByName("Label_HeroName_Stroke"):setString(string.format("%s X %d",getDictionaryText(_infoDB.Name),_num))
			else
				newHeroPanel:getChildByName("Label_HeroName_Stroke"):setString(getDictionaryText(_infoDB.Name))
			end
		elseif evt == "2" then
			--
			local act1 = cc.FadeOut:create(0.16)
			local act2 = cc.CallFunc:create(showSpine)
			newHeroPanel:getChildByName("Panel_Card"):runAction(cc.Sequence:create(act1,act2))
		end
	end

	local function playStarFinish( ... )
		Animflower:play(AnimflowerPlay2,true)
	end
	local function Event(evt)
		if evt == "1" then
			AnimheroCard1 = AnimManager:createAnimNode(AnimHeroCard)
			newHeroPanel:getChildByName("Panel_CardAnimation"):addChild(AnimheroCard1:getRootNode(), 100)
			if _num then
				AnimheroCard1:play(AnimHeroCardPlay2,false,CardFinish1,CardEvent)
			else
				AnimheroCard1:play(AnimHeroCardPlay1,false,CardFinish1,CardEvent)
			end
			registerWidgetReleaseUpEvent(newHeroPanel:getChildByName("Panel_32"), CloseWindow)
		end
	end
	Animflower:play(AnimflowerPlay1,false,playStarFinish,Event)
	
	root:addChild(newHeroPanel,200)

	return newHeroPanel
end

-- 根据类型和Id获取图片名字
function getImgNameByTypeAndId(imgType, imgId)
	if 2 == imgType then 	-- 金钱
		return "public_gold.png"
	elseif 3 == imgType then 	-- 钻石
		return "public_diamond.png"
	elseif 4 == imgType then 	-- 经验
		return "public_exp.png"
	elseif 5 == imgType then 	-- 体力
		return "public_energy.png"
	elseif 6 == imgType then 	-- 耐力
		-- return "icon_life.png"
	elseif 8 == imgType then    -- 宝石
		local itemData = DB_Diamond.getDataById(imgId)
		local itemIconId = itemData.Icon
		-- 换物品图片
		local imgName = DB_ResourceList.getDataById(itemIconId).Res_path1
		return imgName
	else 						-- 物品
		local itemData = DB_ItemConfig.getDataById(imgId)
		local itemIconId = itemData.IconID
		-- 换物品图片
		local imgName = DB_ResourceList.getDataById(itemIconId).Res_path1
		return imgName
	end
end

-- 创建Widget
function createCommonWidget(wgtType, wgtId, wgtCount, cloneWidget, notShowInfo)
--	print("物品类型:", wgtType, "物品ID:", wgtId)
	local widget = nil
	if 0 == wgtType then -- 物品
		widget = createItemWidget(wgtId, wgtCount, cloneWidget)
	elseif 1 == wgtType then -- 装备
		widget = createEquipWidget(wgtId, 1, wgtCount, cloneWidget)
	elseif 2 == wgtType then -- 金钱
		widget = GUIWidgetPool:createWidget("ItemWidget")
		widget:getChildByName("Image_Quality"):setVisible(true)
		widget:getChildByName("Image_Quality"):loadTexture("icon_item_quality1.png",1)
		widget:getChildByName("Image_Quality_Bg"):loadTexture("icon_item_quality_bg1.png",1)
		widget:getChildByName("Image_Item"):loadTexture("item_gold.png",1)
		widget:getChildByName("Image_Item"):setVisible(true)
		widget:getChildByName("Label_Count_Stroke"):setVisible(true)
		widget:getChildByName("Label_Count_Stroke"):setString(tostring(wgtCount))
	elseif 3 == wgtType then -- 钻石
		widget = GUIWidgetPool:createWidget("ItemWidget")
		widget:getChildByName("Image_Quality"):setVisible(true)
		widget:getChildByName("Image_Quality"):loadTexture("icon_item_quality1.png",1)
		widget:getChildByName("Image_Quality_Bg"):loadTexture("icon_item_quality_bg1.png",1)
		widget:getChildByName("Image_Item"):loadTexture("item_diamond.png",1)
		widget:getChildByName("Image_Item"):setVisible(true)
		widget:getChildByName("Label_Count_Stroke"):setVisible(true)
		widget:getChildByName("Label_Count_Stroke"):setString(tostring(wgtCount))
	elseif 4 == wgtType then -- 经验
		widget = GUIWidgetPool:createWidget("ItemWidget")
		widget:getChildByName("Image_Quality"):setVisible(true)
		widget:getChildByName("Image_Quality"):loadTexture("icon_item_quality1.png",1)
		widget:getChildByName("Image_Quality_Bg"):loadTexture("icon_item_quality_bg1.png",1)
		widget:getChildByName("Image_Item"):loadTexture("item_exp.png",1)
		widget:getChildByName("Image_Item"):setVisible(true)
		widget:getChildByName("Label_Count_Stroke"):setVisible(true)
		widget:getChildByName("Label_Count_Stroke"):setString(tostring(wgtCount))
	elseif 5 == wgtType then -- 体力
		widget = GUIWidgetPool:createWidget("ItemWidget")
		widget:getChildByName("Image_Quality"):setVisible(false)
		widget:getChildByName("Image_Quality_Bg"):setVisible(false)
		widget:getChildByName("Image_Item"):loadTexture("public_energy.png")
	elseif 6 == wgtType then -- 声望
		widget = GUIWidgetPool:createWidget("ItemWidget")
		widget:getChildByName("Image_Quality"):setVisible(false)
		widget:getChildByName("Image_Quality_Bg"):setVisible(false)
		widget:getChildByName("Image_Item"):loadTexture("item_currency_arena.png")
	elseif 8 == wgtType then -- 宝石
		widget = createDiamondWidget(wgtId, wgtCount, cloneWidget)
	elseif 10 == wgtType then
		widget = createHeroIcon(wgtId, wgtCount)
	elseif 11 == wgtType then -- 天梯币
		widget = GUIWidgetPool:createWidget("ItemWidget")
		widget:getChildByName("Image_Quality"):setVisible(true)
		widget:getChildByName("Image_Quality"):loadTexture("icon_item_quality1.png",1)
		widget:getChildByName("Image_Quality_Bg"):loadTexture("icon_item_quality_bg1.png",1)
		widget:getChildByName("Image_Item"):loadTexture("item_currency_tianti.png",1)
		widget:getChildByName("Image_Item"):setVisible(true)
		widget:getChildByName("Label_Count_Stroke"):setVisible(true)
		widget:getChildByName("Label_Count_Stroke"):setString(tostring(wgtCount))
	elseif 12 == wgtType then -- 帮会贡献点
		widget = GUIWidgetPool:createWidget("ItemWidget")
		widget:getChildByName("Image_Quality"):setVisible(true)
		widget:getChildByName("Image_Quality"):loadTexture("icon_item_quality1.png",1)
		widget:getChildByName("Image_Quality_Bg"):loadTexture("icon_item_quality_bg1.png",1)
		widget:getChildByName("Image_Item"):loadTexture("item_currency_guild.png",1)
		widget:getChildByName("Image_Item"):setVisible(true)
		widget:getChildByName("Label_Count_Stroke"):setVisible(true)
		widget:getChildByName("Label_Count_Stroke"):setString(tostring(wgtCount))
	elseif 13 == wgtType then -- 活跃度
		widget = GUIWidgetPool:createWidget("ItemWidget")
		widget:getChildByName("Image_Quality"):setVisible(true)
		widget:getChildByName("Image_Quality"):loadTexture("icon_item_quality1.png",1)
		widget:getChildByName("Image_Quality_Bg"):loadTexture("icon_item_quality_bg1.png",1)
		widget:getChildByName("Image_Item"):loadTexture("task_activity_icon.png")
		widget:getChildByName("Image_Item"):setVisible(true)
		widget:getChildByName("Label_Count_Stroke"):setVisible(true)
		widget:getChildByName("Label_Count_Stroke"):setString(tostring(wgtCount))
	elseif 16 == wgtType then  -- 代币
		widget = GUIWidgetPool:createWidget("ItemWidget")
		widget:getChildByName("Image_Quality"):setVisible(true)
		widget:getChildByName("Image_Quality"):loadTexture("icon_item_quality1.png",1)
		widget:getChildByName("Image_Quality_Bg"):loadTexture("icon_item_quality_bg1.png",1)
		widget:getChildByName("Image_Item"):loadTexture("item_currency_tower.png",1)
		widget:getChildByName("Image_Item"):setVisible(true)
		widget:getChildByName("Label_Count_Stroke"):setVisible(true)
		widget:getChildByName("Label_Count_Stroke"):setString(tostring(wgtCount))
	end
	if not notShowInfo then
		MessageBox:setTouchShowInfo(widget,wgtType,wgtId)
	end
	return widget
end

function visibleOnlyImg(itemWidget)
	itemWidget:getChildByName("Label_Count_Stroke"):setVisible(false)
	itemWidget:getChildByName("Image_Quality"):setVisible(false)
	itemWidget:getChildByName("Image_Quality_Bg"):setVisible(false)
end

-- 获取名字
function getCommonName(wgtType, wgtId)
	if 0 == wgtType then -- 物品
		local itemData = DB_ItemConfig.getDataById(wgtId)
		local nameId = itemData.Name
		return getDictionaryText(nameId)
	elseif 1 == wgtType then -- 装备
		local itemData = DB_EquipmentConfig.getDataById(wgtId)
		local nameId = itemData.Name
		return getDictionaryText(nameId)
	elseif 2 == wgtType then
		return "金币"
	elseif 3 == wgtType then
		return "钻石"
	elseif 4 == wgtType then
		return "经验"
	elseif 5 == wgtType then
		return "体力"
	elseif 6 == wgtType then
		return "声望"
	elseif 8 == wgtType then -- 宝石
		local itemData = DB_Diamond.getDataById(wgtId)
		local nameId = itemData.Name
		return getDictionaryText(nameId)
	elseif 10 == wgtType then -- 英雄
		local heroData = DB_HeroConfig.getDataById(wgtId)
		local nameId = heroData.Name
		return getDictionaryText(nameId)
	end
end

-- 创建spine触摸区域
function createSpineTouchRegion(_size, _root, _func, _param)
    local _tr = ccui.Widget:create()
    _tr:setContentSize(_size)
    _tr:setAnchorPoint(cc.p(0.5, 0))
    _tr:setPosition(cc.p(0,0))
    _root:addChild(_tr)
    _tr:setTouchEnabled(true)
    registerWidgetPushAndReleaseEvent(_tr, _func, _param)
end

-- 显示loading窗口
function showLoadingWindow(_nextWindowName,_curWindowName)
	Event.GUISYSTEM_SHOW_LOADINGWINDOW.mData = {}
    Event.GUISYSTEM_SHOW_LOADINGWINDOW.mData[1] = _nextWindowName
    Event.GUISYSTEM_SHOW_LOADINGWINDOW.mData[2] = _curWindowName
    EventSystem:PushEvent(Event.GUISYSTEM_SHOW_LOADINGWINDOW)
end

-- 显示PVPloading窗口
function showPVPLoadingWindow(_nextWindowName,_curWindowName)
	Event.GUISYSTEM_SHOW_LADDERLOADINGWINDOW.mData = {}
    Event.GUISYSTEM_SHOW_LADDERLOADINGWINDOW.mData[1] = _nextWindowName
    Event.GUISYSTEM_SHOW_LADDERLOADINGWINDOW.mData[2] = _curWindowName
    EventSystem:PushEvent(Event.GUISYSTEM_SHOW_LADDERLOADINGWINDOW)
end


-- 关闭loading窗口
function hideLoadingWindow()
	EventSystem:PushEvent(Event.GUISYSTEM_HIDE_LOADINGWINDOW)
end

-- 关闭PVPloading窗口
function hidePVPLoadingWindow()
	EventSystem:PushEvent(Event.GUISYSTEM_HIDE_LADDERLOADINGWINDOW)
end

-- 雷达
RadarWidget = {}

function RadarWidget:new()
	local o = 
	{
		mParentNode		=	nil,
		mRootNode 		= 	nil,
		mRadarWidget	=	nil,
		mClippingNode	=	nil,
		mImageWidget	=	nil,
		mDrawNode 		=	nil,
	}
	o = newObject(o, RadarWidget)
	return o
end

function RadarWidget:init(parentNode)
	self.mParentNode = parentNode
	local contentSize = parentNode:getContentSize()
	self.mRootNode = cc.Layer:create()
	self.mParentNode:addChild(self.mRootNode, 100)

	self.mClippingNode = cc.ClippingNode:create()
	self.mRootNode:addChild(self.mClippingNode, 100)

 	self.mDrawNode = cc.DrawNode:create()
  
    self.mClippingNode:setStencil(self.mDrawNode)
--  self.mClippingNode:setInverted(true)

	-------------------------------------------------------

	local colorLayer = ccui.Layout:create()
--	colorLayer:setBackGroundColor(cc.c3b(0,255,0))
--	colorLayer:setOpacity(120)
	colorLayer:setContentSize(cc.size(contentSize.width, contentSize.height))
--	colorLayer:setBackGroundColorType(ccui.LayoutBackGroundColorType.solid)

	self.mImageWidget = ccui.ImageView:create()
	self.mImageWidget:loadTexture("hero_shuxing_pentagon_bg.png")
	colorLayer:addChild(self.mImageWidget)
	self.mImageWidget:setPosition(cc.p(contentSize.width/2, contentSize.height/2 + 10))
	self.mImageWidget:setScale(1.5)

	self.mClippingNode:addChild(colorLayer, 500)

end

function RadarWidget:drawShape(val)
	local innerPoint =
    { 	
    	cc.p(212, 203),
    	cc.p(207, 221), 
    	cc.p(222, 233), 
    	cc.p(238, 221),
    	cc.p(232, 203),
    }

    local outerPoint = 
    {
    	cc.p(167.5, 145.5),
    	cc.p(134.5, 247.5), 
    	cc.p(221.5, 309.5), 
    	cc.p(308.5, 247.5),
    	cc.p(274.5, 145.5),
	}

	local newPoint = {}
	for i = 1, 5 do
		local deltaX = (outerPoint[i].x-innerPoint[i].x)*val[i]
		local deltaY = (outerPoint[i].y-innerPoint[i].y)*val[i]
		newPoint[i] = cc.p(innerPoint[i].x + deltaX, innerPoint[i].y + deltaY)
	end
	self.mDrawNode:clear()
    self.mDrawNode:drawPolygon(newPoint, table.getn(newPoint), cc.c4f(1,0,0,0.5), 4, cc.c4f(0,0,1,1))
end

--xml string example
--	"<text>\
--		<a type=\"text\" fontsize=\"20\" fontcolor=\"#FF0000\" text=\"您确定要花费\"></a>\
--		<a type=\"text\" fontsize=\"20\" fontcolor=\"#00FF00\" text=\"255\"></a>\
--		<a type=\"text\" fontsize=\"20\" fontcolor=\"#FF0000\" text=\"钻石,购买\"></a>\
--		<a type=\"text\" fontsize=\"20\" fontcolor=\"#00FF00\" text=\"1\"></a>\
--		<a type=\"text\" fontsize=\"20\" fontcolor=\"#FF0000\" text=\"点体力吗?\"></a>\
--	</text>"
--server string example
-- string.format("请选择购买#50ff33%s#的数量", str)

function richTextCreate(panel,string,multiline, func,bXmlStr)
	panel:removeAllChildren()
	local contentSize = panel:getContentSize()
	local richText = ccui.RichText:create()

	richText:ignoreContentAdaptWithSize(not multiline)
	richText:setContentSize(contentSize)
	if bXmlStr == true then 
		richText:setString(string)
	else
		richText:setStringEx(string)
	end
	richText:setContainer(panel)

	if func then
		richText:registerLuaFunc(func)
	end

	if multiline == true then
		richText:setAnchorPoint(cc.p(0, 0))
	else
		richText:setAnchorPoint(cc.p(0, 0.5))
		richText:setPosition(cc.p(0,contentSize.height/2))
	end
	
	panel:addChild(richText)

	return richText
end

--@alignment: 1: left 2: right
function richTextCreateSingleLine(panel,string,alignment)
	panel:removeAllChildren()
	local contentSize = panel:getContentSize()
	local richText = ccui.RichText:create()
	richText:ignoreContentAdaptWithSize(true)
	richText:setContentSize(contentSize)
	richText:setStringEx(string)
	richText:setContainer(panel)
	if alignment == 1 then
	   richText:setAnchorPoint(cc.p(0, 0.5))
	   richText:setPosition(cc.p(0,contentSize.height/2))
	else
	   richText:setAnchorPoint(cc.p(1, 0.5))
	   richText:setPosition(cc.p(contentSize.width,contentSize.height/2))
	end
	panel:addChild(richText)

	return richText
end

-- 创建富文本，带字体设置
function richTextCreateWithFont(panel, string, multiline, fontsize, fontName)
	panel:removeAllChildren()
	local contentSize = panel:getContentSize()
	local richText = ccui.RichText:create()
	richText:ignoreContentAdaptWithSize(not multiline)
	richText:setContentSize(contentSize)
	richText:setFontSize(fontsize)
	if fontName then
	   richText:setFontName(fontName)
	end
	if bXmlStr == true then 
		richText:setString(string)
	else
		richText:setStringEx(string)
	end
	richText:setContainer(panel)

	if multiline == true then
		richText:setAnchorPoint(cc.p(0, 0))
	else
		richText:setAnchorPoint(cc.p(0, 0.5))
		richText:setPosition(cc.p(0,contentSize.height/2))
	end
	
	panel:addChild(richText)

	return richText
end

function setMedalLayout(score,medalPanel,typ)
	local picArr     = {"tianti_badge_1.png","tianti_badge_2.png","tianti_badge_3.png",
						"tianti_badge_4.png","tianti_badge_5.png","tianti_badge_6.png","tianti_badge_7.png"}
	local picIndex   = 0
	local starCnt    = 0
	local level      = 0
	local starPanel  = nil
	local levelStr   = nil
	local data       = (typ == 0 and DB_pvprewards1v1 or DB_pvprewards3v3)

	for i=1,17 do
		local minScore =  data.getDataById(i).Minscore
		local maxScore =  data.getDataById(i).Maxscore
		if score >= minScore and score <= maxScore then 
			level = i
			local desData = DB_Text.getDataById(data.getDataById(i).Name)
			levelStr = desData.Text_CN
		end
	end

	starCnt  = (level > 15 and 3 or (level - 3 * (math.ceil(level / 3) - 1)))
	picIndex = (level == 17 and 7 or math.ceil(level / 3))

 	medalPanel:getChildByName("Image_Badge"):loadTexture(picArr[picIndex])

 	if medalPanel:getChildByName("Label_Level_Stroke") then
 		medalPanel:getChildByName("Label_Level_Stroke"):setString(levelStr)
 	end

	starPanel = medalPanel:getChildByName("Panel_Star")
	starPanel:setVisible(true)

	for i=1,3 do
		starPanel:getChildByName(string.format("Image_Star_%d",i)):setVisible(false) 
	end

	for j=1,starCnt do
		starPanel:getChildByName(string.format("Image_Star_%d",j)):setVisible(true) 
	end
end


-- @param window the window which show PVE_FightTeam 
-- @param func function to call
-- @param heros default battle heros
-- @param selectType see SELECTHERO
-- @param ... extra param
-- @return no return

function ShowRoleSelWindow(window,func,heros,selectType,...)
	local function hideNoDisplayedWindow()
		EventSystem:PushEvent(Event.GUISYSTEM_DISABLEDRAW_BLACKMARKETWINDOW)
		EventSystem:PushEvent(Event.GUISYSTEM_DISABLEDRAW_TOWEREXWINDOW)
		EventSystem:PushEvent(Event.GUISYSTEM_DISABLEDRAW_WORLDBOSSWINDOW)
		EventSystem:PushEvent(Event.GUISYSTEM_DISABLEDRAW_WEALTHWINDOW)
		EventSystem:PushEvent(Event.GUISYSTEM_DISABLEDRAW_GANGWARSWINDOW)
		EventSystem:PushEvent(Event.GUISYSTEM_DISABLEDRAW_TOWERWINDOW)
	end
	hideNoDisplayedWindow()



	local argc = select('#',...)
	local argv = {}

	for i=1,argc do
		argv[i] = select(i,...)
	end

	local roleSelWindow = GUIWidgetPool:createWidget("PVE_FightTeam")
	local limitCnt      = ((not window or window.mName == "TowerWindow") and config.TowerFigntCnt or 1)
	local rootNode      = (window and window.mRootNode or GUISystem.RootNode) 
	local heroContainer = roleSelWindow:getChildByName(selectType == SELECTHERO.SHOWSELF and "Panel_3Hero" or "Panel_3v3")

	roleSelWindow:getChildByName("Panel_3v3"):setVisible(false)
	roleSelWindow:getChildByName("Panel_3Hero"):setVisible(false)
	heroContainer:setVisible(true)
	rootNode:addChild(roleSelWindow, 1501)

	--window extra layout or config
	if window and window.mName == "TowerWindow" then
		local enemyInfo = argv[1]

		for i=1,#enemyInfo do
			local enemyInfoPanel  = heroContainer:getChildByName(string.format("Panel_Enemy%d_Bg",i))
			local enemyPanel      = enemyInfoPanel:getChildByName(string.format("Panel_Hero_%d",i))
			local enemyInfo       = enemyInfo[i]
			local enemyData       = DB_HeroConfig.getDataById(enemyInfo.mHeroId)
			local enemyNameId     = enemyData.Name
			local heroWidget      = createHeroIcon(enemyInfo.mHeroId,enemyInfo.mHeroLevel,enemyInfo.mHeroQuality,enemyInfo.mHeroAdvanceLv)

			heroWidget:getChildByName("Label_Level_Stroke"):setVisible(false)
			heroWidget:getChildByName("Panel_Star"):setVisible(false)
			heroWidget:getChildByName("Image_HeroDead"):setVisible(enemyInfo.mHeroCurHp == 0)
			
			enemyInfoPanel:getChildByName("Image_HeroBlood_Bg"):setVisible(true) 
			enemyInfoPanel:getChildByName("ProgressBar_HeroBlood"):setPercent(enemyInfo.mHeroCurHp / enemyInfo.mHeroTotalHp * 100)
			enemyInfoPanel:getChildByName(string.format("Label_HeroName_%d",i)):setVisible(true) 
			enemyInfoPanel:getChildByName(string.format("Label_HeroName_%d",i)):setString(getDictionaryText(enemyNameId))
			--enemyInfoPanel:getChildByName("Image_Zhanli"):setVisible(true) 
			--enemyInfoPanel:getChildByName("Image_Zhanli"):getChildByName("Label_Zhanli"):setString(tostring(enemyInfo.mCombat))
			--heroInfoPanel:getChildByName("Label_Zhanli"):setString(heroInfo.mCombat)

			enemyPanel:removeAllChildren()
			enemyPanel:addChild(heroWidget)
		end
	elseif window and window.mName == "GangWarsWindow" then
		heroContainer:getChildByName("Panel_Hero2_Bg"):setVisible(false)
		heroContainer:getChildByName("Panel_Hero3_Bg"):setVisible(false) 
	end

	-- 背景适配
	local winSize = cc.Director:getInstance():getVisibleSize()
	local preSize = roleSelWindow:getChildByName("Image_WindowBg"):getContentSize()
	roleSelWindow:getChildByName("Image_WindowBg"):setContentSize(cc.size(winSize.width, preSize.height))

	local battleHeroIdTbl   = heros   	-- 上阵英雄id
	local battleHeroIconTbl = {}       	-- 上阵英雄头像
	local allHeroIdTbl      = {}     	-- 所有英雄id
	local allHeroIconTbl    = {}     	-- 所有英雄头像
	local combatTotal       = 0

	-- 获取阵容上英雄的数量
	local function getBattleHeroCount()
		local cnt = 0
		for i = 1, #battleHeroIdTbl do
			if 0 ~= battleHeroIdTbl[i] then
				cnt = cnt + 1
			end
		end
		return cnt
	end

	local function showHeroRelationShip()
		local rootWidget = GUIWidgetPool:createWidget("Hero_GroupCircle")
		registerWidgetPushDownEvent(rootWidget, function() rootWidget:removeFromParent(true) end)
		roleSelWindow:addChild(rootWidget)
	end
	registerWidgetReleaseUpEvent(roleSelWindow:getChildByName("Button_GroupCircle"), showHeroRelationShip)

	-- 显示英雄名字
	local function showBattleHeroName()
		local combat = 0 
		for i = 1, #battleHeroIdTbl do
			local lblWidget = heroContainer:getChildByName("Panel_Hero"..tostring(i).."_Bg"):getChildByName("Label_HeroName_"..tostring(i))
			if 0 == battleHeroIdTbl[i] then -- 没有英雄
				lblWidget:setVisible(false)
			else -- 有英雄 
				lblWidget:setVisible(true)
				-- 名字
				local heroData = DB_HeroConfig.getDataById(battleHeroIdTbl[i])
				local heroNameId = heroData.Name
				lblWidget:setString(getDictionaryText(heroNameId))
								-- 战力
				local heroObj = globaldata:findHeroById(battleHeroIdTbl[i])
				combat = combat + heroObj.combat
			end
		end

		combatTotal = combat
		roleSelWindow:getChildByName("Panel_TotalZhanli"):setVisible(true)
		roleSelWindow:getChildByName("Label_TotalZhanli"):setString(tostring(combat))
		roleSelWindow:getChildByName("Label_TotalZhanli"):setVisible(true)
	end

	--显示血条
	local function visibleBlood(widget)
		if window == nil then return end
		if window.mName == "TowerWindow" then
			local hpInfo = window:GetHpInfoById(widget:getTag())
			widget:getChildByName("Image_HeroBlood_Bg"):setVisible(true)
			widget:getChildByName("ProgressBar_HeroBlood"):setPercent(hpInfo.curHp / hpInfo.totalHp * 100)
			widget:getChildByName("Image_HeroDead"):setVisible(hpInfo.curHp == 0)
		end
	end

	-- 让英雄下阵
	local function sendHeroBack(widget)
		-- 去掉阵上英雄
		local heroId = widget:getTag()
		-- 去掉阵上id和控件
		for i = 1, #battleHeroIdTbl do
			if battleHeroIdTbl[i] == heroId then
				battleHeroIdTbl[i] = 0
				battleHeroIconTbl[i]:removeFromParent(true)
				battleHeroIconTbl[i] = nil

				heroContainer:getChildByName(string.format("Panel_Hero%d_Bg",i)):getChildByName("Image_HeroBlood_Bg"):setVisible(false)
				-- 播放特效
				local animNode = AnimManager:createAnimNode(8001)
				heroContainer:getChildByName("Panel_Hero_"..tostring(i)):addChild(animNode:getRootNode(), 100)
				animNode:setPosition(cc.p(45, 32))
				animNode:play("fightteam_cell_chose2")
			end
		end
		for i = 1, #allHeroIdTbl do
			if allHeroIdTbl[i] == heroId then
				allHeroIconTbl[i]:getChildByName("Image_HeroChosen"):setVisible(false)
				allHeroIconTbl[i]:getChildByName("Label_HeroName"):setColor(G_COLOR_C3B.WHITE)
				-- 播放特效
				animNode = AnimManager:createAnimNode(8001)
				allHeroIconTbl[i]:getChildByName("Panel_Animation"):addChild(animNode:getRootNode(), 100)
				animNode:play("fightteam_cell_chose2")
			end
		end
		showBattleHeroName()
	end

	-- 判断英雄是否在阵上
	local function isHeroInBattle(id)
		for i = 1, #battleHeroIdTbl do
			if id == battleHeroIdTbl[i] then
				return true
			end
		end
		return false
	end

	-- 送英雄上阵
	local function sendHeroToBattle(widget)
		local heroId = widget:getTag()

		if window and window.mName == "TowerWindow" then 
			if window:GetHpInfoById(heroId).curHp == 0 then
				return 
			end 
		end

		if not isHeroInBattle(heroId) then
			if window and window.mName == "GangWarsWindow" then
				if getBattleHeroCount() >= 1 then return end
			else
				if getBattleHeroCount() >= 3 then return end
			end

			for i = 1, #battleHeroIdTbl do
				if 0 == battleHeroIdTbl[i] then -- 此处是空位
					-- 记住id
					battleHeroIdTbl[i] = heroId
					-- 创建控件
					local heroObj = globaldata:findHeroById(heroId)
					local heroPanel = heroContainer:getChildByName(string.format("Panel_Hero%d_Bg",i))
					heroPanel:setTag(heroId)

					battleHeroIconTbl[i] = createHeroIcon(heroObj.id, heroObj.level, heroObj.quality, heroObj.advanceLevel)
					battleHeroIconTbl[i]:setTouchEnabled(true)

					heroPanel:getChildByName("Panel_Hero_"..tostring(i)):setTag(heroId)
					heroPanel:getChildByName("Panel_Hero_"..tostring(i)):addChild(battleHeroIconTbl[i])

					visibleBlood(heroPanel)

					registerWidgetReleaseUpEvent(battleHeroIconTbl[i], sendHeroBack)
					-- 播放特效
					local animNode = AnimManager:createAnimNode(8001)
					heroPanel:getChildByName("Panel_Hero_"..tostring(i)):addChild(animNode:getRootNode(), 100)
					animNode:setPosition(cc.p(45, 32))
					animNode:play("fightteam_cell_chose1")
					-- 原来控件设置上阵
					widget:getChildByName("Image_HeroChosen"):setVisible(true)
					widget:getChildByName("Label_HeroName"):setColor(cc.c3b(255, 245, 84))
					showBattleHeroName()
					-- 播放特效
					animNode = AnimManager:createAnimNode(8001)
					widget:getChildByName("Panel_Animation"):addChild(animNode:getRootNode(), 100)
					animNode:play("fightteam_cell_chose2")
					return 
				end
			end
		else
			sendHeroBack(widget)
		end	
	end

	local iconCnt = 0
	-- 载入所有英雄
	local function loadAllHero()
		if window and window.mName == "TowerWindow" then
			towerHeroTeam = window:GetTowerHeroTeam()
			for i=1,#towerHeroTeam do
				table.insert(allHeroIdTbl, towerHeroTeam[i])
			end
		else
			for k, v in pairs(globaldata.heroTeam) do
				table.insert(allHeroIdTbl, v.id)
			end
		end

		-- 根据战力排序
		table.sort(allHeroIdTbl, function(id1,id2) return globaldata:findHeroById(id1).combat > globaldata:findHeroById(id2).combat end)	

		for i = 1, #allHeroIdTbl do
			local heroObj = globaldata:findHeroById(allHeroIdTbl[i])
			iconCnt = iconCnt + 1
			allHeroIconTbl[iconCnt] = GUIWidgetPool:createWidget("PVE_FightTeamCell")
			allHeroIconTbl[iconCnt]:getChildByName("Panel_HeroIcon"):addChild(createHeroIcon(heroObj.id, heroObj.level, heroObj.quality, heroObj.advanceLevel))
			allHeroIconTbl[iconCnt]:setTouchEnabled(true)
			allHeroIconTbl[iconCnt]:setTag(heroObj.id)

			visibleBlood(allHeroIconTbl[iconCnt])

			roleSelWindow:getChildByName("ListView_heroList"):pushBackCustomItem(allHeroIconTbl[iconCnt])
			registerWidgetReleaseUpEvent(allHeroIconTbl[iconCnt], sendHeroToBattle)
			-- 名字
			local heroData = DB_HeroConfig.getDataById(heroObj.id)
			local heroNameId = heroData.Name
			allHeroIconTbl[iconCnt]:getChildByName("Label_HeroName"):setString(getDictionaryText(heroNameId))
		end

		showBattleHeroName()
	end
	loadAllHero()

	-- 默认上阵
	local function xxx()
		for i = 1, #battleHeroIdTbl do
			local heroId = battleHeroIdTbl[i]
			if 0 ~= heroId then
				for j = 1, #allHeroIdTbl do
					if heroId == allHeroIdTbl[j] then
						-- 创建控件
						local heroObj = globaldata:findHeroById(heroId)
						local heroPanel = heroContainer:getChildByName(string.format("Panel_Hero%d_Bg",i))
						heroPanel:setTag(heroId)

						battleHeroIconTbl[i] = createHeroIcon(heroObj.id, heroObj.level, heroObj.quality, heroObj.advanceLevel)
						battleHeroIconTbl[i]:setTouchEnabled(true)

						heroPanel:getChildByName("Panel_Hero_"..tostring(i)):setTag(heroId)
						heroPanel:getChildByName("Panel_Hero_"..tostring(i)):addChild(battleHeroIconTbl[i])

						visibleBlood(heroPanel)

						registerWidgetReleaseUpEvent(battleHeroIconTbl[i], sendHeroBack)
						-- 原来控件设置上阵
						allHeroIconTbl[j]:getChildByName("Image_HeroChosen"):setVisible(true)
						allHeroIconTbl[j]:getChildByName("Label_HeroName"):setColor(cc.c3b(255, 245, 84))
					end
				end
			end
		end
	end
	xxx()

	local function closeRoleSelWindow()
		EventSystem:PushEvent(Event.GUISYSTEM_EABLEDRAW_BLACKMARKETWINDOW)
		EventSystem:PushEvent(Event.GUISYSTEM_EABLEDRAW_TOWEREXWINDOW)
		EventSystem:PushEvent(Event.GUISYSTEM_EABLEDRAW_WORLDBOSSWINDOW)
		EventSystem:PushEvent(Event.GUISYSTEM_EABLEDRAW_WEALTHWINDOW)
		EventSystem:PushEvent(Event.GUISYSTEM_EABLEDRAW_GANGWARSWINDOW)
		EventSystem:PushEvent(Event.GUISYSTEM_EABLEDRAW_TOWERWINDOW)
		--
		roleSelWindow:removeFromParent(true)
		roleSelWindow = nil
	end

	registerWidgetReleaseUpEvent(roleSelWindow:getChildByName("Button_Cancel"), closeRoleSelWindow)
	registerWidgetReleaseUpEvent(roleSelWindow:getChildByName("Button_Fight"), 
	function()
		if getBattleHeroCount() < limitCnt then MessageBox:showMessageBox1(string.format("需%d人出战才可挑战!",limitCnt)) return end

		if argc == 3 then 			--wealth
			if combatTotal < argv[3] then
				MessageBox:showMessageBox2("上阵学员战力不足推荐战力，是否开战？",
				function() func(argv[1],argv[2],battleHeroIdTbl) closeRoleSelWindow() end,function() end )
			else
				func(argv[1],argv[2],battleHeroIdTbl)
				closeRoleSelWindow()
			end	
		else  					    --otherwise   			
			func(battleHeroIdTbl)		
			closeRoleSelWindow()
		end
	end)
end

function wndJump(jumpType,parmTbl)
	local funcTbl = {	[1] = function() GUISystem:goTo("pve",parmTbl[1],parmTbl[2]) end,
						[2] = function() GUISystem:goTo("pve",parmTbl[1],nil) end,
						[3] = function() GUISystem:goTo("hero",parmTbl[1]) end,
						[4] = function() GUISystem:goTo("arena") end,
						[5] = function() GUISystem:goTo("shangcheng",parmTbl[1]) end,
						[6] = function() GUISystem:goTo("equip",parmTbl[1]) end,
						[7] = function() GUISystem:goTo("lottery") end,
						[8] = function() GUISystem:goTo("goldenfinger") end,
						[9] = function()  end,
						[10] = function() end,
						[11] = function() GUISystem:goTo("tower") end,
						[12] = function()  end,
						[13] = function() GUISystem:goTo("friend") end,
						[14] = function() GUISystem:goTo("blackmarket") end,
						[15] = function() GUISystem:goTo("technology") end,
						[16] = function() GUISystem:goTo("ladder") end,
						[17] = function() GUISystem:goTo("wealth") end,
						[18] = function() GUISystem:goTo("towerex") end,
						[19] = function() GUISystem:goTo("worldboss") end,
						[20] = function() GUISystem:goTo("task") end,
						[21] = function() GUISystem:goTo("blackmarket",parmTbl[1] == BMTYPE.GUARD and nil or {"jump",function() end}) end,
						[22] = function() GUISystem:goTo("skill") end,
						[23] = function() GUISystem:goTo("herobeautify") end,
						[24] = function() GUISystem:goTo("herotitle") end,
						[25] = function() GUISystem:goTo("horsegun",parmTbl[1]) end,
						[26] = function() GUISystem:goTo("badge") end,
					}
	funcTbl[jumpType]()
end

-- 创建时装物品项
function createFashionItemWidget(itemId, iconId)
	local widget = GUIWidgetPool:createWidget("MountsGuns_Icon")
	local itemData = DB_FashionEquip.getDataById(itemId)
	
	-- 换品质图片
	local quality = itemData.Quality
	widget:getChildByName("Image_Quality"):loadTexture("icon_item_quality"..tostring(quality)..".png",1)
	widget:getChildByName("Image_Quality_Bg"):loadTexture("icon_item_quality_bg"..tostring(quality)..".png",1)

	-- 换物品图片
	local imgName = DB_ResourceList.getDataById(iconId).Res_path1
	widget:getChildByName("Image_Icon"):loadTexture(imgName, 1)	
	widget:getChildByName("Image_Icon"):setVisible(true)
	
	return widget
end

-- 创建以UIWidget为根节点的控件
function createHolyshitWidget()
	local rootWidget = ccui.Widget:create()
	rootWidget:setContentSize(cc.size(80, 80))

	-- Label_Count_Stroke
	local Label_Count_Stroke = ccui.Text:create("00", "font_3.ttf", 23)
	Label_Count_Stroke:ignoreContentAdaptWithSize(false)
	Label_Count_Stroke:setContentSize(cc.size(60, 30))
	rootWidget:addChild(Label_Count_Stroke, 35)
	Label_Count_Stroke:setPosition(cc.p(45, 15))

	-- Image_Quality
	local Image_Quality = ccui.ImageView:create("public_gold.png")
	rootWidget:addChild(Image_Quality, 30)
	Image_Quality:setPosition(cc.p(40, 40))

	-- Image_Quality_Bg
	local Image_Quality_Bg = ccui.ImageView:create("public_gold.png")
	rootWidget:addChild(Image_Quality_Bg, 0)
	Image_Quality_Bg:setPosition(cc.p(40, 40))

	-- Image_Item
	local Image_Item = ccui.ImageView:create("public_gold.png")
	rootWidget:addChild(Image_Item, 5)
	Image_Item:setPosition(cc.p(40, 40))

	-- Panel_HeroStar
	local Panel_HeroStar = ccui.Widget:create()
	Panel_HeroStar:setContentSize(cc.size(86, 20))
	Panel_HeroStar:setAnchorPoint(cc.p(0, 0))
	rootWidget:addChild(Panel_HeroStar, 14)
	Panel_HeroStar:setPosition(cc.p(-3, -2))

	-- Image_Star_1
	local Image_Star_1 = ccui.ImageView:create("public_star1.png")
	Panel_HeroStar:addChild(Image_Star_1)
	Image_Star_1:setPosition(cc.p(8, 10))
	Image_Star_1:ignoreContentAdaptWithSize(false)
	Image_Star_1:setContentSize(cc.size(16, 16))

	-- Image_Star_2
	local Image_Star_2 = ccui.ImageView:create("public_star1.png")
	Panel_HeroStar:addChild(Image_Star_2)
	Image_Star_2:setPosition(cc.p(22, 10))
	Image_Star_2:ignoreContentAdaptWithSize(false)
	Image_Star_2:setContentSize(cc.size(16, 16))

	-- Image_Star_3
	local Image_Star_3 = ccui.ImageView:create("public_star1.png")
	Panel_HeroStar:addChild(Image_Star_3)
	Image_Star_3:setPosition(cc.p(36, 10))
	Image_Star_3:ignoreContentAdaptWithSize(false)
	Image_Star_3:setContentSize(cc.size(16, 16))

	-- Image_Star_4
	local Image_Star_4 = ccui.ImageView:create("public_star1.png")
	Panel_HeroStar:addChild(Image_Star_4)
	Image_Star_4:setPosition(cc.p(50, 10))
	Image_Star_4:ignoreContentAdaptWithSize(false)
	Image_Star_4:setContentSize(cc.size(16, 16))

	-- Image_Star_5
	local Image_Star_5 = ccui.ImageView:create("public_star1.png")
	Panel_HeroStar:addChild(Image_Star_5)
	Image_Star_5:setPosition(cc.p(64, 10))
	Image_Star_5:ignoreContentAdaptWithSize(false)
	Image_Star_5:setContentSize(cc.size(16, 16))

	-- Image_Star_6
	local Image_Star_6 = ccui.ImageView:create("public_star1.png")
	Panel_HeroStar:addChild(Image_Star_6)
	Image_Star_6:setPosition(cc.p(78, 10))
	Image_Star_6:ignoreContentAdaptWithSize(false)
	Image_Star_6:setContentSize(cc.size(16, 16))
	

	return rootWidget
end