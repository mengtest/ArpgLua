-- Name: 	TaskWindow
-- Func：	任务窗口
-- Author:	lichuan
-- Data:	15-5-19

local TaskMInstance = nil 

TaskModel = class("TaskModel")

function TaskModel:ctor()
	self.mName 		    = "TaskModel"
	self.mOwner			= nil

	self.mDataSource    = {{},{}}
	self.mActivity      = nil
	self.mLstActivity   = nil
	self.mGetTotelCnt	= nil
	self.mRefresh       = false

	self:registerNetEvent()
end

function TaskModel:deinit()
	self.mName 		    = nil
	self.mOwner			= nil

	self.mDataSource    = {{},{}}
	self.mActivity      = nil
	self.mLstActivity   = nil
	self.mGetTotelCnt	= nil
	self.mRefresh       = false

	self:unRegisterNetEvent()
end

function TaskModel:getInstance()
	if TaskMInstance == nil then  
        TaskMInstance = TaskModel.new()
    end  
    return TaskMInstance
end

function TaskModel:destroyInstance()
	if TaskMInstance then
		TaskMInstance:deinit()
    	TaskMInstance = nil
    end
end

function TaskModel:registerNetEvent()
	NetSystem.mNetManager:RegisterPacketHandler(PacketTyper.__PTYPE_SC_REQUEST_TASK_INFO_, handler(self, self.onLoadTaskResponse))
	NetSystem.mNetManager:RegisterPacketHandler(PacketTyper.__PTYPE_SC_REQUEST_GET_TASK_REWARD_, handler(self, self.onGetRewardResponse))
	NetSystem.mNetManager:RegisterPacketHandler(PacketTyper.__PTYPE_SC_REQUEST_TASK_REFRESH_, handler(self, self.onRefreshResponse))
	NetSystem.mNetManager:RegisterPacketHandler(PacketTyper._PTYPE_SC_ACTIVITY_REWARD_INFO_, handler(self, self.onLoadRewardInfoResponse))

	GUIEventManager:registerEvent("taskSyncHappen", self, self.onTaskSyncHappen)
end

function TaskModel:unRegisterNetEvent()
	NetSystem.mNetManager:UnregisterPacketHandler(PacketTyper.__PTYPE_SC_REQUEST_TASK_INFO_)
	NetSystem.mNetManager:UnregisterPacketHandler(PacketTyper.__PTYPE_SC_REQUEST_GET_TASK_REWARD_)
	NetSystem.mNetManager:UnregisterPacketHandler(PacketTyper.__PTYPE_SC_REQUEST_TASK_REFRESH_)
	NetSystem.mNetManager:UnregisterPacketHandler(PacketTyper._PTYPE_SC_ACTIVITY_REWARD_INFO_)

	GUIEventManager:unregister("taskSyncHappen", self.onTaskSyncHappen)
end

function TaskModel:setOwner(owner)
	self.mOwner = owner
end


function TaskModel:doLoadTaskRequest()
	local packet = NetSystem.mNetManager:GetSPacket()
	packet:SetType(PacketTyper.__PTYPE_CS_REQUEST_TASK_INFO_)
	packet:Send()	
	GUISystem:showLoading()
end

