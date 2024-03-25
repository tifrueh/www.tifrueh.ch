+++
title = "Site Optimisations"
date = 2024-03-25T15:57:06+01:00
description = "A few notes on optimising this site."
draft = false
url = "/blog/2024/03/site-optimisations"
+++

During the last few days, I've had some time to spare, but I didn't really have
a good idea for another post yet[^1], so I set about optimising this website as
thoroughly as my current knowledge about the web allows me.

[^1]: Well, *actually*, I did have a few good ones right off the bat, but I made
    the mistake of not writing them down *immediately* and my monkey brain
    obviously forgot all about them right away.

*Quick side note: If you're not very interested in all the stuff that goes on
behind the scenes of this website and you're here for my writing about other
things, this post might not be your piece of cake. But don't fret; While I will
probably write more technical posts like this one from time to time, I don't
intend to make them the norm. As interesting as they are, I enjoy writing about
general life things a lot more.*

So, let's get started, shall we?

### General Improvements

The first thing I did was type "website tests" into my search engine and
click on the first sites (namely <https://www.webpagetest.org> and
<https://nibbler.insites.com>) that popped up. Those two suggested some nice
optimisation opportunities and the following were the ones I went for
right away:

1. Optimising my HUGO code, so that it doesn't generate as many empty lines in
   its HTML output.

1. Adding a language attribute to the `<html>` tag.

1. Providing titles and descriptions to the menu bar icons, so that
   screenreaders know what they are supposed to represent.

1. Adding descriptions to all pages.

Additionally, I also converted all fonts to WOFF2 (they were TTFs previously),
which can also improve performance.

There were, of course, many more suggested improvements, but when thinking about
the rest of them I either didn't really understand why it *would* be an
improvement or plainly didn't have *any* idea at all on how to implement it
using my GitHub Pages / HUGO setup, but I was satisfied for the moment
nonetheless.

### Styling my RSS Feed

Now, there is another thing that I find really cool and wanted to attempt:

Styling my RSS feed's XML file using XSLT. 

Sounds cool, right? And it is! Imagine yourself visiting a website. You click on
the RSS icon and instead of being presented with raw XML (or even worse, your
browser downloading the XML file), you see a neat web view of the feed. I
learned about this from Robb Knight[^2], but I used the [guide on
w3schools](https://www.w3schools.com/xml/xsl_intro.asp) as a base for my own
stylesheet.

[^2]: Go read his post about this, too, he does a way better job of explaining
    this than me. &rarr; [Styling RSS and Atom
    Feeds](https://rknight.me/blog/styling-rss-and-atom-feeds/)

So, to give you the gist of it: In this context, XSLT is used to transform XML
content into HTML content if need be. To do this, a separate XSL file is needed,
which can then be linked in the XML file like so:

```diff
<?xml version="1.0" encoding="utf-8" standalone="yes"?>
+ <?xml-stylesheet href="/xsl/rss.xsl" type="text/xsl"?>
```

This separate file the contains the XSL. Mine looks like this:

```xsl
<?xml version="1.0" encoding="utf-8"?>

<xsl:stylesheet version="3.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:output method="html" version="1.0" encoding="UTF-8" indent="yes" />

<xsl:template match="/">
    <html>
        <xsl:attribute name="lang"><xsl:value-of select="/rss/channel/language" /></xsl:attribute>
    <head>
        <meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1"/>
        <meta charset="utf-8" />
        <title><xsl:value-of select="/rss/channel/title" /></title>
        <link rel="stylesheet" href="../css/stylesheet.css" />
    </head>
    <body>
        <div class="top-flex-div">
        <main>
        <p>
            <strong>This is a web feed,</strong> also known as an RSS feed. <strong>Subscribe</strong> by copying the URL from the address bar into your newsreader.
        </p>
        <hr />
        <h1>Web Feed Preview</h1>
        <p>
            <p><xsl:value-of select="/rss/channel/title" />&#x2002;<a><xsl:attribute name="href"><xsl:value-of select="/rss/channel/link" /></xsl:attribute>&#x2192; Visit website</a></p>
        </p>
        <hr />
        <h2>Recent posts</h2>
        <xsl:for-each select="/rss/channel/item">
            <p class="summary-timestamp"><xsl:value-of select="pubDate" /></p>
            <a>
                <xsl:attribute name="href"><xsl:value-of select="link" /></xsl:attribute>
                <h3 class="summary-link"><xsl:value-of select="title" /></h3>
            </a>
        </xsl:for-each>
        </main>
        <footer>
            <p><xsl:value-of select="/rss/channel/copyright" /></p>
        </footer>
        </div>
    </body>
    </html>
</xsl:template>

</xsl:stylesheet>
```

To make this work on iOS, however, I'd need to set a custom HTTP header (as
noted by Robb and, by extension, the comments in
[`pretty-feed-v3.xsl`](https://github.com/genmon/aboutfeeds/blob/main/tools/pretty-feed-v3.xsl))
and that is currently not possible using GitHub Pages. This is obviously less
than ideal for mobile users, who won't see the online feed preview, but there is
unfortunately nothing I can do about that (or at least nothing I could think of)
except hosting this site myself[^3].

But if you're on a desktop browser (that is not Safari), you should be able to
see the styled feed if you click on the RSS icon in the top right corner. :)

[^3]: I might actually be able to do this in the near future, as I will probably
    start renting a VPS for my Nextcloud deployment in the next few months.
    There is also the additional benefit of being able to do redirections on
    this site properly as soon as I start hosting myself.

### Open Graph Information

When I shared my website and this blog's first post on Mastodon last week, I
noticed that the link previews didn't look as detailed as they do when other
people share stuff from their websites. So I set about digging around on various
websites and I found some interesting `og:something` meta tags. It turns out
that these are connected to the [Open Graph protocol](https://ogp.me) and that
this Open Graph metadata was exactly what I was missing. So I jumped into my
graphics editor, created the images I needed and added the necessary meta tags
to the `<head>` of my site, which was really easy to do with HUGO.

The following lines in my `baseof.html` template:

```html
<meta property="og:description" content="{{- if .Description }}{{ .Description }}{{- else }}{{ .Content | truncate 150 }}{{- end }}" />
<meta property="og:url" content="{{ .Permalink }}" />
<meta property="og:title" content="{{ .Title }}" />
<meta property="og:image" content="{{- block "og-image" . }}/images/og-index.png{{- end}}" />
<meta property="og:type" content="{{- block "og-type" . }}website{{- end}}" />
```

render to the following HTML on the homepage:

```html
<meta property="og:description" content="I&#39;m a computer science student and a generally techy person. Lately I&#39;ve begun delving a bit more into the whole indie web thing and now I have my own website. All very exciting!"/>
<meta property="og:description" content="I'm a computer science student and a generally techy person. Lately I've begun delving a bit more into the whole indie web thing and now I have my own website. All very exciting!">
<meta property="og:url" content="https://www.tifrueh.ch/">
<meta property="og:title" content="Home">
<meta property="og:image" content="/images/og-index.png">
<meta property="og:type" content="website">
```

And if I ever want to have a different preview image or content type (like
e.&nbsp;g. on a blog post), I merely have to override the corresponding HUGO
block.

### Syntax highlighting

Now, this came to my attention while writing this blog post, because I wanted to
include some code and I hadn't configured the site to show code properly just
yet. This was quite simple to do with HUGO, fortunately. I just had to add some
additional configuration to my `hugo.toml`:

```toml
[markup]
[markup.highlight]
    lineNos = false
    tabWidth = 4
    noClasses = false
```

and then use:

```shell
hugo gen chromastyles --style=onedark
```

to generate all necessary CSS classes.

I modified those a bit, added scrollbars, added padding and set a different
background colour because the default one of the `onedark` colour scheme is
obviously the same as the background of my site, as this is the exact colour scheme it
uses.

There was a weird issue, where the font size on iOS wouldn't be consistent
across the code blocks, but I was able to fix that by adding
`-webkit-text-size-adjust: 100%` to the CSS of the flexbox containers Chroma
(HUGO's syntax highlighter) uses to display the code.

As a last finishing touch I then also added some styling to the inline code
blocks:

```css
p code {
    background-color: var(--background-code);
    padding: 0.2em;
    border-radius: 3px;
}
```

### Conclusion

I have to admit, it was really fun trying to delve a bit more into the smaller
details of building a website. I was able to implement some things I already
knew about and learned about some other, new things along the way, which is
always great. And by no means do I think that there aren't a great many more
things I could improve still. I'm also not totally sure that I followed best
practices for everything contained in this post, but I think that's okay, I'm
still an absolute noob when it comes to web development and I'm absolutely fine
with learning from all the hilariously stupid things I'm probably doing right
now in the future. But I'm quite satisfied with my hunt for problems for the
moment and will fix the rest of them as soon as they pop up.
