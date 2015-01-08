<?xml version="1.0"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
  <xsl:output method="text" version="1.0" encoding="UTF-8" indent="no"/>
  <xsl:template match="/">
    <xsl:value-of select="level1Product/productInfo/sceneInfo/start/timeUTC"/>
    <xsl:text/>
  </xsl:template>
</xsl:stylesheet>
