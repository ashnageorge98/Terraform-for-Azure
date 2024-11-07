







#Notes:
Load Balancing Rule (Port 80): Distributes HTTP (web) traffic across multiple backend instances.
Setting backend_port = 80 means that the Load Balancer will forward incoming traffic on frontend_port = 80 to the backend VMs on port 80 as well.
Purpose: This rule is used for distributing incoming HTTP requests across multiple backend instances (e.g., web servers running on port 80).

NAT Rule (Port 22): Allows SSH access to individual backend VMs, usually for administrative purposes.
Setting backend_port = 22 means the Load Balancer will forward incoming SSH requests on frontend_port = 22 to backend VMs on port 22 as well.
Purpose: This rule allows external users to SSH into the backend VMs, typically for administrative access.
