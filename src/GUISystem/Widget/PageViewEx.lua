-- Name: 	PageViewEx.lua
-- Func：	滑动层
-- Author:	wangshengdong
-- Data:	15-6-18


PageViewEx = {}

function PageViewEx:new()
	local o = 
	{
		mRootNode		=	nil, 	-- 根节点
		mContentSize	=	nil, 	-- 大小
		mInnerContainer =	nil, 	-- 内部容器
		mTouchLayer		=	nil,	-- 触摸层
		mPageSize		=	nil, 	-- 页大小
		mPageWidgetList	=	{},		-- 页控件链表
	}
	o = newObject(o, PageViewEx)
	return o
end

-- 初始化
function PageViewEx:init(contentSize)
	self.mContentSize = contentSize
	self.mRootNode = ccui.Layout:create()

	self.mRootNode:setContentSize(self.mContentSize)
--	self.mRootNode:setBackGroundColorType(ccui.LayoutBackGroundColorType.solid)
--	self.mRootNode:setBackGroundColor(cc.c3b(255, 0, 0))
	self.mRootNode:setAnchorPoint(cc.p(0, 0))
	self.mRootNode:setTouchEnabled(true)
	-- 初始化内部容器
	self:initInnerContainer()
	-- 初始化触摸层
	self:initTouchLayer()
end

-- 初始化内部容器
function PageViewEx:initInnerContainer()
	self.mInnerContainer = ccui.ScrollView:create()
	self.mInnerContainer:setBackGroundColor(cc.c3b(255, 0 , 0))
    self.mInnerContainer:setBackGroundColorType(ccui.LayoutBackGroundColorType.solid)
    self.mInnerContainer:setBounceEnabled(false)
    self.mInnerContainer:setDirection(ccui.ScrollViewDir.both)
    self.mInnerContainer:setInnerContainerSize(self.mContentSize)
    self.mInnerContainer:setContentSize(self.mContentSize)
    self.mInnerContainer:setPosition(cc.p(0, 0))
    self.mRootNode:addChild(self.mInnerContainer, 1)
end

local preLocation = nil

-- 响应触摸层滑动
function PageViewEx:onTouch(widget, eventType)
	if eventType == ccui.TouchEventType.began then
    	print("触摸开始")
    elseif eventType == ccui.TouchEventType.ended then
        print("触摸结束")
    elseif eventType == ccui.TouchEventType.moved then
       	local curLocation = widget:getTouchMovePosition()
       	if preLocation then
       		local deltaX = curLocation.x - preLocation.x
       		self.mInnerContainer:scrollChildren(deltaX, 0)
       	end
       	preLocation = curLocation 
    elseif eventType == ccui.TouchEventType.canceled then
        print("触摸取消")
    end
end

-- 初始化触摸层
function PageViewEx:initTouchLayer()
	self.mTouchLayer = ccui.Layout:create()
	self.mTouchLayer:setContentSize(self.mContentSize)
	self.mTouchLayer:setTouchEnabled(true)
	self.mTouchLayer:setPosition(cc.p(0, 0))
    self.mRootNode:addChild(self.mTouchLayer, 2)
    self.mTouchLayer:addTouchEventListener(handler(self, self.onTouch))
end

-- 设置页大小
function PageViewEx:setPageSize(sz)
	self.mPageSize	=	sz
end

-- 获取根节点
function PageViewEx:getRootNode()
	return self.mRootNode
end

-- 添加页
function PageViewEx:addPage(widget)
	local curCount = #self.mPageWidgetList
	self.mPageWidgetList[curCount+1] = widget
	self.mInnerContainer:addChild(widget)
	local posX = curCount*self.mPageSize.width
	local posY = 0
	widget:setPosition(cc.p(posX, posY))

	-- 调整
	self.mInnerContainer:setInnerContainerSize(cc.size((curCount+1)*self.mPageSize.width, self.mPageSize.height))
end

-- 设置位置
function PageViewEx:setPosition(pos)
	self.mRootNode:setPosition(pos)
end