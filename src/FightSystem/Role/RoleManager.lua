-- Name: RoleManager
-- Func: 战斗角色管理器
-- Author: Johny

require "FightSystem/Fuben/MonsterObject"
require "FightSystem/Role/RoleData"
require "FightSystem/Role/FightRole"
require "FightSystem/Role/SceneAni"
require "FightSystem/Role/SkillGroup/EffectController"



RoleManager = {}
-- 己方队伍
RoleManager.mFriendRoles = {}
-- 敌人队伍
RoleManager.mEnemyRoles = {}
-- 道具列表
RoleManager.mSceneAniList = {}

-- 己方队伍
RoleManager.mFriendRolesTeam = {}
-- 敌人队伍
RoleManager.mEnemyRolesTeam = {}
-- 道具列表
RoleManager.mSceneAniListTeam = {}

function RoleManager:Init()
	self.mEnemyInstanceIDCounter = 0
	self.mFriendInstanceIDCounter = 0
	self.mSceneAniInstanceIDCounter = 0
	self.keyRoleTempId = {id = 0,group = ""}
end

function RoleManager:Release()
	--
	_G["RoleManager"] = nil
  	package.loaded["RoleManager"] = nil
  	package.loaded["FightSystem/Role/RoleManager"] = nil
end

function RoleManager:Tick(delta)
	for index,role in pairs(self.mFriendRoles) do
		role:Tick(delta)
	end

	for index,role in pairs(self.mEnemyRoles) do
		role:Tick(delta)
	end

	for index,obj in pairs(self.mSceneAniList) do
		obj:Tick()
	end
end

function RoleManager:UnloadRoles()
	self.mManagerAIState = nil
	self.mEnemyInstanceIDCounter = 0
	self.mFriendInstanceIDCounter = 0
	self.mSceneAniInstanceIDCounter = 0
	self.mFriendBulletCount = nil
	self.mIsFriendfollow = nil
	for index,role in pairs(self.mFriendRoles) do
		role:Destroy()
	end

	for index,role in pairs(self.mEnemyRoles) do
		role:Destroy()
	end
	self.mFriendRoles = {}
	self.mEnemyRoles = {}
	self.mFriendRolesTeam = {}
	-- 敌人队伍
	self.mEnemyRolesTeam = {}
end

-- 移除所有敌人
function RoleManager:removeAllEnemy()
	-- 测试用的
	for index,role in ipairs(self.mEnemyRoles) do
		role:Destroy()
		local group = role.mGroup
		local pos = role:getPosition_pos()
		local monsterId = role.mRoleData.mMonsterID
		FightSystem.mFubenManager:OnRoleKilled(group, pos,monsterId)
	end	
	self.mEnemyRoles = {}
	self.mEnemyRolesTeam = {}
end

-- 怪物死亡全体飞出
function RoleManager:removeAllFlyEnemy()
	-- 测试用的
	for index,role in ipairs(self.mEnemyRoles) do
		if role.mPropertyCon.mCurHP > 0 then
			if role.mGroup == "monster" and role.mRoleData.mInfoDB.Monster_Type == 2 then
				role.mFSM:ForceChangeToState("dead")
   				role:RemoveSelf()
			else
				role.mPropertyCon.mCurHP = 0
				role.mPropertyCon:handleDead(nil,true)
			end
		end	
	end
end

-- 人物死亡全体飞出
function RoleManager:removeAllFlyFriend()
	-- 测试用的
	for index,role in ipairs(self.mFriendRoles) do
		if role.mPropertyCon.mCurHP > 0 then
			role.mPropertyCon.mCurHP = 0
			role.mPropertyCon:handleDead(nil,true)
		end	
	end
end


-- 移除角色
function RoleManager:RemoveRoleByIdx(_group, _id)
   if _group == "monster" then
   	  	for index,role in ipairs(self.mEnemyRoles) do
			if role.mInstanceID == _id then
			   FightSystem.mTouchPad:OnMonsterDead(role)
			   role:Destroy()
			   table.remove(self.mEnemyRoles,index)
			return end
		end
   elseif _group == "friend" then
   	    -- 友军死亡移除
   		for index,role in ipairs(self.mFriendRoles) do
			if role.mInstanceID == _id then
			   -- 通知控制板
			   FightSystem.mTouchPad:OnFriendDead(role)
			   self:RemoveFriendTeam(role.mSceneIndex,_id)
			   role:Destroy()
			   table.remove(self.mFriendRoles,index)
			return end
		end
   elseif _group == "enemyplayer" then
		for index,role in ipairs(self.mEnemyRoles) do
			if role.mInstanceID == _id then
			   -- 通知控制板
			   FightSystem.mTouchPad:OnEnemyplayerDead(role)
			    self:RemoveEnemyTeam(role.mSceneIndex,_id)
			   role:Destroy()
			   table.remove(self.mEnemyRoles,index)
			return end
		end
   else
 		self:RemoveSummonByIdx(_group, _id)
   end
