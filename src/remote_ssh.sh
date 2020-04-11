# For execution on client device
# create .ssh directory for key storage
mkdir -p $HOME/.ssh
chmod 0700 $HOME/.ssh

# generate default RSA key pair
ssh-keygen

# Server connection details
echo Server name:
read user_name
echo Server IP
read server_ip

# Server SSH Key install
# Simply install the public key on the server device from the client machine.

ssh-copy-id $user_name@$server_ip

# Run Remote Connection
# Login to Ubuntu 18.04 LTS server with `ssh` from client using ssh keys
ssh $user_name@$server_ip