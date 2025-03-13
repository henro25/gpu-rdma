# gpu-rdma

A simple RDMA server client example adapted from [RDMA-examples](https://github.com/animeshtrivedi/rdma-example). The comments are adapted from the original code and made more extensive. An additional explanation of the code is provided in the [one_sided_rdma_documentation.md](one_sided_rdma_documentation.md) file.

Client: 
  1. setup RDMA resources   
  2. connect to the server 
  3. receive server side buffer information
  4. perform benchmark loops:
     - For RDMA Write test:
       - Record start time
       - Perform N RDMA writes
       - Record end time
     - For RDMA Read test:
       - Record start time
       - Perform N RDMA reads
       - Record end time
  5. disconnect and cleanup

Server: 
  1. setup RDMA resources (wait for client connection)
  2. accept client connection
  3. allocate and pin server buffer
  4. send buffer information (and wait for disconnect)
  5. disconnect and cleanup

In sequence:

Client & Server: Setup RDMA resources (C.1, S.1-wait for client connection)

Client: Connect to server (C.2)

Server: Accept client connection (S.2)

Server: allocate and pin server buffer (S.3)

Server: Send buffer information (and wait for disconnect) (S.4)

Client: Receive server side buffer information (C.3)

Client: Post receive buffer (C.4)

Client: Perform benchmark loops (C.5)

Client: Disconnect (C.5)

Server: Disconnect (S.5)

###### How to run      
```text
git clone https://github.com/animeshtrivedi/rdma-example.git
cd ./rdma-example
cmake .
make
``` 
 
###### server
```text
./bin/rdma_server
```
###### client
```text
atr@atr:~/gpu-rdma$ ./bin/rdma_client -a 127.0.0.1
=== Testing buffer size: 1048576 bytes ===
Trying to connect to server at : 127.0.0.1 port: 20886 
The client is connected successfully 
---------------------------------------------------------
buffer attr, addr: 0x7fb6eb200000 , len: 1048576 , stag : 0xb1d3 
---------------------------------------------------------
...
Client resource clean up is complete 
atr@atr:~/gpu-rdma$ 
```

## Does not have an RDMA device?
In case you do not have an RDMA device to test the code, you can setup SofitWARP software RDMA device on your Linux machine. Follow instructions here: [https://github.com/animeshtrivedi/blog/blob/master/post/2019-06-26-siw.md](https://github.com/animeshtrivedi/blog/blob/master/post/2019-06-26-siw.md).
