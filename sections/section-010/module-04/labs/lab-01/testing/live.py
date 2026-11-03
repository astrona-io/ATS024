result=command(['kubectl','-n','outpost','get','deployment','beacon'],success=False)
assert result.returncode!=0, 'The unprefixed base Deployment must not exist'
