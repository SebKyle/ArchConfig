import socket
import time

HOST, PORT = "192.168.0.0", 9999

# Cardinal directions and their reverse for backtracking
DIRECTIONS = {
    'N': 'S',
    'S': 'N',
    'E': 'W',
    'W': 'E'
}

def send_command(sock, command):
    """Sends a direction command and receives the response."""
    sock.sendall(bytes(command, "utf-8"))
    sock.sendall(b"\n")
    response = sock.recv(1024).decode("utf-8").strip()
    return response

def solve_maze(sock):
    visited = set()
    path = []

    def dfs(position_key):
        if position_key in visited:
            return False

        visited.add(position_key)

        # Ask for available directions
        response = send_command(sock, "")
        print("At:", position_key, "| Response:", response)

        if "exit" in response.lower() or "escaped" in response.lower():
            print("🎉 Maze solved!")
            return True

        for direction in DIRECTIONS:
            if direction in response:
                # Try moving in that direction
                move_response = send_command(sock, direction)
                path.append(direction)
                print(f"Moved {direction}, server says: {move_response}")

                # Recursive DFS
                if dfs(position_key + direction):
                    return True

                # Backtrack
                back = DIRECTIONS[direction]
                send_command(sock, back)
                path.pop()
                print(f"Backtracked {back}")

        return False

    dfs("")
    print("Final Path:", path)

# Connect to server
with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as sock:
    sock.connect((HOST, PORT))
    solve_maze(sock)