function TaskModel:onLoadTaskResponse(msgPacket)
	local taskCnt       = msgPacket:GetUShort()
	local taskArr       = {}

	for i=1,taskCnt do
		local taskInfo                  = {}
		taskInfo.mTaskType     		    = msgPacket:GetChar()
		taskInfo.mTaskId	            = msgPacket:GetInt()
		taskInfo.mTaskNameStr	        = msgPacket:GetString()
		taskInfo.mTaskDescStr			= msgPacket:GetString()
		taskInfo.mTaskProStr			= msgPacket:GetString()
		taskInfo.mTaskIsFinish			= msgPacket:GetChar()
		taskInfo.mTaskDiffculty			= msgPacket:GetChar()

		taskInfo.mTaskJumpType			= msgPacket:GetChar()
		taskInfo.mTaskJumpPara          = {}

		local jumpParaCnt				= msgPacket:GetChar()
		for i=1,jumpParaCnt do
			local para 					= msgPacket:GetChar()
			table.insert(taskInfo.mTaskJumpPara,para)
		end

		taskInfo.mRewardArr				= {}
		local rewardNum 				= msgPacket:GetUShort()
		for k = 1,rewardNum do
			local rewardInfo            = {}
			rewardInfo.mRewardType      = msgPacket:GetInt()
			rewardInfo.mItemId          = msgPacket:GetInt()
			rewardInfo.mItemCnt         = msgPacket:GetInt()
			table.insert(taskInfo.mRewardArr,rewardInfo)
		end

		table.insert(taskArr,taskInfo)
	end

	self.mDataSource[TASKTYPE.USUAL] = {}

	for i=1,#taskArr do
		table.insert(self.mDataSource[taskArr[i].mTaskType],taskArr[i])
	end

	self:sortTasks(self.mDataSource[1])
	self:sortTasks(self.mDataSource[2])

	self.mActivity =  msgPacket:GetInt()
	self.mLstActivity = self.mActivity

	local rewardCnt = msgPacket:GetUShort()

	self.mStateArr = {}
	for i=1,rewardCnt do
		self.mStateArr[i] = msgPacket:GetChar()
	end

	local function xxx()
		GUISystem:hideLoading()
	end
	nextTick(xxx)

	if self.mRefresh == true then
		self.mOwner:InitUsualPage()
	else
		EventSystem:PushEvent(Event.GUISYSTEM_SHOW_TASKWINDOW)
    end	
end

function TaskModel:getActivityValue()
	return self.mActivity
end

function TaskModel:sortTasks(taskArr)
	local function sortFunc(task1,task2)
		if task1.mTaskId < task2.mTaskId then
			return true
		else
			return false
		end
	end

	local doneTask = {}
	local unDoneTask = {}

	local taskCnt = #taskArr

	for i=1,taskCnt do
		if taskArr[i].mTaskIsFinish == 1 then
			table.insert(doneTask,taskArr[i])
		else
			table.insert(unDoneTask,taskArr[i])
		end
	end

	table.sort(doneTask,sortFunc)
	table.sort(unDoneTask,sortFunc)

	for i=1,#doneTask do
		taskArr[i] = doneTask[i]
	end

	local curIdx = #doneTask + 1

	for i=1,#unDoneTask do
		taskArr[curIdx] = unDoneTask[i]
		curIdx = curIdx + 1
	end
end

function TaskModel:doRefreshRequest()
	if globaldata.diamond < self.mActivity then MessageBox:showMessageBox1("钻石不足") return end
	local packet = NetSystem.mNetManager:GetSPacket()
	packet:SetType(PacketTyper.__PTYPE_CS_REQUEST_TASK_REFRESH_)
	packet:PushChar(TASKTYPE.USUAL)
	packet:Send()
	GUISystem:showLoading()
end

function TaskModel:onRefreshResponse(msgPacket)
	self.mRefresh = true
	self:onLoadTaskResponse(msgPacket)
end

function TaskModel:doGetRewardRequest(index)
	self.mGetIndex		= index
	local packet = NetSystem.mNetManager:GetSPacket()
	packet:SetType(PacketTyper.__PTYPE_CS_REQUEST_GET_TASK_REWARD_)
	packet:PushInt(self.mDataSource[self.mOwner.mTaskType][index].mTaskId)
	packet:Send()
	GUISystem:showLoading()
end

