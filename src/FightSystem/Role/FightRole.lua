-- Name: FightRole
-- Func: 战斗角色, 战斗中出现的角色
-- Author: Johny

require "FightSystem/Role/FightArmature"
require "FightSystem/Role/FightHorse"
require "FightSystem/Role/SpineGhost"
require "FightSystem/Role/SpineShadow"
require "FightSystem/Role/RoleStateMachine/FSM"
require "FightSystem/Role/RoleStateMachine/FEM"
require "FightSystem/Role/PropertyGroup/PropertyController"
require "FightSystem/Role/MoveGroup/MoveController"
require "FightSystem/Role/SkillGroup/SkillController"
require "FightSystem/Role/BeatGroup/BeatController"
require "FightSystem/Role/AIGroup/AIController"
require "FightSystem/Role/FlowLabelGroup/FlowLabelController"
require "FightSystem/Role/SkillGroup/EffectController"
require "FightSystem/Role/SkillGroup/PickupController"
require "FightSystem/Role/SkillGroup/GunController"
require "FightSystem/Role/BeatGroup/BePickupedController"
require "FightSystem/Role/BuffGroup/BuffController"
require "FightSystem/Role/SkillGroup/SummonController"

FightRole = class("FightRole")

function FightRole:ctor(_roledata ,_sceneindex)
	--cclog("FightRole:ctor1===" .. _roledata.mGroup .. "=====" .. _roledata.mInstanceID)
	-- statement
	self.mIsLiving = true  -- 用于标识该对象是否活着
	self.mInstanceID = _roledata.mInstanceID
	if _roledata.mName == 0 then
		self.mName = ""
	else
		self.mName = getDictionaryText(_roledata.mName)  
	end
	self.mRoleData = _roledata
	self.mGroup = _roledata.mGroup
	if self.mGroup == "friend" or self.mGroup == "cgfriend" then
		self.mHeroId = self.mRoleData.mInfoDB.ID
	end
	self.mIsEnableRender = true
	self.mPosIndex = _roledata.mPosIndex
	self.IsKeyRole = false
	self.mCityHall_IsMyRole = false
	self.mJump = _roledata.mJump
	self.mSize = cc.size(100, 170)
	self.mJumpHeight = 0
	self.mHorseID = -1
	-- sound
	self.mSoundList = self.mRoleData.mSoundList
	-- 人在那个场景中
	self.mSceneIndex = 0
	if _sceneindex then
		self.mSceneIndex = _sceneindex
	end
	self.mCGId = 0
	-- 静止帧无锁定标示
	self.mStaticFrameTime_Unlock = false
	self.mStaticFrameDuring = 0
	
	self.mIsCGKeyRole = false
	--
	if self.mGroup == "hallrole" then
		self:InitHallRole(_roledata)
	else
		self:Init(_roledata)
	end
	-- 无敌BUFF
	self.Invincible = false
	-- 束缚计数
	self.mBoundCount = 0
	-- 霸体计数
	self.mNoControlCount = 0
	self.mStopMoveFun = nil
	-- 添加
	cclog("FightRole:ctor2")
end

-- 设置spine的渲染类型
function FightRole:setSpineRenderType(type)
	self.mArmature.mSpine:setSkeletonRenderType(type)
end

function FightRole:setInvincible(ible)
	if self.mGroup == "monster" and self.mRoleData.mInfoDB.Monster_Type == 2 then
		if not ible then return end
	end
	self.Invincible = ible
end

-- 声音
-- 1. 硬直1
-- 2. 硬直2
-- 3. 格挡受击
-- 4. 格挡开始
-- 5. 击飞倒地
-- 6. 死亡
function FightRole:playVoiceSound(_voiceNum)
	local _soundID = self.mSoundList[_voiceNum]
	if _soundID <= 0 then return end
	CommonAnimation.PlayEffectId(_soundID)
end



-- 初始化城镇角色
function FightRole:InitHallRole(_roledata)
	self:Init(_roledata)
end

-- 初始化战斗角色
function FightRole:Init(_roledata)
	local function initStateMachine()
		-- 初始化状态机
		self.mFSM = FSM.new(self)
		self.mFSM:RegisterFunc_State_Change(handler(self,self.OnFSMEvent))

		-- 初始化效果机
		self.mFEM = FEM.new(self)
	end
	--
	local function initArmature()
		local _resID = self.mRoleData.mModel
		local _modelScale = self.mRoleData.mModelScale
		if self.mGroup == "hallrole" then
		   if self.mRoleData.mSimpleModel > 0 then
		   	  _resID = self.mRoleData.mSimpleModel
		   	  _modelScale = self.mRoleData.mSimpleModelScale
		   end
		end
		if self.mGroup == "cgfriend" or self.mGroup == "cgmonster" then
			local temp =  DB_ResourceList.getDataById(_resID)
			if not FightSystem:GetFightManager():FindPreloadjson(temp.Res_path2) then
				_resID = self.mRoleData.mSimpleModel
				_modelScale = self.mRoleData.mSimpleModelScale
			end
		end
		local _resDB = DB_ResourceList.getDataById(_resID)
		local dress = nil
		if self.mGroup == "friend" then

			dress = globaldata:getHeroInfoByBattleIndex(self.mHeroId, "dress")
			if FightSystem:isInCityHall() then
				--dress = globaldata:getHeroInfoByBattleIndex(self.mPosIndex, "dress")
			else
				--local guid = globaldata:getBattleFormationInfoByIndexAndKey(self.mPosIndex, "id")
				--dress = globaldata:getHeroInfoByBattleGuid(guid, "dress")
			end	
		end
		if self.mGroup == "cgfriend" then
			dress = globaldata:getHeroInfoByBattleIndex(self.mHeroId, "dress")
		end
		
		if dress then
			local _atlas = _resDB.Res_path1
			local _atlas1 = string.format("%d.",dress.FashionDressIndex)
			_atlas = string.gsub(_atlas,"%.",_atlas1)
			self.mArmature = FightArmature.new(_resDB.Res_path2, _atlas, _modelScale, self)
		else
			self.mArmature = FightArmature.new(_resDB.Res_path2, _resDB.Res_path1, _modelScale, self)
		end

		self.mArmature:setPosition_ArmatureX(_roledata.mBornPos.x)
		self.mArmature:setPosition_ArmatureY(_roledata.mBornPos.y)
	    -- 初始化影子
	    self.mShadow = SpineShadow.new(self.mArmature, _roledata.mBornPos)
	    --[[
	    if not self.mShadow.mIsHideShadow then
		    self.mSpineShadow = SpineShadowSprite.new()
		    self.mSpineShadow:initWithRole(self)
		    self.mSpineShadow:setPosition(_roledata.mBornPos)
	    end
	    ]]
	   	if self.mGroup ~= "hallrole" then
	   		if not self.mShadow.mIsHideShadow then
	   			if not globaldata.gameperformance then
					self.mSpineShadow = SpineShadowSprite.new()
					self.mSpineShadow:initWithRole(self)
					self.mSpineShadow:setPosition(_roledata.mBornPos)
	   			end
	   		end
	    end
	    -- 初始化
	end
	--
	local function initController()
		self.mMoveCon = MoveController.new(self, self.mArmature)
		self.mPropertyCon = PropertyController.new(self, _roledata)
		self.mBeatCon = BeatController.new(self)
		self.mBeatCon:RegisterBeatStCallBack()
		self.mEffectCon = EffectController.new(self)
		self.mPickupCon = PickupController.new(self)
		self.mBePickupedCon = BePickupedController.new(self)
		self.mFlowLabelCon = FlowLabelController.new(self)
		self.mBuffCon = BuffController.new(self)
		self.mSkillCon = SkillController.new(self)
		self.mSummonCon = SummonController.new(self)
		self.mGunCon = GunController.new(self)
	end
	--
	local function initAI()
		if self.mGroup ~= "cgfriend" and self.mGroup ~= "cgmonster" then
			self.mAI = AIController.new(self)
			if self.mGroup ~= "hallrole" then
				if self.mGroup == "monster" and self.mRoleData.mInfoDB.Monster_Activate ~= 0 then
					self.mAI:setActivateAI(self.mRoleData.mInfoDB.Monster_Activate)
				else
					self.mAI:setOpenAI(true)
					if self.mGroup == "friend" or self.mGroup == "summonfriend" then
						if FightSystem.mRoleManager.mIsFriendfollow then
							self.mAI:setAIFollow(true)
						end
					end
				end
			end
		end	
	end
	--
	initStateMachine()
	initArmature()
	initController()
	initAI()
	self:InitShadow()
	--
	
	----------------------拾取相关参数-------------------
	-- self.mBindType_str = "role"
	-- self.mBindType = 2
	-- self.mBindNormalAttack = self.mBePickupedCon.mDB_pickup.Animation_BindNormalAttack
	-- self.mBindThrowAttack = self.mBePickupedCon.mDB_pickup.Animation_BindThrowAttack
	-------------------------------------------------------
	-- 面朝左
	self.IsFaceLeft = false
	self.mHarm = self.mPropertyCon.mHarm
	self.mRoleMaxHp = self.mPropertyCon.mMaxHP
	if self.mGroup == "monster" then
    	if self.mRoleData.mInfoDB.Monster_Direction == 1 then
    		self:FaceLeft()
    	end
    end

	--初始化状态
	self.mFSM:ChangeToState("idle") 
	-- 如果数怪物先播出生


	self.mHasDestroyed = false
