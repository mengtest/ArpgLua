-- Name: AutoMoveManager
-- Func: 自动行走管理器
-- Author: Johny


-- 城市关系的数据结构
local CityRelationsData ={}
function CityRelationsData:new()
	local o =
	{
		cityid    = -1,
		relationid1 = -1,
		relationid2 = -1,
		relationid3 = -1,
		relationid4 = -1,
	}
	o = newObject(o, CityRelationsData)
	return o
end

AutoMoveManager = {}

function AutoMoveManager:init()
	self:initCityRelations()
end

-- 寻找NPC
function AutoMoveManager:FindPosListByNPCID( _npcId, _curCityId)
	self.mAutoPosList = {}
	local index = 0
	for i=1,8 do
		local  Data = DB_CityConfig.getArrDataByField(string.format("NPC%dID",i),_npcId) 
		if #Data == 1 then
			self.mFindNpcInfo = Data[1]
			index = i
			break
		end
	end
	if self.mFindNpcInfo.ID == _curCityId then
		local pos = cc.p(self.mFindNpcInfo[string.format("NPC%dPos",index)][1],self.mFindNpcInfo[string.format("NPC%dPos",index)][2]-50)
		table.insert(self.mAutoPosList,pos)
	else
		self.mAutoRoadList = self:getRoadMapByTwoCity(_curCityId,self.mFindNpcInfo.ID)
		for i=1,#self.mAutoRoadList do
			if self.mFindNpcInfo.ID == self.mAutoRoadList[i].cityid then
				local pos = cc.p(self.mFindNpcInfo[string.format("NPC%dPos",index)][1],self.mFindNpcInfo[string.format("NPC%dPos",index)][2]-50)
				table.insert(self.mAutoPosList,pos)
				break
			else
				local data = self.mAutoRoadList[i]
				local data1 = self.mAutoRoadList[i+1]
				for i=1,4 do
					local relationidData = data["relationid"..i]
					if  type(relationidData) == "table" then
						if relationidData[1] == data1.cityid then
							table.insert(self.mAutoPosList,relationidData[2])
							break
						end
					end
				end
			end
		end
	end
end

-- 初始化城市关系
function AutoMoveManager:initCityRelations()
	self.mCityMap = {}

	for k,v in pairs(DB_CityConfig.CityConfig) do
		local city = CityRelationsData:new()
		city.cityid = k
		local TableData = DB_CityConfig.getDataById(k)
		for i = 1,4 do
			local _srcpos = TableData[string.format("TransPoint%dMin", i)]
			local _srcsize = TableData[string.format("TransPoint%dMax", i)]
			local _cg = TableData[string.format("TransPoint%dCG", i)]
			local _id = TableData[string.format("TargetCity%dID", i)]
			local _pos = TableData[string.format("TargetCity%dPos", i)]
			if _id > 0 then
				city["relationid"..i] = {_id,cc.p(_srcpos[1]+_srcsize[1]/2,_srcpos[2]+_srcsize[2]/2)}
			end
		end
		self.mCityMap[city.cityid] = city
	end
end

-- 查找两城市之间路径
-- @fromCityId
-- @toCityId
-- @return  table{cityid1,cityid2,cityid3,cityid4,cityid5}
function AutoMoveManager:getRoadMapByTwoCity(fromCityId, toCityId)
	local fromData = self.mCityMap[fromCityId]
	local toData = self.mCityMap[toCityId]
	local retMap = {}
	table.insert(retMap, toData)
	-- 如果下个关系城市id有一个是toCityId，返回当前cityid,否则继续寻找
	-- 遍历每个关系城市需要排除上一城市id
	local function findToData(data, lastCityId)
		for i = 1,4 do
			local relationid = data["relationid" .. i]
			if type(relationid) == "table" then
				if relationid[1] ~= lastCityId then
				   if relationid[1] == toCityId then
				   	  table.insert(retMap, data)
				   	  return true
				   else
				   	  if findToData(self.mCityMap[relationid[1]], data.cityid) then
				   	  	 table.insert(retMap, data)
				   	  	 return true
				   	  end
				   end
				end
			end	
		end

		return false
	end
	--- 倒序数组
	local function deOrderTable()
		local tmp = {}
		for i = #retMap, 1, -1 do
			table.insert(tmp, retMap[i])
		end
		retMap = tmp
	end
	---
	if findToData(fromData) then
	   deOrderTable()
	   return retMap
	end

	return nil
end