import json,subprocess

def run(*args):
    return subprocess.run(["kubectl",*args],check=True,capture_output=True,text=True,timeout=15).stdout.strip()

def get(kind,name):
    return json.loads(run("-n","starfleet","get",kind,name,"-o","json"))

def can(verb,resource,namespace,identity):
    result=subprocess.run(["kubectl","auth","can-i",verb,resource,"-n",namespace,identity],capture_output=True,text=True,timeout=15)
    assert result.returncode in (0,1) and result.stdout.strip() in ("yes","no"), "Authorization check failed"
    return result.returncode==0 and result.stdout.strip()=="yes"

deployment=get("deployment","probe")
spec=deployment["spec"]; status=deployment.get("status",{})
assert spec["replicas"]==2, "Keep two replicas"
assert status.get("observedGeneration",0)>=deployment["metadata"]["generation"], "Wait for the current generation"
assert all(status.get(field,0)==2 for field in ("replicas","updatedReplicas","readyReplicas","availableReplicas")), "Complete the rollout"
container=spec["template"]["spec"]["containers"][0]
assert container["name"]=="probe" and container["image"]=="docker.io/library/python:3.13-alpine", "Restore the required image"
assert container["command"]==["python","/app/server.py"], "Preserve the application command"
response=run("-n","starfleet","exec","shuttle","--","wget","-q","-T","3","-O-","http://probe/")
assert "version=v1 host=probe-" in response, "Verify the original client request"
# Check declared baseline fields while allowing Kubernetes defaulted fields.
from pathlib import Path
baseline=json.loads((Path(__file__).resolve().parent/"deployment-contract.json").read_text())
def contains(actual,expected):
    if isinstance(expected,dict):
        return isinstance(actual,dict) and all(key in actual and contains(actual[key],value) for key,value in expected.items())
    if isinstance(expected,list):
        return isinstance(actual,list) and len(actual)==len(expected) and all(contains(left,right) for left,right in zip(actual,expected))
    return actual==expected
assert contains(spec,baseline), "Preserve the Deployment contract"
print("Required resource contract and behavior verified")
