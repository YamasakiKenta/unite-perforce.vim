let s:save_cpo = &cpo
set cpo&vim


function! unite#sources#p4_change#define()
	return [
				\ s:source_p4_changes_pending,
				\ s:source_p4_changes_submitted,
				\ s:source_p4_changes_pending_reopen,
				\ ]
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
let s:source_p4_changes_pending = {
			\ 'name'        : 'p4_changes_pending',
			\ 'description' : '作成中のチェンジリスト',
			\ 'hooks'       : {},
			\ 'is_quit'     : 0,
			\ }
let s:source_p4_changes_pending.hooks.on_init = function('perforce#get#fname#for_unite')
function! s:source_p4_changes_pending.gather_candidates(args, context) "{{{
	" ********************************************************************************
	" チェンジリストの表示 表示設定関数
	" チェンジリストの変更の場合、開いたいるファイルを変更するか、actionで指定したファイル
	" @param[in]	args				depot
	" ********************************************************************************
	"
	" 表示するクライアント名の取得
	let outs = perforce#data#get('client_changes_only') ? 
				\ [perforce#get#PFCLIENTNAME()] : 
				\ perforce#cmd#base('clients','').outs

	" defaultの表示
	let rtn = []
	let rtn += map( outs, "{
				\ 'word'           : 'default by '.v:val,
				\ 'kind'           : 'k_p4_change_pending',
				\ 'action__chnum'  : 'default',
				\ 'action__depots' : a:context.source__depots,
				\ }")

	let outs = perforce#cmd#base('changes','','-s pending').outs
	let rtn += perforce#get_pfchanges(a:context, outs, 'k_p4_change_pending')
	return rtn
endfunction
"}}}
function! s:source_p4_changes_pending.change_candidates(args, context) "{{{
	" ********************************************************************************
	" p4 change ソースの 変化関数
	" @param[in]	
	" @retval       
	" ********************************************************************************
	" Unite で入力された文字
	let newfile = a:context.input

	" 入力がない場合は、表示しない
	if newfile != ""
		return [{
					\ 'word' : '[new] '.newfile,
					\ 'kind' : 'k_p4_change_reopen',
					\ 'action__chname' : newfile,
					\ 'action__chnum' : 'new',
					\ 'action__depots' : a:context.source__depots,
					\ }]
	else
		return []
	endif

endfunction
"}}}

" ********************************************************************************
" source - p4_changes_pending_reopen
" ********************************************************************************
let s:source_p4_changes_pending_reopen = {
			\ 'name' : 'p4_changes_pending_reopen',
			\ 'description' : 'チェンジリストの移動',
			\ 'hooks' : {},
			\ 'default_action' : 'a_p4_change_reopen',
			\ }
let s:source_p4_changes_pending_reopen.hooks.on_init = function('perforce#get#fname#for_unite')
let s:source_p4_changes_pending_reopen.gather_candidates = s:source_p4_changes_pending.gather_candidates
let s:source_p4_changes_pending_reopen.change_candidates = s:source_p4_changes_pending.change_candidates

" ********************************************************************************
" source - p4_changes_submitted
" ********************************************************************************
let s:source_p4_changes_submitted = {
			\ 'name' : 'p4_changes_submitted',
			\ 'description' : 'submit 済みチェンジリスト',
			\ 'hooks' : {},
			\' default_action' : 'a_p4change_describe',
			\ }

	"call unite#start_temporary([['settings_ex_list_select', tmp_d]], {'default_action' : 'a_toggle'})
let s:source_p4_changes_submitted.hooks.on_init = function('perforce#get#fname#for_unite')
function! s:source_p4_changes_submitted.gather_candidates(args, context) "{{{
	let outs = perforce#cmd#base('changes','','-s submitted').outs
	return perforce#get_pfchanges(a:context, outs, 'k_p4_change_submitted')
endfunction
"}}}

call unite#define_source(s:source_p4_changes_pending_reopen)
call unite#define_source(s:source_p4_changes_submitted)
call unite#define_source(s:source_p4_changes_pending)


let &cpo = s:save_cpo
unlet s:save_cpo

