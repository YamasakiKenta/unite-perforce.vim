"vim : set fdm = marker :
function! unite#kinds#k_p4_change#define()
	return [ s:k_p4_change, s:k_p4_change_reopen ]
endfunction

" ********************************************************************************
let s:kind = { 'name' : 'k_p4_change_reopen',
			\ 'default_action' : 'a_p4_change_reopen',
			\ 'action_table' : {},
			\ }

" --------------------------------------------------------------------------------

let s:kind.action_table.a_p4_change_reopen = {
			\ 'description' : 'チェンジリストの変更' ,
			\ 'is_quit' : 0,
			\ } 
function! s:kind.action_table.a_p4_change_reopen.func(candidate) "{{{
	" ********************************************************************************
	" チェンジリストの変更
	" action から実行した場合は、選択したファイルを変更する。
	" source から実行した場合は、開いたファイルを変更する。
	"
	" @param[in]	g:reopen_depots		選択したファイル
	" ********************************************************************************

	" 選択したファイルがない場合は、現在のファイルを使用する
	if !len(g:reopen_depots)
		let g:reopen_depots = a:candidate.action__path
	endif

	"チェンジリストの番号の取得
	let chnum = <SID>make_new_changes(a:candidate)

	" チェンジリストの変更
	let outs = perforce#cmds('reopen -c '.chnum.' '.okazu#Get_kk(join(g:reopen_depots,'" "')))

	" 追加するファイル名を初期化する
	let g:reopen_depots = [] 

	" ログの出力
	call perforce#LogFile(outs)

endfunction "}}}

let s:k_p4_change_reopen = s:kind
unlet s:kind
" ********************************************************************************
let s:kind = { 'name' : 'k_p4_change',
			\ 'default_action' : 'a_p4_change_opened',
			\ 'action_table' : {},
			\ }
" --------------------------------------------------------------------------------
"複数選択可能
let s:kind.action_table.a_p4_change_opened = { 
			\ 'is_selectable' : 1, 
			\ 'description' : 'ファイルの表示',
			\ 'is_quit' : 0,
			\ }
function! s:kind.action_table.a_p4_change_opened.func(candidates) "{{{

	let chnums = []
	for candidate in a:candidates
		" チェンジリストの番号の取得をする
		let chnums += [<SID>make_new_changes(candidate)]
	endfor

	call unite#start_temporary([insert(chnums,'p4_opened')]) " # 閉じない ? 
endfunction "}}}

let s:kind.action_table.a_p4_change_info = { 
			\ 'is_selectable' : 1, 
			\ 'description' : 'チェンジリストの情報' ,
			\ 'is_quit' : 0,
			\ }
function! s:kind.action_table.a_p4_change_info.func(candidates) "{{{
	let outs = []
	for l:candidate in a:candidates
		let chnum = l:candidate.action__chnum
		let outs += split(system('P4 change -o '.chnum),'\n')
	endfor
	call perforce#LogFile(outs)
endfunction "}}}

let s:kind.action_table.a_p4_change_delete = {
			\ 'is_selectable' : 1,
			\ 'description' : 'チェンジリストの削除' ,
			\ 'is_quit' : 0,
			\ }
function! s:kind.action_table.a_p4_change_delete.func(candidates) "{{{
	let i = 1
	for l:candidate in a:candidates
		let num = l:candidate.action__chnum
		let out = system('p4 change -d '.num)
		let outs = split(out,'\n')
		call perforce#LogFile(outs)
		let i += len(outs)
	endfor
endfunction "}}}

let s:kind.action_table.a_p4_change_submit = {
			\ 'is_selectable' : 1,
			\ 'description' : 'サブミット' ,
			\ 'is_quit' : 0,
			\ }
function! s:kind.action_table.a_p4_change_submit.func(candidates) "{{{

	if g:pf_setting.bool.is_submit_flg.value.common == 0
		echo ' g:pf_setting.bool.is_submit_flg.value.common is not TRUE'
		return 
	else

		let chnums = map(copy(a:candidates), "v:val.action__chnum")
		let outs = perforce#cmds('submit -c '.join(chnums))
		call perforce#LogFile(outs)
	endif 

endfunction "}}}

let s:kind.action_table.a_p4change_describe = { 
			\ 'is_selectable' : 1, 
			\ 'description' : '差分の表示',
			\ 'is_quit' : 0,
			\ }
function! s:kind.action_table.a_p4change_describe.func(candidates) "{{{
	let chnums = map(copy(a:candidates),"v:val.action__chnum")
	call unite#start([insert(chnums,'p4_describe')])
endfunction "}}}

let s:kind.action_table.a_p4_matomeDiff = { 
			\ 'is_selectable' : 1, 
			\ 'description' : '差分のまとめを表示',
			\ 'is_quit' : 0,
			\ }
function! s:kind.action_table.a_p4_matomeDiff.func(candidates) "{{{
	for l:candidate in a:candidates
		let chnum = l:candidate.action__chnum
		call perforce#matomeDiffs(chnum)
	endfor
endfunction "}}}
"
let s:kind.action_table.a_p4_change_reopen = {
			\ 'description' : 'チェンジリストの変更' ,
			\ 'is_quit' : 0,
			\ } 
function! s:kind.action_table.a_p4_change_reopen.func(candidate) "{{{
	" ********************************************************************************
	" チェンジリストの変更
	" action から実行した場合は、選択したファイルを変更する。
	" source から実行した場合は、開いたファイルを変更する。
	"
	" @param[in]	g:reopen_depots		選択したファイル
	" ********************************************************************************

	" 選択したファイルがない場合は、現在のファイルを使用する
	if !len(g:reopen_depots)
		let g:reopen_depots = a:candidate.action__path
	endif

	"チェンジリストの番号の取得
	let chnum = <SID>make_new_changes(a:candidate)

	" チェンジリストの変更
	let outs = perforce#cmds('reopen -c '.chnum.' '.okazu#Get_kk(join(g:reopen_depots,'" "')))

	" 追加するファイル名を初期化する
	let g:reopen_depots = [] 

	" ログの出力
	call perforce#LogFile(outs)

endfunction "}}}

let s:kind.action_table.a_p4_change_rename = {
			\  'description' : '名前の変更' ,
			\ 'is_quit' : 0,
			\ }
function! s:kind.action_table.a_p4_change_rename.func(candidate) "{{{
	let chnum = a:candidate.action__chnum
	"let chname = input('ChangeList Comment (change): '.a:candidate.action__chname, a:candidate.action__chname)
	let chname = input('ChangeList Comment (change): ')

	" 入力がない場合は、実行しない
	if chname =~ ""
		let outs = perforce#pfChange(chname,chnum)
		call perforce#LogFile(outs)
	endif
endfunction "}}}

let s:k_p4_change = s:kind
unlet s:kind

" ********************************************************************************
" チェンジリストの番号の取得をする ( new の場合は、新規作成 )
" @param[in]	candidate	unite のあれ	
" @retval       chnum		番号
" ********************************************************************************
function! s:make_new_changes(candidate) "{{{

	let chnum = a:candidate.action__chnum
	let chname = a:candidate.action__chname

	if chnum == 'new'
		" チェンジリストの作成
		let outs = perforce#pfChange(chname)

		"チェンジリストの新規作成の結果から番号を取得する
		let chnum = perforce#get_ChangeNum_from_changes(outs[0])
	else
		let chnum = chnum
	endif

	return chnum
endfunction "}}}

