-- Func: 场景道具，动的，不动，可破坏的，可拾取的
-- Author: Johny
require "FightSystem/Role/SpineBlood"

SceneAni = class("SceneAni", function()
   return cc.Node:create()
end)

------------------成员变量-----------------
-- 投掷攻击间隔
local _THROW_HIT_INTERVAL_ = 5
local _BLUR_RADIUS = 3.0
--------------------------------------------
function SceneAni:ctor(_id, _instanceID, _bornPos, _isblood)
	self.mIsLiving = true
	self.mGroup = "sceneani"
	self.mState = "ground"
	self.mInstanceID = _instanceID
	self.SceneAniKey = string.format("SceneAni%d",self.mInstanceID)
	self.mDB = DB_SceneAnimationConfig.getDataById(_id)
	self.mType = self.mDB.Animation_Type
	self.mResDB = DB_ResourceList.getDataById(self.mDB.Animation_ResID)
	self.mCollideType = self.mDB.Animation_CanCollision		-- 1: 有碰撞  0：无碰撞
	-- buff
	self.mRegionBuffType = self.mDB.Animation_RangeBuffType  -- 区域内buff类型
	self.mRegionBuffDuring = self.mDB.Animation_RangeBuffLastTime -- 区域内buff持续时间
	if self.mRegionBuffType == 2 or self.mRegionBuffType == 5 then
		if self.mRegionBuffDuring == 0 then
			self.mTickLifeCycle = true
		end
	end
	self.mRegionBuffRange = self.mDB.Animation_RangeBuffRange  -- buff生效区域
	self.mRegionBuffID = self.mDB.Animation_RangeBuffID  -- 区域buffid
	--
	self.mThrow_HitInterval = _THROW_HIT_INTERVAL_
	---
	self.mAnchorOffsetX = self.mDB.Animation_AnchorOffset[1]
	self.mAnchorOffsetY = self.mDB.Animation_AnchorOffset[2]
	self.mFootWidth = self.mDB.Animation_FootSize[1]
	self.mFootHeight = self.mDB.Animation_FootSize[2]

 	self.mDamageRangeLength = self.mDB.Animation_DamageRangeLength
 	self.mDamageRangeWidth = self.mDB.Animation_DamageRangeWidth
	self.mMaxHp = self.mDB.Animation_MaxHP
	self.mStageHp2 = self.mDB.Animation_Stage2HP
	self.mStageHp3 = self.mDB.Animation_Stage3HP
	self.mCurHp = self.mDB.Animation_MaxHP
	self.mCanPickup = self.mDB.Animation_CanPickUp
	self.mBindType = self.mDB.Animation_BindType
	self.mBindDeflection = self.mDB.Animation_BindDeflection
	self.mBindNormalAttack = self.mDB.Animation_BindNormalAttack
	self.mBindThrowAttack = self.mDB.Animation_BindThrowAttack
	self.mBindThrowFly = self.mDB.Animation_BindThrowFly
	self.mBindThrowFlyMaxTime = self.mDB.Animation_BindThrowFlyMaxTime
	self.mBindThrowOffsetHeight = self.mDB.Animation_BindThrowOffsetHeight
	self.mBindingMaxUseCount = self.mDB.Animation_BindingMaxUseCount
	self.mAnimation_BindModelName = self.mDB.Animation_BindModelName
	self.mAnimation_RangeBuffObject = self.mDB.Animation_RangeBuffObject
	self.mCollision = self.mDB.CollisionType
	self.mBindCurUseCount = self.mBindingMaxUseCount
	self.mThrowDamageTick = false
	self.mRole = nil
	self.mIsFaceLeft = false
	--场景上的Monster
	self.MonsterList = {}
	self.isBornTick = false
	self.mScale = 1
	self.Isdead = false
	--------------------------------------
	-- initspine
	local function initSpine()
		if self.mType == 1 or self.mType == 11 or self.mType == 12 then
			local _json = self.mResDB.Res_path2
			local _atlas = self.mResDB.Res_path1
			local _sp = SpineDataCacheManager:getFightSpineByatlas(_json,_atlas,1,self)
			_sp:setLocalZOrder(1)
	 		self.mSpine = _sp
	 		self.mSpine:setPosition(0,0)
	 		_sp:setAnimation(0, "stand", true)
	 		--
			-- 注册回调
			self.mSpine:registerSpineEventHandler(handler(self, self.onAnimationEvent), 1)
			self.mSpine:registerSpineEventHandler(handler(self, self.onAnimationEvent), 3)
		elseif self.mType == 3 then
			local _json = self.mResDB.Res_path2
			local _atlas = self.mResDB.Res_path1
			local _sp = SpineDataCacheManager:getFightSpineByatlas(_json,_atlas,1,self)
			_sp:setLocalZOrder(1)
	 		self.mSpine = _sp
	 		self.mSpine:setPosition(0,0)
	 		--
	 		_sp:setAnimation(0, "animation", false)
			-- 注册回调
			self.mSpine:registerSpineEventHandler(handler(self, self.onAnimationEvent), 1)
			self.mSpine:registerSpineEventHandler(handler(self, self.onAnimationEvent), 3)

			self.tickcount = self.mDB.Animation_MonsterTransUnbind*30
			self:BornMonster()
			self.isBornTick = true
		end
	end
	local function initBlood()
		self.mBlood = SpineBlood.new()
		self.mBlood:setPosition(cc.p(0,250))
		self.mBlood:setLocalZOrder(1)
		self:addChild(self.mBlood)
	end
	
	initSpine()
	self.mIsBlood = _isblood
	
	-- init title
	self:initTitle()

	--
	self:setPositionX(_bornPos.x)
	self:setPositionYAndZorder(_bornPos.y)
	self:InitRect()
	--
	if self.mCollideType ~= 0 then
		self.mMapInfoList = {}
		self:setMapInfo(0)
	end
	--
	if self.mDB.Animation_IsUnderGround == 1 then
	   self:setLocalZOrder(0)
	end
	--
	if self.mBindDeflection > 0 then
	   self:setRotation(self.mBindDeflection)
	end
	--
	-- 接收通知
	self:registerNotification()
