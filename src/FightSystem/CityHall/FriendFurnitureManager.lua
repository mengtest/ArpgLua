-- Func: 好友家具管理器,静态方法
-- Author: Johny

FriendFurnitureManager = {}

-- 载入家具
function FriendFurnitureManager:loadFurnitures(_furnitrueList, _root)
	local function loadOneFur(_fur)
		local _db = DB_ItemConfig.getDataById(_fur.itemid)
		local _db2 = DB_SceneAnimationConfig.getDataById(_db.Animation)
		local _resDB = DB_ResourceList.getDataById(_db2.Animation_ResID)
		local _spine = CommonAnimation.createSpine_common(_resDB.Res_path2, _resDB.Res_path1, 1)
		_spine:setPosition(cc.p(_fur.x, _fur.y))
		_root:addChild(_spine)

		-- 设置地图阻挡
		local configInfo = DB_SceneAnimationConfig.getDataById(_db.Animation)
		local resInfo = DB_ResourceList.getDataById(configInfo.Animation_ResID)
		local size = cc.size(configInfo.Animation_FootSize[1], configInfo.Animation_FootSize[2])
		local rect = cc.rect(_fur.x-size.width/2, _fur.y-size.height/2, size.width, size.height)
		FightSystem:setMapInfoForRect(cc.p(rect.x, rect.y), rect.width, rect.height, 0)
	end
	for i = 1, #_furnitrueList do
		local _fur = _furnitrueList[i]
		loadOneFur(_fur)
	end
end

