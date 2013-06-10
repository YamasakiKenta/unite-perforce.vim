let s:save_cpo = &cpo
set cpo&vim

function! unite#sources#p4_files#define()
	return s:source_p4_files
endfunction

"source - p4_files
let s:source_p4_files = {
			\ 'name'           : 'p4_files',
			\ 'description'    : '',
			\ 'default_action' : '',
			\ }
function! s:source_p4_files.gather_candidates(args, context) "{{{

	let port_clients = perforce#data#get_use_port_clients()
	let cmd = 'p4 files //...'

	let datas_ds = perforce#cmd#clients(port_clients, cmd)

	let candidates = []
	for data_d in data_ds
		let tmps = map( copy(data_d.out), "{
					\ 'word'        : v:val,
					\ 'kind'        : 'file',
					\ 'action__out' : out
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
