-- Name: 	BlackMarketWindow
-- Func：	黑市委托
-- Author:	lichuan
-- Data:	16-1-13

local MTASKSTATE = {}
MTASKSTATE.NOTSTARTED   = 0
MTASKSTATE.STARTED		= 1
MTASKSTATE.DONE         = 2

local MTaskInfo = {}
function MTaskInfo:new()
	local o = 
	{
		mIndex      = nil,	--任务索引
		mTaskId     = nil,	--任务id
		mNameId     = nil,	--任务名字
		mDescId     = nil,	--任务描述
		mQuality    = nil,	--任务品质
		mTaskType   = nil,  --任务类型
		mTime       = nil,	--持续时间
		mRewardArr  = {},	--奖励
		mState      = nil,	--状态 0:未开始 1:开始 2:已完成
		mLeftTime   = nil,	--任务剩余时间
		mHeroIdArr  = {},	--守护的英雄
		mTotalCombat = nil,
		mPlayerId    = nil,
		mRobState    = nil, -- 0 没抢过 1 抢过
	}
	o = newObject(o, MTaskInfo)
	return o
end

function MTaskInfo:getKeyValue(key)
	if self[key] then
		return self[key]
	end
	return nil
end

local BMRecordInfo = {}
function BMRecordInfo:new()
	local o = 
	{
		mRoberName  = "",	--攻击方名字
		mRobTime    = "",	--攻击时间
		mGuardRet   = nil,	--守护结果  0 胜利 1 失败
		mRobCnt     = nil,	--被抢数量
	}
	o = newObject(o, BMRecordInfo)
	return o
end

function BMRecordInfo:getKeyValue(key)
	if self[key] then
		return self[key]
	end
	return nil
end

local BMMInstance = nil

BlackMarketModel = class("BlackMarketModel")

function BlackMarketModel:ctor()
	self.mName          = "BlackMarketModel"
	self.mOwner         = nil
	self.mWinData       = nil
	self.mGTaskInfoArr  = { nil,nil,nil,
							nil,nil,nil,
							nil,nil,nil}
	self.mRTaskInfoArr  = { nil,nil,nil,
					        nil,nil,nil,
	                        nil,nil,nil}

	self.mBattleHeros   = {}

	self.mRecordArr     = {}
	self:registerNetEvent()
end

function BlackMarketModel:deinit()
	self.mName  			  = nil
	self.mOwner 			  = nil
	self.mWinData             = nil
	self.mGTaskInfoArr  	  = { nil,nil,nil,
								  nil,nil,nil,
								  nil,nil,nil}
	self.mRTaskInfoArr        = { nil,nil,nil,
					              nil,nil,nil,
	                              nil,nil,nil}
	self.mBattleHeros   = {}

	self.mRecordArr     = {}
	self:unRegisterNetEvent()
end

function BlackMarketModel:registerNetEvent()
	NetSystem.mNetManager:RegisterPacketHandler(PacketTyper._PTYPE_SC_BLACKMARKET_INFO_RESPONSE, handler(self, self.onLoadMarketInfoResponse))
	NetSystem.mNetManager:RegisterPacketHandler(PacketTyper._PTYPE_SC_BMTASK_REFRESH_RESPONSE, handler(self, self.onRefershResponse))
	NetSystem.mNetManager:RegisterPacketHandler(PacketTyper._PTYPE_SC_BEGIN_BMTASK_RESPONSE, handler(self, self.onBeginGuardResponse))
	NetSystem.mNetManager:RegisterPacketHandler(PacketTyper._PTYPE_SC_GET_BMREWARD_RESPONSE, handler(self, self.onGetBMRewardResponse))
	NetSystem.mNetManager:RegisterPacketHandler(PacketTyper._PTYPE_SC_SEEK_RTASK_RESPONSE, handler(self, self.onSeekRTaskResponse))
	NetSystem.mNetManager:RegisterPacketHandler(PacketTyper._PTYPE_SC_LOAD_BMRECORD_RESPONSE, handler(self, self.onLoadRecordResponse))
	NetSystem.mNetManager:RegisterPacketHandler(PacketTyper._PTYPE_SC_GETEX_BMREWARD_RESPONSE, handler(self, self.onGetBMRewardExResponse))
end

function BlackMarketModel:unRegisterNetEvent()
	NetSystem.mNetManager:UnregisterPacketHandler(PacketTyper._PTYPE_SC_BLACKMARKET_INFO_RESPONSE)
	NetSystem.mNetManager:UnregisterPacketHandler(PacketTyper._PTYPE_SC_BMTASK_REFRESH_RESPONSE)
	NetSystem.mNetManager:UnregisterPacketHandler(PacketTyper._PTYPE_SC_BEGIN_BMTASK_RESPONSE)
	NetSystem.mNetManager:UnregisterPacketHandler(PacketTyper._PTYPE_SC_GET_BMREWARD_RESPONSE)
	NetSystem.mNetManager:UnregisterPacketHandler(PacketTyper._PTYPE_SC_SEEK_RTASK_RESPONSE)
	NetSystem.mNetManager:UnregisterPacketHandler(PacketTyper._PTYPE_SC_LOAD_BMRECORD_RESPONSE)
	NetSystem.mNetManager:UnregisterPacketHandler(PacketTyper._PTYPE_SC_GETEX_BMREWARD_RESPONSE)
end

function BlackMarketModel:getInstance()
	if BMMInstance == nil then  
        BMMInstance = BlackMarketModel.new()
    end  
    return BMMInstance
end

function BlackMarketModel:destroyInstance()
	if BMMInstance then
		BMMInstance:deinit()
    	BMMInstance = nil
    end
end

function BlackMarketModel:setOwner(owner)
	self.mOwner = owner
end

function BlackMarketModel:doLoadMarketInfoRequest()
	local packet = NetSystem.mNetManager:GetSPacket()
    packet:SetType(PacketTyper._PTYPE_CS_BLACKMARKET_INFO_REQUEST)
    packet:Send()
    GUISystem:showLoading()
end

function BlackMarketModel:onLoadMarketInfoResponse(msgPacket)
	self.mLeftTaskCnt  = msgPacket:GetUShort()
	self.mMaxTaskCnt   = msgPacket:GetUShort()
	self.mLeftRTaskCnt = msgPacket:GetUShort()
	self.mMaxRTaskCnt  = msgPacket:GetUShort()
	self.mRefreshCost  = msgPacket:GetInt()
	self.mRefreshTime  = msgPacket:GetInt()

	local taskCnt = msgPacket:GetUShort()

	self.mBattleHeros   = {}
	for i=1,taskCnt do
		local mTaskInfo = MTaskInfo:new()
		mTaskInfo.mIndex	 = msgPacket:GetChar()
		mTaskInfo.mTaskId	 = msgPacket:GetInt()  
		mTaskInfo.mNameId	 = msgPacket:GetInt()  
		mTaskInfo.mDescId	 = msgPacket:GetInt()  
		mTaskInfo.mQuality	 = msgPacket:GetChar() 
		mTaskInfo.mTaskType  = msgPacket:GetChar() 
		mTaskInfo.mTime	     = msgPacket:GetInt()
		local rewardCnt      = msgPacket:GetUShort()
		mTaskInfo.mRewardArr = {}
		for i=1,rewardCnt do
		  	local rewardInfo = {}
		  	rewardInfo.mRewardType = msgPacket:GetInt()
		  	rewardInfo.mItemId     = msgPacket:GetInt()
		  	rewardInfo.mItemCnt    = msgPacket:GetInt()
		  	table.insert(mTaskInfo.mRewardArr,rewardInfo)
		end  
		mTaskInfo.mState	 = msgPacket:GetChar()  
		mTaskInfo.mLeftTime	 = msgPacket:GetInt()
		
		if mTaskInfo.mState == MTASKSTATE.STARTED  then
			if mTaskInfo.mLeftTime == 0 then
				mTaskInfo.mState = MTASKSTATE.DONE
			end 
		end

		local heroCnt        = msgPacket:GetUShort()                     
		mTaskInfo.mHeroIdArr = {}
		for i=1,heroCnt do
			local id = msgPacket:GetInt()
			table.insert(mTaskInfo.mHeroIdArr,id)
			if id ~= 0 then
				table.insert(self.mBattleHeros,id) 
			end
		end
		self.mGTaskInfoArr[mTaskInfo.mIndex + 1] = mTaskInfo
	end

	GUISystem:hideLoading()

	Event.GUISYSTEM_SHOW_BLACKMARKETWINDOW.mData = self.mWinData 

	if self.mWinData ~= nil and self.mWinData[2] ~= nil then     --for offline exit
		self.mWinData[2]()
	end

	EventSystem:PushEvent(Event.GUISYSTEM_SHOW_BLACKMARKETWINDOW) 
end

function BlackMarketModel:doRefershRequest()
	local packet = NetSystem.mNetManager:GetSPacket()
    packet:SetType(PacketTyper._PTYPE_CS_BMTASK_REFRESH_REQUEST)
    packet:Send()
    GUISystem:showLoading()
end

