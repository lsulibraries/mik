<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:mods="http://www.loc.gov/mods/v3"
    xpath-default-namespace="http://www.loc.gov/mods/v3"
    exclude-result-prefixes="xs"
    version="2.0"
    xmlns="http://www.loc.gov/mods/v3">
    
    <!-- takes various permutations of date formatting in dateIssued and converts them
    YYYY-YYYY breaks into point=start and point=end
    Ca. YYYY gets an attribute qualifier="approximate"
    Ca. YYYY-YYYY gets approximate qualifier and start and end
    Before YYYY and YYYY gets split with point start and point end
    YYYY; YYYY; YYYY captures and splits first and last years - discards the middles
    all others stay the same-->
    
    <xsl:template match="@* | node()">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:variable name="dates" select="node()/originInfo/dateIssued/text()"/>
    <xsl:variable name="yearRangeRegEx" select="'^([0-9]{4})\s?-\s?([0-9]{4})'"/> <!-- YYYY-YYYY -->
    <xsl:variable name="inferredYearRangeRegEx" select="'\[([0-9]{4})-([0-9]{4})\]'"/> <!-- [YYYY-YYYY] -->
    <xsl:variable name="caRegEx" select="'\[?[cC]a\.\s?([0-9]{4})\]?$'"/> <!-- Ca. YYYY or [Ca. YYYY] -->
    <xsl:variable name="caDecadeRegEx" select="'[cC]a.\s?([0-9]{3})(0s|-)'"/> <!-- [Ca. YYYYs] or Ca. YYYYs or Ca. YYY- -->
    <xsl:variable name="caEndRegEx" select="'([0-9]{4})\s[cC]a\.'"/> <!-- YYYY ca. --> 
    <xsl:variable name="betweenRegEx" select="'^[bB]etween\s([0-9]{4})(\sand\s|-)([0-9]{4})'"/> <!-- Between YYYY and YYYY -->
    <xsl:variable name="approxBetweenRegEx" select="'\[[bB]etween\s([0-9]{4})(\sand\s|-)([0-9]{4})\]'"/> <!-- [Between YYYY and YYYY] or [Between YYYY-YYYY] -->
    <xsl:variable name="semicolonRegEx" select="'(^[0-9]{4});.*([0-9]{4}$)'"/> <!-- YYYY; YYYY (not captured); YYYY -->
    <xsl:variable name="inferredRegEx" select="'\[([0-9]{4})\]'"/> <!-- [YYYY] -->
    <xsl:variable name="orRegEx" select="'([0-9]{4})\s(or|and)\s([0-9]{4})'"/> <!-- YYYY or YYYY OR YYYY and YYYY OR with brackets-->
    <xsl:variable name="historicalRegEx" select="'([0-9]{4})\s\(historical\)|([0-9]{4}-[0-9]{2}-[0-9]{2})\s\(historical\)'"/> <!-- YYYY (historical) -->
    <xsl:variable name="decadeRegEx" select="'([0-9]{3})-$'"/> <!-- YYY- -->
    <xsl:variable name="decadeQuestionableRegEx" select="'[^0-9]([0-9]{3})-?\?'"/> <!-- YYY? or YYY-? -->
    <xsl:variable name="centuryRegEx" select="'([0-9]{2})th\s[cC]entury'"/> <!-- YYth century -->
    <xsl:variable name="priorRegEx" select="'prior\sto\s([0-9]{4})'"/>
    
    <xsl:template match="originInfo/dateIssued">
        <xsl:choose>
            <xsl:when test="matches(., $yearRangeRegEx) and not(matches(., 'Ca.'))">
                <xsl:analyze-string select="$dates" regex="{$yearRangeRegEx}">
                    <xsl:matching-substring>
                        <dateIssued point="start" keyDate="yes">
                            <xsl:value-of select="replace(regex-group(1), '\s+', ' ')"/>
                        </dateIssued>
                        <dateIssued point="end">
                            <xsl:value-of select="replace(regex-group(2), '\s+', ' ')"/>
                        </dateIssued>
                    </xsl:matching-substring>
                </xsl:analyze-string>
            </xsl:when>
            <xsl:when test="matches(., $inferredYearRangeRegEx) and not(matches(., 'Ca.'))">
                <xsl:analyze-string select="$dates" regex="{$inferredYearRangeRegEx}">
                    <xsl:matching-substring>
                        <dateIssued point="start" keyDate="yes" qualifier="inferred">
                            <xsl:value-of select="replace(regex-group(1), '\s+', ' ')"/>
                        </dateIssued>
                        <dateIssued point="end" qualifier="inferred">
                            <xsl:value-of select="replace(regex-group(2), '\s+', ' ')"/>
                        </dateIssued>
                    </xsl:matching-substring>
                </xsl:analyze-string>
            </xsl:when>
            <xsl:when test="matches(., $caRegEx) and not(matches(., '-'))">
                <xsl:analyze-string select="$dates" regex="{$caRegEx}">
                    <xsl:matching-substring>
                        <dateIssued keyDate="yes" qualifier="approximate">
                            <xsl:value-of select="replace(regex-group(1), '\s+', ' ')"/>
                        </dateIssued>
                    </xsl:matching-substring>
                </xsl:analyze-string>
            </xsl:when>
            <xsl:when test="matches(., $caEndRegEx) and not(matches(., '-'))">
                <xsl:analyze-string select="$dates" regex="{$caEndRegEx}">
                    <xsl:matching-substring>
                        <dateIssued keyDate="yes" qualifier="approximate">
                            <xsl:value-of select="replace(regex-group(1), '\s+', ' ')"/>
                        </dateIssued>
                    </xsl:matching-substring>
                </xsl:analyze-string>
            </xsl:when>
            <xsl:when test="matches(., '-') and not(matches(., 'Ca.'))">
                <xsl:analyze-string select="$dates" regex="{$yearRangeRegEx}">
                    <xsl:matching-substring>
                        <dateIssued point="start" keyDate="yes" qualifier="approximate">
                            <xsl:value-of select="replace(regex-group(1), '\s+', ' ')"/>
                        </dateIssued>
                        <dateIssued point="end" qualifier="approximate">
                            <xsl:value-of select="replace(regex-group(2), '\s+', ' ')"/>
                        </dateIssued>
                    </xsl:matching-substring>
                </xsl:analyze-string>
            </xsl:when>
            <xsl:when test="matches(., $caDecadeRegEx)">
                <xsl:analyze-string select="$dates" regex="{$caDecadeRegEx}">
                    <xsl:matching-substring>
                        <dateIssued point="start" keyDate="yes" qualifier="approximate">
                            <xsl:value-of select="replace(regex-group(1), '\s+', ' ')"/>
                            <xsl:text>0</xsl:text>
                        </dateIssued>
                        <dateIssued point="end" qualifier="approximate">
                            <xsl:value-of select="replace(regex-group(1), '\s+', ' ')"/>
                            <xsl:text>9</xsl:text>
                        </dateIssued>
                    </xsl:matching-substring>
                </xsl:analyze-string>
            </xsl:when>
            <xsl:when test="matches(., $betweenRegEx)">
                <xsl:analyze-string select="$dates" regex="{$betweenRegEx}">
                    <xsl:matching-substring>
                        <dateIssued point="start" keyDate="yes">
                            <xsl:value-of select="replace(regex-group(1), '\s+', ' ')"/>
                        </dateIssued>
                        <dateIssued point="end">
                            <xsl:value-of select="replace(regex-group(3), '\s+', ' ')"/>
                        </dateIssued>
                    </xsl:matching-substring>
                </xsl:analyze-string>
            </xsl:when>
            <xsl:when test="matches(., $approxBetweenRegEx)">
                <xsl:analyze-string select="$dates" regex="{$approxBetweenRegEx}">
                    <xsl:matching-substring>
                        <dateIssued point="start" keyDate="yes" qualifier="approximate">
                            <xsl:value-of select="replace(regex-group(1), '\s+', ' ')"/>
                        </dateIssued>
                        <dateIssued point="end" qualifier="approximate">
                            <xsl:value-of select="replace(regex-group(3), '\s+', ' ')"/>
                        </dateIssued>
                    </xsl:matching-substring>
                </xsl:analyze-string>
            </xsl:when>
            <xsl:when test="matches(., $semicolonRegEx)">
                <xsl:analyze-string select="$dates" regex="{$semicolonRegEx}">
                    <xsl:matching-substring>
                        <dateIssued point="start" keyDate="yes">
                            <xsl:value-of select="replace(regex-group(1), '\s+', ' ')"/>
                        </dateIssued>
                        <dateIssued point="end">
                            <xsl:value-of select="replace(regex-group(2), '\s+', ' ')"/>
                        </dateIssued>
                    </xsl:matching-substring>
                </xsl:analyze-string>
            </xsl:when>
            <xsl:when test="matches(., $inferredRegEx) and not(matches(., '-'))">
                <xsl:analyze-string select="$dates" regex="{$inferredRegEx}">
                    <xsl:matching-substring>
                        <dateIssued keyDate="yes" qualifier="inferred">
                            <xsl:value-of select="replace(regex-group(1), '\s+', ' ')"/>
                        </dateIssued>
                    </xsl:matching-substring>
                </xsl:analyze-string>
            </xsl:when>
            <xsl:when test="matches(., $orRegEx)">
                <xsl:analyze-string select="$dates" regex="{$orRegEx}">
                    <xsl:matching-substring>
                        <dateIssued point="start" keyDate="yes" qualifier="inferred">
                            <xsl:value-of select="replace(regex-group(1), '\s+', ' ')"/>
                        </dateIssued>
                        <dateIssued point="end" qualifier="inferred">
                            <xsl:value-of select="replace(regex-group(3), '\s+', ' ')"/>
                        </dateIssued>
                    </xsl:matching-substring>
                </xsl:analyze-string>
            </xsl:when>
            <xsl:when test="matches(., $historicalRegEx)">
                <xsl:analyze-string select="$dates" regex="{$historicalRegEx}">
                    <xsl:matching-substring>
                        <dateIssued keyDate="yes">
                            <xsl:value-of select="replace(regex-group(1), '\s+', ' ')"/>
                        </dateIssued>
                    </xsl:matching-substring>
                </xsl:analyze-string>
            </xsl:when>
            <xsl:when test="matches(., $decadeRegEx)">
                <xsl:analyze-string select="$dates" regex="{$decadeRegEx}">
                    <xsl:matching-substring>
                        <dateIssued point="start" keyDate="yes" qualifier="inferred">
                            <xsl:value-of select="replace(regex-group(1), '\s+', ' ')"/>
                            <xsl:text>0</xsl:text>
                        </dateIssued>
                        <dateIssued point="end" qualifier="inferred">
                            <xsl:value-of select="replace(regex-group(1), '\s+', ' ')"/>
                            <xsl:text>9</xsl:text>
                        </dateIssued>
                    </xsl:matching-substring>
                </xsl:analyze-string>
            </xsl:when>
            <xsl:when test="matches(., $decadeQuestionableRegEx)">
                <xsl:analyze-string select="$dates" regex="{$decadeQuestionableRegEx}">
                    <xsl:matching-substring>
                        <dateIssued point="start" keyDate="yes" qualifier="questionable">
                            <xsl:value-of select="replace(regex-group(1), '\s+', ' ')"/>
                            <xsl:text>0</xsl:text>
                        </dateIssued>
                        <dateIssued point="end" qualifier="questionable">
                            <xsl:value-of select="replace(regex-group(1), '\s+', ' ')"/>
                            <xsl:text>9</xsl:text>
                        </dateIssued>
                    </xsl:matching-substring>
                </xsl:analyze-string>
            </xsl:when>
            <xsl:when test="matches(., $priorRegEx)">
                <xsl:analyze-string select="$dates" regex="{$priorRegEx}">
                    <xsl:matching-substring>
                        <dateIssued keyDate="yes" point="end">
                            <xsl:value-of select="replace(regex-group(1), '\s+', ' ')"/>
                        </dateIssued>
                    </xsl:matching-substring>
                </xsl:analyze-string>
            </xsl:when>
            <xsl:when test="matches(., 'early 20th century', 'i')">
                <dateIssued point="start" keydate="yes" qualifier="approximate">1901</dateIssued>
                <dateIssued point="end" qualifier="approximate">1939</dateIssued>
            </xsl:when>
            <xsl:when test="matches(., 'mid-20th century', 'i')">
                <dateIssued point="start" keydate="yes" qualifier="approximate">1930</dateIssued>
                <dateIssued point="end" qualifier="approximate">1969</dateIssued>
            </xsl:when>
            <xsl:when test="matches(., '20th century', 'i') and matches(., '19th')">
                <dateIssued point="start" keydate="yes" qualifier="approximate">1801</dateIssued>
                <dateIssued point="end" qualifier="approximate">2000</dateIssued>
            </xsl:when>
            <xsl:when test="matches(., '20th century', 'i') and not (matches(., '19th'))">
                <dateIssued point="start" keydate="yes" qualifier="approximate">1901</dateIssued>
                <dateIssued point="end" qualifier="approximate">2000</dateIssued>
            </xsl:when>
            <xsl:when test="matches(., 'mid-19th century', 'i')">
                <dateIssued point="start" keydate="yes" qualifier="approximate">1830</dateIssued>
                <dateIssued point="end" qualifier="approximate">1869</dateIssued>
            </xsl:when>
            <xsl:when test="matches(., 'late 19th century', 'i')">
                <dateIssued point="start" keydate="yes" qualifier="approximate">1860</dateIssued>
                <dateIssued point="end" qualifier="approximate">1900</dateIssued>
            </xsl:when>
            <xsl:when test="matches(., '19th century', 'i')">
                <dateIssued point="start" keydate="yes" qualifier="approximate">1801</dateIssued>
                <dateIssued point="end" qualifier="approximate">1900</dateIssued>
            </xsl:when>
            <xsl:when test="matches(., '18th century', 'i')">
                <dateIssued point="start" keydate="yes" qualifier="approximate">1701</dateIssued>
                <dateIssued point="end" qualifier="approximate">1800</dateIssued>
            </xsl:when>
            <xsl:when test="matches(., '17th century', 'i')">
                <dateIssued point="start" keydate="yes" qualifier="approximate">1601</dateIssued>
                <dateIssued point="end" qualifier="approximate">1700</dateIssued>
            </xsl:when>
            <xsl:when test="matches(., '16th century', 'i')">
                <dateIssued point="start" keydate="yes" qualifier="approximate">1501</dateIssued>
                <dateIssued point="end" qualifier="approximate">1600</dateIssued>
            </xsl:when>
            <xsl:when test="matches(., '15th century', 'i')">
                <dateIssued point="start" keydate="yes" qualifier="approximate">1401</dateIssued>
                <dateIssued point="end" qualifier="approximate">1500</dateIssued>
            </xsl:when>
            <xsl:when test="matches(., '14th century', 'i')">
                <dateIssued point="start" keydate="yes" qualifier="approximate">1301</dateIssued>
                <dateIssued point="end" qualifier="approximate">1400</dateIssued>
            </xsl:when>
            <xsl:otherwise>
                <dateIssued keyDate="yes">
                    <xsl:value-of select="."/>
                </dateIssued>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
</xsl:stylesheet>