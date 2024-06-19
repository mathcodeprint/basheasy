import subprocess
import os
import getpass

def run_command(command):
    result = subprocess.run(command, shell=True, capture_output=True, text=True)
    if result.returncode != 0:
        print(f"Error: {result.stderr.strip()}")
        exit(1)
    return result.stdout.strip()

def generate_ssh_key(email, key_path):
    if not os.path.exists(key_path):
        command = f'ssh-keygen -t rsa -b 4096 -C "{email}" -f {key_path}'
        print(f"Generating SSH key with email: {email}")
        run_command(command)
    else:
        print(f"SSH key already exists at {key_path}")

def copy_ssh_key_to_remote(username, remote_host, key_path):
    command = f'ssh-copy-id -i {key_path}.pub {username}@{remote_host}'
    print(f"Copying SSH key to {username}@{remote_host}")
    run_command(command)

def main():
    email = input("Enter your email for the SSH key: ")
    key_path = input("Enter the path to save the SSH key (default: ~/.ssh/id_rsa): ") or "~/.ssh/id_rsa"
    key_path = os.path.expanduser(key_path)
    
    generate_ssh_key(email, key_path)
    
    username = input("Enter your remote username: ")
    remote_host = input("Enter your remote host (IP address or domain): ")
    
    copy_ssh_key_to_remote(username, remote_host, key_path)
    
    print(f"Attempting to log in to {username}@{remote_host} using the SSH key.")
    try:
        subprocess.run(f'ssh -i {key_path} {username}@{remote_host}', shell=True)
    except KeyboardInterrupt:
        print("\nSSH login attempt interrupted.")

if __name__ == "__main__":
    main()