end

-- 是否BUff中存在束缚
function FightRole:hasBoundBuffNow()
	return self.mBoundCount > 0
end

-- 是否BUff中存在霸体
function FightRole:hasNoControlBuffNow()
	return self.mNoControlCount > 0
end

function FightRole:Destroy()
	if self.mHasDestroyed then return end
	self.mHasDestroyed = true
	self.mStopMoveFun = nil
	self.mBoundCount = nil
	self.mNoControlCount = nil
	self.mIsLiving = nil
	self.mBuffCon:Destroy()
	self.mBuffCon = nil
	self.mBeatCon:Destroy()
	self.mBeatCon = nil
	self.mMoveCon:Destroy()
	self.mMoveCon = nil
	self.mSkillCon:Destroy()
	self.mSkillCon = nil
	self.mPickupCon:Destroy()
	self.mPickupCon = nil
	if self.mGunCon then
		self.mGunCon:Destroy()
		self.mGunCon = nil
	end
	self.mEffectCon:Destroy()
	self.mEffectCon = nil
	if self.mSummonCon then
		self.mSummonCon:Destroy()
		self.mSummonCon = nil
	end
	if self.mAI then
		self.mAI:Destroy()
		self.mAI = nil
	end
	
	self.mPropertyCon:Destroy()
	self.mPropertyCon = nil
	self.mFlowLabelCon:Destroy()
	self.mFlowLabelCon = nil
	self.mArmature:Destroy()
	self.mArmature = nil
	if self.mHorse then
	   self.mHorse:Destroy()
	   self.mHorse = nil
	end
	self.mShadow:Destroy()
	self.mShadow = nil
	if self.mSpineShadow then
		self.mSpineShadow:destroy()
		self.mSpineShadow = nil		
	end
	self.mRoleData = nil
	self.mHallrelax = nil
end

function FightRole:ShowTimeBorn()
	if self.mGroup == "monster" then
		if self.mAI then
			self:setInvincible(true)
			self.IsShowTimeBorn = true
			self.mAI.mActionOpen = false
			self.mArmature:ActionNow("born")
		end
	end
end

function FightRole:InitHallRelax(_relax)
	local function ActionCallback(_action)
		if _action == self.mHallrelax and self.mFSM:IsIdle() then
			self.mArmature:ActionNow("stand",true)
		end
	end
	self.mHallrelax = _relax
	self.mHallTimerelax = 0
	self.mWaitrelaxTime = math.random(10,15)
	self.mArmature:RegisterActionEnd("FightRolerelax",ActionCallback)
end

function FightRole:Tick(delta)
	if self.mHasDestroyed then return end
	local function base()
		-- debug输出此人状态
		self:debugShowStatusAndPos()
		self:TickHallRoleIdleTime(delta)
		self.mShadow:Tick()
		if self.mHorse then
		   self.mHorse:Tick()
		end
		self.mMoveCon:Tick(delta)
	end
	local function fight()
		--
		self.mPropertyCon:Tick()
		self.mArmature:Tick(delta)
		self:TickJumpHeight()
		self.mBeatCon:Tick(delta)
		self.mBuffCon:Tick(delta)
		if self.mSummonCon then
			self.mSummonCon:Tick(delta)
		end
		--检查静止帧时间
		if self:IsControlByStaticFrameTime() then
		   self.mStaticFrameDuring = self.mStaticFrameDuring - 1
		   if self.mStaticFrameDuring == 0 then
		   	  self:finishStaticFrame()
		   else
		   	  return
		   end
		   --cclog("静止帧中，停止Tick==========" .. self.mGroup .. "=====" .. self.mInstanceID)
		end
		if self.misNextdoStaticFrame then
			self.misNextdoStaticFrame = self.misNextdoStaticFrame - 1
			if self.misNextdoStaticFrame == 0 then
				self.misNextdoStaticFrame = nil
				self:enableStaticFrame(self.mTempStaticFrameDuring)
			end
		end
		--
		self.mSkillCon:Tick(delta)
		self.mEffectCon:Tick()
		self.mPickupCon:Tick()
		self.mBePickupedCon:Tick()
		self.mFlowLabelCon:Tick()
		----
		if self.mAI then self.mAI:Tick(delta) end

	end
	-- 根据类型走不同tick
	if self.mGroup == "hallrole" then
	   base()
	else
	   base()
	   fight()
	end
end

-- 大厅人物检测休闲动作
function FightRole:TickHallRoleIdleTime(delta)
	if self.mHallrelax then
		if self.mFSM:IsIdle() then
			if self.mHallTimerelax then
				self.mHallTimerelax = self.mHallTimerelax + delta
				if self.mHallTimerelax >= self.mWaitrelaxTime then
					self.mWaitrelaxTime = math.random(10,15)
					self.mHallTimerelax = 0
					self.mArmature:ActionNow(self.mHallrelax,false)
				end
			end
		end
	end
end

function FightRole:ResetHallrelaxTime()
	if self.mHallTimerelax then
		self.mHallTimerelax = 0
	end
