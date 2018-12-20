<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:mods="http://www.loc.gov/mods/v3"
    xpath-default-namespace="http://www.loc.gov/mods/v3"
    exclude-result-prefixes="xs"
    version="2.0"
    xmlns="http://www.loc.gov/mods/v3" >

    <!-- changes subject name namePart; namePart to subject name namePart subject name namePart (split on semicolon)-->
    
    <xsl:output method="xml" indent="yes"/>
    
    <xsl:template match="@* | node()">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()"/>
        </xsl:copy>
    </xsl:template>
    
   
    <xsl:template match="subject[name]">
        <xsl:variable name="subAuth" select="@authority"/>
        <xsl:variable name="nameAuth" select="name/@authority"/>
        <xsl:variable name="displayLabel" select="@displayLabel"/>
        <xsl:variable name="nameType" select="name/@type"/>
        <xsl:for-each select="tokenize(name/namePart,'; ')">
            <xsl:element name="subject">
                <xsl:if test="$subAuth"> <!--add authority attribute only if present in source-->
                    <xsl:attribute name="authority">
                        <xsl:value-of select="$subAuth" />
                    </xsl:attribute>
                </xsl:if>
                <xsl:if test="$displayLabel"> <!--add label attribute only if present in source-->
                    <xsl:attribute name="displayLabel">
                        <xsl:value-of select="$displayLabel" />
                    </xsl:attribute>
                </xsl:if>
                <xsl:element name="name">
                    <xsl:if test="$nameAuth">
                        <xsl:attribute name="authority">
                            <xsl:value-of select="$nameAuth"/>
                        </xsl:attribute>
                    </xsl:if>
                    <xsl:if test="$nameType">
                        <xsl:attribute name="type">
                            <xsl:value-of select="$nameType"/>
                        </xsl:attribute>
                    </xsl:if>
                    <xsl:element name="namePart">
                        <xsl:value-of select="."/>
                    </xsl:element>
                </xsl:element>
            </xsl:element>
        </xsl:for-each>
    </xsl:template>
    <!--
    <xsl:template match="subject[geographic]">
        <xsl:variable name="authAttr" select="@authority"/>
        <xsl:variable name="displayLabel" select="@displayLabel"/>
        <xsl:for-each select="tokenize(geographic,';')">
            <xsl:element name="subject">
                <xsl:if test="$authAttr"> <!-\-add authority attribute only if present in source-\->
                    <xsl:attribute name="authority">
                        <xsl:value-of select="$authAttr" />
                    </xsl:attribute>
                </xsl:if>
                <xsl:if test="$displayLabel"> <!-\-add label attribute only if present in source-\->
                    <xsl:attribute name="displayLabel">
                        <xsl:value-of select="$displayLabel" />
                    </xsl:attribute>
                </xsl:if>
                <xsl:for-each select="tokenize(.,'-\-')">
                    <xsl:element name="geographic">
                        <xsl:value-of select="replace(replace(concat(upper-case(substring(.,1,1)),substring(.,2)), '^\s+|\s+$', ''),'\.$','')"/>
                    </xsl:element>
                </xsl:for-each>
            </xsl:element>
        </xsl:for-each>
    </xsl:template>

    <xsl:template match="subject[temporal]">
        <xsl:variable name="authAttr" select="@authority"/>
        <xsl:variable name="displayLabel" select="@displayLabel"/>
        <xsl:for-each select="tokenize(temporal,';')">
            <xsl:element name="subject">
                <xsl:if test="$authAttr"> <!-\-add authority attribute only if present in source-\->
                    <xsl:attribute name="authority">
                        <xsl:value-of select="$authAttr" />
                    </xsl:attribute>
                </xsl:if>
                <xsl:if test="$displayLabel"> <!-\-add label attribute only if present in source-\->
                    <xsl:attribute name="displayLabel">
                        <xsl:value-of select="$displayLabel" />
                    </xsl:attribute>
                </xsl:if>
                <xsl:element name="temporal">
                    <xsl:value-of select="replace(replace(concat(upper-case(substring(.,1,1)),substring(.,2)), '^\s+|\s+$', ''),'\.$','')"/>
                </xsl:element>             
            </xsl:element>
        </xsl:for-each>
    </xsl:template>-->
</xsl:stylesheet>