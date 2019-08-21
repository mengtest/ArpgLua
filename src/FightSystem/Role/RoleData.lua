-- Func: 角色数据,用于存储内存中的数据
-- Author: Johny

RoleData = class("RoleData")

function RoleData:ctor(_instanceID, _group, _roleID, _pos,_index)
	self.mGSFlag = 0
	self.mGSMainSub = 0
	self.mGSID1 = 0
	self.mGSID2 = 0
	self.mPosIndex = 0 -- 仅队伍中的人有值
	self.mNormalSkillMaxCount = 4
	self.mAdvanceLevel = 0
	self.WeaponCrit = 0
	self.WeaponSkillLevel = 0
	self.Old_Replace_New_skillTable = {}
	self.New_Replace_Old_skillTable = {}

	self.AddEnergySkill = {}

	self.CoolTimeSkill = {}

	self.PerHurtSkill = {}
	-- 初始化
	self:Init(_instanceID, _group, _roleID,_pos,_index)

end

function RoleData:Init(_instanceID, _group, _roleID, _pos ,index)
	self.mInstanceID = _instanceID
	self.mGroup = _group
	self.mBornPos = _pos
	if _group == "monster" then
		self:InitMonster(_roleID,index)
	elseif _group == "bossmonster" then
		self.mGroup = "monster"
		self:InitBossMonster(_roleID,index)
	elseif _group == "enemyplayer" then
		self:InitEnenyPlayer(_roleID)
	elseif _group == "friend" then
		self:InitFriend(_roleID)
	elseif _group == "cgfriend" then
	    self:InitCGFriend(_roleID)
	elseif _group == "cgmonster" then
		self:InitCGMonster(_roleID)
	elseif _group == "summonfriend" then
	    self:InitMonster(_roleID)
	elseif _group == "summonmonster" then
		self:InitMonster(_roleID)
	elseif _group == "hallrole" then
		self:InitHallRole(_roleID)
	elseif _group == "publicshowrole" then
		self:InitPublicShowRole(_roleID)
	end
end

function RoleData:InitPublicShowRole(_heroID)
local _infoDB = DB_HeroConfig.getDataById(_heroID)
	self.mName = _infoDB.Name
	self.mModel = _infoDB.ResouceID
	self.mModelScale = _infoDB.ResouceZoom
	self.mSimpleModel = _infoDB.SimpleResouceID
	self.mSimpleModelScale = _infoDB.SimpleResouceZoom
	self.mInfoDB = _infoDB
	self.mRole_AIConfig = _infoDB.Role_AIConfig
	self.mModelEffectID = _infoDB.ModelEffectID
	self.mSimpleModelEffectID = _infoDB.SimpleModelEffectID

	-- sound
	self.mSoundList = _infoDB.SoundList
	--属性
	self.mHP = 0
	self.mPhyAtt = 0
	self.mExpose = 0
	self.mArmor = 0
	self.mHit = 0
	self.mDodge = 0
	self.mCrit = 0
	self.mTough = 0
	self.mAttRate = 0
	self.mSpeed = 12 * MathExt._game_frame -- tmp
	self.mJump = 0
	self.mMaxHP = self.mHP
end

function RoleData:InitHallRole(_heroID)
	local _infoDB = DB_HeroConfig.getDataById(_heroID)
	self.mName = _infoDB.Name
	self.mModel = _infoDB.ResouceID
	self.mModelScale = _infoDB.ResouceZoom
	self.mSimpleModel = _infoDB.SimpleResouceID
	self.mSimpleModelScale = _infoDB.SimpleResouceZoom
	self.mInfoDB = _infoDB
	self.mRole_AIConfig = _infoDB.Role_AIConfig

	self.mModelEffectID = _infoDB.ModelEffectID
	self.mSimpleModelEffectID = _infoDB.SimpleModelEffectID

	-- sound
	self.mSoundList = _infoDB.SoundList
	--属性
	self.mHP = 0
	self.mPhyAtt = 0
	self.mExpose = 0
	self.mArmor = 0
	self.mHit = 0
	self.mDodge = 0
	self.mCrit = 0
	self.mTough = 0
	self.mAttRate = 0
	self.mSpeed = 12 * MathExt._game_frame -- tmp
	self.mJump = 0
	self.mMaxHP = self.mHP
end

