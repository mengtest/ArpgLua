-- Func: 全游戏文本解析处理器
-- Author: Johny

TextParseManager = {}

--------------------局部变量-------------------------------
--[[
"*A_A" = "技能过程段总伤害",
"*A_B" = "技能子物体总伤害",
"*N_A" = "玩家建号时自定义的战队名称",
*N_A：玩家建号时自定义的战队名称。
*N_B：玩家主城主角英雄姓名。
*N_C：玩家进入副本战队的第一个英雄姓名。
"" = ""
]]





local _keyWordFunc = {}
--------------------------------------------------------------

function TextParseManager:init()
	_keyWordFunc["*A_A"] = handler(self,self.getSkillProcTotalDamage)
	_keyWordFunc["*A_B"] = handler(self,self.getSkillSubObjectTotalDamage)
	_keyWordFunc["*N_A"] = handler(self,self.getPlayerName)
	_keyWordFunc["*N_B"] = handler(self,self.getPlayerCityHeroName)
	_keyWordFunc["*N_C"] = handler(self,self.getPlayerFightFirstHeroName)

	_keyWordFunc["*B_A"] = handler(self,self.getSkillTotalDamage)
	_keyWordFunc["*B_B"] = handler(self,self.getNextSkillAddDamage)
	_keyWordFunc["*B_E"] = handler(self,self.getTotalTreat)
	_keyWordFunc["*B_F"] = handler(self,self.getNextAddTreat)

	-- local aa = "Hello, I'm #A_A bahjdksahas."
	-- cclog(self:parseText(aa))
end

function TextParseManager:destroy()
	_keyWordFunc = nil
end

-- 根据定义解析文字中的特殊字段
function TextParseManager:parseText(text, ...)
	local ret = text
	local from,len = string.find(ret, "*", searchPos)
	while(len and len > 0)
	do
		local flag = string.sub(ret,from, from + 3)
		local value = _keyWordFunc[flag](...)
		local fhalf = string.sub(ret,1,from - 1)
		local bhalf = string.sub(ret,from + 4, -1)
		ret = string.format("%s%s%s", fhalf,value,bhalf)
		from,len = string.find(ret, "*")
	end


	return ret
end


-- 技能过程段总伤害
function TextParseManager:getSkillProcTotalDamage(_skillId,_level)
	local _dbEss =  DB_SkillEssence.getDataById(_skillId)
	local _damageRatio = 0
	local PhysicalDamagePoint = 0
	for i = 1,32 do
		local _proID = _dbEss[ProcessID_Table[i]]
		if _proID == 0 then break end
		local _pro = DB_SkillProcess.getDataById(_proID)
		if _pro.Type == 2 then
			_damageRatio = _damageRatio + _pro.PhysicalDamageRatioMin
			PhysicalDamagePoint = PhysicalDamagePoint + _pro.PhysicalDamagePoint*_level
		end
	end
	_damageRatio = math.floor(_damageRatio)
	PhysicalDamagePoint = math.floor(PhysicalDamagePoint)
	local str = string.format("%d%% + %d",_damageRatio,PhysicalDamagePoint)
	return str
end

-- 技能子物体总伤害
function TextParseManager:getSkillSubObjectTotalDamage(_skillId,_level)
	local _dbEss =  DB_SkillEssence.getDataById(_skillId)
	local _damageRatio = 0
	local PhysicalDamagePoint = 0
	for i = 1,32 do
		local _proID = _dbEss[ProcessID_Table[i]]
		if _proID == 0 then break end
		local _pro = DB_SkillProcess.getDataById(_proID)
		for i = 1,8 do
	 	    local subID = _pro[SubObjectID_Table[i]]
		    if subID > 0 then
		       local subDB = DB_SkillSubObject.getDataById(subID)
		       if subDB.SubObjectProcessType == 2 then
		       		_damageRatio = _damageRatio + subDB.PhysicalDamageRatioMin
		       		PhysicalDamagePoint = PhysicalDamagePoint + subDB.PhysicalDamagePoint*_level
		       end
		    end
		end
	end
	_damageRatio = math.floor(_damageRatio)
	PhysicalDamagePoint = math.floor(PhysicalDamagePoint)
	local str = string.format("%d%% + %d",_damageRatio,PhysicalDamagePoint)
	return str
end

-- 玩家的名字
function TextParseManager:getPlayerName()
	return globaldata.name

--[[
	local hero  = globaldata:findHeroById(id)
	if hero then
		return hero.xxx 
	end
]]
end

-- 玩家主城主角英雄姓名
function TextParseManager:getPlayerCityHeroName()
	local _infoDB = DB_HeroConfig.getDataById(globaldata.leaderHeroId)
    return getDictionaryText(_infoDB.Name)
end

