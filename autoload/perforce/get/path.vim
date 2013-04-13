let s:save_cpo = &cpo
set cpo&vim

function! perforce#get#path#from_depot(depot) 
	let out = system('p4 where "'.a:depot.'"')
	let path = s:get_path_from_where(out)
	return path
endfunction

function! perforce#get#path#from_depot_with_client(client, depot)
	let cmd = 'p4 '.a:client.' where "'.a:depot.'"'
	let out = system(cmd)
	return matchstr(out, '.\{-}\zs\w*:.*\ze\n.*')
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