end

-- 玩家闪烁移除
function RoleManager:FadeoutRoleByIdx(_group, _id)
	if _group == "friend" then
   	    -- 友军死亡移除
   		for index,role in ipairs(self.mFriendRoles) do
			if role.mInstanceID == _id then
			   -- 通知控制板
			   FightSystem.mTouchPad:OnFadeoutFriendDead(role)
			return end
		end
   elseif  _group == "enemyplayer" then
		for index,role in ipairs(self.mEnemyRoles) do
			if role.mInstanceID == _id then
			   -- 通知控制板
			   FightSystem.mTouchPad:OnFadeoutEnemyplayerDead(role)
			return end
		end
   end
end

-- 移除召唤物
function RoleManager:RemoveSummonByIdx(_group, _id)
	if _group == "summonfriend" then
	    for index,role in ipairs(self.mFriendRoles) do
			if role.mInstanceID == _id then
			   role:Destroy()
			   table.remove(self.mFriendRoles,index)
			return end
		end
	else
	    for index,role in ipairs(self.mEnemyRoles) do
			if role.mInstanceID == _id then
			   role:Destroy()
			   table.remove(self.mEnemyRoles,index)
			return end
		end
	end
end


-- 移除CG角色
function RoleManager:RemoveCGRoleByIdx(_group, _id)
   if _group == "monster" then
   	  	for index,role in ipairs(self.mEnemyRoles) do
   	  		if role.mCGId ~= 0 then
   	  			if role.mCGId == _id then
			  	 	role:Destroy()
			  	 	--cclog("mCGId==".. role.mCGId .. "_id==" .. _id .. "index==" .. index)
			  		table.remove(self.mEnemyRoles,index)
				return end
   	  		end
		end
   else
   		for index,role in ipairs(self.mFriendRoles) do
			if role.mCGId ~= 0 then
   	  			if role.mCGId == _id then
			  	 	role:Destroy()
			  		table.remove(self.mFriendRoles,index)
				return end
   	  		end
		end
   end
end

-- 通过Posindex 找到角色
function RoleManager:FindFriendRoleById(_posIndex)
	for index,role in ipairs(self.mFriendRoles) do
		if role.mPosIndex == _posIndex then
	  		return role
	  	end
	end
	return nil
end


-- 通过Posindex 找到敌人角色
function RoleManager:FindEnemyRoleById(_posIndex)
	for index,role in ipairs(self.mEnemyRoles) do
		if role.mPosIndex == _posIndex then
	  		return role
	  	end
	end
	return nil
end

-- 通过Posindex 找到敌人角色
function RoleManager:FindEnemyRoleByInstID(_id)
	for index,role in ipairs(self.mEnemyRoles) do
		if role.mInstanceID == _id then
	  		return role
	  	end
	end
	return nil
end

-- 通过ID找到CG角色
function RoleManager:FindCGRoleByIdx(_group, _id)
   if _group == "monster" then
   	  	for index,role in ipairs(self.mEnemyRoles) do
   	  		if role.mCGId ~= 0 then
   	  			if role.mCGId == _id then
					return role
				end
   	  		end
		end
   else
   		for index,role in ipairs(self.mFriendRoles) do
			if role.mCGId ~= 0 then
   	  			if role.mCGId == _id then
					return role
				end
   	  		end
		end
   end
end


-- 移除场景动画
function RoleManager:RemoveSceneAniByIdx(_id)
	for k,v in pairs(self.mSceneAniList) do
		if v.mInstanceID == _id then
		   v:Destroy(true)
		   table.remove(self.mSceneAniList, k)
		return end
	end
end

-- 移除FriendTeam
function RoleManager:RemoveFriendTeam(_sceneIndex,_id)
	if not self.mFriendRolesTeam[_sceneIndex] then return end
	for k,v in pairs(self.mFriendRolesTeam[_sceneIndex]) do
		if v.mInstanceID == _id then
		   table.remove(self.mFriendRolesTeam[_sceneIndex], k)
		return end
	end
end

-- 移除EnemyTeam
function RoleManager:RemoveEnemyTeam(_sceneIndex,_id)
	if not self.mEnemyRolesTeam[_sceneIndex] then return end
	for k,v in pairs(self.mEnemyRolesTeam[_sceneIndex]) do
		if v.mInstanceID == _id then
		   table.remove(self.mEnemyRolesTeam[_sceneIndex], k)
		return end
	end
end