end

-- 注册通知
function SceneAni:registerNotification()
	if self.mCollideType == 0 and self.mRegionBuffID > 0 then
	   FightSystem:RegisterNotifaction("anyrolemoved", self.SceneAniKey, handler(self, self.onAnyRoleMoved))
	end
end

-- 解注册通知
function SceneAni:unRegisterNotification()
	FightSystem:UnRegisterNotification("anyrolemoved", self.SceneAniKey)
end

-- 模糊
function SceneAni:blur( )
	if self.mSpine then
		if self.mIsnoSpine then
			ShaderManager:blur(self.mSpine, cc.vec2(self.mSpine:getContentSize().width, self.mSpine:getContentSize().height), _BLUR_RADIUS)
		else
			ShaderManager:blur_spine(self.mSpine,cc.vec2(self.mSpine:getBoundingBox().width,self.mSpine:getBoundingBox().height),_BLUR_RADIUS)
		end
	end
end

-- 获取骨骼宽度
function SceneAni:getSpineSize()
	if self.mSpine then
		if self.mIsnoSpine then
			return cc.size(self.mSpine:getContentSize().width,self.mSpine:getContentSize().height)
		else
			return cc.size(self.mSpine:getBoundingBox().width,self.mSpine:getBoundingBox().height)
		end
	end
end

function SceneAni:setFindGuideRole()
	self.IsGuideScene = true
end

-- initTitle
function SceneAni:initTitle()
	if self.mDB.Name <= 0 then return end
	local _textDB = DB_Text.getDataById(self.mDB.Name)
	local _lb = ccui.Text:create()
	_lb:setFontName("res/fonts/font_3.ttf")
    _lb:setLocalZOrder(2)
    self:addChild(_lb)
    _lb:setColor(cc.c3b(122, 247, 255))
    _lb:setAnchorPoint(cc.p(0.5, 0))
    _lb:setPosition(cc.p(0, 130))
    _lb:setFontSize(_textDB.Text_CNSize)
    LabelManager:outline(_lb,G_COLOR_C4B.BLACK)
    self.mTitle = _lb
    --
    _lb:setString(_textDB.Text_CN)
end

-- initSceneMark
-- initTitle
function SceneAni:initSceneMark()
	local _sp = cc.Sprite:create()
	_sp:setProperty("Frame", "fight_pve_flag.png")
    _sp:setLocalZOrder(2)
    self:addChild(_sp)
    _sp:setAnchorPoint(cc.p(0.5, 0))
    _sp:setPosition(cc.p(0, 200))
    self.mSprite = _sp
	local act0 = cc.MoveTo:create(0.5, cc.p(_sp:getPositionX(),_sp:getPositionY()+10))
	local act1 = cc.MoveTo:create(0.5, cc.p(_sp:getPositionX(),_sp:getPositionY()-10))
	local act2 = cc.Sequence:create(act0,act1)
	local forever = cc.RepeatForever:create(act2)
    self.mSprite:runAction(forever)
end

function SceneAni:destroyBlood()
	if self.mBlood then
		self.mBlood:removeFromParent()
		self.mBlood = nil
	end
end

