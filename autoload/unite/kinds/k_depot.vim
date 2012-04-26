" ********************************************************************************
" depotで操作できるもの
" 
" ********************************************************************************
"
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
				\		let outs += perforce#cmds('".a:cmd." '.okazu#Get_kk(l:candidate.action__".
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
			\ 'parents' : [],
			\ }
call unite#define_kind(s:kind)

let s:kind.action_table.a_open = {
			\ 'is_selectable' : 1,
			\ 'description' : '開く',
			\ }
function! s:kind.action_table.a_open.func(candidates) "{{{
	for candidate in a:candidates
		let depot = candidate.action__depot

		" ローカルパスを取得して開く
		let path = perforce#get_path_from_depot(depot)

		if  path =~ "file(s) not on client."
			" ファイルの検索
			echo 'FIND...'
			let file = fnamemodify(depot,':t')
			exe 'find' $PFCLIENTPATH.'/**/'.file
		else 
			exe 'edit' path
		endif 

	endfor
endfunction "}}}

let s:kind.action_table.a_p4_files = { 
			\ 'is_selectable' : 1, 
			\ 'description' : 'ファイルの情報',
			\ }
function! s:kind.action_table.a_p4_files.func(candidates) "{{{
	let depots = map(copy(a:candidates),"v:val.action__depot")
	let outs = perforce#cmds('files '.join(depots))
	call okazu#LogFile('p4_files')
	call append(0,outs)
endfunction "}}}

let s:kind.action_table.a_p4_move = {
			\ 'is_selectable' : 1 ,
			\ 'description' : '移動 ( 名前の変更 )' ,
			\ }
function! s:do_move(oris,file) "{{{
	"********************************************************************************
	" perforceでファイル名を変更する関数
	" @param[in]	oris	変更前の名前
	" @param[in]	file	変更後の名前が保存されているファイル名
	"********************************************************************************

	"let g:debug = oris
	"let g:debug = oris + ['debug']


	let trans = readfile(a:file) " # 変更後の名前の取得

	let i = 0     " # ループ制御変数
	let outs = [] " # ログファイル用変数

	for ori in a:oris
		let tran = trans[i]
		let dir = fnamemodify(ori,':h').'/'                               " # ディレクトリの取得
		let outs += perforce#cmds('edit '.okazu#Get_kk(ori))                      " # 編集可能にする
		let outs += perforce#cmds('move '.okazu#Get_kk(ori).' '.okazu#Get_kk(dir.tran)) " # 実処理 - 名前の変更
		let i += 1

	endfor

	" # ログファイルの出力
	call perforce#LogFile(outs)

endfunction "}}}
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

		let g:pfmove_tmpfile = copy(g:pf_tmpfile)
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
		call okazu#event_save_file(g:pfmove_tmpfile,names,'perforce#do_move(g:pfmove_oris, g:pfmove_tmpfile)')

		"}}}
	endif 


endfunction "}}}

let s:kind.action_table.a_p4_diff = { 
			\ 'is_selectable' : 1, 
			\ 'description' : '差分',
			\ }
function! s:kind.action_table.a_p4_diff.func(candidates) "{{{
	let args = map(copy(a:candidates),"v:val.action__depot")
	call unite#start([insert(args,'p4_diff')]) 
endfunction "}}}

let s:kind.action_table.a_p4_diff_tool = {
			\ 'is_selectable' : 1 ,  
			\ 'description' : '差分 ( TOOL )' ,
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
	Unite p4_changes_pending -default-action=a_p4_change_reopen
	"call unite#start([['p4_changes_pending']]) " # defaultアクションの設定方法がわからない
endfunction "}}}

let s:kind.action_table.a_p4_filelog = { 
			\ 'is_selectable' : 1, 
			\ 'description' : '履歴',
			\ }
function! s:kind.action_table.a_p4_filelog.func(candidates) "{{{
	let depots = map(copy(a:candidates),"v:val.action__depot")
	call unite#start([insert(depots, 'p4_filelog')])
endfunction "}}}

let s:kind.action_table.a_p4_sync = { 
			\ 'is_selectable' : 1, 
			\ 'description' : 'ファイルの最新同期',
			\ }
function! s:kind.action_table.a_p4_sync.func(candidates) "{{{
	let depots = map(copy(a:candidates),"v:val.action__depot")
	let outs = perforce#cmds('sync '.join(depots))
	call perforce#LogFile(outs)
endfunction "}}}
