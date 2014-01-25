rewire        = require 'rewire'
benv          = require 'benv'
Backbone      = require 'backbone'
sinon         = require 'sinon'
CurrentUser   = require '../../../../models/current_user.coffee'
Artworks      = require '../../../../collections/artworks.coffee'
_             = require 'underscore'
{ resolve }   = require 'path'
{ fabricate } = require 'antigravity'

describe 'FavoritesView', ->

  before (done) ->
    sinon.stub _, 'defer'
    benv.setup =>
      benv.expose { $: benv.require 'components-jquery' }
      Backbone.$ = $
      done()

  after ->
    _.defer.restore()
    benv.teardown()

  describe 'without favorites items', ->

    beforeEach (done) ->
      sinon.stub Backbone, 'sync'
      benv.render resolve(__dirname, '../../templates/favorites.jade'), {
        sd: {}
      }, =>
        { FavoritesView, @init } = mod = benv.requireWithJadeify(
          (resolve __dirname, '../../client/favorites'), ['artworkColumns', 'hintTemplate']
        )
        artworks = new Artworks()
        sinon.stub artworks, "fetchUntilEnd", (options) -> options.success?()
        @SuggestedGenesView = sinon.stub()
        @SuggestedGenesView.render = sinon.stub()
        @SuggestedGenesView.returns @SuggestedGenesView
        mod.__set__ 'SuggestedGenesView', @SuggestedGenesView
        mod.__set__ 'CurrentUser',
          orNull: -> _.extend fabricate 'user',
            initializeDefaultArtworkCollection: -> return
            defaultArtworkCollection: -> return
        @view = new FavoritesView
          el: $ 'body'
          collection: artworks
        done()

    afterEach ->
      Backbone.sync.restore()

    describe '#showEmptyHint', ->

      it 'shows suggested genes genes', ->
        @SuggestedGenesView.render.should.calledOnce

  describe 'with favorites items', ->

    beforeEach (done) ->
      sinon.stub Backbone, 'sync'
      benv.render resolve(__dirname, '../../templates/favorites.jade'), {
        sd: {}
      }, =>
        { FavoritesView, @init } = mod = benv.requireWithJadeify(
          (resolve __dirname, '../../client/favorites'), ['hintTemplate']
        )
        artworks = new Artworks()
        sinon.stub artworks, "fetchUntilEnd", (options) ->
          artworks.add [
            { artwork: fabricate 'artwork', id: 'artwork1' },
            { artwork: fabricate 'artwork', id: 'artwork2' },
            { artwork: fabricate 'artwork', id: 'artwork3' },
            { artwork: fabricate 'artwork', id: 'artwork4' },
            { artwork: fabricate 'artwork', id: 'artwork5' },
            { artwork: fabricate 'artwork', id: 'artwork6' },
          ]
          options.success?()
        mod.__set__ 'CurrentUser',
          orNull: -> _.extend fabricate 'user',
            initializeDefaultArtworkCollection: sinon.stub()
            defaultArtworkCollection: sinon.stub()
        @artworkColumns = sinon.stub()
        mod.__set__ 'artworkColumns', @artworkColumns
        mod.__set__ 'SaveControls', sinon.stub()
        @view = new FavoritesView
          el: $ 'body'
          collection: artworks
          numOfCols: 2
          numOfRowsPerPage: 1
        done()

    afterEach ->
      Backbone.sync.restore()

    describe '#initialize', ->

      it 'sets up following items collection of the current user', ->
        @view.collection.length.should.equal 6

    describe '#loadNextPage', ->

      it 'calls artworkColumns to render the first page', ->
        @view.nextPage.should.equal 2
        @artworkColumns.should.calledOnce
        @artworkColumns.args[0][0].artworkColumns.length.should.equal 2

      it 'renders the next pages individually until the end', ->
        @view.loadNextPage()
        @view.nextPage.should.equal 3
        _.last(@artworkColumns.args)[0].artworkColumns[0][0].attributes.artwork.id.should.equal 'artwork3'
        _.last(@artworkColumns.args)[0].artworkColumns[1][0].attributes.artwork.id.should.equal 'artwork4'
        @view.loadNextPage()
        @view.nextPage.should.equal 4
        _.last(@artworkColumns.args)[0].artworkColumns[0][0].attributes.artwork.id.should.equal 'artwork5'
        _.last(@artworkColumns.args)[0].artworkColumns[1][0].attributes.artwork.id.should.equal 'artwork6'
