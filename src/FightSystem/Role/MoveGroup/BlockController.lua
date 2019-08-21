-- Name: BlockController
-- Func: 角色格挡控制器
-- Author: tuanzhang

BlockController = class("BlockController")


function BlockController:ctor(_role, _armature)
	self.mRole = _role
	self.mArmature = _armature
	
	self.mBlockCoolingtime = 0
	self.mBlockCoolingMax = 0

	self.mFuncCall = nil
	self.ActionCount = nil
end

function BlockController:RegisterActionCallBack()
	self.mArmature:RegisterActionEnd("BlockController", handler(self, self.OnActionEvent))
	self.mArmature:RegisterActionCustomEvent("BlockController", handler(self, self.OnCustomEvent))
end

-- 开始格挡
function BlockController:StartBlock()
	self:RegisterActionCallBack()
	self.mBlockStartTime = self.mBlockCoolingMax
	if FightSystem.mFightType == "olpvp" and self.mRole.IsKeyRole then
	   	FightSystem:GetFightManager():Block_SyncPVP(self.mRole,1)
	end
	self.mArmature:ActionNow("blockStart")
	self.mRole:playVoiceSound(4)
end

-- 格挡中
function BlockController:HitBlock()
	if self.mArmature.mSpine:getCurrentAniName() == "blockEnd" then return end
	self.mArmature:ActionNow("blockHit")
	self.mRole:playVoiceSound(3)
end

-- 结束格挡
function BlockController:FinishBlock(_call)
	self.mBlockCoolingtime = self.mBlockCoolingMax
	self.mArmature:ActionNow("blockEnd")
	self.mFuncCall = _call
	if _call then
		self.ActionCount = 20
	end
end

-- 骨骼动作完成回调
function BlockController:OnActionEvent(_action)
	if _action == "blockStart" then

	elseif _action == "blockHit" then
		if self.mRole.mGroup == "friend" or self.mRole.mGroup == "enemyplayer" then
			if self.mRole.mRoleData.mInfoDB.Counterattack ~= 0 then
				self.mRole:PlaySkillByID(self.mRole.mRoleData.mInfoDB.Counterattack)
				if self.mFuncCall then
		    		self.ActionCount = nil
		    		self.mFuncCall()
		    		self.mFuncCall = nil
		    	end
			end
		end
    elseif _action == "blockEnd" then
    	if not self.mRole.mFSM:IsBlock() then return end
    	self.mRole.mFSM:ChangeToStateWithCondition("block", "idle")
    	if self.mFuncCall then
    		self.ActionCount = nil
    		self.mFuncCall()
    		self.mFuncCall = nil
    	end
	end
end

function BlockController:Tick(delta)
	self:TickCool(delta)
	self:TickActionCount()
end

function BlockController:TickCool(delta)
	if self.mBlockStartTime and not self.mRole.mFSM:IsBlock() then
		self.mBlockCoolingtime = self.mBlockCoolingMax
		self.mBlockStartTime = nil
	end

	if self.mBlockCoolingtime > 0 then
		self.mBlockStartTime = nil
		self.mBlockCoolingtime = self.mBlockCoolingtime - delta
		if self.mBlockCoolingtime < 0 then
			self.mBlockCoolingtime = 0
		end
	end
end

function BlockController:TickActionCount()
	if not self.ActionCount  then return end
	if self.ActionCount > 0 then
		self.ActionCount = self.ActionCount - 1
	else
		self.ActionCount = nil
		if self.mFuncCall then
			if self.mRole.mFSM:IsBlock() then
				self.mRole.mFSM:ChangeToStateWithCondition("block", "idle")
			end
			self.mFuncCall()
    		self.mFuncCall = nil
		end
	end
end

-- 骨骼事件回调
function BlockController:OnCustomEvent(_action, _eventName)

end
