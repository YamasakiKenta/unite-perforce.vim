function! unite#sources#p4_change#define()
	return [s:source_p4_changes_pending, s:source_p4_changes_submitted, s:source_p4_changes_pending_reopen]
endfunction
" --------------------------------------------------------------------------------
" 表示変更
" action__chname	新規チェンジリストのコメント
" action__chnum		チェンジリストの番号
" action__depots	チェンジリストの変更 ( 編集するファイル ) 
" --------------------------------------------------------------------------------

" ********************************************************************************
" source - p4_changes_pending
" ********************************************************************************
let s:source = {
			\ 'name' : 'p4_changes_pending',
			\ 'description' : '作成中のチェンジリスト',
			\ 'hooks' : {},
			\ 'is_quit' : 0,
			\ }
let s:source.hooks.on_init = function('perforce#GetFileNameForUnite')
let s:source.gather_candidates = function('perforce#p4_change_gather_candidates')
let s:source.change_candidates = function('perforce#p4_change_change_candidates')

let s:source_p4_changes_pending = s:source
unlet s:source

" ********************************************************************************
" source - p4_changes_pending_reopen
" ********************************************************************************
let s:source = {
			\ 'name' : 'p4_changes_pending_reopen',
			\ 'description' : 'チェンジリストの移動',
			\ 'hooks' : {},
			\ 'default_action' : 'a_p4_change_reopen',
			\ }
let s:source.hooks.on_init = function('perforce#GetFileNameForUnite')
let s:source.gather_candidates = function('perforce#p4_change_gather_candidates')
let s:source.change_candidates = function('perforce#p4_change_change_candidates')

let s:source_p4_changes_pending_reopen = s:source
unlet s:source 

" ********************************************************************************
" source - p4_changes_submitted
" ********************************************************************************
let s:source = {
			\ 'name' : 'p4_changes_submitted',
			\ 'description' : 'submit 済みチェンジリスト',
			\ 'hooks' : {},
			\ 'is_quit' : 0,
			\ }
let s:source.hooks.on_init = function('perforce#GetFileNameForUnite')
function! s:source.gather_candidates(args, context) "{{{
	let outs = perforce#pfcmds('changes','','-s submitted')
	return perforce#get_pfchanges(a:context, outs, 'k_p4_change')
endfunction "}}}
let s:source_p4_changes_submitted = s:source
unlet s:source 