function RoleData:InitMonster(_monsterID ,_Index)
	if _Index then
		self.mPosIndex = _Index
	end
	local _infoDB = DB_MonsterConfig.getDataById(_monsterID)
	self.mMonsterID = _monsterID
	self.mName = _infoDB.Name
	self.mModel = _infoDB.Monster_Model
	self.mModelScale = _infoDB.Monster_ModelZoom
	self.mSimpleModel = _infoDB.Monster_SimpleModel
	self.mSimpleModelScale = _infoDB.Monster_SimpleModelZoom
	self.mInfoDB = _infoDB
	self.mRole_AIConfig = _infoDB.Monster_AIStrategy
	self.mModelEffectID = _infoDB.Monster_ModelEffectID
	self.mSimpleModelEffectID = _infoDB.Monster_SimpleModelEffectID


	self.mSight = _infoDB.Monster_Sight
	-- sound
	self.mSoundList = _infoDB.SoundList
	--技能
	local function setSkill()
		self.mRole_NormalSkill1 = _infoDB.Monster_NormalSkill1
		self.mRole_NormalSkill2 = _infoDB.Monster_NormalSkill2
		self.mRole_NormalSkill3 = _infoDB.Monster_NormalSkill3
		self.mRole_NormalSkill4 = _infoDB.Monster_NormalSkill4
		self.mRole_SpecialSkill1 = _infoDB.Monster_SpecialSkill1
		self.mRole_SpecialSkill2 = _infoDB.Monster_SpecialSkill2
		self.mRole_SpecialSkill3 = _infoDB.Monster_SpecialSkill3
		self.mRole_SpecialSkill4 = _infoDB.Monster_SpecialSkill4
		self.mRole_PassiveSkill1 = _infoDB.Monster_PassiveSkill1
		self.mRole_PassiveSkill2 = _infoDB.Monster_PassiveSkill2
		self.mRole_PassiveSkill3 = _infoDB.Monster_PassiveSkill3
		self.mRole_PassiveSkill4 = _infoDB.Monster_PassiveSkill4
	end
	--属性
	local function setProp()
		self.mHP = _infoDB.Monster_MaxHP
		self.mPhyAtt = _infoDB.Monster_PhyAttack
		self.mExpose = _infoDB.Monster_ArmorPene
		self.mArmor = _infoDB.Monster_Armor
		self.mHit = _infoDB.Monster_Hit
		self.mDodge = _infoDB.Monster_Dodge
		self.mCrit = _infoDB.Monster_Crit
		self.mTough = _infoDB.Monster_Tenacity
		self.mAttRate = _infoDB.Monster_AttackSpeed
		self.mSpeed = _infoDB.Monster_MoveSpeed / 125 * MathExt._game_frame
		self.mJump = _infoDB.Monster_JumpHeight
	end
	--
	setSkill()
	setProp()
	self.mMaxHP = self.mHP
end

