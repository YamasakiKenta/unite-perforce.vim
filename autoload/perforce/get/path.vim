let s:save_cpo = &cpo
set cpo&vim

function! s:get_path_from_where(strg)
	return matchstr(a:str, '.\{-}\zs\w*:.*\ze\n.*')
endfunction

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

function! perforce#get#path#from_diff(data_d, out) 
	" ==== //depot/mind/unite-perforce.vim/autoload/perforce.vim#11 - C:\Users\yamasaki.mac\Dropbox\vim\mind\unite-perforce.vim\autoload\perforce.vim ====
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
