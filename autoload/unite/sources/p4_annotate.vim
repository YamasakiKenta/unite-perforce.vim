let s:save_cpo = &cpo
set cpo&vim

function! unite#sources#p4_annotate#define()
	return s:source__p4_annotate
endfunction

let s:source__p4_annotate = {
			\ 'name' : 'p4_annotate',
			\ 'description' : '各行にリビジョン番号を表示',
			\ 'default_kind' : 'k_p4_filelog',
			\ 'hooks' : {},
			\ }
let s:source__p4_annotate.hooks.on_init = function('perforce#get#fname#for_unite')
function! s:source__p4_annotate.gather_candidates(args, context)
	return pf_annotate#gather_candidates(a:args, a:context, 'annotate')
endfunction

call unite#define_source(s:source__p4_annotate)

let &cpo = s:save_cpo
unlet s:save_cpo

