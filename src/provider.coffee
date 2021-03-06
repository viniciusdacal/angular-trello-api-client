angular.module 'trello-api-client'
.provider 'TrelloClient', ($authProvider, TrelloClientConfig) ->
  @init = (config) ->
    return unless config?
    angular.extend TrelloClientConfig, config

    $authProvider.tokenPrefix = TrelloClientConfig.localStoragePrefix
    $authProvider.httpInterceptor = (request) -> false
    $authProvider.oauth2 {
      name: TrelloClientConfig.appName
      key: TrelloClientConfig.key
      returnUrl: window.location.origin
      authorizationEndpoint: "#{ TrelloClientConfig.authEndpoint }/#{ TrelloClientConfig.version }/authorize"
      defaultUrlParams: ['response_type', 'key', 'return_url', 'expiration', 'scope', 'name']
      requiredUrlParams: null
      optionalUrlParams: null
      scope: TrelloClientConfig.scope
      scopeDelimiter: ','
      type: 'redirect'
      popupOptions: TrelloClientConfig.popupOptions
      responseType: 'token'
      expiration: TrelloClientConfig.tokenExpiration
    }

  @$get = ($location, $http, $window, $auth) ->
    baseURL = "#{ TrelloClientConfig.apiEndpoint }/#{ TrelloClientConfig.version }"
    TrelloClient = {}
    TrelloClient.authenticate = ->
      $auth.authenticate(TrelloClientConfig.appName).then (response)->
        $auth.setToken response.token
        return response
    for method in ['get', 'post', 'put', 'delete']
      do (method) ->
        TrelloClient[method] = (endpoint, config) ->
          config ?= {}
          config.trelloRequest = true # for interceptor
          return unless $auth.isAuthenticated()
          $http[method] baseURL + endpoint, config

    return TrelloClient
  return
