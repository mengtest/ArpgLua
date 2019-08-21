-- Name: AICondition
-- Func: AI条件控制器
-- Author: tuanzhang

AICondition = class("AICondition")
AICondition.BrithType = 1
AICondition.BloodLessType = 12
AICondition.BloodZeroType = 13
AICondition.HpPer = 14
AICondition.SceneIdType = 2
AICondition.RoundGold = 21
AICondition.RandomType = 3
AICondition.SkillCoolDown = 4
AICondition.TimerType = 5

------------------------------------------------
--		BehaviorType
-- 	1	释放特定ID技能，参数：技能ID、目标
-- 	11	为友方生命值最低的目标释放技能，参数为：技能ID
-- 	12	为友方缺少目标释放技能，参数为：buffID
--		13	新增“13泡泡喊话”，参数为speaktext ID、延迟时间（单位：秒）、持续时间（单位：秒）
-- 	2	特定ID场景参数减1
-- 	21	特定ID场景参数加1
-- 	3	逃跑
-- 	31	自杀
-- 	32	跳跃至目标点，参数：{x,y}
--		33	跑到至目标点，参数：{x,y}
-- 	4	开启定时器，参数：定时器ID、定时时间
-- 	41	关闭定时器，参数：定时器序号
------------------------------------------------

function AICondition:ctor(index,data,AI,role)
	self.mRole = role
	self.mGroup = self.mRole.mGroup
	self.mAI = AI
	self.mIndex = index
	self.BloodLesscount = 0
	self.mRandomTime = 0
	local key = "AI_Condition" .. index
	self.AI_Condition = data[key]
	key = string.format("AI_Condition%dParam1",index)
	self.AI_ConditionParam1 = data[key]
	key = string.format("AI_Condition%dParam2",index)  
	self.AI_ConditionParam2 = data[key]
	key = string.format("AI_Condition%dParam3",index)
	self.AI_ConditionParam3 = data[key]

	key = "AI_Behavior" .. index
	self.AI_Behavior = data[key]
	key = string.format("AI_Behavior%dParam1",index)
	self.AI_BehaviorParam1 = data[key]
	key = string.format("AI_Behavior%dParam2",index)
	self.AI_BehaviorParam2 = data[key]
	key = string.format("AI_Behavior%dParam3",index)
	self.AI_BehaviorParam3 = data[key]

	if self.AI_Behavior == 101 then
		self.AI_BehaviorParam1 = self.mRole.mRoleData["mRole_SpecialSkill".. self.AI_BehaviorParam1]
	end

	self.mTimerKey = {}




	if self.AI_Condition == AICondition.BrithType then
		self.CondiFun = handler(self,self.BrithStartCondition)
	elseif self.AI_Condition == AICondition.BloodLessType then
		self.CondiFun = handler(self,self.BloodLessCondition)
	elseif self.AI_Condition == AICondition.BloodZeroType then
		self.CondiFun = handler(self,self.BloodZero)
	elseif self.AI_Condition == AICondition.HpPer then
		self.HpPerTimer = 0.5
		self.HpPerWaitTime = 0
		self.CondiFun = handler(self,self.HpPerCondition)
	elseif self.AI_Condition == AICondition.SceneIdType then
		self.CondiFun = handler(self,self.SceneIDChangeCondition)
	elseif self.AI_Condition == AICondition.RoundGold then
		self.RgoldTimer = 0.3
		self.RgoldWaitTime = 0
		self.CondiFun = handler(self,self.RgoldCondition)

	elseif self.AI_Condition == AICondition.RandomType then
		self.CondiFun = handler(self,self.RandomExecuCondition)
	elseif self.AI_Condition == AICondition.SkillCoolDown then
		self.CondiFun = handler(self,self.SkillCoolCondition)
	elseif self.AI_Condition == AICondition.TimerType then
		self.CondiFun = handler(self,self.TimebeCondition)
	end

	--cclog("AI_Condition=="..self.AI_Condition)
end

-- 
function AICondition:BrithStartCondition( ... )
	self:Execute_Behavior(self.AI_Behavior)
	self.mAI:RemoveCondition(self.mIndex)
end

function AICondition:BloodLessCondition( ... )
	self:BloodLess(self.AI_ConditionParam1)
end

