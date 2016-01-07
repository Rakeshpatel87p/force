_ = require 'underscore'
Backbone = require 'backbone'
mediator = require '../../lib/mediator.coffee'
analyticsHooks = require '../../../lib/analytics_hooks.coffee'
{ modelNameAndIdToLabel } = require '../../../analytics/helpers.js'

module.exports = class FollowButton extends Backbone.View

  events:
    'click': 'toggle'
    'touchstart': () -> @$el.removeClass "no-touch"

  initialize: (options) ->
    { @following, @notes, @modelName, @href } = options

    @label = if options.label then options.label else "#{@modelName}s"

    return unless @following

    throw new Error('Requires @modelName') unless @modelName

    @listenTo @following, "add:#{@model.id}", @change
    @listenTo @following, "remove:#{@model.id}", @change

    @analyticsFollowMessage = options.analyticsFollowMessage or @defaultAnalyticsMessage('Followed')
    @analyticsUnfollowMessage = options.analyticsUnfollowMessage or @defaultAnalyticsMessage('Unfollowed')

    @$el.addClass "no-touch"

    @change()

  defaultAnalyticsMessage: (action) ->
    "#{action} #{@modelName} from #{window?.location.pathname}"

  change: ->
    state = if @following.isFollowing(@model.id) then 'following' else 'follow'
    @$el.attr 'data-state', state

  toggle: (e) ->
    @trigger 'click'

    unless @following
      analyticsHooks.trigger 'follow:sign-up'
      mediator.trigger 'open:auth',
        mode: 'register'
        copy: "Sign up to follow #{@label}"
        destination: @href || "#{@model.href()}/follow"
      return false

    if @following.isFollowing @model.id
      @following.unfollow @model.id
      mediator.trigger 'follow-button:unfollow', @$el, @model
      analyticsHooks.trigger 'followable:unfollowed',
        label: modelNameAndIdToLabel(@modelName, @model.id)
        message: @analyticsUnfollowMessage
    else
      @following.follow @model.id, notes: (@notes or @analyticsFollowMessage)
      # Delay label change
      @$el.addClass 'is-clicked'
      setTimeout (=> @$el.removeClass 'is-clicked'), 1500
      mediator.trigger 'follow-button:follow', @$el, @model
      aanalyticsHooks.trigger 'followable:followed',
        label: modelNameAndIdToLabel(@modelName, @model.id)
        message: @analyticsUnfollowMessage

    false
