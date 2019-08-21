-- Name: 	FurnitObject
-- Func：	家具对象
-- Author:	WangShengdong
-- Data:	15-5-20

FurnitWidget = {}

function FurnitWidget:new()
	local o = 
	{
		mOwner  		=	nil, 	-- 持有者
		mRootNode 		=	nil, 	-- 根节点
		mIsNew			=	nil, 	-- 是否是新的
		mItemId 		=	nil, 	-- 物品Id
		mItemGuid 		=	nil, 	-- GUID
		mAnimCfgId 		=	nil, 	-- 场景道具资源Id
		mSize 			=	nil, 	-- 脚底矩形框
		mMoveable		=	false,	-- 是否可以移动
		mBtnOk 			=	nil,	-- 确认按钮
		mBtnCancel 		=	nil,	-- 取消按钮
		mStartPos 		=	nil,	-- 初始位置
	}
	o = newObject(o, FurnitWidget)
	return o
end

function FurnitWidget:destroy()
	self.mRootNode:removeFromParent(true)
end

function FurnitWidget:setBlink(blink)
	if blink then
		local act0 = cc.FadeOut:create(0.5)
		local act1 = cc.FadeIn:create(0.5)
		local act2 = cc.Sequence:create(act0, act1)
		self.mAnimNode:runAction(cc.RepeatForever:create(act2))
	else
		self.mAnimNode:setOpacity(255)
		self.mAnimNode:stopAllActions()
	end
end

-- 获得脚的矩形框
function FurnitWidget:getFootRect()
	local curPos = self:getPosition()
	return cc.rect(curPos.x - self.mSize.width/2, curPos.y - self.mSize.height/2, self.mSize.width, self.mSize.height)
end

-- 碰撞检查
function FurnitWidget:checkCollision()
	local furnitList = self.mOwner.mFurnitList
	local ret = false
	-- 与其他建筑检查
	for i = 1, #furnitList do
		if self ~= furnitList[i] then
			local selfRect = self:getFootRect()
			local otherRect = furnitList[i]:getFootRect()
			ret = cc.rectIntersectsRect(selfRect, otherRect)
			if ret then
				break
			end
		end
	end

	-- 与地面检查
	if 1 == FightSystem:getMapInfo(self:getPosition()) then -- 可达

	else -- 不可达
		ret = true
	end

	self:setOkBtnVisible(not ret)
end

function FurnitWidget:onTouch(widget, eventType)
	if eventType == ccui.TouchEventType.began then
		self:setMoveable(true)
	elseif eventType == ccui.TouchEventType.ended then
		if not self.mOwner:getMovingFurnit() and GUISystem:GetWindowByName("HomeWindow"):getBuildMode() then
			self.mOwner:setMovingFurnit(self)
		end
	elseif eventType == ccui.TouchEventType.moved then

	elseif eventType == ccui.TouchEventType.canceled then

	end
end