function SceneAni:Destroy(_flag)
	self:unRegisterNotification()
	--
	self.mIsLiving = false
	if self.mCollideType ~= 0 then
		self:setMapInfo(1)
	end
	if self.mDB.Animation_CreateAni ~= 0 and _flag and FightSystem.mStatus ~= "pause" then
		local obj = FightSystem.mRoleManager:LoadSceneAnimation(self.mDB.Animation_CreateAni,cc.p(self:getPositionX(),self:getPositionY()))
		local pos = cc.p(self:getPositionX()+self.mDB.Animation_CreateOffset[1],self:getPositionY()+self.mDB.Animation_CreateOffset[2])
		local _ac = cc.JumpTo:create(1, pos, 150, 1)
		obj:runAction(_ac)
	end
	--
	self.mInstanceID = nil
	self.mDB = nil
	self.mType = nil
	self.mResDB = nil
	self.mCollideType = nil
	self.mMaxHp = nil
	self.mCurHp = nil

	if self.mRegionBuffType == 5 then
		local x = getGoldFightPosition_LU().x + ( self:getPositionX() + FightSystem.mSceneManager:GetTiledLayer():getPositionX())
	    local y =  self:getPositionY() + getGoldFightPosition_LD().y
	    local pos = cc.p(x,y)
	    self.mSpine:setStopTick(true)
	    self.mSpine:setToSetupPose()
		Baoxiangpiao:showBaoJinbi(self.mSpine,pos,cc.p(getGoldFightPosition_LU().x+460,getGoldFightPosition_RU().y-100))
	else
		SpineDataCacheManager:collectFightSpineByAtlas(self.mSpine)
	end

	self.mIsnoSpine = nil
	self.mSpine = nil
	if self.mShadow then
	   self.mShadow:destroy()
	   self.mShadow = nil
	end
	if self.mTitle then
		self.mTitle:removeFromParent()
		self.mTitle = nil
	end
	self:removeFromParent()

	self.MonsterList = nil
	self.mMapInfoList = nil
end

function SceneAni:Tick()
	if self.mIsPickup then
		self.mIsPickup = false
		self:destroyself()
		return
	end
	if self.IsGuideScene then
		local _keyRole = FightSystem:GetKeyRole()
		local _posKeyRole = _keyRole:getPosition_pos()
		local _r = cc.pGetDistance(cc.p(self:getPositionX(), self:getPositionY()), _posKeyRole)
		if _r < 100 then
			FightSystem:GetFightManager():GuideStep5()
			self:destroyself()
		end
		return
	end
	self:TickTrigger()
	self:TickThrow()
	self:TickBornMonsterItem()
	self:TickLifeCycle()
end

function SceneAni:TickLifeCycle()
	if self.mTickLifeCycle then return end
	if self.mRegionBuffType == 3 or self.mRegionBuffType == 2 or self.mRegionBuffType == 5 then
		if self.mRegionBuffDuring > 0 then self.mRegionBuffDuring = self.mRegionBuffDuring - 1 return end
		self.mTickLifeCycle = true
		if self.mRegionBuffType == 3 then
			self:destroyself()
		elseif self.mRegionBuffType == 2 or self.mRegionBuffType == 5 then
			local function destroy()
				self:destroyself()
			end 
			CommonAnimation.FadeoutToDestroy(self, destroy)
		end
	end
end

function SceneAni:PickUpJinbi()
	if self.mPickupover then return end
	if self.mRegionBuffType and self.mRegionBuffType == 5 then
		self.mIsPickup = true
		self.mPickupover = true
	end
end

function SceneAni:TickTrigger()
	-- 检测主角触发动画事件
	local _keyRole = FightSystem.mRoleManager:GetKeyRole()
	if _keyRole then
		local _pos = _keyRole:getPosition_pos()
		self:OnTriggerRange(_pos)
	end
end

function SceneAni:TickBornMonsterItem()

	if not self.isBornTick then
		return
	end
	self.tickcount = self.tickcount - 1
	if self.tickcount == 0 then
		for i=1, #self.MonsterList do
			local key = string.format("Animation_MonsterTransUnbindPos%d",i)
			if self.mDB[key] == 0 then
				return
			end
			local pos = self.mDB[key]
			self.MonsterList[i]:setJumpto(cc.p(pos[1],pos[2]))
		end
		self.isBornTick = false
		return 
	end
	if self.mType == 3 then
		for i=1, #self.MonsterList do
			local pos = self.mSpine:getBonePosition(string.format("bind%d",i))
			self.MonsterList[i]:setPositionX(self:getPositionX()+pos.x)
			self.MonsterList[i]:setPositionY(self:getPositionY()+pos.y)
		end
	end
end

function SceneAni:BornMonster(_pos)
	for i=1,4 do

		local key = string.format("Animation_MonsterTransBindMonster%d",i)
		if self.mDB[key] == 0 then
			return
		end
		local pos = self.mSpine:getBonePosition(string.format("bind%d",i))
		local role = FightSystem.mRoleManager:LoadMonster(self.mDB[key],pos)
		role.mAI:setOpenAI(false)
		
		self.MonsterList[i] = role
	end
end

function SceneAni:InitRect()
	local _x = self:getPositionX() + self.mAnchorOffsetX  - self.mFootWidth/2
	local _y = self:getPositionY() + self.mAnchorOffsetY - self.mFootHeight/2
	local _w = self.mFootWidth
	local _h = self.mFootHeight
	--
	self.mRect = cc.rect(_x, _y, _w, _h)
end

