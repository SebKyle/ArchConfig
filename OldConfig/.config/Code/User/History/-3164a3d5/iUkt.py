import socket
import time

HOST, PORT = "192.168.1.1", 9999

# Cardinal directions and their reverse for backtracking
DIRECTIONS = {
    'N': (0, -1),
    'S': (0, 1),
    'E': (1, 0),
    'W': (-1, 0)
}
REVERSE = {
    'N': 'S',
    'S': 'N',
    'E': 'W',
    'W': 'E'
}

def send_command(sock, command):
    """Sends a direction command and receives the response."""
    if command:
        sock.sendall(bytes(command, "utf-8"))
        sock.sendall(b"\n")
    response = sock.recv(1024).decode("utf-8").strip()
    time.sleep(5)
    return response

def solve_maze(sock):
    visited = set()
    path = []
    graph = {}
    position = (0, 0)  # Start at origin

    def dfs(pos):
        if pos in visited:
            return False

        visited.add(pos)
        response = send_command(sock, "")
        print("At:", pos, "| Response:", response)

        if "exit" in response.lower() or "escaped" in response.lower():
            print("🎉 Maze solved!")
            return True

        # Record neighbors
        graph[pos] = {}

        for dir_char, (dx, dy) in DIRECTIONS.items():
            if dir_char in response:
                next_pos = (pos[0] + dx, pos[1] + dy)
                if next_pos not in visited:
                    move_response = send_command(sock, dir_char)
                    print(f"Moved {dir_char}, server says: {move_response}")

                    path.append((pos, dir_char))  # From pos, moved dir_char
                    graph[pos][dir_char] = next_pos

                    if dfs(next_pos):
                        return True

                    # Backtrack
                    send_command(sock, REVERSE[dir_char])
                    print(f"Backtracked {REVERSE[dir_char]}")
                    path.pop()

        return False

    dfs(position)
    print("\n✅ Final Path to Exit:")
    for step in path:
        print(f"{step[0]} -> {step[1]}")

    print_maze(graph, path)

def print_maze(graph, path):
    """Simple ASCII map of the maze based on visited graph and path."""
    all_positions = graph.keys()
    xs = [x for x, y in all_positions]
    ys = [y for x, y in all_positions]

    min_x, max_x = min(xs), max(xs)
    min_y, max_y = min(ys), max(ys)

    path_positions = set([pos for pos, _ in path])

    print("\n🗺️  Maze Map:")
    for y in range(min_y, max_y + 1):
        line = ""
        for x in range(min_x, max_x + 1):
            if (x, y) == (0, 0):
                line += "S"  # Start
            elif (x, y) in path_positions:
                line += "*"
            elif (x, y) in graph:
                line += "."
            else:
                line += "#"
        print(line)

# Connect to server
with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as sock:
    sock.connect((HOST, PORT))
    solve_maze(sock)