-- 设置当前人物AI
function RoleManager:AllPlayerAiStop(_open)
	if not _open then
		self.mManagerAIState = "stop"
	else
		self.mManagerAIState = nil
	end
	for k,role in pairs(self.mFriendRoles) do
		if not role.IsKeyRole then
			if role.mGroup == "friend" and not role.mAI.mActivateFriendAI then
				role.mAI:setOpenAI(_open)
			end
		end
		-- if _open and role.mGroup == "friend" then
		-- 	role.mAI.mActivateAIKeyRole = nil
		-- 	role.mAI.mActivateFriendAI = nil
		-- end
	end
	for k,role in pairs(self.mEnemyRoles) do
		role.mAI:setOpenAI(_open)
	end
end

-- 设置当前人物AI改变激活状态
function RoleManager:AllPlayerAiStopForActivat(_open)
	for k,role in pairs(self.mFriendRoles) do
		if not role.IsKeyRole then
			if role.mGroup == "friend" then
				role.mAI:setOpenAI(_open)
				if not _open then
					role.mAI.mActivateAIKeyRole = nil
					role.mAI.mActivateFriendAI = true
				else
					role.mAI.mActivateAIKeyRole = nil
					role.mAI.mActivateFriendAI = nil
				end
			end
		else
			if not _open then
				role.mAI.mActivateAIKeyRole = true
				role.mAI.mActivateFriendAI = nil
			else
				role.mAI.mActivateAIKeyRole = nil
				role.mAI.mActivateFriendAI = nil
			end
		end
	end
	for k,role in pairs(self.mEnemyRoles) do
		role.mAI:setOpenAI(_open)
	end
end

-- 设置当前人物AI改变激活状态
function RoleManager:FriendAiActivatRemove()
	for k,role in pairs(self.mFriendRoles) do
		if role.mGroup == "friend" then
			if role.mAI then
				role.mAI.mActivateAIKeyRole = nil
				role.mAI.mActivateFriendAI = nil
			end
		end
	end
end

-- 载入友方角色
-- _posIndex =  出场位置索引
function RoleManager:LoadFriendRoles(_posIndex, _bornpos, _sceneIndex)

    self.mFriendInstanceIDCounter = self.mFriendInstanceIDCounter + 1
	local _roled = RoleData.new(self.mFriendInstanceIDCounter, "friend", _posIndex, _bornpos)
	local _role = FightRole.new(_roled,_sceneIndex)
	--_role:changeHorse(globaldata:getHeroInfoByBattleIndex(_posIndex, "horse"))
	
	if _posIndex == 1 then
		if FightSystem.mFightType == "fuben" then
			_role:setKeyRole(true)
			_role.mAI:setOpenAI(false)
		elseif FightSystem.mFightType == "arena" then
			if globaldata.PvpType == "brave" then
				_role:setKeyRole(true)
				_role.mAI:setOpenAI(false)
			elseif globaldata.PvpType == "arena" then
				_role:setKeyRole(true)
				_role.mAI:setOpenAI(false)
			elseif globaldata.PvpType == "boss" then
				_role:setKeyRole(true)
				_role.mAI:setOpenAI(false)
			end
		elseif FightSystem.mFightType == "olpvp" then
			_role:setKeyRole(true)
			_role.mAI:setOpenAI(false)
		end
	else
		_role:setKeyRole(false)
	end
	_role:AddToRoot(FightSystem.mSceneManager:GetTiledLayer(_role.mSceneIndex))
	for i=1,4 do
		local data = globaldata:getHeroInfoByBattleIndex(_roled.mInfoDB.ID, "changecolor",i)
		ShaderManager:changeColorspineByData(_role.mArmature.mSpine,data,_roled.mInfoDB.ID)
	end

	table.insert(self.mFriendRoles, _role)
	return _role
end

-- 载入友方角色
-- _posIndex =  出场位置索引
function RoleManager:LoadFriendOlPvpRoles(_posIndex, _bornpos, _sceneIndex)

    self.mFriendInstanceIDCounter = self.mFriendInstanceIDCounter + 1
	local _roled = RoleData.new(self.mFriendInstanceIDCounter, "friend", _posIndex, _bornpos)
	local _role = FightRole.new(_roled,_sceneIndex)
	--_role:changeHorse(globaldata:getHeroInfoByBattleIndex(_posIndex, "horse"))
	_role.mAI:setOpenAI(false)
	_role:setKeyRole(false)
	_role:AddToRoot(FightSystem.mSceneManager:GetTiledLayer(_role.mSceneIndex))
	for i=1,4 do
		local datalist = globaldata:getBattleFormationInfoByIndexAndKey(_posIndex, "changecolor")
		if datalist then
			local data = datalist[i]
			ShaderManager:changeColorspineByData(_role.mArmature.mSpine,data,_roled.mInfoDB.ID)
		end
	end
	table.insert(self.mFriendRoles, _role)
	return _role
end

