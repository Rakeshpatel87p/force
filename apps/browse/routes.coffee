Q = require 'q'
_ = require 'underscore'
_.mixin require 'underscore.string'
OrderedSets = require '../../collections/ordered_sets.coffee'
Genes = require '../../collections/genes.coffee'
FilterSuggest = require '../../models/filter_suggest.coffee'
{ API_URL } = require('sharify').data

renderCanonicalTag = (req) ->
  if Object.keys(req.query)?.length > 0 then false else true

@index = (req, res) ->
  featuredGenes = new OrderedSets(key: 'browse:featured-genes')
  popularCategories = new OrderedSets(key: 'browse:popular-categories')
  filterSuggest = new FilterSuggest(id: 'main')
  Q.allSettled([
    featuredGenes.fetchAll(cache: true)
    popularCategories.fetchAll(cache: true)
    filterSuggest.fetch(cache: true)
  ]).then ->
    res.render 'index',
      featuredGenes: featuredGenes
      popularCategories: popularCategories
      mediums: filterSuggest.mediumsHash()
      showBrowseCategories: true
      filterRoot: '/browse/artworks'
      renderCanonicalTag: renderCanonicalTag(req)

@categories = (req, res) ->
  geneCategories = new OrderedSets(key: 'browse:gene-categories')
  geneCategories.fetchAll
    cache: true
    success: ->
      new Genes().fetchUntilEnd
        data: { size: 100, published: true, sort: "name" }
        url: "#{API_URL}/api/v1/genes"
        cache: true
        success: (genes) ->
          aToZGroup = genes.groupByAlphaWithColumns 3
          res.render 'categories',
            geneCategories: geneCategories
            aToZGroup: aToZGroup

@filter = (req, res) ->
  filterSuggest = new FilterSuggest(id: 'main')
  filterSuggest.fetch
    cache: true
    success: ->
      res.render 'index',
        showBrowseCategories: false
        filterRoot: '/browse/artworks'
        mediums: filterSuggest.mediumsHash()
        renderCanonicalTag: renderCanonicalTag(req)

@redirectToCategories = (req, res) ->
  res.redirect '/categories'

@redirectToBrowse = (req, res) ->
  res.redirect '/browse'
