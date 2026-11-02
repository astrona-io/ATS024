worker=get('node','astro-ats-024-lab-050-01-02-worker',namespace='')
assert any(t.get('key')=='training.astrona.io/dedicated' and t.get('value')=='report' and t.get('effect')=='NoSchedule' for t in worker['spec'].get('taints',[])), 'Preserve the dedicated taint'
assert get('pod','taint-reader')['spec']['nodeName']=='astro-ats-024-lab-050-01-02-worker', 'Schedule on the eligible worker'
