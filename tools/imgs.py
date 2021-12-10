import json
import os
import subprocess
import sys

def findTag(imgs):
    tags = []
    for i in imgs:
        if i['Repository'] == 'dockerhubaneo/armonik_compute':
            tags.append(i['Tag'])
        elif i['Repository'] == 'dockerhubaneo/armonik_control':
            tags.append(i['Tag'])
        elif i['Repository'] == 'dockerhubaneo/armonik_pollingagent':
            tags.append(i['Tag'])
    if len(tags) > 0:
        return sorted(tags).pop()
    else:
        return 'dev-1000'

def incrTag(tag):
    s = tag.split('-')
    return s[0] + '-' + str(int(s[1]) + 1)

imgs = [json.loads(r) for r in os.popen('docker image ls --format="{{json .}}"').readlines()]

tag = findTag(imgs)
tag = incrTag(tag)
print(tag)

p1 = subprocess.Popen(f'docker build -t dockerhubaneo/armonik_control:{tag} -f src/Control/src/ArmoniK.Control.Service/ArmoniK.Control/Dockerfile .', shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
p2 = subprocess.Popen(f'docker build -t dockerhubaneo/armonik_pollingagent:{tag} -f ./src/Compute/PollingAgent/src/ArmoniK.Compute.PollingAgent/Dockerfile .', shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
p3 = subprocess.Popen(f'docker build -t dockerhubaneo/armonik_compute:{tag} -f ./src/DevelopmentKit/csharp/SymphonyApi/Gridlib/src/ArmoniK.DevelopmentKit.SymphonyApi/Dockerfile .', shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)

print(p1.communicate()[0].decode('utf-8'))
print(p2.communicate()[0].decode('utf-8'))
print(p3.communicate()[0].decode('utf-8'))

if p1.returncode or p2.returncode or p3.returncode:
    print('error while building')
    if p1.returncode:
        print(p1.communicate()[1].decode('utf-8'))
    if p2.returncode:
        print(p2.communicate()[1].decode('utf-8'))
    if p3.returncode:
        print(p3.communicate()[1].decode('utf-8'))
    sys.exit(1)

os.popen(f'sed s/dev-[0-9]*/{tag}/g -i ../../infrastructure/localhost/deploy/parameters.tfvars')

# kubectl logs -n armonik svc/control-plane
# kubectl logs -n armonik deployment/compute-plane-0 -c polling-agent
# kubectl logs -n armonik deployment/compute-plane-0 -c compute-0