function! unite#sources#p4_annotate#define()
	return [ s:source__p4_annotate, s:source__p4_annotate_ai ]
endfunction

let s:source = {
			\ 'name' : 'p4_annotate',
			\ 'description' : '各行にリビジョン番号を表示',
			\ 'hooks' : {},
			\ }
let s:source.hooks.on_init = function('perforce#GetFileNameForUnite')
function! s:source.gather_candidates(args, context) "{{{

	" 引数がある場合は、引数のファイルをしていする
	if len(a:args) > 0
		let paths = map( a:args, '"//...".v:val."..."')
	else
		let paths = [a:context.source__path]
	endif

	let candidates = []
	for path in paths 

		let outs = perforce#pfcmds('annotate '.perforce#Get_kk(path))

		let candidates += map( outs, "{
					\ 'word' : v:val,
					\ 'kind' : 'k_p4_filelog',
					\ 'action__path' : path,
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
let s:source.hooks.on_init = function('perforce#GetFileNameForUnite')
function! s:source.gather_candidates(args, context) "{{{

	" 引数がある場合は、引数のファイルをしていする
	if len(a:args) > 0
		let paths = map( a:args, '"//...".v:val."..."')
	else
		let paths = [a:context.source__path]
	endif

	let candidates = []
	for path in paths 

		let outs = perforce#pfcmds('annotate -ai '.perforce#Get_kk(path))

		let candidates += map( outs, "{
					\ 'word' : v:val,
					\ 'kind' : 'k_p4_filelog',
					\ 'action__path' : path,
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
