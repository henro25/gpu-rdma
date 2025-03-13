This file walks through the code in the `rdma-examples` repository.

In general `bzero` should be used to initialize the memory of a structure that is later used in an RDMA operation.

# Understanding the code

## Usage

```c
make
./bin/rdma_server [-a <address/hostname>] [-p <port>] // If does not provide `-a`, then it will listen on all interfaces (connect to any client). If does not provide `-p`, default to `DEFAULT_RDMA_PORT` (20886)
./bin/rdma_client -a <server_address> -s <textstring>
```

## Entire Workflow 

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

Client: Disconnect and cleanup (C.6)

Server: Disconnect and cleanup (S.6)

## Function Calls in rdma_server.c

1. `start_rdma_server(&server_sockaddr)`
2. `setup_client_resources()`
3. `accept_client_connection()`
4. `send_server_metadata_to_client()`
5. `disconnect_and_cleanup()`

## Function Calls in rdma_client.c

Receives server_sockaddr from input `

1. `start_rdma_server(&server_sockaddr)`
2. `setup_client_resources()`
3. `accept_client_connection()`
4. `send_server_metadata_to_client()`
5. `disconnect_and_cleanup()`


```c
/* Pre-posts a receive buffer before calling rdma_connect () 
The receive buffer is where the data will be written to */
static int client_pre_post_recv_buffer()
```
```c
struct ibv_mr *rdma_buffer_register(struct ibv_pd *pd, 
        void *addr, uint32_t length, 
        enum ibv_access_flags permission)
```c

Calls

```c
/*Under the hood calls ibv_reg_mr/ibv_reg_mr_iova2 depending on ibv_access_flags. Note that iova uses IO virtual address, whilst the other just takes the va as identity*/

struct ibv_mr *rdma_buffer_register(struct ibv_pd *pd, 
        void *addr, uint32_t length, 
        enum ibv_access_flags permission)
```

RDMA_Server:

static int start_rdma_server(struct sockaddr_in *server_addr)
/* Starts an RDMA server by allocating basic connection resources 
 * Uses PS_TCP for the Port
 * The purpose of this function is to create a connection identifier (cm_server_id) and bind it to the server address.
 * It then listens for a client connection.
 * When a client connects, it generates a RDMA_CM_EVENT_CONNECT_REQUEST event on the RDMA CM event channel.
 * This function then processes this event to get the client connection identifier (cm_client_id).
 * It then acknowledges the event and returns the client connection identifier.
 */

static int setup_client_resources()
 /* When we call this function cm_client_id must be set to a valid identifier.
 * This is where, we prepare client connection before we accept it. This 
 * mainly involve pre-posting a receive buffer to receive client side 
 * RDMA credentials
 * Allocates 1. Protection Domain (PD) via `ibv_alloc_pd`
 * 2. Completion Channel via `ibv_create_comp_channel`c
 * 3. Completion Queue (CQ) via `ibv_create_cq`
 * 4. Queue Pair (QP) via `rdma_create_qp`
 * The purpose of each resource should be clear from the comments below.
 */

 	/* 1. Protection Domain (PD):
	 * Protection Domain (PD) is similar to a "process abstraction" 
	 * in the operating system. All resources are tied to a particular PD. 
	 * And accessing recourses across PD will result in a protection fault.
	 */

   	/* 2. Completion Channel:
	 * Now we need a completion channel, were the I/O completion 
	 * notifications are sent. Remember, this is different from connection 
	 * management (CM) event notifications. 
	 * A completion channel is also tied to an RDMA device, hence we will 
	 * use cm_client_id->verbs. 
	 */