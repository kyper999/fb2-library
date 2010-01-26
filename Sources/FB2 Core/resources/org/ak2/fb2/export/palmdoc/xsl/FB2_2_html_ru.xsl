<?xml version="1.0" encoding="windows-1251"?><xsl:stylesheet version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:l="http://www.w3.org/1999/xlink"
	xmlns:xlink="http://www.w3.org/1999/xlink"
	xmlns:fb="http://www.gribuser.ru/xml/fictionbook/2.0">
		<xsl:output method="html" encoding="UTF8" />	<xsl:output method="html" media-type="text/html; charset=UTF8"/>
		<xsl:param name="saveimages" select="2" />	<xsl:param name="tocdepth" select="3" />	<xsl:param name="toccut" select="1" />	<xsl:param name="skipannotation" select="1" />	<xsl:param name="NotesTitle" select="'������'" />	<xsl:key name="note-link" match="section" use="@id" />	<xsl:template match="/*">		<html>			<head>				<metadata>					<dc-metadata
						xmlns:dc="http://purl.org/metadata/dublin_core"
						xmlns:oebpackage="http://openebook.org/namespaces/oeb-package/1.0/">						<dc:Date>16-May-05</dc:Date>					</dc-metadata>				</metadata>				<GUIDE></GUIDE>				<!--			
					<title>
					<xsl:value-of disable-output-escaping="yes" select="description/title-info/book-title"/>
					</title>
				-->			</head>			<body>				<xsl:apply-templates
					select="description/title-info/coverpage/image" />				<h1>					<xsl:apply-templates
						select="description/title-info/book-title" />
				</h1>				<h2>					<small>						<xsl:for-each
							select="description/title-info/author">							<b>								<xsl:call-template name="author" />							</b>						</xsl:for-each>					</small>				</h2>				<xsl:if test="description/title-info/sequence">					<p>						<xsl:for-each
							select="description/title-info/sequence">							<xsl:call-template name="sequence" />							<xsl:text disable-output-escaping="yes">								&lt;br&gt;							</xsl:text>						</xsl:for-each>					</p>				</xsl:if>				<xsl:if test="$skipannotation = 0">					<xsl:for-each
						select="description/title-info/annotation">						<div>							<xsl:call-template name="annotation" />						</div>						<hr />					</xsl:for-each>				</xsl:if>				<!-- BUILD TOC -->				<xsl:if
					test="$tocdepth &gt; 0 and count(//body[not(@name) or @name != 'notes']//title) &gt; 1">					<hr />					<blockquote>						<ul>							<xsl:apply-templates select="body"
								mode="toc" />						</ul>					</blockquote>				</xsl:if>				<!-- BUILD BOOK -->				<xsl:call-template name="DocGen" />			</body>		</html>	</xsl:template>	<!-- author -->	<xsl:template name="author">		<xsl:value-of disable-output-escaping="yes" select="first-name" />		<xsl:text disable-output-escaping="no">&#032;</xsl:text>		<xsl:value-of disable-output-escaping="yes"
			select="middle-name" />		&#032;		<xsl:text disable-output-escaping="no">&#032;</xsl:text>		<xsl:value-of disable-output-escaping="yes" select="last-name" />		<xsl:text disable-output-escaping="yes">&lt;br&gt;</xsl:text>	</xsl:template>	<!-- secuence -->	<xsl:template name="sequence">		<LI />		<xsl:value-of disable-output-escaping="yes" select="@name" />		<xsl:if test="@number">			<xsl:text disable-output-escaping="no">,&#032;#</xsl:text>			<xsl:value-of disable-output-escaping="yes"
				select="@number" />		</xsl:if>		<xsl:if test="sequence">			<UL>				<xsl:for-each select="sequence">					<xsl:call-template name="sequence" />				</xsl:for-each>			</UL>		</xsl:if>		<!--      <xsl:text disable-output-escaping="yes">&lt;br&gt;</xsl:text> -->	</xsl:template>	<!-- toc template: body -->	<xsl:template match="body" mode="toc">		<xsl:choose>			<xsl:when test="not(@name) or @name != 'notes'">				<xsl:apply-templates mode="toc" select="section" />
			</xsl:when>			<xsl:otherwise>				<br />				<li>					<a href="#TOC_notes_{generate-id()}"
						filepos="000000000">
						<xsl:value-of disable-output-escaping="yes"
							select="$NotesTitle" />
					</a>
				</li>
			</xsl:otherwise>		</xsl:choose>	</xsl:template>	<!-- toc template: section -->	<xsl:template match="section" mode="toc">		<xsl:if
			test="title | .//section[count(ancestor::section) &lt; $tocdepth]/title">			<li>				<xsl:apply-templates select="title" mode="toc" />				<xsl:if
					test="(.//section/title) and (count(ancestor::section) &lt; $tocdepth or $tocdepth=	4)">					<UL>						<xsl:apply-templates select="section"
							mode="toc" />
					</UL>				</xsl:if>			</li>		</xsl:if>	</xsl:template>	<!-- toc template: title -->	<xsl:template match="title" mode="toc">		<a href="#TOC_{generate-id()}" filepos="000000000">			<xsl:choose>				<xsl:when test="$toccut &gt; 0">					<xsl:value-of disable-output-escaping="yes"
						select="normalize-space(p[1])" />				</xsl:when>				<xsl:otherwise>					<xsl:for-each select="title/p">						<xsl:if test="position()>1">							<xsl:text></xsl:text>
						</xsl:if>						<xsl:value-of disable-output-escaping="yes"
							select="normalize-space(.)" />					</xsl:for-each>				</xsl:otherwise>			</xsl:choose>		</a>	</xsl:template>	<!-- description -->	<xsl:template match="description">		<xsl:apply-templates />	</xsl:template>	<!-- section -->	<xsl:template match="section">		<xsl:call-template name="preexisting_id" />		<xsl:apply-templates select="title" />		<div>			<xsl:apply-templates select="*[name()!='title']" />
		</div>	</xsl:template>	<!-- title -->	<xsl:template match="section/title|poem/title">		<xsl:choose>			<xsl:when
				test="ancestor::body/@name = 'notes' and not(following-sibling::section)">				<!--<xsl:call-template name="preexisting_id"/>
					<xsl:for-each select="parent::section">
					<xsl:call-template name="preexisting_id"/>
					</xsl:for-each>-->				<strong>					<xsl:apply-templates />
				</strong>			</xsl:when>			<xsl:otherwise>				<xsl:choose>					<xsl:when test="count(ancestor::node()) &lt; 9">						<div>							<xsl:element
								name="{concat('h',count(ancestor::node())-3)}">								<xsl:attribute name="align">									center								</xsl:attribute>								<a name="TOC_{generate-id()}"></a>								<xsl:call-template
									name="preexisting_id" />								<xsl:apply-templates />							</xsl:element>						</div>					</xsl:when>					<xsl:otherwise>						<div>							<xsl:element name="h6">								<xsl:call-template
									name="preexisting_id" />								<xsl:apply-templates />							</xsl:element>						</div>					</xsl:otherwise>				</xsl:choose>			</xsl:otherwise>		</xsl:choose>	</xsl:template>	<!-- body/title -->	<xsl:template match="body/title">		<div>			<h1>				<xsl:apply-templates />
			</h1>
		</div>	</xsl:template>	<!-- title/p and the like -->	<xsl:template match="title/p|title-info/book-title">		<xsl:apply-templates />		<xsl:text disable-output-escaping="yes">&lt;br&gt;</xsl:text>	</xsl:template>	<!-- subtitle -->	<xsl:template match="subtitle">		<xsl:call-template name="preexisting_id" />		<h5>			<xsl:apply-templates />		</h5>	</xsl:template>	<!-- p -->	<xsl:template match="p">		<xsl:call-template name="preexisting_id" />		&#160;&#160;&#160;		<xsl:apply-templates />		<xsl:text disable-output-escaping="yes">&lt;br&gt;</xsl:text>	</xsl:template>	<!-- strong -->	<xsl:template match="strong">		<b>			<xsl:apply-templates />
		</b>	</xsl:template>	<!-- emphasis -->	<xsl:template match="emphasis">		<i>			<xsl:apply-templates />
		</i>	</xsl:template>	<!-- style -->	<xsl:template match="style">		<span class="{@name}">			<xsl:apply-templates />
		</span>	</xsl:template>	<!-- empty-line -->	<xsl:template match="empty-line">		&#160;		<xsl:text disable-output-escaping="yes">&lt;br&gt;</xsl:text>	</xsl:template>	<!-- link -->	<xsl:template match="a">		<xsl:element name="a">			<xsl:attribute name="href">				<xsl:value-of select="@href" />
			</xsl:attribute>			<!--
				<xsl:attribute name="title">
				<xsl:choose>
				<xsl:when test="starts-with(@href,'#')"><xsl:value-of select="key('note-link',substring-after(@href,'#'))/p"/></xsl:when>
				<xsl:otherwise><xsl:value-of select="key('note-link',@href)/p"/></xsl:otherwise>
				</xsl:choose>
				</xsl:attribute>
			-->			<xsl:attribute name="filepos">000000000</xsl:attribute>			<xsl:choose>				<xsl:when test="(@type) = 'note'">					<sup>						<xsl:apply-templates />					</sup>				</xsl:when>				<xsl:otherwise>					<xsl:apply-templates />				</xsl:otherwise>			</xsl:choose>		</xsl:element>	</xsl:template>	<!-- annotation -->	<xsl:template name="annotation">		<xsl:call-template name="preexisting_id" />		<h3>Annotation</h3>		<xsl:apply-templates />	</xsl:template>	<!-- epigraph -->	<xsl:template match="epigraph">		<blockquote class="epigraph">			<xsl:call-template name="preexisting_id" />			<xsl:apply-templates />		</blockquote>		<xsl:if test="name(./following-sibling::node()) = 'epigraph'">			<br />
		</xsl:if>		<br />	</xsl:template>	<!-- epigraph/text-author -->	<xsl:template match="epigraph/text-author">		<blockquote>			<b>				<i>					<xsl:apply-templates />
				</i>
			</b>		</blockquote>	</xsl:template>	<!-- cite -->	<xsl:template match="cite">		<blockquote>			<xsl:call-template name="preexisting_id" />			<xsl:apply-templates />		</blockquote>	</xsl:template>	<!-- cite/text-author -->	<xsl:template match="text-author">		<blockquote>			<i>				<xsl:apply-templates />
			</i>
		</blockquote>	</xsl:template>	<!-- date -->	<xsl:template match="date">		<xsl:choose>			<xsl:when test="not(@value)">				&#160;&#160;&#160;				<xsl:apply-templates />				<xsl:text disable-output-escaping="yes">					&lt;br&gt;				</xsl:text>			</xsl:when>			<xsl:otherwise>				&#160;&#160;&#160;				<xsl:value-of disable-output-escaping="yes"
					select="@value" />				<xsl:text disable-output-escaping="yes">					&lt;br&gt;				</xsl:text>			</xsl:otherwise>		</xsl:choose>	</xsl:template>	<!-- poem -->	<xsl:template match="poem">		<blockquote>			<xsl:call-template name="preexisting_id" />			<xsl:apply-templates />		</blockquote>	</xsl:template>	<!-- stanza -->	<xsl:template match="stanza">		&#160;		<xsl:text disable-output-escaping="yes">&lt;br&gt;</xsl:text>		<xsl:apply-templates />		&#160;		<xsl:text disable-output-escaping="yes">&lt;br&gt;</xsl:text>	</xsl:template>	<!-- v -->	<xsl:template match="v">		<xsl:call-template name="preexisting_id" />		<xsl:apply-templates />		<xsl:text disable-output-escaping="yes">&lt;br&gt;</xsl:text>	</xsl:template>	<!-- image - inline -->	<xsl:template match="p/image|v/image|td/image|subtitle/image">		<xsl:if test="$saveimages &gt; 0">			<img border="0">				<xsl:attribute name="src">					<xsl:value-of select="@prctype" />
				</xsl:attribute>				<xsl:attribute name="recindex">					<xsl:value-of select="@prcindex" />
				</xsl:attribute>			</img>		</xsl:if>	</xsl:template>	<!-- image - block -->	<xsl:template match="image">		<xsl:if test="$saveimages &gt; 0">			<div align="center">				<img border="1">					<xsl:attribute name="src">						<xsl:value-of select="@prctype" />
					</xsl:attribute>					<xsl:attribute name="recindex">						<xsl:value-of select="@prcindex" />
					</xsl:attribute>				</img>			</div>		</xsl:if>	</xsl:template>	<!-- we preserve used ID's and drop unused ones -->	<xsl:template name="preexisting_id">		<xsl:variable name="i" select="@id" />		<xsl:if test="@id and //a[@href=concat('#',$i)]">			<a name="{@id}" />
		</xsl:if>	</xsl:template>	<!-- book generator -->	<xsl:template name="DocGen">		<xsl:for-each select="body">			<xsl:if test="position()!=1">				<hr />			</xsl:if>			<xsl:choose>				<xsl:when test="@name = 'notes'">					<h4>						<a name="#TOC_notes_{generate-id()}" />						<xsl:value-of disable-output-escaping="yes"
							select="$NotesTitle" />
					</h4>
				</xsl:when>				<xsl:when test="@name">					<h4>						<xsl:value-of disable-output-escaping="yes"
							select="@name" />
					</h4>
				</xsl:when>			</xsl:choose>			<!-- <xsl:apply-templates /> -->			<xsl:apply-templates />		</xsl:for-each>	</xsl:template>	<xsl:template name="CSS_Style_Screen">		A { color : #0002CC } A:HOVER { color : #BF0000 } BODY		{font-family : Verdana, Geneva, Arial, Helvetica, sans-serif;		text-align : justify } H1{ font-size : 160%; font-style :		normal; font-weight : bold; text-align : left; text-transform :		capitalize; border : 1px solid Black; background-color :		#E7E7E7; text-transform : capitalize; margin-left : 0px;		padding-left : 0.5em; } H2{ font-size : 130%; font-style :		normal; font-weight : bold; text-align : left; text-transform :		capitalize; background-color : #EEEEEE; border : 1px solid Gray;		text-transform : capitalize; padding-left : 1em; } H3{ font-size		: 110%; font-style : normal; font-weight : bold; text-align :		left; background-color : #F1F1F1; border : 1px solid Silver;		text-transform : capitalize; padding-left : 1.5em;} H4{		font-size : 100%; font-style : normal; font-weight : bold;		text-align : left padding-left : 0.5em; text-transform :		capitalize; border : 1px solid Gray; background-color : #F4F4F4;		padding-left : 2em;} H5{ font-size : 100%; font-style : italic;		font-weight : bold; text-align : left; text-transform :		capitalize;border : 1px solid Gray; background-color : #F4F4F4;		padding-left : 2.5em;} H6{ font-size : 100%; font-style :		italic; font-weight : normal; text-align : left; text-transform		: capitalize;border : 1px solid Gray; background-color :		#F4F4F4; padding-left : 2.5em;} SMALL{ font-size : 80% }		BLOCKQUOTE{ margin : 0 1em 0.2em 4em } HR{ color : Black } UL{		padding-left : 1em; margin-left: 0} .epigraph{margin-right:5em;		margin-left : 25%;} DIV{font-family : Verdana, Geneva, Arial,		Helvetica, sans-serif; text-align : justify}	</xsl:template>	<xsl:template name="CSS_Style_Print">		A { color : #0002CC } A:HOVER { color : #BF0000 } BODY		{font-family : "Times New Roman", Times, serif; text-align :		justify } H1{ font-family : Verdana, Geneva, Arial, Helvetica,		sans-serif; font-size : 160%; font-style : normal; font-weight :		bold; text-align : left; text-transform : capitalize } H2{		font-family : Verdana, Geneva, Arial, Helvetica, sans-serif;		font-size : 130%; font-style : normal; font-weight : bold;		text-align : left; text-transform : capitalize } H3{ font-family		: Verdana, Geneva, Arial, Helvetica, sans-serif; font-size :		110%; font-style : normal; font-weight : bold; text-align : left		} H4{ font-family : Verdana, Geneva, Arial, Helvetica,		sans-serif; font-size : 100%; font-style : normal; font-weight :		bold; text-align : left } H5,H6{ font-family : Verdana, Geneva,		Arial, Helvetica, sans-serif; font-size : 100%; font-style :		italic; font-weight : normal; text-align : left; text-transform		: uppercase } SMALL{ font-size : 80% } BLOCKQUOTE{ margin : 0		1em 0.2em 4em } HR{ color : Black } DIV{font-family : "Times New		Roman", Times, serif; text-align : justify}	</xsl:template></xsl:stylesheet>