-- Name: 	PartyTableViews
-- Func：	帮派TVs
-- Author:	lichuan
-- Data:	2015/12/7

--==========================================================recordTv begin ==================================================================
RecordTableView = {}

function RecordTableView:new(owner,listType)
	local o = 
	{
		mOwner			  = owner,
		mRootNode 	      =	nil,
		mType 		      =	listType,
		mTableView	      =	nil,
	}
	o = newObject(o, RecordTableView)
	return o
end

function RecordTableView:Destroy()
	self.mRootNode:removeFromParent(true)
	self.mRootNode     = nil
	self.mTableView    = nil
	self.mOwner        = nil
end

function RecordTableView:myModel()
	return self.mOwner.mModel
end

function RecordTableView:init(rootNode)
	self.mRootNode = rootNode
	-- 初始化数据源
	--self:myModel():doLoadDataRequest(PacketTyper._PTYPE_CS_REQUEST_FRIEND_LIST_,nil)
	self:initTableView()
end

function RecordTableView:initTableView()
	self.mTableView = TableViewEx:new()

	local widget = GUIWidgetPool:createWidget("Guild_RecordCell")

	self.mTableView:setCellSize(widget:getContentSize())
	self.mTableView:setCellCount(#self.mOwner.mModel.mMsgdeque)

	self.mTableView:registerTableCellAtIndexFunc(handler(self, self.tableCellAtIndex))
	self.mTableView:registerTableCellTouchedFunc(handler(self, self.tableCellTouched))

	self.mTableView:init(self.mRootNode:getContentSize(), cc.p(0,0), 1)
	self.mRootNode:addChild(self.mTableView:getRootNode())
end

function RecordTableView:tableCellAtIndex(table, index)
	local cell = table:dequeueCell()
	local applyItem = nil

	if nil == cell then
		cell = cc.TableViewCell:new()
		applyItem = GUIWidgetPool:createWidget("Guild_RecordCell")
		
		applyItem:setTouchSwallowed(false)
		applyItem:setTag(1)
		cell:addChild(applyItem)
	else
		applyItem = cell:getChildByTag(1)
	end

	if #self:myModel().mMsgdeque ~= 0 then
		self:setCellLayOut(applyItem,index)
	end
	
	return cell
end

function RecordTableView:setCellLayOut(widget,index)
	local deque = self:myModel().mMsgdeque
	widget:getChildByName("Label_Time"):setString(deque[index + 1][1])
	widget:getChildByName("Label_PlayerName"):setString(deque[index + 1][2])
	widget:getChildByName("Label_Event"):setString(deque[index + 1][3])
end

function RecordTableView:tableCellTouched(table,cell)
	print("RecordTableView cell touched at index: " .. cell:getIdx())

end

function RecordTableView:UpdateTableView(cellCnt) --move table to cur cell after reload
	self.mTableView:setCellCount(cellCnt)

	--local curOffset = self.mTableView.mInnerContainer:getContentOffset()
	--local curHeight = self.mTableView.mInnerContainer:getContentSize().height
	self.mTableView:reloadData()
	--self.mTableView.mInnerContainer:setContentOffset(cc.p(0,self.mTableView.mInnerContainer:getViewSize().height - self.mTableView.mInnerContainer:getContentSize().height))
	--local height = self.mTableView.mInnerContainer:getContentSize().height
	--curOffset.y = curOffset.y + (curHeight - height)
	--self.mTableView.mInnerContainer:setContentOffset(curOffset)
end

--==========================================================memberTv begin ==================================================================
MemberTableView = {}

function MemberTableView:new(owner,listType)
	local o = 
	{
		mOwner			  = owner,
		mRootNode 	      =	nil,
		mType 		      =	listType,
		mTableView	      =	nil,
		mLastSel		  = nil,
	}
	o = newObject(o, MemberTableView)
	return o
end

function MemberTableView:Destroy()
	self.mRootNode:removeFromParent(true)
	self.mRootNode     = nil
	self.mTableView    = nil
	self.mOwner        = nil
	self.mLastSel	   = nil
end

function MemberTableView:myModel()
	return self.mOwner.mModel
end

function MemberTableView:init(rootNode)
	self.mRootNode = rootNode
	-- 初始化数据源
	--self:myModel():doLoadDataRequest(PacketTyper._PTYPE_CS_REQUEST_FRIEND_LIST_,nil)
	self:initTableView()
end

function MemberTableView:initTableView()
	self.mTableView = TableViewEx:new()

	local widget = GUIWidgetPool:createWidget("Guild_MemberListCell")

	self.mTableView:setCellSize(widget:getContentSize())
	self.mTableView:setCellCount(#self.mOwner.mModel.mMemberInfoArr)

	self.mTableView:registerTableCellAtIndexFunc(handler(self, self.tableCellAtIndex))
	self.mTableView:registerTableCellTouchedFunc(handler(self, self.tableCellTouched))

	self.mTableView:init(self.mRootNode:getContentSize(), cc.p(0,0), 1)
	self.mRootNode:addChild(self.mTableView:getRootNode())
end

function MemberTableView:tableCellAtIndex(table, index)
	local cell = table:dequeueCell()
	local applyItem = nil

	if nil == cell then
		cell = cc.TableViewCell:new()
		applyItem = GUIWidgetPool:createWidget("Guild_MemberListCell")
		
		applyItem:setTouchSwallowed(false)
		applyItem:setTag(1)
		cell:addChild(applyItem)
	else
		applyItem = cell:getChildByTag(1)
	end

	--if #self:myModel().mPartyInfoArr ~= 0 then
		self:setCellLayOut(applyItem,index)
	--end
	
	return cell
end

function MemberTableView:setCellLayOut(widget,index)
	local memberInfo = self:myModel().mMemberInfoArr[index + 1]

	local playerInfoWidget = GUIWidgetPool:createWidget("PlayerInfo")
	playerInfoWidget:setTouchSwallowed(false)

	playerInfoWidget:getChildByName("Image_PlayerHead_Bg"):loadTexture(FindFrameIconbyId(memberInfo.mMemberFrameId))
	playerInfoWidget:getChildByName("Image_PlayerHead"):loadTexture(FindFrameIconbyId(memberInfo.mMemberIconId))

	widget:getChildByName("Panel_PlayerInfo"):removeAllChildren()
	widget:getChildByName("Panel_PlayerInfo"):addChild(playerInfoWidget)

	

	playerInfoWidget:getChildByName("Label_Level"):setString(tostring(memberInfo.mMemberLv))
	playerInfoWidget:getChildByName("Label_Name"):setString(memberInfo.mMemberNameStr)
	playerInfoWidget:getChildByName("Label_Zhanli"):setString(tostring(memberInfo.mMemberFightPower))

	widget:getChildByName("Label_Contribution"):setString(tostring(memberInfo.mContribution))
	widget:getChildByName("Label_BattleScore"):setString(tostring(memberInfo.mFightRecord))
	widget:getChildByName("Label_Position"):setString(PARTYROLESTR[memberInfo.mPosition])
	widget:getChildByName("Label_LastOnlineTime"):setString(tostring(memberInfo.mLastOnLineTime))
end

function MemberTableView:tableCellTouched(table,cell)
	print("MemberTableView cell touched at index: " .. cell:getIdx())

	if self.mLastSel ~= nil and self.mLastSel ~= cell then
		self.mLastSel:getChildByTag(1):getChildByName("Image_Bg"):loadTexture("guild_menberlist_bg1.png")
	end

	local memberPanel = self.mOwner.mPPFs[2][2]

	if self.mOwner.mModel.mMemberInfoArr[cell:getIdx() + 1].mMemberIdStr ~= globaldata.playerId then
		memberPanel:getChildByName("Panel_Options"):setPositionY(cell:getChildByTag(1):getPositionY() - cell:getIdx()*5)
		memberPanel:getChildByName("Panel_Options"):setVisible(true) 
		memberPanel:getChildByName("Panel_Close"):setVisible(true)
	end

	local clickRole = self.mOwner.mModel.mMemberInfoArr[cell:getIdx() + 1].mPosition
	if self.mOwner.mModel.mPartyRole ~= PARTYROLE.MASTER then
		if self.mOwner.mModel.mPartyRole == PARTYROLE.SMALLMASTER and clickRole == PARTYROLE.MEMBER then
			memberPanel:getChildByName("Button_Appoint"):setTouchEnabled(false)
			memberPanel:getChildByName("Button_TakeOut"):setTouchEnabled(true)
			memberPanel:getChildByName("Button_HandPower"):setTouchEnabled(false)
			ShaderManager:DoUIWidgetDisabled(memberPanel:getChildByName("Button_Appoint"), true)
			ShaderManager:DoUIWidgetDisabled(memberPanel:getChildByName("Button_TakeOut"), false)  
			ShaderManager:DoUIWidgetDisabled(memberPanel:getChildByName("Button_HandPower"), true)
		else
			memberPanel:getChildByName("Button_Appoint"):setTouchEnabled(false)
			memberPanel:getChildByName("Button_TakeOut"):setTouchEnabled(false)
			memberPanel:getChildByName("Button_HandPower"):setTouchEnabled(false)
			ShaderManager:DoUIWidgetDisabled(memberPanel:getChildByName("Button_Appoint"), true)
			ShaderManager:DoUIWidgetDisabled(memberPanel:getChildByName("Button_TakeOut"), true)  
			ShaderManager:DoUIWidgetDisabled(memberPanel:getChildByName("Button_HandPower"), true)
		end
	else
		if clickRole == PARTYROLE.SMALLMASTER then
			memberPanel:getChildByName("Button_Appoint"):getChildByName("Label_Appoint"):setString("撤职")
		else
			memberPanel:getChildByName("Button_Appoint"):getChildByName("Label_Appoint"):setString("任命副会长")
		end

	    memberPanel:getChildByName("Button_Appoint"):setTouchEnabled(true)
		memberPanel:getChildByName("Button_TakeOut"):setTouchEnabled(true)
		memberPanel:getChildByName("Button_HandPower"):setTouchEnabled(true)
		ShaderManager:DoUIWidgetDisabled(memberPanel:getChildByName("Button_Appoint"), false)
		ShaderManager:DoUIWidgetDisabled(memberPanel:getChildByName("Button_TakeOut"), false)  
		ShaderManager:DoUIWidgetDisabled(memberPanel:getChildByName("Button_HandPower"), false)
	end

	cell:getChildByTag(1):getChildByName("Image_Bg"):loadTexture("guild_menberlist_bg2.png") 	

	self.mLastSel = cell
end

function MemberTableView:getCurSelIndex()
	return self.mLastSel:getIdx()
end

function MemberTableView:UpdateCurSel(position)
	if self.mLastSel == nil then return end
	self.mOwner.mModel.mMemberInfoArr[self.mLastSel:getIdx() + 1].mPosition = position
	if position ~= -1 then
		self.mLastSel:getChildByTag(1):getChildByName("Label_Position"):setString(PARTYROLESTR[position])
	else
		self.mLastSel:getChildByTag(1):getChildByName("Image_Bg"):loadTexture("guild_menberlist_bg1.png")
	end
end

function MemberTableView:UpdateTableView(cellCnt) --move table to cur cell after reload
	self.mTableView:setCellCount(cellCnt)

	--local curOffset = self.mTableView.mInnerContainer:getContentOffset()
	--local curHeight = self.mTableView.mInnerContainer:getContentSize().height
	self.mTableView:reloadData()
	--self.mTableView.mInnerContainer:setContentOffset(cc.p(0,self.mTableView.mInnerContainer:getViewSize().height - self.mTableView.mInnerContainer:getContentSize().height))
	--local height = self.mTableView.mInnerContainer:getContentSize().height
	--curOffset.y = curOffset.y + (curHeight - height)
	--self.mTableView.mInnerContainer:setContentOffset(curOffset)
end

--==========================================================applyTv begin ==================================================================
ApplyTableView = {}

function ApplyTableView:new(owner,listType)
	local o = 
	{
		mOwner			  = owner,
		mRootNode 	      =	nil,
		mType 		      =	listType,
		mTableView	      =	nil,
	}
	o = newObject(o, ApplyTableView)
	return o
end

function ApplyTableView:Destroy()
	self.mRootNode:removeFromParent(true)
	self.mRootNode     = nil
	self.mTableView    = nil
	self.mOwner        = nil
end

function ApplyTableView:myModel()
	return self.mOwner.mModel
end

function ApplyTableView:init(rootNode)
	self.mRootNode = rootNode
	-- 初始化数据源
	--self:myModel():doLoadDataRequest(PacketTyper._PTYPE_CS_REQUEST_FRIEND_LIST_,nil)
	self:initTableView()
end

function ApplyTableView:initTableView()
	self.mTableView = TableViewEx:new()

	local widget = GUIWidgetPool:createWidget("Guild_Main_JoinApply_Cell")

	self.mTableView:setCellSize(widget:getContentSize())
	self.mTableView:setCellCount(#self.mOwner.mModel.mApplyInfoArr)--

	self.mTableView:registerTableCellAtIndexFunc(handler(self, self.tableCellAtIndex))
	self.mTableView:registerTableCellTouchedFunc(handler(self, self.tableCellTouched))

	self.mTableView:init(self.mRootNode:getContentSize(), cc.p(0,0), 1)
	self.mRootNode:addChild(self.mTableView:getRootNode())
end

function ApplyTableView:tableCellAtIndex(table, index)
	local cell = table:dequeueCell()
	local applyItem = nil

	if nil == cell then
		cell = cc.TableViewCell:new()
		applyItem = GUIWidgetPool:createWidget("Guild_Main_JoinApply_Cell")

		registerWidgetReleaseUpEvent(applyItem:getChildByName("Button_Refuse"),
		function(widget) GUISystem:playSound("homeBtnSound") self:myModel():doRefuseApplyRequest(widget:getTag() + 1) end)

		registerWidgetReleaseUpEvent(applyItem:getChildByName("Button_Agree"),
		function(widget) GUISystem:playSound("homeBtnSound") self:myModel():doAgreeApplyRequest(widget:getTag() + 1) end)
		
		applyItem:setTouchSwallowed(false)
		applyItem:setTag(1)
		cell:addChild(applyItem)
	else
		applyItem = cell:getChildByTag(1)
	end

	applyItem:getChildByName("Button_Refuse"):setTag(index)
	applyItem:getChildByName("Button_Agree"):setTag(index)
	--if #self:myModel().mPartyInfoArr ~= 0 then
		self:setCellLayOut(applyItem,index)
	--end
	
	return cell
end

function ApplyTableView:setCellLayOut(widget,index)

	local applyInfo = self:myModel().mApplyInfoArr[index + 1]

	local playerInfoWidget = GUIWidgetPool:createWidget("PlayerInfo")
	playerInfoWidget:setTouchSwallowed(false)

	playerInfoWidget:getChildByName("Image_PlayerHead_Bg"):loadTexture(FindFrameIconbyId(applyInfo.mPlayerFrameId))
	playerInfoWidget:getChildByName("Image_PlayerHead"):loadTexture(FindFrameIconbyId(applyInfo.mPlayerIconId))

	widget:getChildByName("Panel_PlayerInfo"):removeAllChildren()
	widget:getChildByName("Panel_PlayerInfo"):addChild(playerInfoWidget)

	playerInfoWidget:getChildByName("Label_Level"):setString(""..applyInfo.mPlayerLv)
	playerInfoWidget:getChildByName("Label_Name"):setString(applyInfo.mPlayerNameStr)
	playerInfoWidget:getChildByName("Label_Zhanli"):setString(tostring(applyInfo.mPlayerFightPower))

end

function ApplyTableView:tableCellTouched(table,cell)
	print("ApplyTableView cell touched at index: " .. cell:getIdx())

end

function ApplyTableView:UpdateTableView(cellCnt) --move table to cur cell after reload
	self.mTableView:setCellCount(cellCnt)

	--local curOffset = self.mTableView.mInnerContainer:getContentOffset()
	--local curHeight = self.mTableView.mInnerContainer:getContentSize().height
	self.mTableView:reloadData()
	--self.mTableView.mInnerContainer:setContentOffset(cc.p(0,self.mTableView.mInnerContainer:getViewSize().height - self.mTableView.mInnerContainer:getContentSize().height))
	--local height = self.mTableView.mInnerContainer:getContentSize().height
	--curOffset.y = curOffset.y + (curHeight - height)
	--self.mTableView.mInnerContainer:setContentOffset(curOffset)
end