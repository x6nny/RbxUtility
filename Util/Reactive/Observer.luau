local collectionService = game:GetService('CollectionService')

local function observeAttribute<T>(instance: Instance, attribute: string, callback: (value: T) -> ()): () -> ()
	if instance:GetAttribute(attribute) then
		task.spawn(callback, instance:GetAttribute(attribute))
	end

	local connection = instance:GetAttributeChangedSignal(attribute):Connect(function()
		task.spawn(callback, instance:GetAttribute(attribute))
	end)

	return function()
		connection:Disconnect()
	end
end

local function observeAllAttributes(instance: Instance, callBack: (attribute: string, value: any) -> ()): () -> ()
	local attributes = instance:GetAttributes()

	for attribute, value in pairs(attributes) do
		task.spawn(callBack, attribute, value)
	end

	local connection = instance.AttributeChanged:Connect(function(attribute: string)
		local value = instance:GetAttribute(attribute)
		task.spawn(callBack, attribute, value)
	end)

	return function()
		connection:Disconnect()
	end
end

local function observeCharacter(player: Player, characterAdded: (character: Model) -> ()?, characterRemoved: (character: Model) -> ()?): () -> ()
	if player.Character and characterAdded then
		task.spawn(characterAdded, player.Character)
	end

	local added: RBXScriptConnection?
	local removed: RBXScriptConnection?

	if characterAdded then
		added = player.CharacterAdded:Connect(characterAdded)
	end
	if characterRemoved then
		removed = player.CharacterRemoving:Connect(characterRemoved)
	end

	return function()
		if added then
			added:Disconnect()
		end
		if removed then
			removed:Disconnect()
		end
	end
end

local function observeProperty<T>(instance: Instance, property: string, callBack: (value: T) -> ()): () -> ()
	local succ, hasProperty = pcall(function()
		return instance[property] and typeof(instance[property]) ~= 'Instance'
	end)

	local connection: RBXScriptConnection?

	if succ and hasProperty then
		task.spawn(callBack, instance[property] :: any)

		connection = instance:GetPropertyChangedSignal(property):Connect(function()
			task.spawn(callBack, instance[property] :: any)
		end)
	end

	return function()
		if connection then
			connection:Disconnect()
		end
	end
end

local function observeTag(tag: string, tagAdded: (instance: Instance) -> (), tagRemoved: (instance: Instance) -> ()): () -> ()
	for _, v in collectionService:GetTagged(tag) do
		task.spawn(tagAdded, v)
	end

	local added = collectionService:GetInstanceAddedSignal(tag):Connect(tagAdded)
	local removed = collectionService:GetInstanceRemovedSignal(tag):Connect(tagRemoved)

	return function()
		added:Disconnect()
		removed:Disconnect()
	end
end

local function observeChildren(instance: Instance, addedCallback: (child: Instance) -> (), removedCallback: (child: Instance) -> ()): () -> ()
	for _, v in instance:GetChildren() do
		task.spawn(addedCallback, v)
	end

	local added = instance.ChildAdded:Connect(addedCallback)
	local removed = instance.ChildRemoved:Connect(removedCallback)

	return function()
		added:Disconnect()
		removed:Disconnect()
	end
end

local function observeDescendants(instance: Instance, addedCallback: (descendant: Instance) -> (), removedCallback: (descendant: Instance) -> ()): () -> ()
	for _, v in instance:GetDescendants() do
		task.spawn(addedCallback, v)
	end

	local added = instance.DescendantAdded:Connect(addedCallback)
	local removed = instance.DescendantRemoving:Connect(removedCallback)


	return function()
		added:Disconnect()
		removed:Disconnect()
	end
end

local function observeTable<T, K, V>(t: T, onChange: (key: K, value: V) -> ()): (T, () -> T)
	local T = {
		_data = t,
	}
	local self
	self = setmetatable(T, {
		__newindex = function(_, key, value)
			if T._data[key] ~= nil and T._data[key] == value then
				return
			end
			T._data[key] = value
			onChange(key, value)
		end,

		__index = function(_, key)
			return self._data[key]
		end,
	})

	return self, function()
		setmetatable(T :: any, nil)
		return T._data
	end
end

return {
	observeAttribute = observeAttribute,
	observeAllAttributes = observeAllAttributes,
	observeProperty = observeProperty,
	observeCharacter = observeCharacter,
	observeTag = observeTag,
	observeChildren = observeChildren,
	observeDescendants = observeDescendants,
	observeTable = observeTable,
}
