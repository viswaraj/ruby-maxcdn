Running benchmarks as follows in order:
 
 maxcdn.get('zones/pull.json')
 maxcdn.get('reports/popularfiles.json')
 maxcdn.get('v3/reporting/logs.json')
 maxcdn.post('zones/pull.json', { :name => 'NAM', :url => 'URL' })
 maxcdn.put('account.json', { :name => 'NAME' })
 maxcdn.delete('zones/pull.json/ZONEID')
 maxcdn.purge('ZONEID')
 maxcdn.purge('ZONEID', 'FILE')
 maxcdn.purge('ZONEID', [ 'FILE1','FILE2' ])
 
       user     system      total        real
get   :  0.010000   0.000000   0.010000 (  1.356269)
get   :  0.010000   0.000000   0.010000 (  0.911275)
get   :  0.010000   0.000000   0.010000 (  1.069133)
post  :  0.000000   0.000000   0.000000 (  6.513997)
put   :  0.010000   0.000000   0.010000 (  0.831379)
delete:  0.010000   0.000000   0.010000 (  1.248739)
purge :  0.010000   0.000000   0.010000 (  4.019390)
purge :  0.010000   0.000000   0.010000 (  6.221071)
purge :  0.010000   0.000000   0.010000 (  2.496699)
