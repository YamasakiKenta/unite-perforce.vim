let s:save_cpo = &cpo
set cpo&vim

function! unite#kinds#k_depot#define()
	return s:kind_depot
endfunction

function! s:get_port_client_files(candidates) "{{{
	" ********************************************************************************
	" [2013-06-08 20:32]
	" @return        { port_client = [file] }
	" ********************************************************************************
	let file_d = {}
	let default_port_clients = perforce#get#clients#get_use_port_clients()
	for candidate in a:candidates

		if exists('candidate.action__client')
			let port_clients = [candidate.action__client]
		else
			let port_clients = deepcopy(default_port_clients)
		endif

		for port_client in port_clients
			if !exists('file_d[port_client]')
				let file_d[port_client] = []
			endif
			if exists('candidate.action__depot')
				let path = candidate.action__depot
			elseif exists('candidate.action__path')
				let path = candidate.action__path
			endif
			call add(file_d[port_client], path)
		endfor
	endfor

	return file_d
endfunction
"}}}
function! s:sub_action(candidates, cmd) "{{{
	" [2013-06-08 20:32]
	let file_d = s:get_port_client_files(a:candidates)
	let datas  = perforce#cmd#client_files(file_d, a:cmd)
	let outs   = perforce#extend_dicts('outs', datas)
	return outs
endfunction
"}}}
function! s:sub_action_log(...) "{{{
	return call('pf_action#sub_action_log', a:000)
endfunction
"}}}
function! s:find_filepath_from_depot(candidate) "{{{
	" ********************************************************************************
	" [2013-06-09 01:27]
	" 編集するファイル名を取得する 
	" @param[in]	candidate		unite action の引数
	" @retval       path			編集するファイル名
	" ********************************************************************************
	if exists('a:candidate.action__cmd')
		if a:candidate.action__cmd == 'files'
			let depot = matchstr(a:candidate.action__out, '.*\ze#\d\+ - ')
		else
			let depot  = a:candidate.action__depot
		endif
	else
		let depot  = a:candidate.action__depot
	endif
	let client = exists( 'a:candidate.action__client' ) ? a:candidate.action__client : ''
	let path   = perforce#get#path#from_depot_with_client(client, depot)
	return path
endfunction
"}}}
"
"p4 k_depot 
let s:kind_depot = {
			\ 'name'           : 'k_depot',
			\ 'default_action' : 'a_open',
			\ 'action_table'   : {},
			\ 'parents'        : ['k_p4'],
			\ }
let s:kind_depot.action_table.p4_edit = {
				\ 'is_selectable' : 1, 
				\ 'description'   : '',
				\ }
function s:kind_depot.action_table.p4_edit.func(candidates)
	return s:sub_action_log(a:candidates, 'edit')
endfunction

let s:kind_depot.action_table.delete = {
				\ 'is_selectable' : 1, 
				\ 'description'   : '',
				\ }
function s:kind_depot.action_table.delete.func(candidates)
	return s:sub_action_log(a:candidates, 'delete')
endfunction

if 0
let s:kind_depot.action_table.revert = {
				\ 'is_selectable' : 1, 
				\ 'description'   : '',
				\ }
function s:kind_depot.action_table.revert.func(candidates)
	return s:sub_action_log(a:candidates, 'revert')
endfunction
endif

let s:kind_depot.action_table.revert_a = {
				\ 'is_selectable' : 1, 
				\ 'description'   : '',
				\ }
function s:kind_depot.action_table.revert_a.func(candidates)
	return s:sub_action_log(a:candidates, 'revert -a')
endfunction

let s:kind_depot.action_table.a_open = {
			\ 'description' : '開く',
			\ }
function! s:kind_depot.action_table.a_open.func(candidate) "{{{
	exe 'edit '.s:find_filepath_from_depot(a:candidate)
endfunction
"}}}

let s:kind_depot.action_table.yank = {
			\ 'description' : '',
			\ 'is_selectable' : 1, 
			\ }
function! s:kind_depot.action_table.yank.func(candidates) "{{{
	let tmps = []
	for candidate in a:candidates
		call add(tmps, s:find_filepath_from_depot(candidate))
	endfor
	let @" = join(tmps, "\n")
	let @+ = join(tmps, "\n")
endfunction
"}}}

let s:kind_depot.action_table.preview = {
			\ 'description' : 'preview' , 
			\ 'is_quit' : 0,
			\ }
function! s:kind_depot.action_table.preview.func(candidate) "{{{
	let path = s:find_filepath_from_depot(a:candidate) 
	exe 'pedit' path
endfunction
"}}}

let s:kind_depot.action_table.a_p4_files = { 
			\ 'is_selectable' : 1, 
			\ 'description' : 'ファイルの情報',
			\ }
function! s:kind_depot.action_table.a_p4_files.func(candidates) "{{{
	"TODO: source にする
	let outs = s:sub_action(a:candidates, 'files')
	call perforce#show(outs)
endfunction
"}}}