-- 创建根节点
function FurnitWidget:createRootNode()
	local itemData = DB_ItemConfig.getDataById(self.mItemId)
	self.mAnimCfgId = itemData.Animation
	local configInfo = DB_SceneAnimationConfig.getDataById(self.mAnimCfgId)
	local resInfo = DB_ResourceList.getDataById(configInfo.Animation_ResID)
	self.mAnimNode = CommonAnimation.createSpine_common(resInfo.Res_path2, resInfo.Res_path1, 1)
	self.mSize = cc.size(configInfo.Animation_FootSize[1], configInfo.Animation_FootSize[2])

	-- 初始化跟节点
	self.mRootNode = ccui.Layout:create()
	self.mRootNode:setTouchEnabled(true)
	self.mRootNode:addTouchEventListener(handler(self, self.onTouch))

	local function doOk()
		local curPos = self:getPosition()
		local packet = NetSystem.mNetManager:GetSPacket()
		packet:SetType(PacketTyper._PTYPE_CS_FURNITURE_MOVE_)
		packet:PushString(self.mItemGuid)
		packet:PushInt(self.mItemId)
		packet:PushUShort(curPos.x)
		packet:PushUShort(curPos.y)
		packet:Send()
		GUISystem:showLoading()
		self.mOwner:stopEditMode()
	end
	-- 确认按钮
	self.mBtnOk = ccui.Button:create()
	self.mBtnOk:setTouchEnabled(true)
 	self.mBtnOk:loadTextures("right.png", "", "")
 	registerWidgetReleaseUpEvent(self.mBtnOk, doOk)

 	local function doCancel()
 		if self.mIsNew then
 			self.mOwner:removeNewFurnit()
 			self.mOwner:stopEditMode()
 		else
 			self.mOwner:removeMovingFurnit()
 		end
	end
 	-- 取消按钮
	self.mBtnCancel = ccui.Button:create()
	self.mBtnCancel:setTouchEnabled(true)
 	self.mBtnCancel:loadTextures("wrong.png", "", "")
 	registerWidgetReleaseUpEvent(self.mBtnCancel, doCancel)

	local function reSize()
		local newSize = self.mAnimNode:getBoundingBox()
		self.mRootNode:setContentSize(newSize)
		self.mAnimNode:setPosition(cc.p(newSize.width/2, 0))
		self.mAnimNode:setVisible(true)
		self.mBtnCancel:setPosition(cc.p(self.mSize.width, 0))
	end
	nextTick(reSize)

	self.mRootNode:addChild(self.mAnimNode)
	self.mRootNode:addChild(self.mBtnOk)
	self.mRootNode:addChild(self.mBtnCancel)
	self.mAnimNode:setVisible(false)
end

function FurnitWidget:setOkBtnVisible(visible)
	self.mBtnOk:setVisible(visible)
end

function FurnitWidget:setCancelBtnVisible(visible)
	self.mBtnCancel:setVisible(visible)
end

function FurnitWidget:init(owner, resId, guid, isNew)
	self.mOwner = owner
	self.mItemId = resId
	self.mItemGuid = guid
	self.mIsNew = isNew
	self:createRootNode()

	-- 隐藏按钮
	self:setOkBtnVisible(false)
	self:setCancelBtnVisible(false)
end

-- 设置可以移动
function FurnitWidget:setMoveable(moveable)
	self.mMoveable = moveable
end

-- 获取是否可以移动
function FurnitWidget:getMoveable()
	return self.mMoveable
end

function FurnitWidget:getRootNode()
	return self.mRootNode
end

function FurnitWidget:setPosition(pos)
	self.mRootNode:setPosition(pos)
	self.mRootNode:setLocalZOrder(1440 - (pos.y + 1))
end

function FurnitWidget:getPosition()
	return cc.p(self.mRootNode:getPosition())
end

function FurnitWidget:setLocalZOrder(ZOrder)
	self.mRootNode:setLocalZOrder(ZOrder)
end

function FurnitWidget:getFootSize()
	return self.mSize
end

FurnitManager = {}

function FurnitManager:new()
	local o = 
	{
		mParentNode 			=	nil,	-- 父节点
		mRootNode 				= 	nil,	-- 跟节点
		mFurnitList 			=	{},	 	-- 家具链表
		mTouchLayer 			=	nil,	-- 触摸层
		----------------------------------------------------------
		mTblViewWidget 			=	nil, 	-- 背包
		mSchedulerHandler		=	nil,	-- 定时器
		mTickCount 				=	0,		-- 计时点
		mlastClickedItemIndex	=	nil,	-- 最后一次点击的序号
		mMovingFurObject 		=	nil,	-- 移动中的spine
		mLastClickedScreenPos 	=	nil,	-- 最后一次点击的屏幕坐标
		mfurnitListOutHouse 	=	nil, 
		mNewFurnit 				=	nil, 	-- 新家具
		mMovingFurnit 			=	nil, 	-- 移动家具
	}
	o = newObject(o, FurnitManager)
	return o
end

function FurnitManager:destroy()
	GUIEventManager:unregister("furnitChanged", self.onFurnitChanged)
	self.mRootNode:removeFromParent(true)
	self.mTouchLayer:removeFromParent(true)
	GUISystem:GetWindowByName("HomeWindow").mBuildPanel:setVisible(false)
end