function RoleData:InitEnenyPlayer(_posIndex)
    self.mPosIndex = _posIndex
    local _heroID = globaldata:getBattleEnemyFormationInfoByIndexAndKey(_posIndex, "id")
    local _skill = globaldata:getBattleEnemyFormationInfoByIndexAndKey(_posIndex, "skillList")
    local _prop = globaldata:getBattleEnemyFormationInfoByIndexAndKey(_posIndex, "propList")
	local _infoDB = DB_HeroConfig.getDataById(_heroID)
	self.mName = _infoDB.Name
	self.mModel = _infoDB.ResouceID
	self.mModelScale = _infoDB.ResouceZoom
	self.mSimpleModel = _infoDB.SimpleResouceID
	self.mSimpleModelScale = _infoDB.SimpleResouceZoom
	self.mInfoDB = _infoDB
	self.mRole_AIConfig = _infoDB.Role_AIConfig
	self.mModelEffectID = _infoDB.ModelEffectID
	self.mSimpleModelEffectID = _infoDB.SimpleModelEffectID
	self.mAdvanceLevel = globaldata:getBattleEnemyFormationInfoByIndexAndKey(_posIndex, "advanceLevel")
	-- sound
	self.mSoundList = _infoDB.SoundList
	--技能
	local function setSkill()

		self.mRole_NormalSkill1 = _skill["Role_NormalSkill1"]
		self.mRole_NormalSkill2 = _skill["Role_NormalSkill2"]
		self.mRole_NormalSkill3 = _skill["Role_NormalSkill3"]
		self.mRole_NormalSkill4 = _skill["Role_NormalSkill4"]
		self.mRole_SpecialSkill1 = _skill["Role_SpecialSkill1"]
		self.mRole_SpecialSkill2 = _skill["Role_SpecialSkill2"]
		self.mRole_SpecialSkill3 = _skill["Role_SpecialSkill3"]
		self.mRole_SpecialSkill4 = _skill["Role_SpecialSkill4"]

		self.mRole_NormalSkill1 = self:ChangeNewWeapSkillById(self.mRole_NormalSkill1)
		self.mRole_NormalSkill2 = self:ChangeNewWeapSkillById(self.mRole_NormalSkill2)
		self.mRole_NormalSkill3 = self:ChangeNewWeapSkillById(self.mRole_NormalSkill3)
		self.mRole_NormalSkill4 = self:ChangeNewWeapSkillById(self.mRole_NormalSkill4)
		self.mRole_SpecialSkill1 = self:ChangeNewWeapSkillById(self.mRole_SpecialSkill1)
		self.mRole_SpecialSkill2 = self:ChangeNewWeapSkillById(self.mRole_SpecialSkill2)
		self.mRole_SpecialSkill3 = self:ChangeNewWeapSkillById(self.mRole_SpecialSkill3)
		self.mRole_SpecialSkill4 = self:ChangeNewWeapSkillById(self.mRole_SpecialSkill4)

		

		self.mRole_SpecialSkillActivate1 = _skill["Role_SpecialSkillActivate1"]
		self.mRole_SpecialSkillActivate2 = _skill["Role_SpecialSkillActivate2"]
		self.mRole_SpecialSkillActivate3 = _skill["Role_SpecialSkillActivate3"]
		self.mRole_SpecialSkillActivate4 = _skill["Role_SpecialSkillActivate4"]

		self.mRole_NormalSkillLevel1 = _skill["Role_NormalSkill1_Level"]
		self.mRole_SpecialSkillLevel1 = _skill["Role_SpecialSkillActivate1_Level"]
		self.mRole_SpecialSkillLevel2 = _skill["Role_SpecialSkillActivate2_Level"]
		self.mRole_SpecialSkillLevel3 = _skill["Role_SpecialSkillActivate3_Level"]
		self.mRole_SpecialSkillLevel4 = _skill["Role_SpecialSkillActivate4_Level"]

		self.mRoleNormalSkill_LevelList = {}
		self.mRoleNormalSkill_LevelList[self.mRole_NormalSkill1] = self.mRole_NormalSkillLevel1
		self.mRoleNormalSkill_LevelList[self.mRole_NormalSkill2] = self.mRole_NormalSkillLevel1
		self.mRoleNormalSkill_LevelList[self.mRole_NormalSkill3] = self.mRole_NormalSkillLevel1
		self.mRoleNormalSkill_LevelList[self.mRole_NormalSkill4] = self.mRole_NormalSkillLevel1
		self.mRoleNormalSkill_LevelList[self.mRole_SpecialSkill1] = self.mRole_SpecialSkillLevel1
		self.mRoleNormalSkill_LevelList[self.mRole_SpecialSkill2] = self.mRole_SpecialSkillLevel2
		self.mRoleNormalSkill_LevelList[self.mRole_SpecialSkill3] = self.mRole_SpecialSkillLevel3
		self.mRoleNormalSkill_LevelList[self.mRole_SpecialSkill4] = self.mRole_SpecialSkillLevel4

		if self.mRole_NormalSkill4 == 0 then
			self.mNormalSkillMaxCount = 3
		end
		self.mSpecialSkillTable = {}
		for i=1,4 do
			local SpecialSkill = string.format("mRole_SpecialSkill%d",i)
			local SpecialSkillActivate = string.format("mRole_SpecialSkillActivate%d",i)
			self.mSpecialSkillTable[self[SpecialSkill]] = self[SpecialSkillActivate]
		end
		self.mRole_PassiveSkill1 = _skill["Role_PassiveSkill1"]
		self.mRole_PassiveSkill2 = _skill["Role_PassiveSkill2"]
		self.mRole_PassiveSkill3 = _skill["Role_PassiveSkill3"]
		self.mRole_PassiveSkill4 = _skill["Role_PassiveSkill4"]
		self.mRole_DodgeSkill = _skill["Role_DodgeSkill"]
		self.mGSID1 = _skill["Role_GroupSkill1"]
		self.mGSID2 = _skill["Role_GroupSkill2"]
		self.mGSMainSub = _skill["Role_GroupMainSubFlag"]
		self.mGSFlag = _skill["Role_GroupSkillFlag"]
	end
	--属性
	local function setProp()
		self.mHP = _prop[0]
		self.mPhyAtt = _prop[1]
		self.mExpose = _prop[2]
		self.mArmor = _prop[3]
		self.mHit = _prop[4]
		self.mDodge = _prop[5]
		self.mCrit = _prop[6]
		self.mTough = _prop[7]
		self.mAttRate = _prop[8]
		self.mSpeed = _prop[9] / 125 * MathExt._game_frame
		self.mJump = _prop[10]
	end
	--
	self:InitWeaponSkill(_heroID,_skill)
	setSkill()
	setProp()
	self.mMaxHP = self.mHP
	if FightSystem.mFightType == "arena" and globaldata.PvpType == "brave" then
		self.mHP = globaldata:getBattleEnemyFormationInfoByIndexAndKey(_posIndex, "braveCurHp")
	end