function BlackMarketModel:onRefershResponse(msgPacket)
	self.mLeftTaskCnt = msgPacket:GetUShort()
	self.mMaxTaskCnt  = msgPacket:GetUShort()
	self.mRefreshCost = msgPacket:GetInt()
	self.mRefreshTime = msgPacket:GetInt()

	local taskCnt = msgPacket:GetUShort()

	if self.mOwner == nil then return end

	if self.mOwner.mLastDoorCel ~= nil then
		self.mOwner.mLastDoorCel:getChildByName("Image_Chosen"):setVisible(false)
		self.mOwner.mLastDoorCel = nil
	end
	self.mOwner.mRootWidget:getChildByName("Label_Cost_Stroke"):setString(tostring(self.mRefreshCost)) 

	for i=1,9 do
		if self.mGTaskInfoArr[i] ~= nil then
			if self.mGTaskInfoArr[i].mState == MTASKSTATE.NOTSTARTED then
				self.mOwner:ResetDoorCell(i)
			end
		end
	end

	self.mOwner.mPanelHeros:setVisible(false)
	self.mOwner.mBottomPanel:setVisible(false)

	self.mBattleHeros   = {}

	for i=1,taskCnt do
		local mTaskInfo = MTaskInfo:new()
		mTaskInfo.mIndex	 = msgPacket:GetChar()
		mTaskInfo.mTaskId	 = msgPacket:GetInt()  
		mTaskInfo.mNameId	 = msgPacket:GetInt()  
		mTaskInfo.mDescId	 = msgPacket:GetInt()  
		mTaskInfo.mQuality	 = msgPacket:GetChar() 
		mTaskInfo.mTaskType  = msgPacket:GetChar() 
		mTaskInfo.mTime	     = msgPacket:GetInt()
		local rewardCnt      = msgPacket:GetUShort()
		mTaskInfo.mRewardArr = {}
		for i=1,rewardCnt do
		  	local rewardInfo = {}
		  	rewardInfo.mRewardType = msgPacket:GetInt()
		  	rewardInfo.mItemId     = msgPacket:GetInt()
		  	rewardInfo.mItemCnt    = msgPacket:GetInt()
		  	table.insert(mTaskInfo.mRewardArr,rewardInfo)
		end  
		mTaskInfo.mState	 = msgPacket:GetChar()  
		mTaskInfo.mLeftTime	 = msgPacket:GetInt()

		if mTaskInfo.mState == MTASKSTATE.STARTED  then
			if mTaskInfo.mLeftTime == 0 then
				mTaskInfo.mState = MTASKSTATE.DONE
			end 
		end

		local heroCnt        = msgPacket:GetUShort()                     
		mTaskInfo.mHeroIdArr = {}
		for i=1,heroCnt do
			local id = msgPacket:GetInt()
			table.insert(mTaskInfo.mHeroIdArr,id)

			if id ~= 0 then
				table.insert(self.mBattleHeros,id) 
			end
		end
		self.mGTaskInfoArr[mTaskInfo.mIndex + 1] = mTaskInfo
	end

	GUISystem:hideLoading()

	for i=1,9 do
		self.mOwner:setDoorCellLayout(self.mOwner.mDoorGuardCells[i],i)	
	end
end