function TaskModel:onGetRewardResponse(msgPacket)
	local taskCnt       = msgPacket:GetUShort()
	local taskArr       = {}

	local typ           = nil

	for i=1,taskCnt do
		local taskInfo                  = {}
		taskInfo.mTaskType     		    = msgPacket:GetChar()
		typ = taskInfo.mTaskType 
		taskInfo.mTaskId	            = msgPacket:GetInt()
		taskInfo.mTaskNameStr	        = msgPacket:GetString()
		taskInfo.mTaskDescStr			= msgPacket:GetString()
		taskInfo.mTaskProStr			= msgPacket:GetString()
		taskInfo.mTaskIsFinish			= msgPacket:GetChar()
		taskInfo.mTaskDiffculty			= msgPacket:GetChar()

		taskInfo.mTaskJumpType			= msgPacket:GetChar()
		taskInfo.mTaskJumpPara          = {}

		local jumpParaCnt				= msgPacket:GetChar()
		for i=1,jumpParaCnt do
			local para 					= msgPacket:GetChar()
			table.insert(taskInfo.mTaskJumpPara,para)
		end

		taskInfo.mRewardArr				= {}
		local rewardNum 				= msgPacket:GetUShort()
		for k = 1,rewardNum do
			local rewardInfo            = {}
			rewardInfo.mRewardType      = msgPacket:GetInt()
			rewardInfo.mItemId          = msgPacket:GetInt()
			rewardInfo.mItemCnt         = msgPacket:GetInt()
			table.insert(taskInfo.mRewardArr,rewardInfo)
		end

		table.insert(taskArr,taskInfo)
	end

	self.mDataSource[self.mOwner.mTaskType] = {}
	
	for i=1,#taskArr do
		table.insert(self.mDataSource[taskArr[i].mTaskType],taskArr[i])
	end

	self:sortTasks(self.mDataSource[1])
	self:sortTasks(self.mDataSource[2])

	self.mActivity =  msgPacket:GetInt()

	local rewardCnt = msgPacket:GetUShort()

	self.mStateArr = {}
	for i=1,rewardCnt do
		self.mStateArr[i] = msgPacket:GetChar()
	end

	if self.mOwner ~= nil then
		if typ == TASKTYPE.USUAL then
			self.mOwner:InitUsualPage()
		else
			self.mOwner:InitAchievementPage()
		end
	end
	GUISystem:hideLoading()
end

function TaskModel:onTaskSyncHappen()
	local index   = 0
	local taskArr = self.mDataSource[globaldata.syncTaskInfo.mTaskType]

	for i=1,#taskArr do
		if globaldata.syncTaskInfo.mTaskId == taskArr[i].mTaskId then
			index = i
		end
	end
 	
 	if index ~= 0 then
		taskArr[index] = globaldata.syncTaskInfo
	else
		table.insert(taskArr,globaldata.syncTaskInfo)
	end

	self:sortTasks(self.mDataSource[1])
	self:sortTasks(self.mDataSource[2])

	if self.mOwner then
		if self.mOwner.mTaskType == TASKTYPE.USUAL then
			self.mOwner:InitUsualPage()
		else
			self.mOwner:InitAchievementPage()
		end
	end

	globaldata.syncTaskInfo = nil
end

function TaskModel:doLoadRewardInfoRequest(index)
	local packet = NetSystem.mNetManager:GetSPacket()
	packet:SetType(PacketTyper._PTYPE_CS_ACTIVITY_REWARD_INFO_)
	packet:PushChar(index)
	packet:Send()
	GUISystem:showLoading()
end

function TaskModel:onLoadRewardInfoResponse(msgPacket)
	local rewardCnt1           = msgPacket:GetUShort()
	local rewardArr = {}
	for i=1,rewardCnt1 do
		local itemType    = msgPacket:GetInt()
		local itemId      = msgPacket:GetInt()
		local itemCnt     = msgPacket:GetInt()
		rewardArr[i] = {itemType, itemId, itemCnt}
	end

	GUISystem:hideLoading()
	MessageBox:showMessageBox6(rewardArr)
end

function TaskModel:doGetActivityRewardRequest(index)
	local packet = NetSystem.mNetManager:GetSPacket()
	packet:SetType(PacketTyper._PTYPE_SC_GETACTIVITY_REWARD_INFO_)
	packet:PushChar(index)
	packet:Send()
end

--==================================================================window begin==========================================================================

local TaskTableView = {}

function TaskTableView:new(owner,listType)
	local o = 
	{
		mOwner			  = owner,
		mRootNode 	      =	nil,
		mType 		      =	listType,
		mTableView	      =	nil,
		mFirstCell		  = nil,
	}
	o = newObject(o, TaskTableView)
	return o
