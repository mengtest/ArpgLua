-- Name: SpineShadow
-- Func: 角色的影子
-- Author: Johny

require "FightSystem/Role/SpineShadowSprite"

SpineShadow = class("SpineShadow", function()
   return cc.Sprite:create()
end)

function SpineShadow:ctor(_armature, _bornPos)
	self.mRole = _armature.mRole
	self.mArmature =  _armature
    -- self.mIsOnRoad = true
    self.mTickMoveSwitchX = true
	self.mTickMoveSwitchY = true
	self.mStopTickZorder = false
    -- init
    self:setPosition(_bornPos)
	self.mPerPosX = _bornPos.x 
	self.mPerPosY = _bornPos.y 
	self.mIsHideShadow = false
	if self.mRole.mGroup == "monster" and self.mRole.mRoleData.mInfoDB.HideBloodShadow == 1 then
		self.mIsHideShadow = true
		self:setVisible(false)
	end
	self.mShadowwidth = self.mRole.mRoleData.mInfoDB.ShadowSize[1]
	self.mShadowheight = self.mRole.mRoleData.mInfoDB.ShadowSize[2]
	if self.mRole.mGroup == "hallrole" or globaldata.gameperformance then
		self:createsimpleShadow()
	end
	
	-- init round
	--self:initRound()
end

function SpineShadow:AddToRoot(_root)
	if self.mRole.mGroup == "friend" then
		self.mHeropositionhelo = CommonAnimation.createCacheSpine_commonByResID(8072, _root)
		self.mHeropositionhelo:setLocalZOrder(1)
		self.mHeropositionhelo:setPosition(cc.p(0,0))
		self.mHeropositionhelo:setAnimation(0, "hero_position_helo", true)
		if self.mRole.IsKeyRole then
			self.mHeropositionhelo:setVisible(true)
		else
			self.mHeropositionhelo:setVisible(false)
		end
	end
end

-- 创建简单影子
function SpineShadow:createsimpleShadow()
	self.Shadow = cc.Sprite:create()
    local _resDB = DB_ResourceList.getDataById(645)
    self.Shadow:setProperty("Frame", _resDB.Res_path1)
    self:addChild(self.Shadow)
	self.Shadow:setScaleX(self.mShadowwidth*self.mArmature.mScale)
	self.Shadow:setScaleY(self.mShadowheight*self.mArmature.mScale)
end

-- init round
function SpineShadow:initRound()
	if self.mRole.mGroup ~= "friend" then return end
	local _resDB = DB_ResourceList.getDataById(526)
	self.mRound =  CommonAnimation.createCacheSpine_commonByResID(526, self)
    self.mRound:setLocalZOrder(0)
    self.mRound:setPosition(cc.p(self:getContentSize().width/2, self:getContentSize().height/2))
end

-- change round ani
function SpineShadow:changeRoundAni(_aniNum)
	if _aniNum == 1 then
	   self.mRound:setAnimation(0, "animation", true)
	else
	   self.mRound:setAnimation(0, "animation2", true)
	end
end

-- 设置影子显示
function SpineShadow:setVisibleShadow(_visible)
	if self.mIsHideShadow then return end
	self:setVisible(_visible)
	if self.mHeropositionhelo then
		self.mHeropositionhelo:setVisible(_visible)
	end
	if self.mRole.mSpineShadow then
		self.mRole.mSpineShadow:setVisible(_visible)
	end
end


function SpineShadow:Destroy()
	if self.mHeropositionhelo then
		SpineDataCacheManager:collectFightSpineByAtlas(self.mHeropositionhelo)
 		self.mHeropositionhelo = nil
	end

	self.mRole = nil
	self.mArmature =  nil
    self.mPerPosX = nil 
    self.mPerPosY = nil
    self.mShadowwidth = nil
    self.mShadowheight = nil
    self:removeFromParent(true)
end

function SpineShadow:Tick()
	-- 检查在什么路况
	self:TickPositionhelo()
	self:setTickZOrder()
end

