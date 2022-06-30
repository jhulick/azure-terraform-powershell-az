FROM mcr.microsoft.com/powershell:ubuntu-18.04

ARG REPOSITORY=PSGallery
ARG MODULE=Az
ARG CONFIG=config
ARG AZURERM_CONTEXT_SETTINGS=AzureRmContextSettings.json
ARG AZURE=/root/.Azure
ARG VCS_REF="none"
ARG BUILD_DATE=
ARG VERSION=
ARG LATEST=
ARG BLOB_URL=
ARG IMAGE_NAME=mcr.microsoft.com/azure-powershell:${VERSION}-ubuntu-18.04
ARG TERRAFORM_VERSION=1.1.3

ENV AZUREPS_HOST_ENVIRONMENT="dockerImage/${VERSION}-ubuntu-18.04"

LABEL maintainer="Azure PowerShell Team <azdevxps@microsoft.com>" \
      readme.md="http://aka.ms/azpsdockerreadme" \
      description="This Dockerfile will install the latest release of Azure PowerShell." \
      org.label-schema.build-date=${BUILD_DATE} \
      org.label-schema.usage="http://aka.ms/azpsdocker" \
      org.label-schema.url="http://aka.ms/azpsdockerreadme" \
      org.label-schema.vcs-url="https://github.com/Azure/azure-powershell" \
      org.label-schema.name="azure powershell" \
      org.label-schema.vendor="Azure PowerShell" \
      org.label-schema.version=${VERSION} \
      org.label-schema.schema-version="1.0" \
      org.label-schema.vcs-ref=${VCS_REF} \
      org.label-schema.docker.cmd="docker run --rm ${IMAGE_NAME} pwsh -c '\$PSVERSIONTABLE'" \
      org.label-schema.docker.cmd.devel="docker run -it --rm -e 'DebugPreference=Continue' ${IMAGE_NAME} pwsh" \
      org.label-schema.docker.cmd.test="currently not available" \
      org.label-schema.docker.cmd.help="docker run --rm ${IMAGE_NAME} pwsh -c Get-Help"

# Update the package repository and install wget and libraries
# That are required for powershell
RUN apt-get update && \
    apt-get install -y curl \
        unzip \
        software-properties-common \
        apt-transport-https \
        ca-certificates \
        git
     
# Install Terraform
RUN curl -L "https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip" -o /tmp/terraform.zip && \
    unzip /tmp/terraform.zip -d /usr/local/bin && \
    rm /tmp/terraform.zip

# Install AZ CLI
RUN curl -sL https://aka.ms/InstallAzureCLIDeb | bash

# Install the PowerShell AZ module
#RUN pwsh -NoProfile -Command "Install-Module -Name Az -Scope AllUsers -Repository PSGallery -Force"

# Install PowerShell-Yaml for parsing YAML in PowerShell
RUN pwsh -NoProfile -Command "Install-Module -Name Powershell-Yaml -Scope AllUsers -Repository PSGallery -Force"
 
RUN pwsh -Command Set-PSRepository -Name ${REPOSITORY} -InstallationPolicy Trusted && \
    pwsh -Command Install-Module -Name ${MODULE} -Scope AllUsers -Repository ${REPOSITORY} -Force && \
    pwsh -Command Set-PSRepository -Name ${REPOSITORY} -InstallationPolicy Untrusted ;

# create AzureRmContextSettings.json before it was generated
COPY ${CONFIG}/${AZURERM_CONTEXT_SETTINGS} ${AZURE}/${AZURERM_CONTEXT_SETTINGS}

CMD [ "pwsh" ]
