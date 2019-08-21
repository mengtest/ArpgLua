-- Name: 	PublicShowRole
-- Func：	用于展示的角色，全模+特效
-- Author:	Johny

----------------------开关-------------------------------
local SHOW_SKILL_EFFECT   =  true
local GENDER_MAP  = {}
GENDER_MAP["5"] = "male"
GENDER_MAP["10"] = "female"
-----------------------------------------------------------


PublicShowRole = class("PublicShowRole")

function PublicShowRole:ctor(heroId, root, pos)
	if pos == nil then pos = cc.p(0,0) end
	self.mRoleData = RoleData.new(0, "publicshowrole", heroId, pos)
	self.mGender = GENDER_MAP[tostring(heroId)]
	self.mSpine = SpineDataCacheManager:getFullSpineByHeroID(heroId, root)
	self.mSpine:setSkeletonRenderType(cc.RENDER_TYPE_HERO)
	self.mSpine:setPosition(pos)
	----
	if SHOW_SKILL_EFFECT then
		self.mSkillEffect = CommonAnimation.createCacheSpine_commonByResID(self.mRoleData.mModelEffectID,root)
		self.mSkillEffect:setPosition(pos)
	end
end

function PublicShowRole:destroy()
	SpineDataCacheManager:collectFightSpineByAtlas(self.mSpine)
	self.mSpine = nil
	if SHOW_SKILL_EFFECT then
		SpineDataCacheManager:collectFightSpineByAtlas(self.mSkillEffect)
		self.mSkillEffect = nil
	end
end

-- 是否是男主
function PublicShowRole:isMale()
   return self.mGender == "male"
end

function PublicShowRole:showSkill(skillName, loop)
	self:stopAni()
	self.mSpine:setAnimation(0, skillName, loop)
	if SHOW_SKILL_EFFECT then
		self.mSkillEffect:setAnimation(0, skillName, loop)
	end
end

function PublicShowRole:setVisibleSpine(isvis)
	self:stopAni()
	self.mSpine:setVisible(isvis)
	if self.mSkillEffect then
		self.mSkillEffect:setVisible(isvis)
	end
end

function PublicShowRole:executeCmd(cmd, loop)
	self:stopAni()
	self.mSpine:setAnimation(0, cmd, loop)
end

function PublicShowRole:registerSpineAniEndFunc(func)
	self.mSpine:registerSpineEventHandler(func,1)
end

function PublicShowRole:stopAni()
	self.mSpine:clearTracks()
	self.mSpine:setToSetupPose()
	if SHOW_SKILL_EFFECT then
		self.mSkillEffect:clearTracks()
		self.mSkillEffect:setToSetupPose()
	end
end