angular.module('Kassa.services', ['ngResource']).factory('Products', ($resource, $window)->
  class Products
    constructor: ($resource)->
      actions =
        index:
          method: 'GET',
          isArray: true
        create:
          method: 'POST'
        update:
          method: 'PUT'
        destroy:
          method: 'DELETE'
      @collection = []
      @$resource = $resource '/products/:id', {id: '@id'}, actions
      @localizedUnits = $window.Kassa.productUnits
      @localizedGroups = $window.Kassa.productGroups
      @$resource.index {}, @_handleCollectionSuccess, @_handleCollectionFailure

    select:(product)=>
      @selected= product
      @selectedInitial = angular.copy product

    unselect: =>
      @editing = false if @selected
      @selected = undefined
      @selectedInitial = undefined

    hasChanges: =>
      return false unless @selected and @selectedInitial
      !angular.equals(@selected, @selectedInitial) and !angular.equals(@selected.materials, @selectedInitial.materials)

    isSelected: (product)=>
      return false unless @selected
      product == @selected

    addEntry: (materialAndAmount)=>
      console.log materialAndAmount
      @selected.materials.push angular.copy(materialAndAmount)

    removeEntry: (index)=>
      if @selected.materials[index].id
        @selected.materials[index].destroy = true
        @selected.materials[index].hidden = true
      else
        @selected.materials.splice index, 1

    save: =>
      if @selected.id then @update() else @create()

    update: =>
      @$resource.update @_toJSON(), @_handleUpdateSuccess, @_handleUpdateFailure if @editing and @selected

    create: =>
      @$resource.create @_toJSON(), @_handleCreateSuccess, @_handleCreateFailure if @selected

    new: =>
      @select {unit: 'piece', group: 'can', materials: [], name: ''}
      @editing = true

    #used to parse only the relevant (changeable) data for server
    _toJSON: ->
      return unless @selected
      product =
        id: @selected.id
        name: @selected.name
        description: @selected.description
        unit: @selected.unit
        group: @selected.group
        materials_attributes: []

      for entry in @selected.materials
        entry.amount = 1 if entry.amount < 1
        product.materials_attributes.push {id: entry.id, amount: entry.amount, material_id: entry.material.id, _destroy: entry.destroy}
      product

    _handleCollectionSuccess: (response, responseHeaders)=>
      for entry in response
        entry.price = parseFloat(entry.price)
      @collection = response

    _handleCollectionFailure: (response, responseHeaders)=>
      console.log response

    _handleUpdateSuccess: (response, responseHeaders)=>
      console.log response
      angular.copy @selected, @selectedInitial

    _handleUpdateFailure: (response, responseHeaders)=>
      console.log response

    _handleCreateSuccess: (response, responseHeaders)=>
      console.log response
      @collection.push response
      @collection.sort

    _handleCreateFailure: (response, responseHeaders)=>
      console.log response

  #Instantiate a single instance of the service
  new Products($resource)
).factory('Users', ($resource)->
  actions =
    index:
      method: 'GET',
      isArray: true
    create:
      method: 'POST'
    update:
      method: 'PUT'
    destroy:
      method: 'DELETE'
  $resource '/users/:id', {id: '@id'}, actions
).factory('Session', ($http)->
  class Session
    constructor: (@$http)->
      @pendingUnauthorizedRequests = []
      @signedIn = {}
      @authenticated = false

    signIn: (credentials, authorized, unauthorized)=>
      @$http.post('/user/sign_in', credentials)
        .success (data, status, headers)=>
          if status == 201 or status == 200
            @_setAuthenticated(data)
            @_checkAndRunCallback(authorized, data, status)
        .error (data, status, headers)=>
          @_clearAuthenticated()
          @_checkAndRunCallback(unauthorized, data, status)

      @signedIn


    signOut: (success, failure)=>
      @$http.delete('/user/sign_out', {})
        .success (data, status)=>
          @_checkAndRunCallback(success, data, status)
        .error (data, status)=>
          @_checkAndRunCallback(failure, data, status)

      @signedIn

    checkStatus: (authorized, unauthorized)=>
      @$http.get('/users/current')
        .success (data, status)=>
          @_setAuthenticated(data)
          @_checkAndRunCallback(authorized, data, status)
        .error (data, status)=>
          @_clearAuthenticated()
          @_checkAndRunCallback(unauthorized, data, status)

      @signedIn

    _setAuthenticated: (data)=>
      @authenticated = true
      @signedIn = data
      @_runPendingRequests()
      return

    _clearAuthenticated: ()=>
      @authenticated = false
      @signedIn = {}
      return

    _checkAndRunCallback: (callback, data, status)->
      callback(data, status) if angular.isFunction callback
      return

    _runPendingRequests: ()=>
      angular.forEach @pendingUnauthorizedRequests, (request)=>
        @$http(request.config).then (response)->
          request.deferred.resolve response

      @pendingUnauthorizedRequests.length = 0
      return

  #return a Session
  new Session($http)
).factory('Materials', ($resource, $window)->
  class Materials
    constructor: ($resource)->
      actions =
        index:
          method: 'GET',
          isArray: true
        create:
          method: 'POST'
        update:
          method: 'PUT'
        destroy:
          method: 'DELETE'
      @collection = []
      @$resource = $resource '/materials/:id', {id: '@id'}, actions
      @localizedUnits = $window.Kassa.materialUnits
      @localizedGroups = $window.Kassa.materialGroups
      @$resource.index {}, @_handleCollectionSuccess, @_handleCollectionFailure

    selectById: (id)=>
      return unless id
      for material in @collection
        select(material) is material.id == id
      return

    select:(material)=>
      @selected= material
      @selectedInitial = angular.copy material

    unselect: =>
      @editing = false if @selected
      @selected = undefined
      @selectedInitial = undefined

    hasChanges: =>
      !angular.equals @selected, @selectedInitial

    isSelected: (material)=>
      if material then @selected == material else false

    save: =>
      if @selected.id then @update() else @create()

    update: ()=>
      @$resource.update @_toJSON(), @_handleUpdateSuccess, @_handleUpdateFailure

    create: =>
      @$resource.create @_toJSON(), @_handleCreateSuccess, @_handleCreateFailure if @selected

    new: =>
      @selected = {unit: 'piece', group: 'can', stock: 1, price: 1}
      @editing = true

    #used to parse only the relevant (changeable) data for server
    _toJSON: =>
      return unless @selected
      material=
        id: @selected.id
        name: @selected.name
        price: @selected.price
        stock: @selected.stock
        unit: @selected.unit
        group: @selected.group
      material

    _handleCollectionSuccess: (response, responseHeaders)=>
      for entry in response
        entry.price = parseFloat(entry.price)
      @collection = response

    _handleCollectionFailure: (response, responseHeaders)=>
      console.log response

    _handleUpdateSuccess: (response, responseHeaders)=>
      console.log response
      angular.copy @selected, @selectedInitial

    _handleUpdateFailure: (response, responseHeaders)=>
      console.log response

    _handleCreateSuccess: (response, responseHeaders)=>
      console.log response
      @collection.push response
      @collection.sort

    _handleCreateFailure: (response, responseHeaders)=>
      console.log response

  #Instantiate the service
  new Materials($resource)
).factory('Buys', ($resource)->
  actions =
    index:
      method: 'GET',
      isArray: true
    create:
      method: 'POST'
  $resource '/buys', {}, actions
).factory('Basket', (Buys)->
  class Basket
    constructor: (@Buys)->
      @products = []

    addProduct: (product)=>
      unless @_incrementIfAlreadyInBasket(product)
        @products.push {product: product, amount: 1, error: ''}

    removeProduct: (index) =>
      @products.splice(index, 1)

    incrementAmount: (index) =>
      @products[index].amount += 1

    decrementAmount: (index) =>
      unless @products[index].amount == 1
        @products[index].amount -= 1

    clearProducts: =>
      @products.length = 0

    clearBuyer: =>
      @buyer = undefined

    clear: =>
      @clearBuyer()
      @clearProducts()

    canBuy: =>
      @buyer and @products.length

    buy: (success, failure) =>
      handleBuySuccess = (response, headers) =>
        @_performClientSideBuy()
        success(response,headers) if success

      handleBuyError = (response,headers)=>
        if response.status == 422
          @_addErrorsToProducts(response.data.errors)
        failure(response, headers) if failure
      @Buys.create @_toJSON(), handleBuySuccess, handleBuyError

    indexOfProduct: (product)=>
      return -1 unless @products.length
      for index in [0..@products.length-1]
        if @products[index].product.name == product.name
          return index
      return -1

    _toJSON: ()=>
      return unless @buyer and @products
      obj = {buyer_id: @buyer.id, products_attributes: []}
      for entry in @products
        obj.products_attributes.push {product_id: entry.product.id, amount: entry.amount}
      obj

    _incrementIfAlreadyInBasket: (product) =>
      index = @indexOfProduct(product)
      @incrementAmount(index) if index != -1
      index != -1

    _performClientSideBuy: =>
      price = 0.0
      product_count = 0
      for entry in @products
        entry.product.stock -= entry.amount
        price += entry.product.price * entry.amount
        product_count += entry.amount
      @buyer.balance -= price
      @buyer.buy_count += product_count
      @clearProducts()
      @clearBuyer()
      return

    _addErrorsToProducts: (errors)=>
      for entry in @products
        product_errors = errors[entry.product.name]
        if angular.isArray(product_errors)
          entry.error = product_errors.join(', ')
        else
          entry.error = product_errors

  #Instantiate the service
  new Basket(Buys)
)