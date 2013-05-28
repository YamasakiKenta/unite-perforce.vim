let s:save_cpo = &cpo
set cpo&vim

function! unite#sources#p4_annotate#define()
	return s:source__p4_annotate
endfunction

let s:source__p4_annotate = {
			\ 'name' : 'p4_annotate',
			\ 'description' : '各行にリビジョン番号を表示',
			\ 'hooks' : {},
			\ }
let s:source__p4_annotate.hooks.on_init = function('perforce#get#fname#for_unite')
function! s:source__p4_annotate.gather_candidates(args, context) "{{{

	let depots = a:context.source__depots

	let candidates = []
	let lnum = 0
	for depot in depots 
		let outs = perforce#cmd#base('annotate','',perforce#get_kk(depot)).outs

		for out in outs
			let candidates += map( [out], "{
						\ 'word' : lnum.' : '.v:val,
						\ 'kind' : 'k_p4_filelog',
						\ 'action__depot' : depot,
						\ 'action__revnum' : s:get_revnum_from_annotate(v:val),
						\ }")
			let lnum += 1
		endfor

		return candidates
	endfunction
	"}}}

call unite#define_source(s:source__p4_annotate)

"=== SUB ===
	function! s:get_revnum_from_annotate(str) "{{{
		return substitute(a:str,'^\(\d\+\).*','\1','')
	endfunction 
	"}}}


	let &cpo = s:save_cpo
	unlet s:save_cpo