let s:kind_depot.action_table.delete = { 
			\ 'description' : 'diff preview ( not delete action. ) ',
			\ 'is_quit' : 0, 
			\ }
function! s:kind_depot.action_table.delete.func(candidate) "{{{
	" [2013-06-09 02:49]
	let outs = s:sub_action([a:candidate], 'diff -dw')
	call perforce#util#log_file('diff', 1, outs)
	wincmd p
endfunction
"}}}

let s:kind_depot.action_table.a_p4_diff = { 
			\ 'is_selectable' : 1, 
			\ 'description' : '差分',
			\ 'is_quit' : 0,
			\ }
function! s:kind_depot.action_table.a_p4_diff.func(candidates) "{{{
	"TODO: クライアント対応
	let args = map(copy(a:candidates),"v:val.action__depot")
	call unite#start_temporary([insert(args,'p4_diff')]) 
endfunction
"}}}

let s:kind_depot.action_table.a_p4_diff_tool = {
			\ 'is_selectable' : 1 ,  
			\ 'description' : '差分 ( TOOL )' ,
			\ }
function! s:kind_depot.action_table.a_p4_diff_tool.func(candidates) "{{{
	for l:candidate in a:candidates
		let depot = l:candidate.action__depot
		call perforce#diff#main(depot)
	endfor
endfunction
"}}}

let s:kind_depot.action_table.a_p4_reopen = {
			\ 'description' : 'チェンジリストの変更' ,
			\ 'is_selectable' : 1 ,
			\ }
function! s:kind_depot.action_table.a_p4_reopen.func(candidates) "{{{
	let client = a:candidates[0].action__client

	let args = [client] " # 初期化

	for candidate in a:candidates
		call add(args , candidate.action__depot) " # 保存

		if client != candidate.action__client
			echoe 'not "'.client. '" only...'
			return 
		endif
	endfor

	call unite#start([insert(args ,'p4_changes_pending_reopen')])
endfunction
"}}}

let s:kind_depot.action_table.a_p4_filelog = { 
			\ 'is_selectable' : 1, 
			\ 'description' : '履歴',
			\ }
function! s:kind_depot.action_table.a_p4_filelog.func(candidates) "{{{
	let depots = map(copy(a:candidates),"v:val.action__depot")
	call unite#start([insert(depots, 'p4_filelog')])
endfunction
"}}}

function! s:copy_file(depot, client, root, type) "{{{

	let depot  = a:depot
	let file1  = perforce#get#path#from_depot_with_client(a:client, depot)
	let port   = matchstr(a:client, '-p\s\+\zs\S*')
	let port   = substitute(port, ':', '', 'g')

	" 空白と引数がない場合は、defaultを設定する
	let root2 = perforce#data#get('g:perforce_merge_default_path')

	" 末尾の \ を削除する
	let root2 = substitute(root2,'/$','','')

	if a:type == 'depot'
		" 先頭の\\を削除する
		let depot = substitute(depot, '//','','')
	else
		" ClientPathを削除する
		let root1  = a:root
		let root1  = substitute(root1, '/', '\','g')

		" 置換するため、スペースはエスケープする
		let root1 = escape(root1,'\')

		" ルートの削除
		let depot = substitute(file1, root1,'','')
	endif

	" コピー先
	let file2 = root2.'/new/'.port.'/'.depot 

	" 変換
	let file1 = substitute(file1, '/','\','g')
	let file2 = substitute(file2, '/','\','g')

	" フォルダの作成
	let cmd = 'mkdir "'.fnamemodify(file2,':h').'"'
	echom 's:copy_file ->' string(cmd)
	call perforce#system(cmd)

	" コピーする
	let cmd = 'copy "'.file1.'" "'.file2.'"'
	echom 's:copy_file ->' string(cmd)
	call perforce#system(cmd)

endfunction
"}}}
let s:kind_depot.action_table.a_p4_dir_copy = {
	\ 'description' : 'dirでコピーする',
	\ 'is_selectable' : 1,
	\ }
function! s:kind_depot.action_table.a_p4_dir_copy.func(candidates) "{{{
	let root_cache = {}
	for candidate in a:candidates
		let client = candidate.action__client

		if !exists('root_cache[client]')
			let root_cache[client] = perforce#util#get_client_root_from_client(client)
		endif

		call s:copy_file(candidate.action__depot, client, root_cache[client].root, 'path')
	endfor
endfunction
"}}}

let s:kind_depot.action_table.a_p4_depot_copy = {
	\ 'description' : 'depotでコピーする',
	\ 'is_selectable' : 1,
	\ }
function! s:kind_depot.action_table.a_p4_depot_copy.func(candidates) "{{{
	for candidate in a:candidates
		let client = candidate.action__client
		call s:copy_file(candidate.action__depot, client, '', 'depot')
	endfor
endfunction
"}}}
"
call unite#define_kind(s:kind_depot)

if exists('s:save_cpo')
	let &cpo = s:save_cpo
	unlet s:save_cpo
else
	set cpo&
endif

