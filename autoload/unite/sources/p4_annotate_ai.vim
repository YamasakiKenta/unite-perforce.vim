let s:save_cpo = &cpo
set cpo&vim

function! unite#sources#p4_annotate_ai#define()
	return s:source__p4_annotate_ai
endfunction

let s:source__p4_annotate_ai = {
			\ 'name' : 'p4/annotate_ai',
			\ 'description' : '各行にチェンジリスト番号を表示 ( 全て )',
			\ 'default_kind' : 'k_p4_filelog',
			\ 'hooks' : {},
			\ }
let s:source__p4_annotate_ai.hooks.on_init = function('perforce#get#fname#for_unite')
function! s:source__p4_annotate_ai.gather_candidates(args, context)
	return pf_annotate#gather_candidates(a:args, a:context, 'annotate -ai')
endfunction

call unite#define_source(s:source__p4_annotate_ai)

let &cpo = s:save_cpo
unlet s:save_cpo
