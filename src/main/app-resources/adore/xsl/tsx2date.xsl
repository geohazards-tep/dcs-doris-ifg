<xsl:stylesheet version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	<xsl:output method="text" version="1.0" encoding="UTF-8" indent="no" />
	<xsl:template match="issue">
	<xsl:value-of select='id' />
	<xsl:text></xsl:text>
	</xsl:template>
	<xsl:template match="*" />
</xsl:stylesheet>
