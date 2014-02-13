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
get   :  0.050000   0.070000   0.120000 (  1.004877)
get   :  0.020000   0.000000   0.020000 (  0.534179)
post  :  0.020000   0.000000   0.020000 ( 18.060298)
put   :  0.030000   0.010000   0.040000 (  0.981422)
delete:  0.020000   0.000000   0.020000 ( 11.770821)
purge :  0.020000   0.000000   0.020000 ( 13.584882)
purge :  0.020000   0.000000   0.020000 ( 17.310386)
purge :  0.030000   0.010000   0.040000 ( 16.446759)
