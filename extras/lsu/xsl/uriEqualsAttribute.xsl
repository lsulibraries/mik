<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
    xmlns="http://www.loc.gov/mods/v3"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:mods="http://www.loc.gov/mods/v3"
    xmlns:xlink="http://www.w3.org/1999/xlink"
    xpath-default-namespace="http://www.loc.gov/mods/v3"
    exclude-result-prefixes="xs mods"
    version="2.0">
    
    <xsl:output method="xml"/>
    
    <xsl:template match="@* | node()">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="genre|form">
        <xsl:choose>
            <xsl:when test="contains(., '|uri=')">
                <xsl:variable name="elName" select="name()"/>
                <xsl:element name="{$elName}">
                    <xsl:attribute name="authorityURI">
                        <xsl:value-of select="'http://vocab.getty.edu/aat'"/>
                    </xsl:attribute>
                    <xsl:attribute name="valueURI">
                        <xsl:value-of select="substring-after(., '|uri=')"/>
                    </xsl:attribute>
                    <xsl:apply-templates select="@* | node()"/>
                </xsl:element>
            </xsl:when>
            <xsl:otherwise>
                <xsl:copy-of select="."/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="name">
        <xsl:choose>
            <xsl:when test="contains(namePart, '|uri=')">
                <xsl:element name="name">
                    <xsl:attribute name="authority">
                        <xsl:value-of select="'naf'"/>
                    </xsl:attribute>
                    <xsl:attribute name="authorityURI">
                        <xsl:value-of select="'http://id.loc.gov/authorities/names'"/>
                    </xsl:attribute>
                    <xsl:attribute name="valueURI">
                        <xsl:value-of select="substring-after(namePart/text(), '|uri=')"/>
                    </xsl:attribute>
                    <xsl:apply-templates select="@* | node()"/>
                </xsl:element>
            </xsl:when>
            <xsl:otherwise>
                <xsl:copy-of select="."/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="accessCondition[contains(., '|uri=')]">
        <xsl:element name="accessCondition">
            <xsl:attribute name="xlink:href">
                <xsl:value-of select="substring-after(.,'|uri=')"/>
            </xsl:attribute>
            <xsl:apply-templates select="@* | node()"/>
        </xsl:element>
    </xsl:template>
    
    <xsl:template match="text()[contains(.,'|uri=')]">
        <xsl:variable name="term" select="substring-before(.,'|uri=')"/>
        <xsl:value-of select="$term"/>
    </xsl:template>
    
</xsl:stylesheet>