-- 竞技场载入友方角色
function RoleManager:LoadFriendArenaRoles(_posIndex, _bornpos, _sceneIndex)

    self.mFriendInstanceIDCounter = self.mFriendInstanceIDCounter + 1
	local _roled = RoleData.new(self.mFriendInstanceIDCounter, "friend", _posIndex, _bornpos)
	local _role = FightRole.new(_roled,_sceneIndex)
	--_role:changeHorse(globaldata:getHeroInfoByBattleIndex(_posIndex, "horse"))
	_role.mAI:setOpenAI(true)
	_role:setKeyRole(false)
	
	_role:AddToRoot(FightSystem.mSceneManager:GetTiledLayer(_role.mSceneIndex))
	if not self.mFriendRolesTeam[_sceneIndex] then
		self.mFriendRolesTeam[_sceneIndex] = {}
	end
	table.insert(self.mFriendRolesTeam[_sceneIndex], _role)
	table.insert(self.mFriendRoles, _role)
	return _role
end

-- 生成怪
function RoleManager:LoadMonster(_monsterID, _bornpos, _sceneIndex,_index)
	self.mEnemyInstanceIDCounter = self.mEnemyInstanceIDCounter + 1
	local _roled = RoleData.new(self.mEnemyInstanceIDCounter, "monster", _monsterID, _bornpos ,_index)
	local _monster = FightRole.new(_roled, _sceneIndex)
	_monster:AddToRoot(FightSystem.mSceneManager:GetTiledLayer())
	_monster:UpDateShadow()
	if _monster.mRoleData.mInfoDB.Monster_Type == 2 then
		_monster:setInvincible(true)
	end
	if _monster.mAI and self.mManagerAIState then
		_monster.mAI:setOpenAI(false)
	end
	table.insert(self.mEnemyRoles, _monster)
	return _monster
end

-- 生成BOSS
function RoleManager:LoadBossMonster(_monsterID, _bornpos, _sceneIndex,_index)
	self.mEnemyInstanceIDCounter = self.mEnemyInstanceIDCounter + 1
	local _roled = RoleData.new(self.mEnemyInstanceIDCounter, "bossmonster", _monsterID, _bornpos ,_index)
	local _monster = FightRole.new(_roled, _sceneIndex)
	_monster:AddToRoot(FightSystem.mSceneManager:GetTiledLayer())
	_monster:UpDateShadow()
	if _monster.mRoleData.mInfoDB.Monster_Type == 2 then
		_monster:setInvincible(true)
	end
	table.insert(self.mEnemyRoles, _monster)
	return _monster
end

-- 生成敌方玩家
function RoleManager:LoadEnemyPlayer(_posIndex, _bornpos, _sceneIndex)
	self.mEnemyInstanceIDCounter = self.mEnemyInstanceIDCounter + 1
	local _roled = RoleData.new(self.mEnemyInstanceIDCounter, "enemyplayer", _posIndex, _bornpos)
	local _enemy = FightRole.new(_roled, _sceneIndex)
	_enemy:AddToRoot(FightSystem.mSceneManager:GetTiledLayer(_enemy.mSceneIndex))
	_enemy:UpDateShadow()
	for i=1,4 do
		local datalist = globaldata:getBattleEnemyFormationInfoByIndexAndKey(_posIndex, "changecolor")
		if datalist then
			local data = datalist[i]
			ShaderManager:changeColorspineByData(_enemy.mArmature.mSpine,data,_roled.mInfoDB.ID)
		end
	end
	table.insert(self.mEnemyRoles, _enemy)
	return _enemy
end

-- 生成OnlinePVP敌方玩家
function RoleManager:LoadOnlineEnemyPlayer(_posIndex, _bornpos, _sceneIndex)
	self.mEnemyInstanceIDCounter = self.mEnemyInstanceIDCounter + 1
	local _roled = RoleData.new(self.mEnemyInstanceIDCounter, "enemyplayer", _posIndex, _bornpos)
	local _enemy = FightRole.new(_roled, _sceneIndex)
	_enemy:AddToRoot(FightSystem.mSceneManager:GetTiledLayer(_enemy.mSceneIndex))
	_enemy:UpDateShadow()
	_enemy.mAI:setOpenAI(false)
	for i=1,4 do
		local datalist = globaldata:getBattleEnemyFormationInfoByIndexAndKey(_posIndex, "changecolor")
		if datalist then
			local data = datalist[i]
			ShaderManager:changeColorspineByData(_enemy.mArmature.mSpine,data,_roled.mInfoDB.ID)
		end
	end
	table.insert(self.mEnemyRoles, _enemy)
	return _enemy
end