end

function RoleData:InitWeaponSkill(_heroID,_skilllist)
	if _skilllist["SkillWeaponLevel"] then
		self.WeaponSkillLevel = _skilllist["SkillWeaponLevel"]
	end
	local HeroWeaponData = DB_HeroWeapon.getDataById(_heroID)
	for i=1,self.WeaponSkillLevel do
		local wkId = HeroWeaponData[string.format("Skill%d",i)]
		local WkData = DB_Weapon_Skill.getDataById(wkId)

		if WkData.Type == 2 then
			self.WeaponCrit = WkData["Param1"]/1000
		elseif WkData.Type == 4 then
			self.Old_Replace_New_skillTable[WkData["Param1"]] = WkData["Param2"]
			self.New_Replace_Old_skillTable[WkData["Param2"]] = WkData["Param1"]
		elseif WkData.Type == 5 then
			self.AddEnergySkill[WkData["Param1"]] = WkData["Param2"]
		elseif WkData.Type == 6 then
			self.CoolTimeSkill[WkData["Param1"]] = WkData["Param2"]
		elseif WkData.Type == 7 then
			self.PerHurtSkill[WkData["Param1"]] = WkData["Param2"]/1000
		end
	end
end

function RoleData:ChangeNewWeapSkillById(_oldskillId)
	if self.Old_Replace_New_skillTable[_oldskillId] then
		return self.Old_Replace_New_skillTable[_oldskillId]
	end
	return _oldskillId
end

function RoleData:ChangeOldWeapSkillById(_newskillId)
	if self.New_Replace_Old_skillTable[_newskillId] then
		return self.New_Replace_Old_skillTable[_newskillId]
	end
	return _newskillId
end

function RoleData:AddEnergyWeapSkillById(_newskillId)
	local oldskill = self:ChangeOldWeapSkillById(_newskillId)
	if self.AddEnergySkill[oldskill] then
		return self.AddEnergySkill[oldskill]
	end
	return 0
end

function RoleData:CoolTimeWeapSkillById(_newskillId)
	local oldskill = self:ChangeOldWeapSkillById(_newskillId)
	if self.CoolTimeSkill[oldskill] then
		return self.CoolTimeSkill[oldskill]
	end
	return 0
end

function RoleData:PerHurtWeapSkillById(_newskillId)
	if not _newskillId then return 0 end
	local oldskill = self:ChangeOldWeapSkillById(_newskillId)
	if self.PerHurtSkill[oldskill] then
		return self.PerHurtSkill[oldskill]
	end
	return 0
end

function RoleData:SkillLevelById(_skill)
	if self.mRoleNormalSkill_LevelList and  self.mRoleNormalSkill_LevelList[_skill] then
		return self.mRoleNormalSkill_LevelList[_skill]
	end
	return 1
end

