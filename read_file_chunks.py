import sys

def read_in_chunks(file_path, chunk_size=2000):
    try:
        with open(file_path, 'r') as f:
            content = f.read()
            for i in range(0, len(content), chunk_size):
                print(f"--- Chunk {i//chunk_size + 1} ---")
                print(content[i:i+chunk_size])
    except FileNotFoundError:
        print(f"File not found: {file_path}")

if __name__ == "__main__":
    if len(sys.argv) > 1:
        read_in_chunks(sys.argv[1])
    else:
        print("Please provide a file path.")