-- 生成敌方玩家
function RoleManager:LoadEnemyArenaPlayer(_posIndex, _bornpos, _sceneIndex)
	self.mEnemyInstanceIDCounter = self.mEnemyInstanceIDCounter + 1
	local _roled = RoleData.new(self.mEnemyInstanceIDCounter, "enemyplayer", _posIndex, _bornpos)
	local _enemy = FightRole.new(_roled, _sceneIndex)
	_enemy:AddToRoot(FightSystem.mSceneManager:GetTiledLayer(_enemy.mSceneIndex))
	_enemy:UpDateShadow()
	if not self.mEnemyRolesTeam[_sceneIndex] then
		self.mEnemyRolesTeam[_sceneIndex] = {}
	end
	table.insert(self.mEnemyRolesTeam[_sceneIndex], _enemy)
	table.insert(self.mEnemyRoles, _enemy)
	return _enemy
end

--添加CG 主角
function RoleManager:LoadCGFriendRoles(_heroID, _bornpos)
	self.mFriendInstanceIDCounter = self.mFriendInstanceIDCounter + 1
	local _roled = RoleData.new(self.mFriendInstanceIDCounter, "cgfriend", _heroID, _bornpos)
	local _role = FightRole.new(_roled)
	_role.mCGId = _heroID
	_role:AddToRoot( FightSystem.mSceneManager:GetTiledLayer())
	for i=1,4 do
		local data = globaldata:getHeroInfoByBattleIndex(_roled.mInfoDB.ID, "changecolor",i)
		ShaderManager:changeColorspineByData(_role.mArmature.mSpine,data,_roled.mInfoDB.ID)
	end
	_role:UpDateShadow()
	table.insert(self.mFriendRoles, _role)
	_role:setInvincible(true)
	return _role
end

-- 添加CG 生成敌人
function RoleManager:LoadCGEnemyRoles(_monsterID, _bornpos)
	self.mEnemyInstanceIDCounter = self.mEnemyInstanceIDCounter + 1
	local _roled = RoleData.new(self.mEnemyInstanceIDCounter, "cgmonster", _monsterID, _bornpos)
	local _monster = FightRole.new(_roled)
	_monster.mCGId = _monsterID
	_monster:AddToRoot( FightSystem.mSceneManager:GetTiledLayer())
	table.insert(self.mEnemyRoles, _monster)
	_monster:setInvincible(true)
	return _monster
end

-- 载入召唤物
function RoleManager:LoadSummon(_id, _bornpos, _group, _sceneIndex)
	local _summonGroup = nil
	local _instanceID = nil
	if _group == "friend" then
	    _summonGroup = "summonfriend"
		self.mFriendInstanceIDCounter = self.mFriendInstanceIDCounter + 1
		_instanceID = self.mFriendInstanceIDCounter
    else
    	_summonGroup = "summonmonster"
    	self.mEnemyInstanceIDCounter = self.mEnemyInstanceIDCounter + 1
    	_instanceID = self.mEnemyInstanceIDCounter
    end
    -- 召唤物只取Monster表的数据
	local _roled = RoleData.new(_instanceID, _summonGroup, _id, _bornpos)
	local summon = FightRole.new(_roled,_sceneIndex)
	summon:AddToRoot(FightSystem.mSceneManager:GetTiledLayer(_sceneIndex))
	summon:UpDateShadow()
	if _group == "friend" then
	    --cclog("创建友军召唤物========" .. _instanceID)
	   	table.insert(self.mFriendRoles, summon)
	else
		--cclog("创建敌人召唤物========" .. _instanceID)
		table.insert(self.mEnemyRoles, summon)
	end

	return summon
end


-- 生成场景动画
function RoleManager:LoadSceneAnimation(_aniID, _bornpos,isblood,TiledLayer, _isHallScene)
	self.mSceneAniInstanceIDCounter = self.mSceneAniInstanceIDCounter + 1
	local _obj = SceneAni.new(_aniID, self.mSceneAniInstanceIDCounter, _bornpos,isblood)
	if TiledLayer then
		_obj:AddToRoot(TiledLayer,_bornpos.y, _isHallScene)
	else
		_obj:AddToRoot(FightSystem.mSceneManager:GetTiledLayer(),_bornpos.y, _isHallScene)
	end
	
	table.insert(self.mSceneAniList, _obj)

	return _obj
end

-- 生成Map场景动画
function RoleManager:LoadSceneMapAnimation(_aniID, _bornpos,isblood,TiledLayer)
	self.mSceneAniInstanceIDCounter = self.mSceneAniInstanceIDCounter + 1
	local _obj = SceneAni.new(_aniID, self.mSceneAniInstanceIDCounter, _bornpos,isblood)
	if TiledLayer then
		_obj:AddToRoot(TiledLayer,_bornpos.y)
	else
		_obj:AddToRoot(FightSystem.mSceneManager:GetTiledLayer(),_bornpos.y)
	end
end

-- 卸载场景动画
function RoleManager:unloadSceneAni()
	for index,obj in ipairs(self.mSceneAniList) do
		if obj and obj.Destroy then
			obj:Destroy()
		end
	end
	self.mSceneAniList = {}
end

