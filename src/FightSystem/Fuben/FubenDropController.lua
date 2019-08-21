-- Name: FubenDropController
-- Func: 副本掉落处理器
-- Author: tuanzhang

FubenDropController =  class("FubenDropController")

function FubenDropController:ctor()
	
end

function FubenDropController:Init(SectionId,PveLevel,noserverdrop)
	
	self.MonsterList = {}
	self.SceneList = {}
	self.InstanceID = 0
	local sectionId = SectionId
	while true do
		local BoardsData = DB_BoardsConfig.getDataById(sectionId)
		local diffdegreekey = "Board_EeayController"
		if PveLevel == 1 then
			diffdegreekey = "Board_EeayController"
		elseif PveLevel == 2 then
			diffdegreekey = "Board_NormalController"
		elseif PveLevel == 3 then
			diffdegreekey = "Board_HardController"
		end
		for i,v in ipairs(BoardsData[diffdegreekey]) do
			self:DropControll(v)
		end
		if BoardsData.Board_NextBoardID == 0 then
			break
		else
			sectionId = BoardsData.Board_NextBoardID
		end
	end
	if not noserverdrop then
		for k,v in pairs(globaldata.monsterdroplist) do
			if not self.MonsterList[v.monsterId] then break end
			for i=1,#self.MonsterList[v.monsterId].MonsterInfoList do
				self.MonsterList[v.monsterId].MonsterInfoList[i] = v.monsterInfo[i]
			end
		end
	end
end

function FubenDropController:DropControll(con_id)
	local ControllerData = DB_ControllerConfig.getDataById(con_id)
	for i = 1 ,ControllerData.Controller_MonsterCount do
		local Controller_ID = string.format("Controller_ID%d",i)
		local Controller_Type = string.format("Controller_Type%d",i)
		local monsterID = ControllerData[Controller_ID]
		local dropitem = 1
		local monstertype = ControllerData[Controller_Type]
		if monstertype == 1 then
			if self.MonsterList[monsterID] then
				self.MonsterList[monsterID].count = self.MonsterList[monsterID].count + 1
				--cclog( monsterID .."====ID==="..self.MonsterList[monsterID].count)
				local key = self.MonsterList[monsterID].count
				self.MonsterList[monsterID].MonsterInfoList[key] = dropitem
			else
				local monster = {}
				monster.count = 1
				monster.index = 1
				monster.MonsterInfoList = {}
				monster.MonsterInfoList[1] = dropitem
				self.MonsterList[monsterID] = monster
			end
		elseif monstertype == 3 then
			if not self.SceneList[monsterID] then
				self.SceneList[monsterID] = monsterID
			end
		end
	end
end

function FubenDropController:DropItem(_monsterid, _pos)
	if self.MonsterList[_monsterid] then
		local dropinfo = self.MonsterList[_monsterid].MonsterInfoList[self.MonsterList[_monsterid].index]
		if not dropinfo or dropinfo == 1 then return end
		if dropinfo.goodsNum ~= 0 then
			local goodsNum = dropinfo.goodsNum
			for i=1,goodsNum do
				local item = dropinfo.goodslist[i]
				self:ShowDropItem(item.itemType,item.itemId,item.itemNum,_pos)
			end
		end
		self.MonsterList[_monsterid].index = self.MonsterList[_monsterid].index + 1
	end
end

function FubenDropController:ShowDropItem(itemType,itemId,itemNum,_pos)
	--cclog("itemId ==" ..itemId.."itemType==" ..itemType .."itemNum" ..itemNum)
	if itemType == 9 then
		local obj = FightSystem.mRoleManager:LoadSceneAnimation(itemId,_pos)
		local _ac = cc.JumpTo:create(1, _pos, 150, 1)
		obj:runAction(_ac)
	else
		local _baoxiang = FubenBaoxiang.new(itemType,itemId,itemNum)
		_baoxiang:setPosition(_pos)
		_baoxiang:setLocalZOrder(1440 - _pos.y)
		_baoxiang:setPositionX(_baoxiang:getPositionX()+ 100)
		FightSystem.mSceneManager:GetTiledLayer():addChild(_baoxiang)

		FightSystem:GetFightManager().mBaoxiangtable[_baoxiang] = _baoxiang
	end
end

