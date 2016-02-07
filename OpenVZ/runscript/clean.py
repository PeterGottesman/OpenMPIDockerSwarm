#!/usr/bin/env python3

import threading
from subprocess import check_output, call
from queue import Queue

q = Queue()

def worker():
    while True:
        hostname = q.get()
        ids = check_output("pdsh -Nw " + hostname + " sudo vzlist -Ho ctid", shell=True).decode('utf-8').strip(' ').split('\n')
        ids = [id.strip(' ') for id in ids if id is not '']
        for id in ids:
            call("pdsh -Nw " + hostname + " sudo vzctl --quiet stop " + id, shell=True)
        ids = check_output("pdsh -Nw " + hostname + " sudo vzlist -SHo ctid", shell=True).decode('utf-8').strip(' ').split('\n')
        ids = [id.strip(' ') for id in ids if id is not '']
        for id in ids:
            call("pdsh -Nw " + hostname + " sudo vzctl --quiet destroy " + id, shell=True)
        print(hostname)
        q.task_done()


def main():
    with open('hosts.txt', 'r') as f:
        for hostname in f.readline().rstrip('\n').split(','):
            t = threading.Thread(target=worker)
            t.daemon = True
            t.start()

            q.put(hostname)

        q.join()

if __name__ == "__main__":
    main()
