-- Name: 	SkillNoticeHelper
-- Func：	技能界面红点工具(内部)
-- Author: 	wangshengdong
-- Date:	2016-7-13

SkillNoticeHelper = {}

-- 判断某个英雄装备是否能获得
function SkillNoticeHelper:isHeroCanGetEquip(heroId)
	local heroObj 	= globaldata:findHeroById(heroId)
	if heroObj.weapon then -- 已经有装备
		return false
	else
		local weaponData 	= DB_HeroWeapon.getDataById(heroId)
		if globaldata:getItemOwnCount(weaponData.ItemId) >= 1 then -- 足够
			return true
		else
			return false
		end
	end
end

-- 判断某个英雄装备是否能强化
function SkillNoticeHelper:isHeroEquipCanLevelUp(heroId)
	local heroObj 	= globaldata:findHeroById(heroId)
	if heroObj.weapon then -- 已经有装备
		if 10 == heroObj.weapon.mLevel then
			return false
		end
		local weaponData 	= DB_HeroWeapon.getDataById(heroId)
		if globaldata.money >= heroObj.weapon.mMoney and globaldata:getItemOwnCount(weaponData.ItemId) >= heroObj.weapon.mItemCnt then
			return true
		else
			return false
		end
	else
		return false
	end
end