function AICondition:RgoldCondition( delta )
	if self.RgoldWaitTime > 0 then self.RgoldWaitTime = self.RgoldWaitTime - delta return end
	if self.RgoldTimer > 0 then self.RgoldTimer = self.RgoldTimer - delta return end
	self.RgoldTimer = 0.3
	local rolelist = nil
	if self.mRole.mGroup == "friend" then
		rolelist = FightSystem.mRoleManager:GetEnemyTable(self.mRole.mSceneIndex)
	elseif self.mRole.mGroup =="enemyplayer" or self.mRole.mGroup == "monster" then
		rolelist = FightSystem.mRoleManager:GetFriendTable(self.mRole.mSceneIndex)
	end
	local monpos = self.mRole:getShadowPos()
	local count = 0
	for k,v in pairs(rolelist) do
		local goalpos = v:getPosition_pos()
		local leng1 = (goalpos.x - monpos.x)*(goalpos.x - monpos.x) + (goalpos.y - monpos.y)*(goalpos.y - monpos.y)
		local len = self.AI_ConditionParam2
		if len*len >= leng1 then
			count = count + 1
			if count >= self.AI_ConditionParam1 then
				local count = self.AI_ConditionParam3[2] - self.AI_ConditionParam3[1]
				local ran = math.random(1,100)
				self.RgoldWaitTime = self.AI_ConditionParam3[1] + ran*0.01*count
				self:Execute_Behavior(self.AI_Behavior)
				break
			end
		end
	end
end

function AICondition:HpPerCondition( delta )
	if self.HpPerWaitTime > 0 then self.HpPerWaitTime = self.HpPerWaitTime - delta return end
	if self.HpPerTimer > 0 then self.HpPerTimer = self.HpPerTimer - delta return end
	self.HpPerTimer = 0.5
	local rolelist = nil
	if self.mRole.mGroup == "friend" then
		rolelist = FightSystem.mRoleManager:GetFriendTable(self.mRole.mSceneIndex)
	elseif self.mRole.mGroup =="enemyplayer" or self.mRole.mGroup == "monster" then
		rolelist = FightSystem.mRoleManager:GetEnemyTable(self.mRole.mSceneIndex)
	end
	for k,v in pairs(rolelist) do
		if v:BloodPercentValue() <= self.AI_ConditionParam1 then
			local count = self.AI_ConditionParam2[2] - self.AI_ConditionParam2[1]
			local ran = math.random(1,100)
			self.HpPerWaitTime = self.AI_ConditionParam2[1] + ran*0.01*count
			self:Execute_Behavior(self.AI_Behavior)
			break
		end
	end
end

function AICondition:SceneIDChangeCondition( ... )
	self:SceneIDChange(self.AI_ConditionParam1)
end

function AICondition:RandomExecuCondition( delta )
	self:RandomExecution(delta)
end

function AICondition:SkillCoolCondition( ... )
	self:SkillCool(self.AI_ConditionParam1)
end

function AICondition:TimebeCondition( ... )
	self:Timebe(self.AI_ConditionParam1)
end

function AICondition:Tick(delta)
	self.CondiFun(delta)
end

function AICondition:Execute_Behavior(_type)
	if _type == 1 then
		if self.mAI.IsNoExecuteSkill then return end
		self.AI_BehaviorParam1 = self.mRole.mRoleData:ChangeNewWeapSkillById(self.AI_BehaviorParam1)
		if self.AI_BehaviorParam1 ~= 0 and self.mRole.mRoleData:IsSkillActivateById(self.AI_BehaviorParam1) then
			self.mAI:AddSkillCool(self,self.AI_BehaviorParam1)
		end
	elseif  _type == 11 then
		
	elseif  _type == 12 then

	elseif  _type == 13 then
		self.mAI:Behavior_Speak(self.AI_BehaviorParam1,self.AI_BehaviorParam2,self.AI_BehaviorParam3)

	elseif  _type == 101 then
		if self.mAI.IsNoExecuteSkill then return end
		self.AI_BehaviorParam1 = self.mRole.mRoleData:ChangeNewWeapSkillById(self.AI_BehaviorParam1)
		if self.AI_BehaviorParam1 ~= 0 and self.mRole.mRoleData:IsSkillActivateById(self.AI_BehaviorParam1) then
			self.mAI:AddSkillCool(self,self.AI_BehaviorParam1)
		end
	elseif  _type == 2 then
		self:BehaviorSceneIdChange(self.AI_BehaviorParam1)
	elseif  _type == 21 then
	
	elseif  _type == 3 then
	
	elseif  _type == 31 then
		self:Suicide()
	elseif  _type == 32 then
		self.mAI:Behavior_Jumpgoal(self.AI_BehaviorParam1)
	elseif  _type == 33 then
		self.mAI:Behavior_Walkgoal(self.AI_BehaviorParam1)
	elseif  _type == 4  then
		self.mAI:OpenTimer(self.AI_BehaviorParam1,self.AI_BehaviorParam2,self.AI_BehaviorParam3)
	elseif  _type == 41 then
		self.mAI:CloseTimer(self.AI_BehaviorParam1)
	elseif  _type == 5  then
		self.mAI:Summon(self.AI_BehaviorParam1,self.AI_BehaviorParam2)
	elseif _type == 6 then
		self.mAI:ConditionAddBuff(self.AI_BehaviorParam1)
	end

end

