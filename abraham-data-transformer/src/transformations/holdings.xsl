<?xml version="1.0" encoding="UTF-8"?>

<!-- 

     Transformation template for 
     Abraham. Belgian Newspaper Catalogue
     https://krantencatalogus.be/en
     
     Vlaamse Erfgoedbibliotheken
     https://vlaamse-erfgoedbibliotheken.be
     David Coppoolse
     
     Abraham Holding Information
     v2.0 - 20190808

-->
     
     

<xsl:stylesheet version="2.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

	<xsl:output method="text" encoding="UTF-8" />

	<!-- Set delimiters for three data levels: L1 = column; L2 = multi-value; L3 = subfields -->
	<xsl:param name="delimL1" select="','" />
	<xsl:param name="delimL2" select="'|'" />
	<xsl:param name="delimL3" select="'^'" />

	<!-- Set string delimiter (to use on all values) -->
	<xsl:param name="delimStr" select="'&quot;'" />

	<!-- Set new line character (to append after each record) -->
	<!--Server/PHP: <xsl:param name="lineEnd" select="'&#xa;'" /> -->
	<!--Browser/JS: <xsl:param name="lineEnd" select="'&#10;&#13;'" /> -->
	<xsl:param name="lineEnd" select="'&#xa;'" />

	<!-- Set fixed prefix for catalog_url -->
	<xsl:param name="url-prefix"
		select="'https://anet.be/record/opacbnc/'" />

	<xsl:template match="/">

		<!-- Output column headers -->
		<xsl:value-of select="concat(
				'catalog_id', $delimL1,
				'catalog_url', $delimL1,
				'title', $delimL1,
				'language',	$delimL1,
				'place_of_issue', $delimL1,
				'year_sort_begin', $delimL1,
				'year_sort_end', $delimL1,
				'holding_id', $delimL1,
				'holding_library_acronym', $delimL1,
				'holding_carrier_type', $delimL1,
				'holding_location_mark', $delimL1,
				'holding_volumes',	$delimL1,
				'holding_annotations',$lineEnd
			)" 
		/>

		<!-- Output database records -->

		<xsl:for-each select="CATFILE/RECORD">

			<xsl:choose>

				<!-- If holding info present -->
				<xsl:when test="HSECTION">

					<xsl:for-each select="HSECTION/LIB/HOLDING">
					
    						<!-- catalog_id -->
    						<xsl:value-of
    							select="concat($delimStr,../../../@cloi,$delimStr,$delimL1)" />
    
    						<!-- catalog_url -->
    						<xsl:value-of
    							select="concat($delimStr,$url-prefix,../../../@cloi,$delimStr,$delimL1)" />
    
    						<!-- bibliography: title,place-of-issue,year-sort-begin,year-sort-end -->
    						<xsl:apply-templates select="../../../BSECTION" />
    
    						<!-- holding_id -->
    						<xsl:value-of
    							select="concat($delimStr,@ploi,$delimStr,$delimL1)" />
    
    						<!-- holding_library_acronym -->
    						<xsl:value-of
    							select="concat($delimStr,../@library,$delimStr,$delimL1)" />
    
    						<!-- holding_carrier_type -->
    						<xsl:value-of
    							select="concat($delimStr,@ty,$delimStr,$delimL1)" />
    
    						<!-- holding_call_number --><xsl:value-of
    							select="concat($delimStr,PK/DATA,$delimStr,$delimL1)" />
    
    						<!-- holding_volumes -->
    						<xsl:value-of
    							select="concat($delimStr,PKBZ/DATA,$delimStr,$delimL1)" />
    
    						<!-- holding_annotations -->
    						<xsl:value-of
    							select="concat($delimStr,PKNOTE/DATA,$delimStr)" />
    
    						<xsl:value-of select="$lineEnd" />

					</xsl:for-each>

				</xsl:when>

				<!-- If subject terms NOT present -->
				<xsl:otherwise>

					<!-- catalog_id -->
					<xsl:value-of
						select="concat($delimStr,@cloi,$delimStr,$delimL1)" />

					<!-- catalog_url -->
					<xsl:value-of
						select="concat($delimStr,$url-prefix,@cloi,$delimStr,$delimL1)" />

					<!-- bibliography: title,place-of-issue,year-sort-begin,year-sort-end -->
					<xsl:apply-templates select="BSECTION" />

					<!-- blank values for holding information + end of 
						record -->
					<xsl:value-of
						select="concat($delimL1,$delimL1,$delimL1,$delimL1,$delimL1,$lineEnd)" />

				</xsl:otherwise>

			</xsl:choose>

		</xsl:for-each>

	</xsl:template>


	<xsl:template match="BSECTION">

		<!-- title -->
		<xsl:value-of select="$delimStr" />
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
			
		<xsl:value-of select="concat($delimStr,$delimL1)" />
		
		
		<!-- language -->
		<!-- MARC code, see https://www.loc.gov/marc/languages/language_code.html -->
		<xsl:value-of select="$delimStr" />
		<xsl:for-each select="LG">
			<xsl:value-of select="@lg" />
			<xsl:if test="position() != last()">
				<xsl:value-of select="$delimL2" />
			</xsl:if>
		</xsl:for-each>
		<xsl:value-of select="$delimStr" />
		<xsl:value-of select="$delimL1" />

		<!-- place_of_issue -->
		<xsl:value-of
			select="concat($delimStr,IM/PL/DATA,$delimStr,$delimL1)" />

		<!-- year_sort_begin -->
		<!-- year publication (probably) started (numeric) -->
		<xsl:value-of
			select="concat($delimStr,IM/JU/@ju1sv,$delimStr,$delimL1)" />

		<!-- year_sort_end -->
		<!-- year publication (probably) ended (numeric) -->
		<xsl:value-of
			select="concat($delimStr,IM/JU/@ju2sv,$delimStr,$delimL1)" />

	</xsl:template>
	
<!-- https://developertips.blogspot.com/2007/03/escape-csv-string-in-xslt.html -->
<!-- Helper function for escaping quotes -->
<xsl:template name="escape_quotes">
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