Backbone = require 'backbone'
State = require '../branching_state/index.coffee'
{ fade } = require '../mixins/transition.coffee'
map = require './map.coffee'
debug = require './debug.coffee'

module.exports = class InquiryQuestionnaireView extends Backbone.View
  className: 'inquiry-questionnaire'

  initialize: ({ @user, @artwork, prequalify }) ->
    @state = new State map
    @state.inject user: @user, state: @state
    @listenTo @state, 'next', @render

  render: ->
    pendingView = @state.view user: @user, state: @state, artwork: @artwork

    debug @state

    if ($parent = @$el.parent()).length
      fade $parent,
        out: =>
          @$el.html pendingView.render().$el
        in: =>
          @view?.remove()
          @view = pendingView
    else
      @$el.html (@view = pendingView).render().$el

    this