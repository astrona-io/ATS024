d=get('deployment','probe')
assert int(d['metadata']['annotations']['deployment.kubernetes.io/revision'])>=4, 'Roll back first, then ship the new version as a separate revision'
assert d['metadata']['annotations'].get('kubernetes.io/change-cause','').strip(), 'Record a change cause for the release'
assert not d['spec'].get('paused'), 'The Deployment must not be paused'
