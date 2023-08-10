import json
from backend import huey, app
from backend.models import new_log as log, Frame, update_frame
from paramiko import RSAKey, SSHClient, AutoAddPolicy
from io import StringIO
from gevent import sleep
from scp import SCPClient
import atexit
import signal
from huey.signals import SIGNAL_ERROR, SIGNAL_LOCKED

@huey.signal(SIGNAL_LOCKED)
def task_not_run_handler(signal, task, exc=None):
    # Do something in response to the "ERROR" or "LOCEKD" signals.
    # Note that the "ERROR" signal includes a third parameter,
    # which is the unhandled exception that was raised by the task.
    # Since this parameter is not sent with the "LOCKED" signal, we
    # provide a default of ``exc=None``.
    print('SIGNAL_ERROR')
    print(SIGNAL_ERROR)

@huey.signal(SIGNAL_LOCKED)
def task_not_run_handler(signal, task, exc=None):
    print('SIGNAL_LOCKED')
    print(SIGNAL_LOCKED)

ssh_connections = set()
locks = set()

def close_ssh_connection():
    # Assuming 'ssh' is accessible here
    for ssh in ssh_connections:
        ssh.close()
    print("SSH connection closed.")
    for lock in locks:
        pass
        # huey.release_lock(lock)
        # lock.close()

# Registering the close_ssh_connection function to be called on exit
atexit.register(close_ssh_connection)

# You may also catch specific signals to handle them
def handle_signal(signum, frame):
    close_ssh_connection()
    exit(1)

signal.signal(signal.SIGTERM, handle_signal)
signal.signal(signal.SIGINT, handle_signal)

@huey.task()
def reset_frame(id: int):
    with app.app_context():
        frame = Frame.query.get_or_404(id)
        if frame.status != 'uninitialized':
            frame.status = 'uninitialized'
            update_frame(frame)
        
        log(id, "admin", "Resetting frame status to 'uninitialized'")


@huey.task()
def initialize_frame(id: int):
    with app.app_context():
        # with huey.lock_task(f'frame--{id}'):
        locks.add(f'frame--{id}')
        ssh = SSHClient()
        ssh_connections.add(ssh)
        try:
            frame = Frame.query.get_or_404(id)
            if frame.status == 'deploying':
                raise Exception(f"Current frame status '{frame.status}' is not valid for this operation")

            frame.status = 'deploying'
            update_frame(frame)

            frame_json = {
                "api_host": frame.api_host,
                "api_key": frame.api_key,
                "api_port": frame.api_port,
            }

            log(id, "stdinfo", f"Connecting to {frame.ssh_user}@{frame.host}")
            ssh.set_missing_host_key_policy(AutoAddPolicy())

            if frame.ssh_pass:
                ssh.connect(frame.host, username=frame.ssh_user, password=frame.ssh_pass, timeout=10)
            else:
                with open('/Users/marius/.ssh/id_rsa', 'r') as f:
                    ssh_key = f.read()
                ssh_key_obj = RSAKey.from_private_key(StringIO(ssh_key))
                ssh.connect(frame.host, username=frame.ssh_user, pkey=ssh_key_obj, timeout=10)
            
            log(id, "stdinfo", f"Connected to {frame.ssh_user}@{frame.host}")

            def exec_command(command: str) -> int:
                log(id, "stdout", f"> {command}")
                stdin, stdout, stderr = ssh.exec_command(command)
                exit_status = None
                while exit_status is None:
                    while line := stdout.readline():
                        log(id, "stdout", line)
                    while line := stderr.readline():
                        log(id, "stderr", line)
                        
                    # Check if the command has finished running
                    if stdout.channel.exit_status_ready():
                        exit_status = stdout.channel.recv_exit_status()

                    # Sleep to prevent busy-waiting
                    sleep(0.1)

                if exit_status != 0:
                    log(id, "exit_status", f"The command exited with status {exit_status}")
                
                return exit_status
            
            # exec_command("sudo apt update -y")
            exec_command("sudo mkdir -p /srv/frameos")
            exec_command(f"sudo chown -R {frame.ssh_user} /srv/frameos")

            with SCPClient(ssh.get_transport()) as scp:
                log(id, "stdout", "> add /srv/frameos/frame.json")
                scp.putfo(StringIO(json.dumps(frame_json, indent=4) + "\n"), "/srv/frameos/frame.json")
                
                log(id, "stdout", "> add /srv/frameos/frame.py")
                scp.put("./device/frame.py", "/srv/frameos/frame.py")
                
                log(id, "stdout", "> add /srv/frameos/index.html")
                scp.put("./device/index.html", "/srv/frameos/index.html")
                
                log(id, "stdout", "> add /srv/frameos/requirements.txt")
                scp.put("./device/requirements.txt", "/srv/frameos/requirements.txt")

            exec_command("cd /srv/frameos && (sha256sum -c requirements.txt.sha256sum 2>/dev/null || (pip3 install -r requirements.txt && sha256sum requirements.txt > requirements.txt.sha256sum))")

            exec_command("tmux has-session -t frameos 2>/dev/null && tmux kill-session -t frameos")
            exec_command("cd /srv/frameos && tmux new-session -s frameos -d 'python3 frame.py'")

            frame.status = 'initialized'
            update_frame(frame)

        except Exception as e:
            log(id, "stderr", str(e))
            frame.status = 'uninitialized'
            update_frame(frame)
        finally:
            ssh.close()
            ssh_connections.remove(ssh)
            log(id, "stdinfo", "Connection closed")
