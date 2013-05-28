let s:save_cpo = &cpo
set cpo&vim

function! unite#sources#p4_annotate_ai#define()
	return s:source__p4_annotate_ai
endfunction

let s:source__p4_annotate_ai = {
			\ 'name' : 'p4_annotate_ai',
			\ 'description' : '各行にチェンジリスト番号を表示 ( 全て )',
			\ 'hooks' : {},
			\ }
let s:source__p4_annotate_ai.hooks.on_init = function('perforce#get#fname#for_unite')
function! s:source__p4_annotate_ai.gather_candidates(args, context) "{{{

	let depots = a:context.source__depots

	let candidates = []
	for depot in depots 

		let outs = perforce#cmd#base('annotate','','-ai '.perforce#get_kk(depot)).outs

		let candidates += map( outs, "{
					\ 'word' : v:val,
					\ 'kind' : 'k_p4_filelog',
					\ 'action__depot' : depot,
					\ 'action__chnum' : s:get_chnum_from_annotate(v:val),
					\ }")
	endfor

	return candidates
endfunction
"}}}

call unite#define_source(s:source__p4_annotate_ai)

" === SUB ===
function! s:get_chnum_from_annotate(str) "{{{
	let low  = substitute(a:str, '\(\d\+\)-\(\d\+\):.*', '\1', '')
	let high = substitute(a:str, '\(\d\+\)-\(\d\+\):.*', '\2', '')

	return {
				\ 'low' : low,
				\ 'high' : high,
				\ }
endfunction 
"}}}

let &cpo = s:save_cpo
unlet s:save_cpo
