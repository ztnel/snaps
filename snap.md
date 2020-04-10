# Snap Notes

### What is SSH?

> SSH stands for Secure SHell and is a cryptographic network protocol

SSH is used for accessing remote servers or embedded devices. User name and passord infromation can be stolen while logging into a remote system since symmetrical encryption cannot be done on the remote system. However SSH uses asymmetric encryption to make the loggin process more secure.

> **Symmetrical Encryption Algorithm** uses one function for encryption and decryption and is shared across the client and server. This function must be known by both systems in advance in order to support the encryption process. 

Problem arises when we are trying to access a remote system. How can we send it the encryption function in a way that is not vunerable to interception?

> **Asymmetrical Encryption Algorithm** uses a unique pair of keys called the public key and private key to encrypt and decrypt network packets. The private key is secure to the home device whereas the public key is shared with anyone who wants to communicate with the home device.

Any remote system can communicate with the home device by using its public key to encrypt its network packets as it is sent through the network. The home device will use its private key to decrypt the packet contents on arrival. This works because the private key is secure to the home device and is very hard to guess using computer hashing.

In essence, asymmetric encryption shares the function for encryption publicly but secures the function for decryption to its local device.

### SSH Communication Process
1. Client identifies themselves to the server by sharing its list of public keys
2. Server checks that the clients public key is registered in its database.
3. If present the server encrypts a secret message using the clients public key and sends it to the client.
4. Client then uses its private key to decrypt the contents and sends it back to the server for validation
5. If the pre-encrypted message matches the post decrpytion message the server verifies the client and SSH opens a tunnel between the client and the server from which all hashed / encrypted data is sent


### SSH Clients
- MacOS and Linux: Terminal (SSH built-in)
- Windows: PuTTY
- Android: JuiceSSH
- iOS: prompt

### SSH Caveats
SSH is a service, so its not available until the system establishes an SSH connection. 

### SSH Setup with Ubuntu Core 18

1. On client machine open a bash terminal and generate an RSA key pair
```console
foo@bar:~$ ssh-keygen -t rsa
```

2. Navigate to ~home/users/[username]/.ssh
3. Read file contents:
```console
$ cat id_rsa.pub
```
4. Copy the file contents and import the key into Ubunto SSO account to register the key with your account ID (email address)

5. Boot RPi and configure network settings
6. Enter account ID (email address) for access to imported public keys. If the account has no imported public keys Ubuntu Core will produce an error message claiming the account setup is incomplete.
7. Once configured with your Ubuntu SSO account, Ubuntu Core will provide host key fingerprints and login details in the format shown below:
```console
To login:
    ssh [username]@[ip_address]
    ssh ...
```
8. We are now able to remotely connect to the system using the provided connection specification:
```console
$ ssh [user]@[ip_address]
```
