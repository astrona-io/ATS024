for ordinal, image in ((0,'docker.io/library/busybox:1.36.1'),(1,'docker.io/library/busybox:1.36.1'),(2,'docker.io/library/busybox:1.37.0'),(3,'docker.io/library/busybox:1.37.0')):
    pod=get('pod',f'crew-{ordinal}')
    assert pod['spec']['containers'][0]['image']==image, f'crew-{ordinal} runs the wrong image'
    assert any(c['type']=='Ready' and c['status']=='True' for c in pod['status'].get('conditions',[])), f'crew-{ordinal} must be ready'
status=get('statefulset','crew')['status']
assert status.get('readyReplicas')==4 and status.get('updatedReplicas')==2, 'Only two Pods may run the new revision'
