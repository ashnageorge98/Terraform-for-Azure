# Define provider
provider "azurerm" {
  features {}
}

# Resource group
resource "azurerm_resource_group" "rg" {
  name     = "example-resource-group"
  location = "East US"
}

# App Service Plan
resource "azurerm_service_plan" "app_service_plan" {
  name                = "example-app-service-plan"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  sku {
    tier = "Standard"
    size = "S1"
  }
  os_type = "Windows" # Change to "Linux" for Linux-based App Services
}

# App Service
resource "azurerm_windows_web_app" "app_service" {
  name                = "example-app-service"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  service_plan_id     = azurerm_service_plan.app_service_plan.id

  site_config {
    dotnet_framework_version = "v6.0" # Optional for Windows Apps
    scm_type                 = "LocalGit"
    always_on                = true
    app_command_line         = "" # Specify if needed (for Linux apps)
    ftps_state               = "AllAllowed"

    cors {
      allowed_origins = ["https://example.com"]
    }
  }

  app_settings = {
    "APPINSIGHTS_INSTRUMENTATIONKEY" = "your-app-insights-key"
    "APP_SECRET_KEY"                 = "your-secret-key"
  }

  connection_string {
    name  = "MyDBConnection"
    type  = "SQLAzure"
    value = "Server=tcp:mydb.database.windows.net,1433;Database=mydb;User ID=myuser;Password=mypassword;Encrypt=true;Connection Timeout=30;"
  }

  https_only = true
}

# Custom domain binding (Optional)
resource "azurerm_app_service_custom_hostname_binding" "custom_domain" {
  hostname            = "www.example.com"
  app_service_name    = azurerm_windows_web_app.app_service.name
  resource_group_name = azurerm_resource_group.rg.name
}

# SSL Binding for the custom domain (Optional)
resource "azurerm_app_service_certificate_binding" "ssl_binding" {
  hostname_binding_id = azurerm_app_service_custom_hostname_binding.custom_domain.id
  certificate_id      = azurerm_app_service_certificate.certificate.id
  ssl_state           = "SniEnabled"
}

# Autoscale settings (Optional)
resource "azurerm_monitor_autoscale_setting" "autoscale" {
  name                = "example-autoscale"
  resource_group_name = azurerm_resource_group.rg.name
  target_resource_id  = azurerm_service_plan.app_service_plan.id

  profile {
    name = "defaultProfile"
    capacity {
      minimum = 1
      maximum = 5
      default = 1
    }

    rule {
      metric_trigger {
        metric_name        = "CpuPercentage"
        metric_resource_id = azurerm_service_plan.app_service_plan.id
        operator           = "GreaterThan"
        statistic          = "Average"
        threshold          = 70
        time_aggregation   = "Average"
        cooldown           = "PT5M"
      }

      scale_action {
        direction = "Increase"
        type      = "ChangeCount"
        value     = "1"
        cooldown  = "PT5M"
      }
    }

    rule {
      metric_trigger {
        metric_name        = "CpuPercentage"
        metric_resource_id = azurerm_service_plan.app_service_plan.id
        operator           = "LessThan"
        statistic          = "Average"
        threshold          = 30
        time_aggregation   = "Average"
        cooldown           = "PT5M"
      }

      scale_action {
        direction = "Decrease"
        type      = "ChangeCount"
        value     = "1"
        cooldown  = "PT5M"
      }
    }
  }
}

# App Service Certificate (Optional)
resource "azurerm_app_service_certificate" "certificate" {
  name                = "example-certificate"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  pfx_blob            = filebase64("path-to-your-certificate.pfx")
  password            = "certificate-password"
}

# Application Insights (Optional)
resource "azurerm_application_insights" "app_insights" {
  name                = "example-app-insights"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  application_type    = "web"
}