function SpineShadow:TickPositionhelo()
	if self.mHeropositionhelo then
		self.mHeropositionhelo:setPosition(self:getPosition_pos())
	end
end


function SpineShadow:getPosition_pos()
	return cc.p(self:getPosition())
end

-- 设置人物的ZOrder
function SpineShadow:setTickZOrder()
	if self.mStopTickZorder then return end
	--
	local _y = self:getPositionY()
	
	if self.mRole.mGroup == "friend" or self.mRole.mGroup == "enemyplayer" then
		_y = _y - 5	
	end

	pCall(self.mRole, handler(self.mRole, self.mRole.setLocalZOrder), 1440 - _y)
	self:setLocalZOrder(1440 - (_y + 1))
	if self.mRole.mSpineShadow then
		self.mRole.mSpineShadow:setLocalZOrder(1440 - (_y + 1))
	end

	
end

-- 跟踪人物摄像头
function SpineShadow:setTickCameraRun()
	if self.mRole.IsKeyRole then
		if self.mPerPosX ~= self:getPositionX() then
			local  _dis =  self:getPositionX() - self.mPerPosX
			self:MoveSceneViewHor(_dis)
			self.mPerPosX = self:getPositionX()
		end

		if self.mPerPosY ~= self:getPositionY() then
			self:MoveSceneViewVer(self.mPerPosY,self:getPositionY())
			self.mPerPosY = self:getPositionY()
		end
	end
end

function SpineShadow:MoveTo(_during, _nextPos)
	local function doSomething()
		self:stopTickMove(false)
	end
	self:stopTickMove(true)
	local _ac = cc.MoveTo:create(_during, _nextPos)
	local _ac2 = cc.CallFunc:create(doSomething)
	self:runAction(cc.Sequence:create(_ac, _ac2))
	if self.mRole.mSpineShadow then
		local _ac = cc.MoveTo:create(_during, _nextPos)
		self.mRole.mSpineShadow:runAction(_ac)
	end

end

function SpineShadow:forceSetPosition(_pos)
	self:setPosition(_pos)
end

function SpineShadow:setPositionYAndZorder(_y)
	if _y < 3 then  _y = 3 end
	local _curY = self:getPositionY()
	if _curY == _y then return end
	--
	--self.mArmature:ChangeScaleByPosY(_y)
	self:setPositionY(_y)
	self:setSpineShadowPosY(_y)
end

function SpineShadow:setSpineShadowPosX(_x)
	if self.mRole.mSpineShadow and not self.mRole.mSpineShadow.IsStopTickPosX then
		self.mRole.mSpineShadow:setPositionX(_x)
	end
end

function SpineShadow:setSpineShadowPosY(_y)
	if self.mRole.mSpineShadow and not self.mRole.mSpineShadow.IsStopTickPosY then
		self.mRole.mSpineShadow:setPositionY(_y)
	end
end

function SpineShadow:setPositionXWithCheckReachable(_x)
	local _curX = self:getPositionX()
	if _curX == _x then return end
	--
	--local _scale = self.mArmature.mSpine:getScale()
	--local _offset = 0.25*(_scale-1) * self.mArmature.mSpine:getBoundingBox().width
	--self:setPositionX(_x - _offset)
	self:setPositionX(_x)
	self:setSpineShadowPosX(_x)
end

function SpineShadow:getRect(_pos)
	local _w = self:getContentSize().width
	local _h = self:getContentSize().height
	local _rect = cc.rect(_pos.x - _w/2, _pos.y - _h/2, _w, _h)

	return _rect
end

function SpineShadow:IsSameHorWithRole()
	if self.mRole:getPositionY() > self:getPositionY() then
	   return 1
	elseif self.mRole:getPositionY() < self:getPositionY() then
	   return -1
	else
	   return 0
	end
end

function SpineShadow:GetHorHeight()
	if self.mRole:getPositionY() > self:getPositionY() then
		return self.mRole:getPositionY() - self:getPositionY()
	end
end

