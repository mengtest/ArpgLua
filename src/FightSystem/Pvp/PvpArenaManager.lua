-- Name: PvpArenaManager
-- Func: PVP竞技场数据处理器
-- Author: tuanzhang

require "FightSystem/Fuben/FubenConfig" 
require "FightSystem/Fuben/MonsterObject"
require "FightSystem/Fuben/FubenBaoxiang"
require "FightSystem/Fuben/FubenMoney"

PvpArenaManager = {}

function PvpArenaManager:initVars()
	self.mBoardMaxTime = nil		--最大通关时间
	self.mCurTime = 0			--当前剩余时间
	self.mtablemonster = {}			--控制器里面
	self.isTick = false
	self.mtick = 0
	self.mCurControllerKill = 0
	self.mResultTick = -1
	self.mMoneytable = {}
	self.mCurBoardMonster = nil

	self.mLeftLineX = 0  --大于等于0的数
	self.mRightLineX = 0  --大于等于0的数

	self.mLeftMAXLineX = 0   --大于等于0的数
	self.mRightMAXLineX = 0  --大于等于0的数

	self.mResult = nil
	--CG列表

	--副本当前替补
	self.mSubstitutionCount = 0
	--副本敌人替补
	self.mSubstitutionEnemyCount = 0
	--当前Player index 
	self.mPlayerIndex = 0
	self.mFinishTick = nil
end

function PvpArenaManager:Destroy()
	NetSystem:removeGSReLoginFunc("PvpArenaresult")	
	FightSystem:UnloadTouchPad()
	self.IsStartTick = nil
	self.mBoardMaxTime = nil		--最大通关时间
	self.mControllerData = nil		--控制器数据
	self.mCurTime = nil				--当前剩余时间
	self.mtablemonster = nil
	self.isTick = nil
	self.mtick = nil
	self.mCurControllerKill = nil
	self.mResultTick = nil
	self.mResult = nil
	self.misTickBornMonster = nil
	self.mCurBoardMonster = nil
	self.mRoot = nil
	self.mFinishTick = nil
end

function PvpArenaManager:Release()
	--
	_G["PvpArenaManager"] = nil
  	package.loaded["PvpArenaManager"] = nil
  	package.loaded["FightSystem/Pvp/PvpArenaManager"] = nil
end

function PvpArenaManager:Init(rootNode)
	self:initVars()
	self.mRoleManager = FightSystem.mRoleManager
	self.mRoot = rootNode
	self.isTick = true

	--当前加载场景
	if globaldata.PvpType == "arena" then
		self:LoadArenaInfo2()
	elseif globaldata.PvpType == "pk" then
		self:LoadPkInfo()
	elseif globaldata.PvpType == "brave" then	
		self:LoadBraveInfo()
	elseif globaldata.PvpType == "boss" then
		self:LoadWorldBossInfo()
	end

	FightSystem:LoadTouchPad(FightConfig.FIGHTWINDOW_Z_TOUCHPAD, rootNode,self.mCurTime)
	FightSystem.mTouchPad:SetTime(self.mCurTime)

	if globaldata.PvpType == "brave" then
		FightSystem.mTouchPad:InitBraveHead2()
		-- FightSystem.mTouchPad:HideBraveBtn()
		-- local role = FightSystem.mRoleManager:FindEnemyRoleByInstID(1)
		-- FightSystem.mTouchPad:InitKofMonsterHead(nil,self.liveEnemyIndex)
		FightSystem:GetFightSceneView():setPositionY(math.abs(getGoldFightPosition_LD().y))
	elseif globaldata.PvpType == "pk" then
		FightSystem.mTouchPad:HidePvpBtn()
		FightSystem.mTouchPad:InitPvpPkEnemyHead()
		FightSystem:GetFightSceneView():setPositionY(math.abs(getGoldFightPosition_LD().y))
	elseif globaldata.PvpType == "arena" then
		--FightSystem.mTouchPad:InitArenaHead()
		FightSystem.mTouchPad:InitArenaHead2()
	elseif globaldata.PvpType == "boss" then
		FightSystem.mTouchPad:InitBossBar(self.mRoleBoss)
		FightSystem.mTouchPad:InitWorldBossUI()
	end
	self:AutoFightPvp()
	-- 放学校名
	--self:ShowSchool()
	CommonAnimation.ChangeBGM(globaldata.pvpmucicId)
end

function PvpArenaManager:AutoFightPvp()

end

