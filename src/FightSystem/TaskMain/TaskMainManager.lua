-- Name: TaskMainManager
-- Func: 主线任务管理器
-- Author: tuanzhang

local TaskMainManager = class("TaskMainManager")


function TaskMainManager:ctor()
	self.mMainTaskInfo = nil
    self.CGPlaySpeed = 0.03
    self.mDialogTable = {}
end

function TaskMainManager:Destroy()
    self.mMainTaskInfo = nil
    self.mTaskPanel = nil
    self.mDialogTable = {}
end
-- 
function TaskMainManager:UpDateTask(_panle)
	if not self.mMainTaskInfo then return end
    if self.NoTask then return end
    self.mTaskPanel = _panle
	_panle:setVisible(true)
	_panle:getChildByName("Label_TaskName"):setString(string.format("【%s】",self.mMainTaskInfo.mTaskNameStr))
	self.mCurTaskData = DB_TaskConfig.getDataById(self.mMainTaskInfo.mTaskId)
	if not self.mCurTaskData then return end
	self.mNpcId = nil
    --_panle:getChildByName("Label_State"):setColor()
	if self.mMainTaskInfo.mTaskIsFinish == 0 then
        _panle:getChildByName("Label_State"):setColor(cc.c3b(255,252,0))
		_panle:getChildByName("Label_State"):setString("未完成")
		self.mNpcId = self.mCurTaskData.ACC_NPCID
        self:InitTalkList("ACC_Talk%d")
        _panle:getChildByName("Label_Story_Des"):setVisible(true)
	elseif self.mMainTaskInfo.mTaskIsFinish == 1 then
        if _panle:getChildByName("Label_State"):getString() ~= "完成" then
            local animNode = AnimManager:createAnimNode(8029)
            _panle:getChildByName("Panel_Animation"):addChild(animNode:getRootNode(), 100)
            animNode:play("storytask_complete")
        end
        _panle:getChildByName("Label_State"):setColor(cc.c3b(42,255,0))
		_panle:getChildByName("Label_State"):setString("完成")
		self.mNpcId = self.mCurTaskData.FIN_NPCID
        self:InitTalkList("FIN_Talk%d")
        _panle:getChildByName("Label_Story_Des"):setVisible(true)
	elseif self.mMainTaskInfo.mTaskIsFinish == 3 then
        self.mNpcId = self.mCurTaskData.ACC_NPCID
        _panle:getChildByName("Label_State"):setColor(cc.c3b(255,252,0))
		_panle:getChildByName("Label_State"):setString("未完成")
        self:InitTalkList("ACC_Talk%d")
        _panle:getChildByName("Label_Story_Des"):setVisible(true)
	end
    local monster = DB_MonsterConfig.getDataById(self.mNpcId)
    local imgName = DB_ResourceList.getDataById(monster.Monster_Icon).Res_path1
    _panle:getChildByName("Image_NPC_Icon"):loadTexture(imgName, 1)

	-- if self.mMainTaskInfo.mTaskIsFinish ~= 3 then
	-- 	local monster = DB_MonsterConfig.getDataById(self.mNpcId)
	-- 	local name = getDictionaryText(monster.Name)
	-- 	_panle:getChildByName("Label_NPC_Name"):setString(name)
	-- 	_panle:getChildByName("Label_NPC_Name"):setVisible(true)
	-- else
	-- 	_panle:getChildByName("Label_NPC_Name"):setVisible(false)
	-- end
    _panle:getChildByName("Label_Story_Des"):setString(self.mMainTaskInfo.mTaskDescStr)  
	-- if self.mMainTaskInfo.mTaskProStr == "" then
	-- 	_panle:getChildByName("Label_Story_Des"):setString(self.mMainTaskInfo.mTaskDescStr)  
	-- else
	-- 	_panle:getChildByName("Label_Story_Des"):setString(string.format("%s(%s)",self.mMainTaskInfo.mTaskDescStr,self.mMainTaskInfo.mTaskProStr))  
	-- end
end

-- 是否是当前NPC
function TaskMainManager:IsTaskNPC(_npcId)
    if self.mNpcId then
        if self.mNpcId == _npcId then
            return true
        end
    end
    return false
end


-- 存对话表
function TaskMainManager:InitTalkList(_str)
    self.mTalkList = {}
    for i=1,6 do
        local data = self.mCurTaskData[string.format(_str,i)]
        if type(data) == "table" then
            table.insert(self.mTalkList,data)
        else
            break
        end
    end
