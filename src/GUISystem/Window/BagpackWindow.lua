-- Name: 	BagpackWindow
-- Func：	背包
-- Author:	WangShengdong
-- Data:	14-11-14

local margin_left = 0 			-- 左间距
local margin_cell = 7 			-- 物品间距(横向)
local margin_cell_vertical = 7 	-- 物品间距(竖向)
local column_count = 5 			-- 每行物品数量


-- 物品对象(复用一下globaldata中的)
local itemObject = {}
function itemObject:new()
	local o = 
	{
		itemId 		= 	nil,	-- 物品Id
		itemType 	= 	nil,	-- 物品类型
		itemNum		= 	0,		-- 物品数量
		itemGUID 	=	"",		-- guid
	}
	o = newObject(o, itemObject)
	return o
end

function itemObject:getKeyValue(key)
	if self[key] then
		return self[key]
	end
	return nil
end

-- 背包物品列表
local BagpackItemList = {}

function BagpackItemList:new(owner, itemType)
	local o = 
	{
		mRootNode				=	nil,
		mType 					=	itemType,
		mDataSource 			=   nil,
		mCellCount  			= 	0,
		mOwner 					=	owner,
		mItemSelectedAnimNode	=	nil, 			-- 物品选中动画
		mLastChooseItemId		=	nil,			-- 上一次选中的物品ID
		mLastChooseEquipGuid	=	nil,			-- 行一次选中的装备GUID
		mLastClickedRow 		= 	nil,
		mLastClickedColumn 		= 	nil,
	}
	o = newObject(o, BagpackItemList)
	return o
end

function BagpackItemList:init(rootNode)
	self.mRootNode = rootNode

	-- 初始化数据源
	self:initDataSource()

	-- 初始化列表容器
	self:initTableView()
end

function BagpackItemList:initDataSource()
	self.mDataSource = {}

	-- 物品
	local itemList = globaldata:getItemList()
	for i = 1, #itemList do
	--	if i ~= 5 then 						-- 排除类型5
			for j = 1, #itemList[i] do
				local itemObj = itemList[i][j]
				table.insert(self.mDataSource, itemObj)
			end
	--	end
	end

	-- 时装
	local equipList = globaldata:getTotalEquipList()
	for i = 1, #equipList do
		if equipList[i]:getKeyValue("type") >= 7 then -- 时装
			local itemObj = itemObject:new()
			itemObj.itemId = equipList[i]:getKeyValue("id")
			itemObj.itemType = -1 -- 装备
			itemObj.itemNum = ""
			itemObj.itemGUID = equipList[i]:getKeyValue("guid")
			table.insert(self.mDataSource, itemObj)
		end
	end
end