end

function FightRole:RegisterFuncStopMove(_func)
	self.mStopMoveFun = nil
	self.mStopMoveFun = _func
end

-- 人物放技能时回调
function FightRole:ForBlockBySkill(_skillID)
	if self.mGroup == "friend" then
		local enemyroles = FightSystem.mRoleManager:GetEnemyTable()
		for k,v in pairs(enemyroles) do
			if v.mGroup ~= "cgmonster" then
				if v.mAI:isOpenAI() then
					v.mAI:BlockBySkill(self,_skillID)
				end
			end
		end	
	elseif self.mGroup == "monster" or self.mGroup == "enemyplayer" then
		local enemyroles = FightSystem.mRoleManager:GetFriendTable()
		for k,v in pairs(enemyroles) do
			if v.mGroup ~= "cgfriend" then
				if v.mAI:isOpenAI() then
					v.mAI:BlockBySkill(self,_skillID)
				end
			end
		end
	end
end

-- 实时检测离地高度
function FightRole:TickJumpHeight()
	local _shadowY = self.mShadow:getPositionY()
	local _roleY = self:getPositionY()
	local _height = _roleY - _shadowY
	self.mJumpHeight = _height
	self.mAttackJump = nil
end

-- 影子和人物的高度差
function FightRole:GetShadowandRoleHeight()
	local _shadowY = self.mShadow:getPositionY()
	local _roleY = self:getPositionY()
	return _roleY - _shadowY
end

-- 更换时装
function FightRole:changeFashion(tabledata)
	if tabledata[1] then
		local HorseKey = string.format("FashionHorseID%d",tabledata[1][2]) 
		local HorseID = DB_FashionEquip.getDataById(tabledata[1][1])[HorseKey]
		self:changeHorse(HorseID)
		return true
	elseif tabledata[2] then
		local HorseKey = string.format("FashionHorseID%d",tabledata[2][2]) 
		local HorseID = DB_FashionEquip.getDataById(tabledata[2][1])[HorseKey]
		self.mGunCon:ShowRoleEquipedByGunId(HorseID)
		return true
	end
	return false
end

-- 更换时装通过horseID
function FightRole:changeFashionById(horseID,horseID2)
	if horseID then
		self:changeHorse(horseID)
		return true
	elseif horseID2 then
		self.mGunCon:ShowRoleEquipedByGunId(horseID2)
		return true
	end
	return false
end

-- 更换坐骑
function FightRole:changeHorse(_horseID)
	if not _horseID then return false end
	if _horseID <= 0 then return false end
	self.mHorseID = _horseID
	local function xxx()
		local x = self:getPositionX()
		local y = self:getPositionY()
		self.mHorse = FightHorse.new(self, self.mHorseID)
		self.mHorse:hangRole()
		self.mHorse:setPositionHorse_X(x)
		self.mHorse:setPositionHorse_Y(y)
		self:InitShadow()
	end
	xxx()
	return true
end

-- 拷贝属性
function FightRole:copyProperty(property)
	self.mPropertyCon:copyProperty(property)
end

-- 开启队长
function FightRole:setKeyRole(_flag,Ai)
	if self.mGroup == "summonfriend" or self.mGroup == "summonmonster" then return end
	self.IsKeyRole = _flag
	if _flag then
		self.mArmature:changeCornerByindex(1)
		if self.mShadow.mHeropositionhelo then
			self.mShadow.mHeropositionhelo:setVisible(true)
		end
	else
		if self.mShadow.mHeropositionhelo then
			self.mShadow.mHeropositionhelo:setVisible(false)
		end
		self.mArmature:changeCornerByindex(2)
	end
end

-- 设置玩家跳跃
function FightRole:setJumpto(posnext)
	local _ac = cc.JumpTo:create(1, posnext, 100, 1)
	local _callback = cc.CallFunc:create(handler(self,self.FinishJump))
	self.mArmature:runAction(cc.Sequence:create(_ac, _callback))
	self.mShadow:MoveTo(1, posnext)
end

function FightRole:FinishJump()
	self.mAI:setOpenAI(true)
end

-- debug 输出
function FightRole:debugShowStatusAndPos()
	if not FightConfig.__DEBUG_ROLE_STATUS then return end
	local Invincible = "NO"
	if self.Invincible then
		Invincible = "YES"
	end
	local AICurState = "NO"
	local AIID = 0
	if self.mAI then
		AICurState = self.mAI.mAICurState
		AIID = self.mAI.mAI_ID
	end
	
	self.mArmature.mAllian:setString(string.format("%s,%s,%s,pos(%.1f,%.1f),%s,[AI=%s=],[AI_ID=%d=],[HP=%d=]", self.mFSM:GetCurState(), self.mArmature:getCurAction(),self.mFEM.mCurBeatEffect, self:getPositionX(), self:getPositionY(),Invincible,AICurState,AIID,self.mPropertyCon.mCurHP))
	--self.mArmature.mAllian:setString(string.format("%s,%s", self.mFSM:GetCurState(), self.mArmature:getCurAction()))
	-- self.mArmature.mAllian:setVisible(true)
	if self.mGroup ~= "friend" then
		self.mArmature.mAllian:setVisible(true)
	else
		self.mArmature.mAllian:setVisible(false)
	end
	
end

function FightRole:debugShowHiterInfo(_hiter, _params)
	if not FightConfig.__DEBUG_ROLE_STATUS then return end
	if _hiter.mGroup == "sceneani" then return end
	if not _params then return end
	local _procid = _params["procid"] or "none"
	--self.mArmature.mName:setString(string.format("hiter: %s, procid: %s", _hiter.mName, _procid))
end

-- 设置玩家title
function FightRole:setTitle(_name, _allian, _titleId)
	self.mArmature:setCityTitle(_name, _allian,_titleId)
	if FightConfig.__DEBUG_ROLE_STATUS then
		self.mArmature.mName:setString(_name)
		self.mArmature.mAllian:setString(_allian)
	end
	local function updateSpineBox()
        if not self.mArmature then return end
        if not self.mArmature.mSpine then return end
        local height = self.mArmature.mSpine:getBoundingBox().height + 20
       -- self.mArmature.mName:setPositionY(height)
        if FightConfig.__DEBUG_ROLE_STATUS then
        	self.mArmature.mAllian:setPositionY(height-20)
        end
    end
    --nextTick(updateSpineBox)
end


function FightRole:AddToRoot(_root)
	if _root.mTiledMapMiny and _root.mTiledMapMaxy then
		self.mTiledMapMiny = _root.mTiledMapMiny
		self.mTiledMapMaxy = _root.mTiledMapMaxy
		self.mTiledScaleY = 0.1 / math.floor(self.mTiledMapMaxy - self.mTiledMapMiny)
	end
	if self.mHorse then
		_root:addChild(self.mHorse)
	else
		_root:addChild(self.mArmature)	   
	end
	self.mArmature:Addroot(_root)
	self.mShadow:AddToRoot(_root)
	_root:addChild(self.mShadow)
	if self.mSpineShadow then
		_root:addChild(self.mSpineShadow)
	end
end

function FightRole:getTiledmapScaleByPosY(_y)
	if self.mTiledScaleY then
		return (self.mTiledMapMiny - _y)*self.mTiledScaleY + 1
	end
	return 1
