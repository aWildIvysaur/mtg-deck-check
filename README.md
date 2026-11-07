# Magic: The Gathering deck checker
Using scryfall's API, checks to see if your MTG deck is legal in your favourite format<br>
Including:
- The correct number of cards
- All cards are legal in the format

## Usage:
### Format:
Defaults to checking `deck.txt` <br>
Format can be included above decklist, if not you wil be asked as the decklist is read. <br>
All  formats supported on scryfall/ oracle are supported here.<br>
Format names are case-insensitive; use Scryfall's format key without spaces (for example,
`standardbrawl` or `paupercommander`).
### Headers:
`mainboard` and `sideboard` header should be used but are case-insensitive, as are card names which should be paired with the quantity in the same line. <br>

### Example:
```
Pauper
Mainboard
1 Forest
Gruul Turf 3

sideboard
1 Abandon Attachments```