end

function TaskMainManager:AutoRoadCity()
   AutoMoveManager:FindPosListByNPCID(self.mNpcId,FightSystem.mHallManager.mCurCityID)
   local _role = FightSystem.mHallManager:getMyRole()
   if #AutoMoveManager.mAutoPosList == 1 then
        self.mIsAutoFind = true
        _role:WalkingByPos(AutoMoveManager.mAutoPosList[1],handler(self,self.OnStopGoalPos))
   else
        self.mIsAutoFind = true
        _role:WalkingByPos(AutoMoveManager.mAutoPosList[1])
        
   end
end

function TaskMainManager:OnStopGoalPos(_type)
	cclog("OnStopGoal=====" .._type )
    if #self.mTalkList ~= 0  and  _type == "daoda" and not self.mWidgetTalk then
        self.mIsAutoFind = false
        GUISystem:enableUserInput()
        self:CreateAllDialog()
        self.mTalkIndex = 1
        self:PlayTalk(self.mTalkList[self.mTalkIndex][1],self.mTalkList[self.mTalkIndex][2])
    end
end

-- 点击主线任务栏
function TaskMainManager:OnTaskEvent()
    if FightSystem:GetKeyRole().mFSM:IsRuning() then return end
    if self.mWidgetTalk then return end
	if self.mMainTaskInfo.mTaskIsFinish == 0 then
        self:AutoRoadCity()
	elseif self.mMainTaskInfo.mTaskIsFinish == 1 then
        self:AutoRoadCity()
	elseif self.mMainTaskInfo.mTaskIsFinish == 3 then
	  self:onBtnGoTo()
	end
end

-- 创建当前对话框
function TaskMainManager:CreateAllDialog()
   -- local Widget1 = GUIWidgetPool:createWidget("CGShade")
    local WidgetTalk = GUIWidgetPool:createWidget("CGTalkText")
    self.mWidgetTalk = WidgetTalk
    self.mTalkBoxLeft = WidgetTalk:getChildByName("Image_Talk_BoxLeft")
    self.mArrow_l = WidgetTalk:getChildByName("Panel_Arrow") 
    local _resDB = DB_ResourceList.getDataById(612)
    
    local animNode = AnimManager:createAnimNode(8022)
    self.mArrow_l:addChild(animNode:getRootNode(), 100)
    animNode:play("cg_arrow_next", true)

    self.mTalkBoxRight = WidgetTalk:getChildByName("Image_Talk_BoxRight")
   
    for i=1,2 do
        local  head = nil
        local point = nil
        local labeltalk = nil
        local labelname = nil
        if i == 1 then
            --point =  cc.p(getGoldFightPosition_LD().x+130,getGoldFightPosition_LD().y-200)
            labeltalk = self.mTalkBoxLeft:getChildByName("Label_CG_Talk")
            labelname = self.mTalkBoxLeft:getChildByName("Label_Name")
            head = WidgetTalk:getChildByName("Panel_Main_Left"):getChildByName("Image_CG_HalfHead")
            head:setVisible(false)
        elseif i == 2 then
            --point =  cc.p(getGoldFightPosition_RD().x-130,getGoldFightPosition_RD().y-200)
            labeltalk = self.mTalkBoxRight:getChildByName("Label_CG_Talk")
            labelname = self.mTalkBoxRight:getChildByName("Label_Name")
            head = WidgetTalk:getChildByName("Panel_Main_Right"):getChildByName("Image_CG_HalfHead")
            head:setVisible(false)
        end
        self.mDialogTable[i] = {["head"] = head,["labeltalk"] = labeltalk,["labelname"] = labelname}
        --head:setPosition(point)
    end
    self.CurHeadpos1 = cc.p(self.mDialogTable[1]["head"]:getPositionX()-150,self.mDialogTable[1]["head"]:getPositionY())
    self.CurHeadpos2 = cc.p(self.mDialogTable[2]["head"]:getPositionX()+150,self.mDialogTable[2]["head"]:getPositionY())

    self.mDialogTable[1]["head"]:setPosition(self.CurHeadpos1)
    self.mDialogTable[2]["head"]:setPosition(self.CurHeadpos2)

    GUISystem.Windows["HomeWindow"].mRootNode:addChild(WidgetTalk,300)
    --WidgetTalk:setPosition(cc.p(getGoldFightPosition_Middle().x,getGoldFightPosition_LD().y))
    local function doSomething()
        WidgetTalk:getChildByName("Panel_Main_Left"):setPosition(getGoldFightPosition_LD())
        WidgetTalk:getChildByName("Panel_Main_Right"):setPosition(getGoldFightPosition_RD())
        WidgetTalk:getChildByName("Panel_Next"):setPosition(getGoldFightPosition_RD())
       
    end 

    doSomething()
    self.layer = WidgetTalk:getChildByName("Panel_Shade_layer")
    registerWidgetReleaseUpEvent(self.layer,handler(self,self.TouchEventTalk))
    self.layer:setEnabled(false)