end

function FightRole:hide()
   self.mArmature:setVisible(false)
   if self.mHorse then
   	  self.mHorse:setVisible(false)
   end
   self.mShadow:setVisibleShadow(false)
   self.mSkillCon:HideHaloEffect()
end

function FightRole:show()
   self.mArmature:setVisible(true)
   if self.mHorse then
   	  self.mHorse:setVisible(true)
   end
   self.mShadow:setVisibleShadow(true)
   self.mSkillCon:ShowHaloEffect()

end

----------------影子位置相关---------------------------------
function FightRole:getShadowPos()
	return cc.p(self.mShadow:getPositionX(), self.mShadow:getPositionY())
end

function FightRole:setShadowPosX(_x)
	self.mShadow:setPositionXWithCheckReachable(_x)
end

function FightRole:setShadowPosY(_y)
	self.mShadow:setPositionYAndZorder(_y)
end

-- 同步影子位置与人一致
function FightRole:syncShadowPosWithRolePos()
	self:setShadowPosX(self:getPositionX())
	self:setShadowPosY(self:getPositionY())
	self.mShadow:setSpineShadowPosX(self:getPositionX())
	self.mShadow:setSpineShadowPosY(self:getPositionY())
end

-- 设置影子和身体位置
function FightRole:ForcesetPosandShadow(_pos)
	self:forceSetPositionX(_pos.x)
	self:forceSetPositionY(_pos.y)
	self:setShadowPosX(_pos.x)
	self:setShadowPosY(_pos.y)
end


-------------------------------------------------------------------

--------------------------人物位置相关-----------------------------------------------
function FightRole:getPosition_pos()
	if self.mHorse then
	   return cc.p(self.mHorse:getPosition())
	else
       return cc.p(self.mArmature:getPosition())
	end
end

function FightRole:getPositionX()
	if self.mHorse then
	   return self.mHorse:getPositionX()
	else
		return self.mArmature:getPositionX()
	end
end

function FightRole:getPositionY()
	if self.mHorse then
	    return self.mHorse:getPositionY()
	else
		return self.mArmature:getPositionY()
	end
end

function FightRole:setPositionX(_posX,flag)
	if not flag then
		if not TiledMoveHandler.CanPosStand(cc.p(_posX, self:getPositionY()),self.mSceneIndex) then return end
	end
	if self.mHorse then
	    self.mHorse:setPositionHorse_X(_posX)
	else
		self.mArmature:setPosition_ArmatureX(_posX)
	end
	self.mShadow:setFightRolePositionX(_posX)
	-- 通知
	if self.mGroup == "hallrole" and self.mCityHall_IsMyRole then
	   FightSystem:PushNotification("hall_myrolemove", self:getPosition_pos())
	else
	   FightSystem:PushNotification("anyrolemoved", self)
	end
end

function FightRole:setPositionY(_posY)
	if self.mHorse then
	    self.mHorse:setPositionHorse_Y(_posY)
	else
		self.mArmature:setPosition_ArmatureY(_posY)
	end
	self.mShadow:setFightRolePositionY(_posY)
	-- 通知
	if self.mGroup == "hallrole" and self.mCityHall_IsMyRole then
	   FightSystem:PushNotification("hall_myrolemove", self:getPosition_pos())
	else
	   FightSystem:PushNotification("anyrolemoved", self)
	end
end

-- 强迫设置坐标,无需检测是否可达
function FightRole:forceSetPositionX(_x)
	self.mArmature:setPosition_ArmatureX(_x)
end
function FightRole:forceSetPositionY(_y)
	self.mArmature:setPosition_ArmatureY(_y)
end

function FightRole:setLocalZOrder(_zorder)
	if self.mHorse then
	    self.mHorse:setLocalZOrder(_zorder)
	else
		self.mArmature:setLocalZOrder_Armature(_zorder)
	end
end

function FightRole:getLocalZOrder()
	if self.mHorse then
	   return self.mHorse:getLocalZOrder()
	else
	   return self.mArmature:getLocalZOrder()
	end
end

function FightRole:addToTiledLayer()
	FightSystem.mSceneManager:GetTiledLayer():addChild(self.mArmature)
end

-- 血量百分比
function FightRole:BloodPercentValue()
	return self.mPropertyCon.mCurHP / self.mPropertyCon.mMaxHP
end

-- 面向左边
function FightRole:FaceLeft()
	self.IsFaceLeft = true
	if self.mHorse then
	   self.mHorse:faceLeft()
	else
	   self.mArmature:setScaleX(-1)
	end
	self.mArmature:setTitleFlip(-1)
	self.mBuffCon:setTitleFlip(-1)
	self.mShadow:setScaleX(-1)
	if self.mSpineShadow then
		self.mSpineShadow:directionSetting()
		self.mSpineShadow:setScaleX(-1)
	end
	self.mSkillCon:setFlip(-1)
end

-- 面向右边
function FightRole:FaceRight()
	self.IsFaceLeft = false
	if self.mHorse then
	   self.mHorse:faceRight()
	else
	   self.mArmature:setScaleX(1)
	end
	self.mArmature:setTitleFlip(1)
	self.mBuffCon:setTitleFlip(1)
	self.mShadow:setScaleX(1)
	if self.mSpineShadow then
		self.mSpineShadow:directionSetting()
		self.mSpineShadow:setScaleX(1)
	end
	self.mSkillCon:setFlip(1)
end

-- 人转反相
function FightRole:TurnReverse()
	if self.IsFaceLeft then
		self:FaceRight()
	else
		self:FaceLeft()
	end
end

-- 修复人物朝向
function FightRole:fixFaceDirection()
	if self.IsFaceLeft then
	   self.mArmature:setScaleX(-1)
	else
		self.mArmature:setScaleX(1)
	end
end

-- 后退多少距离
function FightRole:BackDis(_dis)
	local _x = self:getPositionX()
	local _y = self:getPositionY()
	local _nextX = -_dis + _x
	local Posx = -10
	local X = 0
	if self.IsFaceLeft then 
	   _nextX = _dis + _x
	   Posx = 10
	   X = FightSystem.mSceneManager.mSceneView:GetSceneWidth()
	end
	_nextX = self.mMoveCon:filtPosX(_nextX)
	if TiledMoveHandler.CanPosStand(cc.p(_nextX, _y)) then 
		self:setPositionX(_nextX,true)
	else
		_nextX = _nextX - Posx
		for i=_nextX,X,Posx do
			if TiledMoveHandler.CanPosStand(cc.p(i, _y))  then
				self:setPositionX(i,true)
				break
			end
		end
	end 
end

