-- Name: 	TableViewEx.lua
-- Func：	滑动层
-- Author:	wangshengdong
-- Data:	15-4-9


-- cc.SCROLLVIEW_DIRECTION_HORIZONTAL = 0
-- cc.SCROLLVIEW_DIRECTION_VERTICAL = 1


-- cc.TABLEVIEW_FILL_TOPDOWN = 0
-- cc.TABLEVIEW_FILL_BOTTOMUP = 1

TableViewEx = {}

function TableViewEx:new()
	local o = 
	{
		mRootNode		=	nil, 	-- 根节点
		mInnerContainer	=	nil, 	-- 内部容器
		mCellSize 		=	nil,	-- 格子大小
		mContentSize	=	nil,	-- 容器大小
		mPos			=	nil,	-- 位置
		mDir 			=	nil,	-- 方向
		mCellCount		=	nil,	-- 格子数量
	----------------------------------------------
		mTableCellAtIndexFunc		=	nil,
		mTableCellTouchedFunc 		=	nil,
		mTableCellHighLightFunc 	=   nil,
		mTableCellUnHighLightFunc 	=	nil,
		mTableViewDidScrollFunc		=	nil,
	}
	o = newObject(o, TableViewEx)
	return o
end

function TableViewEx:init(contentSize, initPostion, direction)
	self.mContentSize = contentSize
	self.mPos = initPostion
	self.mDir = direction
---------------------------------------------------------------------------------
	self.mRootNode = ccui.Layout:create()
--	self.mRootNode:setBackGroundColorType(ccui.LayoutBackGroundColorType.solid)
--	self.mRootNode:setBackGroundColor(cc.c3b(255, 0, 0))
	self.mRootNode:setContentSize(self.mContentSize)
	self.mRootNode:setAnchorPoint(cc.p(0, 0))
	self.mRootNode:setPosition(self.mPos)
	self.mRootNode:setTouchEnabled(true)
--	self.mRootNode:setOpacity(20)
---------------------------------------------------------------------------------
	self:initInnerContainer()
end

function TableViewEx:setContentSize(newSize)
	self.mRootNode:setContentSize(newSize)
	self.mInnerContainer:setContentSize(newSize)
	self.mInnerContainer:setViewSize(newSize)
end

function TableViewEx:setVisible(visible)
	self.mRootNode:setVisible(visible)
end

function TableViewEx:setContentOffset(offset)
	self.mInnerContainer:setContentOffset(offset)
end

function TableViewEx:getContentSize()
	return self.mRootNode:getContentSize()
end

function TableViewEx:setCellSize(size)
	self.mCellSize = size
end

function TableViewEx:getPosition()
	return cc.p(self.mRootNode:getPosition())
end

function TableViewEx:setPosition(pos)
	self.mRootNode:setPosition(pos)
end

function TableViewEx:setCellCount(count)
	self.mCellCount = count
end

function TableViewEx:setTouchEnabled(enabled)
	self.mInnerContainer:setTouchEnabled(enabled)
end

function TableViewEx:setBounceable(boolVal)
	self.mInnerContainer:setBounceable(boolVal)
end

function TableViewEx:initInnerContainer()
	self.mInnerContainer = cc.TableView:create(self.mContentSize)
	self.mInnerContainer:setDirection(self.mDir)
	self.mInnerContainer:setAnchorPoint(cc.p(0, 0))
	self.mInnerContainer:setPosition(cc.p(0, 0))
	self.mInnerContainer:setDelegate()
	self.mInnerContainer:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
	self.mRootNode:addChild(self.mInnerContainer)

	self.mInnerContainer:registerScriptHandler(handler(self, self.numberOfCellsInTableView), cc.NUMBER_OF_CELLS_IN_TABLEVIEW)  
    self.mInnerContainer:registerScriptHandler(handler(self, self.scrollViewDidScroll), cc.SCROLLVIEW_SCRIPT_SCROLL)
    self.mInnerContainer:registerScriptHandler(handler(self, self.scrollViewDidZoom), cc.SCROLLVIEW_SCRIPT_ZOOM)
    self.mInnerContainer:registerScriptHandler(handler(self, self.tableCellTouched), cc.TABLECELL_TOUCHED)
    self.mInnerContainer:registerScriptHandler(handler(self, self.cellSizeForTable), cc.TABLECELL_SIZE_FOR_INDEX)
    self.mInnerContainer:registerScriptHandler(handler(self, self.tableCellAtIndex), cc.TABLECELL_SIZE_AT_INDEX)
    self.mInnerContainer:registerScriptHandler(handler(self, self.tableCellHighLight), cc.TABLECELL_HIGH_LIGHT)
    self.mInnerContainer:registerScriptHandler(handler(self, self.tableCellUnHighLight), cc.TABLECELL_UNHIGH_LIGHT)


    self.mInnerContainer:reloadData()
end

function TableViewEx:getRootNode()
	return self.mRootNode
end

function TableViewEx:reloadData()
	self.mInnerContainer:reloadData()
end

function TableViewEx:numberOfCellsInTableView(table)
	return self.mCellCount
end

function TableViewEx:scrollViewDidScroll(view)
	if self.mTableViewDidScrollFunc then
		self.mTableViewDidScrollFunc()
	end
end

function TableViewEx:scrollViewDidZoom(view)
	
end

function TableViewEx:setWidthEx(value)
	self.mInnerContainer:setWidthEx(value)
end

function TableViewEx:tableCellHighLight(table,cell)
	if self.mTableCellHighLightFunc then
		return self.mTableCellHighLightFunc(table, cell)
	end
end

function TableViewEx:tableCellUnHighLight(table,cell)
	if self.mTableCellUnHighLightFunc then
		return self.mTableCellUnHighLightFunc(table, cell)
	end
end

function TableViewEx:tableCellTouched(table,cell)
--	print("cell touched at index: " .. cell:getIdx())
	return self.mTableCellTouchedFunc(table,cell)
end

function TableViewEx:cellSizeForTable(table,idx)
	return self.mCellSize.height, self.mCellSize.width
end

function TableViewEx:tableCellAtIndex(table, index)
	return self.mTableCellAtIndexFunc(table, index)
end

function TableViewEx:registerTableCellAtIndexFunc(func)
	self.mTableCellAtIndexFunc = func
end

function TableViewEx:registerTableCellTouchedFunc(func)
	self.mTableCellTouchedFunc = func
end

function TableViewEx:registerTableCellHighLight(func)
	self.mTableCellHighLightFunc = func
end

function TableViewEx:registerTableCellUnHighLight(func)
	self.mTableCellUnHighLightFunc = func
end

function TableViewEx:registerScrollViewDidScrollFunc(func)
	self.mTableViewDidScrollFunc = func
end
--------------------------------------------------------------------------------------