function RoleData:InitBossMonster(_posIndex)
    local _heroID = globaldata:getBattleEnemyFormationInfoByIndexAndKey(_posIndex, "id")
    local _skill = globaldata:getBattleEnemyFormationInfoByIndexAndKey(_posIndex, "skillList")
    local _prop = globaldata:getBattleEnemyFormationInfoByIndexAndKey(_posIndex, "propList")

    local _infoDB = DB_MonsterConfig.getDataById(_heroID)
	self.mMonsterID = _monsterID
	self.mName = _infoDB.Name
	self.mModel = _infoDB.Monster_Model
	self.mModelScale = _infoDB.Monster_ModelZoom
	self.mSimpleModel = _infoDB.Monster_SimpleModel
	self.mSimpleModelScale = _infoDB.Monster_SimpleModelZoom
	self.mInfoDB = _infoDB
	self.mRole_AIConfig = _infoDB.Monster_AIStrategy
	self.mModelEffectID = _infoDB.Monster_ModelEffectID
	self.mSimpleModelEffectID = _infoDB.Monster_SimpleModelEffectID
	self.mSight = _infoDB.Monster_Sight
	-- sound
	self.mSoundList = _infoDB.SoundList
	--技能
	local function setSkill()
		self.mRole_NormalSkill1 = _infoDB.Monster_NormalSkill1
		self.mRole_NormalSkill2 = _infoDB.Monster_NormalSkill2
		self.mRole_NormalSkill3 = _infoDB.Monster_NormalSkill3
		self.mRole_NormalSkill4 = _infoDB.Monster_NormalSkill4
		self.mRole_SpecialSkill1 = _infoDB.Monster_SpecialSkill1
		self.mRole_SpecialSkill2 = _infoDB.Monster_SpecialSkill2
		self.mRole_SpecialSkill3 = _infoDB.Monster_SpecialSkill3
		self.mRole_SpecialSkill4 = _infoDB.Monster_SpecialSkill4
		self.mRole_PassiveSkill1 = _infoDB.Monster_PassiveSkill1
		self.mRole_PassiveSkill2 = _infoDB.Monster_PassiveSkill2
		self.mRole_PassiveSkill3 = _infoDB.Monster_PassiveSkill3
		self.mRole_PassiveSkill4 = _infoDB.Monster_PassiveSkill4
	end
	--属性
	local function setProp()
		self.mHP = _prop[0]
		self.mPhyAtt = _prop[1]
		self.mExpose = _prop[2]
		self.mArmor = _prop[3]
		self.mHit = _prop[4]
		self.mDodge = _prop[5]
		self.mCrit = _prop[6]
		self.mTough = _prop[7]
		self.mAttRate = _prop[8]
		self.mSpeed = _prop[9] / 125 * MathExt._game_frame
		self.mJump = _prop[10]
	end
	--
	setSkill()
	setProp()
	self.mMaxHP = self.mHP
end

function RoleData:IsSkillActivateById(_skillid)
	if self.mSpecialSkillTable then
		if self.mSpecialSkillTable[_skillid] == 0 then
			return false
		end
		return true
	end
	return true
end