-- 前进多少距离
function FightRole:ForwardDis(_dis)
	local _y = self:getPositionY()
	local _x = self:getPositionX()
	local _nextPos = nil
	if self.IsFaceLeft then 
	   _nextPos = cc.p(- _dis + _x, _y)
	else
		_nextPos = cc.p(_dis + _x, _y)
	end
	if self.IsFaceLeft then
		local maxX = math.floor(_x)
		local minX = math.ceil(_nextPos.x)
		local curPos = _nextPos
		for i = maxX,minX,-10 do
			local con1 = self.mMoveCon:CanMoveTo_Hor(i)
			if FightSystem:getMapInfo(cc.p(i,_y),self.mSceneIndex) == 0 then
				curPos = cc.p(i+10,_y)
				if maxX <= i+10 then
					curPos = cc.p(maxX,_y)
				end
				break
			end
		end

		curPos.x = self.mMoveCon:filtPosX(curPos.x)
       self:setPositionX(curPos.x)
	else
		local minX = math.ceil(_x)
		local maxX = math.floor(_nextPos.x)
		local curPos = _nextPos
		for i = minX,maxX,10 do
			if FightSystem:getMapInfo(cc.p(i,_y),self.mSceneIndex) == 0 then

				curPos = cc.p(i-10,_y)
				if minX > i-10 then
					curPos = cc.p(minX,_y)
				end
				break
			end
		end
		curPos.x = self.mMoveCon:filtPosX(curPos.x)
       self:setPositionX(curPos.x)
	end
end

-- 被推开多少距离
function FightRole:BeatAwayDis(_dis, isLeft)
	local _x = self:getPositionX()
	local _nextX = _dis + _x
	if isLeft then 
	   _nextX = -_dis + _x
	end
	_nextX = self.mMoveCon:filtPosX(_nextX)
	local _nextY = self:getShadowPos().y
	if TiledMoveHandler.CanPosStand(cc.p(_nextX, _nextY),self.mSceneIndex) then
		self:setPositionX(_nextX,true)
	end
end
------------------------------------------------------------------------

function FightRole:canbeGriped()
	local con1 = self:CanbeBeated()
	local con2 = not self.mFSM:IsBeGriped()
	return con1 and con2
end

-- 停止移动
function FightRole:StopMove()
	self.mMoveCon:StopMove()
	self.mFSM:ChangeToStateWithCondition("runing", "idle")
	if self.mStopMoveFun then self.mStopMoveFun(self) return end
end

-- 跳到一个点
function FightRole:jumpByPos(_pos, _callback)
	self.mMoveCon.mJumpCon:HandleJumpTo(_pos, _callback)
end

-- 走到一个点
function FightRole:WalkingByPos( _pos, _callback,_isturnrun)
	self.IsTurnRun = _isturnrun
	if not self.mFSM:ChangeToState("runing") then return false end
	local _curPos = self:getPosition_pos()
	-- 如果欲移动位置与当前相同直接返回
	if cc.pGetDistance(_curPos, _pos) == 0 then
		if _callback then
		   _callback("daoda")
		end
	else
		if self.mGroup == "friend" or self.mGroup == "monster" or self.mGroup == "enemyplayer" then
			_pos.x = self.mMoveCon:filtPosX(_pos.x)
		end
		self.mMoveCon:StartMoveByPos(_pos, _callback)
	end
	return true
end

-- 走到一个点
function FightRole:WalkingByPosByShowPve( _pos, _callback)
	if not self.mFSM:ChangeToState("runing") then return false end
	local _curPos = self:getPosition_pos()
	-- 如果欲移动位置与当前相同直接返回
	if cc.pGetDistance(_curPos, _pos) == 0 then
		if _callback then
		   _callback("daoda")
		end
	else
		if self.mGroup == "friend" or self.mGroup == "monster" or self.mGroup == "enemyplayer" then
			_pos.x = self.mMoveCon:filtPosX(_pos.x)
		end
		self.mMoveCon:StartMoveForPveByPos(_pos, _callback)
	end
	return true
end

-- 攻击中走到一个点
function FightRole:WalkingByPosAttacking( _pos, _callback)
	if self.mGroup == "friend" or self.mGroup == "monster" or self.mGroup == "enemyplayer" then
		_pos.x = self.mMoveCon:filtPosX(_pos.x)
	end
	self.mMoveCon:StartMoveByPos(_pos, _callback)

end

-- 强迫走到一个点
function FightRole:forceWalkingByPos(_pos, _callback)
	if self.mFSM:ForceChangeToState("runing") then
		self.mMoveCon:StartMoveByPos(_pos, _callback)
	end
end

-- 跳跃
function FightRole:PlayJump()
	if self.mBuffCon:isInSheepBuff() then return end
	if self:IsControlByStaticFrameTime() then return end
	if self.mFSM:IsAttacking() then
	   self.mSkillCon:FinishCurSkill()
	else
	   self.mFSM:ChangeToState("jumping")
	end
end

-- 闪烁
function FightRole:PlayBlink()
	self:PlaySkillByID(self.mRoleData.mRole_DodgeSkill)
end

-- 强制闪烁
function FightRole:ForcePlayBlink(_deg)
	if not self.mFSM:IsBeatingStiff() then
		return
	end
	self:ForcesetPosandShadow(self:getShadowPos())
	self.mFSM:ForceChangeToStateForpvp("idle")
	self:PlaySkillByID(self.mRoleData.mRole_DodgeSkill)
	--[[
	if _deg then
		local _dir = FightConfig.GetDirectionByDegree(_deg)
		if _dir == FightConfig.DIRECTION_CMD.DLEFT or _dir == FightConfig.DIRECTION_CMD.DLEFTUP  or _dir == FightConfig.DIRECTION_CMD.DLEFTDOWN then
			self:FaceLeft()
		elseif _dir == FightConfig.DIRECTION_CMD.DRIGHT or _dir == FightConfig.DIRECTION_CMD.DRIGHTUP  or _dir == FightConfig.DIRECTION_CMD.DRIGHTDOWN then
			self:FaceRight()
		end
		self:PlaySkillByID(self.mRoleData.mRole_DodgeSkill)
	else
		self:PlaySkillByID(self.mRoleData.mRole_DodgeSkill)
	end
	]]
end

-- 格挡
function FightRole:PlayBlock()
	-- 判断是否在抓投中，并且可以打断
	if self.mBuffCon:isInSheepBuff() then return false end
	if self:IsControlByStaticFrameTime() then return false end
	if self.mMoveCon.mBlockCon.mBlockCoolingtime > 0 then return false end
	if self.mFSM:IsAttacking() then
	   self.mSkillCon:FinishCurSkill()	  
	end
	return self.mFSM:ChangeToState("block")
end

-- 取消格挡
function FightRole:StopBlock(_call)
	if not self.mFSM:IsBlock() then return false end
	if self.mBuffCon:isInSheepBuff() then return false end
	--if self:IsControlByStaticFrameTime() then return false end
	if self.mFSM:IsNotMutex(self.mFSM.mCurState, "block") then
		self.mMoveCon.mBlockCon:FinishBlock(_call)
		return true
	end
end

-- 人物正在攻击停止攻击
function FightRole:CancelAttack()
	if self.mFSM:IsAttacking() then
	   self.mSkillCon:FinishCurSkill()	  
	end
end


-- 正在攻击的话结束

-- 展示技能范围
function FightRole:showSkillRangeByID(_skillID)
	self.mSkillCon:showSkillRange(_skillID)
end

function FightRole:cancelSkillRange()
	self.mSkillCon:cancelSkillRange()
end

-- 施展技能
function FightRole:PlaySkillByID(_skillID, _tp)
	--debugLog("PlaySkillByID==========".._skillID)
	--self:ForBlockBySkill(_skillID)
	if not _tp then
		_tp = "normal"
	end
	--
	local _data = {_skillID, _tp}
	local xxx = self.mFSM:ChangeToState("attacking", _data)
	return  xxx
