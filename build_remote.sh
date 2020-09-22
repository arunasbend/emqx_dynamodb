# Install on remote (change IP to public instance IP)
scp -i ec2-b1.pem emqx-ubuntu20.04-4.2.0-x86_64.deb ubuntu@52.57.255.35:~
ssh -i ec2-b1.pem ubuntu@52.57.255.35
sudo apt install ./emqx-ubuntu20.04-4.2.0-x86_64.deb

# Change to - allow_anonymous = false
sudo nano /etc/emqx/emqx.conf

# Update auth variables
sudo nano /etc/emqx/plugins/emqx_dynamodb.conf

sudo emqx start

# Inspect logs
cat /var/log/emqx/erlang.log.1

# Open url http://{{DomainOfLoadBalancer}}:18083/
# Enable plugins - emqx_dynamodb, emqx_auth_username
# Add users