function AICondition:Suicide()
	self.mRole.mFSM:ForceChangeToState("dead")
    self.mRole:RemoveSelf()
end

function AICondition:BehaviorSceneIdChange(_Param)
	local id = _Param[1]
	local tiaojian = _Param[2] --1 增加；2 减少；3 重置对应值
	local value = _Param[3] --对应值
	local data = FightSystem.mAISceneIDlist[id]
	local AItiaojianID = self.mAI.mSceneListID[id]
	if not data then FightSystem.mAISceneIDlist[id] = 0 end
	if tiaojian == 1 then
		FightSystem.mAISceneIDlist[id] = FightSystem.mAISceneIDlist[id] + value
		FightSystem.mRoleManager:setAllRoleSceneListId(id)
	elseif tiaojian == 2 then
		FightSystem.mAISceneIDlist[id] = FightSystem.mAISceneIDlist[id] - value
		FightSystem.mRoleManager:setAllRoleSceneListId(id)
	elseif tiaojian == 3 then
		FightSystem.mAISceneIDlist[id] =  value
		FightSystem.mRoleManager:setAllRoleSceneListId(id)
	end	
end


--生命小于百分比
function AICondition:BloodLess(bloodvalue)
	if self.mRole:BloodPercentValue() <= bloodvalue then
		if self.BloodLesscount == 0 then
			if self.mRole.mFSM:IsIdle() or self.mRole.mFSM:IsRuning() or self.mRole.mFSM:IsAttacking() then 
				self.BloodLesscount = 1
				self:Execute_Behavior(self.AI_Behavior)
			end
		end
	else
		if self.BloodLesscount == 1 then
			self.BloodLesscount = 0
		end
	end
end

--场景ID条件
function AICondition:SceneIDChange(_Param)
	local id = _Param[1]
	local tiaojian = _Param[2] --判定条件：1 大于；2 小于；3 等于
	local value = _Param[3] --判定值
	local data = FightSystem.mAISceneIDlist[id]
	local AItiaojianID = self.mAI.mSceneListID[id]
	if not self.mAI.mSceneListID[id] then
		self.mAI.mSceneListID[id] = {}
	end
	if not data then return end
	if self.mAI.mSceneListID[id][self.mIndex] then return end
	if tiaojian == 1 then
		if data > value then
			local Data = {self.mIndex,0}
			self.mAI.mSceneListID[id][self.mIndex] = 0
			self:Execute_Behavior(self.AI_Behavior)
		end
	elseif tiaojian == 2 then
		if data < value then
			self.mAI.mSceneListID[id][self.mIndex] = 0
			self:Execute_Behavior(self.AI_Behavior)	
		end
	elseif tiaojian == 3 then
		if data == value then
			self.mAI.mSceneListID[id][self.mIndex] = 0
			self:Execute_Behavior(self.AI_Behavior)
		end
	end	
end

-- 随机执行
function AICondition:RandomExecution(delta)
	if self.mRandomTime == 0 then
		local count = self.AI_ConditionParam2[2] - self.AI_ConditionParam2[1]
		local ran = math.random(1,100)
		self.mRandomTime = self.AI_ConditionParam2[1] + ran*0.01*count
		local num = self.AI_ConditionParam1*100
		local randomnum = math.random(1,100)
		if randomnum <= num then
			self:Execute_Behavior(self.AI_Behavior)
		end
	else
		self.mRandomTime = self.mRandomTime - delta
		if self.mRandomTime <= 0 then
			local count = self.AI_ConditionParam2[2] - self.AI_ConditionParam2[1]
			local ran = math.random(1,100)
			self.mRandomTime = self.AI_ConditionParam2[1] + ran*0.01*count
			local num = self.AI_ConditionParam1*100
			local randomnum = math.random(1,100)
			if randomnum <= num then
				self:Execute_Behavior(self.AI_Behavior)
			end
		end
	end
end

--死亡血为零
function AICondition:BloodZero()
	if self.mRole:BloodPercentValue() == 0 then
		self:Execute_Behavior(self.AI_Behavior)
		self.mAI:RemoveCondition(self.mIndex)
	end
end

--技能是否冷却
function AICondition:SkillCool(param)
	param = self.mRole.mRoleData:ChangeNewWeapSkillById(param)
	if param ~= 0 and self.mRole.mRoleData:IsSkillActivateById(param) then
		--self.mAI:AddSkillCool(self,param)
		self:Execute_Behavior(self.AI_Behavior)
	end
end

--条件时间
function AICondition:Timebe(param)
	if self.mTimerKey[param] then return end
	for k,v in pairs(self.mAI.TimerIdList) do
		if v == param then
			self:Execute_Behavior(self.AI_Behavior)
			self.mTimerKey[param] = param
			--table.remove(self.mAI.TimerIdList,k)
		end
	end
end