function PvpArenaManager:LoadArenaInfo2()
	local fristrole = nil
	local _mapID = globaldata.pvpmapId
	FightSystem.mSceneManager.mArenaViewIndex = i
	FightSystem.mSceneManager:LoadSceneView(FightConfig.FIGHTWINDOW_Z_SCENEVIEW, self.mRoot, _mapID)
	for i=1,3 do
		local width = FightSystem.mSceneManager:GetTiledLayer().mWidth
		local _pos = cc.p(globaldata.pvpFriendPosList[i].x*width,globaldata.pvpFriendPosList[i].y*770)
		if globaldata:getBattleFormationInfoByIndex(i) then

			local role = FightSystem.mRoleManager:LoadFriendRoles(i, _pos)
			if not fristrole then
				--role.mAI:setOpenAI(false)
				role:setKeyRole(true)
				fristrole = true
			end
			role.mSkillCon.mMp = 0
		end
		local _pos = cc.p(globaldata.pvpEnemyPosList[i].x*width,globaldata.pvpEnemyPosList[i].y*770)
		if globaldata:getBattleEnemyFormationInfoByIndex(i) then
			local role = FightSystem.mRoleManager:LoadEnemyPlayer(i, _pos)
			role.mSkillCon.mMp = 0
		end
	end
	FightSystem:GetFightSceneView():setPositionY(math.abs(getGoldFightPosition_LD().y))
	FightSystem.mSceneManager.mArenaViewIndex = 1
	self.mBoardMaxTime = globaldata.pvpmaxTime
	self.mLeftLineX = 0   --大于等于0的数
	self.mRightLineX = FightSystem.mSceneManager:GetTiledLayer().mWidth --大于等于0的数
	self.mLeftMAXLineX = 0   --大于等于0的数
	self.mRightMAXLineX = FightSystem.mSceneManager:GetTiledLayer().mWidth --大于等于0的数
	self.mCurTime = self.mBoardMaxTime
	self.mCurBoardMonster = globaldata:getBattleEnemyFormationCount()
	self.mFriendsession = 0
	self.mEnemysession = 0

	FightSystem.mRoleManager:AllPlayerAiStop(false)
	local function waitCountLayout()
		FightSystem.mRoleManager:AllPlayerAiStop(true)
		self.IsStartTick = true
		if globaldata.PvpType == "arena" then
			if FightSystem:isEnabledWudaoguanAuto() then
				FightSystem.mTouchPad:setCheckAuto(true)
			end
		end
	end
	GUISystem:FightBeginlayout(waitCountLayout)
end

function PvpArenaManager:LoadArenaInfo()

	local fristrole = nil
	for i=1,3 do
		local _mapID = globaldata.pvpmapId
		FightSystem.mSceneManager.mArenaViewIndex = i

		FightSystem.mSceneManager:LoadSceneArenaView(FightConfig.FIGHTWINDOW_Z_SCENEVIEW, self.mRoot, _mapID,i)
		FightSystem.mSceneManager:GetSceneView(i):setVisible(false)
		local width = FightSystem.mSceneManager:GetTiledLayer(i).mWidth
		
		local _pos = cc.p(globaldata.pvpFriendPosList[i].x*width,globaldata.pvpFriendPosList[i].y*770)
		if globaldata:getBattleFormationInfoByIndex(i) then

			local role = FightSystem.mRoleManager:LoadFriendArenaRoles(i, _pos,i)
			if not fristrole then
				--role.mAI:setOpenAI(false)
				role:setKeyRole(true)
				fristrole = true
			end
		end
		--[[
		local _pos = cc.p(globaldata.pvpFriendPosList[2].x*width,globaldata.pvpFriendPosList[1].y*770)
		if globaldata:getBattleFormationInfoByIndex(i+3) then
			local role = FightSystem.mRoleManager:LoadFriendArenaRoles(i+3, _pos,i)
			if not fristrole then
				role.mAI:setOpenAI(false)
				role:setKeyRole(true)
				fristrole = true
			end
		end
		]]

		local _pos = cc.p(globaldata.pvpEnemyPosList[i].x*width,globaldata.pvpEnemyPosList[i].y*770)
		if globaldata:getBattleEnemyFormationInfoByIndex(i) then
			local role = FightSystem.mRoleManager:LoadEnemyArenaPlayer(i, _pos,i)
			role:FaceLeft()
		end
		--[[
		local _pos = cc.p(globaldata.pvpEnemyPosList[2].x*width,globaldata.pvpEnemyPosList[1].y*770)
		if globaldata:getBattleEnemyFormationInfoByIndex(i+3) then
			FightSystem.mRoleManager:LoadEnemyArenaPlayer(i+3, _pos,i)
		end
		]]

		FightSystem:GetFightSceneView():setPositionY(math.abs(getGoldFightPosition_LD().y))
	end
	FightSystem.mSceneManager.mArenaViewIndex = 1
	FightSystem.mSceneManager:GetSceneView(1):setVisible(true)
	self.mBoardMaxTime = globaldata.pvpmaxTime
	self.mLeftLineX = 0   --大于等于0的数
	self.mRightLineX = FightSystem.mSceneManager:GetTiledLayer(1).mWidth --大于等于0的数
	self.mLeftMAXLineX = 0   --大于等于0的数
	self.mRightMAXLineX = FightSystem.mSceneManager:GetTiledLayer(1).mWidth --大于等于0的数
	self.mCurTime = self.mBoardMaxTime
	self.mCurBoardMonster = globaldata:getBattleEnemyFormationCount()
	self.mFriendsession = 0
	self.mEnemysession = 0
	self.SessionArr = {0,0,0}
