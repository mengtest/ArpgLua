-- Func: 副本掉落的金币
-- Author: Johny

FubenMoney = class("FubenMoney", function()
   return cc.Node:create()
end)

function FubenMoney:ctor(_count)
   self.mCount = _count
	 self.mTexPath = "res/image/fight/money.png"
   self.mItemList = _itemIDList
   -- 拾取检测半径
   self.mPickRange = 50
   -- 创建宝箱
   local _money = cc.Sprite:create()
   _money:setProperty("Image", self.mTexPath)
   self:addChild(_money)
   self.mMoney = _money
end

-- 检查范围内主角
function FubenMoney:CheckKeyRoleInPickRange()
   local _keyRole = FightSystem.mRoleManager:GetKeyRole()
   local _posKeyRole = _keyRole:getPosition_pos()
   local _r = cc.pGetDistance(cc.p(self:getPositionX(), self:getPositionY()), _posKeyRole)
   if _r < self.mPickRange then
      self:PickItems()
      return true
   end
   return false
end

-- 拾取金币
function FubenMoney:PickItems()
    cclog("捡到金币了，哈哈")
end