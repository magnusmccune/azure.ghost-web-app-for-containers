# azure.ghost-web-app-for-containers

This is a modification of [@andrewmatveychuk](https://github.com/andrewmatveychuk)'s excellent work on automating the deployment of the Ghost blogging platform to Azure App Service Containers using Azure Front Door(or Azure CDN), Azure DB for MySQL and other Azure Services. His original repo is located [here](https://github.com/andrewmatveychuk/azure.ghost-web-app-for-containers).

The primary objective of this fork is to make the IaC work in my environment, which has centralized logging, Front Door, and other preexisting Azure Services. 

I may also find time to create a Azure DevOps workflows for managing updates to both the container file(with Azure Container Registry) and the continuous deployment of the solution.

As a stretch goal, I'd like to find the time to bring back the multi-container setup that Andrew had originally created but later failed on him(documented in his blog post, [here](https://andrewmatveychuk.com/how-to-connect-to-azure-database-for-mysql-from-ghost-container/)) as it is significantly more cost effective.

A one-click [Ghost](https://ghost.org/) deployment on [Azure Web App for Containers](https://azure.microsoft.com/en-us/services/app-service/containers/).

## Deploy

[![Deploy to Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fandrewmatveychuk%2Fazure.ghost-web-app-for-containers%2Fmaster%2Fghost.json)

## Getting Started

This is an Azure Web app deployed as a container . It uses [the custom Ghost Docker image with Azure Application Insights support](https://github.com/andrewmatveychuk/docker-ghost-ai) and [Azure Database for MySQL](https://azure.microsoft.com/en-us/services/mysql/) to store the application data.

The Azure Web app configuration is provided as a ready-to-use ARM template that deploys and configures all requires Azure resources:

* a Web app and App Hosting plan for running the container;
* a Key Vault for storing secrets such as database passwords;
* a Log Analytics workspace and Application Insights component for monitoring the application;
* an Azure Database for MySQL server;
* an [Azure Front Door](https://docs.microsoft.com/en-us/azure/frontdoor/) endpoint with a [WAF policy](https://docs.microsoft.com/en-us/azure/web-application-firewall/afds/afds-overview) _or_ an [Azure CDN](https://docs.microsoft.com/en-us/azure/cdn/) profile and endpoint for offloading the traffic from the Web app depending on the specified input parameter (deploymentConfiguration).

All resources have their diagnostic settings configured to stream resource logs and metrics to the Log Analytics workspace.

For the complete list of settings, please refer to the following blog posts:

* [A one-click Ghost deployment on Azure Web App for Containers](https://andrewmatveychuk.com/a-one-click-ghost-deployment-on-azure-web-app-for-containers/)
* [Ghost deployment on Azure: Security Hardening](https://andrewmatveychuk.com/ghost-deployment-on-azure-security-hardening/)
* [How to connect to Azure Database for MySQL from Ghost container](https://andrewmatveychuk.com/how-to-connect-to-azure-database-for-mysql-from-ghost-container/)
