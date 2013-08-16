let s:save_cpo = &cpo
set cpo&vim


function! unite#sources#p4_users#define()
	return s:source
endfunction

let s:source = {
			\ 'name' : 'p4/users',
			\ 'description' : 'ユーザーの切り替え',
			\ 'default_kind' : 'k_p4_users',
			\ }
function! s:source.gather_candidates(args, context) "{{{
	let datas = perforce#cmd#use_ports_max('p4 users')

	let candidates = []
	for data in datas
		let client = data.client
		call extend(candidates, map( data.outs, "{
					\ 'word' : client.' : '.v:val,
					\ 'action__out' : v:val,
					\ 'action__client' : client,
					\ }"))
	endfor
	return candidates
endfunction
"}}}

call unite#define_source(s:source)

let &cpo = s:save_cpo
unlet s:save_cpo