end

function PvpArenaManager:LoadPkInfo()
	self:setFubenNeedData()
	local width = FightSystem.mSceneManager:GetTiledLayer().mWidth
	local _count = globaldata:getBattleFormationCount()
	for i = 1, _count do
		local _pos = cc.p(globaldata.pvpFriendPosList[i].x*width,globaldata.pvpFriendPosList[i].y*770)
		FightSystem.mRoleManager:LoadFriendRoles(i, _pos)
	end

	self.mCurBoardMonster = globaldata:getBattleEnemyFormationCount()
	for i = 1, self.mCurBoardMonster do
		local _pos = cc.p(globaldata.pvpEnemyPosList[i].x*width,globaldata.pvpEnemyPosList[i].y*770)
		FightSystem.mRoleManager:LoadEnemyPlayer(i, _pos)
	end
end

function PvpArenaManager:LoadBraveInfo()
	self:setFubenNeedData()
	local width = FightSystem.mSceneManager:GetTiledLayer().mWidth
	local _friendcount = globaldata:getBattleFormationCount()
	local fristrole = nil
	for i=1,_friendcount do
		local _pos = cc.p(globaldata.pvpFriendPosList[i].x*width,globaldata.pvpFriendPosList[i].y*770)
		if globaldata:getBattleFormationInfoByIndex(i) then
			local role = FightSystem.mRoleManager:LoadFriendArenaRoles(i, _pos,i)
			if not fristrole then
				role:setKeyRole(true)
				fristrole = true
			end
		end
	end

	local _count1 = globaldata:getBattleEnemyFormationCount()
	local liveCount = 0
	for i=1,_count1 do
		local curhp = globaldata:getBattleEnemyFormationInfoByIndexAndKey(i, "braveCurHp")
		if curhp ~= 0 then
			local _pos1 = cc.p(globaldata.pvpEnemyPosList[i].x*width,globaldata.pvpEnemyPosList[i].y*770)
			local role = FightSystem.mRoleManager:LoadEnemyPlayer(i, _pos1)
			role:FaceLeft()

			liveCount = liveCount + 1
		end
	end
	self.mCurBoardMonster = liveCount
	FightSystem.mRoleManager:AllPlayerAiStop(false)
	local function waitCountLayout()
		FightSystem.mRoleManager:AllPlayerAiStop(true)
		self.IsStartTick = true
		if globaldata.PvpType == "brave" then
			if FightSystem:isEnabledChuangGuanAuto() then
				FightSystem.mTouchPad:setCheckAuto(true)
			end
		end
	end
	GUISystem:FightBeginlayout(waitCountLayout)

end

function PvpArenaManager:LoadWorldBossInfo()
	self:setFubenNeedData()
	local width = FightSystem.mSceneManager:GetTiledLayer().mWidth
	local _count = globaldata:getBattleFormationCount()
	for i=1,_count do
		local _pos = cc.p(globaldata.pvpFriendPosList[i].x*width,globaldata.pvpFriendPosList[i].y*770)
		local role = FightSystem.mRoleManager:LoadFriendRoles(i, _pos)
	end

	local _pos1 = cc.p(globaldata.pvpEnemyPosList[1].x*width,globaldata.pvpEnemyPosList[1].y*770)
	self.mRoleBoss = FightSystem.mRoleManager:LoadBossMonster(1, _pos1)
	--self.mRoleBoss = FightSystem.mRoleManager:LoadBossMonster(1106, _pos1)

	self.mCurBoardMonster = globaldata:getBattleEnemyFormationCount()
		
	local _count = globaldata:getBattleFormationCount()
	self.mSubstitutionCount = _count - 1

	local _count = globaldata:getBattleEnemyFormationCount()
	self.mSubstitutionEnemyCount = _count - 1
	FightSystem.mRoleManager:AllPlayerAiStop(false)
	local function waitCountLayout()
		FightSystem.mRoleManager:AllPlayerAiStop(true)
		self.IsStartTick = true
		if globaldata.PvpType == "boss" then
			if FightSystem:isEnabledBossAuto() then
				FightSystem.mTouchPad:setCheckAuto(true)
			end
		end
	end
	GUISystem:FightBeginlayout(waitCountLayout)
