import socket 
import sys

HOST, PORT = "192.168.1.1", 9999
data = " ".join(sys.argv[1:])

with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as sock: 
    sock.connect((HOST, PORT))
    sock.sendall(bytes(data, "utf-8"))
    sock.sendall(b"\n")

    received = str(sock.recv(1024), "utf-8")

print("Sent:    ", data)
print("Received:", received)