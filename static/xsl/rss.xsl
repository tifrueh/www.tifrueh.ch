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
            <strong>This is a web feed,</strong> also known as an RSS feed. <strong> Subscribe </strong>
            by copying the URL from the address bar into your newsreader.
            <a href="https://aboutfeeds.com">Help! What is a feed?</a>
        </p>
        <hr />
        <h1>Web Feed Preview</h1>
        <p>
            <p><xsl:value-of select="/rss/channel/description" />&#x2002;<a><xsl:attribute name="href"><xsl:value-of select="/rss/channel/link" /></xsl:attribute>&#x2192; Visit website</a></p>
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
