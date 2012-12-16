let s:save_cpo = &cpo
set cpo&vim


function! unite#sources#p4_filelog#define()
	return s:source
endfunction

let s:source = { 
			\ 'name' : 'p4_filelog',
			\ 'description' : '履歴',
			\ }
function! s:getRevisionNum(str) "{{{
	return substitute(copy(a:str), '.\{-}#\(\d\+\).*', '\1','g')
endfunction "}}}
function! s:source.gather_candidates(args, context) "{{{
	" ********************************************************************************
	" ファイルの履歴を表示する
	" @param[in]	arg		表示する履歴のdepot
	" ********************************************************************************
	let candidates = []

	for arg in a:args 
	 	let lines = perforce#pfcmds('filelog','',perforce#common#get_kk(arg)).outs
		let candidates += map(filter(lines, "v:val =~ '\.\.\. #'"), "{ 
					\ 'word' : v:val,
					\ 'kind' : 'k_p4_filelog', 
					\ 'action__revnum' : s:getRevisionNum(v:val),
					\ 'action__depot' : arg,
					\ }")
	endfor
"... ... branch into //depot/branch_1/mind/Test/AAA BBB/AAA BBB.txt.txt#1
	
	return candidates
endfunction "}}}

call unite#define_source(s:source)

let &cpo = s:save_cpo
unlet s:save_cpo

