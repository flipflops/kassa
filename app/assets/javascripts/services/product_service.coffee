angular.module('kassa').factory('ProductService',[
  '$http'
  '$routeParams'
  '$rootScope'
  'CacheService'
  ($http, $routeParams, $rootScope, Cache)->
    [isArray, isObject, isNumber, copy] = [angular.isArray, angular.isObject, angular.isNumber, angular.copy]
    CACHE_PREFIX = 'product'

    #handle price as a float, not a string
    convert = (product)->
      product.price = parseFloat(product.price)

    cacheProduct = (product)-> Cache.set(product, CACHE_PREFIX)

    convert = (resp)->
      products = resp.data.products
      if products?
        _.forEach products, convert
      else
        convert(resp.data.product)
      resp

    getFromResponse = (resp)-> resp.data.product || resp.data.products

    broadcastNewProduct = (product)->
      $rootScope.$broadcast 'product:new', product
      product

    all = ->
      $http.get('/products').then(convert).then(getFromResponse).then (products)->
        _.forEach products, cacheProduct
        #rewrite all loader function to use the now fully populated cache
        exports.all = all = -> Cache.getAllByPrefix(CACHE_PREFIX)
        all()

    find = (id)->
      Cache.getByIdentity(id, CACHE_PREFIX).then (product)->
        return product if isObject(product) && isNumber(product.id)
        $http.get("/products/#{id}").then(convert).then(getFromResponse).then(cacheProduct)

    currentByRoute = -> find($routeParams.id)

    update = (product)-> $http.put("/products/#{product.id}", product: product).then(convert).then(getFromResponse).then(cacheProduct)

    create = (product)-> $http.post('/products', {product}).then(convert).then(getFromResponse).then(cacheProduct).then(broadcastNewProduct)


    $rootScope.$on 'buys:new', (event, buy)->
      _.forEach buy.consistsOfProducts, (buyEntry)->
        Cache.getByIdentity(buyEntry.productId, CACHE_PREFIX).then (product)->
          if isObject(product)
            buyEntry.product = copy(buyEntry.product, product)
          else
            convert(buyEntry.product)
            cacheProduct(buyEntry.product)

    exports = {all, find, currentByRoute, update, create}
])