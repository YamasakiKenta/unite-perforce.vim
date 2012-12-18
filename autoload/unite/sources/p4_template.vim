let s:save_cpo = &cpo
set cpo&vim

let g:pf_clients_template = get(g:, 'pf_clients_template', [])

function! unite#sources#p4_template#define()
	return [s:source_p4_template]
endfunction

let s:source_p4_template = {}
"source - p4_template
let s:source = {
			\ 'name'           : 'p4_template',
			\ 'description'    : '',
			\ 'default_action' : '',
			\ }
function! s:source.gather_candidates(args, context) "{{{
	let datas = deepcopy(g:pf_clients_template) 

	let candidates = []
	for data in datas
		for port in data.ports
			call add( candidates, {
						\ 'word' : '-p '.port.' -c '.data.clname.' : -c '.data.tmp,
						\ 'kind' : 'k_p4_template',
						\ 'action__cltmp' : data.cltmp,
						\ 'action__port' : port,
						\ 'action__clname' : data.clname,
						\ })
		endfor
	endfor
	return candidates
endfunction "}}}
let s:source_p4_template = deepcopy(s:source)

call unite#define_source(s:source_p4_template)

let &cpo = s:save_cpo
unlet s:save_cpo

" memo
" push ok
"  - diff
