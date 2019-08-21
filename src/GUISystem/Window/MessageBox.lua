-- Name: 	MessageBox
-- Func：	MessageBox
-- Author:	WangShengdong
-- Data:	14-12-1

MessageBox = {}
MessageBox.mMessageBox4Layer = nil

-- 显示类型1的消息对话框(无按钮)
function MessageBox:showMessageBox1(text)
	local rootWidget = GUIWidgetPool:createWidget("MessageBox_1")
	local msgWidget = rootWidget:getChildByName("Image_messagebg")
	msgWidget:setOpacity(0)

	-- 更新文字
	local function updateText()
		local labelWidget = rootWidget:getChildByName("Label_messageText")
		labelWidget:setString(text)
	end
	updateText()

	-- 清理
	local function doCleanup()
		rootWidget:removeFromParent(true)
	end

	-- 做动作
	local function doAction()
		local act0 = cc.MoveBy:create(0.3, cc.p(0, 100))
		local act1 = cc.FadeIn:create(0.3)
		local act2 = cc.DelayTime:create(1.1)
		local act3 = cc.MoveBy:create(0.3, cc.p(0, 200))
		local act4 = cc.FadeOut:create(0.3)
		local act5 = cc.CallFunc:create(doCleanup)
		msgWidget:runAction(cc.Sequence:create( cc.Spawn:create(act0, act1), act2, cc.Spawn:create(act3, act4), act5 ))	
	end 
	doAction()

	GUISystem.RootNode:addChild(rootWidget, GUISYS_ZORDER_MESSAGEBOXWINDOW)
end

-- 显示类型2的消息对话框(有确定和取消按钮)
function MessageBox:showMessageBox2(text, funcOk, funcCancel, okBtnText, cancelBtnText)
	local rootWidget = GUIWidgetPool:createWidget("MessageBox_2")
	-- 更新文字
	--local function updateText()
	local labelWidget = rootWidget:getChildByName("Panel_Message")
	--end
	--updateText()
	print(text)
	richTextCreate(labelWidget,text,true)
	-- Ok
	local function doOk(widget)
		rootWidget:removeFromParent(true)
		if funcOk then
			funcOk()
		end
	end
	registerWidgetReleaseUpEvent(rootWidget:getChildByName("Button_Ok"), doOk)

	-- Cancel
	local function doCancel(widget)
		rootWidget:removeFromParent(true)
		if funcCancel then
			funcCancel()
		end
	end
	registerWidgetReleaseUpEvent(rootWidget:getChildByName("Button_Cancel"), doCancel)

	if okBtnText then
		rootWidget:getChildByName("Button_Ok"):setTitleText(okBtnText)
	end

	if cancelBtnText then
		rootWidget:getChildByName("Button_Cancel"):setTitleText(cancelBtnText)
	end

	GUISystem.RootNode:addChild(rootWidget, GUISYS_ZORDER_MESSAGEBOXWINDOW)
end

-- 显示类型3的消息对话框(只有确定按钮)
function MessageBox:showMessageBox3(text, funcOk)
	local rootWidget = GUIWidgetPool:createWidget("MessageBox_3")
	-- 更新文字
	local function updateText()
		local labelWidget = rootWidget:getChildByName("Label_Message")
		labelWidget:setString(text)
	end
	updateText()

	-- Ok
	local function doOk(widget)
		rootWidget:removeFromParent(true)
		if funcOk then
			funcOk()
		end
	end
	registerWidgetReleaseUpEvent(rootWidget:getChildByName("Button_Ok"), doOk)

	GUISystem.RootNode:addChild(rootWidget, GUISYS_ZORDER_MESSAGEBOXWINDOW)
end

-- 显示类型4的消息对话框(有很多物品)

local RewardItemTv = {}

function RewardItemTv:new(itemList,listType)
	local o = 
	{
		mItemList		  = itemList,
		mRootNode 	      =	nil,
		mType 		      =	listType,
		mTableView	      =	nil,
		mCellSize		  = nil,
	}
	o = newObject(o, RewardItemTv)
	return o
end

function RewardItemTv:Destroy()
	self.mRootNode:removeFromParent(true)
	self.mRootNode   = nil
	self.mTableView  = nil
	self.mItemList   = nil
	self.mCellSize	 = nil
end

function RewardItemTv:init(rootNode)
	self.mRootNode = rootNode
	-- 初始化数据源
	self:initTableView()
end

