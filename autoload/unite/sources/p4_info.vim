let s:save_cpo = &cpo
set cpo&vim

function! unite#sources#p4_info#define()
	return s:source_p4_info
endfunction

let s:source_p4_info = {
			\ 'name' : 'p4_info',
			\ 'description' : 'show p4 info',
			\ }
function! s:source_p4_info.gather_candidates(args, context) "{{{
	let datas = perforce#cmd#use_ports_max('p4 info')

	let candidates = []
	for data in datas
		let client = data.client
		call extend(candidates ,map( data.outs, "{
					\ 'word' : client.' : '.v:val,
					\ 'action__client' : client,
					\ 'action__out' : v:val,
					\ }"))
	endfor

	return candidates
endfunction
"}}}

call unite#define_source( s:source_p4_info )

let &cpo = s:save_cpo
unlet s:save_cpo

