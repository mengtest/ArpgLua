-- Func: 开枪控制器
-- Author: tuanzhang

GunController = class("GunController")


function GunController:ctor(_role)
	self.mRole = _role
	self.mUseMaxCount = 0
	self.mCurUseCount = 0
	self.mDB = nil
	self.isHaveGun = false
	self.isEquip = false
	if self.mRole.mGroup == "friend" then
		if globaldata.fashionEquipList[2] then
			local HorseKey = string.format("FashionHorseID%d",globaldata.fashionEquipList[2][2]) 
			local HorseID = DB_FashionEquip.getDataById(globaldata.fashionEquipList[2][1])[HorseKey]
			self.mDB = DB_HorseConfig.getDataById(HorseID)
		end
	end
	if self.mDB then
		self.mUseMaxCount = self.mDB.BindingMaxUseCount
		if not FightSystem.mRoleManager.mFriendBulletCount then
			FightSystem.mRoleManager.mFriendBulletCount = self.mUseMaxCount
		end
		self.mCurUseCount = self.mDB.BindingMaxUseCount
		self.mBindSkill = self.mDB.BindNormalAttack
		self.mFashionWeaponIndex = self.mDB.FashionWeaponIndex
		self.isHaveGun = true
	else
		self.isHaveGun = false
	end
	self.mArmature = _role.mArmature
end

function GunController:Destroy()
	self.mRole = nil
	self.mUseMaxCount = nil
	self.mCurUseCount = nil
	self.mFashionWeaponIndex = nil
	self.isHaveGun = nil
	self.mCurweaponId = nil
end

function GunController:Tick()

end

function GunController:EquipedGun()
	if not self.isHaveGun then return false end
	if self.isEquip then return true end
	if FightSystem.mRoleManager.mFriendBulletCount > 0 then
		self.isEquip = true
		SpineDataCacheManager:collectFightSpineByAtlas(self.mArmature.mSpine)
		self.mArmature.mSpine = SpineDataCacheManager:getFightSpineByAtlasWeapon(self.mRole.mArmature.mJson,self.mRole.mArmature.mAtlas,self.mDB.ID,self.mRole.mArmature.mScale,self.mArmature)
		self:resetRole()
		return true
	end
	return false
end

function GunController:UnloadGun()
	if not self.isHaveGun then return false end
	if not self.isEquip then return true end
	FightSystem.mTouchPad:setCheckWeapon(false)
	SpineDataCacheManager:collectFightSpineByAtlas(self.mArmature.mSpine)
	self.mArmature.mSpine = SpineDataCacheManager:getFightSpineByatlas(self.mRole.mArmature.mJson,self.mRole.mArmature.mAtlas,self.mRole.mArmature.mScale,self.mArmature)
	self.isEquip = false
	self:resetRole()
	return true
end

function GunController:FightEquipedGun()
	if not self.isHaveGun then return false end
	if self.isEquip then return true end
	if FightSystem.mRoleManager.mFriendBulletCount > 0 then
		self.isEquip = true
		self:resetRole()
		self.mRole:AddBuff(197)
		self.mRole:AddBuff(198)
		return true
	end
	return false
end

function GunController:FightUnloadGun()
	if not self.isHaveGun then return false end
	if not self.isEquip then return true end
	FightSystem.mTouchPad:setCheckWeapon(false)
	self.isEquip = false
	self:resetRole()
	self.mRole:removeBuffByID(197)
	self.mRole:removeBuffByID(198)
	return true
end

function GunController:ShowRoleEquipedByGunId(_id)
	local db = DB_HorseConfig.getDataById(_id)
	if not db then return end
	SpineDataCacheManager:collectFightSpineByAtlas(self.mArmature.mSpine)
	self.mArmature.mSpine = SpineDataCacheManager:getFightSpineByAtlasWeapon(self.mRole.mArmature.mJson,self.mRole.mArmature.mAtlas,db.ID,self.mRole.mArmature.mScale,self.mArmature)
	self.mArmature.mSpine:setAnimation(0, "bindStand3", true)
	self.isEquip = true
	self.mCurweaponId = _id
	self:resetRole()
end

function GunController:resetRole()
	if self.mRole.mFSM:IsIdle() then
		if self.isEquip then	
			self.mArmature:ActionNow("bindStand3",true)
		else
			self.mArmature:ActionNow("stand",true)
		end
	elseif self.mRole.mFSM:IsRuning() then
		if self.isEquip then
			self.mArmature:ActionNow("bindRun3",true)
		else
			self.mArmature:ActionNow("run",true)
		end
	end
end

function GunController:getCentshoot()
	if self.isHaveGun then
		return FightSystem.mRoleManager.mFriendBulletCount/self.mUseMaxCount *100
	else
		return 0
	end
end

function GunController:playShootSkill()
	if self.isHaveGun and self.isEquip and FightSystem.mRoleManager.mFriendBulletCount > 0 then
		self.mRole:PlaySkillByID(self.mDB.BindNormalAttack, "shoot_hit")
		return true
	end
	return false
end

------------------------------------------------------------------------------------
--[[
   开枪回调
]]
function GunController:decreaseUseCount(count,isloop)
	FightSystem.mRoleManager.mFriendBulletCount = FightSystem.mRoleManager.mFriendBulletCount - count
	if FightSystem.mRoleManager.mFriendBulletCount <= 0 then
		if not isloop then
			self:FightUnloadGun()
		end
	end
end


