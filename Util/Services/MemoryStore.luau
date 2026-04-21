local memoryStoreService = game:GetService('MemoryStoreService')

export type memoryStore = {
	map: MemoryStoreHashMap
}

local function new(name: string): memoryStore
	return {
		map = memoryStoreService:GetHashMap(name)
	}
end

local function getQueue(memoryStore: memoryStore, name: string, invisibilityTimeout: number?): MemoryStoreQueue
	return memoryStoreService:GetQueue(name, invisibilityTimeout)
end

local function getSortedMap(memoryStore: memoryStore, name: string): MemoryStoreSortedMap
	return memoryStoreService:GetSortedMap(name)
end

local function setAsync(memoryStore: memoryStore, key: string, value: any, expire: number): boolean
	return memoryStore.map:SetAsync(key, value, expire)
end

local function getAsync(memoryStore: memoryStore, key: string): any
	return memoryStore.map:GetAsync(key)
end

local function removeAsync(memoryStore: memoryStore, key: string)
	memoryStore.map:RemoveAsync(key)
end

local function updateAsync(memoryStore: memoryStore, key: string, transform: (value: any) -> any, expire: number): any
	return memoryStore.map:UpdateAsync(key, transform, expire)
end

local function listItemsAsync(memoryStore: memoryStore, count: number): MemoryStoreHashMapPages
	return memoryStore.map:ListItemsAsync(count)
end

return {
	new = new,
	getQueue = getQueue,
	getSortedMap = getSortedMap,
	setAsync = setAsync,
	getAsync = getAsync,
	removeAsync = removeAsync,
	updateAsync = updateAsync,
	listItemsAsync = listItemsAsync
}
