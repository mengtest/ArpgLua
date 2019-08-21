-- Name: FreefallController
-- Author: Johny

FreefallController = class("FreefallController")


function FreefallController:ctor(_role)
	self.mRole = _role
	self.mIsFreeFalling = false
	self.mDownGG = MathExt._g_KnockFly_DOWN
end

function FreefallController:Destroy()
	cclog("FreefallController:Destroy")
	self.mRole = nil
	self.mIsFreeFalling = nil
end

function FreefallController:Tick(delta)
	if self.mRole:IsControlByStaticFrameTime() then return end
	if self.mIsFreeFalling then
		self.mVH = MathExt.GetV1InUniformAcceleration(self.mVH, self.mDownGG, 1*FightSystem:getGameSpeedScale())
		_disY = - self.mVH*FightSystem:getGameSpeedScale()
		self.mRole:setPositionY(_disY + self.mRole:getPositionY())
		self.mRole.mShadow:ShadowChangeScale()
		if self.mRole.mShadow:IsSameHorWithRole() <= 0 then
			self.mIsFreeFalling = false
			self.mDownGG = MathExt._g_KnockFly_DOWN
			self:HandleFallDown()
		end
		
	end
	
end

function FreefallController:HandleFallDown()
	self.mRole.mShadow:ShadowRestoreScale()
	if self.mRole.mGroup == "friend" or self.mRole.mGroup == "enemyplayer" then
		if self.mTopheight then
			local height = math.floor(self.mTopheight / 100)
			if height > 0 then
				shakeFallNodeType1(FightSystem.mSceneManager:GetSceneView(self.mRole.mSceneIndex),height,height*0.035)	
			end
			self.mTopheight = nil
		end
	else
		if self.mTopheight then
			local height = math.floor(self.mTopheight / 100)
			if height > 0 then
				shakeFallNodeType1(FightSystem.mSceneManager:GetSceneView(self.mRole.mSceneIndex),height,height*0.035)	
			end
			self.mTopheight = nil
		end
	end
	self.mRole.mFEM:ChangeToBeatEffect(0)
	if self.mRole.mPropertyCon:IsHpEmpty() then
	   self.mRole.mFSM:ForceChangeToState("dead")
	   -- self.mRole:RemoveSelf()
	   -- return
	else
		self.mRole.mBeatCon.mBeatFlyCount = 0
		self.mRole.mBeatCon.mBeatTiffCount = 0
		self.mRole.mFSM:ForceChangeToState("falldown")
	end
	self.mRole:setPositionY(self.mRole.mShadow:getPositionY())
	self.mRole.mShadow:stopTickMoveY(false)
	self.mRole.mBeatCon.mFalldownCon:Start("beBlowUpEnd","beBlowUpStand",30)
	--self.mRole.mArmature:ActionNow("beBlowUpEnd")
	--voice
	self.mRole:playVoiceSound(5)
end

-- 开始自由落体
function FreefallController:Start()
	self:registerActionCustom()
	self.mRole.mBeatCon.mBeatTiffCount = 0
	self.mVH = 0
	self.mVH = MathExt.GetV1InUniformAcceleration(self.mVH, self.mDownGG, 1*FightSystem:getGameSpeedScale())
	self.mIsFreeFalling = true
	if self.mRole.mArmature.mSpine:getCurrentAniName() ~= "injured3" then
		self.mRole.mArmature:ActionNowWithSpeedScale("beBlowUping",100)
	end
	self.mTopheight = self.mRole.mShadow:GetHorHeight()
	self.mRole.mShadow:stopTickMoveY(true)
end

function FreefallController:registerActionCustom()
	local function _OnActionCustom(_action,name)
		if not self.mRole.mFEM:IsFreeFall() then return end
		if _action == "beBlowUping" and name == "freefall" then
			self.mRole.mArmature.mSpine:setTimeScale(0.001)
		end
	end
	self.mRole.mArmature:RegisterActionCustomEvent("FreefallController",_OnActionCustom)
end

function FreefallController:cancelFreeFall()
	--doError("cancelFreeFall")
	self.mIsFreeFalling = false
	self.mDownGG = MathExt._g_KnockFly_DOWN
end

function FreefallController:cancelFallDown()
	self.mDownGG = MathExt._g_KnockFly_DOWN
end
