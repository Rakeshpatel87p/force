_ = require 'underscore'
sd = require('sharify').data
Backbone = require 'backbone'
mediator = require '../../../../lib/mediator.coffee'
Sticky = require '../../../../components/sticky/index.coffee'
Artworks = require '../../../../collections/artworks.coffee'
ArtworkFilter = require '../../../../components/artwork_filter/index.coffee'
BorderedPulldown = require '../../../../components/bordered_pulldown/view.coffee'
template = -> require('../../templates/sections/works.jade') arguments...

module.exports = class WorksView extends Backbone.View
  subViews: []

  initialize: ({ @user, @statuses }) ->
    @sticky = new Sticky

  fadeInSection: ($el) ->
    $el.show()
    _.defer -> $el.addClass 'is-fade-in'
    $el

  setupArtworkFilter: ->
    filterRouter = ArtworkFilter.init
      el: @$('#artwork-section')
      model: @model
      mode: 'grid'
      showSeeMoreLink: false
    @subViews.push filterRouter.view
    @sticky.headerHeight = $('#main-layout-header').outerHeight(true) +
      $('.artist-sticky-header-container').outerHeight(true) + 20
    @sticky.add @$('#artwork-filter-selection')
    $.onInfiniteScroll ->
      filterRouter.view.loadNextPage()

  postRender: ->
    @setupArtworkFilter()

  render: ->
    @$el.html template hasWorks: @statuses.artworks
    _.defer => @postRender()
    this

  remove: ->
    $(window).off 'infiniteScroll'
    _.invoke @subViews, 'remove'