end


function PvpArenaManager:loadPlayCount()
	if globaldata.PvpType == "brave" then
		self:loadKOFFriend()
		self:loadKOFEnemy()
	end
end

-- 轮流上1 + 1 + 1 
function PvpArenaManager:loadKOFFriend()
	local _count = globaldata:getBattleFormationCount()
	self.mSubstitutionCount = _count - 1
	self.ShowHeadCount = 1
end

function PvpArenaManager:loadKOFEnemy()
	local _count = globaldata:getBattleEnemyFormationCount()
	self.mSubstitutionEnemyCount = _count - 1
end

--查找当前副本需要的数值
function PvpArenaManager:setFubenNeedData()

	--暂时用
	local _mapID = globaldata.pvpmapId
	FightSystem.mSceneManager:LoadSceneView(FightConfig.FIGHTWINDOW_Z_SCENEVIEW, self.mRoot, _mapID)

	self.mBoardMaxTime = globaldata.pvpmaxTime
	
	self.mLeftLineX = 0   --大于等于0的数
	self.mRightLineX = FightSystem.mSceneManager:GetTiledLayer().mWidth --大于等于0的数

	self.mLeftMAXLineX = 0   --大于等于0的数
	self.mRightMAXLineX = FightSystem.mSceneManager:GetTiledLayer().mWidth --大于等于0的数

	self.mCurTime = self.mBoardMaxTime

end

--设置副本控制难度系数
function PvpArenaManager:Tick(delta)
	if not self.isTick then return end

	FightSystem.mTouchPad:Tick(delta)

	--if self:ResultTick(delta) then return end

	if self.mFinishTick then return end
	if not self.IsStartTick then return end
	self:PvpArenaTime(delta)
end

function PvpArenaManager:ResultTick(delta)
	-- if self.mResultTick ~= -1 then
	-- 	self.mResultTick = self.mResultTick + delta
	-- 	if self.mResultTick >= 3 then
	-- 		self.mResultTick = -1
			
	-- 	end
	-- 	return true	
	-- end
	-- return false
end

-- 有人被击杀通知
function PvpArenaManager:OnRoleKilled(_group, _pos)
	if self:IsArena() then
		self:OnKilledArena(_group, _pos)
	else
		self:OnKilledOther(_group, _pos)
	end
end

-- 胜负
function PvpArenaManager:ArenaResult(_sessionindex,_group)
	if self.SessionArr[_sessionindex] == 0 then
		self.SessionArr[_sessionindex] = 1
		if _group == "friend" then
			self.mEnemysession = self.mEnemysession + 1
		else
			self.mFriendsession = self.mFriendsession + 1
		end
		if self.mEnemysession == 2 then
			self:Result("fail")
			return false
		end
		if self.mFriendsession == 2 then
			self:Result("success")
			return false
		end
		return _sessionindex
	end
	return false
end

function PvpArenaManager:IsArena( _group, _pos )
	return globaldata.PvpType == "arena" 
end

function PvpArenaManager:OnKilledArena(_group, _pos)
	if _group == "friend"  then
		if #FightSystem.mRoleManager.mFriendRoles == 0 then
			self:Result("fail")
		end
	elseif _group == "enemyplayer" then
		self.mCurControllerKill = self.mCurControllerKill + 1 
		if self.mCurControllerKill ==  self.mCurBoardMonster then
			self:Result("success")
			return 
		end
	end
end


function PvpArenaManager:OnKilledOther(_group, _pos)
	if _group == "friend"  then
		if #FightSystem.mRoleManager.mFriendRoles == 0 then
			self:Result("fail")
		end
	elseif _group == "enemyplayer" then
		self.mCurControllerKill = self.mCurControllerKill + 1 
		if self.mCurControllerKill ==  self.mCurBoardMonster then
			self:Result("success")
			return 
		end
	elseif _group == "monster" then
		self:Result("success")
		return 
	end
end

function PvpArenaManager:Result(_result)
	if self.mResult then return end
	FightSystem.mTouchPad.mResultTick = false
	GUISystem:enableUserInput()
	self.mResult = _result
	self:SendPvpResult(_result)
	if self.mResult == "success" then
		if globaldata.PvpType == "boss" then
			EventSystem:PushEvent(Event.GUISYSTEM_SHOW_WORLDBOSSRESULTWINDOW)
		else
			EventSystem:PushEvent(Event.GUISYSTEM_SHOW_BATTLERESULT_WIN)
		end
	else
		if globaldata.PvpType == "boss" then
			EventSystem:PushEvent(Event.GUISYSTEM_SHOW_WORLDBOSSRESULTWINDOW)
		else
			EventSystem:PushEvent(Event.GUISYSTEM_SHOW_BATTLERESULT_LOSE)
		end
	end

