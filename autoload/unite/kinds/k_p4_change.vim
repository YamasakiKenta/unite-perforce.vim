"vim : set fdm = marker :
function! unite#kinds#k_p4_change#define()
	return s:kind
endfunction

let s:kind = { 'name' : 'k_p4_change',
			\ 'default_action' : 'a_p4_change_opened',
			\ 'action_table' : {},
			\ }

"複数選択可能
let s:kind.action_table.a_p4_change_opened = { 
			\ 'is_selectable' : 1, 
			\ 'description' : 'ファイルの表示',
			\ }
function! s:kind.action_table.a_p4_change_opened.func(candidates) "{{{

	" チェンジリストの番号の取得をする
	let chnums = []
	for candidate in a:candidates
		let chnum = candidate.action__chnum
		let chname = candidate.action__chname

		if chnum =~ 'new'
			" チェンジリストの作成
			let outs = perforce#pfChange(chname)

			"チェンジリストの新規作成の結果から番号を取得する
			let g:debug = outs
			let chnums += [perforce#get_ChangeNum_from_changes(outs[0])]

		else
			let chnums += [chnum]

		endif

	endfor

	call unite#start([insert(chnums,'p4_opened')])

endfunction "}}}

let s:kind.action_table.a_p4_change_info = { 
			\ 'is_selectable' : 1, 
			\ 'description' : 'チェンジリストの情報' 
			\ ,}
function! s:kind.action_table.a_p4_change_info.func(candidates) "{{{
	let outs = []
	for l:candidate in a:candidates
		let chnum = l:candidate.action__chnum
		let outs += split(system('P4 change -o '.chnum),'\n')
	endfor
	call perforce#pfLogFile(outs)
endfunction "}}}

let s:kind.action_table.a_p4_change_delete = {
			\ 'is_selectable' : 1,
			\ 'description' : 'チェンジリストの削除' 
			\ }
function! s:kind.action_table.a_p4_change_delete.func(candidates) "{{{
	let i = 1
	for l:candidate in a:candidates
		let num = l:candidate.action__chnum
		let out = system('p4 change -d '.num)
		let outs = split(out,'\n')
		call perforce#pfLogFile(outs)
		let i += len(outs)
	endfor
endfunction "}}}

let s:kind.action_table.a_p4_change_submit = {
			\ 'is_selectable' : 1,
			\ 'description' : 'サブミット' 
			\ }
function! s:kind.action_table.a_p4_change_submit.func(candidates) "{{{

	if g:pf_is_submit_flg == 0
		echo ' g:pf_is_submit_flg is not TRUE'
		return 
	else
		"let outs = []
		"for l:candidate in a:candidates
		"let chnum = l:candidate.action__chnum
		"let outs += perforce#cmds('submit -c '.chnum)
		"endfor
		"
		let chnums = map(copy(a:candidates), "v:val.action__chnum")
		let outs = perforce#cmds('submit -c '.join(chnums))
		call perforce#pfLogFile(outs)
	endif 

endfunction "}}}

let s:kind.action_table.a_p4change_describe = { 
			\ 'is_selectable' : 1, 
			\ 'description' : '差分の表示',
			\ }
function! s:kind.action_table.a_p4change_describe.func(candidates) "{{{
	let chnums = map(copy(a:candidates),"v:val.action__chnum")
	call unite#start([insert(chnums,'p4_describe')])
endfunction "}}}

let s:kind.action_table.a_p4_matomeDiff = { 
			\ 'is_selectable' : 1, 
			\ 'description' : '差分のまとめを表示',
			\ }
function! s:kind.action_table.a_p4_matomeDiff.func(candidates) "{{{
	for l:candidate in a:candidates
		let chnum = l:candidate.action__chnum
		call perforce#matomeDiffs(chnum)
	endfor
endfunction "}}}
"
"ひとつのみ選択可能
let s:kind.action_table.a_p4_change_reopen = {
			\ 'description' : 'チェンジリストの変更' 
			\ } 
function! s:kind.action_table.a_p4_change_reopen.func(candidates) "{{{
	" ********************************************************************************
	" チェンジリストの変更
	" action から実行した場合は、選択したファイルを変更する。
	" source から実行した場合は、開いたファイルを変更する。
	"
	" @param[in]	g:reopen_depots		選択したファイル
	" ********************************************************************************
	let chnum = a:candidates.action__chnum

	" 選択したファイルがない場合は、現在のファイルを使用する
	if !len(g:reopen_depots)
		let g:reopen_depots = a:candidates.action__path
	endif

	" チェンジリストの変更
	let outs = perforce#cmds('reopen -c '.chnum.' '.okazu#Get_kk(join(g:reopen_depots,'" "')))

	" Ignore
	let g:reopen_depots = [] 

	" ログの出力
	call perforce#pfLogFile(outs)
endfunction "}}}

let s:kind.action_table.a_p4_change_rename = {
			\  'description' : '名前の変更' 
			\ }
function! s:kind.action_table.a_p4_change_rename.func(candidates) "{{{
	let num = a:candidates.action__chnum
	let str = input('ChangeList Comment (change): ')
	let outs = perforce#pfChange(str,num)
	call perforce#pfLogFile(outs)
endfunction "}}}
