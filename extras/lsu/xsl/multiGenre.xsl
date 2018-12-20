<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:mods="http://www.loc.gov/mods/v3"
    xpath-default-namespace="http://www.loc.gov/mods/v3"
    exclude-result-prefixes="xs"
    version="2.0"
    xmlns="http://www.loc.gov/mods/v3" >
    
    <!-- 
        When genre contains multiple semicolon-delimited values: 
           - Split them into different genre elements
           - Keep attribute values
    -->
    
    <xsl:output indent="yes"/>
    
    <xsl:template match="@* | node()">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="genre[contains(text(), ';')]">
        <xsl:variable name="displayLabel" select="@displayLabel"/>
        <xsl:variable name="type" select="@type"/>
        <xsl:variable name="authority" select="@authority"/>
        <xsl:variable name="authorityURI" select="@authorityURI"/>
        <xsl:variable name="valueURI" select="@valueURI"/>
        <xsl:for-each select="tokenize(.,';')">
            <xsl:element name="genre">
                <xsl:if test="$type!=''">
                    <xsl:attribute name="type" select="$type"/>
                </xsl:if>                
                <xsl:if test="$authority!=''">
                    <xsl:attribute name="authority" select="$authority"/>
                </xsl:if>
                <xsl:if test="$authorityURI!=''">
                    <xsl:attribute name="authorityURI" select="$authorityURI"/>
                </xsl:if>
                <xsl:if test="$valueURI!=''">
                    <xsl:attribute name="valueURI" select="$valueURI"/>
                </xsl:if>
                <xsl:if test="$displayLabel!=''">
                    <xsl:attribute name="displayLabel" select="$displayLabel"/>
                </xsl:if>
                <xsl:value-of select="normalize-space(.)"/>
            </xsl:element>
        </xsl:for-each>
    </xsl:template>
    
</xsl:stylesheet>