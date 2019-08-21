-- Name: 霸体状态
-- Author: Johny

BuffNoControl = class("BuffNoControl")

function BuffNoControl:ctor(_role, _buffCon, _releaser, _dbState, _dbEff)
	self.mRole = _role
	self.mBuffCon = _buffCon
	self.mReleaser = _releaser
	self.mStateDbData = _dbState
	self.mStateID = _dbState.ID
	self.mEffMethod = 202
	self.mType = "buff"
	self.mName = "nocontrol"
	self.mDuringType = _dbState.TimeType
	self.mDuring = _dbState.LastTime
	self.mEffect = {}
	self.mShaderScheduleHandler = nil  --shader定时器句柄
	if self.mStateID ~= 197 then
		--self:addNoEffect()
	end
	self:CancelFlight()
	--
	self.mRole.mNoControlCount = self.mRole.mNoControlCount + 1
	self.mBuffCon:addLightEffect(_dbState,self)
end

-- 设置霸体不能浮空应该下落
function BuffNoControl:CancelFlight()
	if self.mRole.mFSM:IsBeControlled() then
		if self.mRole.mFEM:IsBeatStFly() then
			self.mRole.mBeatCon.mKnockFlyCon:cancelKnockFlyByNoContr()
			self.mRole.mFEM:ChangeToBeatEffectBeglectBuff(6)
		end
		if self.mRole.mFEM:IsBeatStFlight() then
			self.mRole.mBeatCon.mKnockFlightCon:cancelKnockFlightHitByNoCon()
		end
	end
end

-- 添加霸体特效
function BuffNoControl:addNoEffect()
	local _resDB = DB_ResourceList.getDataById(self.mRole.mRoleData.mModel)
	local _tableList = _resDB.Res_path4
	-- local _color1 = cc.vec4(1.0, 0.64, 0.68, 1.0)
	-- local _color2 = cc.vec4(0.9, 0.38, 0.44, 1.0)
	local _color1 = cc.vec4(1.0, 1.0, 0.7, 1.0)
	local _color2 = cc.vec4(1.0, 1.0, 0.01, 1.0)
	if self.mStateID == 196 then
		_color1 = cc.vec4(1.0, 1.0, 0.7, 1.0)
		_color2 = cc.vec4(1.0, 1.0, 0.01, 1.0)
	end
	self.mShaderScheduleHandler = CommonAnimation.Spine_ColorChangeBetween2(self.mRole.mArmature.mSpine, _color1, _color2, _tableList, "BuffNoControl")
end

function BuffNoControl:Destroy()
	if self.mShaderScheduleHandler then
		cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.mShaderScheduleHandler)
		self.mShaderScheduleHandler = nil
	end
	ShaderManager:ResumeColor_spine(self.mRole.mArmature.mSpine)
	self.mRole = nil
	self.mBuffCon = nil
	self.mReleaser = nil
	self.mEffMethod = nil
	self.mType = nil
	self.mName = nil
	self.mDuring = nil
	if #self.mEffect ~= 0 then
		for i,v in ipairs(self.mEffect) do
			SpineDataCacheManager:collectFightSpineByAtlas(v.SpineEffect)
			v.SpineNode:removeFromParent()
		end
	end
	self.mEffect = nil
end

function BuffNoControl:Tick(delta)
	if #self.mEffect ~= 0 then
		for i,v in ipairs(self.mEffect) do
			if v.HangType == 0 and v.HangBone ~= "" then
				local _bonePos = self.mRole.mArmature.mSpine:getBonePosition(v.HangBone)
				v.SpineNode:setPositionY(_bonePos.y*self.mRole.mArmature.mScale)
			end
		end
	end
	if self.mDuringType == 1 then return end
	if self.mDuring > 0 then
		if not self.mRole:IsControlByStaticFrameTime() then
			self.mDuring = self.mDuring - 1
		end
	else
		self.mRole.mNoControlCount = self.mRole.mNoControlCount - 1
		self.mBuffCon:removeBuff(self)
	end
end