function RoleManager:GetKeyRole(_IsCamera)
	if _IsCamera then
		if self.keyRoleTempId.id ~= 0 then
			local role = self:getRole(self.keyRoleTempId.group,self.keyRoleTempId.id) 
			if role then
				return role
			else
				FightSystem.mSceneManager.mCamera.isChangeSpeed = true
				self.keyRoleTempId.id = 0
				self.keyRoleTempId.group = ""
			end
		end
	end
	if StorySystem.mCGManager.mCGRuning then
		for k,v in pairs(self.mFriendRoles) do
			if v.mCGId ~= 0 then
				if v.mIsCGKeyRole then
					return v
				end
			end
		end

		for k,v in pairs(self.mEnemyRoles) do
			if v.mCGId ~= 0 then
				if v.mIsCGKeyRole then
					return v
				end
			end
		end
	end

	for k,v in pairs(self.mFriendRoles) do
		if v.IsKeyRole then
			return v
		end
	end
	return self.mFriendRoles[1]
end

-- 获得角色实例
function RoleManager:getRole(_group, _id)
	local _role = nil
	if _group == "friend" then
	   _role = self:getRoleByID(self.mFriendRoles, _id)
    elseif _group == "monster" or _group == "enemyplayer" then
       _role = self:getRoleByID(self.mEnemyRoles, _id)
    end

    return _role
end

function RoleManager:getRoleByID(_list, _id)
	for k,_role in pairs(_list) do
		if _role.mInstanceID == _id then
		   return _role
		end
	end
end

-- 设置新主角
function RoleManager:SetKeyRoleById(id)
	for k,v in pairs(self.mFriendRoles) do
		if v.mPosIndex ==  id then
			v:setKeyRole(true)
		else
			v:setKeyRole(false)
		end		
	end
end

function RoleManager:SetFriendFollowKeyRole(isfollow)
	self.mIsFriendfollow = isfollow
	for k,v in pairs(self.mFriendRoles) do
		if v.IsKeyRole then
			if not v.mAI then return end
			v.mAI.mIsfollow = false
			if not isfollow then
				if  FightSystem.mTouchPad.mAutoTouchAttack then
					v.mAI:ResetAttack()
				end	
			end
		else
			if not v.mAI then return end
			v.mAI:setAIFollow(isfollow)
		end	
	end
end

function RoleManager:GetEnemyCount()
	local i = 0
	for k,v in pairs(self.mEnemyRoles) do
		if not v.mPropertyCon:IsHpEmpty() then
			i = i + 1
		end
	end
	return i
end

function RoleManager:GetEnemyTable(index)
	return self.mEnemyRoles
	-- if index and index ~= 0 then
	-- 	return self.mEnemyRolesTeam[index]
	-- else
	-- 	return self.mEnemyRoles
	-- end
end

function RoleManager:GetFriendTable(index)
	return self.mFriendRoles
	-- if index and index ~= 0 then
	-- 	return self.mFriendRolesTeam[index]
	-- else
	-- 	return self.mFriendRoles
	-- end
end

function RoleManager:GetObjectTable(index)
	return self.mSceneAniList
end

-- 设置骨骼动画速度
function RoleManager:ChangeAllRoleActionSpeedScale(_frame)
	for index,role in pairs(self.mFriendRoles) do
		role:ChangeActionSpeedScale(_frame)
	end
	for index,role in pairs(self.mEnemyRoles) do
		role:ChangeActionSpeedScale(_frame)
	end
end

function RoleManager:StopEachSpineTick(_stoped)
	for k,role in pairs(self.mFriendRoles) do
		if role.mGroup ~= "cgfriend" then
			if not role.mStaticFrameTime_Unlock then
		    	if _stoped then
		    		role:pauseAction()
		    	else
		    		role:resumeAction()
		    	end
		    end
		end
	end
	--
	for k,role in pairs(self.mEnemyRoles) do
		if role.mGroup ~= "cgmonster" then
			if not role.mStaticFrameTime_Unlock then
		    	if _stoped then
		    		role:pauseAction()
		    	else
		    		role:resumeAction()
		    	end
	 	    end
		end
	end
end

function RoleManager:StopEachSpineTickForCg(_stoped)
	for k,role in pairs(self.mFriendRoles) do
		if not role.mStaticFrameTime_Unlock then
	    	if _stoped then
	    		role:pauseAction()
	    	else
	    		role:resumeAction()
	    	end
	    end
	end
	--
	for k,role in pairs(self.mEnemyRoles) do
		if not role.mStaticFrameTime_Unlock then
			if _stoped then
				role:pauseAction()
			else
				role:resumeAction()
			end
		end
	end
end

function RoleManager:pauseAllActions()
	for k,role in pairs(self.mFriendRoles) do
		if role.mGroup ~= "cgfriend" then
	    	role.mArmature:pause()
	    end
	end
	--
	for k,role in pairs(self.mEnemyRoles) do
		if role.mGroup ~= "cgmonster" then
			role.mArmature:pause()
		end
	end