end

-- 是否可以施展技能
function FightRole:isCanPlaySkillByID(_skillID, _tp)
	if not _tp then
		_tp = "normal"
	end
	--
	local _data = {_skillID, _tp}
	return self.mFSM:IsCanChangeToState("attacking", _data)
end


-- 强迫施展技能
-- 1. 恢复动作
-- 2. 强制转成攻击状态
function FightRole:forcePlaySkill(_skillID, _tp)
	if not _tp then
		_tp = "normal"
	end
	--
	self:resumeAction()
	local _data = {_skillID, _tp}
	return self.mFSM:ForceChangeToState("attacking", _data)
end

-- 施展角色技能
function FightRole:playSpecialSkill1()
	self:PlaySkillByID(self.mRoleData.mRole_SpecialSkill1)
end

-- 施展角色技能
function FightRole:playSpecialSkill2()
	self:PlaySkillByID(self.mRoleData.mRole_SpecialSkill2)
end

-- 施展角色技能
function FightRole:playSpecialSkill3()
	self:PlaySkillByID(self.mRoleData.mRole_SpecialSkill3)
end

-- 开启静止帧
function FightRole:enableStaticFrame(_during,_nextdo)
	self.misNextdoStaticFrame = _nextdo
	if self.misNextdoStaticFrame then  self.mTempStaticFrameDuring = _during return end
	if self.mStaticFrameTime_Unlock then return end
	self.mStaticFrameDuring = _during
	self.mStaticFrameTime_Unlock = false
	self.mArmature:pauseAction(true)
end

-- 开启静 为了出厂
function FightRole:enableStaticFrame_ForStage(_during)
	if self.mStaticFrameTime_Unlock then return end
	self.mStaticFrameDuring = _during
	self.mStaticFrameTime_Unlock = false
end

-- 是否是静止影响
function FightRole:IsControlByStaticFrameTime()
	local con1 = FightSystem:IsWithinStaticFrameTime() and not self.mStaticFrameTime_Unlock
	local con2 = self.mStaticFrameDuring > 0
	return con1 or con2
end

-- 设置骨骼动画速度
function FightRole:ChangeActionSpeedScale(_frame)
	local _scale = _frame / 30
	self.mArmature.mSpine:setTimeScale(_scale)
end

-- 玩家是否为不可操作的状态
function FightRole:IsCannotControl()
	local _con1 = self:IsControlByStaticFrameTime()
	local _con2 = not self.mFEM:IsBeatStNone()

	return _con1 or _con2
end

-- 死亡移除
function FightRole:RemoveSelf()
	if FightSystem.mFightType == "olpvp" and (globaldata.olpvpType == 0 or globaldata.olpvpType == 3) then return end
	if self.mRemoveSummoning then return end
	if self.mGroup == "summonmonster" or self.mGroup == "summonfriend" then
		self:SummonRemoveHost()
	else
		if self.mSummonCon then
			self.mSummonCon:Destroy()
			self.mSummonCon = nil
		end
	end
	local function destroy()
		cclog("FightRole:RemoveSelf=====Group==" ..self.mGroup .. "===="..self.mInstanceID)
		local _group = self.mGroup
		local _pos = self:getPosition_pos()
		local monsterId = self.mRoleData.mMonsterID
		FightSystem.mRoleManager:RemoveRoleByIdx(_group, self.mInstanceID)
		if _group == "summonmonster" or _group == "summonfriend" then
			return
		end
		FightSystem:GetFightManager():OnRoleKilled(_group, _pos, monsterId)
	end

	-- 死亡通知
	--FightSystem.mRoleManager:FadeoutRoleByIdx(self.mGroup, self.mInstanceID)
	CommonAnimation.FadeoutToDestroy(self.mArmature, destroy)
end

-- 直接移除自已
function FightRole:RemoveOlPvpSelf()
	local function destroy()
		cclog("FightRole:RemoveOlPvpSelf=====Group==" ..self.mGroup .. "===="..self.mInstanceID)
		self.mSkillCon:RemoveAllSubObject()
		local _group = self.mGroup
		local _pos = self:getPosition_pos()
		local monsterId = self.mRoleData.mMonsterID
		FightSystem.mRoleManager:RemoveRoleByIdx(_group, self.mInstanceID)
		if _group == "summonmonster" or _group == "summonfriend" then
			return
		end
		FightSystem:GetFightManager():OnRoleKilled(_group, _pos, monsterId)
	end
	destroy()
end


-- 召唤物死亡移除主人关系
function FightRole:SummonRemoveHost()
	if self.mHost and self.mHost.mSummonCon then
		for k,v in pairs(self.mHost.mSummonCon.mSummons) do
			if v.mInstanceID  == self.mInstanceID then
				table.remove(self.mHost.mSummonCon.mSummons, k)
			end
		end	
	end
end

-- 冰冻死亡移除
function FightRole:RemoveSelfByFrozen()
	if FightSystem.mFightType == "olpvp" and (globaldata.olpvpType == 0 or globaldata.olpvpType == 3) then return end
	if self.mRemoveSummoning then return end
	if self.mGroup == "summonmonster" or self.mGroup == "summonfriend" then
		self:SummonRemoveHost()
	else
		if self.mSummonCon then
			self.mSummonCon:Destroy()
			self.mSummonCon = nil
		end
	end
	local function destroy()
		local _group = self.mGroup
		local _pos = self:getPosition_pos()
		local monsterId = self.mRoleData.mMonsterID
		FightSystem.mRoleManager:RemoveRoleByIdx(_group, self.mInstanceID)
		if _group == "summonmonster" or _group == "summonfriend" then
			return
		end
		FightSystem:GetFightManager():OnRoleKilled(_group, _pos, monsterId)
	end

	-- 死亡通知
	--FightSystem.mRoleManager:FadeoutRoleByIdx(self.mGroup, self.mInstanceID)
	if self.mBeatCon then
		if self.mBeatCon.mFrozenCon.mICE then
			self.mArmature.mSpine:setVisible(false)
			self.mBeatCon.mFrozenCon:FrozenDead(destroy)
		else
			CommonAnimation.FadeoutToDestroy(self.mArmature, destroy)
		end
	else
		CommonAnimation.FadeoutToDestroy(self.mArmature, destroy)
	end
	
end

-- 召唤物移除自己
function FightRole:RemoveSelfSummon()
	local function destroy()
		local _group = self.mGroup
		local _pos = self:getPosition_pos()
		local monsterId = self.mRoleData.mMonsterID
		FightSystem.mRoleManager:RemoveSummonByIdx(_group, self.mInstanceID)
		if _group == "summonmonster" or _group == "summonfriend" then
			return
		end
		FightSystem:GetFightManager():OnRoleKilled(_group, _pos,monsterId)
	end
	if self.mGroup == "summonmonster" or self.mGroup == "summonfriend" then
		self.mRemoveSummoning = true
	end
	CommonAnimation.FadeOutToDestroy_2(self.mArmature, destroy)
end

