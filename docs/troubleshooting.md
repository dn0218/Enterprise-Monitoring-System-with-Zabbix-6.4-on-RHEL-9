**Step-by-Step Debugging:**

Connectivity Check: Used zabbix_get from the server:

Error: Connection refused (111)

Service Verification: Checked status on Agent node:

Finding: zabbix-agent2.service was inactive.

Resolution: Started the service and enabled it on boot.

Result: Icon turned Green and metrics began flowing.
