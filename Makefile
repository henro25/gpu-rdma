CC = gcc
CFLAGS = -O2 -Ofast -ffast-math -funroll-loops -march=native
LDFLAGS = -pthread
LIBS = -libverbs -lrdmacm

# Directories
SRC_DIR = src
BIN_DIR = bin

# Ensure bin directory exists
$(shell mkdir -p $(BIN_DIR))

# Source files
COMMON_SRC = $(SRC_DIR)/rdma_common.c
SERVER_SRC = $(SRC_DIR)/rdma_server.c
CLIENT_SRC = $(SRC_DIR)/rdma_client.c

# Targets
all: $(BIN_DIR)/rdma_server $(BIN_DIR)/rdma_client

$(BIN_DIR)/rdma_server: $(COMMON_SRC) $(SERVER_SRC)
	$(CC) $(CFLAGS) $^ -o $@ $(LDFLAGS) $(LIBS)

$(BIN_DIR)/rdma_client: $(COMMON_SRC) $(CLIENT_SRC)
	$(CC) $(CFLAGS) $^ -o $@ $(LDFLAGS) $(LIBS)

clean:
	rm -f $(BIN_DIR)/rdma_server $(BIN_DIR)/rdma_client

.PHONY: all clean
