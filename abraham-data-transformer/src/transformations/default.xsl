<?xml version="1.0" encoding="UTF-8"?>

<!-- 

     Transformation template for 
     Abraham. Belgian Newspaper Catalogue
     https://krantencatalogus.be/en
     
     Vlaamse Erfgoedbibliotheken
     https://vlaamse-erfgoedbibliotheken.be
     David Coppoolse
     
     Abraham Full Records
     v2.0 - 20190808
     v3.0 - 20210124 - Added alternative titles, publication suspended, publication frequency, online editions, additional documentation, corporate author, publisher & format (anton@vlaamse-erfgoedbibliotheken.be)

     TODO: Escape quotes from library_holdings

-->

<xsl:stylesheet version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

    <xsl:output method="text" encoding="UTF-8" />

    <!-- Set delimiters for three data levels: l1 = column; l2 = multi-value; l3 = subfields -->
    <xsl:param name="delim-l1" select="','" />
    <xsl:param name="delim-l2" select="'|'" />
    <xsl:param name="delim-l3" select="'^'" />

    <!-- Set string delimiter (to use on all values) -->
    <xsl:param name="delim-str" select="'&quot;'" />

    <!-- Set new line character (to append after each record) -->
    <!--Server/PHP: <xsl:param name="crnl" select="'&#xa;'" /> -->
    <!--Browser/JS: <xsl:param name="crnl" select="'&#10;&#13;'" /> -->
    <xsl:param name="crnl" select="'&#xa;'" />

    <!-- Set fixed prefix for catalog_url -->
    <xsl:param name="url-prefix"
        select="'https://anet.be/record/opacbnc/'" />

    <xsl:template match="/">

        <!-- Output column headers -->
        <xsl:value-of select="concat('catalog_id',$delim-l1,'catalog_url',$delim-l1,'title',$delim-l1,'title_alt',$delim-l1,'language',$delim-l1,'place_of_issue',$delim-l1,'publisher',$delim-l1,'corporate_author',$delim-l1,'year_display_begin',$delim-l1,'year_display_end',$delim-l1,'year_sort_begin',$delim-l1,'year_sort_end',$delim-l1,'publication_suspended',$delim-l1,'publication_frequency',$delim-l1,'format',$delim-l1,'annotations',$delim-l1,'related_titles',$delim-l1,'subject_terms',$delim-l1,'library_holdings',$delim-l1,'online_editions',$delim-l1,'additional_documentation',$crnl)" />

        <!-- Output database records -->
        <xsl:for-each select="CATFILE/RECORD">
            <!-- catalog_id -->
            <xsl:value-of
                select="concat($delim-str,@cloi,$delim-str,$delim-l1)" />
            <!-- catalog_url -->
            <xsl:value-of
                select="concat($delim-str,$url-prefix,@cloi,$delim-str,$delim-l1)" />

            <!-- bibliography: title,place-of-issue,year-display-begin,year-display-end,year-sort-begin,year-sort-end,notes -->
            <xsl:apply-templates select="BSECTION" />

            <!-- releationships -->
            <xsl:apply-templates select="RSECTION" />
            <xsl:value-of select="$delim-l1" />

            <!-- subject terms -->
            <xsl:apply-templates select="SSECTION" />
            <xsl:value-of select="$delim-l1" />

            <!-- library_holdings -->
            <xsl:apply-templates select="HSECTION" />
            <xsl:value-of select="$delim-l1" />

            <!-- additional_documentation -->
            <xsl:apply-templates select="CSECTION" />

            <xsl:value-of select="$crnl" />

        </xsl:for-each>
    </xsl:template>

    <xsl:template match="BSECTION">

        <!-- main title -->
        <xsl:value-of select="$delim-str" />
            <xsl:choose>
                <xsl:when test="TI[@ty='h']">
                    <xsl:choose>
                        <xsl:when test="contains(TI/TITLE/DATA, '&quot;' )">
                            <xsl:call-template name="escape_quotes">
                                    <xsl:with-param name="string" select="TI/TITLE/DATA"/>
                            </xsl:call-template>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="TI/TITLE/DATA" />
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
            </xsl:choose>
            
        <xsl:value-of select="concat($delim-str,$delim-l1)" />

        <!-- alt title(s) -->
        <xsl:value-of select="$delim-str" />
        <xsl:for-each select="TI[not(@ty='h')]">
            <xsl:choose>
                <xsl:when test="contains(TITLE/DATA, '&quot;' )">
                    <xsl:call-template name="escape_quotes">
                        <xsl:with-param name="string" select="TITLE/DATA"/>
                    </xsl:call-template>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="TITLE/DATA" />
                </xsl:otherwise>
            </xsl:choose>
            <xsl:if test="position() != last()">
                <xsl:value-of select="$delim-l2" />
            </xsl:if>
        </xsl:for-each>
        <xsl:value-of select="$delim-str" />
        <xsl:value-of select="$delim-l1" />

        <!-- language -->
        <!-- MARC code, see https://www.loc.gov/marc/languages/language_code.html -->
        <xsl:value-of select="$delim-str" />
        <xsl:for-each select="LG">
            <xsl:value-of
                select="@lg" />
            <xsl:if test="position() != last()">
                <xsl:value-of select="$delim-l2" />
            </xsl:if>
        </xsl:for-each>
        <xsl:value-of select="$delim-str" />
        <xsl:value-of select="$delim-l1" />

        <!-- place_of_issue -->
        <xsl:value-of
            select="concat($delim-str,IM/PL/DATA,$delim-str,$delim-l1)" />

        <!-- publisher -->
        <xsl:value-of select="$delim-str" />
        <xsl:choose>
            <xsl:when test="contains(IM/UG/DATA, '&quot;' )">
                <xsl:call-template name="escape_quotes">
                    <xsl:with-param name="string" select="IM/UG/DATA"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="IM/UG/DATA" />
            </xsl:otherwise>
        </xsl:choose>

        <xsl:value-of select="concat($delim-str,$delim-l1)" />

        <!-- corporate author -->
        <xsl:value-of select="$delim-str" />
        <xsl:choose>
            <xsl:when test="contains(CA/NM//DATA, '&quot;' )">
                <xsl:call-template name="escape_quotes">
                    <xsl:with-param name="string" select="CA/NM/DATA"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="CA/NM/DATA" />
            </xsl:otherwise>
        </xsl:choose>

        <xsl:value-of select="concat($delim-str,$delim-l1)" />

        <!-- year_display_begin -->
        <!-- year publication started, including question mark if uncertain (text) -->
        <!-- if blank, same as year-sort-begin -->
        <xsl:choose>
            <xsl:when test="IM/JU/@ju1dv != ''">
                <xsl:value-of
                    select="concat($delim-str,IM/JU/@ju1dv,$delim-str,$delim-l1)" />
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of
                    select="concat($delim-str,IM/JU/@ju1sv,$delim-str,$delim-l1)" />
            </xsl:otherwise>
        </xsl:choose>

        <!-- year_display_end -->
        <!-- year publication ended, including question mark if uncertain (text) -->
        <!-- if blank, same as year-sort-end -->
        <xsl:choose>
            <xsl:when test="IM/JU/@ju2dv != ''">
                <xsl:value-of
                    select="concat($delim-str,IM/JU/@ju2dv,$delim-str,$delim-l1)" />
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of
                    select="concat($delim-str,IM/JU/@ju2sv,$delim-str,$delim-l1)" />
            </xsl:otherwise>
        </xsl:choose>

        <!-- year_sort_begin -->
        <!-- year publication (probably) started (numeric) -->
        <xsl:value-of
            select="concat($delim-str,IM/JU/@ju1sv,$delim-str,$delim-l1)" />

        <!-- year_sort_end -->
        <!-- year publication (probably) ended (numeric) -->
        <xsl:value-of
            select="concat($delim-str,IM/JU/@ju2sv,$delim-str,$delim-l1)" />

        <!-- publication_suspended -->
        <xsl:value-of select="$delim-str" />
        <xsl:for-each select="NT[@ty='sus']">
            <xsl:value-of select="DATA" />
            <xsl:if test="position() != last()">
                <xsl:value-of select="$delim-l2" />
            </xsl:if>
        </xsl:for-each>
        <xsl:value-of select="$delim-str" />
        <xsl:value-of select="$delim-l1" />

        <!-- publication_frequency -->
        <xsl:value-of select="$delim-str" />
        <xsl:for-each select="NT[@ty='freq']">
            <xsl:value-of select="DATA" />
            <xsl:if test="position() != last()">
                <xsl:value-of select="$delim-l2" />
            </xsl:if>
        </xsl:for-each>
        <xsl:value-of select="$delim-str" />
        <xsl:value-of select="$delim-l1" />

        <!-- format -->
        <xsl:value-of
            select="concat($delim-str,CO/@sz,$delim-str,$delim-l1)" />

        <!-- annotations -->
        <xsl:value-of select="$delim-str" />
        <xsl:apply-templates select="NT" />
        <xsl:value-of select="$delim-str" />
        <xsl:value-of select="$delim-l1" />
    </xsl:template>

    <!-- annotations -->
    <!-- note_type#note_content -->
    <xsl:template match="NT">
        <xsl:choose>
            <xsl:when test="@ty = 'tv'">
                <xsl:value-of
                    select="concat('Title varies',$delim-l3,DATA)" />
            </xsl:when>
            <xsl:when test="@ty = 'alg'">
                <xsl:value-of
                    select="concat('General note',$delim-l3,DATA)" />
            </xsl:when>
            <!-- if none of the above, annotation type is not valid in the context 
                of this database and should be corrected in the source -->
            <xsl:otherwise>
                <xsl:value-of select="concat('?!',@ty,$delim-l3,DATA)" />
            </xsl:otherwise>
        </xsl:choose>
        <xsl:if test="position() != last()">
            <xsl:value-of select="$delim-l2" />
        </xsl:if>
    </xsl:template>

    <!-- related_titles -->
    <!-- relationship_type#target_id#target_title -->
    <xsl:template match="RSECTION">
        <xsl:value-of select="$delim-str" />
        <xsl:for-each select="RELATION[not(@ty='bncl')]">
            <!-- not including bncl = relations to regular anet catalog records -->
            <xsl:choose>
                <xsl:when test="@ty = 'cb'">
                    <xsl:call-template name="doublequotes">
                        <xsl:with-param name="text" select="concat('Continued by',$delim-l3,@cloi,$delim-l3,DATA)"/>
                    </xsl:call-template>
                </xsl:when>
                <xsl:when test="@ty = 'co'">
                    <xsl:call-template name="doublequotes">
                        <xsl:with-param name="text" select="concat('Continuation of',$delim-l3,@cloi,$delim-l3,DATA)"/>
                    </xsl:call-template>
                </xsl:when>
                <xsl:when test="@ty = 'cbo'">
                    <xsl:call-template name="doublequotes">
                        <xsl:with-param name="text" select="concat('Continued by/Continuation of',$delim-l3,@cloi,$delim-l3,DATA)"/>
                    </xsl:call-template>
                </xsl:when>
                <xsl:when test="@ty = 'cob'">
                    <xsl:call-template name="doublequotes">
                        <xsl:with-param name="text" select="concat('Continuation of/Continued by',$delim-l3,@cloi,$delim-l3,DATA)"/>
                    </xsl:call-template>
                </xsl:when>
                <xsl:when test="@ty = 'in'">
                    <xsl:call-template name="doublequotes">
                        <xsl:with-param name="text" select="concat('Supplement to',$delim-l3,@cloi,$delim-l3,DATA)"/>
                    </xsl:call-template>
                </xsl:when>
                <xsl:when test="@ty = 'wi' or @ty = 'iwe' or @ty = 'ewi'">
                    <xsl:call-template name="doublequotes">
                        <xsl:with-param name="text" select="concat('With',$delim-l3,@cloi,$delim-l3,DATA)"/>
                    </xsl:call-template>
                </xsl:when>
                <xsl:when test="@ty = 'supe'">
                    <xsl:call-template name="doublequotes">
                        <xsl:with-param name="text" select="concat('Supplement Entry',$delim-l3,@cloi,$delim-l3,DATA)"/>
                    </xsl:call-template>
                </xsl:when>
                <xsl:when test="@ty = 'spare'">
                    <xsl:call-template name="doublequotes">
                        <xsl:with-param name="text" select="concat('Supplement Parent Entry',$delim-l3,@cloi,$delim-l3,DATA)"/>
                    </xsl:call-template>
                </xsl:when>
                <xsl:when test="@ty = 'oee'">
                    <xsl:call-template name="doublequotes">
                        <xsl:with-param name="text" select="concat('Other Edition Entry',$delim-l3,@cloi,$delim-l3,DATA)"/>
                    </xsl:call-template>
                </xsl:when>
                <!-- if none of the above, relationship type is not valid in the context 
                    of this database and should be corrected in the source -->
                <xsl:otherwise>
                    <xsl:call-template name="doublequotes">
                        <xsl:with-param name="text" select="concat('?!',$delim-l3,@cloi,$delim-l3,DATA)"/>
                    </xsl:call-template>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:if test="position() != last()">
                <xsl:value-of select="$delim-l2" />
            </xsl:if>
        </xsl:for-each>
        <xsl:value-of select="$delim-str" />
    </xsl:template>

    <!-- subject_terms -->
    <!-- term_id#term_name -->
    <xsl:template match="SSECTION">
        <xsl:value-of select="$delim-str" />
        <xsl:for-each select="SU">
            <xsl:value-of select="concat(@ac,$delim-l3,DATA)" />
            <xsl:if test="position() != last()">
                <xsl:value-of select="$delim-l2" />
            </xsl:if>
        </xsl:for-each>
        <xsl:value-of select="$delim-str" />
    </xsl:template>

    <!-- library_holdings -->
    <!-- holding_id#library_acronym#carrier_type#volumes -->
    <xsl:template match="HSECTION">
        <xsl:value-of select="$delim-str" />
        <xsl:for-each select="LIB">
            <xsl:for-each select="HOLDING">
                <xsl:value-of select="concat(@ploi,$delim-l3,../@library,$delim-l3,@ty,$delim-l3,PKBZ/DATA)" />
                <xsl:if test="position() != last()">
                    <xsl:value-of select="$delim-l2" />
                </xsl:if>        
            </xsl:for-each>        
            <xsl:if test="position() != last()">
                <xsl:value-of select="$delim-l2" />
            </xsl:if>
        </xsl:for-each>
        <xsl:value-of select="$delim-str" />
    </xsl:template>

    <xsl:template match="CSECTION">
        
        <xsl:value-of select="$delim-str" />
        
        <!-- online_editions -->
        <!-- resource_type#resource_url -->
        <xsl:for-each select="IN">
            <xsl:choose>
                <xsl:when test="@ty = 'full'">
                    <xsl:value-of
                        select="concat($delim-l3,NOTE/DATA,$delim-l3,@zurl)" />
                    <xsl:if test="position() != last()">
                        <xsl:value-of select="$delim-l2" />
                    </xsl:if>
                </xsl:when>
            </xsl:choose>
        </xsl:for-each>

        <xsl:value-of select="$delim-str" />
        <xsl:value-of select="$delim-l1" />
        <xsl:value-of select="$delim-str" />

        <!-- additional_documentation -->
        <!-- resource_type#resource_url -->
        <xsl:for-each select="IN">
            <xsl:choose>
                <xsl:when test="@ty = 'link'">
                    <xsl:value-of
                        select="concat('Reference',$delim-l3,NOTE/DATA,$delim-l3,@loc,'/',CONT/DATA)" />
                </xsl:when>
                <xsl:otherwise>
                    <xsl:choose>
                        <xsl:when test="not(@ty = 'full')">
                            <xsl:value-of
                                select="concat('?!',@ty,$delim-l3,NOTE/DATA,$delim-l3,@loc,'/',CONT/DATA)" />
                        </xsl:when>
                    </xsl:choose>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:if test="position() != last()">
                <xsl:value-of select="$delim-l2" />
            </xsl:if>
        </xsl:for-each>

        <xsl:value-of select="$delim-str" />


    </xsl:template>

    <xsl:template name="doublequotes">
        <xsl:param name="text" select="."/>
        <xsl:variable name="quot">"</xsl:variable>
        <xsl:choose>
            <xsl:when test="contains($text, $quot)">
                <xsl:value-of select="substring-before($text, $quot)"/>
                <xsl:text>""</xsl:text>
                <xsl:call-template name="doublequotes">
                    <xsl:with-param name="text" select="substring-after($text, $quot)"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$text"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="escape_quotes">
    <!-- https://developertips.blogspot.com/2007/03/escape-csv-string-in-xslt.html -->
    <!-- Helper function for escaping quotes -->
        <xsl:param name="string" />

        <xsl:value-of select="substring-before( $string, '&quot;' )" />
        <xsl:text>""</xsl:text>
        <xsl:variable name="substring_after_first_quote"
            select="substring-after( $string, '&quot;' )" />
        <xsl:choose>
            <xsl:when test="not( contains( $substring_after_first_quote, '&quot;' ) )">
                <xsl:value-of select="$substring_after_first_quote" />
            </xsl:when>
            <xsl:otherwise>
            <!-- The substring after the first quote contains a quote.
                 So, we call ourself recursively to escape the quotes
                 in the substring after the first quote.  -->
                <xsl:call-template name="escape_quotes">
                    <xsl:with-param name="string" select="$substring_after_first_quote"/>
                </xsl:call-template>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

</xsl:stylesheet>