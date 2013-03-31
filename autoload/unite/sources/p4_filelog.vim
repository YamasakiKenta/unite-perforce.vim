let s:save_cpo = &cpo
set cpo&vim


function! unite#sources#p4_filelog#define()
	return s:source
endfunction

let s:source = { 
			\ 'name' : 'p4_filelog',
			\ 'description' : '履歴',
			\ }
function! s:get_revision_num(str) "{{{
	return matchstr(a:str, '#\zs\d*')
endfunction "}}}
function! s:source.gather_candidates(args, context) "{{{
	" ********************************************************************************
	" @par ファイルの履歴を表示する
	" @param[in]	arg		表示する履歴のdepot
	" @par
	" "... ... branch into //depot/branch_1/mind/Test/AAA BBB/AAA BBB.txt.txt#1
	" ********************************************************************************
	let candidates = []

	for arg in a:args 
	 	let lines = perforce#pfcmds('filelog','',perforce#common#get_kk(arg)).outs
		let candidates += map(filter(lines, "v:val =~ '\.\.\. #'"), "{ 
					\ 'word' : v:val,
					\ 'kind' : 'k_p4_filelog', 
					\ 'action__revnum' : perforce#get#file#revision_num(v:val),
					\ 'action__depot' : arg,
					\ }")
	endfor
	
	return candidates
endfunction 
"}}}

if 1
call unite#define_source(s:source)
endif

let &cpo = s:save_cpo
unlet s:save_cpo