-- 玩家进入副本战队的第一个英雄姓名
function TextParseManager:getPlayerFightFirstHeroName()
	local _heroID = globaldata:getBattleFormationInfoByIndexAndKey(1, "id")
    local _infoDB = DB_HeroConfig.getDataById(_heroID)
    return getDictionaryText(_infoDB.Name)
end

-- 单个技能总伤害
function TextParseManager:getSkillTotalDamage(_skillId,_level,_heroID)
	local heroObj   = globaldata:findHeroById(_heroID)
	local heroData 	= DB_HeroConfig.getDataById(_heroID)
	local gongjili = 0
	if heroObj then
		local propList = heroObj.propList
		local propListEx = heroObj.propListEx
		local PhyAttEx = 0
		local GongfuEx = 0
		local RoushuEx = 0
		if propListEx[1] then PhyAttEx = propListEx[1] end
		if propListEx[4] then GongfuEx = propListEx[4] end
		if propListEx[5] then RoushuEx = propListEx[5] end
		local PhyAtt = propList[1] + PhyAttEx
		local Gongfu = propList[4] + GongfuEx
		local Roushu = propList[5] + RoushuEx
		if heroData.HeroGroup == 1 then
			gongjili = 0.7*PhyAtt + 0.3*Gongfu + 0.3*Roushu
		elseif heroData.HeroGroup == 2 then
			gongjili = 0.3*PhyAtt + 0.7*Gongfu + 0.3*Roushu
		elseif heroData.HeroGroup == 3 then
			gongjili = 0.3*PhyAtt + 0.3*Gongfu + 0.7*Roushu
		end
	end
	local _dbEss =  DB_SkillEssence.getDataById(_skillId)
	local totaldamage = (0.5+2*_level/100)*_dbEss.d_txt1/100*gongjili
	return tostring(math.ceil(totaldamage))
end

-- 下一级增加伤害
function TextParseManager:getNextSkillAddDamage(_skillId,_level,_heroID)
	local heroObj   = globaldata:findHeroById(_heroID)
	local heroData 	= DB_HeroConfig.getDataById(_heroID)
	local gongjili = 0
	if heroObj then
		local propList = heroObj.propList
		local propListEx = heroObj.propListEx
		local PhyAttEx = 0
		local GongfuEx = 0
		local RoushuEx = 0
		if propListEx[1] then PhyAttEx = propListEx[1] end
		if propListEx[4] then GongfuEx = propListEx[4] end
		if propListEx[5] then RoushuEx = propListEx[5] end
		local PhyAtt = propList[1] + PhyAttEx
		local Gongfu = propList[4] + GongfuEx
		local Roushu = propList[5] + RoushuEx
		if heroData.HeroGroup == 1 then
			gongjili = 0.7*PhyAtt + 0.3*Gongfu + 0.3*Roushu
		elseif heroData.HeroGroup == 2 then
			gongjili = 0.3*PhyAtt + 0.7*Gongfu + 0.3*Roushu
		elseif heroData.HeroGroup == 3 then
			gongjili = 0.3*PhyAtt + 0.3*Gongfu + 0.7*Roushu
		end
	end
	local _dbEss =  DB_SkillEssence.getDataById(_skillId)
	local adddamage = 2*_dbEss.d_txt1/10000*gongjili
	return tostring(math.ceil(adddamage))
end

-- 总治疗
function TextParseManager:getTotalTreat(_skillId,_level,_heroID)
	local heroObj   = globaldata:findHeroById(_heroID)
	local heroData 	= DB_HeroConfig.getDataById(_heroID)
	local MaxHp = 0
	if heroObj then
		local propList = heroObj.propList
		local propListEx = heroObj.propListEx
		local MaxHpEx = 0
		if propListEx[0] then MaxHpEx = propListEx[0] end
		MaxHp = propList[0] + MaxHpEx
	end
	local _dbEss =  DB_SkillEssence.getDataById(_skillId)
	local totalheal = (0.5+2*_level/100)*_dbEss.d_txt1/100*MaxHp
	return tostring(math.ceil(totalheal))
end

-- 下一级增加治疗
function TextParseManager:getNextAddTreat(_skillId,_level,_heroID)
	local heroObj   = globaldata:findHeroById(_heroID)
	local heroData 	= DB_HeroConfig.getDataById(_heroID)
	local MaxHp = 0
	if heroObj then
		local propList = heroObj.propList
		local propListEx = heroObj.propListEx
		local MaxHpEx = 0
		if propListEx[0] then MaxHpEx = propListEx[0] end
		MaxHp = propList[0] + MaxHpEx
	end
	local _dbEss =  DB_SkillEssence.getDataById(_skillId)
	local addheal = 2*_dbEss.d_txt1/10000*MaxHp
	return tostring(math.ceil(addheal))
end