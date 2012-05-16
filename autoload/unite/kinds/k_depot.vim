" ********************************************************************************
" depotで操作できるもの
" ********************************************************************************
"
function! unite#kinds#k_depot#define()
	return s:kind
endfunction

function! s:setPfcmd(kind,cmd,des) "{{{
	" ********************************************************************************
	" ファイル名を渡すだけのコマンドのアクション作成
	" @param[in]	kind		unite kind	
	" @param[in]	cmd			p4 コマンド
	" @param[in]	des			説明文
	" ********************************************************************************
	"
	let action = {
				\ 'is_selectable' : 1, 
				\ 'description' : a:des,
				\ }

	" Uniteにアクションの追加
	call unite#custom_action(a:kind, 'a_p4_'.a:cmd, action)

	" アクションパス
	let kind = {
				\ 'k_depot' : 'depot'
				\ }

	" 引数をコマンドにする "{{{
	execute "
				\ function! action.func(candidates) \n
				\ 	let outs = [] \n
				\ 	for l:candidate in a:candidates \n
				\		let outs += perforce#cmds('".a:cmd." '.perforce#Get_kk(l:candidate.action__".
				\			get(kind,a:kind,"file").")) \n
				\ 	endfor \n
				\ 	call perforce#LogFile(outs) \n
				\ endfunction "
	"}}}
	unlet action
endfunction "}}}
call <SID>setPfcmd('file','add','追加')
call <SID>setPfcmd('file','edit','編集')
call <SID>setPfcmd('k_depot','edit','編集')
call <SID>setPfcmd('k_depot','delete','削除')
call <SID>setPfcmd('k_depot','revert -a','元に戻す')
call <SID>setPfcmd('k_depot','revert','元に戻す ( 強制 )')

"p4 k_depot 
let s:kind = { 'name' : 'k_depot',
			\ 'default_action' : 'a_open',
			\ 'action_table' : {},
			\ 'parents' : ['k_p4'],
			\ }
call unite#define_kind(s:kind)

function! s:find_filepath_from_depot(candidate) "{{{
	" ********************************************************************************
	" 編集するファイル名を取得する 
	" @param[in]	candidate		unite action の引数
	" @retval       path			編集するファイル名
	" ********************************************************************************
	let candidate = a:candidate
	let depot = candidate.action__depot

	" ローカルパスを取得して開く
	let path = perforce#get_path_from_depot(depot)

	" ファイルが見つからなかった場合は、探す
	if  path =~ "file(s) not on client."
		" ファイルの検索
		echo 'FIND...'
		let file = fnamemodify(depot,':t')
		exe 'find' $PFCLIENTPATH.'/**/'.file
		let paths = glob($PFCLIENTPATH.'/**/'.file)
		let path = paths[0]
	endif 
	return path
endfunction "}}}

let s:kind.action_table.a_open = {
			\ 'description' : '開く',
			\ }
function! s:kind.action_table.a_open.func(candidate) "{{{
	let path = <SID>find_filepath_from_depot(a:candidate) 
	exe 'edit' path
endfunction "}}}

let s:kind.action_table.preview = {
			\ 'description' : 'preview' , 
			\ 'is_quit' : 0, 
			\ }
function! s:kind.action_table.preview.func(candidate) "{{{
	let path = <SID>find_filepath_from_depot(a:candidate) 
	exe 'pedit' path
endfunction "}}}

let s:kind.action_table.a_p4_files = { 
			\ 'is_selectable' : 1, 
			\ 'description' : 'ファイルの情報',
			\ 'is_quit' : 0 ,
			\ }
function! s:kind.action_table.a_p4_files.func(candidates) "{{{
	let depots = map(copy(a:candidates),"v:val.action__depot")
	let outs = perforce#cmds('files '.join(depots))
	call perforce#LogFile1('p4_files', 0)
	call append(0,outs)
endfunction "}}}

let s:kind.action_table.a_p4_move = {
			\ 'is_selectable' : 1 ,
			\ 'description' : '移動 ( 名前の変更 )' ,
			\ 'is_quit' : 0 ,
			\ }
function! s:kind.action_table.a_p4_move.func(candidates) "{{{
	" ********************************************************************************
	" perforceで名前の変更を行う
	" 一時ファイルが保存されたら、値を更新する
	" @param[in]	g:pfmove_oris		元の名前 ( ローカルパス )
	" @param[in]	g:pfmove_tmpfile	変更後の名前が保存される
	" ********************************************************************************
	"
	" 選択しているものがあれば、 
	"if len(a:candidates) == 1 
	if 0
		" 一つだけの場合 "{{{
		let l:candidate  = a:candidates[0]
		let depot        = l:candidate.action__depot
		let path         = perforce#get_path_from_depot(depot)
		let file         = fnamemodify(path,":t")
		let dir          = fnamemodify(path,":h")
		let new          = input(file.' -> ')
		if new != ''
			let outs = []
			let outs += perforce#cmds('edit '.path)
			let outs += perforce#cmds('move '.path.' '.dir.'/'.new)
			call perforce#LogFile(outs)
		endif
		"}}}
	else 
		" 複数選択の場合 "{{{

		let g:pfmove_tmpfile = copy($PFTMP)
		"
		" 元のパスの登録と初期のファイル名の取得 "{{{
		let names = []
		let g:pfmove_oris = []

		for candidate in a:candidates
			let depot          = candidate.action__depot
			let path           = perforce#get_path_from_depot(depot)
			let g:pfmove_oris += [path]
			let names         += [substitute(fnamemodify(path,":t"),'\n','','')] " # ファイル名のみ取得
		endfor
		"}}}
		"
		" 初期の名前の書き出し
		call perforce#event_save_file(g:pfmove_tmpfile,names,'perforce#do_move(g:pfmove_oris, g:pfmove_tmpfile)')

		"}}}
	endif 


endfunction "}}}

let s:kind.action_table.delete = { 
			\ 'description' : '差分',
			\ 'is_quit' : 0,
			\ }
function! s:kind.action_table.delete.func(candidate) "{{{
	"let wnum = winnr()
	let depot = a:candidate.action__depot

	call perforce#LogFile1('diff', 1, perforce#cmds('diff '.depot))

	wincmd p
endfunction "}}}

let s:kind.action_table.a_p4_diff = { 
			\ 'is_selectable' : 1, 
			\ 'description' : '差分',
			\ }
function! s:kind.action_table.a_p4_diff.func(candidates) "{{{
	let args = map(copy(a:candidates),"v:val.action__depot")
	call unite#start_temporary([insert(args,'p4_diff')]) 
endfunction "}}}

let s:kind.action_table.a_p4_diff_tool = {
			\ 'is_selectable' : 1 ,  
			\ 'description' : '差分 ( TOOL )' ,
			\ 'is_quit' : 0 ,
			\ }
function! s:kind.action_table.a_p4_diff_tool.func(candidates) "{{{
	for l:candidate in a:candidates
		let depot = l:candidate.action__depot
		call perforce#pfDiff(depot)
	endfor
endfunction "}}}

let s:kind.action_table.a_p4_reopen = {
			\ 'is_selectable' : 1 ,
			\ 'description' : 'チェンジリストの変更' ,
			\ }
function! s:kind.action_table.a_p4_reopen.func(candidates) "{{{
	let g:reopen_depots= [] " # 初期化
	for l:candidate in a:candidates
		call add(g:reopen_depots, l:candidate.action__depot) " # 保存
	endfor

	" 変更先を決める
	call unite#start_temporary(['p4_changes_pending_reopen'])
endfunction "}}}

let s:kind.action_table.a_p4_filelog = { 
			\ 'is_selectable' : 1, 
			\ 'description' : '履歴',
			\ 'is_quit' : 0 ,
			\ }
function! s:kind.action_table.a_p4_filelog.func(candidates) "{{{
	let depots = map(copy(a:candidates),"v:val.action__depot")
	call unite#start([insert(depots, 'p4_filelog')])
endfunction "}}}

let s:kind.action_table.a_p4_sync = { 
			\ 'is_selectable' : 1, 
			\ 'description' : 'ファイルの最新同期',
			\ 'is_quit' : 0 ,
			\ }
function! s:kind.action_table.a_p4_sync.func(candidates) "{{{
	let depots = map(copy(a:candidates),"v:val.action__depot")
	let outs = perforce#cmds('sync '.join(depots))
	call perforce#LogFile(outs)
endfunction "}}}

let s:kind.action_table.a_p4_dir_copy = {
	\ 'description' : 'dirでコピーする',
	\ 'is_selectable' : 1,
	\ 'is_quit' : 0 ,
	\ }
function! s:kind.action_table.a_p4_dir_copy.func(candidates) "{{{
	for candidate in a:candidates
		let path = perforce#get_path_from_depot(candidate.action__depot)
		call <SID>copyFileDir(path)
	endfor
endfunction "}}}
function! s:copyFileDir(file) "{{{

	" / -> \
	let file1 = substitute(a:file, '/','\','g')

	" 空白と引数がない場合は、defaultを設定する
	let root2 = perforce#get_pf_settings('ClientMove_defoult_root', 'common')[0]
	let root2 = substitute(root2, '/', '\','g')

	" 末尾の \ を削除する
	let root2 = substitute(root2,'\\$','','')

	" ClientPathを削除する
	let root1  = perforce#get_PFCLIENTPATH()
	let root1  = substitute(root1, '/', '\','g')

	" 置換するため、スペースはエスケープする
	let root1 = escape(root1,'\')

	" ルートの削除
	let path1 = substitute(file1, root1,'','')

	" コピー先
	let file2 = root2.''.path1

	"--------------------------------------------------------------------------------
	" 実行する
	"--------------------------------------------------------------------------------
	" フォルダの作成
	call system('mkdir "'.fnamemodify(file2,':h').'"')

	" コピーする
	call system('copy "'.file1.'" "'.file2.'"')

	echo 'copy "'.file1.'" "'.file2.'"'

endfunction
"}}}
let s:kind.action_table.a_p4_depot_copy = {
	\ 'description' : 'depotでコピーする',
	\ 'is_selectable' : 1,
	\ 'is_quit' : 0 ,
	\ }
function! s:kind.action_table.a_p4_depot_copy.func(candidates) "{{{
	for candidate in a:candidates
		call <SID>copyFileDepot(candidate.action__depot)
	endfor
endfunction "}}}
function! s:copyFileDepot(depotfile) "{{{

	" / -> \
	let depotfile1 = a:depotfile
	let localfile1 = perforce#get_path_from_depot(depotfile1)

	let depotfile1 = substitute(depotfile1, '/','\','g')
	let localfile1 = substitute(localfile1, '/','\','g')

	" 空白と引数がない場合は、defaultを設定する
	let root2 = perforce#get_pf_settings('ClientMove_defoult_root', 'common')[0]
	let root2 = substitute(root2, '/', '\','g')

	" 末尾の \ を削除する
	let root2 = substitute(root2,'\\$','','')

	" コピー先
	let file2 = root2.''.depotfile1

	"--------------------------------------------------------------------------------
	" 実行する
	"--------------------------------------------------------------------------------
	" フォルダの作成
	call system('mkdir "'.fnamemodify(file2,':h').'"')
	echo 'mkdir "'.fnamemodify(file2,':h').'"'

	" コピーする
	call system('copy "'.localfile1.'" "'.file2.'"')

	echo 'copy "'.localfile1.'" "'.file2.'"'

endfunction
"}}}