function RoleData:InitFriend(_posIndex)
    self.mPosIndex = _posIndex
    local _heroID = globaldata:getBattleFormationInfoByIndexAndKey(_posIndex, "id")
    local _skill = globaldata:getBattleFormationInfoByIndexAndKey(_posIndex, "skillList")
    local _prop = globaldata:getBattleFormationInfoByIndexAndKey(_posIndex, "propList")
	local _infoDB = DB_HeroConfig.getDataById(_heroID)
	self.mName = _infoDB.Name
	self.mModel = _infoDB.ResouceID
	self.mModelScale = _infoDB.ResouceZoom
	self.mSimpleModel = _infoDB.SimpleResouceID
	self.mSimpleModelScale = _infoDB.SimpleResouceZoom
	self.mInfoDB = _infoDB
	self.mGroupMainSubFlag = self.mInfoDB.Role_GroupMainSubFlag
	self.mRole_AIConfig = _infoDB.Role_AIConfig
	self.mModelEffectID = _infoDB.ModelEffectID
	self.mSimpleModelEffectID = _infoDB.SimpleModelEffectID
	self.mAdvanceLevel = globaldata:getBattleFormationInfoByIndexAndKey(_posIndex, "advanceLevel")
	-- sound
	self.mSoundList = _infoDB.SoundList
	--技能
	local function setSkill()
		self.mRole_NormalSkill1 = _skill["Role_NormalSkill1"]
		self.mRole_NormalSkill2 = _skill["Role_NormalSkill2"]
		self.mRole_NormalSkill3 = _skill["Role_NormalSkill3"]
		self.mRole_NormalSkill4 = _skill["Role_NormalSkill4"]
		self.mRole_SpecialSkill1 = _skill["Role_SpecialSkill1"]
		self.mRole_SpecialSkill2 = _skill["Role_SpecialSkill2"]
		self.mRole_SpecialSkill3 = _skill["Role_SpecialSkill3"]
		self.mRole_SpecialSkill4 = _skill["Role_SpecialSkill4"]

		self.mRole_NormalSkill1 = self:ChangeNewWeapSkillById(self.mRole_NormalSkill1)
		self.mRole_NormalSkill2 = self:ChangeNewWeapSkillById(self.mRole_NormalSkill2)
		self.mRole_NormalSkill3 = self:ChangeNewWeapSkillById(self.mRole_NormalSkill3)
		self.mRole_NormalSkill4 = self:ChangeNewWeapSkillById(self.mRole_NormalSkill4)
		self.mRole_SpecialSkill1 = self:ChangeNewWeapSkillById(self.mRole_SpecialSkill1)
		self.mRole_SpecialSkill2 = self:ChangeNewWeapSkillById(self.mRole_SpecialSkill2)
		self.mRole_SpecialSkill3 = self:ChangeNewWeapSkillById(self.mRole_SpecialSkill3)
		self.mRole_SpecialSkill4 = self:ChangeNewWeapSkillById(self.mRole_SpecialSkill4)

		self.mRole_SpecialSkillActivate1 = _skill["Role_SpecialSkillActivate1"]
		self.mRole_SpecialSkillActivate2 = _skill["Role_SpecialSkillActivate2"]
		self.mRole_SpecialSkillActivate3 = _skill["Role_SpecialSkillActivate3"]
		self.mRole_SpecialSkillActivate4 = _skill["Role_SpecialSkillActivate4"]

		debugLog("self.mRole_SpecialSkillActivate1====" .. self.mRole_SpecialSkillActivate1 .."========" .. self.mRole_SpecialSkill1)
		debugLog("self.mRole_SpecialSkillActivate2====" .. self.mRole_SpecialSkillActivate2.."========" .. self.mRole_SpecialSkill2)
		debugLog("self.mRole_SpecialSkillActivate3====" .. self.mRole_SpecialSkillActivate3.."========" .. self.mRole_SpecialSkill3)
		debugLog("self.mRole_SpecialSkillActivate4====" .. self.mRole_SpecialSkillActivate4.."========" .. self.mRole_SpecialSkill4)

		self.mRole_NormalSkillLevel1 = _skill["Role_NormalSkill1_Level"]
		self.mRole_SpecialSkillLevel1 = _skill["Role_SpecialSkillActivate1_Level"]
		self.mRole_SpecialSkillLevel2 = _skill["Role_SpecialSkillActivate2_Level"]
		self.mRole_SpecialSkillLevel3 = _skill["Role_SpecialSkillActivate3_Level"]
		self.mRole_SpecialSkillLevel4 = _skill["Role_SpecialSkillActivate4_Level"]

		self.mRoleNormalSkill_LevelList = {}
		self.mRoleNormalSkill_LevelList[self.mRole_NormalSkill1] = self.mRole_NormalSkillLevel1
		self.mRoleNormalSkill_LevelList[self.mRole_NormalSkill2] = self.mRole_NormalSkillLevel1
		self.mRoleNormalSkill_LevelList[self.mRole_NormalSkill3] = self.mRole_NormalSkillLevel1
		self.mRoleNormalSkill_LevelList[self.mRole_NormalSkill4] = self.mRole_NormalSkillLevel1
		self.mRoleNormalSkill_LevelList[self.mRole_SpecialSkill1] = self.mRole_SpecialSkillLevel1
		self.mRoleNormalSkill_LevelList[self.mRole_SpecialSkill2] = self.mRole_SpecialSkillLevel2
		self.mRoleNormalSkill_LevelList[self.mRole_SpecialSkill3] = self.mRole_SpecialSkillLevel3
		self.mRoleNormalSkill_LevelList[self.mRole_SpecialSkill4] = self.mRole_SpecialSkillLevel4


		self.mSpecialSkillTable = {}
		if self.mRole_NormalSkill4 == 0 then
			self.mNormalSkillMaxCount = 3
		end
		for i=1,4 do
			local SpecialSkill = string.format("mRole_SpecialSkill%d",i)
			local SpecialSkillActivate = string.format("mRole_SpecialSkillActivate%d",i)
			self.mSpecialSkillTable[self[SpecialSkill]] = self[SpecialSkillActivate]
		end
		self.mRole_PassiveSkill1 = _skill["Role_PassiveSkill1"]
		self.mRole_PassiveSkill2 = _skill["Role_PassiveSkill2"]
		self.mRole_PassiveSkill3 = _skill["Role_PassiveSkill3"]
		self.mRole_PassiveSkill4 = _skill["Role_PassiveSkill4"]
		self.mRole_DodgeSkill = _skill["Role_DodgeSkill"]
		self.mGSID1 = _skill["Role_GroupSkill1"]
		self.mGSID2 = _skill["Role_GroupSkill2"]
		self.mGSMainSub = _skill["Role_GroupMainSubFlag"]
		self.mGSFlag = _skill["Role_GroupSkillFlag"]
	end
	--属性
	local function setProp()
		self.mHP = _prop[0]
		self.mPhyAtt = _prop[1]
		self.mExpose = _prop[2]
		self.mArmor = _prop[3]
		self.mHit = _prop[4]
		self.mDodge = _prop[5]
		self.mCrit = _prop[6]
		self.mTough = _prop[7]
		self.mAttRate = _prop[8]
		self.mSpeed = _prop[9] / 125 * MathExt._game_frame
		self.mJump = _prop[10]
	end
	--
	self:InitWeaponSkill(_heroID,_skill)
	setSkill()
	setProp()
	self.mMaxHP = self.mHP
	if FightSystem.mFightType == "arena" and globaldata.PvpType == "brave" then
		self.mHP = globaldata:getBattleFormationInfoByIndexAndKey(_posIndex, "braveCurHp")
	end