end

function PvpArenaManager:BackPvpArenaResult()
	self.mSendresult = "back"
	GUISystem:hideLoading()
	local result = self.mResult
	if result == "success" then
		GUISystem.Windows["BattleResult_WinWindow"]:ServerBackresult()
	end
end


function PvpArenaManager:BackBossResult()
	self.mSendresult = "back"
	GUISystem:hideLoading()
end

function PvpArenaManager:LoginBackSuccess()
	if globaldata.PvpType == "boss" then
		if GUISystem.Windows["WorldBossResultWindow"].mRootNode and not globaldata.isFubenBalance then
			self:SendPvpResult("success")
			GUISystem:showLoading()
		end
	else
		if GUISystem.Windows["BattleResult_WinWindow"].mRootNode and not globaldata.isFubenBalance then
			self:SendPvpResult("success")
			GUISystem:showLoading()
		end
	end
end

function PvpArenaManager:RegisterLoginBackResult(_result)
	NetSystem:addGSReLoginFunc("PvpArenaresult",handler(self,self.LoginBackSuccess))
end

function PvpArenaManager:SendPvpResult(_result)
	self.mSendresult = "send"
	self.isTick = false
	globaldata.isFubenBalance = nil
	FightSystem.mTouchPad:setVisible(false)
	if self.mResult == "success" then
		if globaldata.PvpType == "arena" then
			self:RegisterLoginBackResult()
			local packet = NetSystem.mNetManager:GetSPacket()
			packet:SetType(PacketTyper._PTYPE_CS_RESULT_PVP_)
			packet:PushInt(globaldata.fightresultkey)
			packet:PushString(globaldata.playerid_str)
			packet:PushInt(globaldata.playerrank)
			packet:PushChar(0)
			packet:Send()
		elseif globaldata.PvpType == "brave" then
			local friendcount = globaldata:getBattleFormationCount()
			local enemycount = globaldata:getBattleEnemyFormationCount()
			local packet = NetSystem.mNetManager:GetSPacket()
			packet:SetType(PacketTyper._PTYPE_CS_REQUEST_BRAVE_COMPLETE_)
			packet:PushInt(globaldata.fightresultkey)
			packet:PushChar(0)
			packet:PushInt(friendcount)
			local FriendHp = {}
			for i=1,friendcount do
				local heroId = globaldata:getBattleFormationInfoByIndexAndKey(i, "id")
				FriendHp[heroId] = 0
			end
			for i=1,friendcount do
				if #FightSystem.mRoleManager:GetFriendTable() ~= 0 then
					local role = FightSystem.mRoleManager:GetFriendTable()[i]
					if role then
						local heroId = globaldata:getBattleFormationInfoByIndexAndKey(role.mPosIndex, "id")
	   					FriendHp[heroId] = role.mPropertyCon.mCurHP
					end
				end
			end
			for k,v in pairs(FriendHp) do
				packet:PushInt(k)
	   			packet:PushInt(v)
	   			debugLog("成功FFFFFFFFFF=C==" .. k.."=====" .. "HHH" .. "====" ..v)
			end
			packet:Send()
		elseif globaldata.PvpType == "boss" then
			self:RegisterLoginBackResult()
			local packet = NetSystem.mNetManager:GetSPacket()
			packet:SetType(PacketTyper._PTYPE_CS_BOSSFIGHT_RESULT_)
			local totaldamage = 0
			for k,v in pairs(globaldata.mFriendPvpDamage) do
				totaldamage = totaldamage + v
			end
			packet:PushInt(globaldata.fightresultkey)
			packet:PushInt(totaldamage)
			packet:Send()
			return
		end
	elseif  self.mResult == "fail" then
		if globaldata.PvpType == "arena" then
			local packet = NetSystem.mNetManager:GetSPacket()
			packet:SetType(PacketTyper._PTYPE_CS_RESULT_PVP_)
			packet:PushInt(globaldata.fightresultkey)
			packet:PushString(globaldata.playerid_str)
			packet:PushInt(globaldata.playerrank)
			packet:PushChar(1)
			packet:Send()
		elseif globaldata.PvpType == "boss" then
			self:RegisterLoginBackResult()
			local packet = NetSystem.mNetManager:GetSPacket()
			packet:SetType(PacketTyper._PTYPE_CS_BOSSFIGHT_RESULT_)
			packet:PushInt(globaldata.fightresultkey)
			local totaldamage = 0
			for k,v in pairs(globaldata.mFriendPvpDamage) do
				totaldamage = totaldamage + v
			end
			packet:PushInt(totaldamage)
			packet:Send()
			return
		elseif globaldata.PvpType == "brave" then

			local friendcount = globaldata:getBattleFormationCount()
			local enemycount = globaldata:getBattleEnemyFormationCount()
			local packet = NetSystem.mNetManager:GetSPacket()
			packet:SetType(PacketTyper._PTYPE_CS_REQUEST_BRAVE_COMPLETE_)
			packet:PushInt(globaldata.fightresultkey)
			packet:PushChar(1)
			packet:PushInt(friendcount)
			local FriendHp = {}
			for i=1,friendcount do
				local heroId = globaldata:getBattleFormationInfoByIndexAndKey(i, "id")
				FriendHp[heroId] = 0
			end
			for i=1,friendcount do
				if #FightSystem.mRoleManager:GetFriendTable() ~= 0 then
					local role = FightSystem.mRoleManager:GetFriendTable()[i]
					if role then
						local heroId = globaldata:getBattleFormationInfoByIndexAndKey(role.mPosIndex, "id")
	   					FriendHp[heroId] = role.mPropertyCon.mCurHP
					end
				end
			end

			for k,v in pairs(FriendHp) do
				packet:PushInt(k)
	   			packet:PushInt(v)
	   			debugLog("失败FFFFFFFFFF=C==" .. k.."=====" .. "HHH" .. "====" ..v)
			end
			packet:PushInt(enemycount)
			local MonsterHp = {}
			for i=1,enemycount do
				MonsterHp[i] = 0
			end
			for i=1,enemycount do
				if #FightSystem.mRoleManager:GetEnemyTable() ~= 0 then
					local role = FightSystem.mRoleManager:GetEnemyTable()[i]
					if role then
						MonsterHp[role.mPosIndex] = role.mPropertyCon.mCurHP
					end
					--[[
					local role = FightSystem.mRoleManager:GetEnemyTable()[1]
					if role.mPosIndex == i then
						packet:PushInt(i)
	   					packet:PushInt(role.mPropertyCon.mCurHP)
					elseif role.mPosIndex > i then
						packet:PushInt(i)
	   					packet:PushInt(0)
					elseif role.mPosIndex < i then	
						packet:PushInt(i)
						local curhp = globaldata:getBattleEnemyFormationInfoByIndexAndKey(i, "braveCurHp")
	   					packet:PushInt(curhp)
					end
					]]
				end
			end
			for i,v in ipairs(MonsterHp) do
				packet:PushInt(i)
	   			packet:PushInt(v)
	   			debugLog("失败MMMMMMMMMM=C==" .. i.."=====" .. "HHH" .. "====" ..v)
			end
			packet:Send()
		end
	end
