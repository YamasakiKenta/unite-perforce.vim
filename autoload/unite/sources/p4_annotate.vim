function! unite#sources#p4_annotate#define()
	return [ s:source__p4_annotate, s:source__p4_annotate_ai ]
endfunction

let s:source = {
			\ 'name' : 'p4_annotate',
			\ 'description' : '各行にリビジョン番号を表示',
			\ 'hooks' : {},
			\ }
let s:source.hooks.on_init = function('common#GetFileNameForUnite')
function! s:source.gather_candidates(args, context) "{{{

	let depots = a:context.source__depots

	let candidates = []
	for depot in depots 
		let outs = perforce#pfcmds('annotate','',common#Get_kk(depot))
		let candidates += map( outs, "{
					\ 'word' : v:val,
					\ 'kind' : 'k_p4_filelog',
					\ 'action__depot' : depot,
					\ 'action__revnum' : <SID>getRevisionNumFromAnnotate(v:val),
					\ }")
	endfor

	return candidates
endfunction "}}}
let s:source__p4_annotate = s:source 

let s:source = {
			\ 'name' : 'p4_annotate_ai',
			\ 'description' : '各行にチェンジリスト番号を表示',
			\ 'hooks' : {},
			\ }
let s:source.hooks.on_init = function('common#GetFileNameForUnite')
function! s:source.gather_candidates(args, context) "{{{

	let depots = a:context.source__depots

	let candidates = []
	for depot in depots 

		let outs = perforce#pfcmds('annotate','','-ai '.common#Get_kk(depot))

		let candidates += map( outs, "{
					\ 'word' : v:val,
					\ 'kind' : 'k_p4_filelog',
					\ 'action__depot' : depot,
					\ 'action__chnum' : <SID>get_chnum_from_annotate(v:val),
					\ }")
	endfor

	return candidates
endfunction "}}}
let s:source__p4_annotate_ai = s:source 

" ================================================================================
" subrutine 
" ================================================================================
function! s:getRevisionNumFromAnnotate(str) "{{{
	return substitute(a:str,'^\(\d\+\).*','\1','')
endfunction "}}}
function! s:get_chnum_from_annotate(str) "{{{
	let low  = substitute(a:str, '\(\d\+\)-\(\d\+\):.*', '\1', '')
	let high = substitute(a:str, '\(\d\+\)-\(\d\+\):.*', '\2', '')

	return {
				\ 'low' : low,
				\ 'high' : high,
				\ }
endfunction "}}}
