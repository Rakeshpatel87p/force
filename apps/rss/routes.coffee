_ = require 'underscore'
sd = require('sharify').data
Articles = require '../../collections/articles'
Section = require '../../models/section'
PAGE_SIZE = 100
PAGE_SIZE_FACEBOOK = 50

@news = (req, res, next) ->
  new Articles().fetch
    data:
      featured: true
      published: true
      sort: '-published_at'
      exclude_google_news: false
      limit: PAGE_SIZE
    error: res.backboneError
    success: (articles) ->
      res.set('Content-Type', 'application/rss+xml')
      res.render('news', articles: articles, pretty: true)

@instantArticles = (req, res, next) ->
  new Articles().fetch
    data:
      featured: true
      published: true
      sort: '-published_at'
      limit: PAGE_SIZE_FACEBOOK
    error: res.backboneError
    success: (articles) ->
      articles.each (article) -> article.prepForInstant()
      res.set('Content-Type', 'application/rss+xml')
      res.render 'instant_articles',
        articles: articles
        pretty: true

@partnerUpdates = (req, res, next) ->
  section = new Section id: 'artsy-partner-updates'
  articles = new Articles

  section.fetch()
    .then ->
      articles.fetch
        data:
          section_id: section.get('id')
          published: true
          sort: '-published_at'
          limit: PAGE_SIZE
    .then ->
      res.set('Content-Type', 'application/rss+xml')
      res.render('partner_updates', articles: articles, pretty: true)
    .catch res.backboneError