end

function PvpArenaManager:GetSlowmotion(_role)
	if _role.mGroup == "enemyplayer" then
		return self:GetLastBoardMonsterCount(_role)
	elseif _role.mGroup == "friend" then
		return self:GetLastFriendCount(_role)
	end
end

function PvpArenaManager:GetLastFriendCount(_role)
	if self:IsArena() or globaldata.PvpType == "brave" then
		local count = 0
		for k,v in pairs(FightSystem.mRoleManager:GetFriendTable()) do
			if v.mGroup == "friend" then
				if v.mPropertyCon.mCurHP > 0 then
					count = count + 1
				end
			end
		end
		if count == 0 then
			return 1
		end
		return nil
	else
		local count = 0
		for k,v in pairs(FightSystem.mRoleManager:GetFriendTable()) do
			if v.mGroup == "friend" then
				if v.mPropertyCon.mCurHP > 0 then
					count = count + 1
				end
			end
		end
		if count == 0 then
			return 1
		end
		return nil
	end
end

function PvpArenaManager:GetLastBoardMonsterCount(_role)

	if globaldata.PvpType == "brave" then
		return self.mCurBoardMonster - self.mCurControllerKill
	elseif self:IsArena() then
		local count = 0
		for k,v in pairs(FightSystem.mRoleManager:GetEnemyTable()) do
			if v.mGroup == "enemyplayer" then
				if v.mPropertyCon.mCurHP > 0 then
					count = count + 1
				end
			end
		end
		if count == 0 then
			return 1
		end
		return nil
	end	
end

function PvpArenaManager:PvpArenaTime(delta)
	if self.mtick >= 1 then
		self.mtick = 0
		self.mCurTime = self.mCurTime - 1
		FightSystem.mTouchPad:SetTime(self.mCurTime)
		if self.mCurTime <= 0 then
			self:CasttoTime()
		end
	else     	  
		self.mtick = self.mtick + delta	
	end
end

function PvpArenaManager:CasttoTime()
	FightSystem.mRoleManager:removeAllFlyFriend()
	self:Result("fail")
	--[[
	if globaldata.PvpType == "brave" then
		self.isTick = false
		if FightSystem.mTouchPad.mSubstitutionCount > 0 then
			FightSystem.mRoleManager:removeAllFlyFriend()
		else
			FightSystem.mRoleManager:removeAllFlyFriend()
			self:Result("fail")
		end
	else
		FightSystem.mRoleManager:removeAllFlyFriend()
		self:Result("fail")
	end
	]]
