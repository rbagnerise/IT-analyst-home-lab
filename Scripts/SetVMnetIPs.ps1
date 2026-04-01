netsh interface ip set address name="VMware Network Adapter VMnet19" static 10.10.30.2 255.255.255.0
netsh interface ip set address name="VMware Network Adapter VMnet10" static 10.10.10.2 255.255.255.0
Set-NetIPInterface -InterfaceAlias "VMware Network Adapter VMnet19" -AddressFamily IPv4 -Forwarding Enabled