function SceneAni:AddToRoot(_root, y , _isHallScene)
	local function initShadow()
		if not self.mDB then return end
		if self.mDB.Animation_HideShadow == 1 then return end
		if _isHallScene then
		   	self.Shadow = cc.Sprite:create()
		    local _resDB = DB_ResourceList.getDataById(645)
		    self.Shadow:setProperty("Frame", _resDB.Res_path1)
		    self:addChild(self.Shadow)
		    local sx = self.mDB.Animation_FootSize[1]/self.Shadow:getContentSize().width
		    local sy = self.mDB.Animation_FootSize[2]/self.Shadow:getContentSize().height
		    if sx == 0 then
		    	sx = 1
		    end
		    if sy == 0 then
		    	sy = 1
		    end
			self.Shadow:setScaleX(sx)
			self.Shadow:setScaleY(sy)
		else
			if globaldata.gameperformance then
				self.Shadow = cc.Sprite:create()
			    local _resDB = DB_ResourceList.getDataById(645)
			    self.Shadow:setProperty("Frame", _resDB.Res_path1)
			    self:addChild(self.Shadow)
			    local sx = self.mDB.Animation_FootSize[1]/self.Shadow:getContentSize().width
			    local sy = self.mDB.Animation_FootSize[2]/self.Shadow:getContentSize().height
			    if sx == 0 then
			    	sx = 1
			    end
			    if sy == 0 then
			    	sy = 1
			    end
				self.Shadow:setScaleX(sx)
				self.Shadow:setScaleY(sy)
			else
				self.mShadow = SpineShadowSprite.new()
		    	self.mShadow:initWithSceneAni(self.mSpine, 1, _root.mSceneView.mDB)
		    	self:addChild(self.mShadow)
			end
		end

	end
	if _root.mTiledMapMiny and _root.mTiledMapMaxy then
		self.mTiledMapMiny = _root.mTiledMapMiny
		self.mTiledMapMaxy = _root.mTiledMapMaxy
		self.mTiledScaleY = 0.1 / math.floor(self.mTiledMapMaxy - self.mTiledMapMiny)
		--self:ChangeScaleByPosY(y)
	end
	initShadow()
	------
	_root:addChild(self)
	--
	if self.mDB.Animation_IsUnderGround ~= 1 then
	  self:setLocalZOrder(1440- y)
	end
	
	self:DebugShowRange()
end

function SceneAni:getTiledmapScaleByPosY(_y)
	if self.mTiledScaleY then
		return (self.mTiledMapMiny - _y)*self.mTiledScaleY + 1
	end
	return 1
end

function SceneAni:DebugShowRange(_throw)
	if not FightConfig.__DEBUG_SCENEANI_RANGE then return end
	self.mSpine:enableBeatRange(cc.p(0, 0))
	local _offX = self.mFootWidth/2
	local _offY = self.mFootHeight/2
	local _w = self.mFootWidth	
	local _h = self.mFootHeight
	if _throw then
		_offX = self.mDamageRangeLength/2
		_offY = self.mDamageRangeWidth/2
		_w = self.mDamageRangeLength
		_h = self.mDamageRangeWidth
	end
	local _x = self.mAnchorOffsetX  - _offX
	local _y = self.mAnchorOffsetY - _offY

	local _rectMe = cc.rect(_x, _y, _w, _h)
    CommonSkill.showDebugRange_Rect(_rectMe, self.mSpine, -999)
end

function SceneAni:getPosition_pos()
	return cc.p(self:getPosition())
end

function SceneAni:CollisionPiece()
	if self.mCollision == 0 then
		return self.mCollision,self:getPosition_pos()
	else
		local _x = self:getPositionX() - self.mFootWidth/2 + self.mAnchorOffsetX
		local _y = self:getPositionY() - self.mFootHeight/2 + self.mAnchorOffsetY
		local _w = self.mFootWidth
		local _h = self.mFootHeight
		local rect = cc.rect(_x, _y, _w, _h)
		return self.mCollision,rect
	end
end

function SceneAni:getCollisionRandomPos()
	if self.mCollision == 0 then
		return self:getPosition_pos()
	else
		local xNum = math.random(1,2)
		local yNum = math.random(1,2)
		local wid = nil
		local hei = nil

		local Widran = math.random(1,self.mFootWidth)
		if xNum == 1 then
			wid = - Widran/2 - 10
		else
			wid = Widran/2 + 10
		end

		if yNum == 1 then
			hei = - self.mFootHeight/2 - 10
		else
			hei = self.mFootHeight/2 + 10
		end
		local _x = self:getPositionX() + wid
		local _y = self:getPositionY() + hei
		return cc.p(_x,_y)
	end
end

function SceneAni:setPositionYAndZorder(_y)
	self:setPositionY(_y)
	self:setLocalZOrder(1440 - _y)
	--self:ChangeScaleByPosY(_y)
end

function SceneAni:ChangeScaleByPosY(_y)
	if self.mCanPickup == 0 then return end
    local _scale = self:getTiledmapScaleByPosY(_y)
    self.mSpine:setScale(_scale*self.mScale)
end

-- 面向左边
function SceneAni:FaceLeft()
	if self.mIsFaceLeft ~= true then
		self:setScaleX(-1)
		self.mIsFaceLeft = true
	end
end

