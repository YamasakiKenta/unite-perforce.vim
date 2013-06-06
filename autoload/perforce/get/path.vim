let s:save_cpo = &cpo
set cpo&vim

function! s:get_path_from_where(str)
	return matchstr(a:str, '.\{-}\zs\w*:.*\ze\n.*')
endfunction

function! perforce#get#path#from_depot_with_client(client, depot)
	" [2013-06-07 02:35]
	let cmd = 'p4 '.a:client.' where "'.a:depot.'"'
	let out = system(cmd)
	return s:get_path_from_where(out)
endfunction

function! perforce#get#path#from_diff(data_d, out) 
	" [2013-06-07 02:36]
	"
	let data_d = a:data_d
	if a:out =~ '^===='
		let data_d.path   = matchstr(a:out, '==== .*#\d* - \zs.*\ze ====')
		let data_d.depot  = matchstr(a:out, '==== \zs.*\ze#\d*')
		let data_d.revnum = matchstr(a:out, '==== .*#\zs\d*')
	endif 
	return data_d
endfunction


let &cpo = s:save_cpo
unlet s:save_cpo
