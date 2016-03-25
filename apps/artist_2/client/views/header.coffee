_ = require 'underscore'
Backbone = require 'backbone'
ShareView = require '../../../../components/share/view.coffee'
{ Following, FollowButton } = require '../../../../components/follow_button/index.coffee'

module.exports = class ArtistHeaderView extends Backbone.View
  initialize: ({ @user }) ->
    @setupShareButtons()
    @setupFollowButton()
    @$window = $ window
    @$window.on 'scroll', _.throttle(@popLock, 150)

  setupShareButtons: ->
    new ShareView el: @$('.artist-share')

  setupFollowButton: ->
    @following = new Following(null, kind: 'artist') if @user
    new FollowButton
      analyticsFollowMessage: 'Followed artist, via artist header'
      analyticsUnfollowMessage: 'Unfollowed artist, via artist header'
      el: @$('#artist-follow-button')
      following: @following
      modelName: 'artist'
      model: @model
    new FollowButton
      analyticsFollowMessage: 'Followed artist, via artist header'
      analyticsUnfollowMessage: 'Unfollowed artist, via artist header'
      el: @$('.artist-sticky-follow-button')
      following: @following
      modelName: 'artist'
      model: @model
    @following?.syncFollows [@model.id]

  popLock: =>
    mainHeaderHeight = $('#main-layout-header').height()
    bottomOfMenu = @$window.scrollTop() + mainHeaderHeight
    tabsOffset = @$('.artist-sticky-header').offset().top
    if tabsOffset <= bottomOfMenu
      @$('.artist-sticky-header').addClass('artist-sticky-header-fixed')
      responsiveMargin = $('.main-layout-container').offset().left

    else
      @$('.artist-sticky-header').removeClass('artist-sticky-header-fixed')
