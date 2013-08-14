let s:save_cpo = &cpo
set cpo&vim

let g:pf_clients_template = get(g:, 'pf_clients_template', {})

function! unite#sources#p4_template#define()
	return s:source_p4_template
endfunction

"source - p4_template
let s:source_p4_template = {
			\ 'name'           : 'p4/template',
			\ 'default_kind'   : 'k_p4_template',
			\ 'description'    : '',
			\ }
function! s:source_p4_template.gather_candidates(args, context) "{{{
	let data_d = copy(perforce#data#get('g:pf_clients_template'))

	let candidates = [{
				\ 'word' : printf("%-50s -> %s", "template", "client"),
				\ 'kind' : 'common',
				\ }]

	for client in keys(data_d)
		call add( candidates, {
					\ 'word' : printf("%-50s -> %s", data_d[client], client),
					\ 'action__cltmp'  : data_d[client],
					\ 'action__clname' : client,
					\ })
	endfor

	return candidates
endfunction
"}}}

call unite#define_source(s:source_p4_template)

let &cpo = s:save_cpo
unlet s:save_cpo