end



--播放对话
function TaskMainManager:PlayTalk(id,Param1)
    if id == 0 or id== -1 then
        self.Curplace = 1
    else
        self.Curplace = 2
    end
    local _resDB = nil
    local heroName = nil
    if id == -1 then
        local _heroID = globaldata:getBattleFormationInfoByIndexAndKey(1, "id")
        local _infoDB = DB_HeroConfig.getDataById(_heroID)
        heroName = getDictionaryText(_infoDB.Name)
        _resDB = DB_ResourceList.getDataById(_infoDB.IconCG)
    elseif id == 0 then
        local _heroID = globaldata.registerHeroId
        local _infoDB = DB_HeroConfig.getDataById(_heroID)
        heroName = getDictionaryText(_infoDB.Name)
        _resDB = DB_ResourceList.getDataById(_infoDB.IconCG)
    else
        local _infoDB = DB_MonsterConfig.getDataById(id)
        heroName = getDictionaryText(_infoDB.Name)
        _resDB = DB_ResourceList.getDataById(_infoDB.IconCG)
    end
    local head = self.mDialogTable[self.Curplace]["head"]

    self.mLabel = self.mDialogTable[self.Curplace]["labeltalk"]

    self.Strtext = getDictionaryCGText(Param1)
    self.Strtext = TextParseManager:parseText(self.Strtext)
    
    self.tableText = splitChineseString( self.Strtext)

    self.index = 0
    self.mLabel:stopAllActions()
    self.mRunLabel = true
    self.mLabel:removeAllChildren()

    local function ShowBoxFinish()
        local function doSomthing()
            if self.index == #self.tableText then
                self.mLabel:stopAllActions()
                richTextCreateWithFont(self.mLabel,self.Strtext , true,25)
                CommonAnimation.PlayEffectId(35)
                self.mRunLabel = false
            else
                self.index = self.index + 1
                --self.mLabel:setString(self.tableText[self.index])
                richTextCreateWithFont(self.mLabel,self.tableText[self.index] , true,25)
                if self.index%2 == 1 then
                    CommonAnimation.PlayEffectId(35)
                end
            end
          end

            local headfun = cc.CallFunc:create(doSomthing)
            local DelayTime = cc.DelayTime:create(self.CGPlaySpeed)
            self.mLabel:runAction(cc.RepeatForever:create(cc.Sequence:create(headfun, DelayTime)))
    end 
    head:setVisible(true)
    head:loadTexture(_resDB.Res_path1)--"skill_22_1.png"
    local width = 0--head:getBoundingBox().width/2
    local height = 0--head:getBoundingBox().height/2
    local Flag = false
    if not self.mTalkBoxLeft:isVisible() and not self.mTalkBoxRight:isVisible() then
        self.mArrow_l:setVisible(true)
        self.mArrow_l:setOpacity(0)
        local actionTo1 = cc.FadeIn:create(0.2)
        self.mArrow_l:runAction(actionTo1)
    end

    if self.Curplace == 1 then
        self.mDialogTable[1]["labelname"]:setString(heroName)
        self.Movepos1 = cc.p(0,0)
        local time = 0
        if self.mTalkBoxRight:isVisible() then
            local act1 = cc.FadeOut:create(0.2)
            local act2 = cc.Hide:create()
            local action1 = cc.Sequence:create(act1,act2)
            self.mTalkBoxRight:runAction(action1)
            local player = self.mDialogTable[2]["head"]
            local pos = cc.p(player:getPosition())
            local move = cc.MoveTo:create(0.2,cc.p(self.CurHeadpos2.x+player:getBoundingBox().width,self.CurHeadpos2.y))
            local act1 = cc.FadeOut:create(0.2)
            local acthide = cc.Hide:create()
            local act3 = cc.Spawn:create(move,act1)
            player:runAction(cc.Sequence:create(act3,acthide))
            time = 0.2
        end
        if  not self.mTalkBoxLeft:isVisible() then
            self.mTalkBoxLeft:setVisible(true)
            self.mTalkBoxLeft:setOpacity(0)
            local actionTo1 = cc.FadeIn:create(time+0.2)
            self.mTalkBoxLeft:runAction(actionTo1)

            head:setPositionX(self.CurHeadpos1.x - head:getBoundingBox().width)
            local DelayTime = cc.DelayTime:create(time+0.2)
            local function Func()
                head:setOpacity(0) 
            end
            local headfun = cc.CallFunc:create(Func)
            local act1 = cc.FadeIn:create(0.2)
            local move = cc.MoveTo:create(0.2,self.CurHeadpos1)
            local act2 = cc.Spawn:create(move,act1)
            local call1 = cc.CallFunc:create(ShowBoxFinish)
            local action1 = cc.Sequence:create(DelayTime,headfun,act2,call1)
            head:runAction(action1)
            Flag = true
        end

    elseif self.Curplace == 2 then
        self.mDialogTable[2]["labelname"]:setString(heroName)
        local time = 0
        if self.mTalkBoxLeft:isVisible() then
            local act1 = cc.FadeOut:create(0.2)
            local act2 = cc.Hide:create()
            local action1 = cc.Sequence:create(act1,act2)
            self.mTalkBoxLeft:runAction(action1)
            local player = self.mDialogTable[1]["head"]
            local pos = cc.p(player:getPosition())
            local move = cc.MoveTo:create(0.2,cc.p(self.CurHeadpos1.x-player:getBoundingBox().width,self.CurHeadpos1.y))
            local act1 = cc.FadeOut:create(0.2)
            local acthide = cc.Hide:create()
            local act3 = cc.Spawn:create(move,act1)
            player:runAction(cc.Sequence:create(act3,acthide))
            time = 0.2
        end
        if  not self.mTalkBoxRight:isVisible() then
            self.mTalkBoxRight:setVisible(true)
            self.mTalkBoxRight:setOpacity(0)
            head:setPositionX(self.CurHeadpos2.x + head:getBoundingBox().width)
            local actionTo1 = cc.FadeIn:create(time+0.2)
            self.mTalkBoxRight:runAction(actionTo1)
            head:setVisible(true)
            local DelayTime = cc.DelayTime:create(time+0.2)
            local function Func()
                head:setOpacity(0) 
            end
            local headfun = cc.CallFunc:create(Func)
            local act1 = cc.FadeIn:create(0.2)
            local move = cc.MoveTo:create(0.2,self.CurHeadpos2)
            local act2 = cc.Spawn:create(move,act1)
            local call1 = cc.CallFunc:create(ShowBoxFinish)
            local action1 = cc.Sequence:create(DelayTime,headfun,act2,call1)
            head:runAction(action1)
            Flag = true
        end
    end
    if not Flag  then
         local function doSomthing1()
            if self.index == #self.tableText then
                self.mLabel:stopAllActions()
                richTextCreateWithFont(self.mLabel,self.Strtext , true,25)
                CommonAnimation.PlayEffectId(35)
                self.mRunLabel = false
            else
                self.index = self.index + 1
                --self.mLabel:setString(self.tableText[self.index])
                richTextCreateWithFont(self.mLabel,self.tableText[self.index] , true,25)
                if self.index%2 == 1 then
                    CommonAnimation.PlayEffectId(35)
                end
            end
        end
        local headfun = cc.CallFunc:create(doSomthing1)
        local DelayTime = cc.DelayTime:create(self.CGPlaySpeed)
        self.mLabel:runAction(cc.RepeatForever:create(cc.Sequence:create(headfun, DelayTime)))
    end
    self.layer:setEnabled(true)
    if #self.mTalkList > self.mTalkIndex then
        self.mTalkIndex = self.mTalkIndex + 1   
    end
    self:ShowLastTalk() 
