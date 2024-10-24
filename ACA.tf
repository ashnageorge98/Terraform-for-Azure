# Configure the Azure provider
provider "azurerm" {
  features {}
  subscription_id = "your_subscription_id"
}

# Create a resource group
resource "azurerm_resource_group" "example" {
  name     = "rg-container-apps"
  location = "East US"
}

# Create an Azure Container Apps Environment
resource "azurerm_container_app_environment" "example" {
  name                = "container-app-env"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
}

# Create a Log Analytics Workspace for monitoring
resource "azurerm_log_analytics_workspace" "example" {
  name                = "log-analytics-workspace"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

# Create the Container App with scaling and ingress enabled
resource "azurerm_container_app" "example" {
  name                    = "my-container-app"
  location                = azurerm_resource_group.example.location
  resource_group_name      = azurerm_resource_group.example.name
  container_app_environment_id = azurerm_container_app_environment.example.id
  logs {
    log_analytics {
      workspace_id = azurerm_log_analytics_workspace.example.id
    }
  }

  # Ingress settings for public exposure
  ingress {
    target_port = 80
    external_enabled = true
  }

  # Configuration for the containers inside the app
  container {
    name   = "myapp-container"
    image  = "nginx:latest"  # Example: You can replace this with your actual image.
    cpu    = 0.5
    memory = "1.0Gi"

    # Environment variables passed to the container
    env {
      name  = "ENVIRONMENT"
      value = "dev"
    }

    # Health probes (optional)
    probes {
      type             = "liveness"
      http_get {
        path   = "/"
        port   = 80
      }
      initial_delay_seconds = 10
    }
  }

  # Scale rules (optional)
  dapr {
    app_id = "myapp"
    enable = true
  }
}

Real-time Project in DevOps Context
Scenario: CI/CD for Microservices on Azure
In a real-world DevOps project, you may be building a microservices-based architecture with multiple container apps that communicate with each other. Here's how this Terraform code fits into a typical CI/CD (Continuous Integration and Continuous Deployment) pipeline:

Infrastructure as Code (IaC):

Terraform allows you to define infrastructure using code, meaning that your infrastructure becomes reproducible and version-controlled. In this project, each team could spin up identical environments (dev, staging, production) simply by running the same Terraform code.
GitOps Workflow:

This Terraform code can be stored in a Git repository. Any changes to the infrastructure (e.g., adding a new container app) would go through pull requests, code reviews, and automated CI/CD pipelines to ensure proper deployment.
Pipeline Automation:

Once the Terraform code is committed, CI/CD tools like Azure DevOps, GitHub Actions, or Jenkins can run Terraform commands (terraform plan, terraform apply) to automatically provision and update the infrastructure.
This process is automated for each environment (development, staging, production) based on branches or triggers (e.g., dev branch deploys to the dev environment).
Scalability and Monitoring:

The container app in this code includes basic autoscaling and logging mechanisms. In a production-grade environment, the infrastructure might auto-scale based on traffic, and logs can be monitored via Azure Monitor (Log Analytics Workspace).
Microservices and Dapr:

In a real microservices architecture, each container app would typically have its own API or microservice. Dapr could be used for service-to-service communication, state management, and more. This allows your microservices to be decoupled yet orchestrated effectively.
Conclusion
This Terraform configuration is a starting point for deploying and managing Azure Container Apps in a DevOps context. By integrating it into your CI/CD pipelines, you can automate the deployment and scaling of your containerized microservices, ensuring consistency across environments like dev, staging, and production.
