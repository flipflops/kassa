angular.module('kassa.materials', ['kassa.common'])
.service('Materials', (BaseService)->
  class Materials extends BaseService
    constructor: ()->
      options =
        id:'@id'
      actions=
        index:
          method: 'GET'
        create:
          method: 'POST'
        update:
          method: 'PUT'
        destroy:
          method: 'DELETE'
      super '/materials/:id', options, actions
    
    updateChanged: (materials...)->
      @_update materials...

  return new Materials()
)
