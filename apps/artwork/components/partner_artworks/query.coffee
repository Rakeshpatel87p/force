module.exports = """
  fragment partner_artworks on Artwork {
    partner {
      name
      href
      counts {
        artworks(format: "0,0", label: "work")
      }
      artworks(size: 20, sort:published_at_desc, exclude: [$id]){
        ... artwork_brick
      }
    }
  }
"""