-- 召唤物移除自己ForOLPVP
function FightRole:RemoveSelfOlPvpSummon()
	local function destroy()
		local _group = self.mGroup
		local _pos = self:getPosition_pos()
		local monsterId = self.mRoleData.mMonsterID
		FightSystem.mRoleManager:RemoveSummonByIdx(_group, self.mInstanceID)
		if _group == "summonmonster" or _group == "summonfriend" then
			return
		end
		FightSystem:GetFightManager():OnRoleKilled(_group, _pos,monsterId)
	end
	destroy()
end

-- 是否可以受击
function FightRole:CanbeBeated()
	local con1 = not self.mFSM:IsDeading()
	local con2 = not self.Invincible
	local con3 = not self.mBuffCon:hasInvincibleBuffNow()
	return con1 and con2 and con3
end

function FightRole:InitShadow()
	if self.mArmature and self.mShadow then
		if self.mHorse then
			if self.mShadow.Shadow then
				self.mShadow.Shadow:setScaleX(self.mHorse.mInfoDB.ShadowSize[1])
				self.mShadow.Shadow:setScaleY(self.mHorse.mInfoDB.ShadowSize[2])
			end
		else
			if self.mShadow.Shadow then
				self.mShadow.Shadow:setScaleX(self.mRoleData.mInfoDB.ShadowSize[1])
				self.mShadow.Shadow:setScaleY(self.mRoleData.mInfoDB.ShadowSize[2])
			end
		end
	end
end

function FightRole:UpDateShadow()
	local function xxx()
		if self.mArmature and self.mShadow and self.mArmature.mSpine then
			if self.mHorse then
				local x = self.mHorse.mSpine:getBoundingBox().width / self.mShadow.Shadow:getContentSize().width
				self.mShadow.Shadow:setScaleX(x)
			else
				local x = self.mArmature.mSpine:getBoundingBox().width / self.mShadow.Shadow:getContentSize().width
				self.mShadow.Shadow:setScaleX(x)
			end
		end	
	end
	-- nextTick(xxx)
end

-- 受击者是否在高度范围内
function FightRole:IsInVictimHeightRange(data)
	if data then
		if data.DamageHeight[1] == 0 and data.DamageHeight[2] == 0 then
			return false
		end
		if self.mFSM:IsFallingDown() then
			if data.DamageHeight[1] == -1 then
				return true
			else
				return false
			end
		end
		local JumpHei = nil
		if self.mFSM:IsAttacking() then
			if not self.mAttackJump then
				self.mAttackJump = self.mArmature:getPlayskillHeigth()
			end
			JumpHei = self.mAttackJump
		else
			JumpHei = self.mJumpHeight
		end
		if data.DamageHeight[2] >= JumpHei then
			return true
		else
			return false
		end
	else
		return true
	end
end

-- 添加触摸区域
function FightRole:addTouchRegion(_func)
   createSpineTouchRegion(self.mSize, self.mArmature, _func, self)
end


------------------拾取相关-------------------------------------------
-- 是否可被拾取
function FightRole:CanbePickup(_pos)
	if not self.mFSM:IsFallingDown() then return false end
	--
	local _w = self.mSize.width
	local _h = self.mSize.height
	local _x = self:getPositionX() - _w/2
	local _y = self:getPositionY() - _h/2
	local _rect = cc.rect(_x, _y, _w, _h)
	if not cc.rectContainsPoint(_rect, _pos) then return false end
	--
	return true
end
--------------------------------------------------------------------------------

--[[ 
	受击回调
]]
function FightRole:OnBeatedEvent(_hiter, _damage, _params)
	self:debugShowHiterInfo(_hiter, _params)
	--[[ 注掉没用 2015.11.27
	if self.mHorse then
		local function doSomeThing()
			self.mFSM:ChangeToState("idle")
		end
		self.mHorse:unHangRole(doSomeThing)
		self.mHorse = nil
	end
	FightSystem:PushNotification("roledamaged")
	]]
	--self:setLocalZOrder(_hiter:getLocalZOrder() - 1)
end


--[[
	状态机回调
	#回调与角色的操作一一对应
]]
function FightRole:OnFSMEvent(_from, _to, _data)
	if self.IsKeyRole then
		--cclog("=====FightRole:OnFSMEvent=====From:  " .. _from .. "===To:  " .. _to)
	end
	-- 通知AI
	if self.mAI then
		self.mAI:OnFSMEvent(_from, _to, _data)
	end	

	local function _pauseMove(_from)
		if _from == "runing" then
			self.mMoveCon:PauseMoveStatus()
		end
	end

	if FightSystem.mFightType == "olpvp" and self.IsKeyRole then
		if _from == "block" and _to ~= "block" then
			FightSystem:GetFightManager():Block_SyncPVP(self,2)
		end
	end

	-- 恢复动作
	if not self.mSkillCon.mDzShowTime then
		self:resumeAction()
	end
	-- 自行处理
	if _to == "idle" then
		-- 先还原动作
		self:OnFSMEvent_toIdle()
	elseif _to == "runing" then
		self:OnFSMEvent_toRuning()
	-- elseif _to == "jumping" then
	-- 	self:OnFSMEvent_toJumping(_from, _pauseMove)
	elseif _to == "attacking" then
		self:OnFSMEvent_toAttacking(_from, _pauseMove, _data[1], _data[2])
	elseif _to == "dead" then
		self:OnFSMEvent_toDead(_data)
	elseif _to == "becontroled" then
		self:OnFSMEvent_toBecontrol(_from)
	elseif _to == "beatingstiff" then
		self:OnFSMEvent_toBeatingStiff(_from, _pauseMove)
	elseif _to == "block" then
		self:OnFSMEvent_toBlock(_from, _pauseMove)
	end

end

function FightRole:OnFSMEvent_toIdle()
	self:ResetHallrelaxTime()
	if self.mHorse then
	   self.mHorse:ActionNow("stand", true)
	else
		if not self.mMoveCon:ResumeMoveStatus() then
			local _cmd = self.mPickupCon:getSpineCmd_Stand()
			self.mArmature:ActionNow(_cmd, true,nil,true)
		end
	end
end

-- 人物播胜利界面
function FightRole:PlayVictory()
	self.mArmature:setNoReceiveAction(false)
	self.mArmature:ActionNow("victory")
end

function FightRole:Up_Bench(_x,_y,waittime)
	self:setShadowPosX(_x)
	self:setShadowPosY(_y)
	local delayTimes = 0.5
	self.mArmature:setPosition_ArmatureY(770)

	local function ActionCallback(key)
		if key == "pickUp" then
			self.mArmature:pauseAction(true)
		end
	end


	local function _func()
		--self:enableStaticFrame(0)
		self.mArmature:setPosition_ArmatureY(_y)
		self.mIsUpBenching = false
		self.mArmature:UnRegisterActionEnd("FightRole")
		self.mArmature:pauseAction(false)
		self.mArmature:ActionNow("stand",true)

		local flag = true
		if FightSystem.mFightType == "fuben" or FightSystem.mFightType == "arena" then
			flag = not FightSystem.mTouchPad.mAutoTouchAttack
		end
		if self.IsKeyRole and flag then
			self.mAI:setOpenAI(false)
		else
			if FightSystem.mFightType == "fuben" and globaldata.PvpType == "blackMarket" then
			else
				self.mAI:setOpenAI(true)
			end
		end
		self:setInvincible(false)
	end

	local act = cc.MoveTo:create(0.5, cc.p(_x,_y))

	local _ac2 = cc.DelayTime:create(delayTimes)

	local _callback = cc.CallFunc:create(_func)
	--cclog("Bench_X===" .. _x .. "Y===" .. _y)
	if waittime then
		local act0 = cc.DelayTime:create(waittime)
		self.mArmature:runAction(cc.Sequence:create(act0,act,_ac2,_callback))
	else
		self.mArmature:runAction(cc.Sequence:create(act,_ac2,_callback))
	end
	
	self.mArmature:RegisterActionEnd("FightRole",ActionCallback)

	self.mArmature:ActionNow("pickUp")

	self.mAI:setOpenAI(false)

	self:setInvincible(true)

	self.mIsUpBenching = true
