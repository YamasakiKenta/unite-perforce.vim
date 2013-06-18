let s:save_cpo = &cpo
set cpo&vim

function! unite#kinds#k_p4_change_reopen#define()
	return s:kind_k_p4_change_reopen
endfunction

function! s:make_new_changes(candidate) "{{{
" ********************************************************************************
" チェンジリストの番号の取得をする ( new の場合は、新規作成 )
" @param[in]	candidate	unite のあれ	
" @retval       chnum		番号
" ********************************************************************************

	let chnum       = a:candidate.action__chnum
	let port_client = pf_changes#get_port_client( a:candidate ) 

	if chnum == 'new'
		let chname = a:candidate.action__chname

		" チェンジリストの作成
		let chnum = pf_changes#make(chname, port_client)
	endif

	return chnum
endfunction
"}}}
"
let s:kind_k_p4_change_reopen = {
			\ 'name'           : 'k_p4_change_reopen',
			\ 'default_action' : 'a_p4_change_reopen',
			\ 'action_table'   : {},
			\ 'parents'        : ['k_p4'],
			\ }
let s:kind_k_p4_change_reopen.action_table.a_p4_change_reopen = {
			\ 'description' : 'チェンジリストの変更 ( reopen )' ,
			\ } 
function! s:kind_k_p4_change_reopen.action_table.a_p4_change_reopen.func(candidate) "{{{
	" ********************************************************************************
	" チェンジリストの変更
	" action から実行した場合は、選択したファイルを変更する。
	" source から実行した場合は、開いたファイルを変更する。
	" ********************************************************************************

	let reopen_depots = a:candidate.action__depots
	let port_client   = pf_changes#get_port_client(a:candidate)

	"チェンジリストの番号の取得
	let chnum = s:make_new_changes(a:candidate)

	" チェンジリストの変更
	let cmd = 'p4  '.port_client.' reopen -c '.chnum.' "'.join(reopen_depots,'" "').'"'
	call unite#print_message(cmd)
	let outs = split(system(cmd), "\n")

	" ログの出力
	call perforce#log_file(outs)

endfunction
"}}}
"
call unite#define_kind(s:kind_k_p4_change_reopen)

if exists('s:save_cpo')
	let &cpo = s:save_cpo
	unlet s:save_cpo
endif
