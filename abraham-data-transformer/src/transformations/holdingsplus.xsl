<?xml version="1.0" encoding="UTF-8"?>

<!-- 

     Transformation template for 
     Abraham. Belgian Newspaper Catalogue
     https://krantencatalogus.be/en
     
     Vlaamse Erfgoedbibliotheken
     https://vlaamse-erfgoedbibliotheken.be
     David Coppoolse
     
     Abraham Holding Information
     v3.0 - 20191026

-->
    	

<xsl:stylesheet version="3.0"
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
				'publication_suspended', $delimL1,
				'publication_frequency', $delimL1,
				'related_titles', $delimL1,
				'online_editions', $delimL1,
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

			<xsl:for-each select="HSECTION/LIB/HOLDING">
				
				<!-- catalog_id -->
				<xsl:value-of
					select="concat($delimStr,../../../@cloi,$delimStr,$delimL1)" />
		
				<!-- catalog_url -->
				<xsl:value-of
					select="concat($delimStr,$url-prefix,../../../@cloi,$delimStr,$delimL1)" />
		
				<!-- bibliography: title,place_of_issue,year_sort_begin,year_sort_end,publication_suspended,publication_frequency -->
				<xsl:apply-templates select="../../../BSECTION" />
				
				<!-- related_titles -->
				<xsl:apply-templates select="../../../RSECTION" />
				<xsl:value-of
					select="$delimL1" />
					
				<!-- online_editions -->
				<xsl:apply-templates select="../../../CSECTION" />
				<xsl:value-of
					select="$delimL1" />
		
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
			
		<!-- publication_suspended -->
        <xsl:value-of select="$delimStr" />
		<xsl:for-each select="NT[@ty='sus']">
			<xsl:value-of select="DATA" />
			<xsl:if test="position() != last()">
				<xsl:value-of select="$delimL2" />
			</xsl:if>
		</xsl:for-each>
		<xsl:value-of select="$delimStr" />
		<xsl:value-of select="$delimL1" />
		
		<!-- publication_frequency -->
        <xsl:value-of select="$delimStr" />
		<xsl:for-each select="NT[@ty='freq']">
			<xsl:value-of select="DATA" />
			<xsl:if test="position() != last()">
				<xsl:value-of select="$delimL2" />
			</xsl:if>
		</xsl:for-each>
		<xsl:value-of select="$delimStr" />
		<xsl:value-of select="$delimL1" />
        
	</xsl:template>
	
	<xsl:template match="CSECTION">
	<!-- digital_resources -->
	<!-- resource_type#resource_url -->
		<xsl:value-of select="$delimStr" />
		<xsl:for-each select="IN[@ty='full']">
			  <xsl:variable name="label">
			    <xsl:call-template name="string-replace-all">
			      <xsl:with-param name="text" select="NOTE/DATA" />
			      <xsl:with-param name="replace" select="'Electronically available: '" />
			      <xsl:with-param name="by" select="''" />
			    </xsl:call-template>
			  </xsl:variable>
			  <xsl:value-of
					select="concat($label,$delimL3,@loc,$delimL3,CONT/DATA)" />
			<xsl:if test="position() != last()">
				<xsl:value-of select="$delimL2" />
			</xsl:if>
		</xsl:for-each>
		<xsl:value-of select="$delimStr" />
	</xsl:template>

	<xsl:template match="RSECTION">
	<!-- related_titles -->
	<!-- relationship_type^target_id^target_title -->
		<xsl:value-of select="$delimStr" />
		<xsl:for-each select="RELATION[not(@ty='bncl')]">
			<!-- not including bncl = relations to regular anet catalog records -->
			<xsl:choose>
				<xsl:when test="@ty = 'cb'">
					<xsl:value-of
						select="concat('Continued by',$delimL3,@cloi,$delimL3,DATA)" />
				</xsl:when>
				<xsl:when test="@ty = 'co'">
					<xsl:value-of
						select="concat('Continuation of',$delimL3,@cloi,$delimL3,DATA)" />
				</xsl:when>
				<xsl:when test="@ty = 'cbo'">
					<xsl:value-of
						select="concat('Continued by/Continuation of',$delimL3,@cloi,$delimL3,DATA)" />
				</xsl:when>
				<xsl:when test="@ty = 'cob'">
					<xsl:value-of
						select="concat('Continuation of/Continued by',$delimL3,@cloi,$delimL3,DATA)" />
				</xsl:when>
				<xsl:when test="@ty = 'in'">
					<xsl:value-of
						select="concat('Supplement to',$delimL3,@cloi,$delimL3,DATA)" />
				</xsl:when>
				<xsl:when test="@ty = 'wi'">
					<xsl:value-of
						select="concat('With supplement',$delimL3,@cloi,$delimL3,DATA)" />
				</xsl:when>
				<xsl:when test="@ty = 'iwe' or @ty = 'ewi'">
					<xsl:value-of
						select="concat('With parallel title',$delimL3,@cloi,$delimL3,DATA)" />
				</xsl:when>
				<!-- if none of the above, relationship type is not valid in the context 
					of this database and should be corrected in the source -->
				<xsl:otherwise>
					<xsl:value-of
						select="concat('Unknown relationship',@ty,$delimL3,@cloi,$delimL3,DATA)" />
				</xsl:otherwise>
			</xsl:choose>
			<xsl:if test="position() != last()">
				<xsl:value-of select="$delimL2" />
			</xsl:if>
		</xsl:for-each>
		<xsl:value-of select="$delimStr" />
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
	
 <xsl:template name="string-replace-all">
 <!-- http://geekswithblogs.net/Erik/archive/2008/04/01/120915.aspx -->
    <xsl:param name="text" />
    <xsl:param name="replace" />
    <xsl:param name="by" />
    <xsl:choose>
      <xsl:when test="contains($text, $replace)">
        <xsl:value-of select="substring-before($text,$replace)" />
        <xsl:value-of select="$by" />
        <xsl:call-template name="string-replace-all">
          <xsl:with-param name="text"
          select="substring-after($text,$replace)" />
          <xsl:with-param name="replace" select="$replace" />
          <xsl:with-param name="by" select="$by" />
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$text" />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

</xsl:stylesheet>