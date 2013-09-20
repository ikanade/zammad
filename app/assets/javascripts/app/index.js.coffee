
#= require_self
#= require_tree ./lib/app_init
#= require ./config.js.coffee
#= require_tree ./models
#= require_tree ./controllers
#= require_tree ./views
#= require_tree ./lib/app_post

class App extends Spine.Controller
  @view: (name) ->
    template = ( params = {} ) =>

      # define print name helper
      params.P = ( item, row = {} ) ->
        return '-' if item is undefined
        return '-' if item is ''
        return item if !item

        # if date is a object, get name of the object
        if typeof item is 'object'
          if item.displayNameLong
            return item.displayNameLong()
          else if item.displayName
            return item.displayName()
          return item.name

        # execute callback on content
        if row.callback
          return row.callback( item, row )

        # return raw data
        item

      # define translation helper
      params.T = ( item, args... ) ->
        App.i18n.translateContent( item, args )

      # define translation inline helper
      params.Ti = ( item, args...  ) ->
        App.i18n.translateInline( item, args )

      # define linkify helper
      params.L = ( item ) ->
        window.linkify( item )

      # define config helper
      params.C = ( key ) ->
        App.Config.get( key )

      # define session helper
      params.S = ( key ) ->
        App.Session.get( key )

      # define template
      JST["app/views/#{name}"](params)
    template

window.App = App