-- 切换数据源
function BagpackItemList:switchDataSource(srcType)
	self.mDataSource = {}
	self.mType = srcType

	if 0 == srcType then 	-- 全部物品和装备
		self:initDataSource()
	elseif 1 == srcType then -- 英雄碎片和装备碎片
		local itemList = globaldata:getItemList()[1]
		for i = 1, #itemList do
			local itemObj = itemList[i]
			table.insert(self.mDataSource, itemObj)
		end
		itemList = globaldata:getItemList()[3]
		for i = 1, #itemList do
			local itemObj = itemList[i]
			table.insert(self.mDataSource, itemObj)
		end
	elseif 2 == srcType then -- 宝石
		local itemList = globaldata:getItemList()[2]
		for i = 1, #itemList do
			local itemObj = itemList[i]
			table.insert(self.mDataSource, itemObj)
		end
	elseif 3 == srcType then -- 装备
		local equipList = globaldata:getTotalEquipList()
		for i = 1, #equipList do
			if equipList[i]:getKeyValue("type") <= 6 then
				local itemObj = itemObject:new()
				itemObj.itemId = equipList[i]:getKeyValue("id")
				itemObj.itemType = -1 -- 装备
				itemObj.itemNum = ""
				itemObj.itemGUID = equipList[i]:getKeyValue("guid")
				table.insert(self.mDataSource, itemObj)
			end
		end
	elseif 4 == srcType then -- 消耗品
		local itemList = globaldata:getItemList()[4]
		for i = 1, #itemList do
			local itemObj = itemList[i]
			table.insert(self.mDataSource, itemObj)
		end
	elseif 5 == srcType then -- 时装
		local equipList = globaldata:getTotalEquipList()
		for i = 1, #equipList do
			if equipList[i]:getKeyValue("type") >= 7 then
				local itemObj = itemObject:new()
				itemObj.itemId = equipList[i]:getKeyValue("id")
				itemObj.itemType = -1 -- 时装
				itemObj.itemNum = ""
				itemObj.itemGUID = equipList[i]:getKeyValue("guid")
				table.insert(self.mDataSource, itemObj)
			end
		end
	elseif 7 == srcType then
		local itemList = globaldata:getItemList()[7]
		for i = 1, #itemList do
			local itemObj = itemList[i]
			table.insert(self.mDataSource, itemObj)
		end
	elseif 8 == srcType then
		local itemList = globaldata:getItemList()[5]
		for i = 1, #itemList do
			local itemObj = itemList[i]
			table.insert(self.mDataSource, itemObj)
		end
	end

	local function sortFunc(obj1, obj2)
		local data1 = nil
		local data2 = nil

		if -1 == obj1.itemType then -- 装备
			data1 = DB_EquipmentConfig.getDataById(obj1.itemId)
		elseif 2 == obj1.itemType then -- 宝石
			data1 = DB_Diamond.getDataById(obj1.itemId)
		else -- 物品
			data1 = DB_ItemConfig.getDataById(obj1.itemId)
		end

		if -1 == obj2.itemType then -- 装备
			data2 = DB_EquipmentConfig.getDataById(obj2.itemId)
		elseif 2 == obj2.itemType then -- 宝石
			data2 = DB_Diamond.getDataById(obj2.itemId)
		else -- 物品
			data2 = DB_ItemConfig.getDataById(obj2.itemId)
		end

		if data1.ClientIndex < data2.ClientIndex then
			return true
		elseif data1.ClientIndex == data2.ClientIndex then
			-- 比较品质
			return data1.Quality > data2.Quality
		elseif data1.ClientIndex > data2.ClientIndex then
			return false
		end
	end
	table.sort(self.mDataSource, sortFunc)

	self.mCellCount = math.ceil(#self.mDataSource/column_count)

	self.mTableView:setCellCount(self.mCellCount)
	self.mTableView:reloadData()

	-- 删除动画
	local function delAnim()
		if self.mItemSelectedAnimNode then
			self.mItemSelectedAnimNode:destroy()
			self.mItemSelectedAnimNode = nil
		end
	end
	delAnim()

	-- 默认选中第一项
	local function autoSelected()
		local cell = self.mTableView.mInnerContainer:cellAtIndex(0)
		if cell then
			local itemWidget = cell:getChildByTag(1)
			if itemWidget then
				self.mOwner:itemOnClicked(itemWidget, self.mDataSource[1])
				self.mLastClickedRow = 0
				self.mLastClickedColumn = 1
				self.mLastChooseItemId = self.mDataSource[1].itemId
				
				-- 添加动画
				local function addAnim()
					-- 回调 
					local function xxx()
						self.mItemSelectedAnimNode:play("bagpack_item_chosen2", true)
					end
					-- 添加选中动画
					if not self.mItemSelectedAnimNode then
						self.mItemSelectedAnimNode = AnimManager:createAnimNode(8002)
						itemWidget:getChildByName("Panel_Animation"):addChild(self.mItemSelectedAnimNode:getRootNode(), 100)
						self.mItemSelectedAnimNode:play("bagpack_item_chosen1", false, xxx)
					end
				end
				addAnim()
			else
				self.mOwner:setItemDetailWindowVisible(false)
			end
		else
			self.mOwner:setItemDetailWindowVisible(false)
		end

		self.mLastChooseEquipGuid = nil
	end
	autoSelected()
end

-- 获取数据数量
function BagpackItemList:getCellCount()
	return self.mCellCount
end

-- 刷新
function BagpackItemList:refresh()
	self:switchDataSource(self.mType)
end

function BagpackItemList:initTableView()
	self.mTableView = TableViewEx:new()
	local itemWidget0 = GUIWidgetPool:createWidget("ItemWidget")
	local itemWidgetContentSize = itemWidget0:getContentSize()
	local tblViewContentSize = self.mRootNode:getContentSize()
	self.mTableView:setCellSize(cc.size(tblViewContentSize.width, itemWidgetContentSize.height + margin_cell_vertical))
	self.mTableView:setCellCount(1000)

	self.mTableView:registerTableCellAtIndexFunc(handler(self, self.tableCellAtIndex))
	self.mTableView:registerTableCellTouchedFunc(handler(self, self.tableCellTouched))

	self.mTableView:init(tblViewContentSize, cc.p(0,0), 1)
	self.mRootNode:addChild(self.mTableView:getRootNode())

	self.mTableView:setBounceable(false)
end


local function itemType2(itemObj,itemWidget)
	itemId = itemObj:getKeyValue("itemId")
	local itemData = DB_Diamond.getDataById(itemId)
	-- 换物品图片
	local iconId = itemData.Icon
	local imgName = DB_ResourceList.getDataById(iconId).Res_path1
	itemWidget:getChildByName("Image_Item"):loadTexture(imgName, 1)
	-- 换品质图片
	local quality = itemData.Level
	itemWidget:getChildByName("Image_Quality"):loadTexture("icon_item_quality"..tostring(quality)..".png", 1)
	itemWidget:getChildByName("Image_Quality_Bg"):loadTexture("icon_item_quality_bg"..tostring(quality)..".png", 1)
end

local function itemType_1(itemObj, itemWidget)
	itemId = itemObj:getKeyValue("itemId")
	local equipInfo = DB_EquipmentConfig.getDataById(itemId)
	local iconId = equipInfo.IconID
	local ImgData = DB_ResourceList.getDataById(iconId)
	local imgName = ImgData.Res_path1
	itemWidget:getChildByName("Image_Item"):loadTexture(imgName)
	-- 换品质图片
	local quality = equipInfo.Quality
	itemWidget:getChildByName("Image_Quality"):loadTexture("icon_item_quality"..tostring(quality)..".png", 1)
	itemWidget:getChildByName("Image_Quality_Bg"):loadTexture("icon_item_quality_bg"..tostring(quality)..".png", 1)
end

local function itemType3(itemObj, itemWidget)
	itemId = itemObj:getKeyValue("itemId")
	local itemData = DB_ItemConfig.getDataById(itemId)
	-- 换物品图片
	local itemIconId = itemData.IconID
	local imgName = DB_ResourceList.getDataById(itemIconId).Res_path1
	itemWidget:getChildByName("Image_Item"):loadTexture(imgName, 1)
	-- 换品质图片
	local quality = itemData.Quality
	itemWidget:getChildByName("Image_Quality"):loadTexture("icon_item_quality"..tostring(quality)..".png", 1)
	itemWidget:getChildByName("Image_Quality_Bg"):loadTexture("icon_item_quality_bg"..tostring(quality)..".png", 1)
	-- 显示碎片标记
	--					itemWidget:getChildByName("Image_Piece"):setVisible(true)
end

local function itemType1(itemObj, itemWidget)
	itemWidget:getChildByName("Image_Item"):setVisible(false)
	itemWidget:getChildByName("Image_HeroIcon"):setVisible(true)
	-- 碎片标志
	itemWidget:getChildByName("Image_HeroPiece"):setVisible(true)
	-- 换物品图片
	itemId = itemObj:getKeyValue("itemId")
	local itemData = DB_ItemConfig.getDataById(itemId)
	local itemIconId = itemData.IconID
	local imgName = DB_ResourceList.getDataById(itemIconId).Res_path1
	itemWidget:getChildByName("Image_HeroIcon"):setVisible(true)
	itemWidget:getChildByName("Image_HeroIcon"):setVisible(true)
	--					itemWidget:getChildByName("Image_Piece"):setVisible(true)
	itemWidget:getChildByName("Image_HeroIcon"):loadTexture(imgName, 1)
	-- 换品质图片
	local quality = itemData.Quality
	quality = 1
	itemWidget:getChildByName("Image_Quality"):loadTexture("icon_item_quality"..tostring(quality)..".png", 1)
	itemWidget:getChildByName("Image_Quality_Bg"):loadTexture("icon_item_quality_bg"..tostring(quality)..".png", 1)
-- 				--	if 5 == itemData.Quality then
-- 					--	local animNode = AnimManager:createAnimNode(8067)
-- 					--	itemWidget:getChildByName("Panel_SuperHero_Animation"):addChild(animNode:getRootNode(), 100)
-- 					--	animNode:play("item_superhero", true)
-- 				--		itemWidget:getChildByName("Image_SuperHero"):loadTexture("hero_super_1.png")
-- 				--	else
-- 				--		itemWidget:getChildByName("Image_SuperHero"):loadTexture("hero_super_0.png")
-- 				--	end
-- 					itemWidget:getChildByName("Image_SuperHero"):setVisible(false)
end

local function itemType_other(itemObj, itemWidget)
	itemId = itemObj:getKeyValue("itemId")
	local itemData = DB_ItemConfig.getDataById(itemId)
	-- 换物品图片
	local itemIconId = itemData.IconID
	local imgName = DB_ResourceList.getDataById(itemIconId).Res_path1
	itemWidget:getChildByName("Image_Item"):loadTexture(imgName, 1)
	-- 换品质图片
	local quality = itemData.Quality
	itemWidget:getChildByName("Image_Quality"):loadTexture("icon_item_quality"..tostring(quality)..".png", 1)
	itemWidget:getChildByName("Image_Quality_Bg"):loadTexture("icon_item_quality_bg"..tostring(quality)..".png", 1)
end

local updateCellInfo_FuncMap = {}
updateCellInfo_FuncMap[2] = itemType2
updateCellInfo_FuncMap[-1] = itemType_1
updateCellInfo_FuncMap[3] = itemType3
updateCellInfo_FuncMap[1] = itemType1
updateCellInfo_FuncMap[0] = itemType_other


function BagpackItemList:tableCellAtIndex(table, index)
	local cell = table:dequeueCell()

	local function updateCellInfo() -- 更新格子信息
		for i = 1, column_count do
			local itemWidget = cell:getChildByTag(i)
			local newIndex = index*column_count + i
			if newIndex > #self.mDataSource then -- 隐藏
				itemWidget:setVisible(false)
			else

				-- 清除所有节点
			--	itemWidget:getChildByName("Panel_SuperHero_Animation"):removeAllChildren()

				itemWidget:setVisible(true)
				local itemObj = self.mDataSource[newIndex]
				local itemType = itemObj:getKeyValue("itemType")
				local itemId = nil
				local itemCount = itemObj:getKeyValue("itemNum")
				
				itemWidget:getChildByName("Image_Item"):setVisible(true)
--				itemWidget:getChildByName("Image_Piece"):setVisible(false)
				itemWidget:getChildByName("Image_HeroIcon"):setVisible(false)
				-- 更换碎片图片
-- 				itemWidget:getChildByName("Image_Piece"):loadTexture("icon_piece.png", 1)
				itemWidget:getChildByName("Image_SuperHero"):setVisible(false)

				-- 碎片标志
				itemWidget:getChildByName("Image_HeroPiece"):setVisible(false)

				-- 根据item类型，载入相应数据
				local func = updateCellInfo_FuncMap[itemType]
				if not func then func = updateCellInfo_FuncMap[0] end
				func(itemObj, itemWidget)


				-- 数量
				itemWidget:getChildByName("Label_Count_Stroke"):setString(tostring(itemCount))

				local function onClicked(widget)
					-- 添加动画
					local function addAnim()
						-- 回调 
						local function xxx()
							self.mItemSelectedAnimNode:play("bagpack_item_chosen2", true)
						end
						-- 添加选中动画
						if not self.mItemSelectedAnimNode then
							self.mItemSelectedAnimNode = AnimManager:createAnimNode(8002)
							widget:getChildByName("Panel_Animation"):addChild(self.mItemSelectedAnimNode:getRootNode(), 100)
							self.mItemSelectedAnimNode:play("bagpack_item_chosen1", false, xxx)
						end
					end

					self.mLastClickedRow = index
					self.mLastClickedColumn = widget:getTag()

					-- 删除动画
					local function delAnim()
						if self.mItemSelectedAnimNode then
							self.mItemSelectedAnimNode:destroy()
							self.mItemSelectedAnimNode = nil
						end
					end

					if -1 ~= itemObj.itemType then -- 非时装
						if self.mLastChooseItemId == itemObj.itemId then
							return
						else
							-- 删除动画
							delAnim() 
						end
						self.mLastChooseEquipGuid = nil
					elseif -1 == itemObj.itemType then -- 时装
						if self.mLastChooseEquipGuid == itemObj.itemGUID then
							return
						else
							-- 删除动画
							delAnim() 
						end
						self.mLastChooseEquipGuid = itemObj.itemGUID
					end

					self.mLastChooseItemId = itemObj.itemId

					self.mOwner:itemOnClicked(widget, itemObj)
					-- 添加动画
					addAnim()
				end
				registerWidgetPushDownEvent(itemWidget, onClicked)
			end
		end
		-- 选中
		self:setPreItemSelected()
	end

	local function createLocalItemWidget(index) -- 创建物品
		local widget = GUIWidgetPool:createWidget("ItemWidget")
		widget:getChildByName("Label_Count_Stroke"):setVisible(true)
		local pos = cc.p(margin_left+(index-1)*(widget:getContentSize().width+margin_cell), 0)
		widget:setPosition(pos)
		widget:setTouchSwallowed(false)
		return widget
	end

	if nil == cell then
		cell = cc.TableViewCell:new()
		for i = 1, column_count do
			local itemWidget = createLocalItemWidget(i)
			itemWidget:setTag(i)
			cell:addChild(itemWidget)
		end
	else
		
	end

	updateCellInfo()

	return cell
end

function BagpackItemList:tableCellTouched(table,cell)
end

-- 在滑动过程中控制前一次选择的Item高亮
function BagpackItemList:setPreItemSelected()
	-- 删除动画
	local function delAnim()
		if self.mItemSelectedAnimNode then
			self.mItemSelectedAnimNode:destroy()
			self.mItemSelectedAnimNode = nil
		end
	end
	
	-- 找到需要添加动画的那个
	for i = 1, self.mCellCount do
		local cell = self.mTableView.mInnerContainer:cellAtIndex(i-1)
		if cell then
			for j = 1, column_count do
				local widget = cell:getChildByTag(j)
				-- 添加选中状态
				if i-1 == self.mLastClickedRow and j == self.mLastClickedColumn then
					delAnim()
					-- 添加动画
					if not self.mItemSelectedAnimNode then
						self.mItemSelectedAnimNode = AnimManager:createAnimNode(8002)
						widget:getChildByName("Panel_Animation"):addChild(self.mItemSelectedAnimNode:getRootNode(), 100)
						self.mItemSelectedAnimNode:play("bagpack_item_chosen2", true)
					end
					return
				end
			end
		end
	end
end

-- 销毁
function BagpackItemList:destroy()
	if self.mItemSelectedAnimNode then
		self.mItemSelectedAnimNode:destroy()
		self.mItemSelectedAnimNode = nil
	end
end

local BagpackWindow = 
{
	mName					=	"BagpackWindow",
	mRootNode				=	nil,
	mRootWidget				=	nil,
	---------------------------------------------------------
	mItemDetailWindow		=	nil,							-- 物品详情窗口
	mDiamondComposeWindow	=	nil,							-- 宝石合成窗口
	mLastChooseWidget   	=	nil,							-- 最后一次选中的菜单项
	mDiamondComAnimNode 	=	nil,							-- 宝石合成动画
}

function BagpackWindow:Release()
end

function BagpackWindow:Load()
	cclog("=====BagpackWindow:Load=====begin")

	GUIEventManager:registerEvent("itemInfoChanged", self, self.refresh)

	self.mRootNode = cc.Node:create()
	GUISystem:GetRootNode():addChild(self.mRootNode)
	
	self:InitLayout()

	-- 初始化数据
	self.mItemListWidget = BagpackItemList:new(self, 0)
	self.mItemListWidget:init(self.mRootWidget:getChildByName("Panel_Container"))

	-- 默认选择全部
	self:showItem(self.mRootWidget:getChildByName("Image_ShowAll"))

	cclog("=====BagpackWindow:Load=====end")
end

function BagpackWindow:InitLayout()

	self.mRootWidget = GUIWidgetPool:createWidget("Bagpack")
	self.mRootNode:addChild(self.mRootWidget)

	local function closeWindow()
		EventSystem:PushEvent(Event.GUISYSTEM_HIDE_BAGPACKWINDOW)
	end
	self.mTopRoleInfoPanel = TopRoleInfoPanel:new()
	local topInfoPanel = self.mTopRoleInfoPanel:init(self.mRootNode,ROLE_TITLE_TYPE.TITLE_BAG,closeWindow)

	local function doAdapter()
	    local topInfoPanelSize = topInfoPanel:getContentSize()
	    local newHeight = getGoldFightPosition_LU().y - topInfoPanelSize.height - getGoldFightPosition_LD().y
	    local newPosY = newHeight/2 + getGoldFightPosition_LD().y - self.mRootWidget:getChildByName("Panel_Main"):getContentSize().height/2
	    self.mRootWidget:getChildByName("Panel_Main"):setVisible(false)
		local function doSomething()
			self.mRootWidget:getChildByName("Panel_Main"):setPositionY(newPosY)
			self.mRootWidget:getChildByName("Panel_Main"):setVisible(true)
		end
		nextTick(doSomething)
	end
	doAdapter()

	-- 重新设置tag
	local function setTag()
		self.mRootWidget:getChildByName("Image_ShowAll"):setTag(1)
		self.mRootWidget:getChildByName("Image_ShowChips"):setTag(2)
		self.mRootWidget:getChildByName("Image_ShowDiamond"):setTag(3)
		self.mRootWidget:getChildByName("Image_ShowShizhuang"):setTag(5)
		self.mRootWidget:getChildByName("Image_ShowWeapon"):setTag(6)
		self.mRootWidget:getChildByName("Image_ShowConsumeItem"):setTag(7)
	end
	setTag()

	-- 按钮飞入动画
	local function doAnim()
		local topWidget = self.mRootWidget:getChildByName("Panel_ButtonList")

		for i = 1, 7 do
			if 4 ~= i then
				local btnWidget = topWidget:getChildByTag(i)
				btnWidget:setOpacity(0)
			end
		end

		for i = 1, 7 do
			if 4 ~= i then -- 装备功能隐藏
				local btnWidget = topWidget:getChildByTag(i)
				local contentSize = btnWidget:getContentSize()
				local startPos = cc.p(btnWidget:getPosition())
				local endPos = cc.p(contentSize.width/2, startPos.y)
				local delayTime = 0.1
				local moveTime	= 0.2
				local act0 = cc.DelayTime:create(delayTime*(i-1))

				local act1 = cc.MoveTo:create(moveTime, endPos)
				local act2 = cc.FadeIn:create(moveTime)
				local act3 = cc.Spawn:create(act1, act2)
				local act4 = cc.EaseOut:create(act3 , 3)

				btnWidget:runAction(cc.Sequence:create(act0, act4))
			end
		end
	end
	doAnim()

	self.mItemDetailWindow = self.mRootWidget:getChildByName("Panel_ItemDetalInfo")
	self.mItemDetailWindow:setVisible(false)

	self.mDiamondComposeWindow = GUIWidgetPool:createWidget("Bagpack_DiamondCom")
	self.mRootNode:addChild(self.mDiamondComposeWindow, 100)
	self.mDiamondComposeWindow:setVisible(false)

	local function onShowItemBtnTouched(widget)
		GUISystem:playSound("homeBtnSound")
		self:showItem(widget)
	end

	registerWidgetPushDownEvent(self.mRootWidget:getChildByName("Image_ShowAll"), onShowItemBtnTouched)
	registerWidgetPushDownEvent(self.mRootWidget:getChildByName("Image_ShowChips"), onShowItemBtnTouched)
	registerWidgetPushDownEvent(self.mRootWidget:getChildByName("Image_ShowDiamond"), onShowItemBtnTouched)
	registerWidgetPushDownEvent(self.mRootWidget:getChildByName("Image_ShowShizhuang"), onShowItemBtnTouched)
	registerWidgetPushDownEvent(self.mRootWidget:getChildByName("Image_ShowWeapon"), onShowItemBtnTouched)
	registerWidgetPushDownEvent(self.mRootWidget:getChildByName("Image_ShowConsumeItem"), onShowItemBtnTouched)

	-- 添加动画
	if not self.mDiamondComAnimNode then
		self.mDiamondComAnimNode = AnimManager:createAnimNode(8044)
		self.mDiamondComposeWindow:getChildByName("Panel_Animation_Bottom"):addChild(self.mDiamondComAnimNode:getRootNode(), 100)
		self.mDiamondComAnimNode:play("bagpack_diamond_bottom", true)
	end
end

function BagpackWindow:refresh()
	self.mItemListWidget:refresh()
end

-- 显示物品
function BagpackWindow:showItem(widget)
	if self.mLastChooseWidget == widget then
		return
	end

	if "Image_ShowAll" == widget:getName() then 			-- 全部
		self.mItemListWidget:switchDataSource(0)
	elseif "Image_ShowChips" == widget:getName() then 		-- 碎片
		self.mItemListWidget:switchDataSource(1)
	elseif "Image_ShowDiamond" == widget:getName() then
		self.mItemListWidget:switchDataSource(2)
	elseif "Image_ShowEquip" == widget:getName() then
		self.mItemListWidget:switchDataSource(3)
	elseif "Image_ShowShizhuang" == widget:getName() then
		self.mItemListWidget:switchDataSource(7)
	elseif "Image_ShowConsumeItem" == widget:getName() then
		self.mItemListWidget:switchDataSource(4)
	elseif "Image_ShowWeapon" == widget:getName() then
		self.mItemListWidget:switchDataSource(8)
	end

	local function replaceTexture()
		if self.mLastChooseWidget then
			self.mLastChooseWidget:loadTexture("backpack_page1.png")
			self.mLastChooseWidget = widget
		else
			self.mLastChooseWidget = widget
		end
		widget:loadTexture("backpack_page2.png")
	end
	-- 换菜单项图片
	replaceTexture()

	local function addAnim()
		-- 播放特效
		animNode = AnimManager:createAnimNode(8015)
		widget:getChildByName("Panel_Page_Animation"):addChild(animNode:getRootNode(), 100)
		animNode:play("bagpack_page_chose")
	end
	addAnim()
end

-- 物品响应点击
function BagpackWindow:itemOnClicked(widget, itemObj)
	-- 显示物品详情
	self:setItemDetailWindowVisible(true, widget, itemObj)
end

-- 显示物品详情窗口
function BagpackWindow:setItemDetailWindowVisible(visible, itemWiget, itemObj)
	if visible then -- 显示
		local price = nil

		if 2 == itemObj.itemType then -- 宝石
			local itemData = DB_Diamond.getDataById(itemObj.itemId)
			-- 显示物品
			local itemWidget = createDiamondWidget(itemObj.itemId, 0)
			itemWidget:getChildByName("Image_Quality"):setVisible(true)
			itemWidget:getChildByName("Image_Quality_Bg"):loadTexture("icon_item_quality_bg"..tostring(itemData.Quality)..".png", 1)
			self.mItemDetailWindow:getChildByName("Panel_ItemIcon"):removeAllChildren()
			self.mItemDetailWindow:getChildByName("Panel_ItemIcon"):addChild(itemWidget)
			itemWidget:getChildByName("Label_Count_Stroke"):setString("")
			-- 显示名字
			local nameId = itemData.Name
			local name = getDictionaryText(nameId)
			self.mItemDetailWindow:getChildByName("Label_ItemName"):setString(name)
			-- 单价
			price = itemData.Money
			self.mItemDetailWindow:getChildByName("Label_Price"):setString(tostring(price))	
			-- 数量
			local count = itemObj.itemNum
			self.mItemDetailWindow:getChildByName("Label_Own"):setString("当前拥有"..tostring(count).."件")
			self.mItemDetailWindow:getChildByName("Label_Own"):setVisible(true)
			-- 描述
			local itemDescId = itemData.description
			local DescText = getDictionaryText(itemDescId)
		--	self.mItemDetailWindow:getChildByName("Label_Des"):setString(DescText)
			local label = richTextCreate(self.mItemDetailWindow:getChildByName("Panel_Desc"), DescText, true)

			self.mItemDetailWindow:getChildByName("Panel_Detail"):setVisible(true)
			self.mItemDetailWindow:getChildByName("Panel_SellDetail"):setVisible(false)
			self.mItemDetailWindow:getChildByName("Panel_ItemDetail"):setVisible(true)
			self.mItemDetailWindow:getChildByName("Panel_BagButton"):setVisible(false)
			self.mItemDetailWindow:getChildByName("Panel_SellButton"):setVisible(false)
			self.mItemDetailWindow:getChildByName("Panel_UseDetail"):setVisible(false)
			self.mItemDetailWindow:getChildByName("Panel_UseButton"):setVisible(false)
			self.mItemDetailWindow:getChildByName("Panel_BagHeChengButton"):setVisible(true)
			-- 能否使用
			self.mItemDetailWindow:getChildByName("Button_use"):setVisible(false)
		elseif 1 == itemObj:getKeyValue("itemType") then -- 英雄碎片
			local newWidget = itemWiget:clone()
			newWidget:setTouchEnabled(false)
			newWidget:getChildByName("Label_Count_Stroke"):setVisible(false)
			self.mItemDetailWindow:getChildByName("Panel_ItemIcon"):removeAllChildren()
			self.mItemDetailWindow:getChildByName("Panel_ItemIcon"):addChild(newWidget)

			local itemData = DB_ItemConfig.getDataById(itemObj.itemId)
			-- 显示名字
			local nameId = itemData.Name
			local name = getDictionaryText(nameId)
			self.mItemDetailWindow:getChildByName("Label_ItemName"):setString(name)
			-- 数量
			local count = itemObj.itemNum
			self.mItemDetailWindow:getChildByName("Label_Own"):setString("当前拥有"..tostring(count).."件")
			self.mItemDetailWindow:getChildByName("Label_Own"):setVisible(true)
			-- 描述
			local itemDescId = itemData.Description
			local DescText = getDictionaryText(itemDescId)
		--	self.mItemDetailWindow:getChildByName("Label_Des"):setString(DescText)
			local label = richTextCreate(self.mItemDetailWindow:getChildByName("Panel_Desc"), DescText, true)

			self.mItemDetailWindow:getChildByName("Panel_Detail"):setVisible(true)
			self.mItemDetailWindow:getChildByName("Panel_SellDetail"):setVisible(false)
			self.mItemDetailWindow:getChildByName("Panel_ItemDetail"):setVisible(true)
			self.mItemDetailWindow:getChildByName("Panel_BagButton"):setVisible(true)
			self.mItemDetailWindow:getChildByName("Panel_SellButton"):setVisible(false)
			self.mItemDetailWindow:getChildByName("Panel_UseDetail"):setVisible(false)
			self.mItemDetailWindow:getChildByName("Panel_UseButton"):setVisible(false)
			self.mItemDetailWindow:getChildByName("Panel_BagHeChengButton"):setVisible(false)

			-- 单价
			price = itemData.Price
			self.mItemDetailWindow:getChildByName("Label_Price"):setString(tostring(price))	

			-- 能否使用
			if 1 == itemData.CanUse then
				self.mItemDetailWindow:getChildByName("Button_use"):setVisible(true)
				-- 再判断另一个字段
				if 3 == itemData.EffectID then
					self.mItemDetailWindow:getChildByName("Button_use"):setVisible(false)
				end
			elseif 0 == itemData.CanUse then
				self.mItemDetailWindow:getChildByName("Button_use"):setVisible(false)
			end
		elseif -1 == itemObj:getKeyValue("itemType") then
			local itemData = DB_EquipmentConfig.getDataById(itemObj.itemId)
			-- 显示时装和装备
			local itemWidget = createEquipWidget(itemObj.itemId, 1)
			itemWidget:getChildByName("Image_Quality"):setVisible(true)
			itemWidget:getChildByName("Image_Quality_Bg"):loadTexture("icon_item_quality_bg"..tostring(itemData.Quality)..".png", 1)

			self.mItemDetailWindow:getChildByName("Panel_ItemIcon"):removeAllChildren()
			self.mItemDetailWindow:getChildByName("Panel_ItemIcon"):addChild(itemWidget)
			itemWidget:getChildByName("Label_Count_Stroke"):setString("")

			local itemData = DB_EquipmentConfig.getDataById(itemObj.itemId)
			-- 显示名字
			local nameId = itemData.Name
			local name = getDictionaryText(nameId)
			self.mItemDetailWindow:getChildByName("Label_ItemName"):setString(name)

			-- 描述
			local itemDescId = itemData.EquipText
			local DescText = getDictionaryText(itemDescId)
		--	self.mItemDetailWindow:getChildByName("Label_Des"):setString(DescText)
			local label = richTextCreate(self.mItemDetailWindow:getChildByName("Panel_Desc"), DescText, true)

			-- 单价
			price = itemData.Price
			self.mItemDetailWindow:getChildByName("Label_Price"):setString(tostring(price))

			self.mItemDetailWindow:getChildByName("Panel_Detail"):setVisible(true)
			self.mItemDetailWindow:getChildByName("Panel_SellDetail"):setVisible(false)
			self.mItemDetailWindow:getChildByName("Panel_ItemDetail"):setVisible(true)
			self.mItemDetailWindow:getChildByName("Panel_BagButton"):setVisible(true)
			self.mItemDetailWindow:getChildByName("Panel_SellButton"):setVisible(false)	
			self.mItemDetailWindow:getChildByName("Panel_UseDetail"):setVisible(false)
			self.mItemDetailWindow:getChildByName("Panel_UseButton"):setVisible(false)
			self.mItemDetailWindow:getChildByName("Panel_BagHeChengButton"):setVisible(false)

			-- 装备不显示数量
			self.mItemDetailWindow:getChildByName("Label_Own"):setVisible(false)

			-- 能否使用
			self.mItemDetailWindow:getChildByName("Button_use"):setVisible(false)
		else
			local itemData = DB_ItemConfig.getDataById(itemObj.itemId)
			-- 显示物品
			local itemWidget = createItemWidget(itemObj.itemId)
			self.mItemDetailWindow:getChildByName("Panel_ItemIcon"):removeAllChildren()
			self.mItemDetailWindow:getChildByName("Panel_ItemIcon"):addChild(itemWidget)
			itemWidget:getChildByName("Label_Count_Stroke"):setString("")
			-- 显示品质
			itemWidget:getChildByName("Image_Quality"):setVisible(true)
			itemWidget:getChildByName("Image_Quality_Bg"):loadTexture("icon_item_quality_bg"..tostring(itemData.Quality)..".png", 1)
			-- 显示名字
			local nameId = itemData.Name
			local name = getDictionaryText(nameId)
			self.mItemDetailWindow:getChildByName("Label_ItemName"):setString(name)
			-- 单价
			price = itemData.Price
			self.mItemDetailWindow:getChildByName("Label_Price"):setString(tostring(price))	
			-- 数量
			local count = itemObj.itemNum
			self.mItemDetailWindow:getChildByName("Label_Own"):setString("当前拥有"..tostring(count).."件")
			self.mItemDetailWindow:getChildByName("Label_Own"):setVisible(true)
			-- 描述
			local itemDescId = itemData.Description
			local DescText = getDictionaryText(itemDescId)
		--	self.mItemDetailWindow:getChildByName("Label_Des"):setString(DescText)
			local label = richTextCreate(self.mItemDetailWindow:getChildByName("Panel_Desc"), DescText, true)
		--	label:setFontSize(18)

			self.mItemDetailWindow:getChildByName("Panel_Detail"):setVisible(true)
			self.mItemDetailWindow:getChildByName("Panel_SellDetail"):setVisible(false)
			self.mItemDetailWindow:getChildByName("Panel_ItemDetail"):setVisible(true)
			self.mItemDetailWindow:getChildByName("Panel_BagButton"):setVisible(true)
			self.mItemDetailWindow:getChildByName("Panel_SellButton"):setVisible(false)
			self.mItemDetailWindow:getChildByName("Panel_UseDetail"):setVisible(false)
			self.mItemDetailWindow:getChildByName("Panel_UseButton"):setVisible(false)	
			self.mItemDetailWindow:getChildByName("Panel_BagHeChengButton"):setVisible(false)

			-- 能否使用
			if 1 == itemData.CanUse then
				self.mItemDetailWindow:getChildByName("Button_use"):setVisible(true)
				-- 再判断另一个字段
				if 3 == itemData.EffectID then
					self.mItemDetailWindow:getChildByName("Button_use"):setVisible(false)
				end
			elseif 0 == itemData.CanUse then
				self.mItemDetailWindow:getChildByName("Button_use"):setVisible(false)
			end
		end

		-- 显示使用窗口
		local function showUseWindow()
			if 1 == itemObj:getKeyValue("itemType") then -- 是碎片
				local itemData = DB_ItemConfig.getDataById(itemObj.itemId)
				Event.GUISYSTEM_SHOW_HEROINFOWINDOW.mData    = {}
				Event.GUISYSTEM_SHOW_HEROINFOWINDOW.mData[1] = itemData.para2   -- 当前选择英雄索引
				Event.GUISYSTEM_SHOW_HEROINFOWINDOW.mData[2] = 1    			-- 显示培养
				Event.GUISYSTEM_SHOW_HEROINFOWINDOW.mData[3] = 2    			-- 显示升星界面
   				EventSystem:PushEvent(Event.GUISYSTEM_SHOW_HEROINFOWINDOW)
				return
			end
			self:setItemUseWindowVisible(true, itemObj)
		end
		registerWidgetReleaseUpEvent(self.mItemDetailWindow:getChildByName("Button_use"), showUseWindow)

		-- 显示出售窗口
		local function showSellWindow()
			if -1 ~= itemObj:getKeyValue("itemType") then -- 普通物品
				self:setItemSellWindowVisible(true, itemObj, price)
			else
				local function doOk()
					local packet = NetSystem.mNetManager:GetSPacket()
				    packet:SetType(PacketTyper._PTYPE_CS_REQUEST_SELLEQUIP_)
					packet:PushString(itemObj:getKeyValue("itemGUID"))
				    packet:Send()
				    GUISystem:showLoading()
				    self:setItemSellWindowVisible(false)
				end
				MessageBox:showMessageBox2("确定出售?", doOk)
			end
		end
		registerWidgetReleaseUpEvent(self.mItemDetailWindow:getChildByName("Panel_BagButton"):getChildByName("Button_sell"), showSellWindow)
		registerWidgetReleaseUpEvent(self.mItemDetailWindow:getChildByName("Panel_BagHeChengButton"):getChildByName("Button_sell"), showSellWindow)
	
		-- 显示合成窗口
		local function showComposeWindow()
			-- 显示目标宝石
			local itemData = DB_Diamond.getDataById(itemObj.itemId)
			local targetId = itemData.NextID
			if -1 == targetId then
				MessageBox:showMessageBox1("当前宝石已经是最高级,无法再进行合成操作哟~")
				return
			end

		--	self.mItemDetailWindow:setVisible(false)
			self.mDiamondComposeWindow:setVisible(true)

			local function createDiamondFunc(id)
				local itemWidget = createDiamondWidget(id, 0)
				itemWidget:getChildByName("Image_Quality"):setVisible(true)
				itemWidget:getChildByName("Label_Count_Stroke"):setString("")
				return itemWidget
			end

			local diamondWidget = createDiamondFunc(targetId)
			self.mDiamondComposeWindow:getChildByName("Panel_Diamond_Mid"):removeAllChildren()
			self.mDiamondComposeWindow:getChildByName("Panel_Diamond_Mid"):addChild(diamondWidget)
			diamondWidget:getChildByName("Image_Quality_Bg"):setVisible(false)
			diamondWidget:getChildByName("Image_Quality"):setVisible(false)
			-- 更换品质图片
			local diamondData = DB_Diamond.getDataById(targetId)
			local quality = diamondData.Quality
			self.mDiamondComposeWindow:getChildByName("Image_Dianond_Mid_Bg"):loadTexture(string.format("backpack_diamond_quality_%d.png", quality))
				
			local function updateDiamondCnt()
				local count = globaldata:getItemOwnCount(itemObj.itemId)
				if count >= 5 then
					count = 5
				end

				-- 清理
				for i = 1, 5 do
					self.mDiamondComposeWindow:getChildByName(string.format("Panel_Diamond_%d",i)):removeAllChildren()
				end

				-- 还原图
				for i = 1, 5 do
					self.mDiamondComposeWindow:getChildByName(string.format("Image_Dianond_%d_Bg",i)):loadTexture("backpack_diamond_com_itembg.png")
				end

				-- 显示材料宝石
				for i = 1, count do
					local diamondWidget = createDiamondFunc(itemObj.itemId)
					self.mDiamondComposeWindow:getChildByName(string.format("Panel_Diamond_%d",i)):addChild(diamondWidget)
					diamondWidget:getChildByName("Image_Quality_Bg"):setVisible(false)
					diamondWidget:getChildByName("Image_Quality"):setVisible(false)
					-- 更换品质图片
					local diamondData = DB_Diamond.getDataById(itemObj.itemId)
					local quality = diamondData.Quality
					self.mDiamondComposeWindow:getChildByName(string.format("Image_Dianond_%d_Bg",i)):loadTexture(string.format("backpack_diamond_quality_%d.png", quality))
				end

				-- 显示文字
				self.mDiamondComposeWindow:getChildByName("Label_Com_Most"):setString("合成"..tostring(math.floor(itemObj.itemNum/5)).."个")
				self.mDiamondComposeWindow:setVisible(true)
			end
			updateDiamondCnt()

			local function onRequestDoCompose(info)
				if self.mRootNode then
				--	if self.mItemDetailWindow then
				--		self.mItemDetailWindow:setVisible(false)
				--	end

					-- if self.mOnDiamondComFunc then
					-- 	GUIEventManager:unregister("itemInfoChanged", self.mOnDiamondComFunc)
					-- 	self.mOnDiamondComFunc = nil
					-- end
					
					-- 显示文字
					self.mDiamondComposeWindow:getChildByName("Label_Com_Most"):setString("合成"..tostring(math.floor(globaldata:getItemOwnCount(itemObj.itemId)/5)).."个")
				end

				local animNode = AnimManager:createAnimNode(8041)
				self.mDiamondComposeWindow:getChildByName("Panel_Animation_Top"):addChild(animNode:getRootNode(), 100)

				local function onAnimPlayEnd()
					-- 刷新出下一次的
					updateDiamondCnt()
					-- 销毁动画
					animNode:destroy()
				end

				local function onAnimPlayBegin(evtName)
					if "happen" == evtName then
						for i = 1, 5 do
						--	local childTbl = self.mDiamondComposeWindow:getChildByName(string.format("Panel_Diamond_%d",i)):getChildren()
						--	if childTbl[1] then
						--		childTbl[1]:setVisible(false)
						--	end
							self.mDiamondComposeWindow:getChildByName(string.format("Panel_Diamond_%d",i)):removeAllChildren()
						end
					end
				end

				animNode:play("bagpack_diamond_com_top", false, onAnimPlayEnd, onAnimPlayBegin)
			end

			if self.mOnDiamondComFunc then
				GUIEventManager:unregister("itemInfoChanged", self.mOnDiamondComFunc)
				self.mOnDiamondComFunc = nil
			end

			GUIEventManager:registerEvent("itemInfoChanged", nil, onRequestDoCompose)
			self.mOnDiamondComFunc = onRequestDoCompose

			local function requestDoCompose(widget)
				local count = globaldata:getItemOwnCount(itemObj.itemId)
				if count < 5 then
					MessageBox:showMessageBox1("宝石数量不够哦亲~~")
					return
				end
				local packet = NetSystem.mNetManager:GetSPacket()
				packet:SetType(PacketTyper._PTYPE_CS_COMPOSE_DIAMOND_)
				packet:PushUShort(itemObj.itemId)
				packet:PushChar(widget:getTag())
				packet:Send()
				GUISystem:showLoading()
			end
			registerWidgetReleaseUpEvent(self.mDiamondComposeWindow:getChildByName("Button_Com_1"), requestDoCompose)
			self.mDiamondComposeWindow:getChildByName("Button_Com_1"):setTag(1)
			registerWidgetReleaseUpEvent(self.mDiamondComposeWindow:getChildByName("Button_Com_Most"), requestDoCompose)
			self.mDiamondComposeWindow:getChildByName("Button_Com_Most"):setTag(2)

			local function closeComposeWindow()

				if self.mOnDiamondComFunc then
					GUIEventManager:unregister("itemInfoChanged", self.mOnDiamondComFunc)
					self.mOnDiamondComFunc = nil
				end

		--		self.mItemDetailWindow:setVisible(true)
				self.mDiamondComposeWindow:setVisible(false)
			end
			registerWidgetReleaseUpEvent(self.mDiamondComposeWindow:getChildByName("Button_Back"), closeComposeWindow)
		end
		registerWidgetReleaseUpEvent(self.mItemDetailWindow:getChildByName("Panel_BagHeChengButton"):getChildByName("Button_HeCheng"), showComposeWindow)
	else -- 隐藏
		
	end
	self.mItemDetailWindow:setVisible(visible)
end

-- 显示物品使用窗口
function BagpackWindow:setItemUseWindowVisible(visible, itemObj)
	local itemId = nil
	local sellCount = nil
	local totalCount = nil

	if visible then
		itemId = itemObj:getKeyValue("itemId")
		sellCount = 1
		local tempItem = globaldata:getItemInfo(nil, itemId)
		if tempItem then
			totalCount = tempItem.itemNum
		else
			return
		end

		local itemId1 = {20501, 20504}
		local itemId2 = {20502, 20505}
		local itemId3 = {20503, 20506}

		-- 判断是否是金宝箱或者金钥匙
		if itemId == itemId1[1] or itemId == itemId1[2] then
			local total1 = 0
			local total2 = 0
			local obj1 = globaldata:getItemInfo(nil, itemId1[1])
			if obj1 then
				total1 = obj1.itemNum
			end
			local obj2 = globaldata:getItemInfo(nil, itemId1[2])
			if obj2 then
				total2 = obj2.itemNum
			end

			if 0 == total1 or  0 == total2 then
				MessageBox:showMessageBox1("金宝箱或金钥匙数量不足")
				return
			end
			totalCount = math.min(total1, total2)
		end

		-- 判断是否是银宝箱或者银钥匙
		if itemId == itemId2[1] or itemId == itemId2[2] then
			local total1 = 0
			local total2 = 0
			local obj1 = globaldata:getItemInfo(nil, itemId2[1])
			if obj1 then
				total1 = obj1.itemNum
			end
			local obj2 = globaldata:getItemInfo(nil, itemId2[2])
			if obj2 then
				total2 = obj2.itemNum
			end

			if 0 == total1 or  0 == total2 then
				MessageBox:showMessageBox1("银宝箱或银钥匙数量不足")
				return
			end
			totalCount = math.min(total1, total2)
		end

		-- 判断是否是铜宝箱或者铜钥匙
		if itemId == itemId3[1] or itemId == itemId3[2] then
			local total1 = 0
			local total2 = 0
			local obj1 = globaldata:getItemInfo(nil, itemId3[1])
			if obj1 then
				total1 = obj1.itemNum
			end
			local obj2 = globaldata:getItemInfo(nil, itemId3[2])
			if obj2 then
				total2 = obj2.itemNum
			end

			if 0 == total1 or  0 == total2 then
				MessageBox:showMessageBox1("铜宝箱或铜钥匙数量不足")
				return
			end
			totalCount = math.min(total1, total2)
		end
	end

	if visible then
		self.mRootWidget:getChildByName("Image_Smbg"):setVisible(false)
		self.mItemDetailWindow:getChildByName("Panel_Detail"):setVisible(true)
		self.mItemDetailWindow:getChildByName("Panel_SellDetail"):setVisible(false)
		self.mItemDetailWindow:getChildByName("Panel_ItemDetail"):setVisible(false)
		self.mItemDetailWindow:getChildByName("Panel_BagButton"):setVisible(false)
		self.mItemDetailWindow:getChildByName("Panel_SellButton"):setVisible(true)
		self.mItemDetailWindow:getChildByName("Panel_UseDetail"):setVisible(true)
		self.mItemDetailWindow:getChildByName("Panel_UseButton"):setVisible(true)

		local function updateCount()
			self.mItemDetailWindow:getChildByName("Panel_UseDetail"):getChildByName("Label_CountPercent"):setString(tostring(sellCount).."/"..tostring(totalCount))
		end
		updateCount()

		local function doChangeCount(widget)
			if -1 == widget:getTag() then
				sellCount = sellCount - 1
			elseif 1 == widget:getTag() then
				sellCount = sellCount + 1
			elseif 2 == widget:getTag() then
				sellCount = totalCount
			end

			if sellCount < 1 then
				sellCount = 1
			elseif sellCount > totalCount then
				sellCount = totalCount
			end
			updateCount()
		end
		registerWidgetReleaseUpEvent(self.mItemDetailWindow:getChildByName("Panel_UseDetail"):getChildByName("Button_Minus"), doChangeCount)
		self.mItemDetailWindow:getChildByName("Panel_UseDetail"):getChildByName("Button_Minus"):setTag(-1)
		registerWidgetReleaseUpEvent(self.mItemDetailWindow:getChildByName("Panel_UseDetail"):getChildByName("Button_Add"), doChangeCount)
		self.mItemDetailWindow:getChildByName("Panel_UseDetail"):getChildByName("Button_Add"):setTag(1)
		registerWidgetReleaseUpEvent(self.mItemDetailWindow:getChildByName("Panel_UseDetail"):getChildByName("Button_Most"), doChangeCount)
		self.mItemDetailWindow:getChildByName("Panel_UseDetail"):getChildByName("Button_Most"):setTag(2)

		-- 使用
		local function doUse()
			local packet = NetSystem.mNetManager:GetSPacket()
		    packet:SetType(PacketTyper._PTYPE_CS_REQUEST_USEITEM_)
		    packet:PushInt(itemObj.itemId)
		    packet:PushInt(sellCount)
		    GUISystem:showLoading()
		    packet:Send()
		    self:setItemUseWindowVisible(false)
		end
		
		registerWidgetReleaseUpEvent(self.mItemDetailWindow:getChildByName("Panel_UseButton"):getChildByName("Button_Confirm"), doUse)

		-- 关闭出售窗口
		local function hideUseWindow()
			self:setItemUseWindowVisible(false)
		end
		registerWidgetReleaseUpEvent(self.mItemDetailWindow:getChildByName("Panel_UseButton"):getChildByName("Button_Back"), hideUseWindow)
	else
		self.mRootWidget:getChildByName("Image_Smbg"):setVisible(true)
		self.mItemDetailWindow:getChildByName("Panel_Detail"):setVisible(true)
		self.mItemDetailWindow:getChildByName("Panel_SellDetail"):setVisible(false)
		self.mItemDetailWindow:getChildByName("Panel_ItemDetail"):setVisible(true)
		self.mItemDetailWindow:getChildByName("Panel_BagButton"):setVisible(true)
		self.mItemDetailWindow:getChildByName("Panel_SellButton"):setVisible(false)
		self.mItemDetailWindow:getChildByName("Panel_UseDetail"):setVisible(false)
		self.mItemDetailWindow:getChildByName("Panel_UseButton"):setVisible(false)
	end
end

-- 显示物品出售窗口
function BagpackWindow:setItemSellWindowVisible(visible, itemObj, price)
	if visible then
		self.mItemDetailWindow:getChildByName("Panel_Detail"):setVisible(true)
		self.mItemDetailWindow:getChildByName("Panel_SellDetail"):setVisible(true)
		self.mItemDetailWindow:getChildByName("Panel_ItemDetail"):setVisible(false)
		self.mItemDetailWindow:getChildByName("Panel_BagButton"):setVisible(false)
		self.mItemDetailWindow:getChildByName("Panel_SellButton"):setVisible(true)

		local itemId = itemObj:getKeyValue("itemId")
		local sellCount = 1
		local totalCount = globaldata:getItemInfo(nil, itemId).itemNum
		local totalPrice = 0

		local function updateCount()
			self.mItemDetailWindow:getChildByName("Panel_SellDetail"):getChildByName("Label_CurCount"):setString(tostring(sellCount))
			totalPrice = sellCount*price
			self.mItemDetailWindow:getChildByName("Panel_SellDetail"):getChildByName("Label_Money"):setString(tostring(totalPrice))
			self.mItemDetailWindow:getChildByName("Panel_SellDetail"):getChildByName("Label_CountPercent"):setString(tostring(sellCount).."/"..tostring(totalCount))
		end
		updateCount()

		local function doChangeCount(widget)

			if -1 == widget:getTag() then
				sellCount = sellCount - 1
			elseif 1 == widget:getTag() then
				sellCount = sellCount + 1
			elseif 2 == widget:getTag() then
				sellCount = totalCount
			end

			if sellCount < 1 then
				sellCount = 1
			elseif sellCount > totalCount then
				sellCount = totalCount
			end
			updateCount()
		end
		registerWidgetReleaseUpEvent(self.mItemDetailWindow:getChildByName("Panel_SellDetail"):getChildByName("Button_Minus"), doChangeCount)
		registerWidgetReleaseUpEvent(self.mItemDetailWindow:getChildByName("Panel_SellDetail"):getChildByName("Button_Add"), doChangeCount)
		registerWidgetReleaseUpEvent(self.mItemDetailWindow:getChildByName("Panel_SellDetail"):getChildByName("Button_Most"), doChangeCount)

		-- 出售
		local function doSell()
			local packet = NetSystem.mNetManager:GetSPacket()
		    packet:SetType(PacketTyper._PTYPE_CS_REQUEST_SELLITEM_)
		    packet:PushUShort(1)
			packet:PushInt(itemId)
			packet:PushInt(sellCount)
		    packet:Send()
		    GUISystem:showLoading()
		    self:setItemSellWindowVisible(false)
		end
		registerWidgetReleaseUpEvent(self.mItemDetailWindow:getChildByName("Button_Confirm"), doSell)

		-- 关闭出售窗口
		local function hideSellWindow()
			self:setItemSellWindowVisible(false)
		end
		registerWidgetReleaseUpEvent(self.mItemDetailWindow:getChildByName("Button_Back"), hideSellWindow)
	else
		self.mItemDetailWindow:getChildByName("Panel_Detail"):setVisible(true)
		self.mItemDetailWindow:getChildByName("Panel_SellDetail"):setVisible(false)
		self.mItemDetailWindow:getChildByName("Panel_ItemDetail"):setVisible(true)
		self.mItemDetailWindow:getChildByName("Panel_BagButton"):setVisible(true)
		self.mItemDetailWindow:getChildByName("Panel_SellButton"):setVisible(false)
	end
end

-- 刷新
function BagpackItemList:refresh()
	self:switchDataSource(self.mType)
end

function BagpackWindow:Destroy()

	GUIEventManager:unregister("itemInfoChanged", self.refresh)

	if self.mDiamondComAnimNode then
		self.mDiamondComAnimNode:destroy()
		self.mDiamondComAnimNode = nil
	end

	self.mItemListWidget:destroy()

	self.mDiamondComposeWindow = nil

	if self.mOnDiamondComFunc then
		GUIEventManager:unregister("itemInfoChanged", self.mOnDiamondComFunc)
		self.mOnDiamondComFunc = nil
	end

	self.mTopRoleInfoPanel:destroy()
	self.mTopRoleInfoPanel = nil

	self.mLastChooseWidget = nil

	self.mRootNode:removeFromParent(true)
	self.mRootNode = nil
	self.mRootWidget = nil
end

function BagpackWindow:onEventHandler(event)
	if event.mAction == Event.WINDOW_SHOW then
		self:Load(event)
		---------停止画主城镇界面
		EventSystem:PushEvent(Event.GUISYSTEM_DISABLEDRAW_HOMEWINDOW)
	elseif event.mAction == Event.WINDOW_HIDE then
		self:Destroy()
		---------开启画主城镇界面
		EventSystem:PushEvent(Event.GUISYSTEM_EABLEDRAW_HOMEWINDOW)
	end
end

return BagpackWindow