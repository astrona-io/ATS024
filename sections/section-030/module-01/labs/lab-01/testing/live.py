hpa=get('horizontalpodautoscaler','probe')
assert hpa.get('status',{}).get('currentMetrics'), 'Wait for real autoscaling measurements'
assert any(c['type']=='ScalingActive' and c['status']=='True' for c in hpa['status'].get('conditions',[])), 'The controller must be able to scale'
assert 2<=get('deployment','probe')['spec']['replicas']<=4, 'Keep replica bounds'
