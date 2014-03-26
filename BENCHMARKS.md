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
get   :  0.060000   0.060000   0.120000 (  1.014527)
get   :  0.010000   0.000000   0.010000 (  0.613805)
post  :  0.020000   0.000000   0.020000 ( 19.011447)
put   :  0.020000   0.000000   0.020000 (  0.670025)
delete:  0.010000   0.000000   0.010000 (  1.076173)
purge :  0.020000   0.000000   0.020000 ( 11.109962)
purge :  0.010000   0.010000   0.020000 (  0.813984)
purge :  0.030000   0.000000   0.030000 (  6.704786)
