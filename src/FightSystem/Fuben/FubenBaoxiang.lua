-- Func: 副本掉落的宝箱
-- Author: Johny
require "GUISystem/Widget/Baoxiangpiao"
FubenBaoxiang = class("FubenBaoxiang", function()
   return cc.Node:create()
end)

function FubenBaoxiang:ctor(itemType,itemId,itemNum)
   self.mBornTime = 6
	 self.mTexPath = nil
    if 0 == itemType then -- 物品
        local itemData = DB_ItemConfig.getDataById(itemId)
        local itemIconId = itemData.IconID
        self.mTexPath = DB_ResourceList.getDataById(itemIconId).Res_path1
    elseif 1 == itemType then -- 装备
        local equipInfo = DB_EquipmentConfig.getDataById(itemId)
        local iconId = equipInfo.IconID
        self.mTexPath = DB_ResourceList.getDataById(iconId).Res_path1
    else
        self.mTexPath = getImgNameByTypeAndId(itemType)
    end
     self.mItemList = _itemIDList
     -- 拾取检测半径
     self.mPickRange = 50
     -- 创建宝箱
     local _bx = cc.Sprite:create()
     _bx:setProperty("Frame", self.mTexPath)
     _bx:setAnchorPoint(cc.p(0,0))
     local _shadow = cc.Sprite:create()
     local _resDB = DB_ResourceList.getDataById(645)
     _shadow:setProperty("Frame", _resDB.Res_path1)
     _shadow:addChild(_bx)
     _bx:setPositionY(_bx:getPositionY()+10)
      local act0 = cc.MoveTo:create(1, cc.p(_bx:getPositionX(),_bx:getPositionY()+10))
      local act1 = cc.MoveTo:create(1, cc.p(_bx:getPositionX(),_bx:getPositionY()-10))
      local act2 = cc.Sequence:create(act0,act1)
      local forever = cc.RepeatForever:create(act2)
      _bx:runAction(forever)



     self:addChild(_shadow)
     self.mBaoxiang = _shadow
     self:setScale(0.8)
end

-- 检查范围内主角
function FubenBaoxiang:CheckKeyRoleInPickRange()
   local _keyRole = FightSystem:GetKeyRole()
   local _posKeyRole = _keyRole:getPosition_pos()
   local _r = cc.pGetDistance(cc.p(self:getPositionX(), self:getPositionY()), _posKeyRole)
   if _r < self.mPickRange then
      self:PickItems()
      return true
   end
    return false
end

-- 拾取道具
function FubenBaoxiang:PickItems()
    cclog("捡到宝箱了，哈哈")
    local x = getGoldFightPosition_LU().x + ( self:getPositionX() + FightSystem.mSceneManager:GetTiledLayer():getPositionX())
    local y =  self:getPositionY() + getGoldFightPosition_LD().y--+ FightSystem.mSceneManager:GetTiledLayer():getPositionY()-- (  + FightSystem.mSceneManager:GetTiledLayer():getPositionY())
    local pos = cc.p(x,y)
    Baoxiangpiao:showBaoxiang(self.mTexPath,pos,cc.p(getGoldFightPosition_LU().x+300,getGoldFightPosition_RU().y-100))
   -- self.mBaoxiang:setVisible(false)
end