function BlackMarketModel:doBeginGuardRequest(index)
	local taskInfo = self.mGTaskInfoArr[index]
	self.mBeginIdx = index

	if taskInfo == nil then return end
	if taskInfo.mHeroIdArr[1] == 0 and taskInfo.mHeroIdArr[2] == 0 and taskInfo.mHeroIdArr[3] == 0 then 
		MessageBox:showMessageBox1("请选择英雄！！！")
		return
	end

	if self.mLeftTaskCnt <= 0 then MessageBox:showMessageBox1("守护任务次数不足！！！") return end

	local packet = NetSystem.mNetManager:GetSPacket()
    packet:SetType(PacketTyper._PTYPE_CS_BEGIN_BMTASK_REQUEST)
    packet:PushChar(taskInfo.mIndex)
    packet:PushInt(taskInfo.mTaskId)
    packet:PushUShort(#taskInfo.mHeroIdArr)
    for i=1,#taskInfo.mHeroIdArr do
    	packet:PushInt(taskInfo.mHeroIdArr[i])
    end
    packet:Send()

    GUISystem:showLoading()
end

function BlackMarketModel:onBeginGuardResponse(msgPacket)
	local ret = msgPacket:GetChar()
	GUISystem:hideLoading()

	self.mLeftTaskCnt = self.mLeftTaskCnt - 1

	if ret == 0 then
		local rewardInfo = self.mGTaskInfoArr[self.mBeginIdx].mRewardArr[1]
		rewardInfo.mItemCnt = rewardInfo.mItemCnt * self.mOwner:GetFactorByHeroCnt()
		self.mOwner:UpdateCellandBotm(self.mOwner.mCurSel)

		AnySDKManager:td_task_begin("market-pro")
	else

	end
end

function BlackMarketModel:doGetBMRewardRequest(index)
	local taskInfo = self.mGTaskInfoArr[index]
	if taskInfo == nil then return end
	local packet = NetSystem.mNetManager:GetSPacket()
    packet:SetType(PacketTyper._PTYPE_CS_GET_BMREWARD_REQUEST)
    packet:PushChar(taskInfo.mIndex)
    packet:PushInt(taskInfo.mTaskId)
    packet:Send()
	GUISystem:showLoading()
end

function BlackMarketModel:onGetBMRewardResponse(msgPacket)
	local rewardCount = msgPacket:GetUShort()
	local itemList = {}
	for i = 1, rewardCount do
		local itemType = msgPacket:GetInt()
		local itemId = msgPacket:GetInt()
		local itemCount = msgPacket:GetInt()
		itemList[i] = {itemType, itemId, itemCount}
	end
	GUISystem:hideLoading()
	MessageBox:showMessageBox_ItemAlreadyGot(itemList)

	if self.mOwner ~= nil then
		local taskInfo = self.mGTaskInfoArr[self.mOwner.mCurSel]
		if taskInfo ~= nil then
			for i=1,#taskInfo.mHeroIdArr do
				local id = taskInfo.mHeroIdArr[i]
				if id ~= 0 then
					local heroObj  = globaldata:findHeroById(id)
					local heroIcon = createHeroIcon(heroObj.id, heroObj.level, heroObj.quality, heroObj.advanceLevel)

					heroIcon:setTouchEnabled(true)
					heroIcon:setTag(id)
					self.mOwner.mHeroList:pushBackCustomItem(heroIcon)
					registerWidgetReleaseUpEvent(heroIcon, handler(self.mOwner,self.mOwner.OnSelectHero))
					self.mOwner.mExistHeroIcons[id] = heroIcon

					table.remove(self.mBattleHeros,id)
				end
			end
		end
		self.mOwner.mBottomPanel:setVisible(false)
		self.mOwner.mLastDoorCel = nil
		self.mOwner:ResetDoorCell(self.mOwner.mCurSel)
	end
end

function BlackMarketModel:doSeekRTaskRequest()
	local packet = NetSystem.mNetManager:GetSPacket()
    packet:SetType(PacketTyper._PTYPE_CS_SEEK_RTASK_REQUEST)
    packet:Send()
    GUISystem:showLoading()
end

function BlackMarketModel:onSeekRTaskResponse(msgPacket)
	self.mLeftRTaskCnt = msgPacket:GetUShort()
	self.mMaxRTaskCnt  = msgPacket:GetUShort()
	local taskCnt = msgPacket:GetUShort()

	local indexs = {}

	for i=1,9 do
		if self.mRTaskInfoArr[i] ~= nil then
			self.mOwner:ResetDoorCell(i)
		end
	end

	local function isIdxExist(idx)
		for i=1,#indexs do
			if idx == indexs[i] then
				return true
			end
		end
		return false
	end

	for i=1,taskCnt do
		local mTaskInfo = MTaskInfo:new()
		mTaskInfo.mIndex     = msgPacket:GetChar()
		mTaskInfo.mTaskId	 = msgPacket:GetInt()
		mTaskInfo.mPlayerId  = msgPacket:GetString()
		mTaskInfo.mNameId	 = msgPacket:GetInt()   
		mTaskInfo.mQuality	 = msgPacket:GetChar() 
		mTaskInfo.mTaskType  = msgPacket:GetChar() 
		
		local rewardCnt      = msgPacket:GetUShort()
		mTaskInfo.mRewardArr = {}
		for i=1,rewardCnt do
		  	local rewardInfo = {}
		  	rewardInfo.mRewardType = msgPacket:GetInt()
		  	rewardInfo.mItemId     = msgPacket:GetInt()
		  	rewardInfo.mItemCnt    = msgPacket:GetInt()
		  	table.insert(mTaskInfo.mRewardArr,rewardInfo)
		end  

		local heroCnt        = msgPacket:GetUShort()                     
		mTaskInfo.mHeroIdArr = {}
		for i=1,heroCnt do
			local id = msgPacket:GetInt()
			table.insert(mTaskInfo.mHeroIdArr,id)
		end

		mTaskInfo.mTotalCombat = msgPacket:GetInt()

		
		local idx = math.random(1,9)
		while isIdxExist(idx) do
			idx = math.random(1,9)
		end

		table.insert(indexs,idx)

		self.mRTaskInfoArr[idx] = mTaskInfo
	end

	GUISystem:hideLoading()


	self.mOwner:ResetRobPanel()
end

function BlackMarketModel:doBeginRobRequest(heroIds)
	if self.mLeftRTaskCnt <= 0 then MessageBox:showMessageBox1("出击次数不足！！！") return end
	local taskInfo = self.mRTaskInfoArr[self.mOwner.mCurSel]
	globaldata:doBlackMarketBattleRequest(taskInfo.mIndex,taskInfo.mTaskId,taskInfo.mPlayerId,heroIds)
end

function BlackMarketModel:doLoadRecordRequest()
	local packet = NetSystem.mNetManager:GetSPacket()
    packet:SetType(PacketTyper._PTYPE_CS_LOAD_BMRECORD_REQUEST)
    packet:Send()
    GUISystem:showLoading()
end

function BlackMarketModel:onLoadRecordResponse(msgPacket)
	local recordCnt = msgPacket:GetUShort()

	self.mRecordArr = {}
	for i=1,recordCnt do
		local recordInfo        = BMRecordInfo:new()
		recordInfo.mTaskId 		= msgPacket:GetInt()
		cclog(string.format("aaaaaaaaaaaaaaaaaaaaaaaaaaa%d",recordInfo.mTaskId))
		recordInfo.mRoberName   = msgPacket:GetString()
		recordInfo.mRoberFrameId= msgPacket:GetInt()
		recordInfo.mRoberIconId = msgPacket:GetInt()
		recordInfo.mRoberLv     = msgPacket:GetInt()
		recordInfo.mRoberCombat = msgPacket:GetInt()
		recordInfo.mRobTime     = msgPacket:GetString()
		recordInfo.mRoberId     = msgPacket:GetString()
		recordInfo.mGuardRet    = msgPacket:GetChar()

		if recordInfo.mGuardRet == SUCCESS then
			recordInfo.mRewardState = msgPacket:GetChar()
		else
			recordInfo.revengeTask = {}
			local taskCnt   = msgPacket:GetUShort()
			for i=1,taskCnt do
				local mTaskInfo = MTaskInfo:new()

				mTaskInfo.mRobCnt    = msgPacket:GetInt() 
				mTaskInfo.mIndex	 = msgPacket:GetChar()
				mTaskInfo.mTaskId	 = msgPacket:GetInt()  
				mTaskInfo.mNameId	 = msgPacket:GetInt()  
				mTaskInfo.mDescId	 = msgPacket:GetInt()  
				mTaskInfo.mQuality	 = msgPacket:GetChar() 
				mTaskInfo.mTaskType  = msgPacket:GetChar() 
				mTaskInfo.mTime	     = msgPacket:GetInt()
				
				local rewardCnt      = msgPacket:GetUShort()
				mTaskInfo.mRewardArr = {}
				for i=1,rewardCnt do
				  	local rewardInfo = {}
				  	rewardInfo.mRewardType = msgPacket:GetInt()
				  	rewardInfo.mItemId     = msgPacket:GetInt()
				  	rewardInfo.mItemCnt    = msgPacket:GetInt()
				  	table.insert(mTaskInfo.mRewardArr,rewardInfo)
				end  
				mTaskInfo.mState	 = msgPacket:GetChar()  
				mTaskInfo.mLeftTime	 = msgPacket:GetInt()

				local heroCnt        = msgPacket:GetUShort()                     
				mTaskInfo.mHeroIdArr = {}
				for i=1,heroCnt do
					local id = msgPacket:GetInt()
					table.insert(mTaskInfo.mHeroIdArr,id)
				end

				mTaskInfo.mRobState  = msgPacket:GetInt()
				
				if mTaskInfo.mLeftTime > 0 then
					table.insert(recordInfo.revengeTask,mTaskInfo)
				end
			end
		end

		recordInfo.mItemType    = msgPacket:GetInt()
		recordInfo.mItemId      = msgPacket:GetInt()
		recordInfo.mItemCnt     = msgPacket:GetInt()

		table.insert(self.mRecordArr,recordInfo) 
	end

	GUISystem:hideLoading()

	if self.mOwner then 
		self.mOwner:ShowRecord()
	end
end

function BlackMarketModel:doGetBMRewardExRequest(btn,taskId)
	self.mGetBtn = btn
	local packet = NetSystem.mNetManager:GetSPacket()
    packet:SetType(PacketTyper._PTYPE_CS_GETEX_BMREWARD_REQUEST)
    packet:PushInt(taskId)
    packet:Send()
	GUISystem:showLoading()
end

function BlackMarketModel:onGetBMRewardExResponse(msgPacket)
	local rewardCount = msgPacket:GetUShort()
	local itemList = {}
	for i = 1, rewardCount do
		local itemType = msgPacket:GetInt()
		local itemId = msgPacket:GetInt()
		local itemCount = msgPacket:GetInt()
		itemList[i] = {itemType, itemId, itemCount}
	end
	GUISystem:hideLoading()
	self.mGetBtn:setVisible(false)

	self.mRecordArr[self.mGetBtn:getTag()].mRewardState = REWARDSTATE.HAVERECEIVED
	MessageBox:showMessageBox_ItemAlreadyGot(itemList)
end

function BlackMarketModel:doBeginRobRequestEx(heroIds,tag)
	if self.mLeftRTaskCnt <= 0 then MessageBox:showMessageBox1("出击次数不足！！！") return end

	local function findRecordById(taskId)
		for i=1,#self.mRecordArr do
			if self.mRecordArr[i].mTaskId == taskId then
				return self.mRecordArr[i]
			end
		end
		return nil
	end

	local recInfo       = findRecordById(self.mOwner.mTaskId)
	local revengeTask   = recInfo.revengeTask[tag]
	globaldata:doBlackMarketBattleRequest(revengeTask.mIndex,revengeTask.mTaskId,recInfo.mRoberId,heroIds)
end

--==========================================================RecordTv begin ==================================================================

BMRecordTableView = {}

function BMRecordTableView:new(owner,listType)
	local o = 
	{
		mOwner			  = owner,
		mRootNode 	      =	nil,
		mType 		      =	listType,
		mTableView	      =	nil,
	}
	o = newObject(o, BMRecordTableView)
	return o
end

function BMRecordTableView:Destroy()
	self.mRootNode:removeFromParent(true)
	self.mRootNode     = nil
	self.mTableView    = nil
	self.mOwner        = nil
end

function BMRecordTableView:myModel()
	return self.mOwner.mModel
end

function BMRecordTableView:init(rootNode)
	self.mRootNode = rootNode
	-- 初始化数据源
	--self:myModel():doLoadDataRequest(PacketTyper._PTYPE_CS_REQUEST_FRIEND_LIST_,nil)
	self:initTableView()
end

function BMRecordTableView:initTableView()
	self.mTableView = TableViewEx:new()

	local widget = GUIWidgetPool:createWidget("BlackMarket_RecardCell")

	self.mTableView:setCellSize(widget:getContentSize())
	self.mTableView:setCellCount(#self.mOwner.mModel.mRecordArr)

	self.mTableView:registerTableCellAtIndexFunc(handler(self, self.tableCellAtIndex))
	self.mTableView:registerTableCellTouchedFunc(handler(self, self.tableCellTouched))

	self.mTableView:init(self.mRootNode:getContentSize(), cc.p(0,0), 1)
	self.mRootNode:addChild(self.mTableView:getRootNode())
end

function BMRecordTableView:tableCellAtIndex(table, index)
	local cell = table:dequeueCell()
	local item = nil

	if nil == cell then
		cell = cc.TableViewCell:new()
		item = GUIWidgetPool:createWidget("BlackMarket_RecardCell")
		
		item:setTouchSwallowed(false)
		item:setTag(1)
		cell:addChild(item)
	else
		item = cell:getChildByTag(1)
	end

	if #self:myModel().mRecordArr ~= 0 then
		self:setCellLayOut(item,index)
	end
	
	return cell
end

function BMRecordTableView:setCellLayOut(widget,index)
	local recInfo = self:myModel().mRecordArr[index + 1]
	local recImg = {[0] = "arena_record_win.png","arena_record_lose.png"}

	widget:getChildByName("Image_Result"):loadTexture(recImg[recInfo.mGuardRet])
	widget:getChildByName("Label_Time"):setString(recInfo.mRobTime)

	local winPanel  = widget:getChildByName("Panel_Win")
	local losePanel = widget:getChildByName("Panel_Lose")
	local itemWidget = createCommonWidget(recInfo.mItemType,recInfo.mItemId,recInfo.mItemCnt)
	itemWidget:getChildByName("Label_Count_Stroke"):setVisible(false)

	if recInfo.mGuardRet == SUCCESS then
		winPanel:setVisible(true)
		losePanel:setVisible(false)

		winPanel:getChildByName("Label_Num"):setString(tostring(recInfo.mItemCnt))
		winPanel:getChildByName("Panel_Item"):removeAllChildren()
		winPanel:getChildByName("Panel_Item"):addChild(itemWidget)

		winPanel:getChildByName("Button_GetRewards"):setVisible(recInfo.mRewardState == REWARDSTATE.CANRECEIVE)
		winPanel:getChildByName("Button_GetRewards"):setTag(index + 1)
		registerWidgetReleaseUpEvent(winPanel:getChildByName("Button_GetRewards"),function(btn) self.mOwner.mModel:doGetBMRewardExRequest(btn,recInfo.mTaskId) end)

		local richPanel = winPanel:getChildByName("Panel_SomeWords")
		richTextCreate(richPanel,string.format("#00FF1E%s#半路挑衅，被你揍了一顿!",recInfo.mRoberName))
	else
		winPanel:setVisible(false)
		losePanel:setVisible(true)

		losePanel:getChildByName("Label_Num"):setString(tostring(recInfo.mItemCnt))
		losePanel:getChildByName("Panel_Item"):removeAllChildren()
		losePanel:getChildByName("Panel_Item"):addChild(itemWidget)

		registerWidgetReleaseUpEvent(losePanel:getChildByName("Button_Revenge"),function() self.mOwner:ShowRevengeTask(recInfo.mTaskId) end)	

		local richPanel = widget:getChildByName("Panel_Lose"):getChildByName("Panel_SomeWords")
		richTextCreate(richPanel,string.format("你的队伍在途中遭到#00FF1E%s#偷袭!",recInfo.mRoberName))
		end
end

function BMRecordTableView:tableCellTouched(table,cell)
	print("PartyTableView cell touched at index: " .. cell:getIdx())

end

function BMRecordTableView:UpdateTableView(cellCnt)
	self.mTableView:setCellCount(cellCnt)
	self.mTableView:reloadData()
end

--==========================================================window  begin ==================================================================

local BlackMarketWindow = 
{
	mName 				= "BlackMarketWindow",
	mRootNode			=	nil,	
	mRootWidget 		= 	nil,
	mTopRoleInfoPanel	=	nil,	-- 顶部人物信息面板
	mModel				=   nil,

	mDoorGuardCells	    =   {},
	mDoorRobCells       =   {},
	mPages              =   {},

	mType               =   nil,
	mLastDoorCel 		=   nil,
	mExistHeroIcons 	=   {},
	mTimeScheduler	    =   nil,
	mEventData          =   nil,
	----------------------------------------------------
	mCallFuncAfterDestroy = nil
}

function BlackMarketWindow:Load(event)
	cclog("=====BlackMarketWindow:Load=====begin")

	self.mRootNode = cc.Node:create()
	GUISystem:GetRootNode():addChild(self.mRootNode)

	self.mEventData    = event.mData
	self.mModel = BlackMarketModel:getInstance()
	self.mModel:setOwner(self)
	
	self:InitLayout(event)

	local function doBlackMarketGuide_Stop()
		BlackMarketGuide:stop()
	end
	BlackMarketGuide:step(1, nil, doBlackMarketGuide_Stop)
	
	cclog("=====BlackMarketWindow:Load=====begin")
end

function BlackMarketWindow:InitLayout(event)
	if self.mRootWidget == nil then	
		self.mRootWidget = GUIWidgetPool:createWidget("BlackMarket_Main")
		self.mRootNode:addChild(self.mRootWidget)
	end

	local function closeWindow()
		GUISystem:playSound("homeBtnSound")
		
		if self.mEventData and self.mEventData[1] ~= nil then			
		   	local function callFun()
			  EventSystem:PushEvent(Event.GUISYSTEM_HIDE_BLACKMARKETWINDOW)
	          showLoadingWindow("HomeWindow")
	        end
			FightSystem:sendChangeCity(false,callFun)
		else
			EventSystem:PushEvent(Event.GUISYSTEM_HIDE_BLACKMARKETWINDOW)
		end

	end
	if self.mTopRoleInfoPanel == nil then
		cclog("BlackMarketWindow mTopRoleInfoPanel init")
		self.mTopRoleInfoPanel = TopRoleInfoPanel:new()
		self.mTopRoleInfoPanel:init(self.mRootNode,ROLE_TITLE_TYPE.TITLE_BLACKMARKET, closeWindow)
	end

	self.mRootWidget:getChildByName("Panel_Page"):setPositionX(getGoldFightPosition_LD().x)
	self.mBottomPanel = self.mRootWidget:getChildByName("Panel_Bottom")
	self.mBottomPanel:setPositionY(getGoldFightPosition_LD().y)

	self.mRootWidget:getChildByName("Panel_Refresh"):setVisible(true)

	registerWidgetReleaseUpEvent(self.mRootWidget:getChildByName("Button_Refresh"),
	function()
		if self.mType == BMTYPE.GUARD then 
			self.mModel:doRefershRequest() 
		else
			self.mModel:doSeekRTaskRequest()
		end
	end)

	local page    = self.mRootWidget:getChildByName("Panel_Page")
	self.mPages   = {page:getChildByName("Image_Page_Protect"),page:getChildByName("Image_Page_Rob")} 

	for i=1,#self.mPages  do
		self.mPages[i]:setTag(i)
		registerWidgetReleaseUpEvent(self.mPages[i],handler(self,self.OnPressPage))
	end

	self.mPanelHeros = self.mRootWidget:getChildByName("Panel_HeroList")
	self.mHeroList   = self.mPanelHeros:getChildByName("ListView_HeroList")

	self.mTimeScheduler = cc.Director:getInstance():getScheduler():scheduleScriptFunc(handler(self, self.UpdateTimeLine), 1, false)

	self.mExistHeroIcons = {}

	local allHeroIdTbl = {}

	for k, v in pairs(globaldata.heroTeam) do
		table.insert(allHeroIdTbl, v.id)
	end
	-- 根据战力排序
	local function sortFunc(id1, id2)
		local heroObj1 = globaldata:findHeroById(id1)
		local heroObj2 = globaldata:findHeroById(id2)
		return heroObj1.combat > heroObj2.combat
	end
	table.sort(allHeroIdTbl, sortFunc)

	for i=1,#allHeroIdTbl do
		if not self:isHeroBusy(allHeroIdTbl[i]) then	
			local heroObj  = globaldata:findHeroById(allHeroIdTbl[i])
			local heroIcon = createHeroIcon(heroObj.id, heroObj.level, heroObj.quality, heroObj.advanceLevel)

			heroIcon:setTouchEnabled(true)
			heroIcon:setTag(allHeroIdTbl[i])
			self.mHeroList:pushBackCustomItem(heroIcon)
			registerWidgetReleaseUpEvent(heroIcon, handler(self,self.OnSelectHero))

			self.mExistHeroIcons[allHeroIdTbl[i]] = heroIcon
		end
	end

    self.mRootWidget:getChildByName("Label_Cost_Stroke"):setString(tostring(self.mModel.mRefreshCost)) 

	if self.mEventData and self.mEventData[1] ~= nil then
		self:OnPressPage(self.mPages[2])
	else
		self:OnPressPage(self.mPages[1])
	end	

	registerWidgetReleaseUpEvent(self.mRootWidget:getChildByName("Button_Rule"),
	function() 
		local rulePanel = GUIWidgetPool:createWidget("BlackMarket_Rule")

		self.mRootNode:addChild(rulePanel,1000)
		
		registerWidgetReleaseUpEvent(rulePanel:getChildByName("Button_Close"),function() rulePanel:removeFromParent()  rulePanel = nil end) 
		registerWidgetReleaseUpEvent(rulePanel,function() rulePanel:removeFromParent()  rulePanel = nil end)

		local textData = DB_Text.getDataById(1735)
		local textStr  = textData.Text_CN
		richTextCreate(rulePanel:getChildByName("Panel_Text"),textStr,true,nil,false)
	end)

	registerWidgetReleaseUpEvent(self.mRootWidget:getChildByName("Button_Recard"),function() self.mModel:doLoadRecordRequest() end)
end

function BlackMarketWindow:ShowRecord()
	local panelRec = GUIWidgetPool:createWidget("BlackMarket_Recard")

	self.mRootNode:addChild(panelRec,1000)

	local function closeWindow()
		if self.mRecordTv ~= nil then
			self.mRecordTv:Destroy()
			self.mRecordTv        = nil
		end

		panelRec:removeFromParent(true) 
		panelRec = nil
	end

	registerWidgetReleaseUpEvent(panelRec,closeWindow)
	registerWidgetReleaseUpEvent(panelRec:getChildByName("Button_Close"),closeWindow)

    local tvRecord = panelRec:getChildByName("Panel_RecardList")
	if self.mRecordTv == nil then
		self.mRecordTv = BMRecordTableView:new(self,0)
		self.mRecordTv:init(tvRecord)
	else
		self.mRecordTv:UpdateTableView(#self.mModel.mRecordArr)
	end	
end

function BlackMarketWindow:ShowRevengeTask(taskId)
	self.mTaskId = taskId
	local function findRecordById(taskId)
		for i=1,#self.mModel.mRecordArr do
			if self.mModel.mRecordArr[i].mTaskId == taskId then
				return self.mModel.mRecordArr[i]
			end
		end
		return nil
	end

	local recInfo       = findRecordById(taskId)
	local revengeTask   = recInfo.revengeTask

	if #revengeTask == 0 then MessageBox:showMessageBox1("对方暂无守护任务。") return end

	local revengePanel  = GUIWidgetPool:createWidget("BlackMarket_Revenge")
	local revengeList   = revengePanel:getChildByName("ListView_List")
	local timeScheduler = nil

	revengePanel:getChildByName("Label_LastRobTimes"):setString(string.format("%d/%d",self.mModel.mLeftRTaskCnt,self.mModel.mMaxRTaskCnt))
	self.mRootNode:addChild(revengePanel,1000)

	local function closeWindow()
		revengeList:removeAllItems()
		revengeList = nil

		revengePanel:removeFromParent(true)
		revengePanel = nil

		if timeScheduler ~= nil then
			cc.Director:getInstance():getScheduler():unscheduleScriptEntry(timeScheduler)
			timeScheduler = nil
		end
	end

	registerWidgetReleaseUpEvent(revengePanel,closeWindow)

	local revengeItems = {}
	for i=1,#revengeTask do
		local revengeItem = GUIWidgetPool:createWidget("BlackMarket_RevengeCell")
		local mTaskInfo   = revengeTask[i]
		local robBtn      = revengeItem:getChildByName("Button_Rob")

		robBtn:setTag(i)
		robBtn:getChildByName("Label_Rob"):setString(mTaskInfo.mRobState == 1 and "已回击" or "回击")
		ShaderManager:DoUIWidgetDisabled(robBtn,mTaskInfo.mRobState == 1)
		robBtn:setTouchEnabled(mTaskInfo.mRobState == 0)

		for i=1,3 do
			revengeItem:getChildByName(string.format("Image_Star_%d",i)):setVisible(false)
			revengeItem:getChildByName("Panel_HeroIcon_"..tostring(i)):removeAllChildren()
		end

		if mTaskInfo.mQuality > 3 then mTaskInfo.mQuality = 3 end

		for i=1,mTaskInfo.mQuality do
			revengeItem:getChildByName(string.format("Image_Star_%d",i)):setVisible(true)
		end

		revengeItem:getChildByName("Image_Logo"):loadTexture(string.format("blackmarket_logo_%d.png",mTaskInfo.mTaskType))


		local rewardInfo = mTaskInfo.mRewardArr[1]
		local rewardPanel = revengeItem:getChildByName("Panel_Item")
		if rewardInfo.mRewardType == 2 then
			rewardPanel:setVisible(false)
			revengeItem:getChildByName("Image_Gold"):setVisible(true)
			revengeItem:getChildByName("Image_Gold"):loadTexture("public_gold.png")
		elseif rewardInfo.mRewardType == 3 then
			rewardPanel:setVisible(false)
			revengeItem:getChildByName("Image_Gold"):setVisible(true)
			revengeItem:getChildByName("Image_Gold"):loadTexture("public_diamond.png")
		else
			revengeItem:getChildByName("Image_Gold"):setVisible(false)
			local rewardWidget = createCommonWidget(rewardInfo.mRewardType,rewardInfo.mItemId,rewardInfo.mItemCnt)
			rewardWidget:getChildByName("Label_Count_Stroke"):setVisible(false)
			rewardPanel:setVisible(true)
			rewardPanel:removeAllChildren()
			rewardPanel:addChild(rewardWidget)
		end

		revengeItem:getChildByName("Label_Num"):setString(tostring(mTaskInfo.mRobCnt))

		local ids = mTaskInfo.mHeroIdArr

		for i=1,#ids do
			if ids[i] ~= 0 then 
				local heroIcon = createHeroIcon(ids[i],1,1,1)
				heroIcon:getChildByName("Label_Level_Stroke"):setVisible(false)
				revengeItem:getChildByName("Panel_HeroIcon_"..tostring(i)):addChild(heroIcon)			
			end
		end

		local playerInfoWidget = GUIWidgetPool:createWidget("PlayerInfo")
	   	revengeItem:getChildByName("Panel_PlayerInfo"):addChild(playerInfoWidget)
	    playerInfoWidget:getChildByName("Image_PlayerHead_Bg"):loadTexture(FindFrameIconbyId(recInfo.mRoberFrameId))
	    playerInfoWidget:getChildByName("Image_PlayerHead"):loadTexture(FindFrameIconbyId(recInfo.mRoberIconId))
	    playerInfoWidget:getChildByName("Label_Level"):setString(tostring(recInfo.mRoberLv))
	    playerInfoWidget:getChildByName("Label_Name"):setString(recInfo.mRoberName)
	    playerInfoWidget:getChildByName("Label_Zhanli"):setString(tostring(recInfo.mRoberCombat))

	    revengeItem:getChildByName("Label_LastTime"):setString(timeFormat(mTaskInfo.mLeftTime))

		revengeList:pushBackCustomItem(revengeItem)

		registerWidgetReleaseUpEvent(revengeItem:getChildByName("Button_Rob"),function(widget)
			ShowRoleSelWindow(self,function(heros)  
				self.mModel:doBeginRobRequestEx(heros,widget:getTag()) 
				closeWindow() 
			end,{0,0,0},SELECTHERO.SHOWSELF) 
		end)
		table.insert(revengeItems,revengeItem)
	end

	local function UpdateTimeLine()
		for i=1,#revengeItems do
			revengeItems[i]:getChildByName("Label_LastTime"):setString(timeFormat(revengeTask[i].mLeftTime))
			revengeTask[i].mLeftTime = revengeTask[i].mLeftTime - 1
			if revengeTask[i].mLeftTime == 0 then
				revengeItems[i]:removeFromParent(true)
				revengeItems[i] = nil
			end
		end
	end

	timeScheduler = cc.Director:getInstance():getScheduler():scheduleScriptFunc(UpdateTimeLine, 1, false)
end

function BlackMarketWindow:UpdateTimeLine()
	if self.mType == BMTYPE.PLUNDER then return end
	self.mRootWidget:getChildByName("Label_NextTime"):setString(timeFormat(self.mModel.mRefreshTime))

	self.mModel.mRefreshTime = self.mModel.mRefreshTime - 1
	if self.mModel.mRefreshTime < 0 then
		self.mModel.mRefreshTime = 0
		--self.mModel:doRefershRequest()
	end

	local btn = self.mBottomPanel:getChildByName("Button_Do")

	for i=1,9 do
		if self.mModel.mGTaskInfoArr[i] ~= nil then
			if self.mModel.mGTaskInfoArr[i].mState == MTASKSTATE.STARTED then
				if self.mModel.mGTaskInfoArr[i].mLeftTime < 0 then 
					self.mModel.mGTaskInfoArr[i].mLeftTime = 0
					self.mModel.mGTaskInfoArr[i].mState = MTASKSTATE.DONE
					self.mDoorGuardCells[i]:getChildByName("Panel_Doing"):setVisible(false)
					self.mDoorGuardCells[i]:getChildByName("Label_Done"):setVisible(true)
					if i == self.mCurSel then
						ShaderManager:DoUIWidgetDisabled(btn, false)
						btn:setTouchEnabled(true)
						btn:getChildByName("Label_Do"):setString("领奖")
						registerWidgetReleaseUpEvent(btn,function() self.mModel:doGetBMRewardRequest(self.mCurSel) end) 
						self.mBottomPanel:getChildByName("ProgressBar_RemainingTime"):setPercent(100)
					end
				else
					self.mDoorGuardCells[i]:getChildByName("Label_RemainingTime"):setString(timeFormat(self.mModel.mGTaskInfoArr[i].mLeftTime))
					if i == self.mCurSel then
						local rewardInfo = self.mModel.mGTaskInfoArr[i].mRewardArr[1]
						self.mBottomPanel:getChildByName("Label_RemainingTime"):setString(timeFormat(self.mModel.mGTaskInfoArr[i].mLeftTime))
						local percent = (self.mModel.mGTaskInfoArr[i].mTime - self.mModel.mGTaskInfoArr[i].mLeftTime) / self.mModel.mGTaskInfoArr[i].mTime * 100
						self.mBottomPanel:getChildByName("ProgressBar_RemainingTime"):setPercent(percent)
						self.mBottomPanel:getChildByName("Label_TotalNum"):setString(rewardInfo.mItemCnt)
						--string.format("%d",math.floor(rewardInfo.mItemCnt * percent / 100))
					end
					self.mModel.mGTaskInfoArr[i].mLeftTime = self.mModel.mGTaskInfoArr[i].mLeftTime - 1
				end
			end
		end
	end
end

function BlackMarketWindow:setDoorCellLayout(doorCell,idx)
	if doorCell == nil then return end
	doorCell:setTag(idx)
	registerWidgetReleaseUpEvent(doorCell,handler(self,self.onSelectDoorCell))

	doorCell:getChildByName("Image_Chosen"):setVisible(false)
	local mTaskInfo = nil

	if self.mType == BMTYPE.GUARD then
		mTaskInfo = self.mModel.mGTaskInfoArr[idx]
	else
		mTaskInfo = self.mModel.mRTaskInfoArr[idx]
	end

	if mTaskInfo == nil then 
		return 
	else
		if self.mType ~= BMTYPE.GUARD then
			print("aaaaaaaaaaaaaaaaaa",idx)
		end
	end	

	local topStarPanel = doorCell:getChildByName("Panel_Top")
	topStarPanel:setVisible(true)

	topStarPanel:getChildByName("Image_Logo"):loadTexture(string.format("blackmarket_logo_%d.png",mTaskInfo.mTaskType))

	if mTaskInfo.mState == MTASKSTATE.STARTED  or mTaskInfo.mState == MTASKSTATE.DONE then
		topStarPanel:getChildByName("Panel_Paper_1"):setRotation(45)
	else
		topStarPanel:getChildByName("Panel_Paper_1"):setRotation(0)
	end

	for i=1,3 do
		topStarPanel:getChildByName(string.format("Image_Star_%d",i)):setVisible(false)
	end

	if mTaskInfo.mQuality > 3 then mTaskInfo.mQuality = 3 end

	for i=1,mTaskInfo.mQuality do
		topStarPanel:getChildByName(string.format("Image_Star_%d",i)):setVisible(true)
	end

	doorCell:getChildByName("Panel_Rob"):setTouchSwallowed(false)
	doorCell:getChildByName("Panel_Doing"):setTouchSwallowed(false)

	if self.mType == BMTYPE.GUARD then
		doorCell:getChildByName("Panel_Rob"):setVisible(false)
		if mTaskInfo.mState == MTASKSTATE.NOTSTARTED then
			doorCell:getChildByName("Panel_Doing"):setVisible(false)
			doorCell:getChildByName("Label_Done"):setVisible(false)
			doorCell:getChildByName("Image_PhotoBg"):setVisible(false)
		elseif mTaskInfo.mState == MTASKSTATE.STARTED then
			doorCell:getChildByName("Panel_Doing"):setVisible(true)
			doorCell:getChildByName("Label_Done"):setVisible(false)

			local id = nil 

			if mTaskInfo.mHeroIdArr[1] ~= 0 then 
				id =  mTaskInfo.mHeroIdArr[1]
			else
				if mTaskInfo.mHeroIdArr[2] ~= 0 then
					id =  mTaskInfo.mHeroIdArr[2]
				else
					if mTaskInfo.mHeroIdArr[3] ~= 0 then
						id =  mTaskInfo.mHeroIdArr[3]
					else
						id = nil
					end
				end
			end

			if id ~= nil then

				local heroData = DB_HeroConfig.getDataById(id)
				if heroData ~= nil then		
					local imgId    = heroData.IconID
					local imgName  = DB_ResourceList.getDataById(imgId).Res_path1
					doorCell:getChildByName("Image_PhotoBg"):setVisible(true)
					doorCell:getChildByName("Image_HeroIcon"):loadTexture(imgName, 1)
				end
			end
		elseif mTaskInfo.mState == MTASKSTATE.DONE then
			doorCell:getChildByName("Panel_Doing"):setVisible(false)
			doorCell:getChildByName("Label_Done"):setVisible(true)

			local id = nil 

			if mTaskInfo.mHeroIdArr[1] ~= 0 then 
				id =  mTaskInfo.mHeroIdArr[1]
			else
				if mTaskInfo.mHeroIdArr[2] ~= 0 then
					id =  mTaskInfo.mHeroIdArr[2]
				else
					if mTaskInfo.mHeroIdArr[3] ~= 0 then
						id =  mTaskInfo.mHeroIdArr[3]
					else
						id = nil
					end
				end
			end

			if id ~= nil then
				local heroData = DB_HeroConfig.getDataById(id)
				if heroData ~= nil then
					doorCell:getChildByName("Image_PhotoBg"):setVisible(true)
					doorCell:getChildByName("Image_HeroIcon"):loadTexture(DB_ResourceList.getDataById(heroData.IconID).Res_path1, 1)
				end
			end
		end
	else
		doorCell:getChildByName("Panel_Rob"):setVisible(true)

		local id = 0 

		for i=1,#mTaskInfo.mHeroIdArr do
			if mTaskInfo.mHeroIdArr[i] ~= 0 then
				id = mTaskInfo.mHeroIdArr[i]
				break
			end
		end
		
		local heroData = DB_HeroConfig.getDataById(id)
		if heroData ~= nil then
			doorCell:getChildByName("Image_PhotoBg"):setVisible(true)
			doorCell:getChildByName("Image_HeroIcon"):loadTexture(DB_ResourceList.getDataById(heroData.IconID).Res_path1,1)
		end

		local rewardInfo = mTaskInfo.mRewardArr[1]
		local itemImg = doorCell:getChildByName("Image_Item")
		if rewardInfo.mRewardType == 2 then
			itemImg:loadTexture("item_gold.png",1)
		elseif rewardInfo.mRewardType == 3 then
			itemImg:loadTexture("item_diamond.png",1)
		else
			itemImg:loadTexture(DB_ResourceList.getDataById(DB_ItemConfig.getDataById(rewardInfo.mItemId).IconID).Res_path1,1)
		end
		doorCell:getChildByName("Label_Num"):setString(string.format("X %d",rewardInfo.mItemCnt))
	end
end

function BlackMarketWindow:OnPressPage(widget)
	self.mType = widget:getTag()

	local lockers = self.mRootWidget:getChildByName("Panel_Cabinet")

	if self.mType == BMTYPE.GUARD then 
		self.mPages[1]:loadTexture("blackmarket_page2.png")
		self.mPages[2]:loadTexture("blackmarket_page1.png")
		self.mPages[1]:getChildByName("Label_Protect"):setColor(cc.c3b(255, 255,255))
		self.mPages[2]:getChildByName("Label_Rob"):setColor(cc.c3b(90, 204, 255))

		self.mRootWidget:getChildByName("Image_RemainingTime"):setVisible(true)
		self.mRootWidget:getChildByName("Label_Des"):setVisible(true)
		self.mRootWidget:getChildByName("Panel_Zhanli"):setVisible(false)
		self.mBottomPanel:getChildByName("Label_Rewards"):setString("奖励：")
		self.mPanelHeros:setVisible(true)

		self.mRootWidget:getChildByName("Label_NextTime"):setVisible(true)
		self.mRootWidget:getChildByName("Label_NextTime_0"):setVisible(true)

		self.mRootWidget:getChildByName("Label_Cost_Stroke"):setVisible(true)
		self.mRootWidget:getChildByName("Image_Diamond"):setVisible(true)


		self.mRootWidget:getChildByName("Label_LastTimes"):setString(string.format("今日守护次数 %d/%d",self.mModel.mLeftTaskCnt,self.mModel.mMaxTaskCnt))

		if #self.mDoorGuardCells == 0 then
			for i=1,9 do
				local doorCell = GUIWidgetPool:createWidget("BlackMarket_Cell")
				lockers:getChildByName(string.format("Panel_Door_%d",i)):addChild(doorCell)
				doorCell:setTag(i)
				self:setDoorCellLayout(doorCell,i)	
				table.insert(self.mDoorGuardCells,doorCell)	
			end
		else
			for i=1,9 do
				self:setDoorCellLayout(self.mDoorGuardCells[i],i)	
			end
		end

		for i=1,9 do
			if self.mDoorRobCells[i] ~= nil then
				self.mDoorRobCells[i]:setTouchEnabled(false)
				self.mDoorRobCells[i]:setVisible(false)
			end
			if self.mDoorGuardCells[i] ~= nil then
				self.mDoorGuardCells[i]:setTouchEnabled(true)
				self.mDoorGuardCells[i]:setVisible(true)
			end
		end

		self:onSelectDoorCell(self.mDoorGuardCells[1])		
	else
		local function isAllNil()
			for i=1,9 do
				if self.mModel.mRTaskInfoArr[i] ~= nil then
					return false
				end
			end
			return true
		end

		if isAllNil() == true then
			self.mModel:doSeekRTaskRequest()
		else
			self.mRootWidget:getChildByName("Label_LastTimes"):setString(string.format("今日出击次数 %d/%d",self.mModel.mLeftRTaskCnt,self.mModel.mMaxRTaskCnt))
			self:onSelectDoorCell(self.mDoorRobCells[1])
		end

		self.mPages[1]:loadTexture("blackmarket_page1.png")
		self.mPages[2]:loadTexture("blackmarket_page2.png")
		self.mPages[1]:getChildByName("Label_Protect"):setColor(cc.c3b(90, 204,255))
		self.mPages[2]:getChildByName("Label_Rob"):setColor(cc.c3b(255, 255, 255))

		self.mRootWidget:getChildByName("Image_RemainingTime"):setVisible(false)
		self.mRootWidget:getChildByName("Label_Des"):setVisible(false)
		self.mRootWidget:getChildByName("Panel_Zhanli"):setVisible(true)
		self.mBottomPanel:getChildByName("Label_Rewards"):setString("可抢得：")
		self.mPanelHeros:setVisible(false)
		self.mBottomPanel:setVisible(false) 

		self.mRootWidget:getChildByName("Label_NextTime"):setVisible(false)
		self.mRootWidget:getChildByName("Label_NextTime_0"):setVisible(false)
		
		self.mRootWidget:getChildByName("Label_Cost_Stroke"):setVisible(false)
		self.mRootWidget:getChildByName("Image_Diamond"):setVisible(false)

		for i=1,9 do
			if self.mDoorGuardCells[i] ~= nil then
				self.mDoorGuardCells[i]:setTouchEnabled(false)
				self.mDoorGuardCells[i]:setVisible(false)
			end
			if self.mDoorRobCells[i] ~= nil then
				self.mDoorRobCells[i]:setTouchEnabled(true)
				self.mDoorRobCells[i]:setVisible(true)
			end
		end
	end
end

function BlackMarketWindow:ResetRobPanel()
	local lockers = self.mRootWidget:getChildByName("Panel_Cabinet")

	self.mBottomPanel:setVisible(not (self.mType == BMTYPE.PLUNDER))
	self.mLastDoorCel = nil

	if #self.mDoorRobCells == 0 then
		for i=1,9 do
			local doorCell = GUIWidgetPool:createWidget("BlackMarket_Cell")
			lockers:getChildByName(string.format("Panel_Door_%d",i)):addChild(doorCell)

			self:setDoorCellLayout(doorCell,i)	
			table.insert(self.mDoorRobCells,doorCell)	
		end
	else
		for i=1,9 do
			self:setDoorCellLayout(self.mDoorRobCells[i],i)	
		end
	end

	self:onSelectDoorCell(self.mDoorRobCells[1])	
	self.mRootWidget:getChildByName("Label_LastTimes"):setString(string.format("今日出击次数 %d/%d",self.mModel.mLeftRTaskCnt,self.mModel.mMaxRTaskCnt))
end

function BlackMarketWindow:ResetDoorCell(index)
	local doorCellPanel = self.mRootWidget:getChildByName("Panel_Cabinet"):getChildByName(string.format("Panel_Door_%d",index))
	local doorCell = GUIWidgetPool:createWidget("BlackMarket_Cell")
	doorCellPanel:addChild(doorCell)

	if self.mType == BMTYPE.GUARD then
		self.mModel.mGTaskInfoArr[index] = nil
		self.mDoorGuardCells[index]:removeFromParent()
		self.mDoorGuardCells[index] = doorCell
	else
		self.mModel.mRTaskInfoArr[index] = nil
		self.mDoorRobCells[index]:removeFromParent()
		self.mDoorRobCells[index] = doorCell
	end	
	
	self:setDoorCellLayout(doorCell,index)
end

function BlackMarketWindow:UpdateCellandBotm(index)
	local mTaskInfo = self.mModel.mGTaskInfoArr[self.mCurSel]
	local doorCell  = self.mDoorGuardCells[self.mCurSel]

	local id = 0 

	for i=1,#mTaskInfo.mHeroIdArr do
		if mTaskInfo.mHeroIdArr[i] ~= 0 then
			id = mTaskInfo.mHeroIdArr[i]
			break
		end
	end

	local heroData  = DB_HeroConfig.getDataById(id)	
	local imgId     = heroData.IconID
	local imgName   = DB_ResourceList.getDataById(imgId).Res_path1
	doorCell:getChildByName("Image_HeroIcon"):loadTexture(imgName, 1)
	doorCell:getChildByName("Panel_Doing"):setVisible(true)
	doorCell:getChildByName("Label_Done"):setVisible(false)
	doorCell:getChildByName("Image_PhotoBg"):setVisible(true)
	doorCell:getChildByName("Panel_Top"):getChildByName("Panel_Paper_1"):setRotation(45)

	self.mPanelHeros:setVisible(false)
	ShaderManager:DoUIWidgetDisabled(self.mBottomPanel:getChildByName("Button_Do"), true)
	self.mBottomPanel:getChildByName("Button_Do"):setTouchEnabled(false)
	self.mRootWidget:getChildByName("Label_LastTimes"):setString(string.format("今日守护次数 %d/%d",self.mModel.mLeftTaskCnt,self.mModel.mMaxTaskCnt))

	mTaskInfo.mState    =  MTASKSTATE.STARTED
	mTaskInfo.mLeftTime = mTaskInfo.mTime

	for i=1,#mTaskInfo.mHeroIdArr do
		local id = mTaskInfo.mHeroIdArr[i]
		if id ~= 0 then
			if self.mExistHeroIcons[id] ~= nil then
				self.mExistHeroIcons[id]:removeFromParent()
				self.mExistHeroIcons[id] = nil
			end
			table.insert(self.mModel.mBattleHeros,id)
		end
	end	
end

function BlackMarketWindow:isHeroInBattle(id)
	local mTaskInfo = self.mModel.mGTaskInfoArr[self.mCurSel]
	if mTaskInfo == nil then return end
	local ids = mTaskInfo.mHeroIdArr
	for i = 1, #ids do
		if id == ids[i] then
			return true
		end
	end
	return false
end

function BlackMarketWindow:isHeroBusy(id)
	local ids = self.mModel.mBattleHeros
	for i = 1, #ids do
		if id == ids[i] then
			return true
		end
	end
	return false
end

function BlackMarketWindow:onSelectDoorCell(widget)	
	self.mCurSel = widget:getTag()

	self:setBottomLayout()

	widget:getChildByName("Image_Chosen"):setVisible(true)
	if widget ~= self.mLastDoorCel then	 	
	 	if 	self.mLastDoorCel ~= nil then		
			self.mLastDoorCel:getChildByName("Image_Chosen"):setVisible(false)
		end			
		self.mLastDoorCel = widget
	end
end

function BlackMarketWindow:setBottomLayout()
	local mTaskInfo = nil
	if self.mType == BMTYPE.GUARD then
		mTaskInfo = self.mModel.mGTaskInfoArr[self.mCurSel]
	else
		mTaskInfo = self.mModel.mRTaskInfoArr[self.mCurSel]
	end
	 
	local btn = self.mBottomPanel:getChildByName("Button_Do")

	for i=1,3 do
		self.mBottomPanel:getChildByName(string.format("Image_Star_%d",i)):setVisible(false)
		self.mBottomPanel:getChildByName("Panel_Hero_"..tostring(i)):removeAllChildren()
	end

	if mTaskInfo == nil then
		self.mBottomPanel:setVisible(false)
		self.mPanelHeros:setVisible(false)
		btn:getChildByName("Label_Do"):setString("开始") 
		return
	else
		self.mBottomPanel:setVisible(true)
	 	self.mPanelHeros:setVisible(true)
	end

	if mTaskInfo.mQuality > 3 then mTaskInfo.mQuality = 3 end

	for i=1,mTaskInfo.mQuality do
		self.mBottomPanel:getChildByName(string.format("Image_Star_%d",i)):setVisible(true)
	end

	local nameData = DB_Text.getDataById(mTaskInfo.mNameId)
	local nameStr  = nameData.Text_CN

	self.mBottomPanel:getChildByName("Image_Logo"):loadTexture(string.format("blackmarket_logobottom_%d.png",mTaskInfo.mTaskType))
	self.mBottomPanel:getChildByName("Label_Name"):setString(nameStr)	

	local rewardInfo = mTaskInfo.mRewardArr[1]
	local rewardPanel = self.mBottomPanel:getChildByName("Panel_Item")
	if rewardInfo.mRewardType == 2 then
		rewardPanel:setVisible(false)
		self.mBottomPanel:getChildByName("Image_Gold"):setVisible(true)
		self.mBottomPanel:getChildByName("Image_Gold"):loadTexture("public_gold.png")
	elseif rewardInfo.mRewardType == 3 then
		rewardPanel:setVisible(false)
		self.mBottomPanel:getChildByName("Image_Gold"):setVisible(true)
		self.mBottomPanel:getChildByName("Image_Gold"):loadTexture("public_diamond.png")
	else
		self.mBottomPanel:getChildByName("Image_Gold"):setVisible(false)
		local rewardWidget = createCommonWidget(rewardInfo.mRewardType,rewardInfo.mItemId,rewardInfo.mItemCnt)
		rewardWidget:getChildByName("Label_Count_Stroke"):setVisible(false)
		rewardPanel:setVisible(true)
		rewardPanel:removeAllChildren()
		rewardPanel:addChild(rewardWidget)
	end
	
	if mTaskInfo.mState == MTASKSTATE.NOTSTARTED then
		self.mPanelHeros:setVisible(true)
		ShaderManager:DoUIWidgetDisabled(btn, false)
		btn:setTouchEnabled(true) 
		btn:getChildByName("Label_Do"):setString("开始")
		self.mBottomPanel:getChildByName("Label_RemainingTime"):setString(timeFormat(mTaskInfo.mTime))
		self.mBottomPanel:getChildByName("ProgressBar_RemainingTime"):setPercent(0)

		if self.mType == BMTYPE.GUARD then    
			registerWidgetReleaseUpEvent(btn,function() self.mModel:doBeginGuardRequest(self.mCurSel) end)
		end
		self.mBottomPanel:getChildByName("Label_TotalNum"):setString(tostring(rewardInfo.mItemCnt*self:GetFactorByHeroCnt()))
	elseif mTaskInfo.mState == MTASKSTATE.STARTED then
		self.mPanelHeros:setVisible(false)
		ShaderManager:DoUIWidgetDisabled(btn, true)
		btn:setTouchEnabled(false)
		btn:getChildByName("Label_Do"):setString("开始")

		if self.mType == BMTYPE.GUARD then
			local taskInfo   = self.mModel.mGTaskInfoArr[self.mCurSel] 
			local rewardInfo = taskInfo.mRewardArr[1]
			local percent    = (taskInfo.mTime - taskInfo.mLeftTime) / taskInfo.mTime * 100

			self.mBottomPanel:getChildByName("Label_RemainingTime"):setString(timeFormat(taskInfo.mLeftTime))
			self.mBottomPanel:getChildByName("ProgressBar_RemainingTime"):setPercent(percent)
			self.mBottomPanel:getChildByName("Label_TotalNum"):setString(tostring(rewardInfo.mItemCnt)) 
			--string.format("%d",math.floor(rewardInfo.mItemCnt * percent / 100))
		end
	else
		self.mPanelHeros:setVisible(false)
		ShaderManager:DoUIWidgetDisabled(btn, false)
		btn:setTouchEnabled(true)
		btn:getChildByName("Label_Do"):setString("领奖")
		self.mBottomPanel:getChildByName("Label_RemainingTime"):setString("00:00:00")
		registerWidgetReleaseUpEvent(btn,function() self.mModel:doGetBMRewardRequest(self.mCurSel) end) 

		self.mBottomPanel:getChildByName("Label_TotalNum"):setString(tostring(rewardInfo.mItemCnt))
		self.mBottomPanel:getChildByName("ProgressBar_RemainingTime"):setPercent(100)
	end

	if self.mType == BMTYPE.GUARD then
		local descData = DB_Text.getDataById(mTaskInfo.mDescId)
		local descStr  = descData.Text_CN
		self.mBottomPanel:getChildByName("Label_Des"):setString(descStr)

		if self.mLastDoorCel ~= nil then
			local lastSel = self.mLastDoorCel:getTag()
			if self.mModel.mGTaskInfoArr[lastSel] ~= nil then
				if self.mModel.mGTaskInfoArr[lastSel].mState ~= MTASKSTATE.STARTED and self.mModel.mGTaskInfoArr[lastSel].mState ~= MTASKSTATE.DONE then
					self.mModel.mGTaskInfoArr[lastSel].mHeroIdArr = {0,0,0}
				end
			end
		end

		for k,v in pairs(self.mExistHeroIcons) do
			if v ~= nil then
				if self:isHeroInBattle(v:getTag()) then
					v:getChildByName("Image_HeroChosen"):setVisible(true)
				else
					v:getChildByName("Image_HeroChosen"):setVisible(false)
				end
			end
		end

	else
		self.mPanelHeros:setVisible(false)
		ShaderManager:DoUIWidgetDisabled(btn, false)
		btn:setTouchEnabled(true) 
		btn:getChildByName("Label_Do"):setString("开始")
		registerWidgetReleaseUpEvent(btn,
		function() 
			ShowRoleSelWindow(self,function(heros) self.mModel:doBeginRobRequest(heros) end,{0,0,0},SELECTHERO.SHOWSELF) 
		end)
		self.mBottomPanel:getChildByName("Label_Zhanli"):setString(string.format("%d",mTaskInfo.mTotalCombat))
	end	

	local ids = mTaskInfo.mHeroIdArr

	for i=1,#ids do
		if ids[i] ~= 0 then 
			local heroObj = globaldata:findHeroById(ids[i])
			local heroIcon = nil 
			if heroObj ~= nil then
				heroIcon = createHeroIcon(heroObj.id, heroObj.level, heroObj.quality, heroObj.advanceLevel)
			else
				heroIcon = createHeroIcon(ids[i],1,1,1)
			end
			
			heroIcon:setTouchEnabled(true)
			heroIcon:setTag(ids[i])
			
			--registerWidgetReleaseUpEvent(heroIcon, handler(self,self.OnDisSelectHero))

			self.mBottomPanel:getChildByName("Panel_Hero_"..tostring(i)):addChild(heroIcon)			
		end
	end
end

function BlackMarketWindow:GetFactorByHeroCnt()
	local mTaskInfo = (self.mType == BMTYPE.GUARD and self.mModel.mGTaskInfoArr[self.mCurSel] or self.mModel.mRTaskInfoArr[self.mCurSel])
	local cnt		= 0
	for i=1,#mTaskInfo.mHeroIdArr do
		if mTaskInfo.mHeroIdArr[i] ~= 0 then
			cnt = cnt + 1
		end
	end

	return (cnt == 0 and 1 or  1 + (0.5 * (cnt - 1)))
end

function BlackMarketWindow:OnSelectHero(widget)
	local heroId = widget:getTag()

	local mTaskInfo = self.mModel.mGTaskInfoArr[self.mCurSel]
	if mTaskInfo == nil then return end
	local ids = mTaskInfo.mHeroIdArr
	
	if not self:isHeroInBattle(heroId) then
		for i = 1, #ids do
			if 0 == ids[i] then -- 此处是空位
				-- 记住id
				ids[i] = heroId
				-- 创建控件
				local heroObj  = globaldata:findHeroById(heroId)
				local heroicon = createHeroIcon(heroObj.id, heroObj.level, heroObj.quality, heroObj.advanceLevel)
				heroicon:setTouchEnabled(true)
				heroicon:setTag(heroId)

				self.mBottomPanel:getChildByName("Panel_Hero_"..tostring(i)):addChild(heroicon)
				
				-- 播放特效
				local animNode = AnimManager:createAnimNode(8001)
				self.mBottomPanel:getChildByName("Panel_Hero_"..tostring(i)):addChild(animNode:getRootNode(), 100)
				animNode:setPosition(cc.p(45, 32))
				animNode:play("fightteam_cell_chose1")

				widget:getChildByName("Image_HeroChosen"):setVisible(true)
				registerWidgetReleaseUpEvent(heroicon, handler(self,self.OnDisSelectHero))

				-- 播放特效
				animNode = AnimManager:createAnimNode(8001)
				widget:getChildByName("Panel_Animation"):addChild(animNode:getRootNode(), 100)
				animNode:play("fightteam_cell_chose2")

				self.mBottomPanel:getChildByName("Label_TotalNum"):setString(tostring(math.floor(mTaskInfo.mRewardArr[1].mItemCnt * self:GetFactorByHeroCnt())))
				return 
			end
		end
	else
		self:OnDisSelectHero(widget)
	end
end

function BlackMarketWindow:OnDisSelectHero(widget)
	local heroId = widget:getTag()

	local mTaskInfo = self.mModel.mGTaskInfoArr[self.mCurSel]
	if mTaskInfo == nil then return end
	if mTaskInfo.mState == MTASKSTATE.STARTED then return end
	local ids = mTaskInfo.mHeroIdArr

	-- 去掉阵上id和控件
	for i = 1, #ids do
		if ids[i] == heroId then
			ids[i] = 0

			self.mBottomPanel:getChildByName("Panel_Hero_"..tostring(i)):removeAllChildren()
			
			-- 播放特效
			local animNode = AnimManager:createAnimNode(8001)
			self.mBottomPanel:getChildByName("Panel_Hero_"..tostring(i)):addChild(animNode:getRootNode(), 100)
			animNode:setPosition(cc.p(45, 32))
			animNode:play("fightteam_cell_chose2")
		end
	end

	self.mBottomPanel:getChildByName("Label_TotalNum"):setString(tostring(math.floor(mTaskInfo.mRewardArr[1].mItemCnt * self:GetFactorByHeroCnt())))

	for k,v in pairs(self.mExistHeroIcons) do
		if v:getTag() == heroId then
			v:getChildByName("Image_HeroChosen"):setVisible(false)
			-- 播放特效
			animNode = AnimManager:createAnimNode(8001)
			v:getChildByName("Panel_Animation"):addChild(animNode:getRootNode(), 100)
			animNode:play("fightteam_cell_chose2")
			break 
		end
	end
end

function BlackMarketWindow:Destroy()
	if self.mRecordTv ~= nil then
		self.mRecordTv:Destroy()
		self.mRecordTv        = nil
	end

	if self.mTimeScheduler ~= nil then
		cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.mTimeScheduler)
		self.mTimeScheduler = nil
	end

	self.mLastDoorCel = nil
	for i=1,#self.mDoorGuardCells do
		if self.mDoorGuardCells[i] ~= nil then
			self.mDoorGuardCells[i]:removeFromParent()
			self.mDoorGuardCells[i] = nil
		end
	end

	for i=1,#self.mDoorRobCells do
		if self.mDoorRobCells[i] ~= nil then
			self.mDoorRobCells[i]:removeFromParent()
			self.mDoorRobCells[i] = nil
		end
	end

	if self.mHeroList ~= nil then
		self.mHeroList:removeAllItems()
		self.mHeroList = nil
	end


	self.mModel:destroyInstance()

	if self.mTopRoleInfoPanel ~= nil then 
		self.mTopRoleInfoPanel:destroy()
		self.mTopRoleInfoPanel = nil
	end

	self.mRootWidget = nil

	if self.mRootNode then
		self.mRootNode:removeFromParent(true)
		self.mRootNode = nil
	end
	----------------
	CommonAnimation.clearAllTextures()
end

function BlackMarketWindow:DisableDraw()
	if self.mRootWidget then
		self.mRootWidget:setVisible(false)
	end
end

function BlackMarketWindow:EnableDraw()
	if self.mRootWidget then
		self.mRootWidget:setVisible(true)
	end
end

function BlackMarketWindow:onEventHandler(event, func)
	if event.mAction == Event.WINDOW_SHOW then
		self:Load(event)
		---------停止画主城镇界面
		EventSystem:PushEvent(Event.GUISYSTEM_DISABLEDRAW_HOMEWINDOW)
		---------
		NoticeSystem:doSingleUpdate(self.mName) 
		self.mCallFuncAfterDestroy = func
	elseif event.mAction == Event.WINDOW_HIDE then
		self:Destroy()
		---------开启画主城镇界面
		EventSystem:PushEvent(Event.GUISYSTEM_EABLEDRAW_HOMEWINDOW)
		---------
		if self.mCallFuncAfterDestroy then
			self.mCallFuncAfterDestroy()
			self.mCallFuncAfterDestroy = nil
		end
	elseif event.mAction == Event.WINDOW_ENABLE_DRAW then
		self:EnableDraw()
	elseif event.mAction == Event.WINDOW_DISABLE_DRAW then
		self:DisableDraw()
	end
end

return BlackMarketWindow