-- 面向右边
function SceneAni:FaceRight()
	if self.mIsFaceLeft == true then
		self:setScaleX(1)
		self.mIsFaceLeft = false
	end
end

-- 设置当前路面信息
function SceneAni:setMapInfo(_type)
	local _x = self:getPositionX() + self.mDB.Animation_AnchorOffset[1] - self.mDB.Animation_FootSize[1]/2
	local _y = self:getPositionY() + self.mDB.Animation_AnchorOffset[2] - self.mDB.Animation_FootSize[2]/2
	local _w = self.mDB.Animation_FootSize[1]
	local _h = self.mDB.Animation_FootSize[2]
	local _tiledW = math.floor((_x )/10)
	local _tiledW1 = math.floor((_x + _w )/10)
	local _tiledH = math.floor(_y/10)
	local _tiledH1 = math.floor((_y + _h)/10)

	for x = _tiledW, _tiledW1 do
		for y = _tiledH,_tiledH1 do
			if _type == 0 then
				if not self.mMapInfoList[x] then
					self.mMapInfoList[x] = {}
				end
				self.mMapInfoList[x][y] = FightSystem:getMapInfoByTildepos(cc.p(x,y))
				FightSystem:setMapInfo(cc.p(x,y),_type)
			else
				FightSystem:setMapInfo(cc.p(x,y),self.mMapInfoList[x][y])
			end
		end
	end
end

function SceneAni:canbeDamaged(_hit)
	if self.Isdead then
		return false
	end
	if self.mType == 1 then
		return true
	else
		if self.mType == 12 then
			if _hit.mGroup == "monster" or _hit.mGroup == "summonmonster" or _hit.mGroup == "enemyplayer" then
				return true
			end
		end
	end
end

-- 死亡
function SceneAni:destroyAni()
	self.Isdead = true
	self.mSpine:setAnimation(0, "dead", false)
end

-- 消失
function SceneAni:destroyself()
	FightSystem:GetFightManager():OnRoleKilled(self.mGroup, self:getPosition_pos(), self.mDB.ID)
	FightSystem.mRoleManager:RemoveSceneAniByIdx(self.mInstanceID)
end

------------------------------拾取----------------------------------------
function SceneAni:TickThrow()
	if not self.mThrowDamageTick then return end
	self:TickThrow_Any()
end

function SceneAni:TickThrow_Any()
	if self.mThrow_HitInterval < _THROW_HIT_INTERVAL_ then
	   self.mThrow_HitInterval = self.mThrow_HitInterval + 1
	return end
	self.mThrow_HitInterval = 0
	------
	local _list = self:FindVictim(0)
	if #_list == 0 then return end
	--
	local function hitBody()
		local dbSkill = DB_SkillEssence.getDataById(self.mBindThrowAttack)
		for k,_victim in pairs(_list) do
			local _damage, _damageTP = self:getPickupThrowDamageCount(self.mRole, _victim, dbSkill)
			if _damageTP ~= "dodge" then
				_victim.mBeatCon:Beated(self.mRole, _damage, _damageTP,dbSkill.ProcessID2)
				self:pickupThrowHit(_victim, dbSkill)
			end
		end
	end
	local function afterHit()
		if self.mBindType == 1 then
			-- 击中后消失
			self.mThrowDamageTick = false
			local _disY = self:getPositionY()
			local _during = MathExt.GetDownTimeByDis(_disY) / 30
			local _ac = cc.EaseIn:create(cc.MoveTo:create(_during, cc.p(0, 0)), 2.0)
			local _callbcak = cc.CallFunc:create(handler(self, self.FadeoutAndDestroy))
			self.mSpine:stopAllActions()
			self.mSpine:setRotation(0)
			self.mSpine:runAction(cc.Sequence:create(_ac, _callbcak))
			self:stopAllActions()
		end
	end
	hitBody()
	afterHit()
end

function SceneAni:CanbePickup(_pos)
	if self.mCanPickup == 0 then return false end
	if self.mState ~= "ground" then return false end
	if not cc.rectContainsPoint(self.mRect, _pos) then return false end
	--
	return true
end

function SceneAni:pickupedByRole(_role)
	self.mRole = _role
end