-- 刷新数据
function FurnitManager:reloadData()
	-- 设置
	self.mTblViewWidget:setCellCount(#self.mfurnitListOutHouse)
	-- 刷界面
	self.mTblViewWidget:reloadData()
end

-- 编辑模式
function FurnitManager:setEditMode(boolVal)
	self.mEditMode = boolVal
	for i = 1, #self.mFurnitList do
		-- 设置可编辑
		self.mFurnitList[i]:setEditMode(boolVal)
	end
end

-- 移除模式
function FurnitManager:setDelMode(boolVal)
	self.mDelMode = boolVal
	for i = 1, #self.mFurnitList do
		-- 设置可编辑
		self.mFurnitList[i]:setDelMode(boolVal)
	end
end

-- 显示背包
function FurnitManager:setBagVisible(visible)
	GUISystem:GetWindowByName("HomeWindow").mBuildBagPanel:setVisible(visible)
end

-- 初始化数据
function FurnitManager:getDataFromGlobal()
	self.mfurnitListOutHouse = {}

	for i = 1, #globaldata.furnitListOutHouse do
		self.mfurnitListOutHouse[i] = furnitObject:new()
		self.mfurnitListOutHouse[i].mGuid = globaldata.furnitListOutHouse[i].mGuid
		self.mfurnitListOutHouse[i].mId = globaldata.furnitListOutHouse[i].mId
	end
end

-- 家具变化
function FurnitManager:onFurnitChanged(evtType, furnitObj, posX, posY)
	if "move" == evtType then -- 移动
		local rect = self.mMovingFurnit:getFootRect()
		-- 阻挡(-)
		FightSystem:setMapInfoForRect(cc.p(posX, posY), rect.width, rect.height, 1)
		-- 阻挡(+)
		FightSystem:setMapInfoForRect(cc.p(furnitObj.mPosX, furnitObj.mPosY), rect.width, rect.height, 0)
		-- 清除
		self.mMovingFurnit:setCancelBtnVisible(false)
		self.mMovingFurnit:setOkBtnVisible(false)
		-- 闪烁
		self.mMovingFurnit:setBlink(false)
		-- 清空
		self.mMovingFurnit = nil
	elseif "add" == evtType then -- 添加
		-- 插入
		table.insert(self.mFurnitList, self.mNewFurnit)
		self.mNewFurnit.mIsNew = false
		self.mNewFurnit:setOkBtnVisible(false)
		self.mNewFurnit:setCancelBtnVisible(false)
		-- 阻挡
		local rect = self.mNewFurnit:getFootSize()
		FightSystem:setMapInfoForRect(cc.p(furnitObj.mPosX, furnitObj.mPosY), rect.width, rect.height, 0)
		-- 清除
		self.mNewFurnit = nil
		self:reloadData()
		self:setBagVisible(true)
	elseif "del" == evtType then -- 删除
		for i = 1, #self.mFurnitList do
			if furnitObj.mGuid == self.mFurnitList[i].mItemGuid then
				-- 清除原来位置信息
				local rect = self.mFurnitList[i]:getFootRect()
				local prePos = self.mFurnitList[i]:getPosition()
				FightSystem:setMapInfoForRect(cc.p(rect.x+prePos.x, rect.y), rect.width, rect.height, 1)
				self.mFurnitList[i]:destroy()
				table.remove(self.mFurnitList, i)
				break
			end
		end
	end
end

function FurnitManager:startTick()
	self.mTickCount = 0
	local scheduler = cc.Director:getInstance():getScheduler()
	self.mSchedulerHandler = scheduler:scheduleScriptFunc(handler(self, self.tick), 0.1, false)
end

function FurnitManager:tick()
	self.mTickCount = self.mTickCount + 0.1
	if self.mTickCount > 0.15 then
		self:startEditMode()
		self:stopTick()
	end
end

-- 开启编辑模式
function FurnitManager:startEditMode()
	self.mTblViewWidget:setTouchEnabled(false)
	-- 创建spine
	self:addNewFurnit(self.mfurnitListOutHouse[self.mlastClickedItemIndex + 1])
	-- 移除table
	table.remove(self.mfurnitListOutHouse, self.mlastClickedItemIndex + 1)
	-- reload
	self:reloadData()
	-- 隐藏背包
	self:setBagVisible(false)
end

-- 编辑模式
function FurnitManager:stopEditMode()
	self.mTblViewWidget:setTouchEnabled(true)
	-- 显示背包
	self:setBagVisible(true)
end

function FurnitManager:stopTick()
	self.mTickCount = 0
	local scheduler = cc.Director:getInstance():getScheduler()
	if self.mSchedulerHandler then
		scheduler:unscheduleScriptEntry(self.mSchedulerHandler)
		self.mSchedulerHandler = nil
	end
end

local function getLength(p1, p2)
	return math.sqrt( (p1.x-p2.x)*(p1.x-p2.x) + (p1.y-p2.y)*(p1.y-p2.y) ) 
end

local startPos = nil
local movedPos = nil
function FurnitManager:initFurnitBag()
	local function tableCellAtIndex(table, index)
		local cell = table:dequeueCell()
		local function updateCellInfo() -- 更新格子信息
			local itemWidget = cell:getChildByTag(1)
			local furnitObj = self.mfurnitListOutHouse[index+1]
			local itemData = DB_ItemConfig.getDataById(furnitObj.mId)
			local itemIconId = itemData.IconID
			local imgName = DB_ResourceList.getDataById(itemIconId).Res_path1
			itemWidget:getChildByName("Image_Item"):loadTexture(imgName, 1)

			-- 清除所有选中
        	for i = 1, #self.mfurnitListOutHouse do
        		local cellWidget = table:cellAtIndex(i-1)
        		if cellWidget then
        			local widget0 = cellWidget:getChildByTag(1)
        			widget0:getChildByName("Image_Chosen"):setVisible(false)
        		end
        	end

        	

			local function onTouch(widget, eventType)
		    	if eventType == ccui.TouchEventType.began then
		    		startPos = widget:getTouchBeganPosition()
		    		-- 记录
		    		self.mlastClickedItemIndex = index		    		
		    		-- 计时
		        	self:startTick()
		        	-- 清除所有选中
		        	for i = 1, #self.mfurnitListOutHouse do
		        		local cellWidget = table:cellAtIndex(i-1)
		        		if cellWidget then
		        			local widget0 = cellWidget:getChildByTag(1)
		        			widget0:getChildByName("Image_Chosen"):setVisible(false)
		        		end
		        	end
		        	-- 添加选中
		        	widget:getChildByName("Image_Chosen"):setVisible(true)
		    	elseif eventType == ccui.TouchEventType.ended then
		        	self:stopTick()
		    	elseif eventType == ccui.TouchEventType.moved then
		    		movedPos = widget:getTouchMovePosition()
		    		if getLength(startPos, movedPos) > 10 then
		        		self:stopTick()
		        	end
		    	elseif eventType == ccui.TouchEventType.canceled then
		        	self:stopTick()
		      	end
		    end
			itemWidget:addTouchEventListener(onTouch)

			itemWidget:setVisible(true)
		end

		local function createItemWidget(index) -- 创建物品
			local widget = GUIWidgetPool:createWidget("ItemWidget")
			widget:getChildByName("Label_Count_Stroke"):setVisible(false)
			widget:setTouchSwallowed(false)
			return widget
		end

		if nil == cell then
			cell = cc.TableViewCell:new()
			local itemWidget = createItemWidget(index+1)
			itemWidget:setTag(1)
			itemWidget:getChildByName("Image_Quality"):setVisible(true)
			-- itemWidget:getChildByName("Image_Quality"):loadTexture("icon_item_quality_null.png", 1)
			cell:addChild(itemWidget)
		else
			
		end

		updateCellInfo()

		return cell
	end

	local function tableCellTouched(table,cell)
	end

	local parentNode = GUISystem:GetWindowByName("HomeWindow").mRootWidget:getChildByName("TableView")

	self.mTblViewWidget = TableViewEx:new()
	local itemWidget0 = GUIWidgetPool:createWidget("ItemWidget")
	local itemWidgetContentSize = itemWidget0:getContentSize()
	local tblViewContentSize = parentNode:getContentSize()
	self.mTblViewWidget:setCellSize(cc.size(tblViewContentSize.width, itemWidgetContentSize.height))
	self.mTblViewWidget:setCellCount(math.ceil(#self.mfurnitListOutHouse))
	self.mTblViewWidget:registerTableCellAtIndexFunc(tableCellAtIndex)
	self.mTblViewWidget:registerTableCellTouchedFunc(tableCellTouched)

	self.mTblViewWidget:init(tblViewContentSize, cc.p(0,0), 1)
	parentNode:addChild(self.mTblViewWidget:getRootNode())
end

local preLocation = nil

function FurnitManager:init(parentNode)

	GUISystem:GetWindowByName("HomeWindow").mBuildPanel:setVisible(true)

	GUIEventManager:registerEvent("furnitChanged", self, self.onFurnitChanged)

	self.mParentNode = parentNode
	self.mRootNode = cc.Node:create()

	local function onTouchBegan(touch, event)
		local location = touch:getLocation()
		-- 记录点击的屏幕坐标
		self.mLastClickedScreenPos = location 
		print("坐标:", self.mLastClickedScreenPos.x, self.mLastClickedScreenPos.y)

		preLocation = nil

		return true
	end

	local function onTouchMoved(touch, event)
		local location = touch:getLocation()

		if not preLocation then
			preLocation = location
		end

		if getLength(preLocation, location) < 20 then
			return
		end

		preLocation = location

		-- if self.mMoveObject and canMove then
		-- 	-- 设置位置
		-- 	local deltaPos = FightSystem:getCurrentViewOffset()
		-- 	local newPos = cc.p(location.x - deltaPos.x, location.y - deltaPos.y)
		-- 	local footRect = self.mMoveObject:getFootRect()
		-- 	newPos.x = newPos.x - footRect.width/2
		-- 	self.mMoveObject:setPosition(newPos)
		-- 	self.mMoveObject:setLocalZOrder(1440 - (newPos.y + 1))
		-- 	-- 碰撞检查
		-- 	self.mMoveObject:checkCollision()
		-- 	preLocation = location
		-- end

		if self.mNewFurnit and self.mNewFurnit:getMoveable() then
			local footSize = self.mNewFurnit:getFootSize()
			local deltaPos = FightSystem:getCurrentViewOffset()
			location.x = location.x - footSize.width/2 - deltaPos.x
			location.y = location.y - deltaPos.y
			self.mNewFurnit:setPosition(location)
			-- 检查碰撞
			self.mNewFurnit:checkCollision()
		end

		if self.mMovingFurnit and self.mMovingFurnit:getMoveable() then
			local footSize = self.mMovingFurnit:getFootSize()
			local deltaPos = FightSystem:getCurrentViewOffset()
			location.x = location.x - footSize.width/2 - deltaPos.x
			location.y = location.y - deltaPos.y
			self.mMovingFurnit:setPosition(location)
			-- 检查碰撞
			self.mMovingFurnit:checkCollision()
		end
	end

	local function onTouchEnded(touch, event)
		if self.mNewFurnit then
			self.mNewFurnit:setMoveable(false)
			-- if self.mRootNode ~= self.mNewFurnit:getParentNode() then
			-- 	self.mNewFurnit:reParent(self.mRootNode)
			-- end
		--	self:stopEditMode()
		end

		if self.mMovingFurnit then
			self.mMovingFurnit:setMoveable(false)
		end
	end

	local function onTouchCancelled(touch, event)
		if self.mNewFurnit then
			self.mNewFurnit:setMoveable(false)
		--	self:stopEditMode()
		end

		if self.mMovingFurnit then
			self.mMovingFurnit:setMoveable(false)
		end
	end

	self.mTouchLayer = cc.Layer:create()
	local listener = cc.EventListenerTouchOneByOne:create()
	listener:setSwallowTouches(false)
	listener:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN )
    listener:registerScriptHandler(onTouchMoved,cc.Handler.EVENT_TOUCH_MOVED )
    listener:registerScriptHandler(onTouchEnded,cc.Handler.EVENT_TOUCH_ENDED )
    listener:registerScriptHandler(onTouchCancelled,cc.Handler.EVENT_TOUCH_CANCELLED )
    local eventDispatcher = self.mTouchLayer:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, self.mTouchLayer)
    GUISystem:GetWindowByName("HomeWindow").mRootNode:addChild(self.mTouchLayer, 2000)

    -- 取数据
    self:getDataFromGlobal()
    -- 初始化背包
 	self:initFurnitBag()
 	-- 初始化家具
 	self:initFurnitList()

	parentNode:addChild(self.mRootNode, 2000)
end

function FurnitManager:initFurnitList()
	-- 添加
	for i = 1, #globaldata.furnitListInHouse do
		local furnitObj = globaldata.furnitListInHouse[i]
		self.mFurnitList[i] = FurnitWidget:new()
		self.mFurnitList[i]:init(self, furnitObj.mId, furnitObj.mGuid, false)
		FightSystem.mSceneManager:GetTiledLayer():addChild(self.mFurnitList[i]:getRootNode())
		self.mFurnitList[i]:setPosition(cc.p(furnitObj.mPosX, furnitObj.mPosY))
		self.mFurnitList[i]:setLocalZOrder(1440 - (furnitObj.mPosY + 1))
		-- 设置阻挡
		local rect = self.mFurnitList[i]:getFootRect()
		-- 阻挡(+)
		FightSystem:setMapInfoForRect(cc.p(furnitObj.mPosX, furnitObj.mPosY), rect.width, rect.height, 0)
	end
end

-- 添加新家具
function FurnitManager:addNewFurnit(furnitObj)
	self.mNewFurnit = FurnitWidget:new()
	self.mNewFurnit:init(self, furnitObj.mId, furnitObj.mGuid, true)
	FightSystem.mSceneManager:GetTiledLayer():addChild(self.mNewFurnit:getRootNode())
	local footSize = self.mNewFurnit:getFootSize()
	local deltaPos = FightSystem:getCurrentViewOffset()
	self.mNewFurnit:setPosition(cc.p(self.mLastClickedScreenPos.x - footSize.width/2 - deltaPos.x, self.mLastClickedScreenPos.y - deltaPos.y))
	self.mNewFurnit:setLocalZOrder(1440)
	-- 设置可以移动
	self.mNewFurnit:setMoveable(true)
	-- 设置按钮显示
	self.mNewFurnit:setOkBtnVisible(true)
	self.mNewFurnit:setCancelBtnVisible(true)
end

-- 删除新家具
function FurnitManager:removeNewFurnit()
	self.mNewFurnit:destroy()
	self.mNewFurnit = nil
	self:getDataFromGlobal()
	self:reloadData()
end

-- 设置移动家具
function FurnitManager:setMovingFurnit(furnit)
	if not self.mMovingFurnit then
		-- 设置
		self.mMovingFurnit = furnit
		-- 按钮显示
		self.mMovingFurnit:setCancelBtnVisible(true)
		-- 闪烁
		self.mMovingFurnit:setBlink(true)
		-- 检查碰撞
		self.mMovingFurnit:checkCollision()
		-- 记住位置
		self.mMovingFurnit.mStartPos = self.mMovingFurnit:getPosition()
		print("初始位置:", self.mMovingFurnit.mStartPos.x, self.mMovingFurnit.mStartPos.y)
	end
end

-- 获取移动家具
function FurnitManager:getMovingFurnit()
	return self.mMovingFurObject
end

-- 移除移动家具
function FurnitManager:removeMovingFurnit()
	if self.mMovingFurnit then
		-- 按钮显示
		self.mMovingFurnit:setCancelBtnVisible(false)
		self.mMovingFurnit:setOkBtnVisible(false)
		-- 位置还原
		print("初始位置:", self.mMovingFurnit.mStartPos.x, self.mMovingFurnit.mStartPos.y)
		self.mMovingFurnit:setPosition(self.mMovingFurnit.mStartPos)
		self.mMovingFurnit.mStartPos = nil
		-- 闪烁
		self.mMovingFurnit:setBlink(false)
		-- 清空
		self.mMovingFurnit = nil
	end
end

