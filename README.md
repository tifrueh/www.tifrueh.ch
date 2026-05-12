# tifrueh HUGO Theme Module

This is the HUGO theme module I wrote for my personal website.

## Custom Site Parameters

| Parameter             | Default Value         | Description                                                   |
| ---                   | ---                   | ---                                                           |
| `author.name`         | NONE                  | The author to put into the copyright notice.                  |

## Custom Page Parameters

| Parameter             | Default Value         | Description                                                                   |
| ---                   | ---                   | ---                                                                           |
| `book-style`          | `false`               | Format text in a more book-like manner.                                       |
| `math`                | `false`               | Load MathJax to display math on the page.                                     |
| `table-of-contents`   | `false`               | Show a table of contents at the beginning of a page.                          |
| `word-count`          | `false`               | Show the rough amount of words on a page at its beginning.                    |
| `reverse-next-prev`   | `false`               | (On section index) Reverse direction of next/prev navigation of child pages.  |

## Configuration Merge

The configuration settings potentially relevant for merging in `hugo.toml` are
within:

* `[markup.highlight]`
* `[outputFormats.rss]`
