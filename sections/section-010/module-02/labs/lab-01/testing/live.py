d=get('deployment','probe')
assert int(d['metadata']['annotations']['deployment.kubernetes.io/revision'])>=5, 'Roll back with the rollout history instead of recreating the Deployment'
assert not d['spec'].get('paused'), 'The Deployment must not be paused'
assert d['spec'].get('revisionHistoryLimit',10)>=3, 'Keep the revision history'
