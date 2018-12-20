<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:mods="http://www.loc.gov/mods/v3"
    xpath-default-namespace="http://www.loc.gov/mods/v3"
    exclude-result-prefixes="xs"
    version="2.0"
    xmlns="http://www.loc.gov/mods/v3" >
    
    <!-- 
        When titleInfo[@type="alternative"]/title contains multiple semicolon-delimited values: 
           - Split them into different title elements
           - Keep the displayLabel attribute value
    -->
    
    <xsl:output indent="yes"/>
    
    <xsl:template match="@* | node()">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="titleInfo[@type='alternative'][contains(title/text(), ';')]">
        <xsl:variable name="displayLabel" select="@displayLabel"/>
        <xsl:for-each select="tokenize(title,';')">
            <xsl:element name="titleInfo">
                <xsl:attribute name="type" select="'alternative'"/>
                <xsl:if test="$displayLabel!=''">
                    <xsl:attribute name="displayLabel" select="$displayLabel"/>
                </xsl:if>
                <xsl:element name="title">
                    <xsl:value-of select="normalize-space(.)"/>
                </xsl:element>
            </xsl:element>
        </xsl:for-each>
    </xsl:template>
    
</xsl:stylesheet>