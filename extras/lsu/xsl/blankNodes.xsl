<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:mods="http://www.loc.gov/mods/v3"
    exclude-result-prefixes="xs"
    version="1.0"
    xmlns="http://www.loc.gov/mods/v3" 
    >
    
    <!-- deletes mods elements that contain no text other than whitespace; 
         deletes attributes with empty values -->
    
    <xsl:output indent="yes"/>
    
    <xsl:template match="@* | node() ">
        <xsl:copy>
            <xsl:apply-templates select="@*[normalize-space()] | node()[normalize-space()] "/>
        </xsl:copy>
    </xsl:template>
       
</xsl:stylesheet>