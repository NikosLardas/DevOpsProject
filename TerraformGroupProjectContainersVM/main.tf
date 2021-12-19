terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=2.46.0"
    }
  }
}

provider "azurerm" {
  features {}
}

#Resource Group
resource "azurerm_resource_group" "main" {
  name     = "devops-group-project-application"
  location = "North Europe"
}

#Virtual Network
resource "azurerm_virtual_network" "main" {
  name                = "virtual-network-devops-application"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  address_space       = ["10.0.0.0/16"]
}

#Subnet
resource "azurerm_subnet" "main" {
  name                 = "subnet-devops-application"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.1.0/24"]
}

#Public IP
resource "azurerm_public_ip" "main" {
  name                    = "devops-public-ip-application"
  location                = azurerm_resource_group.main.location
  resource_group_name     = azurerm_resource_group.main.name
  allocation_method       = "Static"
}

#Security Group
resource "azurerm_network_security_group" "main" {
  name                = "security-group-devops-application"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  security_rule {
    name                       = "Devops Main Security Rule"
    priority                   = 200
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "TCP"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

#Virtual Machine
resource "azurerm_virtual_machine" "main" {
  name                  = "devops-virtual-machine-application"
  location              = azurerm_resource_group.main.location
  resource_group_name   = azurerm_resource_group.main.name
  network_interface_ids = [azurerm_network_interface.main.id]
  vm_size               = "Standard_DS1_v2"

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }

  storage_os_disk {
    name              = "myosdisk1"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    computer_name  = "DevOps Group Project PC 2"
    admin_username = "DevOpsApplicationVM"
    admin_password = "GroupProject21ApplicationVm"
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }
}

#Network Interface
resource "azurerm_network_interface" "main" {
  name                = "devops-network-interface-application"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.main.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id = azurerm_public_ip.main.id
  }
}

#Service plan
resource "azurerm_app_service_plan" "main" {
  name                = "devops-service-plan-application"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  kind = "Linux"
  reserved = "true"

  sku {
    tier = "Basic"
    size = "F1"
  }
}

#Application Service
resource "azurerm_app_service" "main" {
  name                = "devops-group-project-application-service-application-vm-elpida"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  app_service_plan_id = azurerm_app_service_plan.main.id
   
  site_config {
    java_version           = "11"
    java_container         = "JAVA"
    java_container_version = "11"
	use_32_bit_worker_process = "true"
  } 
}

output "public_ip_address" {
  value = azurerm_public_ip.main.ip_address
  description = "Our VM public IP"
}