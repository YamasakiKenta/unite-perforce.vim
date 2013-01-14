let s:save_cpo = &cpo
set cpo&vim

let s:_file  = expand("<sfile>")
let s:_debug = vital#of('unite-perforce.vim').import("Mind.Debug")
"
let g:perforce_merge_tool         = get(g:, 'perforce_merge_tool', 'winmergeu /S')
let g:perforce_merge_default_path = get(g:, 'perforce_merge_default_path', 'c:\tmp')

command! -nargs=? PfMerge call s:pf_merge(<q-args>)

function! s:pf_merge(...) "{{{
	" ********************************************************************************
	" 現在のクライアントと、マージします。
	" @param[in]	path	比較するファイル
	" @retval       NONE
	" ********************************************************************************
	let path = ( a:1 == "" ) ? g:perforce_merge_default_path : a:1
	
	let cmd = g:perforce_merge_tool.' "'.path.'" "'.perforce#get_PFCLIENTPATH.'"'
	echo cmd

	exe '!start '.cmd

endfunction
"}}}

let &cpo = s:save_cpo
unlet s:save_cpo

