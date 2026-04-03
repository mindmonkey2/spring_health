import sys

def read_chunks(filepath):
    with open(filepath, 'r') as f:
        content = f.read()

    chunk_size = 2000
    for i in range(0, len(content), chunk_size):
        print(f"--- CHUNK {i//chunk_size} ---")
        print(content[i:i+chunk_size])

if __name__ == "__main__":
    read_chunks(sys.argv[1])
