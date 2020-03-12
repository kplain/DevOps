<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0" >

	<xsl:output method="xml" encoding="utf-8" indent="yes"/>

	<xsl:param name="environments"/>

	<xsl:param name="deployerHost"/>
	<xsl:param name="deployerPort"/>
	<xsl:param name="deployerUsername"/>
	<xsl:param name="deployerPassword"/>
	<xsl:param name="deployerPasswordHandle"/>

	<xsl:param name="repoName"/>
	<xsl:param name="repoPath"/>
	<xsl:param name="projectName"/>

	<xsl:param name="buildAPI"/>
	<xsl:param name="envConfig"/>

	<xsl:variable name="environment" select="document($envConfig)/environments"/>

	<xsl:template match="@*|node()">
		<xsl:copy>
			<xsl:apply-templates select="@*|node()" />
		</xsl:copy>
	</xsl:template>

	<xsl:template match="DeployerSpec/DeployerServer">
		<DeployerServer>
			<host><xsl:value-of select="$deployerHost"/>:<xsl:value-of select="$deployerPort"/></host>
			<user><xsl:value-of select="$deployerUsername"/></user>
			<pwd><xsl:value-of select="$deployerPassword"/></pwd>
			<xsl:if test="deployerPasswordHandle"><pwdHandle><xsl:value-of select="$deployerPasswordHandle"/></pwdHandle></xsl:if>
		</DeployerServer>
	</xsl:template>

	<xsl:template match="DeployerSpec/Environment">
		<Environment>
			<IS>
				<xsl:call-template name="processEnvironmentISs">
					<xsl:with-param name="string" select="$environments"/>
				</xsl:call-template>
			</IS>
			<xsl:if test="$buildAPI = 'true'">
			<APIGateway>
				<xsl:call-template name="processEnvironmentAPIs">
					<xsl:with-param name="string" select="$environments"/>
				</xsl:call-template>
			</APIGateway>
			</xsl:if>
			<xsl:call-template name="processEnvironmentGroups">
				<xsl:with-param name="string" select="$environments"/>
			</xsl:call-template>

			<xsl:apply-templates select="@* | *" />

		</Environment>
	</xsl:template>

	<xsl:template match="DeployerSpec/Environment/Repository">
		<Repository>

			<repalias>
				<xsl:attribute name="name"><xsl:value-of select="$repoName"/></xsl:attribute>
				<type>FlatFile</type>
				<urlOrDirectory><xsl:value-of select="$repoPath"/></urlOrDirectory>
				<createIndex>true</createIndex>
				<Test>true</Test>
			</repalias>

			<xsl:apply-templates select="@* | *" />

		</Repository>
	</xsl:template>

	<xsl:template match="DeployerSpec/Projects">
		<Projects>

			<xsl:call-template name="processProjects">
				<xsl:with-param name="string" select="$environments"/>
			</xsl:call-template>

			<xsl:apply-templates select="@* | *" />

		</Projects>
	</xsl:template>

	<xsl:template name="processProjects">
		<xsl:param name="string" />
		<xsl:param name="delimiter" select="','" />

		<xsl:choose>
			<xsl:when test="$delimiter and contains($string, $delimiter)">
				<xsl:variable name="targetEnvironment" select="substring-before($string, $delimiter)" />
				<xsl:call-template name="makeProject">
					<xsl:with-param name="targetEnvironment" select="$targetEnvironment" />
				</xsl:call-template>
				<xsl:call-template name="processProjects">
					<xsl:with-param name="string" select="substring-after($string, $delimiter)" />
					<xsl:with-param name="delimiter" select="$delimiter" />
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<xsl:variable name="targetEnvironment" select="$string" />
				<xsl:call-template name="makeProject">
					<xsl:with-param name="targetEnvironment" select="$targetEnvironment" />
				</xsl:call-template>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<xsl:template name="processEnvironmentISs">
		<xsl:param name="string" />
		<xsl:param name="delimiter" select="','" />

		<xsl:choose>
			<xsl:when test="$delimiter and contains($string, $delimiter)">
				<xsl:variable name="targetEnvironment" select="substring-before($string, $delimiter)" />
				<xsl:call-template name="makeEnvironmentIS">
					<xsl:with-param name="targetEnvironment" select="$targetEnvironment" />
				</xsl:call-template>
				<xsl:call-template name="processEnvironmentISs">
					<xsl:with-param name="string" select="substring-after($string, $delimiter)" />
					<xsl:with-param name="delimiter" select="$delimiter" />
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<xsl:variable name="targetEnvironment" select="$string" />
				<xsl:call-template name="makeEnvironmentIS">
					<xsl:with-param name="targetEnvironment" select="$targetEnvironment" />
				</xsl:call-template>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<xsl:template name="processEnvironmentAPIs">
		<xsl:param name="string" />
		<xsl:param name="delimiter" select="','" />

		<xsl:choose>
			<xsl:when test="$delimiter and contains($string, $delimiter)">
				<xsl:variable name="targetEnvironment" select="substring-before($string, $delimiter)" />
				<xsl:call-template name="makeEnvironmentAPI">
					<xsl:with-param name="targetEnvironment" select="$targetEnvironment" />
				</xsl:call-template>
				<xsl:call-template name="processEnvironmentAPIs">
					<xsl:with-param name="string" select="substring-after($string, $delimiter)" />
					<xsl:with-param name="delimiter" select="$delimiter" />
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<xsl:variable name="targetEnvironment" select="$string" />
				<xsl:call-template name="makeEnvironmentAPI">
					<xsl:with-param name="targetEnvironment" select="$targetEnvironment" />
				</xsl:call-template>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<xsl:template name="processEnvironmentGroups">
		<xsl:param name="string" />
		<xsl:param name="delimiter" select="','" />

		<xsl:choose>
			<xsl:when test="$delimiter and contains($string, $delimiter)">
				<xsl:variable name="targetEnvironment" select="substring-before($string, $delimiter)" />
				<xsl:call-template name="makeEnvironmentGroup">
					<xsl:with-param name="targetEnvironment" select="$targetEnvironment" />
				</xsl:call-template>
				<xsl:call-template name="processEnvironmentGroups">
					<xsl:with-param name="string" select="substring-after($string, $delimiter)" />
					<xsl:with-param name="delimiter" select="$delimiter" />
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<xsl:variable name="targetEnvironment" select="$string" />
				<xsl:call-template name="makeEnvironmentGroup">
					<xsl:with-param name="targetEnvironment" select="$targetEnvironment" />
				</xsl:call-template>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template name="makeProject">
		<xsl:param name="targetEnvironment" />
		<Project description="" overwrite="true" type="Repository">
			<xsl:attribute name="name"><xsl:value-of select="$projectName"/>_<xsl:value-of select="$targetEnvironment"/></xsl:attribute>

			<ProjectProperties>
				<Property name="projectLocking">false</Property>
				<Property name="concurrentDeployment">false</Property>
				<Property name="ignoreMissingDependencies">true</Property>
				<Property name="isTransactionalDeployment">true</Property>
			</ProjectProperties>

			<DeploymentSet autoResolve="ignore" description="" name="isDeploymentSet">
				<xsl:attribute name="srcAlias"><xsl:value-of select="$repoName"/></xsl:attribute>
				<Composite displayName="" name="*" type="IS">
					<xsl:attribute name="srcAlias"><xsl:value-of select="$repoName"/></xsl:attribute>
				</Composite>
			</DeploymentSet>
			<xsl:if test="$buildAPI = 'true'">
			<DeploymentSet autoResolve="ignore" description="" name="apiDeploymentSet">
				<xsl:attribute name="srcAlias"><xsl:value-of select="$repoName"/></xsl:attribute>
				<Composite displayName="" name="*" type="APIGateway">
					<xsl:attribute name="srcAlias"><xsl:value-of select="$repoName"/></xsl:attribute>
				</Composite>
			</DeploymentSet>
			</xsl:if>

			<xsl:for-each select="$environment/TargetGroup[@env=$targetEnvironment]">
				<xsl:variable name="tempEnv" select="concat($targetEnvironment, '_DeploymentMap')"/>
				<DeploymentMap name="{$tempEnv}" description=""/>
				<MapSetMapping mapName="{$tempEnv}" setName="isDeploymentSet">
					<group type="IS"><xsl:value-of select="@name"/></group>
				</MapSetMapping>

				<xsl:if test="$buildAPI = 'true'">
				<xsl:for-each select="$environment/APIGateway[@env=$targetEnvironment]/apigatewayalias">
					<MapSetMapping mapName="{$tempEnv}" setName="apiDeploymentSet">
						<alias type="APIGateway"><xsl:value-of select="@name"/></alias>
					</MapSetMapping>
				</xsl:for-each>
				</xsl:if>
			</xsl:for-each>

			<DeploymentCandidate description="" mapName="{$targetEnvironment}_DeploymentMap" name="{$targetEnvironment}_Deployment"/>

		</Project>
	</xsl:template>
	<xsl:template name="makeEnvironmentIS">
		<xsl:param name="targetEnvironment" />
		<xsl:for-each select="$environment/IS[@env=$targetEnvironment]/isalias">
			<isalias name="{@name}">
				<host><xsl:value-of select="host"/></host>
				<port><xsl:value-of select="port"/></port>
				<user><xsl:value-of select="user"/></user>
				<xsl:if test="pwd"><pwd><xsl:value-of select="pwd"/></pwd></xsl:if>
				<xsl:if test="pwdHandle"><pwdHandle><xsl:value-of select="pwdHandle"/></pwdHandle></xsl:if>
				<useSSL><xsl:value-of select="useSSL"/></useSSL>
				<xsl:if test="version"><version><xsl:value-of select="version"/></version></xsl:if>
				<installDeployerResource>false</installDeployerResource>
				<xsl:if test="not(Test)"><Test>true</Test></xsl:if>
				<xsl:if test="not(executeACL)"><executeACL>Internal</executeACL></xsl:if>
			</isalias>
		</xsl:for-each>
	</xsl:template>
	<xsl:template name="makeEnvironmentAPI">
		<xsl:param name="targetEnvironment" />
		<xsl:for-each select="$environment/APIGateway[@env=$targetEnvironment]/apigatewayalias">
			<apigatewayalias name="{@name}">
				<host><xsl:value-of select="host"/></host>
				<port><xsl:value-of select="port"/></port>
				<user><xsl:value-of select="user"/></user>
				<xsl:if test="pwd"><pwd><xsl:value-of select="pwd"/></pwd></xsl:if>
				<xsl:if test="pwdHandle"><pwdHandle><xsl:value-of select="pwdHandle"/></pwdHandle></xsl:if>
				<useSSL><xsl:value-of select="useSSL"/></useSSL>
				<xsl:if test="version"><version><xsl:value-of select="version"/></version></xsl:if>
				<xsl:if test="not(Test)"><Test>true</Test></xsl:if>
			</apigatewayalias>
		</xsl:for-each>
	</xsl:template>
	<xsl:template name="makeEnvironmentGroup">
		<xsl:param name="targetEnvironment" />
		<xsl:for-each select="$environment/TargetGroup[@env=$targetEnvironment]">
			<TargetGroup>
				<xsl:attribute name="description"><xsl:value-of select="@description"/></xsl:attribute>
				<xsl:attribute name="name"><xsl:value-of select="@name"/></xsl:attribute>
				<xsl:attribute name="type"><xsl:value-of select="@type"/></xsl:attribute>
				<xsl:if test="@version">
				<xsl:attribute name="version"><xsl:value-of select="@version"/></xsl:attribute>
				</xsl:if>
				<xsl:attribute name="isLogicalCluster"><xsl:value-of select="@isLogicalCluster"/></xsl:attribute>
				<xsl:apply-templates select="$environment/TargetGroup[@env=$targetEnvironment]/alias"/>
				<xsl:apply-templates select="$environment/TargetGroup[@env=$targetEnvironment]/cluster"/>
			</TargetGroup>
		</xsl:for-each>
	</xsl:template>

</xsl:stylesheet>
