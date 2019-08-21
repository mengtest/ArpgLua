-- Name: SkillObject
-- Func: 技能对象
-- Author: Johny

require "FightSystem/Role/SkillGroup/SkillProcess"

SkillObject = class("SkillObject")

function SkillObject:ctor(_skillID, _skillCon, _role, _tp)
	self.mType = _tp
	self.mRole = _role
	self.mSkillCon = _skillCon
	self.mDB_Base = DB_SkillEssence.getDataById(_skillID)
	--1：伤害技能  2：祝福技能
	self.mSkillType = self.mDB_Base.Type
	self.mSkillID = _skillID
	self.mName = self.mDB_Base.Name
	self.mProStack = {}
	self.mCurPro = nil
	self.mFinalVictimCount = 0
	self.mCanMove = self.mDB_Base.CanMove

	self.mHiddenShadow = self.mDB_Base.HiddenShadow

	self.mGroupSpine = nil

	-- 是否可以循环
    self.mIsProcessLoop = true
	-- init
	self:LoadProcess()
end

function SkillObject:Tick(delta)
	if self.mCurPro then
		self.mCurPro:Tick(delta)
		--self.mCurPro:HandleFirstTick()
	end
	if self.mGroupSpine then
		self.mGroupSpine:setPosition(self.mRole.mShadow:getPosition_pos())
		local _scale = self.mRole:getTiledmapScaleByPosY(self.mRole.mShadow:getPosition_pos().y)
		if self.mRole.IsFaceLeft then
			self.mGroupSpine:setScale(-_scale*self.mGroupSpineScale)
		else
			self.mGroupSpine:setScale(_scale*self.mGroupSpineScale)
		end
	end
end

function SkillObject:LoadProcess()
	for num = 1, 32 do
		local _proID = self.mDB_Base[ProcessID_Table[num]]
		--
		if _proID == 0 then
		break end
		--
		local _pro = SkillProcess.new(num, _proID, self, self.mRole)
		table.insert(self.mProStack, _pro)
	end
	--cclog("共加载： " .. #self.mProStack .. "个过程")
end

function SkillObject:PopProcess()
	if self.mCurPro then
		self.mCurPro:Finish()
	end
	self.mCurPro = table.remove(self.mProStack, 1)
end

-- 开始执行这个技能
function SkillObject:StartRun()
	self:PopProcess()
	if self.mCurPro then
		self.mCurPro:HandleFirstTick()
	end
	if self.mHiddenShadow == 1 then
	   self.mRole.mShadow:setVisibleShadow(false)
	end
end

-- 回调
function SkillObject:OnProcessFinish(_pro)
	-- 检查投掷
	if _pro.IsNoneGripPro then
		self:FinishSelfBeforeNextProcess()
		return
	end
	if self.mType == "pickup_throw" then
 	   if _pro.mProNum == 1 then
 	   	  self.mRole.mPickupCon:OnThrowPickupStart()	  
 	   end
	end
	-- 检查过程结束
	if #self.mProStack == 0 then
		if self.mHiddenShadow == 1 then
			self.mRole.mShadow:setVisibleShadow(true)
		end
		self.mSkillCon:OnFinishSkill(self)
	else
		if not self.mFinishBeforeNextPro then
			if self.mCurPro then
				if self.mCurPro.mMoveHandler then
					self.mCurPro.mMoveHandler:ArriveDis()
				end	
			end
			self:PopProcess()
		else
			self:clearProcStack()
			if self.mHiddenShadow == 1 then
				self.mRole.mShadow:setVisibleShadow(true)
			end
			self.mSkillCon:OnForcedFinishSkill(self)
		end
	end
end

-- 地面技能回调
function SkillObject:onAnimationEventGroupEffect(event)
	if event.type == 'end' then
		self:GroupEffectEnd()
	end
end


-- 查看当前地面技能
function SkillObject:GroupEffectEnd()
	if self.mCurPro then
		self.mCurPro:Finish()
	end
	if self.mGroupSpine then
		SpineDataCacheManager:collectFightSpineByAtlas(self.mGroupSpine)
		self.mGroupSpine = nil
	end
end

-- 下一个过程前结束技能
function SkillObject:FinishSelfBeforeNextProcess()
	self.mFinishBeforeNextPro = true
	self:clearProcStack()
	if self.mHiddenShadow == 1 then
		self.mRole.mShadow:setVisibleShadow(true)
	end
	self.mSkillCon:OnForcedFinishSkill(self)
end

-- 是否可以移动
function SkillObject:CanMove()
	if self.mCurPro then
		return self.mCurPro.mDB.ProcessCanMove == 1 
	end
	return self.mCanMove == 1
end

-- 清空pro列表
function SkillObject:clearProcStack()
	if self.mCurPro then
		self.mCurPro:Finish()
	end
	self.mCurPro = nil
	self.mProStack = {}
end

-- 设置当前技能取消按钮按下
function SkillObject:setCancelBtn()
	self.mIsProcessLoop = false
end