end

--对话点击
function TaskMainManager:TouchEventTalk()
    --
    if self.mRunLabel then
        self.mLabel:stopAllActions()
        richTextCreateWithFont(self.mLabel,self.Strtext , true,25)
        CommonAnimation.PlayEffectId(35)
        self.mRunLabel = false
        self:StopTalkAction(self.Curplace)
    else
        self.layer:setEnabled(false)
        self:TalkNext()
    end
end

function TaskMainManager:StopTalkAction(index)
    local head1 = self.mDialogTable[1]["head"]
    local head2 = self.mDialogTable[2]["head"]
    if index == 1 then
        self.mTalkBoxLeft:stopAllActions()
        self.mTalkBoxRight:stopAllActions()
        head1:stopAllActions()
        head2:stopAllActions()
        self.mTalkBoxLeft:setVisible(true)
        self.mTalkBoxRight:setVisible(false)
        head1:setVisible(true)
        head1:setOpacity(255)
        head2:setVisible(false)
        self.mTalkBoxLeft:setOpacity(255)
        self.mTalkBoxRight:setOpacity(255)
        head1:setPosition(self.CurHeadpos1)
    elseif index == 2 then
        self.mTalkBoxLeft:stopAllActions()
        self.mTalkBoxRight:stopAllActions()
        head1:stopAllActions()
        head2:stopAllActions()
        self.mTalkBoxLeft:setVisible(false)
        self.mTalkBoxRight:setVisible(true)
        head1:setVisible(false)
        head2:setVisible(true)
        head2:setOpacity(255)
        self.mTalkBoxLeft:setOpacity(255)
        self.mTalkBoxRight:setOpacity(255)
        head2:setPosition(self.CurHeadpos2)
    end