-- 水平投掷
function SceneAni:throwHor(_holder)
	local _rolePos = _holder:getPosition_pos()
	local function finishThrow()
		self:FadeoutAndDestroy()
	end
	local function cancelThrowDamageTick()
		self.mThrowDamageTick = false
		self.mSpine:setRotation(0)
		self:stopAllActions()
	end
	local _dis = self.mBindThrowFlyMaxTime * self.mBindThrowFly
	local _curY = _rolePos.y
	local _curY_Object = _holder.mArmature:getSize().height * 0.7
	local _rotation = 1080
	local function initPos()
		if self.mRole.IsFaceLeft then
		   _dis = - _dis
		   _rotation = - _rotation
		end
		local _curX = _rolePos.x
		self.mSpine:setPositionY(_curY_Object)
		self:setPositionX(_curX)
		self:setPositionYAndZorder(_curY)
		self:setLocalZOrder(_holder:getLocalZOrder() + 1)
	end
	local function horAction()
		local _during = self.mBindThrowFlyMaxTime/30
		local function objectAction()
			-- 旋转
			local _during1 = _during
			local _ac = cc.RotateBy:create(_during1, _during1* _rotation)
			_during2 = MathExt.GetDownTimeByDis(_curY_Object) / 30
			-- 落地动作
			local _ac2 = cc.EaseIn:create(cc.MoveTo:create(_during2, cc.p(0, 0)), 2.0)
			local _callbcak1 = cc.CallFunc:create(cancelThrowDamageTick)
			local _delay = cc.DelayTime:create(1)
			local _callbcak2 = cc.CallFunc:create(finishThrow)
			self.mSpine:runAction(cc.Sequence:create(_ac, _callbcak1,  _ac2, _delay, _callbcak2))
		end
		local function selfAction()
			-- 移动自己
			local _ac = cc.MoveBy:create(_during, cc.p(_dis, 0))
			self:runAction(_ac)
			self.mThrowDamageTick = true
		end
		objectAction()
		selfAction()
	end
	initPos()
	horAction()
	--
end

-- 抛物线投掷
function SceneAni:throwParabola(_holder)
	local _rolePos = _holder:getPosition_pos()
	local function hitFalldown()
		local _list = self:FindVictim(1)
		if #_list == 0 then return end
		local dbSkill = DB_SkillEssence.getDataById(self.mBindThrowAttack)
		for k,_victim in pairs(_list) do
			local _damage, _damageTP = self:getPickupThrowDamageCount_falldown(self.mRole, _victim, dbSkill)
			if _damageTP ~= "dodge" then
				_victim.mBeatCon:Beated(self.mRole, _damage, _damageTP,dbSkill.ProcessID2)
				self:pickupThrowHit_falldown(_victim, dbSkill)
			end
		end
	end
	local function finishThrow()
		self.mSpine:setRotation(0)
		self:stopAllActions()
		self:FadeoutAndDestroy()
		-- 判定落地伤害
		hitFalldown()
		-- 停止逐帧检查伤害
		self.mThrowDamageTick = false
	end
	--
	local _dis = self.mBindThrowFlyMaxTime * self.mBindThrowFly
	local _rotation = 720
	local _curX = _rolePos.x
	local _curY = _rolePos.y
	local function initPos()
		if self.mRole.IsFaceLeft then
		   _dis = - _dis
		   _rotation = - _rotation
		end
		local _curY_Object = _holder.mArmature:getSize().height * 0.7
		self.mSpine:setPositionY(_curY_Object)
		self:setPositionX(_curX)
		self:setPositionYAndZorder(_curY)
		self:setLocalZOrder(_holder:getLocalZOrder() + 1)
	end
	local function ParaAction()
		local _during = self.mBindThrowFlyMaxTime/30
		local function objectAction()
			-- 抛物线滚动
			local _nextPos = cc.p(0, 0)
			local _ac_1 = cc.JumpTo:create(_during, _nextPos, self.mBindThrowOffsetHeight, 1)
			local _ac_2 = cc.RotateBy:create(_during, _during* _rotation)
			local _ac = cc.Spawn:create(_ac_1, _ac_2)
			local _callbcak = cc.CallFunc:create(finishThrow)
			self.mSpine:runAction(cc.Sequence:create(_ac, _callbcak))
		end
		local function selfAction()
			self:runAction(cc.MoveBy:create(_during, cc.p(_dis,0)))
			self.mThrowDamageTick = true
		end
		objectAction()
		selfAction()
	end
	initPos()
	ParaAction()
end

-- 投掷碰撞检测
-- 0: 投掷中  1： 箱子落地
function SceneAni:IsCollideWithMe_Throw(_pos, _type)
	local _sz = cc.size(0,0)
	if _type == 0 then
	   _sz = self:getThrowHitRange()
	elseif _type == 1 then
	   _sz = self:getThrowHitRange_falldown()
	end
	local _x = self:getPositionX() - _sz.width/2
	local _y = self:getPositionY() - _sz.height/2
	local _rectMe = cc.rect(_x, _y, _sz.width, _sz.height)

	return cc.rectContainsPoint(_rectMe, _pos)
end

-- 寻找受害者
function SceneAni:FindVictim(_type)
	local list = {}
	local _victimCount = FightSystem.mRoleManager:GetVicmCount(self.mRole)
	for i = 1, _victimCount do
		local _victim = FightSystem.mRoleManager:GetVicim(i, self.mRole)
		if _victim and self:IsCollideWithMe_Throw(_victim:getPosition_pos(), _type) then
			table.insert(list, _victim)
		end
	end

	return list
end
-- 消失
function SceneAni:FadeoutAndDestroy()
	CommonAnimation.FadeoutToDestroy(self, handler(self, self.OnFinishDeadAction))
