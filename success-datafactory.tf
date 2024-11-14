# main.tf
terraform {                                                                                                                            required_providers {                                                                                                                   azurerm = {                                                                                                                            source  = "hashicorp/azurerm"                                                                                                        version = ">= 2.42"                                                                                                                }
  }
}                                                                                                                                                                                                                                                                         # Configure the Azure provider                                                                                                       provider "azurerm" {
  features {}
  subscription_id = "81b0b41e-5edd-4af2-86ea-1b1457a4374c"
}                                                                                                                                                                                                                                                                         # Define variables for the Azure resources                                                                                           variable "resource_group_name" {                                                                                                       description = "The name of the Resource Group."                                                                                      type        = string                                                                                                                 default     = "RG1"                                                                                                                }                                                                                                                                                                                                                                                                         variable "location" {                                                                                                                  description = "The Azure region to deploy to."                                                                                       type        = string                                                                                                                 default     = "East US"                                                                                                            }                                                                                                                                                                                                                                                                         variable "data_factory_name" {                                                                                                         description = "The name of the Azure Data Factory instance."                                                                         type        = string                                                                                                                 default     = "adf-demo-factory"                 
}

variable "tags" {
  description = "Tags for the resources."
  type        = map(string)
  default     = {
    environment = "development"
    project     = "data-factory-demo"
  }
}

# Fetch the existing resource group
data "azurerm_resource_group" "existing" {
  name = var.resource_group_name
}

# Create an Azure Data Factory instance in the existing resource group
resource "azurerm_data_factory" "data_factory" {
  name                = var.data_factory_name
  location            = data.azurerm_resource_group.existing.location
  resource_group_name = data.azurerm_resource_group.existing.name

  tags = var.tags
}

# Optional: Create an Azure Data Factory Linked Service (Example with Azure Blob Storage)
resource "azurerm_data_factory_linked_service_azure_blob_storage" "example_blob_storage" {
  data_factory_id     = azurerm_data_factory.data_factory.id
  name                = "example-blob-storage"
  connection_string   = "DefaultEndpointsProtocol=https;AccountName=stoaccash1029;AccountKey=yourstoragekey;EndpointSuffix=core.windows.net"
}

# Optional: Define a Dataset (Example for a JSON file in Blob Storage)
resource "azurerm_data_factory_dataset_json" "example_dataset" {
  name                = "example-dataset-json"
  data_factory_id     = azurerm_data_factory.data_factory.id
  linked_service_name = azurerm_data_factory_linked_service_azure_blob_storage.example_blob_storage.name
}

# Define the ARM template for a Data Factory pipeline
data "local_file" "pipeline_template" {
  filename = "${path.module}/pipeline_template.json"  # Reference to the external JSON file
}

# Deploy the Data Factory pipeline using an ARM template
resource "azurerm_resource_group_template_deployment" "data_factory_pipeline" {
  name                = "example-pipeline-deployment"
  resource_group_name = data.azurerm_resource_group.existing.name
  deployment_mode     = "Incremental"

  # Reference the ARM template content from local_file data source
  template_content = data.local_file.pipeline_template.content

  parameters_content = jsonencode ({
    factoryName = azurerm_data_factory.data_factory.name
    pipelineName = "example-pipeline"
    datasetName = azurerm_data_factory_dataset_json.example_dataset.name
  })
}

# Output the Data Factory ID
output "data_factory_id" {
  value = azurerm_data_factory.data_factory.id
}

# Define pipeline_template.json in same directory as u define main.tf and call this file in main.tf
{
  "$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentTemplate.json#",
  "contentVersion": "1.0.0.0",
  "resources": [
    {
      "type": "Microsoft.DataFactory/factories/pipelines",
      "apiVersion": "2018-06-01",
      "name": "[parameters('pipelineName')]",
      "properties": {
        "activities": [
          {
            "name": "CopyBlobToBlob",
            "type": "Copy",
            "inputs": [
              {
                "referenceName": "[parameters('datasetName')]",
                "type": "DatasetReference"
              }
            ],
            "outputs": [
              {
                "referenceName": "[parameters('datasetName')]",
                "type": "DatasetReference"
              }
            ],
            "typeProperties": {
              "source": {
                "type": "BlobSource"
              },
              "sink": {
                "type": "BlobSink"
              }
            }
          }
        ]
      }
    }
  ],
  "parameters": {
    "factoryName": {
      "type": "string"
    },
    "pipelineName": {
      "type": "string"
    },
    "datasetName": {
      "type": "string"
    }
  }
}
