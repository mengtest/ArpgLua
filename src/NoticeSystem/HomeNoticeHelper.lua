-- Name: 	HomeNoticeHelper
-- Func：	主城界面红点工具(内部)
-- Author: 	wangshengdong
-- Date:	2016-1-29

HomeNoticeHelper = {}

-- 是否有英雄能进行操作(培养和升级)
function HomeNoticeHelper:isHeroCanDoPeiyangOfSkillUpFunc()

	-- 英雄ID表
	local heroIdTbl = {}
	for i = 1, maxHeroCount do -- 存在
		local heroData = DB_HeroConfig.getDataById(i)
		if 1 == heroData.Open then 
			table.insert(heroIdTbl, i)
		end
	end

	for i = 1, #heroIdTbl do
		local heroId = heroIdTbl[i]
		if globaldata:isHeroIdExist(heroId) then -- 存在
--			if HeroNoticeHelper:isHeroIdCanDoPeiyangFunc(heroId) or HeroNoticeHelper:isHeroIdCanDoSkillUpdateFunc(heroId) or HeroNoticeHelper:isHeroIdCanDoTalentUpdateFunc(heroId) then -- 能培养或者能升级
			if HeroNoticeHelper:isHeroIdCanDoPeiyangFunc(heroId) or HeroNoticeHelper:isHeroIdCanDoTalentUpdateFunc(heroId) then -- 能培养或者能升级
				return true
			else
				
			end
		else -- 不存在
			if HeroNoticeHelper:isHeroIdCanGet(heroId) then -- 能合成
				return true
			else	
				
			end
		end
	end

	return false
end

-- 是否有英雄能进行操作(培养和升级)
function HomeNoticeHelper:isHeroCanDoQianghuaForEquipFunc()
	if globaldata.level < 4 then
		return false
	end
	
	-- 英雄ID表
	local heroIdTbl = {}
	for i = 1, maxHeroCount do -- 存在
		local heroData = DB_HeroConfig.getDataById(i)
		if globaldata:isHeroIdExist(i)then 
			table.insert(heroIdTbl, i)
		end
	end

	for i = 1, #heroIdTbl do
		local heroId = heroIdTbl[i]
		-- 能强化
		if EquipNoticeHelper:isEquipCanDoQianghua(heroId) then
			return true
		end

	--	-- 能镶嵌
	--	if EquipNoticeHelper:isEquipCanDoXiangqian(heroId) then
	--		return true
	--	end

		-- 能洗练
		if EquipNoticeHelper:isEquipCanDoXilian(heroId) then
			return true
		end
	end

	return false
end

-- 技能
function HomeNoticeHelper:isHeroSkillCanDoLevelUp()
	-- 英雄ID表
	local heroIdTbl = {}
	for i = 1, maxHeroCount do -- 存在
		local heroData = DB_HeroConfig.getDataById(i)
		if globaldata:isHeroIdExist(i)then 
			table.insert(heroIdTbl, i)
		end
	end

	for i = 1, #heroIdTbl do
		local heroId = heroIdTbl[i]
		if SkillNoticeHelper:isHeroCanGetEquip(heroId) or SkillNoticeHelper:isHeroEquipCanLevelUp(heroId) or HeroNoticeHelper:isHeroIdCanDoSkillUpdateFunc(heroId) then
			return true
		end
	end
	return false
end
