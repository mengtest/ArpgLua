-- Name: SpineDataCacheManager
-- Func: 管理spine数据的缓存
-- Author: Johny

SpineDataCacheManager = {}
-- 是否需要等待清理spine数据缓存
SpineDataCacheManager.mWaitForRemoveSpineDataCache = false
-- 加载spine缓存数据容器
SpineDataCacheManager.mLoadSpineDataFuncList = {}

function SpineDataCacheManager:Init()
	self.mCache_FightSpine = {}
end

function SpineDataCacheManager:Release()
	  _G["SpineDataCacheManager"] = nil
	  package.loaded["SpineDataCacheManager"] = nil
	  package.loaded["ResSystem/SpineDataCacheManager"] = nil
end

function SpineDataCacheManager:Tick()
end

-- 申请清理spine数据缓存
function SpineDataCacheManager:applyForRemoveSpineDataCache()
	cclog("[Clear All SpineData Cache]")
	self:destroyFightSpineList()
	FightSystem.mSpineAgent:DestroyAllSpineData()
	---必须在这个位置释放
	ShaderManager:clearShaderCache()
	SoundSystem:unloadAllEffects()
	TextureSystem:UnLoadAllUnusedTexture()
	---
	SpineDataCacheManager.mWaitForRemoveSpineDataCache = false
	self:executeLoadSpineDataFunc()
end

-- 申请加载spine数据缓存
-- #目前需要在函数外部自行实现加载，形式不限
function SpineDataCacheManager:applyForAddSpineDataCache(_func)
	table.insert(SpineDataCacheManager.mLoadSpineDataFuncList, _func)
	self:executeLoadSpineDataFunc()
end

-- 执行外部申请加载spine数据缓存方法
function SpineDataCacheManager:executeLoadSpineDataFunc()
	-- 如果不是在等待移除spine缓存，即时执行，如果等待则移除spine缓存后执行
	if not SpineDataCacheManager.mWaitForRemoveSpineDataCache then
		for i = 1, #SpineDataCacheManager.mLoadSpineDataFuncList do
		    if SpineDataCacheManager.mLoadSpineDataFuncList[i] then
		    	SpineDataCacheManager.mLoadSpineDataFuncList[i]()
		    end 	
		end
		SpineDataCacheManager.mLoadSpineDataFuncList = {}
	end
end

-- 从缓存池中通过_atlas获取spine，引用计数减1放出，如果不存在则重新创建
function SpineDataCacheManager:getFightSpineByatlas(_binary, _atlas, _scale ,_root)
	if not _root then return end 
	local CacheSpineKey = string.format("%s%s",_binary,_atlas)
	local spineCacheList = self.mCache_FightSpine[CacheSpineKey]
	if not spineCacheList or #spineCacheList == 0 then
		--debugLog("getFightSpineByatlas 22222222222== ".._binary)
		local spine = CommonAnimation.createSpine_common(_binary, _atlas, _scale)
		_root:addChild(spine)
		return spine
	else
		local v =  table.remove(spineCacheList,1)
		v:setVisible(true)
		v:setOpacity(255)
		_root:addChild(v)
		if _scale then
			v:setScale(_scale)
		end
		v:release()
		--debugLog("getFightSpineByatlas 1111111111== ".._binary)
		return v,true
	end
end

-- 从缓存池中通过_atlas 和 Weaponindex获取spine，引用计数减1放出，如果不存在则重新创建
function SpineDataCacheManager:getFightSpineByAtlasWeapon(_binary, _atlas, _FashionWeaponIndex,_scale ,_root)
	if not _root then return end
	local CacheSpineKey = string.format("%s%s",_binary,_atlas)
	local spineCacheList = self.mCache_FightSpine[CacheSpineKey]
	if not spineCacheList or #spineCacheList == 0 then
		local db = DB_HorseConfig.getDataById(_FashionWeaponIndex)
		local spine = CommonAnimation.createSpine_weapon(_binary, _atlas, db.FashionWeaponIndex,_scale)
		spine:setWeaponKey(_FashionWeaponIndex)
		_root:addChild(spine)
		spine:setSkeletonRenderType(cc.RENDER_TYPE_HERO_WEAPON)
		return spine
	else
		for i,v in ipairs(spineCacheList) do
			if v:getWeaponKey() == _FashionWeaponIndex then
				local v =  table.remove(spineCacheList,i)
				v:setVisible(true)
				v:setOpacity(255)
				_root:addChild(v)
				if _scale then
					v:setScale(_scale)
				end
				v:release()
				v:setSkeletonRenderType(cc.RENDER_TYPE_HERO_WEAPON)
				return v,true
			end
		end
		local db = DB_HorseConfig.getDataById(_FashionWeaponIndex)
		local spine = CommonAnimation.createSpine_weapon(_binary, _atlas, db.FashionWeaponIndex,_scale)
		spine:setWeaponKey(_FashionWeaponIndex)
		_root:addChild(spine)
		return spine
	end
end

