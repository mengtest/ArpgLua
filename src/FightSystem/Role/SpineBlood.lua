-- Name: SpineBlood
-- Func: 上传
-- Author: tuanzhang

SpineBlood = class("SpineBlood", function()
   return cc.Node:create()
end)

function SpineBlood:ctor(_type)
	local path_bg = "fight_xiaoguai_bg.png"
	local path_xuetiao = "fight_xiaoguai_blood.png"
	if _type == 2 then
		path_bg = "fight_jinyingxuetiao_bg.png"
		path_xuetiao = "fight_jinyingxuetiao.png"
	end	

	local backBarbg = cc.Sprite:create()
	backBarbg:setProperty("Frame", path_bg)
	backBarbg:setAnchorPoint(cc.p(0.5,0.5))
	self:addChild(backBarbg)
	local xuetiao = cc.Sprite:create()
	xuetiao:setProperty("Frame", path_xuetiao)
	self.mMonsterPro = cc.ProgressTimer:create(xuetiao)
    self.mMonsterPro:setType(1)
    self.mMonsterPro:setMidpoint(cc.p(0,1))
    if _type == 2 then
    	self.mMonsterPro:setPosition(cc.p(backBarbg:getBoundingBox().width/2+9,backBarbg:getBoundingBox().height/2+1))
    else
    	self.mMonsterPro:setPosition(cc.p(backBarbg:getBoundingBox().width/2,backBarbg:getBoundingBox().height/2))
    end
    self.mMonsterPro:setAnchorPoint(cc.p(0.5,0.5))
    self.mMonsterPro:setBarChangeRate(cc.p(1, 0))
    backBarbg:addChild(self.mMonsterPro)
    self.mMonsterPro:setPercentage(100)
end

function SpineBlood:Destroy()
	self.mMonsterPro = nil
	self:removeFromParent(true)
end


function SpineBlood:setBloodPer(value)
	self.mMonsterPro:setPercentage(value)
end