function RewardItemTv:initTableView()
	self.mTableView = TableViewEx:new()

	local widget = GUIWidgetPool:createWidget("ItemWidget")
	self.mCellSize = widget:getContentSize()

	local width = self.mRootNode:getContentSize().width

	self.mTableView:setCellSize(cc.size(width,self.mCellSize.height))

	self.mTableView:setCellCount(#self.mItemList/5 + 1)

	self.mTableView:registerTableCellAtIndexFunc(handler(self, self.tableCellAtIndex))
	self.mTableView:registerTableCellTouchedFunc(handler(self, self.tableCellTouched))

	self.mTableView:init(self.mRootNode:getContentSize(), cc.p(0,0), 1)
	self.mRootNode:addChild(self.mTableView:getRootNode())
end

function RewardItemTv:tableCellAtIndex(table, index)
	local cell = table:dequeueCell()
	local section = nil

	if nil == cell then
		cell = cc.TableViewCell:new()

		section = self:CreateSection(index)
		section:setTag(1)

		cell:addChild(section)
	else
		section = cell:getChildByTag(1)	
	end
	
	self:setCellLayOut(section,index)

	return cell
end

function RewardItemTv:CreateSection(index)
	local layer = cc.Layer:create()
	layer:setContentSize(cc.size(self.mRootNode:getContentSize().width,self.mCellSize.height))
	layer:setTouchEnabled(false)

	for i=1,5 do
		if self.mItemList[index*5+i] ~= nil then
			local itemType =  self.mItemList[index*5+i][1]
			local itemId   =  self.mItemList[index*5+i][2]
			local itemCnt  =  self.mItemList[index*5+i][3]

			local widget = createCommonWidget(itemType, itemId, itemCnt)
			widget:setTouchSwallowed(false)
			widget:setTouchEnabled(true)
			widget:setPositionX((self.mCellSize.width + 10)*(i-1))
			widget:setTag(i)
			--MessageBox:setTouchShowInfo(widget,itemType,itemId)
			layer:addChild(widget)
		end
	end

	return layer
end

function RewardItemTv:setCellLayOut(section,index)
	for i=1,5 do
		local function setChildLayout(itemInfo,item)
			if itemInfo == nil then return end
			local itemType = itemInfo[1]
			local itemId   = itemInfo[2]
			local itemCnt  = itemInfo[3]

			if itemType == 0 then 
				createItemWidget(itemId,itemCnt,item)
			elseif itemType == 1 then
				self:createEquipWidget(itemId, 1,itemCnt,item)
			elseif itemType == 2 then
				if item == nil then item = GUIWidgetPool:createWidget("ItemWidget") end 
--				item:getChildByName("Image_Piece"):setVisible(false)
				item:getChildByName("Panel_HeroIcon"):setVisible(false)
				item:getChildByName("Image_Quality"):setVisible(true)
				item:getChildByName("Image_Item"):loadTexture("item_gold.png",1)
				item:getChildByName("Image_Item"):setVisible(true)
				item:getChildByName("Label_Count_Stroke"):setVisible(true)
				item:getChildByName("Label_Count_Stroke"):setString(tostring(itemCnt))
			elseif itemType == 3 then 
				if item == nil then item = GUIWidgetPool:createWidget("ItemWidget") end 
--				item:getChildByName("Image_Piece"):setVisible(false)
				item:getChildByName("Panel_HeroIcon"):setVisible(false)
				item:getChildByName("Image_Quality"):setVisible(true)
				item:getChildByName("Image_Item"):loadTexture("item_diamond.png",1)
				item:getChildByName("Image_Item"):setVisible(true)
				item:getChildByName("Label_Count_Stroke"):setVisible(true)
				item:getChildByName("Label_Count_Stroke"):setString(tostring(itemCnt))
			elseif itemType == 4 then 
				if item == nil then item = GUIWidgetPool:createWidget("ItemWidget") end 
--				item:getChildByName("Image_Piece"):setVisible(false)
				item:getChildByName("Panel_HeroIcon"):setVisible(false)
				item:getChildByName("Image_Quality"):setVisible(true)
				item:getChildByName("Image_Item"):loadTexture("item_exp.png",1)
				item:getChildByName("Image_Item"):setVisible(true)
				item:getChildByName("Label_Count_Stroke"):setVisible(true)
				item:getChildByName("Label_Count_Stroke"):setString(tostring(itemCnt))
			elseif itemType == 5 then 
				if item == nil then item = GUIWidgetPool:createWidget("ItemWidget") end 
--				item:getChildByName("Image_Piece"):setVisible(false)
				item:getChildByName("Panel_HeroIcon"):setVisible(false)
				item:getChildByName("Image_Quality"):setVisible(false)
				item:getChildByName("Image_Item"):loadTexture("public_energy.png")
				item:getChildByName("Image_Item"):setVisible(true)
			elseif itemType == 6 then 
				if item == nil then item = GUIWidgetPool:createWidget("ItemWidget") end 
--				item:getChildByName("Image_Piece"):setVisible(false)
				item:getChildByName("Panel_HeroIcon"):setVisible(false)
				item:getChildByName("Image_Quality"):setVisible(false)
				item:getChildByName("Image_Item"):loadTexture("public_currency_arena.png")
				item:getChildByName("Image_Item"):setVisible(true)
			elseif itemType == 8 then 
				self:createDiamondWidget(itemId, itemCnt, item)
			elseif itemType == 10 then
				createHeroIcon(itemId, itemCnt,item)
			end  
		end

		setChildLayout(self.mItemList[index*5+i],section:getChildByTag(i))
	end
end

function RewardItemTv:tableCellTouched(table,cell)
	print("RewardItemTv cell touched at index: " .. cell:getIdx())
end

function RewardItemTv:UpdateTableView(cellCnt) --move table to cur cell after reload
	self.mTableView:setCellCount(cellCnt)

	--local curOffset = self.mTableView.mInnerContainer:getContentOffset()
	--local curHeight = self.mTableView.mInnerContainer:getContentSize().height
	self.mTableView:reloadData()
	--self.mTableView.mInnerContainer:setContentOffset(cc.p(0,self.mTableView.mInnerContainer:getViewSize().height - self.mTableView.mInnerContainer:getContentSize().height))
	--local height = self.mTableView.mInnerContainer:getContentSize().height
	--curOffset.y = curOffset.y + (curHeight - height)
	--self.mTableView.mInnerContainer:setContentOffset(curOffset)
end

function RewardItemTv:createEquipWidget(id, equipQuality,wgtCount,srcWidget)
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
	rootWidget:getChildByName("Image_Quality"):loadTexture("icon_item_quality"..tostring(equipQuality)..".png", 1)

	rootWidget:setTouchEnabled(true)

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

function RewardItemTv:createDiamondWidget(id, count, srcWidget)
	local resultWidget = nil

	if srcWidget == nil then  
		resultWidget = GUIWidgetPool:createWidget("ItemWidget")
	else
		resultWidget = srcWidget
	end

	local diamondData = DB_Diamond.getDataById(id)
	local diamondIconId = diamondData.Icon

	-- 换品质图片
	local quality = diamondData.Quality
	resultWidget:getChildByName("Image_Quality"):loadTexture("icon_item_quality"..tostring(quality)..".png", 1)
	resultWidget:getChildByName("Image_Quality"):setVisible(false)
	-- 换物品图片
	local imgName = DB_ResourceList.getDataById(diamondIconId).Res_path1
	resultWidget:getChildByName("Image_Item"):loadTexture(imgName, 1)
	-- 显示数量
	if count > 1 then
		resultWidget:getChildByName("Label_Count_Stroke"):setVisible(true)
		resultWidget:getChildByName("Label_Count_Stroke"):setString(tostring(count))
	end

	resultWidget:getChildByName("Image_Quality"):setVisible(true)

	return resultWidget
end

-- example
-- local itemList = {}
-- itemList[1] = {1,10001,8}
-- itemList[2] = {0,20299,7}
-- itemList[3] = {0,20005,6}
-- MessageBox:showMessageBox4(itemList,false)

function MessageBox:showMessageBox4(itemList, forDailyReward)
	local rootWidget = GUIWidgetPool:createWidget("MessageBox_4")
	-- 更新物品
	local function updateItem()
		local listWidget = rootWidget:getChildByName("ListView_Reward")
		local newWidth = listWidget:getContentSize().width
		local newHeight = GUIWidgetPool:createWidget("ItemWidget"):getContentSize().height
		local itemWidth = nil
		for i = 1, #itemList, 5 do
			local function createBigWidget(index)
				--local bigWidget = GUIWidgetPool:createWidget("MessageBox_4_Item")
				--itemWidth = bigWidget:getContentSize().width
				-- 数量
				--bigWidget:getChildByName("Label_Count"):setString("x "..tostring(itemList[index][3]))
				-- 名字
				--bigWidget:getChildByName("Label_Name"):setString(getCommonName(itemList[index][1], itemList[index][2]))
				-- 物品
				local itemWidget = createCommonWidget(itemList[index][1], itemList[index][2], itemList[index][3])
				itemWidth = itemWidget:getContentSize().width
				--itemWidget:getChildByName("Label_Count"):setVisible(false)
				--bigWidget:getChildByName("Panel_Item"):addChild(itemWidget)
				return itemWidget
			end

			local widget1 = createBigWidget(i)
			local widget2 = nil
			local widget3 = nil
			local widget4 = nil
			local widget5 = nil

			if i+1 <= #itemList then
				widget2 = createBigWidget(i+1)
			end

			if i+2 <= #itemList then
				widget3 = createBigWidget(i+2)
			end

			if i+3 <= #itemList then
				widget4 = createBigWidget(i+3)
			end

			if i+4 <= #itemList then
				widget5 = createBigWidget(i+4)
			end

			local layout = ccui.Layout:create()
		    layout:setContentSize(cc.size(newWidth, newHeight))
		    layout:addChild(widget1)
		    if widget2 then
		    	layout:addChild(widget2)
		    	widget2:setPositionX(itemWidth + 10)
		    end

		    if widget3 then
		    	layout:addChild(widget3)
		    	widget3:setPositionX((itemWidth + 10)*2)
		    end

		    if widget4 then
		    	layout:addChild(widget4)
		    	widget4:setPositionX((itemWidth + 10)*3)
		    end

		    if widget5 then
		    	layout:addChild(widget5)
		    	widget5:setPositionX((itemWidth + 10)*4)
		    end

			listWidget:pushBackCustomItem(layout)
		end
		listWidget:setVisible(true)
		rootWidget:getChildByName("Panel_Schedule"):setVisible(false)
	end

	local itemListTv = nil
	local tvPanel = rootWidget:getChildByName("Panel_TV")
	if forDailyReward then
		local itemCnt = itemList[3] 

		local item = createCommonWidget(itemList[1], itemList[2], itemCnt)
		item:getChildByName("Label_Count_Stroke"):setVisible(false)
		local nameStr  =  getCommonName(itemList[1], itemList[2])

		rootWidget:getChildByName("Label_Name_Num"):setString(string.format("%sx%d",nameStr,itemCnt))
		rootWidget:getChildByName("Panel_Item"):addChild(item)
		rootWidget:getChildByName("Panel_Schedule"):setVisible(true)
		if itemList[4] ~= 9999 then  
			rootWidget:getChildByName("Label_VIP"):setString(string.format("VIP %d 可领取双倍",itemList[4]))
			rootWidget:getChildByName("Label_VIP"):setVisible(true)
		else
			rootWidget:getChildByName("Label_VIP"):setVisible(false)
		end

		tvPanel:setVisible(false)
	else
		rootWidget:getChildByName("Panel_Schedule"):setVisible(false)
		itemListTv = RewardItemTv:new(itemList,0)
		itemListTv:init(tvPanel)
		tvPanel:setVisible(true)
	end

	-- 清理
	local function doCleanup()
		rootWidget:removeFromParent(true)
		rootWidget = nil
		self.mMessageBox4Layer = nil
	end
	registerWidgetReleaseUpEvent(rootWidget, doCleanup)
	registerWidgetReleaseUpEvent(rootWidget:getChildByName("Button_Close"), doCleanup)

	GUISystem.RootNode:addChild(rootWidget, 100)
	self.mMessageBox4Layer = rootWidget
end

-- 显示类型5的消息对话框(有物品有按钮)
function MessageBox:showMessageBox5(rewardId, rewardIndex, itemList, level)
	local rootWidget = GUIWidgetPool:createWidget("MessageBox_5")
	-- 更新物品
	local function updateItem()
		-- 隐藏
		for i = 1, 4 do
			rootWidget:getChildByName("Panel_Reward_"..i):setVisible(false)
		end
		-- 添加
		for i = 1, #itemList do
			local widget = createCommonWidget(itemList[i][1], itemList[i][2], itemList[i][3])
			rootWidget:getChildByName("Panel_Reward_"..i):setVisible(true)
			rootWidget:getChildByName("Panel_Reward_"..i):addChild(widget)
		end
	end
	updateItem()

	-- 清理
	local function doCleanup()
		GUIEventManager:pushEvent("starRewardGot")
		rootWidget:removeFromParent(true)
	end
	registerWidgetReleaseUpEvent(rootWidget:getChildByName("Button_Close"), doCleanup)

	-- 请求领取
	local function requestGet()
		local packet = NetSystem.mNetManager:GetSPacket()
		packet:SetType(PacketTyper._PTYPE_CS_STARREWARD_GET_)
		packet:PushChar(level)
		packet:PushInt(rewardId) 	-- 关卡级别
		packet:PushChar(rewardIndex) 	-- 关卡级别
		packet:Send()
		doCleanup()
	end
	registerWidgetReleaseUpEvent(rootWidget:getChildByName("Button_Get"), requestGet)

	GUISystem.RootNode:addChild(rootWidget, 100)
end

-- 显示类型6的消息对话框(有物品无按钮)
function MessageBox:showMessageBox6(itemList)
	local rootWidget = GUIWidgetPool:createWidget("MessageBox_6")
	-- 更新物品
	local function updateItem()
		-- 隐藏
		for i = 1, 4 do
			rootWidget:getChildByName("Panel_Reward_"..i):setVisible(false)
		end
		-- 添加
		for i = 1, #itemList do
			local widget = createCommonWidget(itemList[i][1], itemList[i][2], itemList[i][3])
			rootWidget:getChildByName("Panel_Reward_"..i):setVisible(true)
			rootWidget:getChildByName("Panel_Reward_"..i):addChild(widget)
		end
	end
	updateItem()

	-- 清理
	local function doCleanup()
		GUIEventManager:pushEvent("starRewardGot")
		rootWidget:removeFromParent(true)
	end
	registerWidgetReleaseUpEvent(rootWidget, doCleanup)

	GUISystem.RootNode:addChild(rootWidget, 100)
end

-- 显示7类型的消息对话框(只有物品)
function MessageBox:showMessageBox7(itemList)
	local rootWidget = GUIWidgetPool:createWidget("MessageBox_7")
	-- 更新物品
	local function updateItem()
		local listWidget = rootWidget:getChildByName("ListView_Item")
		for i = 1, #itemList do
			local widget = createCommonWidget(itemList[i][1], itemList[i][2], itemList[i][3])
			listWidget:pushBackCustomItem(widget)
		end
	end
	updateItem()

	-- 清理
	local function doCleanup()
		rootWidget:removeFromParent(true)
	end
	registerWidgetReleaseUpEvent(rootWidget, doCleanup)

	GUISystem.RootNode:addChild(rootWidget, 100)
end


function MessageBox:setTouchShowInfo(widget,itemType,itemId)
	local infoWnd = nil
	local function onItemTouched(widget, eventType)
		local function delInfoWnd()
			if infoWnd then
				infoWnd:removeFromParent()
				infoWnd = nil
				GUISystem:enableUserInput_MsgBox()
			end
		end

		if eventType == ccui.TouchEventType.began then
			GUISystem:disableUserInput_MsgBox()
        	infoWnd = MessageBox:showMessageBoxInfo(widget,itemType, itemId)
      	elseif eventType == ccui.TouchEventType.ended then
        	delInfoWnd()
      	elseif eventType == ccui.TouchEventType.moved then
        	--delInfoWnd()
      	elseif eventType == ccui.TouchEventType.canceled then
        	delInfoWnd()
      	end
	end


	if itemType == 0 or itemType == 1 or itemType == 8 then 
		widget:addTouchEventListener(onItemTouched)
	end
end

function MessageBox:setTouchShowInfoEx(widget1, widget2, itemType, itemId)
	local infoWnd = nil
	local function onItemTouched(widget1, eventType)
		local function delInfoWnd()
			if infoWnd then
				infoWnd:removeFromParent()
				infoWnd = nil
				GUISystem:enableUserInput()
			end
		end

		if eventType == ccui.TouchEventType.began then
			GUISystem:disableUserInput()
        	infoWnd = MessageBox:showMessageBoxInfo(widget1, itemType, itemId, widget2)
      	elseif eventType == ccui.TouchEventType.ended then
        	delInfoWnd()
      	elseif eventType == ccui.TouchEventType.moved then
        	delInfoWnd()
      	elseif eventType == ccui.TouchEventType.canceled then
        	delInfoWnd()
      	end
	end


	if itemType == 0 or itemType == 1 or itemType == 8 then 
		widget1:addTouchEventListener(onItemTouched)
	end
end


-- 显示物品信息
function MessageBox:showMessageBoxInfo(parentNode, itemType, srcId, showWidget)
	-- 参数说明:
	-- parentNode: 挂载的父节点
	-- isItemOrEquip: ture为Item,false为Equip
	-- srcId: 传入的ID

	local widget = GUIWidgetPool:createWidget("MessageBox_ItemInfo")

	local descStr    = nil
	local nameStr    = nil
	local needLevel  = nil
	local sellPrice  = nil 
	local ownCnt     = 0
	local requireStr = nil 
	
	if itemType == 0 then -- 物品
		local itemData   = DB_ItemConfig.getDataById(srcId)
		local itemNameId = itemData.Name
		local textData   = DB_Text.getDataById(itemNameId)
		local itemDescId = itemData.Description

		nameStr    = textData[GAME_LANGUAGE]
		descStr    = getDictionaryText(itemDescId)
		needLevel  = itemData.UseLevel

		requireStr = string.format("需求等级:%d", needLevel)
		sellPrice  = itemData.Price
		ownCnt     = globaldata:getItemOwnCount(srcId)
	elseif  itemType == 1 then -- 装备
		local equipData = DB_EquipmentConfig.getDataById(srcId)
		local nameId 	= equipData.Name
		local nameData  = DB_Text.getDataById(nameId)
		local descStrID = equipData.EquipText
		local descData	= DB_Text.getDataById(descStrID)

		nameStr   = nameData.Text_CN
		descStr   = descData.Text_CN

		local fashionType =  DB_EquipmentConfig.Type
		local rolelLimit  = equipData.RoleLimit

		local heroNameStr = ""
		local typeStr     = ""

		if fashionType == 7 then 
			typeStr = "枪械"
		elseif fashionType == 8 then 
			typeStr = "时装"
		elseif fashionType == 9 then 
			typeStr = "坐骑"
		end

		if rolelLimit > 0 then 
			local heroData   = DB_HeroConfig.getDataById(rolelLimit)
			local heroNameId = heroData.Name
			local textData   = DB_Text.getDataById(heroNameId)
		    heroNameStr      = textData.Text_CN

		    requireStr       = string.format("%s,该装备只可用于 %s",typeStr,heroNameStr)
		else
			requireStr       = typeStr
		end

		sellPrice = equipData.Price
		ownCnt = 8



	elseif  itemType == 2 then

	elseif  itemType == 3 then

	elseif  itemType == 4 then

	elseif  itemType == 5 then

	elseif  itemType == 6 then

	elseif  itemType == 8 then
		local diamondData   = DB_Diamond.getDataById(srcId)
		local diamondNameId = diamondData.Name
		local descStrID     = diamondData.description
		local nameDate      = DB_Text.getDataById(diamondNameId)
		local descData	    = DB_Text.getDataById(descStrID)
		nameStr   = nameDate.Text_CN
		descStr   = descData.Text_CN
		sellPrice = diamondData.Money
		ownCnt    = globaldata:getItemOwnCount(srcId)
	elseif  itemType == 10 then

	end



	GUISystem.RootNode:addChild(widget, 100)

	-- 名字
	widget:getChildByName("Label_Name"):setString(nameStr)
	-- 拥有数量
	if itemType == 1 then
		widget:getChildByName("Label_SelfHave"):setVisible(false)
	else 
		widget:getChildByName("Label_SelfHave"):setVisible(true)
		widget:getChildByName("Label_SelfHave"):setString(string.format("拥有%d件", ownCnt))
	end
	-- 描述
--	widget:getChildByName("Label_Description"):setString(descStr)
--	local lblWgt = richTextCreate(widget:getChildByName("Panel_Description"), descStr, true)
--	lblWgt:setFontSize(10)
	richTextCreateWithFont(widget:getChildByName("Panel_Description"), descStr, true, 18)

	-- 需求等级
	widget:getChildByName("Label_LevelRequire"):setVisible(true)
	widget:getChildByName("Label_LevelRequire"):setString(requireStr)

	if needLevel == 0 then 
		widget:getChildByName("Label_LevelRequire"):setVisible(false)
	end
	-- 售卖价格
	widget:getChildByName("Label_Cost"):setString(tostring(sellPrice))

	-- 设置大小
	if descStr ~= nil then 
		local textLen = getStringLength(descStr)
		local contentSize = widget:getContentSize()
		if textLen < 18*3 then
			contentSize.height = 135
		elseif textLen > 17*3 and textLen < 35*3 then
			contentSize.height = 165
		elseif textLen > 34*3 and textLen < 52*3 then
			contentSize.height = 190
		end
		widget:setContentSize(contentSize)
		widget:getChildByName("Image_Bg"):setContentSize(contentSize)

		if showWidget then
			local iconNode = showWidget:clone()
			-- iconNode:setScale(3)
			iconNode:setAnchorPoint(0,0)
			iconNode:setTouchEnabled(false)
			iconNode:setContentSize(cc.size(100, 100))
			widget:getChildByName("Panel_ItemIcon"):addChild(iconNode)
			local contentSize = widget:getChildByName("Panel_ItemIcon"):getContentSize()
			iconNode:setPosition(cc.p(contentSize.width/2, contentSize.height/2))

			local labelWidget0 = showWidget:getChildByName("Label_Count_Stroke")
			if labelWidget0 then
				labelWidget0:setVisible(false)
			end
			local labelWidget1 = showWidget:getChildByName("Label_Count")
			if labelWidget1 then
				labelWidget1:setVisible(false)
			end

		else
			-- 图标
			local iconNode = parentNode:clone()
			iconNode:setAnchorPoint(0,0)
			iconNode:setPosition(cc.p(0,0))
			iconNode:setTouchEnabled(false)
			iconNode:getChildByName("Label_Count_Stroke"):setVisible(false)
			widget:getChildByName("Panel_ItemIcon"):addChild(iconNode)
		end


		-- 设置位置 
		local parentNodePos = parentNode:getWorldPosition()
		local parentNodeSize = parentNode:getContentSize()
		local selfNodeSize = widget:getContentSize()
		local newPos = cc.p(parentNodePos.x + parentNodeSize.width/2, parentNodePos.y + parentNodeSize.height/2)

		-- 向右偏移出屏幕
		if newPos.x + selfNodeSize.width > getGoldFightPosition_RD().x then
			newPos.x = newPos.x - selfNodeSize.width
		end

		-- 向上偏移出屏幕
		if newPos.y + selfNodeSize.height  > getGoldFightPosition_RU().y then
			newPos.y = newPos.y - selfNodeSize.height
		end

		widget:setPosition(newPos)
	end

	return widget
end

function MessageBox:showSkillInfo(parentNode, skillObj, heroId)

	local delayTime = 0.2

	local schedulerHandler = nil

	local pushDownTime  = 0 -- 按下时间
	local releaseUpTime = 0 -- 弹起时间

	local infoWnd = nil

	local function delScheduler()
		if schedulerHandler then
			local scheduler = cc.Director:getInstance():getScheduler()
			scheduler:unscheduleScriptEntry(schedulerHandler)
			schedulerHandler = nil
		end
	end

	local function tick()
		releaseUpTime = os.clock()
		if releaseUpTime - pushDownTime > delayTime then
			-- 显示技能信息
			infoWnd = MessageBox:showSkillInfoImpl(parentNode, skillObj, heroId)
			-- 删除定时器
			delScheduler()
		end
	end

	local function onItemTouched(widget, eventType)
		local function delInfoWnd()
			if infoWnd then
				infoWnd:removeFromParent()
				infoWnd = nil
			end
		end

		if eventType == ccui.TouchEventType.began then
			-- 开启定时器
        	local scheduler = cc.Director:getInstance():getScheduler()
        	schedulerHandler = scheduler:scheduleScriptFunc(tick, 0, false)
        	pushDownTime = os.clock()
        	releaseUpTime = 0
      	elseif eventType == ccui.TouchEventType.ended then
        	delInfoWnd()
        	delScheduler()
        	if releaseUpTime - pushDownTime <= 1.5 then
        		if 1 == skillObj.mSkillType then
        			if 2 == skillObj.mSkillIndex or 3 == skillObj.mSkillIndex then -- 普通2和普通3
        				if 0 == skillObj.mSkillSelected then -- 选中
							MessageBox:showMessageBox1("当前技能已经激活")
						elseif 1 == skillObj.mSkillSelected then -- 未选中
							local packet = NetSystem.mNetManager:GetSPacket()
							packet:SetType(PacketTyper._PTYPE_CS_SKILL_SET_SELECTED)
							packet:PushInt(heroId)
							packet:PushInt(skillObj.mSkillId)
							packet:Send()
							globaldata.mSkillAnimTag = true
							GUISystem:showLoading()
						end
        			end
        		end
        	end
      	elseif eventType == ccui.TouchEventType.moved then
        	
      	elseif eventType == ccui.TouchEventType.canceled then
        	delInfoWnd()
        	delScheduler()
      	end
	end

	parentNode:addTouchEventListener(onItemTouched)
end

function MessageBox:showSkillInfoImpl(parentNode, skillObj , heroId)
	local widget = GUIWidgetPool:createWidget("MessageBox_SkillInfo")

	-- 技能类型
	local skillData = DB_SkillEssence.getDataById(skillObj.mSkillId)
	local skillTypeTextId = skillData.DisplayType
	if 1 == skillTypeTextId then
		widget:getChildByName("Label_SkillType"):setString(" ")
	elseif 2 == skillTypeTextId then
		widget:getChildByName("Label_SkillType"):setString("主动技")
	elseif 3 == skillTypeTextId then
		widget:getChildByName("Label_SkillType"):setString("合体技")
	elseif 4 == skillTypeTextId then
		widget:getChildByName("Label_SkillType"):setString("被动技")
	elseif 5 == skillTypeTextId then
		widget:getChildByName("Label_SkillType"):setString("必杀技")
	elseif 6 == skillTypeTextId then
		widget:getChildByName("Label_SkillType"):setString("职业技")
	end

	-- 技能图标
	local skillLogoIconId = skillData.ElementType
	if 1 == skillLogoIconId then
		widget:getChildByName("Image_SkillLogo"):loadTexture("skill_nature_wind.png")
	elseif 2 == skillLogoIconId then
		widget:getChildByName("Image_SkillLogo"):loadTexture("skill_nature_fire.png")
	elseif 3 == skillLogoIconId then
		widget:getChildByName("Image_SkillLogo"):loadTexture("skill_nature_thunder.png")
	elseif 4 == skillLogoIconId then
		widget:getChildByName("Image_SkillLogo"):loadTexture("skill_nature_ice.png")
	elseif 5 == skillLogoIconId then
		widget:getChildByName("Image_SkillLogo"):loadTexture("skill_nature_poison.png")
	end

	-- 技能描述
	local skillDescTextId = skillData.DescText
	local skillDescText = getDictionaryText(skillDescTextId)
	local newText = TextParseManager:parseText(skillDescText, skillObj.mSkillId, skillObj.mSkillLevel, heroId)
--	widget:getChildByName("Label_SkillDes"):setString(newText)
	richTextCreate(widget:getChildByName("Panel_SkillDes"), newText, true)

	-- 技能名称
	local skillNameId = skillData.Name
	local skillNameText = getDictionaryText(skillNameId)
	if -1 ~= skillObj.mSkillLevel then
		local newName = skillNameText.." Lv."..tostring(skillObj.mSkillLevel)
		widget:getChildByName("Label_SkillName"):setString(newName)
	else
		widget:getChildByName("Label_SkillName"):setString(skillNameText)
	end

	-- 位置
	local window = widget:getChildByName("Panel_Window")
	local parentPos = parentNode:getWorldPosition()
	local contentSize = window:getContentSize()
--	parentPos.x = parentPos.x - contentSize.width - 60
--	if parentPos.x < 0  then parentPos.x = 0 end
--	parentPos.y = parentPos.y - contentSize.height/4
	parentPos.y = parentPos.y + contentSize.height/4
	parentPos.x = parentPos.x - contentSize.width/2
	if parentPos.x + contentSize.width > getGoldFightPosition_RD().x then
		parentPos.x = getGoldFightPosition_RD().x - contentSize.width
	end
	window:setPosition(parentPos)
	GUISystem.RootNode:addChild(widget, 100)

	return widget
end

-- 显示获得的物品
function MessageBox:showMessageBox_ItemAlreadyGot(itemList)
	local rootWidget = GUIWidgetPool:createWidget("MessageBox_GetItem")
	local itemCnt = #itemList
	if itemCnt > 6 then

		rootWidget:getChildByName("Panel_Rewards_Odd"):setVisible(false)  -- 奇数隐藏
		rootWidget:getChildByName("Panel_Rewards_Even"):setVisible(false) -- 偶数隐藏
		rootWidget:getChildByName("Panel_Rewards_More"):setVisible(true)  -- 更多显示

		local listWidget = rootWidget:getChildByName("ListView_Rewards_More")
		for i = 1, itemCnt do
			local itemWidget = createCommonWidget(itemList[i][1], itemList[i][2], itemList[i][3])
			listWidget:pushBackCustomItem(itemWidget)
		end
		
	else
		rootWidget:getChildByName("Panel_Rewards_More"):setVisible(false)  -- 更多显示

		local containerWidget = nil

		local index = nil
		if 2 == itemCnt or 1 == itemCnt then
			index = 3
		elseif 4 == itemCnt or 3 == itemCnt then
			index = 2
		elseif 6 == itemCnt or 5 == itemCnt then
			index = 1
		end

		if 0 == math.fmod(itemCnt, 2) then -- 偶数
			rootWidget:getChildByName("Panel_Rewards_Odd"):setVisible(false)  -- 奇数隐藏
			rootWidget:getChildByName("Panel_Rewards_Even"):setVisible(true) -- 偶数显示
			containerWidget = rootWidget:getChildByName("Panel_Rewards_Even")
		else -- 奇数
			rootWidget:getChildByName("Panel_Rewards_Odd"):setVisible(true)  -- 奇数显示
			rootWidget:getChildByName("Panel_Rewards_Even"):setVisible(false) -- 偶数隐藏
			containerWidget = rootWidget:getChildByName("Panel_Rewards_Odd")
		end

		for i = 1, itemCnt do
			local actWidget = containerWidget:getChildByName("Panel_Reward_"..tostring(index))
			local itemWidget = createCommonWidget(itemList[i][1], itemList[i][2], itemList[i][3])
			itemWidget:retain()

			local function addAnimAndItem()
				-- 特效
				local animNode = AnimManager:createAnimNode(8005)
				itemWidget:getChildByName("Panel_Animation"):addChild(animNode:getRootNode())
				
				local function onAnimEnd()
					local act2 = cc.FadeIn:create(0.15)
					rootWidget:getChildByName("Label_Close"):runAction(act2)
				end

				if i < itemCnt then
					animNode:play("item_born", false)
				else
					animNode:play("item_born", false, onAnimEnd)
				end

				-- 物品
				actWidget:addChild(itemWidget)
				itemWidget:release()
			end

			local act0 = cc.DelayTime:create(0.15*i)
			local act1 = cc.CallFunc:create(addAnimAndItem)
			actWidget:runAction(cc.Sequence:create(act0, act1))

			index = index + 1
		end

		rootWidget:getChildByName("Label_Close"):setOpacity(0)
	end

	-- 清理
	local function doCleanup()
		rootWidget:removeFromParent(true)
		rootWidget = nil
		self.mMessageBox4Layer = nil

		-- 副本指引
		-- local function doPveGuideFive_Step2()
		-- 	local window = GUISystem:GetWindowByName("PveEntryWindow")
		-- 	if window.mRootWidget then
		-- 		local guideBtn = window.mSectionWidgetList[4]
		-- 		local size = guideBtn:getContentSize()
		-- 		local pos = guideBtn:getWorldPosition()
		-- 		pos.x = pos.x - size.width/2
		-- 		pos.y = pos.y - size.height/2
		-- 		local touchRect = cc.rect(pos.x, pos.y, size.width, size.height)
		-- 		PveGuideFive:step(3, touchRect)
		-- 	end
		-- end
		-- PveGuideFive:step(2, nil, doPveGuideFive_Step2)

		-- 副本指引
		local function doPveGuide1_5_Step2()
			local window = GUISystem:GetWindowByName("PveEntryWindow")
			if window.mRootWidget then
				local guideBtn = window.mSectionWidgetList[5]
				local size = guideBtn:getContentSize()
				local pos = guideBtn:getWorldPosition()
				pos.x = pos.x - size.width/2
				pos.y = pos.y - size.height/2
				local touchRect = cc.rect(pos.x, pos.y, size.width, size.height)
				PveGuide1_5:step(3, touchRect)
			end
		end
		PveGuide1_5:step(2, nil, doPveGuide1_5_Step2)

		-- 副本指引
		-- local function doPveGuide1_6_Step2()
		-- 	local window = GUISystem:GetWindowByName("PveEntryWindow")
		-- 	if window.mRootWidget then
		-- 		local guideBtn = window.mSectionWidgetList[6]
		-- 		local size = guideBtn:getContentSize()
		-- 		local pos = guideBtn:getWorldPosition()
		-- 		pos.x = pos.x - size.width/2
		-- 		pos.y = pos.y - size.height/2
		-- 		local touchRect = cc.rect(pos.x, pos.y, size.width, size.height)
		-- 		PveGuide1_6:step(3, touchRect)
		-- 	end
		-- end
		-- PveGuide1_6:step(2, nil, doPveGuide1_6_Step2)
		if PveGuide1_6:canGuide() then
			local window = GUISystem:GetWindowByName("PveEntryWindow")
		 	if window.mRootWidget then
				local guideBtn = window.mSectionWidgetList[6]
				local size = guideBtn:getContentSize()
				local pos = guideBtn:getWorldPosition()
				pos.x = pos.x - size.width/2
				pos.y = pos.y - size.height/2
				local touchRect = cc.rect(pos.x, pos.y, size.width, size.height)
				PveGuide1_6:step(3, touchRect)
			end
		end

		-- 副本指引
		local function doPveGuide1_7_Step2()
			local window = GUISystem:GetWindowByName("PveEntryWindow")
			if window.mRootWidget then
				local guideBtn = window.mSectionWidgetList[7]
				local size = guideBtn:getContentSize()
				local pos = guideBtn:getWorldPosition()
				pos.x = pos.x - size.width/2
				pos.y = pos.y - size.height/2
				local touchRect = cc.rect(pos.x, pos.y, size.width, size.height)
				PveGuide1_6:step(3, touchRect)
			end
		end
		PveGuide1_7:step(2, nil, doPveGuide1_6_Step2)

		-- 指引结束
		LevelRewardGuideZero:stop()

		-- 指引结束
		LevelRewardGuideOne:stop()

		-- 指引结束
		LevelRewardGuideOnePointFive:stop()

		-- 指引结束
		LevelRewardGuideTwo:stop()

		-- -- 装备指引
		-- if EquipGuideOne:canGuide() then
		-- 	local window = GUISystem:GetWindowByName("TaskWindow")
		-- 	if window.mRootWidget then
		-- 		local guideBtn = window.mTopRoleInfoPanel.mTopWidget:getChildByName("Button_Back")
		-- 		local size = guideBtn:getContentSize()
		-- 		local pos = guideBtn:getWorldPosition()
		-- 		pos.x = pos.x - size.width/2
		-- 		pos.y = pos.y - size.height/2
		-- 		local touchRect = cc.rect(pos.x, pos.y, size.width, size.height)
		-- 		EquipGuideOne:step(1, touchRect)
		-- 	end
		-- end

		-- 等级奖励指引
		local function doLevelRewardGuideZero_Step2()
			local window = GUISystem:GetWindowByName("PveEntryWindow")
			if window.mRootWidget then
				local guideBtn = window.mTopRoleInfoPanel.mTopWidget:getChildByName("Button_Back")
				local size = guideBtn:getContentSize()
				local pos = guideBtn:getWorldPosition()
				pos.x = pos.x - size.width/2
				pos.y = pos.y - size.height/2
				local touchRect = cc.rect(pos.x, pos.y, size.width, size.height)
				LevelRewardGuideZero:step(2, touchRect)
			end
		end
		LevelRewardGuideZero:step(1, nil, doLevelRewardGuideZero_Step2)
	end
	registerWidgetReleaseUpEvent(rootWidget, doCleanup)
--	registerWidgetReleaseUpEvent(rootWidget:getChildByName("Button_Ok"), doCleanup)

	CommonAnimation.PlayEffectId(5011)

	GUISystem.RootNode:addChild(rootWidget, 100)

	local function doLevelRewardGuideOnePointFivePause()
		LevelRewardGuideOnePointFive:pause()
	end
	doLevelRewardGuideOnePointFivePause()

	local function doLevelRewardGuideOnePause()
		LevelRewardGuideOne:pause()
	end
	doLevelRewardGuideOnePause()

	local function doLevelRewardGuideZeroPause()
		LevelRewardGuideZero:pause()
	end
	doLevelRewardGuideZeroPause()

	local function doLevelRewardGuideTwoPause()
		LevelRewardGuideTwo:pause()
	end
	doLevelRewardGuideTwoPause()
end

-- 不足跳转
function MessageBox:showHowToGetMessage(widget, wgtType, wgtId)
	widget:setTouchEnabled(true)
	local infoWnd = nil

	-- 销毁窗口
	local function delInfoWnd()
		if infoWnd then
			infoWnd:removeFromParent()
			infoWnd = nil
			GUISystem:enableUserInput()
		end
	end

	-- 添加窗口
	local function addInfoWnd()
		infoWnd = GUIWidgetPool:createWidget("HeroEquipInfo")
		GUISystem.RootNode:addChild(infoWnd, GUISYS_ZORDER_MESSAGEBOXWINDOW)
		registerWidgetReleaseUpEvent(infoWnd, delInfoWnd)
		registerWidgetReleaseUpEvent(infoWnd:getChildByName("Panel_SourcesBtn"):getChildByName("Button_Close"), delInfoWnd)

		-- 隐藏和显示一堆东西
		infoWnd:getChildByName("Panel_EquipBtn"):setVisible(false)
		infoWnd:getChildByName("Panel_DiamondBtn"):setVisible(false)
		infoWnd:getChildByName("Panel_ShizhuangBtn"):setVisible(false)
		infoWnd:getChildByName("Panel_SourcesBtn"):setVisible(true)
		infoWnd:getChildByName("Panel_Equip"):setVisible(false)
		infoWnd:getChildByName("Panel_DiamondsCom"):setVisible(false)
		infoWnd:getChildByName("Panel_Sources"):setVisible(true)
		infoWnd:getChildByName("Label_Number"):setVisible(true)

		-- 拥有数量
		local ownCnt = globaldata:getItemOwnCount(wgtId)
		infoWnd:getChildByName("Label_Number"):setString("拥有"..ownCnt.."件")

		-- 名称
		local itemData = DB_ItemConfig.getDataById(wgtId)
		local itemNameId = itemData.Name
		local itemName = getDictionaryText(itemNameId)
		infoWnd:getChildByName("Label_Name"):setString(itemName)

		-- 描述
		local descTextId = itemData.Description
		local descText = getDictionaryText(descTextId)
	--	infoWnd:getChildByName("Label_Des"):setString(descText)
		richTextCreate(infoWnd:getChildByName("Panel_Des"), descText, true)

		-- 显示icon
		infoWnd:getChildByName("Panel_EquipIcon"):addChild(createCommonWidget(wgtType, wgtId, nil, nil, true))

		local listWidget = infoWnd:getChildByName("ListView_Sources")

		for i = 1, itemData.JumpNumber do
			local parentNode = GUIWidgetPool:createWidget("HeroEquipInfo_SourcesCell")
			listWidget:pushBackCustomItem(parentNode)

			local parm1 = itemData["Jump"..i]
			-- icon
			local iconId = itemData["JumpIcon"..i]
			local iconName = DB_ResourceList.getDataById(iconId).Res_path1
			parentNode:getChildByName("Image_Icon"):loadTexture(iconName, 1)
			-- text
			local textId = itemData["JumpText"..i]
			local text = getDictionaryText(textId)
			parentNode:getChildByName("Label_Text"):setString(text)
			-- btn
			local function goToFunc()
				wndJump(parm1,{tonumber(itemData["JumpPara"..i.."_1"]), tonumber(itemData["JumpPara"..i.."_2"])})
				delInfoWnd()
			end

			if 2 == parm1 then -- 进入PVE
				parentNode:getChildByName("Label_Text"):setVisible(true)
				parentNode:getChildByName("Panel_PVE"):setVisible(false)
				-- 难度
				local lblWidget = parentNode:getChildByName("Label_Type")
				lblWidget:setVisible(true)
				-- if 1 == itemData["JumpPara"..i.."_1"] then
				-- 	parentNode:getChildByName("Label_Text"):setString("冒险副本-普通")
				-- elseif 2 == itemData["JumpPara"..i.."_1"] then
				-- 	parentNode:getChildByName("Label_Text"):setString("冒险副本-精英")
				-- end
				registerWidgetReleaseUpEvent(parentNode:getChildByName("Button_Sources"), goToFunc)
			elseif 1 == parm1 then -- 进入指定
				parentNode:getChildByName("Label_Text"):setVisible(false)
				parentNode:getChildByName("Panel_PVE"):setVisible(true)
				local sectionInfo = nil
				local sectionInfo = DB_MapUIConfig.getDataById(itemData["JumpPara"..i.."_2"])
				-- 难度
				local lblWidget = parentNode:getChildByName("Label_Type")
				lblWidget:setVisible(true)
				if 1 == itemData["JumpPara"..i.."_1"] then
					lblWidget:setString("冒险副本")
					lblWidget:setColor(cc.c3b(12, 88, 243))
				elseif 2 == itemData["JumpPara"..i.."_1"] then
					lblWidget:setString("精英副本")
					lblWidget:setColor(cc.c3b(215, 14, 180))
				end

				-- 选章节
				local chapterIndex = sectionInfo.MapUI_ChapterID
				-- 选关卡
				local sectionIndex = sectionInfo.MapUI_SectionID
				-- 标签
				parentNode:getChildByName("Label_PVE"):setString(string.format("第%s章 第%s关", chapterIndex, sectionIndex))
				-- 是否开启
				if globaldata:isSectionOpened(chapterIndex, sectionIndex, itemData["JumpPara"..i.."_1"]) then
					parentNode:getChildByName("Label_PVE"):setVisible(true)
					parentNode:getChildByName("Label_Unopened"):setVisible(false)
					registerWidgetReleaseUpEvent(parentNode:getChildByName("Button_Sources"), goToFunc)
					-- 星星
					parentNode:getChildByName("Panel_Star"):setVisible(true)
					local chapterList = globaldata:getChapterListByLevel(itemData["JumpPara"..i.."_1"])
					local sectionList = chapterList[chapterIndex]:getKeyValue("mSectionList")
					local sectionObj = sectionList[sectionIndex]
					local starCount =  sectionObj:getKeyValue("mCurStarCount")
					for j = 1, 3 do
						if j <= starCount then
							parentNode:getChildByName("Panel_Star"):getChildByName("Image_Star_"..j):loadTexture("public_star1.png")
						end
					end

				else
					parentNode:getChildByName("Label_PVE"):setVisible(true)
					parentNode:getChildByName("Label_Unopened"):setVisible(true)
					-- 星星
					parentNode:getChildByName("Panel_Star"):setVisible(false)
					local function xxx()
						MessageBox:showMessageBox1("当前关卡还未开启哦~~")
					end
					registerWidgetReleaseUpEvent(parentNode:getChildByName("Button_Sources"), xxx)
				end
			else
				parentNode:getChildByName("Label_Text"):setVisible(true)
				parentNode:getChildByName("Panel_PVE"):setVisible(false)
				registerWidgetReleaseUpEvent(parentNode:getChildByName("Button_Sources"), goToFunc)
			end
		end
	end

	local function onItemTouched(widget, eventType)
		if eventType == ccui.TouchEventType.began then
        	
      	elseif eventType == ccui.TouchEventType.ended then
      		addInfoWnd()
      	elseif eventType == ccui.TouchEventType.moved then

      	elseif eventType == ccui.TouchEventType.canceled then

      	end
	end

	widget:addTouchEventListener(onItemTouched)
	
end

function MessageBox:showMessageBox_QA(msgBoxType, paramList, func)

	local rootWidget = GUIWidgetPool:createWidget("MessageBox_Consume")
	local parentNode = nil

	
	if "tili" == msgBoxType then -- 体力
		rootWidget:getChildByName("Button_Buy"):getChildByName("Label_DiamondNum_Stroke"):setString(paramList[1])
		parentNode = rootWidget:getChildByName("Panel_Tili")
		parentNode:getChildByName("Label_TiliNum"):setString(paramList[2])
		parentNode:getChildByName("Label_LastTimes"):setString(paramList[3].."/"..paramList[4])
	elseif "libao" == msgBoxType then -- VIP礼包
		rootWidget:getChildByName("Button_Buy"):getChildByName("Label_DiamondNum_Stroke"):setString(paramList[1])
		parentNode = rootWidget:getChildByName("Panel_VIPpackage")
		parentNode:getChildByName("Label_VIP"):setString("VIP "..paramList[2])
	elseif "chongzhi" == msgBoxType then -- 重置闯关次数
		rootWidget:getChildByName("Button_Buy"):getChildByName("Label_DiamondNum_Stroke"):setString(paramList[1])
		parentNode = rootWidget:getChildByName("Panel_PVETimes")
		parentNode:getChildByName("Label_LastTimes"):setString(paramList[2].."/"..paramList[3])
	elseif "arena" == msgBoxType then -- 重置武道馆次数
		rootWidget:getChildByName("Button_Buy"):getChildByName("Label_DiamondNum_Stroke"):setString(paramList[1])
		parentNode = rootWidget:getChildByName("Panel_ArenaTimes")
		parentNode:getChildByName("Label_Times"):setString(paramList[2])
		parentNode:getChildByName("Label_LastTimes"):setString(paramList[3].."/"..paramList[4])
	elseif "shopFresh" == msgBoxType then -- 商场刷新
		rootWidget:getChildByName("Button_Buy"):getChildByName("Label_DiamondNum_Stroke"):setString(paramList[1])
		parentNode = rootWidget:getChildByName("Panel_ShopRefresh")
		parentNode:getChildByName("Label_LastTimes"):setString(paramList[2].."/"..paramList[3])
	elseif "shopBuy" == msgBoxType then -- 商城购买
		rootWidget:getChildByName("Button_Buy"):getChildByName("Label_DiamondNum_Stroke"):setString(paramList[1])
		parentNode = rootWidget:getChildByName("Panel_Shopping")
		parentNode:getChildByName("Label_Num"):setString(paramList[2])
		parentNode:getChildByName("Label_Name"):setString(paramList[3])
		parentNode:getChildByName("Panel_Item"):addChild(createCommonWidget(paramList[4], paramList[5], paramList[2]))
	elseif "heishi" == msgBoxType then -- 黑市
		rootWidget:getChildByName("Button_Buy"):getChildByName("Label_DiamondNum_Stroke"):setString(paramList[1])
		parentNode = rootWidget:getChildByName("Panel_BlackMaket")
	elseif "gonghui" == msgBoxType then -- 创建公会
		rootWidget:getChildByName("Button_Buy"):getChildByName("Label_DiamondNum_Stroke"):setString(paramList[1])
		rootWidget:getChildByName("Image_Diamond"):loadTexture("public_gold.png")
		parentNode = rootWidget:getChildByName("Panel_CreatGuild")
	elseif "worldboss" == msgBoxType then
		rootWidget:getChildByName("Button_Buy"):getChildByName("Label_DiamondNum_Stroke"):setString(paramList[1])
		parentNode = rootWidget:getChildByName("Panel_WorldBossTimes")
		parentNode:getChildByName("Label_Times"):setString(tostring(paramList[2]))
	elseif "talent" == msgBoxType then
		rootWidget:getChildByName("Button_Buy"):getChildByName("Label_DiamondNum_Stroke"):setString(paramList[1])
		parentNode = rootWidget:getChildByName("Panel_ResetTalent")
	else
		rootWidget:getChildByName("Button_Buy"):getChildByName("Label_DiamondNum_Stroke"):setString(paramList[1])
		parentNode = rootWidget:getChildByName("Panel_TechBag")
	end

	parentNode:setVisible(true)

	-- 清理
	local function doCleanup()
		rootWidget:removeFromParent(true)
		func()
	end
	registerWidgetReleaseUpEvent(rootWidget:getChildByName("Button_Buy"), doCleanup)

	-- 关闭
	local function doClose()
		rootWidget:removeFromParent(true)
	end
	registerWidgetReleaseUpEvent(rootWidget:getChildByName("Button_Close"), doClose) 

	GUISystem.RootNode:addChild(rootWidget, 100)
end

-- 天梯体力
function MessageBox:showMessageBoxConsume(price,count)
	local rootWidget = GUIWidgetPool:createWidget("MessageBox_Consume")
	local ladderPanel = rootWidget:getChildByName("Panel_Tianti3v3Times")

	ladderPanel:setVisible(true)
	ladderPanel:getChildByName("Label_Times"):setString(tostring(count))
	rootWidget:getChildByName("Label_DiamondNum_Stroke"):setString(tostring(price))

	GUISystem.RootNode:addChild(rootWidget, GUISYS_ZORDER_MESSAGEBOXWINDOW)

	local function doBuyLadderCnt()
		local packet = NetSystem.mNetManager:GetSPacket()
	    packet:SetType(PacketTyper._PTYPE_CS_BUY_LADDERCNT_REQUEST_)
	    packet:Send()
	    rootWidget:removeFromParent(true)
	end



	registerWidgetReleaseUpEvent(rootWidget:getChildByName("Button_Close"),function() rootWidget:removeFromParent(true) end)
	registerWidgetReleaseUpEvent(rootWidget:getChildByName("Button_Buy"),doBuyLadderCnt)
end

-- 秒转时间
function MessageBox:secondToHour(seconds)
	if not seconds or seconds <= 0 then
		return "00:00:00"
	end
	local hour = math.floor(seconds / 3600)
	seconds = math.mod(seconds, 3600)
	local min = math.floor(seconds / 60)
	seconds = math.mod(seconds, 60)
	local sec = seconds
	return string.format("%02d:%02d:%02d",hour,min,sec)
end

function MessageBox:showMessageBox_TiliInfo(widget)
	local rootWidget = GUIWidgetPool:createWidget("NewHome_TiliWindow")

	GUISystem.RootNode:addChild(rootWidget, GUISYS_ZORDER_MESSAGEBOXWINDOW)

	local parentPos = cc.p(widget:getWorldPosition())
	local parentNode = rootWidget:getChildByName("Panel_Main")
	local parentSize = parentNode:getContentSize()
	parentNode:setPosition(cc.p(parentPos.x + widget:getContentSize().width/2 - parentSize.width/2, parentPos.y - parentSize.height))

	local function updateTiliInfo(evtType, nextTime, allTime)
		-- 下一次
		rootWidget:getChildByName("Label_NextTime"):setString(self:secondToHour(nextTime))

		-- 所有时间
		rootWidget:getChildByName("Label_AllTime"):setString(self:secondToHour(allTime))
	end

	rootWidget:getChildByName("Label_NextTime"):setVisible(true)
	rootWidget:getChildByName("Label_AllTime"):setVisible(true)
	-- 下一次
	rootWidget:getChildByName("Label_NextTime"):setString(self:secondToHour(Shabi.mLeftSeconds_One))
	-- 所有时间
	rootWidget:getChildByName("Label_AllTime"):setString(self:secondToHour(Shabi.mLeftSeconds_Total))

	local function closeWindow()
		rootWidget:removeFromParent(true)
		rootWidget = nil

		GUIEventManager:unregister("shabi", updateTiliInfo)
	end
	registerWidgetReleaseUpEvent(rootWidget, closeWindow)

	GUIEventManager:registerEvent("shabi", nil, updateTiliInfo)
end