end

-- 弹出对话
function TaskMainManager:TalkDialog()
    if #self.mTalkList ~= 0 then
        self.mTalkIndex = 1
        self:CreateAllDialog()
        self:PlayTalk(self.mTalkList[self.mTalkIndex][1],self.mTalkList[self.mTalkIndex][2])
    end
end

function TaskMainManager:ShowLastTalk()

    if #self.mTalkList == self.mTalkIndex then
        self.mArrow_l:setVisible(false)
        if self.mMainTaskInfo.mTaskIsFinish == 0 then
            self.mWidgetTalk:getChildByName("Image_StoryTask_Start"):setVisible(true)
            self.mWidgetTalk:getChildByName("Image_StoryTask_End"):setVisible(false)
        elseif self.mMainTaskInfo.mTaskIsFinish == 1 then
            self.mWidgetTalk:getChildByName("Image_StoryTask_Start"):setVisible(false)
            self.mWidgetTalk:getChildByName("Image_StoryTask_End"):setVisible(true)
        end
    end
end

function TaskMainManager:TalkNext()
    if #self.mTalkList ~= self.mTalkIndex then
        self:PlayTalk(self.mTalkList[self.mTalkIndex][1],self.mTalkList[self.mTalkIndex][2])
    else
        self.mWidgetTalk:removeFromParent()
        self.mWidgetTalk = nil
        if self.mMainTaskInfo.mTaskIsFinish == 0 then
            local packet = NetSystem.mNetManager:GetSPacket()
            packet:SetType(PacketTyper._PTYPE_CS_REQUEST_GET_NCPTALK_OVER_)
            packet:PushInt(self.mMainTaskInfo.mTaskId)
            packet:PushInt(3)
            packet:Send()
            GUISystem:showLoading()
        elseif self.mMainTaskInfo.mTaskIsFinish == 1 then
            local packet = NetSystem.mNetManager:GetSPacket()
            packet:SetType(PacketTyper.__PTYPE_CS_REQUEST_GET_TASK_REWARD_)
            packet:PushInt(self.mMainTaskInfo.mTaskId)
            packet:Send()
            GUISystem:showLoading()
            local mainTaskData = DB_TaskConfig.getDataById(self.mMainTaskInfo.mTaskId)
            if mainTaskData.AfterTask  == -1 then
                self.mTaskPanel:setVisible(false)
                self.NoTask = true
            end
        elseif self.mMainTaskInfo.mTaskIsFinish == 3 then
            
        end
    end
end

function TaskMainManager:onBtnGoTo()
    local taskInfo = self.mMainTaskInfo
    local jumpType = taskInfo.mTaskJumpType
    wndJump(jumpType,taskInfo.mTaskJumpPara)
end

function TaskMainManager:Tick(delta)
   
end

function TaskMainManager:Release()
	--
	_G["TaskMainManager"] = nil
 	package.loaded["TaskMainManager"] = nil
 	package.loaded["TaskMain/TaskMainManager"] = nil
end

return TaskMainManager.new()