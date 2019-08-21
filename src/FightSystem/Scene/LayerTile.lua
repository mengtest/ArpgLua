-- Name: LayerTile
-- Func: 分层上的图片垂直切条，即时加载与释放，用于缓解内存压力
-- Author: Johny

local _PATH_SCENE = "res/scene"

LayerTile = class("LayerTile",function()
  return cc.Sprite:create()
end)

--[[ 
	_layerKey: 索引到分层贴图所在文件夹
	_tileNum: 第几个切块
]]
function LayerTile:ctor(_mapKey, _layerKey, _tileNum)
	self.mMapKey = _mapKey
	self.mLayerKey = _layerKey
	self.mTileNum = _tileNum
	local _ext = "png"
	local s_tileNum = tostring(_tileNum)
	if _tileNum >= 1 and _tileNum <= 9 then
	   s_tileNum = string.format("0%d", _tileNum)
	end
	self.mFilePath = string.format("%s/%s/%d/%s_%d_%s.%s", _PATH_SCENE, _mapKey, _layerKey, _mapKey, _layerKey, s_tileNum, _ext)
	self.mIsLoaded = false
end

-- 加载图片，io -> cache -> gpu
function LayerTile:loadTextureFromIO()
	if FightConfig.__DEBUG_CLOSELOAD_SCENE_ then return end
	if self.mIsLoaded then return end
	self:setProperty("Image", self.mFilePath)
	self:getTexture():setAliasTexParameters()
	self.mIsLoaded = true
end

-- 卸载图片，gpu->cache->io
function LayerTile:unloadTextureFromCache()
	-- 确保安卓场景移动顺滑，不卸载
	if EngineSystem:getOS() == "ANDROID" then return end
	if not self.mIsLoaded then return end
	self:setTexture(nil)
	TextureSystem:UnLoadImage(self.mFilePath)
	self.mIsLoaded = false
end

