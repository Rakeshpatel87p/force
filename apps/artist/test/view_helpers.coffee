sinon = require 'sinon'
helpers = require '../view_helpers'
moment = require 'moment'

describe 'ArtistViewHelpers', ->
  it 'formatAlternateNames', ->
    helpers.formatAlternateNames(alternate_names: []).should.containEql ''
    helpers.formatAlternateNames(alternate_names: ['Joe Shmoe']).should.containEql 'Joe Shmoe'
    helpers.formatAlternateNames(alternate_names: ['Joe Shmoe', 'Someone Else']).should.containEql 'Joe Shmoe; Someone Else'

  it 'displayNationalityAndBirthdate', ->
    helpers.displayNationalityAndBirthdate(nationality: 'American', birthday: '1955')
      .should.containEql 'American, b. 1955'

    helpers.displayNationalityAndBirthdate(nationality: 'American')
      .should.containEql 'American'

    helpers.displayNationalityAndBirthdate(birthday: '1955')
      .should.containEql 'b. 1955'

    helpers.displayNationalityAndBirthdate(nationality: 'American', birthday: '1955', deathday: '2000')
      .should.containEql 'American, 1955–2000'

    helpers.displayNationalityAndBirthdate(nationality: 'American', deathday: '2000')
      .should.containEql 'American'

    helpers.displayNationalityAndBirthdate(birthday: '1955', deathday: '2000')
      .should.containEql '1955–2000'

    helpers.displayNationalityAndBirthdate({}).should.containEql ''

  describe 'formatBirthDeath', ->
    it 'death only', ->
      helpers.formatBirthDeath( deathday: "1990" ).should.eql ''

    it 'birth only', ->
      helpers.formatBirthDeath( birthday: "1920" ).should.eql 'b. 1920'

    it 'birth only with non-birth prefix', ->
      helpers.formatBirthDeath( birthday: "Est 1920" ).should.eql 'Est 1920'

    it 'birth and death', ->
      helpers.formatBirthDeath( birthday: "1920", deathday: "1990" ).should.eql '1920–1990'

    it 'birth and death with non-birth prefix', ->
      helpers.formatBirthDeath( birthday: "Est 1920",  deathday: "Died 1990").should.eql '1920–1990'

    it 'cleans stray characters', ->
      helpers.formatBirthDeath( birthday: "b. 1920", deathday: "Died 1990" ).should.eql '1920–1990'

  describe 'artistMeta', ->
    it 'formats correctly', ->

      artist = hometown: 'New York, New York'
      helpers.artistMeta(artist).should.eql 'New York, New York'

      artist = birthday: '1900', hometown: 'New York, New York'
      helpers.artistMeta(artist).should.eql 'b. 1900, New York, New York'

      artist = location: 'New York, New York'
      helpers.artistMeta(artist).should.eql 'based in New York, New York'

      artist = birthday: '1900', location: 'New York, New York'
      helpers.artistMeta(artist).should.eql 'b. 1900, based in New York, New York'

      artist = birthday: '1900', hometown: 'New York, New York', nationality: 'American', location: 'Chicago, Illinois'
      helpers.artistMeta(artist).should.eql 'American, b. 1900, New York, New York, based in Chicago, Illinois'

      artist = birthday: '1900', deathday: '1970', hometown: 'New York, New York', nationality: 'American', location: 'Chicago, Illinois'
      helpers.artistMeta(artist).should.eql 'American, 1900–1970, New York, New York, based in Chicago, Illinois'

      artist = birthday: '1900', deathday: '1970', nationality: 'American'
      helpers.artistMeta(artist).should.eql ''

  it 'displayFollowers', ->
    result = helpers.displayFollowers(counts: follows: 0)
    (result == undefined).should.be.true()
    helpers.displayFollowers(counts: follows: 1).should.containEql '1'
    helpers.displayFollowers(counts: follows: 4000).should.containEql '4,000'

  it 'mdToHtml', ->
    artist = blurb: "Jeff Koons plays with ideas of taste, pleasure, celebrity, and commerce. “I believe in advertisement and media completely,” he says. “My art and my personal life are based in it.” Working with seductive commercial materials (such as the high chromium stainless steel of his “[Balloon Dog](/artwork/jeff-koons-balloon-dog-blue)” sculptures or his vinyl “Inflatables”), shifts of scale, and an elaborate studio system involving many technicians, Koons turns banal objects into high art icons. His paintings and sculptures borrow widely from art-historical techniques and styles; although often seen as ironic or tongue-in-cheek, Koons insists his practice is earnest and optimistic. “I’ve always loved [Surrealism](/gene/surrealism) and [Dada](/gene/dada) and [Pop](/gene/pop-art), so I just follow my interests and focus on them,” he says. “When you do that, things become very metaphysical.” The “Banality” series that brought him fame in the 1980s included pseudo-[Baroque](/gene/baroque) sculptures of subjects like Michael Jackson with his pet ape, while his monumental topiaries, like the floral _Puppy_ (1992), reference 17th-century French garden design."
    result = helpers.mdToHtml artist, 'blurb'
    result.should.containEql """
      <p>Jeff Koons plays with ideas of taste, pleasure, celebrity, and commerce. “I believe in advertisement and media completely,” he says. “My art and my personal life are based in it.” Working with seductive commercial materials (such as the high chromium stainless steel of his “<a href="/artwork/jeff-koons-balloon-dog-blue">Balloon Dog</a>” sculptures or his vinyl “Inflatables”), shifts of scale, and an elaborate studio system involving many technicians, Koons turns banal objects into high art icons. His paintings and sculptures borrow widely from art-historical techniques and styles; although often seen as ironic or tongue-in-cheek, Koons insists his practice is earnest and optimistic. “I’ve always loved <a href="/gene/surrealism">Surrealism</a> and <a href="/gene/dada">Dada</a> and <a href="/gene/pop-art">Pop</a>, so I just follow my interests and focus on them,” he says. “When you do that, things become very metaphysical.” The “Banality” series that brought him fame in the 1980s included pseudo-<a href="/gene/baroque">Baroque</a> sculptures of subjects like Michael Jackson with his pet ape, while his monumental topiaries, like the floral <em>Puppy</em> (1992), reference 17th-century French garden design.</p>
    """

  it 'formatAuctionDetail', ->
    end = moment.utc('2016-12-05T12:00:00+00:00')
    helpers.formatAuctionDetail(end).should.eql 'Auction Closes Dec 5 at 12 PM'

  describe '#auctionResultsPageTitle', ->

    it 'control auction results title should return default message', ->
      artist =
        id: 'jeff-koons'
        name: 'Jeff Koons'
        counts:
          artworks: 200

      helpers.auctionResultsPageTitle(artist).should.eql 'Auction Results for Jeff Koons on Artsy'