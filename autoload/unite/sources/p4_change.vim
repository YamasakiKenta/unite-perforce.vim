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
let s:source = {
			\ 'name'        : 'p4_changes_pending',
			\ 'description' : '作成中のチェンジリスト',
			\ 'hooks'       : {},
			\ 'is_quit'     : 0,
			\ }
let s:source.hooks.on_init = function('perforce#get_filename_for_unite')
function! s:source.gather_candidates(args, context) "{{{
	" ********************************************************************************
	" チェンジリストの表示 表示設定関数
	" チェンジリストの変更の場合、開いたいるファイルを変更するか、actionで指定したファイル
	" @param[in]	args				depot
	" ********************************************************************************
	"
	" 表示するクライアント名の取得
	let outs = perforce#data#get('client_changes_only') ? 
				\ [perforce#get_PFCLIENTNAME()] : 
				\ perforce#pfcmds('clients','').outs

				"\ 'word'           : 'default by '.perforce#get_ClientName_from_client(v:val),
	" defaultの表示
	let rtn = []
	let rtn += map( outs, "{
				\ 'word'           : 'default by '.v:val,
				\ 'kind'           : 'k_p4_change_pending',
				\ 'action__chnum'  : 'default',
				\ 'action__depots' : a:context.source__depots,
				\ }")

	let outs = perforce#pfcmds('changes','','-s pending').outs
	let rtn += perforce#get_pfchanges(a:context, outs, 'k_p4_change_pending')
	return rtn
endfunction "}}}
function! s:source.change_candidates(args, context) "{{{
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

endfunction "}}}

let s:source_p4_changes_pending = deepcopy(s:source) | unlet s:source

" ********************************************************************************
" source - p4_changes_pending_reopen
" ********************************************************************************
let s:source = {
			\ 'name' : 'p4_changes_pending_reopen',
			\ 'description' : 'チェンジリストの移動',
			\ 'hooks' : {},
			\ 'default_action' : 'a_p4_change_reopen',
			\ }
let s:source.hooks.on_init = function('perforce#get_filename_for_unite')
let s:source.gather_candidates = s:source_p4_changes_pending.gather_candidates
let s:source.change_candidates = s:source_p4_changes_pending.change_candidates

let s:source_p4_changes_pending_reopen = deepcopy(s:source) | unlet s:source 

" ********************************************************************************
" source - p4_changes_submitted
" ********************************************************************************
let s:source = {
			\ 'name' : 'p4_changes_submitted',
			\ 'description' : 'submit 済みチェンジリスト',
			\ 'hooks' : {},
			\' default_action' : 'a_p4change_describe',
			\ }

	"call unite#start_temporary([['settings_ex_list_select', tmp_d]], {'default_action' : 'a_toggle'})
let s:source.hooks.on_init = function('perforce#get_filename_for_unite')
function! s:source.gather_candidates(args, context) "{{{
	let outs = perforce#pfcmds('changes','','-s submitted').outs
	return perforce#get_pfchanges(a:context, outs, 'k_p4_change_submitted')
endfunction "}}}

let s:source_p4_changes_submitted = deepcopy(s:source) | unlet s:source

call unite#define_source(s:source_p4_changes_pending_reopen)
call unite#define_source(s:source_p4_changes_submitted)
call unite#define_source(s:source_p4_changes_pending)


let &cpo = s:save_cpo
unlet s:save_cpo

