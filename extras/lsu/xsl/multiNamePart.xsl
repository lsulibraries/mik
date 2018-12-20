<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:mods="http://www.loc.gov/mods/v3"
    xpath-default-namespace="http://www.loc.gov/mods/v3"
    exclude-result-prefixes="xs"
    version="2.0"
    xmlns="http://www.loc.gov/mods/v3" >
    
    <!-- 
        When name/namePart contains multiple semicolon-delimited values: 
           - Split them into different name elements
           - Keep the name type and displayLabel attribute values
           - Keep the role/roleTerm values (assumes always authority="marcrelator")
    -->
    
    <xsl:output indent="yes"/>
    
    <xsl:template match="@* | node()">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="name[contains(namePart/text(), ';')]">
        <xsl:variable name="displayLabel" select="@displayLabel"/>
        <xsl:variable name="type" select="@type"/>
        <xsl:variable name="authority" select="@authority"/>
        <xsl:variable name="roleCode" select="role/roleTerm[@type='code']"/>
        <xsl:variable name="roleText" select="role/roleTerm[@type='text']"/>
        <xsl:for-each select="tokenize(namePart,';')">
            <xsl:element name="name">
                <xsl:if test="$type!=''">
                    <xsl:attribute name="type" select="$type"/>
                </xsl:if>
                <xsl:if test="$authority!=''">
                    <xsl:attribute name="authority" select="$authority"/>
                </xsl:if>
                <xsl:if test="$displayLabel!=''">
                    <xsl:attribute name="displayLabel" select="$displayLabel"/>
                </xsl:if>
                <xsl:element name="namePart">
                    <xsl:value-of select="normalize-space(.)"/>
                </xsl:element>
                <xsl:if test="$roleCode != '' or $roleText != ''">
                    <xsl:element name="role">
                        <xsl:if test="$roleText != ''">
                            <xsl:element name="roleTerm">
                                <xsl:attribute name="type" select="'text'"/>
                                <xsl:attribute name="authority" select="'marcrelator'"/>
                                <xsl:value-of select="$roleText"/>
                            </xsl:element>
                        </xsl:if>
                        <xsl:if test="$roleCode != ''">
                            <xsl:element name="roleTerm">
                                <xsl:attribute name="type" select="'code'"/>
                                <xsl:attribute name="authority" select="'marcrelator'"/>
                                <xsl:value-of select="$roleCode"/>
                            </xsl:element>
                        </xsl:if>
                    </xsl:element>
                </xsl:if>
            </xsl:element>
        </xsl:for-each>
    </xsl:template>
    
</xsl:stylesheet>