end

function RoleData:InitCGFriend(_heroID)
	local _infoDB = DB_HeroConfig.getDataById(_heroID)
	self.mName = _infoDB.Name
	self.mModel = _infoDB.ResouceID
	self.mModelScale = _infoDB.ResouceZoom
	self.mSimpleModel = _infoDB.SimpleResouceID
	self.mSimpleModelScale = _infoDB.SimpleResouceZoom
	self.mInfoDB = _infoDB
	self.Role_AIConfig = _infoDB.Role_AIConfig
	self.mModelEffectID = _infoDB.ModelEffectID
	self.mSimpleModelEffectID = _infoDB.SimpleModelEffectID
	-- sound
	self.mSoundList = _infoDB.SoundList
	--属性
	self.mHP = 0
	self.mPhyAtt = 0
	self.mExpose = 0
	self.mArmor = 0
	self.mHit = 0
	self.mDodge = 0
	self.mCrit = 0
	self.mTough = 0
	self.mAttRate = 0
	self.mSpeed = 8 * MathExt._game_frame
	self.mJump = 10
	self.mMaxHP = self.mHP
end

function RoleData:InitCGMonster(_monsterID)
	local _infoDB = DB_MonsterConfig.getDataById(_monsterID)
	self.mName = _infoDB.Name
	self.mModel = _infoDB.Monster_Model
	self.mModelScale = _infoDB.Monster_ModelZoom
	self.mSimpleModel = _infoDB.Monster_SimpleModel
	self.mSimpleModelScale = _infoDB.Monster_SimpleModelZoom
	self.mInfoDB = _infoDB
	self.mRole_AIConfig = _infoDB.Monster_AIStrategy
	self.mSight = _infoDB.Monster_Sight
	self.mModelEffectID = _infoDB.Monster_ModelEffectID
	self.mSimpleModelEffectID = _infoDB.Monster_SimpleModelEffectID
	-- sound
	self.mSoundList = _infoDB.SoundList
	--属性
	self.mHP = 0
	self.mPhyAtt = 0
	self.mExpose = 0
	self.mArmor = 0
	self.mHit = 0
	self.mDodge = 0
	self.mCrit = 0
	self.mTough = 0
	self.mAttRate = 0
	self.mSpeed = 4 * MathExt._game_frame
	self.mJump = 10
	self.mMaxHP = self.mHP
end

-- 设置字段
function RoleData:setField(_key, _value)
	self[_key] = _value
end