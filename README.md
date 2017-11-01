# Online Bookstore

## Application Model Specifications

Code for the other models are not implemented but described below.  All models have an “id” field as their primary key.

### Publisher

Each book is associated with a single publisher.  Assume there will be ~100 total.
Key fields:

* `#name` (string)

### Author

Each book is written by a single author.   Assume there will be ~100,000 total
Key fields:

* `#first_name` (string)
* `#last_name` (string)

### BookFormatType

The formats that a book may be available in.  Assume there will be ~10 total
Key fields:

* `#name` (string)  such as “Hardcover”, “Softcover” , “Kindle”, “PDF”
* `#physical` (boolean)   True means a physical format, false means an electronic format

### BookFormat

A many-to-many relationship model between Books and their Formats
Key fields:

* `#book_id` (integer)
* `#book_format_type_id` (integer)

### BookReview

A user’s opinion on a book.  Assume there will be ~100 per book.  
Key fields:

* `#book_id` (integer)
* `#rating` (integer), in the range 1-5 (5 being the best).  Cannot be nil.  

## Goal
Create a Book model and migration.

### Required fields

* `title` (string) the title of the book
* `publisher_id` (integer) the publisher of the book
* `author_id` (integer) the author of the book

### Instance Methods of Book

* `book_format_types`:  Returns a collection of the BookFormatTypes this book is available in
* `author_name`:  The name of the author of this book in “lastname, firstname” format
* `average_rating`:  The average (mean) of all the book reviews for this book.  Rounded to one decimal place.  

### Class Method(s) of Book

* `search(query, options)`
  Returns a collection of books that match the query string, subject to the following rules:

   1. If the last name of the author matches the query string exactly (case insensitive)
   2. If the name of the publisher matches the query string exactly (case insensitive)
   3. If any portion of the book’s title matches the query string (case insensitive)
   4. The results should be the union of books that match any of these three rules.  The results should be ordered by average rating, with the highest rating first.  The list should be unique (the same book shouldn't appear multiple times in the results).

#### Search options 

* `:title_only` (defaults to false).  If true, only return results from rule #3 above.
* `:book_format_type_id` (defaults to nil).  If supplied, only return books that are available in a format that matches the supplied type id.
* `:book_format_physical` (defaults to nil).   If supplied as true or false, only return books that are available in a format whose “physical” field matches the supplied argument.  This filter is not applied if the argument is not present or nil.

The `title_only` and `book_format` options are not exclusive of each other, so
`Book.search('Karamazov', title_only: true, book_format_physical: true)` should return all physical books whose title matches that term.