let s:save_cpo = &cpo
set cpo&vim

function! unite#sources#p4_files#define()
	return s:source_p4_files
endfunction

"source - p4_files
let s:source_p4_files = {
			\ 'name'           : 'p4_files',
			\ 'description'    : '',
			\ 'default_kind'   : 'k_depot',
			\ }
function! s:source_p4_files.gather_candidates(args, context) "{{{

	let port_clients = perforce#data#get_use_port_clients()
	let root = get(a:args, 0, '/')
	let root = substitute(root, '\\', '/', 'g')


	echo root
	let cmd = printf('p4 files %s/...', root)

	let data_ds = perforce#cmd#clients(port_clients, cmd)

	let candidates = []
	for data in data_ds
		let tmps = map( copy(data.outs), "{
					\ 'word'          : v:val,
					\ 'action__out'   : v:val,
					\ 'action__cmd'   : 'files',
					\ 'action__client': data.client,
					\ }")
		call extend(candidates, tmps)
	endfor
	return candidates
endfunction
"}}}

call unite#define_source(s:source_p4_files) 

if exists('s:save_cpo')
	let &cpo = s:save_cpo
	unlet s:save_cpo
endif
