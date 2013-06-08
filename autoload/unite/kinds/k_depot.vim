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
	for candidate in a:candidates
		let port_client = get(candidate, 'action__client', ' ')
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

	return file_d
endfunction
"}}}
function! s:sub_action(candidates, cmd) "{{{
	" [2013-06-08 20:32]
	let file_d = s:get_port_client_files(a:candidates)
	let datas  = perforce#cmd#client_files(a:cmd, file_d)
	let outs   = map(copy(datas), "v:val.outs")
	call perforce#LogFile(outs)
endfunction
"}}}
function! s:find_filepath_from_depot(candidate) "{{{
	" ********************************************************************************
	" [2013-06-09 01:27]
	" 編集するファイル名を取得する 
	" @param[in]	candidate		unite action の引数
	" @retval       path			編集するファイル名
	" ********************************************************************************
	let depot  = a:candidate.action__depot
	let client = exists( 'a:candidate.action__client' ) ? a:candidate.action__client : ''
	let path   = perforce#get#path#from_depot_with_client(client, depot)
	return path
endfunction
"}}}
"
let action = {
				\ 'is_selectable' : 1, 
				\ 'description'   : '',
				\ }
function action.func(candidates)
	return s:sub_action(a:candidates, 'add')
endfunction
call unite#custom_action('jump_list' , 'add' , action)
call unite#custom_action('file'      , 'add' , action)

"p4 k_depot 
let s:kind_depot = {
			\ 'name'           : 'k_depot',
			\ 'default_action' : 'a_open',
			\ 'action_table'   : {},
			\ 'parents'        : ['k_p4'],
			\ }
let s:kind_depot.action_table.edit = {
				\ 'is_selectable' : 1, 
				\ 'description'   : '',
				\ }
function s:kind_depot.action_table.edit.func(candidates)
	return s:sub_action(a:candidates, 'edit')
endfunction
call unite#custom_action('jump_list' , 'p4_edit' , s:kind_depot.action_table.edit)
call unite#custom_action('file'      , 'p4_edit' , s:kind_depot.action_table.edit)

let s:kind_depot.action_table.delete = {
				\ 'is_selectable' : 1, 
				\ 'description'   : '',
				\ }
function s:kind_depot.action_table.delete.func(candidates)
	return s:sub_action(a:candidates, 'delete')
endfunction

if 0
let s:kind_depot.action_table.revert = {
				\ 'is_selectable' : 1, 
				\ 'description'   : '',
				\ }
function s:kind_depot.action_table.revert.func(candidates)
	return s:sub_action(a:candidates, 'revert')
endfunction
endif

let s:kind_depot.action_table.revert_a = {
				\ 'is_selectable' : 1, 
				\ 'description'   : '',
				\ }
function s:kind_depot.action_table.revert_a.func(candidates)
	return s:sub_action(a:candidates, 'revert -a')
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
	let depots = map(copy(a:candidates),"v:val.action__depot")
	let outs = perforce#cmd#base('files','',join(depots)).outs
	let outs = 
	call perforce_2#show(outs)
	sp
endfunction
"}}}

let s:kind_depot.action_table.delete = { 
			\ 'description' : '差分 ( delete だけど ) ',
			\ 'is_quit' : 0, 
			\ }
function! s:kind_depot.action_table.delete.func(candidate) "{{{
	let depot = a:candidate.action__depot
	call perforce#util#LogFile('diff', 1, perforce#cmd#base('diff','',depot).outs)
	wincmd p
endfunction
"}}}

let s:kind_depot.action_table.a_p4_diff = { 
			\ 'is_selectable' : 1, 
			\ 'description' : '差分',
			\ 'is_quit' : 0,
			\ }
function! s:kind_depot.action_table.a_p4_diff.func(candidates) "{{{
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
			call perforce_2#echo_error('not "'.client. '" only...')
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

let s:kind_depot.action_table.a_p4_sync = { 
			\ 'is_selectable' : 1, 
			\ 'description' : 'ファイルの最新同期',
			\ }
function! s:kind_depot.action_table.a_p4_sync.func(candidates) "{{{
	let depots = map(copy(a:candidates),"v:val.action__depot")
	let outs = perforce#cmd#base('sync','',join(depots)).outs
	call perforce#LogFile(outs)
endfunction
"}}}

function! s:copy_file(depot, client, root) "{{{

	let depot  = a:depot
	let file1  = perforce#get#path#from_depot_with_client('', depot)
	let port   = matchstr(a:client, '-p\s\+\zs\S*')
	let port   = substitute(port, ':', '', 'g')

	" 空白と引数がない場合は、defaultを設定する
	let root2 = perforce#data#get('g:perforce_merge_default_path')


	" 末尾の \ を削除する
	let root2 = substitute(root2,'/$','','')

	" 先頭の\\を削除する
	let depot = substitute(depot, '//','','')
	
	" ClientPathを削除する
	let root1  = a:root
	let root1  = substitute(root1, '/', '\','g')

	" 置換するため、スペースはエスケープする
	let root1 = escape(root1,'\')

	" ルートの削除
	let path1 = substitute(file1, root1,'','')

	" コピー先
	let file2 = root2.'/new/'.port.'/'.depot 

	" 変換
	let file1 = substitute(file1, '/','\','g')
	let file2 = substitute(file2, '/','\','g')

	" フォルダの作成
	let cmd = 'mkdir "'.fnamemodify(file2,':h').'"'
	echo 's:copy_file ->' string(cmd)
	call system(cmd)

	" コピーする
	let cmd = 'copy "'.file1.'" "'.file2.'"'
	echo 's:copy_file ->' string(cmd)
	call system(cmd)

endfunction
"}}}
"
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
		call s:copy_file(candidate.action__depot, client, root_cache[client].root)
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
		call s:copy_file(candidate.action__depot, client, '')
	endfor
endfunction
"}}}
"
if 1
	call unite#define_kind(s:kind_depot)
endif

let &cpo = s:save_cpo
unlet s:save_cpo

