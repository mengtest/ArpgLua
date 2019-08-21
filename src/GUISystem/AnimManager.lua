-- Name: 	AnimManager
-- Func：	特效管理
-- Author:	WangShengdong
-- Data:	15-12-1

AnimManager = {}

-- 记录当前添加进的AnimFile信息
AnimManager.mCurAnimFileList = {}


local animObject = {}

function animObject:new(resId)
	local o = 
	{
		mResId 			= 	resId,	-- 对应的资源ID
		mRootNode		=	nil,    -- 跟节点
		mNeedLoop		=	nil,	-- 是否循环
		mFuncCallback1	=	nil,	-- 回调函数
		mFuncCallback2  =   nil,    -- 帧事件回调函数
	}
	o = newObject(o, animObject)
	return o
end

-- 初始化
function animObject:init()
	local resData = DB_ResourceList.getDataById(self.mResId)
	local animName = resData.Res_path2
	local scaleVal = resData.Res_path3
	self.mRootNode = ccs.Armature:create(animName)
	self.mRootNode:setScale(scaleVal)
	self.mRootNode:getAnimation():setMovementEventCallFunc(handler(self, self.animationEvent))
	self.mRootNode:getAnimation():setFrameEventCallFunc(handler(self, self.animationFrameEvent))
end

-- 显示&隐藏
function animObject:setVisible(visible)
	if self.mRootNode then
		self.mRootNode:setVisible(visible)
	end
end

-- 销毁
function animObject:destroy()
	if self.mRootNode then
		self.mRootNode:removeFromParent(true)
		self.mRootNode = nil
	end
end

-- 播放(如果不循环的话,播放结束后自行销毁)
function animObject:play(animName, needLoop, func1, func2)
	if needLoop then
		self.mRootNode:getAnimation():play(animName, -1, 1)
		self.mNeedLoop = true
	else
		self.mRootNode:getAnimation():play(animName, -1, 0)
		self.mNeedLoop = false
	end
	self.mFuncCallback1 = func1
	self.mFuncCallback2 = func2
end

-- 停止
function animObject:stop()
	self.mRootNode:getAnimation():stop()
end

-- 暂停
function animObject:pause()
	self.mRootNode:getAnimation():pause()
end

-- 继续
function animObject:resume()
	self.mRootNode:getAnimation():resume()
end

-- 获取跟节点
function animObject:getRootNode()
	return self.mRootNode
end

-- 设置位置
function animObject:setPosition(pos)
	self.mRootNode:setPosition(pos)
end

-- 事件回调
function animObject:animationEvent(armatureBack, movementType, movementID)
	if movementType == ccs.MovementEventType.start then
		
	elseif movementType == ccs.MovementEventType.complete then
		if not self.mNeedLoop then -- 没有循环
			if self.mFuncCallback1 then -- 有回调就回调一次
				self.mFuncCallback1(self)
				self.mFuncCallback1 = nil
			else -- 没有回调
				self:destroy()
			end
		end
	elseif movementType == ccs.MovementEventType.loopComplete then

	end
end

-- 帧事件回调
function animObject:animationFrameEvent(bone, evt, originFrameIndex, currentFrameIndex)
	if self.mFuncCallback2 then
		self.mFuncCallback2(evt)
	end
end

-- 添加文件信息(private)
local function addAnimFileInfo(animResId)
	if not AnimManager.mCurAnimFileList[tostring(animResId)] then
		local resData = DB_ResourceList.getDataById(animResId)
		local fileName = resData.Res_path1
		ccs.ArmatureDataManager:getInstance():addArmatureFileInfo(fileName)
		AnimManager.mCurAnimFileList[tostring(animResId)] = fileName -- 记录
	end
end

-- 删除文件信息
function AnimManager:removeAnimFileInfo(animResId)
	if self.mCurAnimFileList[tostring(animResId)] then
		local resData = DB_ResourceList.getDataById(tonumber(animResId))
		local fileName = resData.Res_path1
		ccs.ArmatureDataManager:getInstance():removeArmatureFileInfo(fileName)
		self.mCurAnimFileList[tostring(animResId)] = nil -- 删除
	end
end

-- 删除所有文件信息
function AnimManager:removeAllAniFileInfo()
	for resId,fileName in pairs(self.mCurAnimFileList) do
		self:removeAnimFileInfo(resId)
	end
	ccs.ArmatureDataManager:destroyInstance()
end

-- 创建一个动画节点
function AnimManager:createAnimNode(animResId)
	if not self.mCurAnimFileList[tostring(animResId)] then -- 如果没有文件信息
		addAnimFileInfo(animResId)
	end

	local animNode = animObject:new(animResId)
	animNode:init()

	return animNode
end

-- 打印当前缓存的动画文件名
function AnimManager:printAllAnimFileInfo()
	for k, v in pairs(self.mCurAnimFileList) do
		print(v)
	end
end