end

function PvpArenaManager:resetTime()
	self.mtick = 0
	self.mCurTime = self.mBoardMaxTime
	FightSystem.mTouchPad:SetTime(self.mCurTime)
	self.isTick = true
end

function PvpArenaManager:ShowSchool()
	local _dbText = getDictionaryText(globaldata.pvpmapNameId)
	CommonAnimation.ScreenMiddlelabelText(FightSystem.mTouchPad,_dbText,3)
end

----------------回调--------------------------
-- 回包了，准备进入竞技场
function PvpArenaManager:OnPreEnterPVP(_mapID)
	local function _enterPVP()
		local _data = {}
		_data.mType = "arena"
		Event.GUISYSTEM_SHOW_FIGHTWINDOW.mData = _data
		EventSystem:PushEvent(Event.GUISYSTEM_SHOW_FIGHTWINDOW)
		-- 给予渲染时间，延迟1秒消失loading窗口
		local function xxx()
			hideLoadingWindow()
		end
		nextTick_frameCount(xxx, 0.05)
	end
	-- 预加载角色
	local function _loadRoles()
		_co2 = coroutine.create(function()
			-- myteam
			local _count = globaldata:getBattleFormationCount()
			for i = 1, _count do
				local _json, _atlas, _scale, _soundList, _skillList = globaldata:getMyFightTeamSpineData(i)
				-- CommonAnimation.preloadSoundList(_soundList)
				-- CommonAnimation.preloadSkillSoundAndEffect(_skillList)
				CommonAnimation.preloadSpine_common(_json, _atlas, _scale)
				coroutine.yield()
			end
			-- monster
			_count = globaldata:getBattleEnemyFormationCount()
			for i = 1, _count do
				local _json, _atlas, _scale, _soundList, _skillList = globaldata:getEnemyFightTeamSpineData(i)
				-- CommonAnimation.preloadSoundList(_soundList)
				-- CommonAnimation.preloadSkillSoundAndEffect(_skillList)
				CommonAnimation.preloadSpine_common(_json, _atlas, _scale)
				coroutine.yield()
			end
		end)
	end
	_loadRoles()
	-- 开始协同
	local _handler = 0
	local function xxx()
		coroutine.resume(_co2)
		if coroutine.status(_co2) == "dead" then
			_enterPVP()
			cc.Director:getInstance():getScheduler():unscheduleScriptEntry(_handler)
		end
	end
	_handler = nextTick_eachSecond(xxx, 0.1)
end


-- 回包了，准备进入切磋
function PvpArenaManager:OnPreEnterPVP2(_mapID)
	local function _enterPVP2()
		local _data = {}
		_data.mType = "arena"
		Event.GUISYSTEM_SHOW_FIGHTWINDOW.mData = _data
		EventSystem:PushEvent(Event.GUISYSTEM_SHOW_FIGHTWINDOW)
		-- 给予渲染时间，延迟1秒消失loading窗口
		local function xxx()
			hideLoadingWindow()
		end
		nextTick_frameCount(xxx, 0.05)
	end
	-- 预加载角色
	local function _loadRoles()
		_co2 = coroutine.create(function()
			-- myteam
			local _count = globaldata:getBattleFormationCount()
			for i = 1, _count do
				local _json, _atlas, _scale, _soundList, _skillList = globaldata:getMyFightTeamSpineData(i)
				-- CommonAnimation.preloadSoundList(_soundList)
				-- CommonAnimation.preloadSkillSoundAndEffect(_skillList)
				CommonAnimation.preloadSpine_common(_json, _atlas, _scale)
				coroutine.yield()
			end
			-- monster
			_count = globaldata:getBattleEnemyFormationCount()
			for i = 1, _count do
				local _json, _atlas, _scale, _soundList, _skillList = globaldata:getEnemyFightTeamSpineData(i)
				-- CommonAnimation.preloadSoundList(_soundList)
				-- CommonAnimation.preloadSkillSoundAndEffect(_skillList)
				CommonAnimation.preloadSpine_common(_json, _atlas, _scale)
				coroutine.yield()
			end
		end)
	end
	---------------------------
	if FightSystem.mIsReFight then
		_enterPVP2()
	else
		_loadRoles()
		-- 开始协同
		local _handler = 0
		local function xxx()
			coroutine.resume(_co2)
			if coroutine.status(_co2) == "dead" then
				_enterPVP2()
				cc.Director:getInstance():getScheduler():unscheduleScriptEntry(_handler)
			end
		end
		_handler = nextTick_eachSecond(xxx, 0.1)
	end