end

function TaskTableView:Destroy()
	self.mRootNode:removeFromParent(true)
	self.mRootNode   = nil
	self.mTableView  = nil
	self.mOwner      = nil
	self.mFirstCell  = nil
end

function TaskTableView:init(rootNode)
	self.mRootNode = rootNode
	-- 初始化数据源
	self:initTableView()
end

function TaskTableView:myModel()
	return self.mOwner.mModel
end

function TaskTableView:initTableView()
	self.mTableView = TableViewEx:new()

	local widget = GUIWidgetPool:createWidget("Task_Cell")
	self.mTableView:setCellSize(widget:getContentSize())
	
	self.mTableView:setCellCount(#self:myModel().mDataSource[self.mOwner.mTaskType])

	self.mTableView:registerTableCellAtIndexFunc(handler(self, self.tableCellAtIndex))
	self.mTableView:registerTableCellTouchedFunc(handler(self, self.tableCellTouched))

	self.mTableView:init(self.mRootNode:getContentSize(), cc.p(0,0), 1)
	self.mRootNode:addChild(self.mTableView:getRootNode())
end

function TaskTableView:tableCellAtIndex(table, index)
	local cell = table:dequeueCell()
	local taskItem = nil

	if nil == cell then
		cell = cc.TableViewCell:new()
		taskItem = GUIWidgetPool:createWidget("Task_Cell")
		
		taskItem:setTouchSwallowed(false)
		taskItem:setTag(1)
		cell:addChild(taskItem)
	else
		taskItem = cell:getChildByTag(1)
	end

	if index == 0 then
		self.mFirstCell = taskItem
	end

	taskItem:setVisible(true)
	self.mOwner:setCellLayOut(taskItem,index+1)

	return cell
end

function TaskTableView:getFirstCell()
	return self.mFirstCell
end

function TaskTableView:tableCellTouched(table,cell)
	print("TaskTableView cell touched at index: " .. cell:getIdx())
end

function TaskTableView:UpdateTableView(cellCnt)
	self.mTableView:setCellCount(cellCnt)
	self.mTableView:reloadData()
end

--===============================================================window begin=====================================================================
local TaskWindow = 
{
	mName 				= 	"TaskWindow",
	mRootNode 			= 	nil,
	mRootWidget 		= 	nil,
	mTopRoleInfoPanel	=	nil,	-- 顶部人物信息面板
	mLastClickPageIdx   =	nil,
	mTaskTVA			=   nil,
	mTaskTVU			=   nil,
	mIsLoaded 			=   false,
	mTaskType           =   nil,
	mModel        	    =   nil,

	mRewardAnims        =  {}
}

function TaskWindow:Release()

end

function TaskWindow:Load(event)	
	cclog("=====TaskWindow:Load=====begin")

	self.mRootNode = cc.Node:create()
	GUISystem:GetRootNode():addChild(self.mRootNode)
	self.mIsLoaded = true

	self.mModel = TaskModel:getInstance()
	self.mModel:setOwner(self)
	
	self:InitLayout(event)

	local function doTaskGuideOne_Stop()
		TaskGuideOne:stop()
	end
	TaskGuideOne:step(3, nil, doTaskGuideOne_Stop)

	local function doTaskGuideZero_Stop()
		TaskGuideZero:stop()
	end
	TaskGuideZero:step(3, nil, doTaskGuideZero_Stop)

	cclog("=====TaskWindow:Load=====end")
end

function TaskWindow:InitLayout(event)
	if self.mRootWidget == nil then
		self.mRootWidget = GUIWidgetPool:createWidget("Task")
    	self.mRootNode:addChild(self.mRootWidget, 100)
    end

    local function closeWindow()
    	GUISystem:playSound("homeBtnSound")
		EventSystem:PushEvent(Event.GUISYSTEM_HIDE_TASKWINDOW)

		if EquipGuideOne:canGuide() then
			local window = GUISystem:GetWindowByName("HomeWindow")
			if window.mRootWidget then
				local guideBtn = window.mRootWidget:getChildByName("Image_Hero")
				local size = guideBtn:getContentSize()
				local pos = guideBtn:getWorldPosition()
				pos.x = pos.x - size.width/2
				pos.y = pos.y - size.height/2
				local touchRect = cc.rect(pos.x, pos.y, size.width, size.height)
				EquipGuideOne:step(2, touchRect)
			end
		end
	end

	if self.mTopRoleInfoPanel == nil then
		cclog("TaskWindow mTopRoleInfoPanel init")
		self.mTopRoleInfoPanel = TopRoleInfoPanel:new()
		self.mTopRoleInfoPanel:init(self.mRootNode,ROLE_TITLE_TYPE.TITLE_TASK, closeWindow)
	end

	local topSize = self.mTopRoleInfoPanel.mTopWidget:getContentSize()
	local y       = getGoldFightPosition_Middle().y - topSize.height / 2
	local x       = getGoldFightPosition_Middle().x

	self.mRootWidget:getChildByName("Panel_Main"):setAnchorPoint(cc.p(0.5, 0.5))
	self.mRootWidget:getChildByName("Panel_Main"):setPosition(cc.p(x,y))
	
	self.mRootWidget:getChildByName("Panel_Main"):setOpacity(0)
	self.mRootWidget:getChildByName("Panel_Main"):setScale(0.5)
	local act0 = cc.ScaleTo:create(0.15, 1)
	local act1 = cc.FadeIn:create(0.15)
	--	local act1 = cc.EaseElasticOut:create(act0)
	self.mRootWidget:getChildByName("Panel_Main"):runAction(cc.Spawn:create(act0, act1))

	local pageUsual = self.mRootWidget:getChildByName("Image_Usual")
	local pageAchievement = self.mRootWidget:getChildByName("Image_Achievement")

	registerWidgetReleaseUpEvent(pageUsual,handler(self, self.onClickPage))
	registerWidgetReleaseUpEvent(pageAchievement,handler(self, self.onClickPage))

	pageUsual:setVisible(globaldata.level >= 13)
	self:onClickPage((globaldata.level < 13 and pageAchievement or pageUsual),false)
end

function TaskWindow:GetActivityValue()
	return self.mModel:getActivityValue()
end

function TaskWindow:InitUsualPage()
	self.mRootWidget:getChildByName("Panel_Usual"):setVisible(true)
	self.mRootWidget:getChildByName("Panel_Achievement"):setVisible(false)
	self.mRootWidget:getChildByName("Image_Achievement"):loadTexture("task_title2_2.png")
	self.mRootWidget:getChildByName("Image_Usual"):loadTexture("task_title1_1.png")
	self.mRootWidget:getChildByName("Image_Usual"):setVisible(globaldata.level >= 13)

	if self.mTaskTVU == nil then
		self.mTaskTVU = TaskTableView:new(self,0)
		self.mTaskTVU:init(self.mRootWidget:getChildByName("Panel_Usual"):getChildByName("Panel_TaskList"))
	else
		self.mTaskTVU:UpdateTableView(#self.mModel.mDataSource[TASKTYPE.USUAL])
	end

	self.mTaskTVU.mTableView:setTouchEnabled(true)
	if self.mTaskTVA then
		self.mTaskTVA.mTableView:setTouchEnabled(false)
	end

	for i=1,4 do
		local rewardBox = self.mRootWidget:getChildByName(string.format("Panel_Box%d",i))

		if self.mRewardAnims[i] == nil then
			self.mRewardAnims[i] = AnimManager:createAnimNode(8004)

			local panel = rewardBox:getChildByName("Panel_Animation")
			rewardBox:setTag(i)
			panel:addChild(self.mRewardAnims[i]:getRootNode(), 100)
		end

		if self.mModel.mStateArr[i] == 0 then
			self.mRewardAnims[i]:play("pve_rewardsbox1", true)
			registerWidgetReleaseUpEvent(rewardBox,function(widget) self.mModel:doLoadRewardInfoRequest(widget:getTag()) end)
		elseif self.mModel.mStateArr[i] == 1 then
			self.mRewardAnims[i]:play("pve_rewardsbox2", true)

			local function xxx(widget)
				local index = widget:getTag()
				registerWidgetReleaseUpEvent(rewardBox,function() end)
				self.mRewardAnims[index]:play("pve_rewardsbox3", false, 
				function() 
					self.mModel:doGetActivityRewardRequest(index)
					self.mModel.mStateArr[index] = 2
					self.mRewardAnims[index]:play("pve_rewardsbox5", true) 
				end)
			end
			registerWidgetReleaseUpEvent(rewardBox,xxx)
		else
			self.mRewardAnims[i]:play("pve_rewardsbox5", true)
		end	
	end

	--动画进度条
	if  self.mAniBar == nil then
    	self.mAniBar = cc.ProgressTimer:create(cc.Sprite:create("task_activity_prograssbar.png"))
	    self.mAniBar:setType(2)
	    self.mAniBar:setSlopbarParam(40, 0.025)
	    -- Setup for a bar starting from the bottom since the midpoint is 0 for the y
	    self.mAniBar:setMidpoint(cc.p(0,1))
	    -- Setup for a vertical bar since the bar change rate is 0 for x meaning no horizontal change
	    self.mAniBar:setAnchorPoint(cc.p(0,0))
	    self.mAniBar:setBarChangeRate(cc.p(1, 0))
	    self.mAniBar:setPosition(15,13)

	    self.mRootWidget:getChildByName("Image_Prograss_Bg"):addChild(self.mAniBar)
	end

    self.mAniBar:setPercentage(self.mModel.mLstActivity)
	self.mAniBar:runAction(cc.ProgressTo:create(0.5, self.mModel.mActivity))
	self.mModel.mLstActivity = self.mModel.mActivity

	self.mRootWidget:getChildByName("Label_Activity"):setString(tostring(self.mModel.mActivity))
end

function TaskWindow:setCellLayOut(cell,index)
	--[[local originPos = nil

	local function runBegin()
		originPos = cc.p(cell:getWorldPosition())
		local size = cell:getContentSize()
		local destPos = cc.p(originPos.x + 100,originPos.y)
		cell:setPosition(destPos)
	end

	local actBegin = cc.CallFunc:create(runBegin)
	local actMove  =  cc.MoveTo:create(5, originPos)
	cell:runAction(cc.Sequence:create(actBegin,actMove))]]

	cell:setOpacity(0)
	cell:runAction(cc.FadeIn:create(0.2))

	cell:getChildByName("Button_GetReward"):setTag(index)
	cell:getChildByName("Button_GoToDo"):setTag(index)

	cell:getChildByName("Panel_Reward"..2):setVisible(true)
	cell:getChildByName("Panel_Reward"..3):setVisible(true)

	if #self.mModel.mDataSource[self.mTaskType] == 0 then return end
	local taskInfo = self.mModel.mDataSource[self.mTaskType][index]
	if taskInfo == nil then return end

	if taskInfo.mTaskIsFinish ==  1 then   	--完成
		cell:getChildByName("Button_GoToDo"):setVisible(false)
		cell:getChildByName("Button_GoToDo"):setTouchEnabled(false)
		cell:getChildByName("Button_GetReward"):setVisible(true)
		cell:getChildByName("Button_GetReward"):setTouchEnabled(true)
		cell:getChildByName("Image_Bg"):loadTexture("task_entry1.png")

		registerWidgetReleaseUpEvent(cell:getChildByName("Button_GetReward"),
			function(widget) 
				GUISystem:playSound("homeBtnSound") 
				self.mModel:doGetRewardRequest(widget:getTag()) 
			end)
		ShaderManager:DoUIWidgetDisabled(cell:getChildByName("Button_GetReward"), false)
	elseif taskInfo.mTaskIsFinish == 0 then   --未完成
		cell:getChildByName("Button_GoToDo"):setVisible(true)
		cell:getChildByName("Button_GetReward"):setVisible(false)
		cell:getChildByName("Button_GetReward"):setTouchEnabled(false)
		cell:getChildByName("Button_GoToDo"):setTouchEnabled(true)
		cell:getChildByName("Image_Bg"):loadTexture("task_entry2.png")
		registerWidgetReleaseUpEvent(cell:getChildByName("Button_GoToDo"), handler(self,self.onBtnGoTo))
	elseif taskInfo.mTaskIsFinish == 2 then   --已领取
		cell:getChildByName("Button_GoToDo"):setVisible(false)
		cell:getChildByName("Button_GetReward"):setVisible(true)		
		
		ShaderManager:DoUIWidgetDisabled(cell:getChildByName("Button_GetReward"), true)
		registerWidgetReleaseUpEvent(cell:getChildByName("Button_GetReward"),function(widget)  end) 
	end

	if taskInfo.mTaskJumpType == 0 then
		cell:getChildByName("Button_GoToDo"):setVisible(false)
	end

	if self.mTaskType == TASKTYPE.ACHIEVE then --self.mModel.mDataSource[index].mTaskDiffculty == 0
		cell:getChildByName("Image_TaskQuality"):setVisible(false)
		print("&&&&&&&&&&&&&&&&&&&&&&&&&&&&",taskInfo.mTaskId)
	else
		cell:getChildByName("Image_TaskQuality"):setVisible(true)
		cell:getChildByName("Image_TaskQuality"):loadTexture(string.format("task_quality%d.png", taskInfo.mTaskDiffculty))
	end

	if taskInfo.mTaskProStr ~= "" then
		cell:getChildByName("Label_Title"):setString(string.format("%s (%s)",taskInfo.mTaskNameStr,taskInfo.mTaskProStr))
	else
		cell:getChildByName("Label_Title"):setString(string.format("%s",taskInfo.mTaskNameStr))
	end

	for i=1,3 do
		cell:getChildByName("Panel_Reward"..i):setVisible(false)
	end

	for i=1,#taskInfo.mRewardArr do
		local rewardInfo = taskInfo.mRewardArr[i]
		local panelReward = cell:getChildByName("Panel_Reward"..i)
		self:setPanelRewardLayout(panelReward,rewardInfo)
	end
end

function TaskWindow:setPanelRewardLayout(panelReward,rewardInfo)
	local  itemType = rewardInfo.mRewardType
	local  itemId   = rewardInfo.mItemId
	local  itemCnt  = rewardInfo.mItemCnt

	panelReward:setVisible(true)

	if itemType == 0 or itemType == 1 then
		panelReward:getChildByName("Panel_Item"):removeAllChildren()
		local rewardWidget = createCommonWidget(itemType,itemId,itemCnt)
		rewardWidget:getChildByName("Label_Count_Stroke"):setVisible(false)
		panelReward:getChildByName("Panel_Item"):addChild(rewardWidget)
		panelReward:getChildByName("Panel_Item"):setVisible(true)
		panelReward:getChildByName("Image_Item"):setVisible(false)
	elseif itemType == 2 then
		panelReward:getChildByName("Image_Item"):loadTexture("public_gold.png")
		panelReward:getChildByName("Image_Item"):setVisible(true)
		panelReward:getChildByName("Panel_Item"):setVisible(false)
	elseif itemType == 3 then
		panelReward:getChildByName("Image_Item"):loadTexture("public_diamond.png")
		panelReward:getChildByName("Image_Item"):setVisible(true)
		panelReward:getChildByName("Panel_Item"):setVisible(false)
	elseif itemType == 4 then
		panelReward:getChildByName("Image_Item"):loadTexture("public_exp.png")
		panelReward:getChildByName("Image_Item"):setVisible(true)
		panelReward:getChildByName("Panel_Item"):setVisible(false)
	elseif itemType == 13 then
		panelReward:getChildByName("Image_Item"):loadTexture("task_activity_icon.png")
		panelReward:getChildByName("Image_Item"):setVisible(true)
		panelReward:getChildByName("Panel_Item"):setVisible(false)
	end

	panelReward:getChildByName("Label_Num"):setVisible(true)
	panelReward:getChildByName("Label_Num"):setString(rewardInfo.mItemCnt)
end

function TaskWindow:GetUsualTVFirstCell()
	if self.mTaskType == TASKTYPE.USUAL then
		if self.mTaskTVU then
			return self.mTaskTVU:getFirstCell()
		end
	end
end

function TaskWindow:InitAchievementPage()
	self.mRootWidget:getChildByName("Panel_Achievement"):setVisible(true)
	self.mRootWidget:getChildByName("Panel_Usual"):setVisible(false)

	local pageUsual = self.mRootWidget:getChildByName("Image_Usual")
	local pageAchievement = self.mRootWidget:getChildByName("Image_Achievement")
	local usualPos = cc.p(pageUsual:getPosition())
	local usualSize = pageUsual:getContentSize()

	pageAchievement:loadTexture("task_title2_1.png")
	pageUsual:loadTexture("task_title1_2.png")

	pageAchievement:setPositionX(globaldata.level < 13 and usualPos.x or usualPos.x + usualSize.width - 10)
	pageUsual:setVisible(globaldata.level >= 13)

	if self.mTaskTVA == nil then
		self.mTaskTVA = TaskTableView:new(self,0)
		self.mTaskTVA:init(self.mRootWidget:getChildByName("Panel_Achievement"):getChildByName("Panel_TaskList"))
	else
		self.mTaskTVA:UpdateTableView(#self.mModel.mDataSource[TASKTYPE.ACHIEVE])
	end

	self.mTaskTVA.mTableView:setTouchEnabled(true)
	if self.mTaskTVU then
		self.mTaskTVU.mTableView:setTouchEnabled(false)
	end
end

function TaskWindow:onClickPage(widget,bSound)
	if bSound == nil then GUISystem:playSound("tabPageSound") end
	self.mTaskType = widget:getTag()

	if self.mLastClickPageIdx == self.mTaskType then return end

	if self.mTaskType == TASKTYPE.USUAL then
		self:InitUsualPage()
	elseif self.mTaskType == TASKTYPE.ACHIEVE then
		self:InitAchievementPage()
	end

	self.mLastClickPageIdx = self.mTaskType
end

function TaskWindow:onBtnGoTo(widget)
	GUISystem:playSound("tabPageSound")
	
	local index    = widget:getTag()
	local taskInfo = self.mModel.mDataSource[self.mTaskType][index]

	wndJump(taskInfo.mTaskJumpType,taskInfo.mTaskJumpPara)
end

function TaskWindow:Destroy()
	if not self.mIsLoaded then return end
	self.mIsLoaded = false
	if self.mTaskTVA then
		self.mTaskTVA:Destroy()
		self.mTaskTVA     		= nil
	end

	if self.mTaskTVU then
		self.mTaskTVU:Destroy()
		self.mTaskTVU     		= nil
	end

	for i = 1, #self.mRewardAnims do
		self.mRewardAnims[i]:destroy()
		self.mRewardAnims[i] = nil
	end
	
	if self.mTopRoleInfoPanel ~= nil then
		self.mTopRoleInfoPanel:destroy()
		self.mTopRoleInfoPanel  = nil
	end

	if self.mRootNode ~= nil then
		self.mRootNode:removeFromParent(true)
		self.mRootNode          = nil
	end

	self.mRootWidget        = nil
	self.mLastClickPageIdx  = nil

	self.mRootWidget = nil
	self.mAniBar = nil

	self.mModel:destroyInstance()


	CommonAnimation.clearAllTextures()
end

function TaskWindow:onEventHandler(event)
	if event.mAction == Event.WINDOW_SHOW then
		if GUISystem:canShow(self.mName) then
			self:Load(event)
			---------停止画主城镇界面
			EventSystem:PushEvent(Event.GUISYSTEM_DISABLEDRAW_HOMEWINDOW)
			---------
		end
		NoticeSystem:doSingleUpdate(self.mName)
	elseif event.mAction == Event.WINDOW_HIDE then
		self:Destroy()
		---------开启画主城镇界面
		EventSystem:PushEvent(Event.GUISYSTEM_EABLEDRAW_HOMEWINDOW)
		---------
	end
end

return TaskWindow