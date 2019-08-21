-- Name: KnockFlightHitController
-- Author: Johny

KnockFlightHitController = class("KnockFlightHitController")


function KnockFlightHitController:ctor(_role)
	self.mRole = _role
	self.mDowningDuring = 0
	self.mIsFlightHit = false
	self.KeyKnockHit = string.format("KnockFlightHitController%d",self.mRole.mInstanceID)
end

function KnockFlightHitController:Destroy()
	cclog("KnockFlightHitController:Destroy")
	if self.mHiter then
		if not self.mRole then return end
		if self.mHiter.mArmature then
			self.mHiter.mArmature:UnRegisterActionCustom(self.KeyKnockHit)
		end
	end
	self.mRole = nil
	self.mIsFlightHit = nil
end

function KnockFlightHitController:Tick(delta)
	if self.mRole:IsControlByStaticFrameTime() then return end
	if self.mIsFlightHit then
		self.mDuring = self.mDuring - 1
		if self.mDuring <= -1 then
			if self.mRole.mFEM:IsBeatStFlight() then 
				self.mIsFlightHit = false
				self.mRole.mFEM:ChangeToBeatEffectBeglectBuff(6)
			end
		end
	end
end

-- 开始击飞(从地面起飞)
function KnockFlightHitController:Start(_dbSt, _dbSkillEff, _hiter, _dbProc, _from)
	-- 扔手里拾取
	if self.mRole:hasNoControlBuffNow() and self.mRole.mPropertyCon.mCurHP > 0 then
		return
	end
	self.mRole.mBeatCon.mBeatTiffCount = 0
	if self.mHiter then
		if self.mHiter.mArmature then
			self.mHiter.mArmature:UnRegisterActionCustom(self.KeyKnockHit)
		end
	end
	local _during = _dbProc.LastTime / FightSystem:getGameSpeedScale()
	self.mDuring = _during / _hiter.mPropertyCon.mAttRatePer
	self.mDuring = math.ceil(self.mDuring * _dbProc.ModifySpeed)
	self.mIsFlightHit = true
	self.mHiter = _hiter
	self._Height = _dbSkillEff.Data3
	self.mRole:setPositionY(self.mRole.mShadow:getPositionY() + self._Height)
	self.mRole.mShadow:ShadowChangeScale()
	self:registerActionCustom(self.mHiter)
	self.mRole.mShadow:stopTickMoveY(true)
	if _from == "knockflight" and self.mRole.mArmature.mSpine:getCurrentAniName() == "injured3" then
		return
	end
	self.mRole.mArmature:ActionNow("injured3",true)
end

-- 注册动作事件回调

function KnockFlightHitController:registerActionCustom(_role)
	local function _OnActionCustom(_action,name)
		if not self.mRole then return end
		if not self.mRole.mFEM:IsBeatStFlight() then return end
		if self.mHiter and self.mHiter.mSkillCon then
			if self.mHiter.mSkillCon.mCurSkill then
				if self.mHiter.mSkillCon.mCurSkill.mCurPro then
					local _str1 = "TargetStateID"
					local state = false
					for i = 1, 4 do
						local keyState = string.format("%s%d",_str1,i)
						local _stateID = self.mHiter.mSkillCon.mCurSkill.mCurPro.mDB[keyState]
						if _stateID ~= 0 then
							local _dbState = DB_SkillState.getDataById(_stateID)
							local _dbEff = DB_SkillEffect.getDataById(_dbState.EffectID1)
							local ExcuteMethod = _dbEff.ExcuteMethod
							if ExcuteMethod == 3 or ExcuteMethod == 32 then 
								self.mRole.mFEM:ChangeToBeatEffect(6)
								state = true
								break
							elseif ExcuteMethod == 31 then
								state = true
								break
							end
						else
							break
						end
					end
					if not state then
						self.mIsFlightHit = false
						self.mRole.mFEM:ChangeToBeatEffect(6)
					end
					self.mHiter.mArmature:UnRegisterActionCustom(self.KeyKnockHit)
				else
					self.mIsFlightHit = false
					self.mRole.mFEM:ChangeToBeatEffect(6)
					self.mHiter.mArmature:UnRegisterActionCustom(self.KeyKnockHit)
				end
			else
				self.mIsFlightHit = false
				self.mRole.mFEM:ChangeToBeatEffect(6)
				self.mHiter.mArmature:UnRegisterActionCustom(self.KeyKnockHit)
			end
		end
	end
	_role.mArmature:RegisterActionCustomEvent(self.KeyKnockHit,_OnActionCustom)
end

function KnockFlightHitController:cancelKnockFlightHit()

end

function KnockFlightHitController:cancelKnockFlightHitByNoCon()

	if self.mRole.mFEM:IsBeatStFlight() then
		self.mRole.mFEM:ChangeToBeatEffectBeglectBuff(6)
	end
	self.mIsFlightHit = false
	if self.mHiter then
		if not self.mRole then return end
		if self.mHiter.mArmature then
			self.mHiter.mArmature:UnRegisterActionCustom(self.KeyKnockHit)
		end
	end
end