end
--------------------------投掷过程中，棍子和箱子-----------------------
-- 获取投掷击中范围
function SceneAni:getThrowHitRange()
	local dbSkill = DB_SkillEssence.getDataById(self.mBindThrowAttack)
	local dbProc = DB_SkillProcess.getDataById(dbSkill.ProcessID2)

	return cc.size(dbProc.DamageLength, dbProc.DamageWidth)
end
-- 获取投掷伤害
function SceneAni:getPickupThrowDamageCount(_holder, _victim, dbSkill)
	local dbProc = DB_SkillProcess.getDataById(dbSkill.ProcessID2)
	return CommonSkill.getDamageCount(_holder.mPropertyCon, dbProc, _victim.mPropertyCon)
end
-- 投掷击中，显示处理
function SceneAni:pickupThrowHit(_victim, dbSkill)
	local dbProc = DB_SkillProcess.getDataById(dbSkill.ProcessID2)
	CommonSkill.hitVictimDisplay(_victim, dbProc.ProcessDisplayID, self.mRole)
	CommonSkill.attachState(_victim, dbProc, self.mRole)
end
--------------------------箱子落地瞬间-----------------------
-- 获取投掷击中范围
function SceneAni:getThrowHitRange_falldown()
	local dbSkill = DB_SkillEssence.getDataById(self.mBindThrowAttack)
	local dbProc = DB_SkillProcess.getDataById(dbSkill.ProcessID3)

	return cc.size(dbProc.DamageLength, dbProc.DamageWidth)
end
-- 获取伤害
function SceneAni:getPickupThrowDamageCount_falldown(_holder, _victim, dbSkill)
	local dbProc = DB_SkillProcess.getDataById(dbSkill.ProcessID3)
	return CommonSkill.getDamageCount(_holder.mPropertyCon, dbProc, _victim.mPropertyCon)
end
-- 落地的状态和显示处理
function SceneAni:pickupThrowHit_falldown(_victim, dbSkill)
	local dbProc = DB_SkillProcess.getDataById(dbSkill.ProcessID3)
	CommonSkill.hitVictimDisplay(_victim, dbProc.ProcessDisplayID, self.mRole)
	CommonSkill.attachState(_victim, dbProc, self.mRole)
end
------------------------------------------------------------------------

------------------------------------------------------------------------------------------------

-- 椭圆判定
function SceneAni:IsPosInCircle(_a, _b, _pos)
	local _orX = self:getPositionX()
	local _orY = self:getPositionY()
	if MathExt.IsPosInEllipse(_pos.x - _orX, _pos.y- _orY, _a, _b) then
		return true
	end

	return false
end

-- 由Tick检测来移除
function SceneAni:OnFinishDeadAction()
	self:destroyself()
end

-- 死亡添加BUFF
function SceneAni:OnDeadBuff()
	if self.mRegionBuffType == 4 and self.mRegionBuffID > 0 then

		local enemyers = FightSystem.mRoleManager:GetEnemyTable()

		local friends = FightSystem.mRoleManager:GetFriendTable()

		local _rect = cc.rect(self:getPositionX() - self.mRegionBuffRange[1]/2, self:getPositionY() - self.mRegionBuffRange[2]/2, self.mRegionBuffRange[1], self.mRegionBuffRange[2])

		for k,v in pairs(enemyers) do
			if cc.rectContainsPoint(_rect, cc.p(v:getPositionX(),v:getPositionY())) then
				local _dbState = DB_SkillState.getDataById(self.mRegionBuffID)
	  			v.mBeatCon:TrapStateChange(nil, _dbState, self)
			end
		end

		for k,v in pairs(friends) do
			if cc.rectContainsPoint(_rect, cc.p(v:getPositionX(),v:getPositionY())) then
				local _dbState = DB_SkillState.getDataById(self.mRegionBuffID)
	  			v.mBeatCon:TrapStateChange(nil, _dbState, self)
			end
		end
		if self.mShadow then
			self.mShadow:setVisible(false)
		end
		if self.Shadow then
			self.Shadow:setVisible(false)
		end
	end

end


--[[
	回调部分
]]
function SceneAni:OnDamaged(_damage, _hiter)
	local function xxx()
		if not self:canbeDamaged(_hiter) then return end
		-- 调整面向
		-- if _hiter.IsFaceLeft then
		--    self:FaceLeft()
		-- else
		--    self:FaceRight()
		-- end
		--
		if self.mCurHp > 0 then
		   local injur = self:getOnDamagedAction(self.mCurHp)
		   self.mSpine:setAnimation(0, injur, false)
		   --
		   self.mCurHp = self.mCurHp - _damage
		   if self.mCurHp <= 0 then
		   	  if self.mIsBlood then
		   	  	FightSystem.mTouchPad.mSceneAniBar:setPercentage(0)
		   	  	FightSystem.mTouchPad.mSceneAniBar:setColor(getBloodColor(0))

		   	  end
		   	  self:destroyAni()
		   else
		   	  if self.mIsBlood then
		   	    local value = self.mCurHp/self.mMaxHp*100
		   	  	FightSystem.mTouchPad.mSceneAniBar:setPercentage(value)
		   	  	FightSystem.mTouchPad.mSceneAniBar:setColor(getBloodColor(value))
		   	  end
		  	end
		end
	end
	xxx()