function SpineShadow:ShadowChangeScale()
	local rolePosY = self.mRole:getPositionY()
	local shadowY = self:getPositionY()
	local height = rolePosY - shadowY
	if rolePosY > shadowY then
		local scale =  1 - (height)/550
		local xx = 4 
		if scale <= 0 or scale >= 1 then return end
		if self.mRole.mSpineShadow then
			if self.mRole.IsFaceLeft then
				if self.mRole.mSpineShadow.mDynamicShadowConfig then
					if not self.mDycos2 then
						local rad2 = math.rad(self.mRole.mSpineShadow.mDynamicShadowConfig[2])
						self.mDycos2 = math.cos(rad2)
					end
					if not self.mDysin2 then
						local rad2 = math.rad(self.mRole.mSpineShadow.mDynamicShadowConfig[2])
						self.mDysin2 = math.sin(rad2)
					end
					local k1 = self.mRole.mSpineShadow.mDynamicShadowConfig[1]
					self.mRole.mSpineShadow:setPositionX(self.mRole:getShadowPos().x+height*self.mDysin2*k1)
					self.mRole.mSpineShadow:setPositionY(self.mRole:getShadowPos().y+height*self.mDycos2*k1)
				end
			else
				if self.mRole.mSpineShadow.mDynamicShadowConfig then
					if not self.mDycos4 then
						local rad2 = math.rad(self.mRole.mSpineShadow.mDynamicShadowConfig[4])
						self.mDycos4 = math.cos(rad2)
					end
					if not self.mDysin4 then
						local rad2 = math.rad(self.mRole.mSpineShadow.mDynamicShadowConfig[4])
						self.mDysin4 = math.sin(rad2)
					end
					local k1 = self.mRole.mSpineShadow.mDynamicShadowConfig[3]
					self.mRole.mSpineShadow:setPositionX(self.mRole:getShadowPos().x+height*self.mDysin4*k1)
					self.mRole.mSpineShadow:setPositionY(self.mRole:getShadowPos().y+height*self.mDycos4*k1)
				end
			end
		end

		-- self.Shadow:setScaleX(self.mShadowwidth*scale)
		-- self.Shadow:setScaleY(self.mShadowheight*scale)
	end
end

function SpineShadow:ShadowRestoreScale()
	if self.mRole.mSpineShadow then
		if self.mRole.IsFaceLeft then
			self.mRole.mSpineShadow:setScaleX(-1)
			self.mRole.mSpineShadow:setScaleY(self.mRole.mSpineShadow.mScaleY)	
		else
			self.mRole.mSpineShadow:setScaleX(1)
			self.mRole.mSpineShadow:setScaleY(self.mRole.mSpineShadow.mScaleY)	
		end
		if self.mRole.mSpineShadow then
			self.mRole.mSpineShadow:setPosition(self.mRole:getShadowPos())
		end
	end
	-- self.Shadow:setScaleX(self.mShadowwidth)
	-- self.Shadow:setScaleY(self.mShadowheight)
end

function SpineShadow:stopTickZorder(_stoped)
	self.mStopTickZorder = _stoped
end

function SpineShadow:stopTickMove(_stoped)
	self:stopTickMoveX(_stoped)
	self:stopTickMoveY(_stoped)
end

function SpineShadow:stopTickMoveX(_stoped)
	self.mTickMoveSwitchX = not _stoped
end

function SpineShadow:stopTickMoveY(_stoped)
	self.mTickMoveSwitchY = not _stoped
end

function SpineShadow:setFightRolePositionX(_x)
	if self.mTickMoveSwitchX then
		self:setPositionXWithCheckReachable(_x)
	end
end

function SpineShadow:setFightRolePositionY(_y)
	if self.mTickMoveSwitchY then
		local _curX = self.mRole:getPositionX()
		if TiledMoveHandler.CanPosStand(cc.p(_curX,_y),self.mRole.mSceneIndex) then
			self:setPositionYAndZorder(_y)
		end
	end
end


-- 为抓投设置相关
function SpineShadow:setStateForGriped(_griped)
	if _griped then
		self:stopTickMoveY(true)
		self:stopTickZorder(true)
	else
		self:stopTickMoveY(false)
		self:stopTickZorder(false)
	end
end