# SSH Remote Server on Ubuntu 18.04 LTS

This document provides a fast methodology for setting up a remote Ubuntu 18.04 LTS server using *OpenSSH*. *OpenSSH* is divided between `sshd` for the server device and `ssh` for the client device.

## Client SSH key generation
1. create a .ssh directory for storing keys and set the permissions

```console
$ mkdir -p $HOME/.ssh
$ chmod 0700 $HOME/.ssh
```
2. Generate a default key pair for ssh. Default should be `RSA SHA256`.
```console
$ ssh-keygen
```

## Server SSH Key install
Simply install the public key on the server device from the client machine.
```console
$ ssh-copy-id [user_name]@[server_ip]
```
## Run Remote Connection
Login to Ubuntu 18.04 LTS server with `ssh` from client using ssh keys
```console
$ ssh [user_name]@[server_ip]
```
