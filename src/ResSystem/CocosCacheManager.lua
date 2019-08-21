-- Func: cocos控件缓存管理器,暂时安卓需要
-- Author: Johny

CocosCacheManager = {}

function CocosCacheManager:init()
	-- 各种控件缓存池
	self.mCache_LabelBMFont = {}
end

-- 初始化艺术字列表
function CocosCacheManager:initLabelBMFontList(_count)
	for i = 1,_count do
		local _lb = ccui.TextBMFont:create()
		_lb:retain()
		table.insert(self.mCache_LabelBMFont, _lb)
	end
end

-- 销毁艺术字列表
function CocosCacheManager:destroyLabelBMFontList()
	for k,_lb in pairs(self.mCache_LabelBMFont) do
		_lb:release()
	end
	self.mCache_LabelBMFont = {}
end

function CocosCacheManager:Tick()

end

-- 获取艺术字
function CocosCacheManager:getLabelBMFont(_path)
    -- local _lb = ccui.TextBMFont:create()
    local _lb = self.mCache_LabelBMFont[1]
    table.remove(self.mCache_LabelBMFont, 1)
    if _lb == nil then
       	_lb = ccui.TextBMFont:create()
		_lb:retain()
    end
    _lb:setFntFile(_path)
	return _lb
end

-- 归还spine
function CocosCacheManager:collectLabelBMFont(_lb)
	table.insert(self.mCache_LabelBMFont, _lb)
end   