end



function FightRole:OnFSMEvent_toRuning()
	if self.mHorse then
	   self.mHorse:ActionNow("run", true)
	else
		if self.IsTurnRun then
			local _cmd = self.mPickupCon:getSpineCmd_Run()
			self.mArmature:ActionNow(_cmd, true,nil,nil,true)
		else
			local _cmd = self.mPickupCon:getSpineCmd_Run()
			self.mArmature:ActionNow(_cmd, true)
		end
	end
end

-- 处理跳跃状态
function FightRole:OnFSMEvent_toJumping(_from, _pauseMove)
	if self.mHorse then 
	    local function doSomeThing()
	    	 self.mFSM:ChangeToState("idle")
		end
	   self.mHorse:unHangRole(doSomeThing)
       self.mHorse = nil
	return end
	self.mMoveCon.mJumpCon:StartJump()
	_pauseMove(_from)
end

-- 处理格挡状态(类似跳跃)
function FightRole:OnFSMEvent_toBlock(_from, _pauseMove)
	if self.mHorse then 
	    local function doSomeThing()
	    	 self.mFSM:ChangeToState("idle")
		end
	   self.mHorse:unHangRole(doSomeThing)
       self.mHorse = nil
	return end
	self.mMoveCon.mBlockCon:StartBlock()
end

function FightRole:OnFSMEvent_toAttacking(_from, _pauseMove, _param1, _param2)
	local function doSomeThing()
		if self.mSkillCon:SetSkillByID(_param1, _param2) then
			_pauseMove(_from)
		end
	end
	if self.mHorse then 
	   self.mHorse:unHangRole(doSomeThing)
	   self.mHorse = nil
	return end
	if "shoot_hit" ~= _param2 then
	end
	doSomeThing()
end

function FightRole:OnFSMEvent_toBecontrol(_from)
	if self.mHorse then 
	   self.mFSM:ChangeToState("idle")
	return end
	if _from == "attacking" then
		self.mSkillCon:FinishCurSkill()
	end
	self.mMoveCon:StopMove()
end

function FightRole:OnFSMEvent_toBeatingStiff(_from, _pauseMove)
	if self.mHorse then 
	   self.mFSM:ChangeToState("idle")
	return end
	_pauseMove(_from)
	if _from == "attacking" then
		self.mSkillCon:FinishCurSkill()
	end
end

function FightRole:OnFSMEvent_toDead(_hiter)
	self:UnloadGun()
	self.mArmature:DeadAction(_hiter)
	self.mSkillCon:RemoveAllSubObject()
end

function FightRole:isEquipGun()
	return self.mGunCon.isEquip
end

function FightRole:UnloadGun()
	if self.mGunCon.isEquip then
		self.mGunCon:FightUnloadGun()
	end
end

-- 怪物血条
function FightRole:setMonsterBloodPro(value)
	if self.mArmature.mBlood then
		self.mArmature.mBlood:setBloodPer(value)
	end
end

-- 添加buff
function FightRole:AddBuff(id)
	local _state = DB_SkillState.getDataById(id)
	for h = 1,4 do
		local _effid = _state[EffectID_Table[h]]
		if _effid == 0 then break end
		local _eff = DB_SkillEffect.getDataById(_effid)
		self.mBuffCon:addBuff(_state, _eff, self)
	end
end

-- 移除buff
function FightRole:removeBuffByID(id)
	local _state = DB_SkillState.getDataById(id)
	if _state then
		self.mBuffCon:removeBuffByID(_state.ID)
	end
end

--[[
	接收指令
]]

-- 触摸板指令
function FightRole:OnFTCommand(_cmd, _deg)
	if self:IsCannotControl() then 
		self.mMoveCon:PauseMoveStatus(_cmd, _deg)
		return
	end
	if _cmd == FightConfig.DIRECTION_CMD.STOP then
		self:StopMove()
	else
		-- -- 如果在跳跃状态，收集方向
		-- if self.mFSM:IsJumping() then
		-- 	self.mMoveCon.mJumpCon:ChangeDirectionInJump(_cmd, _deg)
		-- end
		--
		if self.mFSM:ChangeToState("runing") or self.mSkillCon:canCurSkillMove() then
		   self.mMoveCon:StartMove(_cmd, _deg)
		else
		   self.mMoveCon:PauseMoveStatus(_cmd, _deg)
		end
	end
end

-- 全屏静止结束
function FightRole:finishFullScreenStatic()
	FightSystem.mRoleManager:StopEachSpineTick(false)
	FightSystem.mRoleManager:resumeAllActions()
	FightSystem.mRoleManager:resumeFSM()
	self.mStaticFrameTime_Unlock = false
end

-- 静止帧结束
function FightRole:finishStaticFrame()
	self:resumeAction()
	self:finishStaticisRun()
	self.mStaticFrameTime_Unlock = false
end

-- 静止帧结束跑动
function FightRole:finishStaticisRun()
	if self.IsKeyRole and not self.mAI.mOpenAI and self.mFSM:IsRuning() then
		local _cmd,_deg = FightSystem.mTouchPad:getCurDirection()
		self.mMoveCon:PauseMoveStatus(_cmd, _deg)
		self.mFSM:ChangeToStateWithCondition("runing", "idle")
	end
end

function FightRole:fullscreenStaticProtect()
	self.mStaticFrameTime_Unlock = true
	self.mArmature:pauseAction(false)
	self.mStaticFrameDuring = 0
end

-- 作为合体技伙伴放第一个技能
function FightRole:playCombineSkill1_sub()
	self.mSkillCon:ClearSkillStack()
	self:forcePlaySkill(self.mRoleData.mGSID1)
end

-- 暂停动作+结束当前技能
function FightRole:pauseActionAndFinishCurSkill()
	self.mArmature:pauseAction(true)
	self.mSkillCon:FinishCurSkill()
end

-- 暂停动作
function FightRole:pauseAction()
	self.mArmature:pauseAction(true)
end

-- 恢复动作
function FightRole:resumeAction()
	self.mArmature:pauseAction(false)
end

-- 开启渲染
function FightRole:enableRender(enabled)
	self.mIsEnableRender = enabled
	self.mArmature.mSpine:enableRenderer(enabled)
	if self.mHorse then
	   self.mHorse.mSpine:enableRenderer(enabled)
	end
	if self.mSpineShadow then
		self.mSpineShadow:setVisible(enabled)
	end
end