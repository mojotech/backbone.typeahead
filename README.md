[![Build Status](https://travis-ci.org/mojotech/backbone.typeahead.png)](https://travis-ci.org/mojotech/backbone.typeahead)

## Backbone Typeahead

Integrates typeahead search into backbone collections.

View the [online demo](http://mojotech.github.io/backbone.typeahead).

### Examples

```coffeescript
class Albums extends Backbone.TypeaheadCollection
  typeaheadAttributes: ['band', 'name', 'meta.members']

albums = new Albums([
  { band: 'A Flock of Seagulls', name: 'A Flock of Seagulls', meta: { members: ['Mike Score'] }}
  { band: 'Rick Astley', name: 'Whenever You Need Somebody', meta: { members: ['Rick Astley'] }}
  { band: 'Queen', name: 'A Day at the Races', meta: { members: ['Freddie Mercury', 'Brian May'] }}
  { band: 'Queen', name: 'Tie Your Mother Down', meta: { members: ['Freddie Mercury', 'Brian May'] }}
])

console.log album.get('name') for album in albums.typeahead('you')
# Outputs:
#  Whenever You Need Somebody
#  Tie Your Mother Down

console.log album.get('name') for album in albums.typeahead('ra', band: 'Queen')
# Outputs:
#  A Day at the Races

console.log album.get('name') for album in albums.typeahead('fred')
# Outputs:
#  A Day at the Races
#  Tie Your Mother Down
```

Inspired by Twitter's [typeahead.js](http://twitter.github.io/typeahead.js/).
