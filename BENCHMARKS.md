Running benchmarks as follows in order:
 
 maxcdn.get('zones/pull.json')
 maxcdn.get('reports/popularfiles.json')
 maxcdn.post('zones/pull.json', { :name => 'NAM', :url => 'URL' })
 maxcdn.put('account.json', { :name => 'NAME' })
 maxcdn.delete('zones/pull.json/ZONEID')
 maxcdn.purge('ZONEID')
 maxcdn.purge('ZONEID', 'FILE')
 maxcdn.purge('ZONEID', [ 'FILE1','FILE2' ])
 
       user     system      total        real
get   :  0.050000   0.070000   0.120000 (  1.026412)
get   :  0.010000   0.000000   0.010000 (  0.636914)
post  :  0.020000   0.010000   0.030000 ( 11.083888)
put   :  0.010000   0.000000   0.010000 (  1.240014)
delete:  0.020000   0.000000   0.020000 (  6.846295)
purge :  0.010000   0.010000   0.020000 ( 11.578944)
purge :  0.020000   0.000000   0.020000 (  0.956149)
purge :  0.030000   0.000000   0.030000 (  1.870104)
