class @PromiseDB
	constructor: (@iDB) ->

	@open: (name, version, upgradeCallback) ->
		new Promise (resolve, reject) ->
			if version?
				request = indexedDB.open name, version
			else
				request = indexedDB.open name
				
			request.onerror = ->
				reject(Error(request.error))			
			request.onsuccess = ->
				resolve(new PromiseDB(request.result))
			request.onupgradeneeded = ->
				upgradeCallback?(new PromiseDB(request.result))

	@delete = (name) ->
		new Promise (resolve, reject) ->
			request = indexedDB.deleteDatabase name
			request.onerror = ->
				reject(Error(request.error))
			request.onsuccess = ->
				resolve()

	Object.defineProperties @prototype,
		version:
			get: ->
				@iDB.version
		objectStoreNames:
			get: ->
				@iDB.objectStoreNames

	createObjectStore: (name, options) =>
		new PromiseDB.ObjectStore(@iDB.createObjectStore(name, options))

	deleteObjectStore: (name) =>
		new PromiseDB.ObjectStore(@iDB.deleteObjectStore(name, options))		

	transaction: (objectStores, mode = 'readonly') =>
		new PromiseDB.Transaction(@iDB.transaction(objectStores, mode))

	close: =>
		@iDB.close()		

class @PromiseDB.Transaction
	constructor: (@iDBTransaction) ->

	objectStore: (name) =>
		new PromiseDB.ObjectStore(@iDBTransaction.objectStore(name))

class @PromiseDB.Request
	constructor: (@iDBRequest) ->

class @PromiseDB.Index
	constructor: (@iDBIndex) ->

	openCursor: (range, direction = 'next') =>
		new Promise (resolve, reject) =>
			request = @iDBIndex.openCursor(range, direction)
			request.onerror = ->
				reject(request.error)
			request.onsuccess = ->
				resolve(request.result)

	openKeyCursor: (range, direction = 'next') ->
		new Promise (resolve, reject) =>
			request = @iDBIndex.openKeyCursor(range, direction)
			request.onerror = ->
				reject(request.error)
			request.onsuccess = ->
				resolve(request.result)

	get: (key) =>
		new Promise (resolve, reject) =>
			request = @iDBIndex.get(key)
			request.onerror = ->
				reject(request.error)
			request.onsuccess = ->
				resolve(request.result)

	getKey: (key) =>
		new Promise (resolve, reject) =>
			request = @iDBIndex.getKey(key)
			request.onerror = ->
				reject(request.error)
			request.onsuccess = ->
				resolve(request.result)

	count: (key) =>
		new Promise (resolve, reject) =>
			request = @iDBIndex.getKey(key)
			request.onerror = ->
				reject(request.error)
			request.onsuccess = ->
				resolve(request.result)	

class @PromiseDB.ObjectStore
	constructor: (@iDBStore) ->

	add: (obj, id) =>
		new Promise (resolve, reject) =>
			obj[key] = id if @iDBStore.keyPath? and id?

			request = @iDBStore.add(obj, id)
			request.onerror = ->
				reject(request.error)
			request.onsuccess = ->
				resolve(request.result)

	clear: =>
		new Promise (resolve, reject) =>
			request = @iDBStore.clear()
			request.onerror = ->
				reject(request.error)
			request.onsuccess = ->
				resolve(request.result)


	delete: (id) =>
		new Promise (resolve, reject) =>
			request = @iDBStore.delete(id)
			request.onerror = ->
				reject(request.error)
			request.onsuccess = ->
				resolve(request.result)

	get: (id) =>
		new Promise (resolve, reject) =>
			request = @iDBStore.get(id)
			request.onerror = ->
				reject(request.error)
			request.onsuccess = ->
				resolve(request.result)


	put: (obj, id) =>
		new Promise (resolve, reject) =>
			obj[key] = id if @iDBStore.keyPath? and id?
			
			request = @iDBStore.put(obj, id)
			request.onerror = ->
				reject(request.error)
			request.onsuccess = ->
				resolve(request.result)

	index: (name) =>
		new PromiseDB.Index(@iDBStore.index(name))

	createIndex: (name, keyPath, options) =>
		new PromiseDB.Index(@iDBStore.createIndex(name, keyPath, options))

	deleteIndex: (name) =>
		@iDBStore.deleteIndex(name)