end

function RoleManager:resumeAllActions()
	for k,role in pairs(self.mFriendRoles) do
		if role.mGroup ~= "cgfriend" then
			role.mArmature:resume()
		end
	end
	--
	for k,role in pairs(self.mEnemyRoles) do
		if role.mGroup ~= "cgmonster" then
			role.mArmature:resume()
		end
	end
end

-- 设置场景模糊
function RoleManager:SetAllSceneLayerblur()
	local sceneview = FightSystem:GetFightSceneView()
  	for k,layer in pairs(sceneview.mLayers) do
    	layer:blur()
  	end
end

-- 场景道具模糊
function RoleManager:SetAllSceneAniblur()
    for k,object in pairs(self.mSceneAniList) do
      	object:blur()
    end
end


function RoleManager:resumeFSM()
	for k,role in pairs(self.mFriendRoles) do
	    role:finishStaticisRun()
	end
	--
	for k,role in pairs(self.mEnemyRoles) do
	    role:finishStaticisRun()
	end
end

-- 获得一个受害者
function RoleManager:GetVicim(_idx, _role ,data)
	local _victim = nil
	if _role.mGroup == "friend" or _role.mGroup == "summonfriend" then
		local _tb = self:GetEnemyTable(_role.mSceneIndex)
		_victim = _tb[_idx]
	elseif _role.mGroup == "monster" or _role.mGroup == "summonmonster" or _role.mGroup == "enemyplayer" then
		local _tb = self:GetFriendTable(_role.mSceneIndex)
		_victim = _tb[_idx]
	end
	--
	if _victim and _victim:CanbeBeated() and _victim:IsInVictimHeightRange(data) then
	   return _victim
	end


	return nil
end

-- 获得一个受害者 去掉无敌
function RoleManager:GetVicimNoInVincible(_idx, _role ,data)
	local _victim = nil
	if _role.mGroup == "friend" or _role.mGroup == "summonfriend" then
		local _tb = self:GetEnemyTable(_role.mSceneIndex)
		_victim = _tb[_idx]
	elseif _role.mGroup == "monster" or _role.mGroup == "summonmonster" or _role.mGroup == "enemyplayer" then
		local _tb = self:GetFriendTable(_role.mSceneIndex)
		_victim = _tb[_idx]
	end
	--
	if _victim and _victim:IsInVictimHeightRange(data) then
	   return _victim
	end
	return nil
end

-- 获得同伴
function RoleManager:GetFriend(_idx, _role, _live)
	local _friend = nil
	if _role.mGroup == "monster" or _role.mGroup == "summonmonster" or _role.mGroup == "enemyplayer" then
		local _tb = self:GetEnemyTable(_role.mSceneIndex)
		_friend = _tb[_idx]
	elseif _role.mGroup == "friend" or _role.mGroup == "summonfriend" then
		local _tb = self:GetFriendTable(_role.mSceneIndex)
		_friend = _tb[_idx]
	end
	--
	if _live then
		if _friend and not _friend.mFSM:IsDeading() and _role ~= _friend then
		   return _friend
		end
	else
		if _friend and _friend:CanbeBeated() and _role ~= _friend then
		   return _friend
		end
	end
	return nil
end

-- 获得同伴包括自己
function RoleManager:GetAllFriend(_idx, _role, _live)
	local _friend = nil
	if _role.mGroup == "monster" or _role.mGroup == "summonmonster" or _role.mGroup == "enemyplayer" then
		local _tb = self:GetEnemyTable(_role.mSceneIndex)
		_friend = _tb[_idx]
	elseif _role.mGroup == "friend" or _role.mGroup == "summonfriend" then
		local _tb = self:GetFriendTable(_role.mSceneIndex)
		_friend = _tb[_idx]
	end
	--
	if _live then
		if _friend and not _friend.mFSM:IsDeading() then
		   return _friend
		end
	else
		if _friend and _friend:CanbeBeated() then
		   return _friend
		end
	end
	return nil
end

-- 获得敌人
function RoleManager:GetEnemy(_idx, _role, _live)
	local _enemy = nil
	if _role.mGroup == "monster" or _role.mGroup == "summonmonster" or _role.mGroup == "enemyplayer" then
		local _tb = self:GetFriendTable(_role.mSceneIndex)
		_enemy = _tb[_idx]
	elseif _role.mGroup == "friend" or _role.mGroup == "summonfriend" then
		local _tb = self:GetEnemyTable(_role.mSceneIndex)
		_enemy = _tb[_idx]
	end
	--
	if _live then
		if _enemy and not _enemy.mFSM:IsDeading() and _role ~= _enemy then
		   return _enemy
		end
	else
		if _enemy and _enemy:CanbeBeated() and _role ~= _enemy then
		   return _enemy
		end
	end
	return nil