-- 通过怪物ID创建全模spine
function SpineDataCacheManager:getSimpleSpineByMonsterID(_monsterid, _root)
	local _db = DB_MonsterConfig.getDataById(_monsterid)
	local _resID = _db.Monster_SimpleModel
	local _resScale = _db.Monster_SimpleModelZoom
	if _resID <= 0 then
		_resID = _db.Monster_Model
	    _resScale = _db.Monster_ModelZoom
	end
	local _resDB = DB_ResourceList.getDataById(_resID)
	local _spine = self:getFightSpineByatlas(_resDB.Res_path2, _resDB.Res_path1, _resScale, _root)
	_spine:setAnimation(0, "stand", true)
	_spine:setSkeletonRenderType(cc.RENDER_TYPE_MONSTER)
	return _spine
end


-- 通过英雄id创建简spine
function SpineDataCacheManager:getSimpleSpineByHeroID(_heroid, _root)
	local _db = DB_HeroConfig.getDataById(_heroid)
	local _resID = _db.SimpleResouceID
	local _resScale = _db.SimpleResouceZoom
	if _resID <= 0 then
	   _resID = _db.ResouceID
	   _resScale = _db.ResouceZoom
	end
	local _resDB = DB_ResourceList.getDataById(_resID)
	local _spine =  self:getFightSpineByatlas(_resDB.Res_path2, _resDB.Res_path1, 1, _root)
	--
	_spine:setAnimation(0, _db.FightStand, true)

	return _spine
end

-- 通过ItemId创建人物穿坐骑或者拿枪 如果ItemId为nil
-- _type : 0 是裸体
-- _type : 1 是时装
-- _type : 2 是武器
function SpineDataCacheManager:getFashionSpineByItemId(_root,_heroid,_type,_itemId ,_level)
	local _rd = RoleData.new(0, "hallrole", _heroid, cc.p(0,0))
	local _op = FightRole.new(_rd)
	_op:setSpineRenderType(cc.RENDER_TYPE_HERO)
	local success = false
	-- 坐骑
	if _type == 0 then

	elseif _type == 1 then
		local HorseKey = string.format("FashionHorseID%d",_level) 
		local HorseID = DB_FashionEquip.getDataById(_itemId)[HorseKey]
		_op:changeHorse(HorseID)
	elseif _type == 2 then
		local WeapKey = string.format("FashionHorseID%d",_level) 
		local HorseID = DB_FashionEquip.getDataById(_itemId)[WeapKey]
		_op.mGunCon:ShowRoleEquipedByGunId(HorseID)
	end
	for i=1,4 do
		local data = globaldata:getHeroInfoByBattleIndex(_heroid, "changecolor",i)
		ShaderManager:changeColorspineByData(_op.mArmature.mSpine,data,_heroid)
	end
	_op:AddToRoot(_root)
	_op.mArmature.mViptitle:setVisible(false)
	return _op
end

-- 通过英雄id创建全spine
function SpineDataCacheManager:getFullSpineByHeroID(_heroid, _root)
	local _db = DB_HeroConfig.getDataById(_heroid)
	local _resID = _db.ResouceID
	local _resScale = _db.ResouceZoom
	local _resDB = DB_ResourceList.getDataById(_resID)
	local _spine =  self:getFightSpineByatlas(_resDB.Res_path2, _resDB.Res_path1, 1, _root)
	--
	_spine:setAnimation(0, _db.FightStand, true)

	return _spine
end

-- 将spine归还到缓存池中，并引用计数加1
function SpineDataCacheManager:collectFightSpineByAtlas(_spine)
	if not _spine then return end
	
	local _binary = _spine:getBinaryFileName()
	local _atlas = _spine:getAtlasFileName()
	local CacheSpineKey = string.format("%s%s",_binary,_atlas)
	--doError("SpineDataCacheManager:collectFightSpineByAtlas ==" .. _atlas)
	--------------------
	-- 必须设置为false，不然schedule会被清除，update就不走了，就不会结束回调了
	--------------------
	----- 解注册事件回调
	_spine:setVisible(false)
	_spine:stopAllActions()
	_spine:unregisterSpineEventHandler(0)
	_spine:unregisterSpineEventHandler(1)
	_spine:unregisterSpineEventHandler(2)
	_spine:unregisterSpineEventHandler(3)
	_spine:clearTracks()
	_spine:setToSetupPose()
	_spine:setStopTick(false)
	_spine:enableRenderer(true)
	ShaderManager:ResumeColor_spine_all(_spine)
	_spine:retain()
	_spine:removeFromParent(false)
	----
	
	
	local spineCacheList = self.mCache_FightSpine[CacheSpineKey]
	if spineCacheList then
		table.insert(self.mCache_FightSpine[CacheSpineKey],_spine)
	else
		self.mCache_FightSpine[CacheSpineKey] = {}
		table.insert(self.mCache_FightSpine[CacheSpineKey],_spine)
	end
	-- if not _spine then return end
	-- _spine:removeFromParent()
end

-- 清理spine缓存数据
function SpineDataCacheManager:destroyFightSpineList()
	for k,list in pairs(self.mCache_FightSpine) do
		if list then
			for i,v in pairs(list) do
				if v then
					v:release()
				end
			end
		end
	end
	self.mCache_FightSpine = {}
end