end

-- 回包了，准备进入闯关
function PvpArenaManager:OnPreEnterPVP3(_mapID)
	local function _enterPVP3()
		local _data = {}
		_data.mType = "arena"
		Event.GUISYSTEM_SHOW_FIGHTWINDOW.mData = _data
		EventSystem:PushEvent(Event.GUISYSTEM_SHOW_FIGHTWINDOW)
		-- 给予渲染时间，延迟1秒消失loading窗口
		local function xxx()
			hideLoadingWindow()
		end
		nextTick_frameCount(xxx, 0.05)
	end
	-- 预加载角色
	local function _loadRoles()
		_co2 = coroutine.create(function()
			-- myteam
			local _count = globaldata:getBattleFormationCount()
			for i = 1, _count do
				local _json, _atlas, _scale, _soundList, _skillList = globaldata:getMyFightTeamSpineData(i)
				-- CommonAnimation.preloadSoundList(_soundList)
				-- CommonAnimation.preloadSkillSoundAndEffect(_skillList)
				CommonAnimation.preloadSpine_common(_json, _atlas, _scale)
				cclog("[_enterPVP3]===myteam===" .. _json)
				coroutine.yield()
			end
			-- monster
			_count = globaldata:getBattleEnemyFormationCount()
			for i = 1, _count do
				local _json, _atlas, _scale, _soundList, _skillList = globaldata:getEnemyFightTeamSpineData(i)
				-- CommonAnimation.preloadSoundList(_soundList)
				-- CommonAnimation.preloadSkillSoundAndEffect(_skillList)
				CommonAnimation.preloadSpine_common(_json, _atlas, _scale)
				cclog("[_enterPVP3]===Monster===" .. _json)
				coroutine.yield()
			end
		end)
	end
	---------------------------
	if FightSystem.mIsReFight then
		_enterPVP3()
	else
		_loadRoles()
		-- 开始协同
		local _handler = 0
		local function xxx()
			coroutine.resume(_co2)
			if coroutine.status(_co2) == "dead" then
				_enterPVP3()
				cc.Director:getInstance():getScheduler():unscheduleScriptEntry(_handler)
			end
		end
		_handler = nextTick_eachSecond(xxx, 0.1)
	end
end

-- 回包了，准备进入世界boss
function PvpArenaManager:OnPreEnterWorldBoss()
	local function _enterPVP3()
		local _data = {}
		_data.mType = "arena"
		Event.GUISYSTEM_SHOW_FIGHTWINDOW.mData = _data
		EventSystem:PushEvent(Event.GUISYSTEM_SHOW_FIGHTWINDOW)
		-- 给予渲染时间，延迟1秒消失loading窗口
		local function xxx()
			hideLoadingWindow()
		end
		nextTick_frameCount(xxx, 0.05)
	end
	-- 预加载角色
	local function _loadRoles()
		_co2 = coroutine.create(function()
			-- myteam
			local _count = globaldata:getBattleFormationCount()
			for i = 1, _count do
				local _json, _atlas, _scale, _soundList, _skillList = globaldata:getMyFightTeamSpineData(i)
				-- CommonAnimation.preloadSoundList(_soundList)
				-- CommonAnimation.preloadSkillSoundAndEffect(_skillList)
				CommonAnimation.preloadSpine_common(_json, _atlas, _scale)
				cclog("[_enterPVP3]===myteam===" .. _json)
				coroutine.yield()
			end
			-- monster
			local _monsterId = globaldata:getBattleEnemyFormationInfoByIndexAndKey(1, "id")
			local _db = DB_MonsterConfig.getDataById(_monsterId)
			-- cclog("aaa ===" .. _monsterId)
			CommonAnimation.preloadSoundList(_db.SoundList)
			local _skillList = {_db.Monster_NormalSkill1, _db.Monster_NormalSkill2, _db.Monster_NormalSkill3, _db.Monster_NormalSkill4,
								_db.Monster_SpecialSkill1, _db.Monster_SpecialSkill2, _db.Monster_SpecialSkill3, _db.Monster_SpecialSkill4}
			CommonAnimation.preloadSkillSoundAndEffect(_skillList)
			CommonAnimation.preloadSpine_commonByResID(_db.Monster_Model)
		end)
	end
	---------------------------
	if FightSystem.mIsReFight then
		_enterPVP3()
	else
		_loadRoles()
		-- 开始协同
		local _handler = 0
		local function xxx()
			coroutine.resume(_co2)
			if coroutine.status(_co2) == "dead" then
				_enterPVP3()
				cc.Director:getInstance():getScheduler():unscheduleScriptEntry(_handler)
			end
		end
		_handler = nextTick_eachSecond(xxx, 0.1)
	end
end

