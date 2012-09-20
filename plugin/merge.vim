let g:perforce_merge_tool         = get(g:, 'perforce_merge_tool', 'winmergeu /S')
let g:perforce_merge_default_path = get(g:, 'perforce_merge_default_path', 'c:\tmp')

command! -nargs=? PfMerge call s:pf_merge(<q-args>) "{{{
function! s:pf_merge(...)
	" ********************************************************************************
	" 現在のクライアントと、マージします。
	" @param[in]	path	比較するファイル
	" @retval       NONE
	"
	" g:perforce_merge_tool         = 
	" g:perforce_merge_default_path = 
	" ********************************************************************************
	let path = a:1 == "" ? g:perforce_merge_default_path : a:1
	call system(g:perforce_merge_tool.' "'.path.'" "'.$PFCLIENTPATH.'"')

endfunction
"}}}