end

-- 获得受害者候选人数量
function RoleManager:GetVicmCount(_role)
	if _role.mGroup == "friend" or _role.mGroup == "summonfriend" then
		local _tb = self:GetEnemyTable(_role.mSceneIndex)
		return #_tb
	elseif _role.mGroup == "monster" or _role.mGroup == "summonmonster" or _role.mGroup == "enemyplayer" then
		local _tb = self:GetFriendTable(_role.mSceneIndex)
		return #_tb
	end
end

-- 获得同伴候选人数量
function RoleManager:GetFriendCount(_role)
	if _role.mGroup == "monster" or _role.mGroup == "summonmonster" or _role.mGroup == "enemyplayer" then
		local _tb = self:GetEnemyTable(_role.mSceneIndex)
		return #_tb
	elseif _role.mGroup == "friend" or _role.mGroup == "summonfriend" then
		local _tb = self:GetFriendTable(_role.mSceneIndex)
		return #_tb
	end
end

-- 找到一个道具来拾取
function RoleManager:findPickup(_pos)
	-- 找拾取道具
	for k,v in pairs(self.mSceneAniList) do
		if v:CanbePickup(_pos) then
		   return v
		end
	end
end

-- 
function RoleManager:findPickupRole(_pos)
	--找人
	for k,v in pairs(self.mEnemyRoles) do
	    if v:CanbePickup(_pos) then
	       return v
	    end
	end
end

-- 设置所有玩家更新AISceneID
function RoleManager:setAllRoleSceneListId(_id)
	for k,role in pairs(self.mFriendRoles) do
	   if role.mAI then
	   		role.mAI.mSceneListID[_id] = nil
	   end
	end
	for k,role in pairs(self.mEnemyRoles) do
	    if role.mAI then
	   		role.mAI.mSceneListID[_id] = nil
	    end
	end
end

function RoleManager:setAllMonsterInvincible(isInvincible)
	for k,role in pairs(self.mEnemyRoles) do
	   role:setInvincible(isInvincible)
	end
end

function RoleManager:hideAllSceneAni(_hide)
	for index,obj in pairs(self.mSceneAniList) do
		obj:setVisible(not _hide)
	end
end
-- 金币过版拾取
function RoleManager:AllPickUpJinbi()
	for index,obj in pairs(self.mSceneAniList) do
		obj:PickUpJinbi()
	end
end

function RoleManager:hideAllFriend(_hide)
	for index,obj in pairs(self.mFriendRoles) do
		obj.mArmature:setVisible(not _hide)
	    obj.mShadow:setVisibleShadow(not _hide)
	end
end

function RoleManager:hideAllMonster(_hide)
	for index,obj in pairs(self.mEnemyRoles) do
		obj.mArmature:setVisible(not _hide)
	    obj.mShadow:setVisibleShadow(not _hide)
	end
end

function RoleManager:playVictory()
	FightSystem.mTouchPad:setCancelledTouch()
	FightSystem.mTouchPad:disabled(true)
	for k,role in pairs(self.mFriendRoles) do
		if role.mGroup == "friend" then
			role.mAI:setOpenAI(false)
			FightSystem.mTouchPad.mAutoTouchAttack = false
			if not role.mPropertyCon:IsHpEmpty() then
				if role.mFSM:IsAttacking() then
					role.mPickupCon:leavePickup()
					role.mSkillCon:FinishCurSkill()
					role:ForcesetPosandShadow(role:getShadowPos())
					role.mFSM:ForceChangeToState("idle")
					role:PlayVictory()
				else
					role.mPickupCon:leavePickup()
					role:ForcesetPosandShadow(role:getShadowPos())
					role.mFSM:ForceChangeToState("idle")
					role:PlayVictory()
				end
			end
		end
	end
end

-- 隐藏场上所有角色
function RoleManager:hideAllRoles()
	for k,role in pairs(self.mFriendRoles) do
		CommonAnimation.CanceltForInvincible(role.mArmature)
	    role:hide()
	end
	for k,role in pairs(self.mEnemyRoles) do
		CommonAnimation.CanceltForInvincible(role.mArmature)
		role:hide()
	end
end

function RoleManager:showAllRoles()
	for k,role in pairs(self.mFriendRoles) do
	    role:show()
	end
	for k,role in pairs(self.mEnemyRoles) do
		role:show()
	end
end

function RoleManager:showBornRoles()
	for k,role in pairs(self.mEnemyRoles) do
		if role.mGroup == "monster" and role.mAI then
			role.mAI.mActionOpen = false
			role.mArmature:ActionNow("born")
		end
	end
end

function RoleManager:setActionOpenRoles()
	for k,role in pairs(self.mEnemyRoles) do
		if role.mGroup == "monster" and role.mAI then
			role.mAI.mActionOpen = false
		end
	end
end