end

-- 检测当前血量播受伤动作
function SceneAni:getOnDamagedAction(_curhp)
	if self.mStageHp2 == 0 then return "injured" end
	if self.mStageHp3 == 0 then return "injured2" end
	if self.mStageHp2 <= _curhp then
		return "injured"
	elseif self.mStageHp2 > _curhp and _curhp >= self.mStageHp3 then
		return "injured2"
	elseif self.mStageHp3 > _curhp then
		return "injured3"
	end
end

function SceneAni:getStandAction(_curhp)
	if self.mStageHp2 == 0 then return "stand" end
	if self.mStageHp3 == 0 then return "stand2" end
	if self.mStageHp2 <= _curhp then
		return "stand"
	elseif self.mStageHp2 > _curhp and _curhp >= self.mStageHp3 then
		return "stand2"
	elseif self.mStageHp3 > _curhp then
		return "stand3"
	end
end

-- 检测范围内有人踏入
function SceneAni:OnTriggerRange(_pos)
	local function xxx()
		if self.mType ~= 11 then return end
		--
		local _a = self.mDB.Animation_TriggerRangeA
		local _b = self.mDB.Animation_TriggerRangeB

		if self:IsPosInCircle(_a, _b, _pos) then
		   local _action = self.mDB.Animation_TriggerAct
		   if _action[1] ~= "" and self.mSpine:getCurrentAniName() == "stand" then
		      self.mSpine:setAnimation(0, _action[1], false)
		   end
		   if _action[2] ~= 0 then
		   	--触发ID生效
		   	if FightSystem.mFightType == "fuben" then
		   		FightSystem:GetFightManager():DelayedTriggerMonster(_action[2],_action[3])
		   	end 
		   end
		end
	end
	xxx()
end


--[[
spine 回调
]]
function SceneAni:onAnimationEvent(event)
	local function xxx()
		if event.type == 'end' then
	    	if event.animation == "dead" then
	       	   CommonAnimation.FadeoutToDestroy(self, handler(self, self.OnFinishDeadAction))
	       	elseif event.animation == self.mDB.Animation_TriggerAct then
	       		if self.mDB.Animation_TriggerActDisappear == 0 then return end
	       		self:setVisible(false)
	       	    performWithDelay(self, handler(self, self.OnFinishDeadAction), 1/30) 
	        elseif event.animation == self.mDB.Animation_MonsterTransAct then
	        	self:setVisible(false)
	       	    performWithDelay(self, handler(self, self.OnFinishDeadAction), 1/30) 
	        elseif event.animation == "injured" or event.animation == "injured2" or event.animation == "injured3" then
	        	if self.mSpine:getCurrentAniName() == "" then
	        		local stand = self:getStandAction(self.mCurHp)
	        		self.mSpine:setAnimation(0, stand, true)
	        	end
	        end
	    elseif event.type == 'event' and event.eventData.name == "sound" then
	    	local intEffectId = event.eventData.intValue
	    	if intEffectId and intEffectId > 0 then
	    		CommonAnimation.PlayEffectId(intEffectId)
	    	end
	   	elseif event.type == 'event' and event.animation == "dead" and event.eventData.name == "1" then
	    	self:OnDeadBuff()
	    end
	end
	xxx()
end


-- 战斗中角色移动的通知
function SceneAni:onAnyRoleMoved(_role)
	local function xxx()
		if self.mAnimation_RangeBuffObject == 1  then
			if _role.mGroup == "friend" or  _role.mGroup == "enemyplayer" then
			else
				return
			end
		elseif self.mAnimation_RangeBuffObject == 2  then
			if _role.mGroup == "monster" then
			else
				return
			end
		end
		local _pos = _role:getPosition_pos()
		local _w = self.mDB.Animation_FootSize[1]
		local _h = self.mDB.Animation_FootSize[2]
		local _x = self:getPositionX() - _w/2 + self.mDB.Animation_AnchorOffset[1]
		local _y = self:getPositionY() - _h/2 + self.mDB.Animation_AnchorOffset[2]
		local _rect = cc.rect(_x, _y, _w, _h)
		local data = {}
		data.DamageHeight = {-1,50}
		if cc.rectContainsPoint(_rect, _pos) and _role:IsInVictimHeightRange(data) then
			-- 添加指定buff
			local _dbState = DB_SkillState.getDataById(self.mRegionBuffID)
		   _role.mBeatCon:TrapStateChange(nil, _dbState, self)
		   -- 踩到消失
		   if self.mRegionBuffType == 2 then
		   		self:destroyself()
		   elseif self.mRegionBuffType == 5 then
		   		self:destroyself()
		   end
		else
		   -- 消散指定buff
		    if self.mRegionBuffType ~= 2 then
		   	  _role.mBuffCon:removeBuffByID(self.mRegionBuffID)
		   	end
		end
	end
	xxx()
end