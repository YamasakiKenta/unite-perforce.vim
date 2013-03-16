let s:save_cpo = &cpo
set cpo&vim

let s:_file  = expand("<sfile>")


let s:_debug = vital#of('unite-perforce.vim').import("Mind.Debug")
"
function! unite#kinds#k_p4_change#define()
	return [ s:kind_k_p4_change, s:kind_k_p4_change_reopen ]
endfunction

" ********************************************************************************
" kind - k_p4_change_reopen
" ********************************************************************************
let s:kind = {
			\ 'name' : 'k_p4_change_reopen',
			\ 'default_action' : 'a_p4_change_reopen',
			\ 'action_table' : {},
			\ 'parents' : ['k_p4'],
			\ }

let s:kind.action_table.a_p4_change_reopen = {
			\ 'description' : 'チェンジリストの変更 ( reopen )' ,
			\ } 
function! s:kind.action_table.a_p4_change_reopen.func(candidate) "{{{
	" ********************************************************************************
	" チェンジリストの変更
	" action から実行した場合は、選択したファイルを変更する。
	" source から実行した場合は、開いたファイルを変更する。
	" ********************************************************************************

	let reopen_depots = a:candidate.action__depots

	"チェンジリストの番号の取得
	let chnum = s:make_new_changes(a:candidate)

	" チェンジリストの変更
	let outs = perforce#pfcmds('reopen','',' -c '.chnum.' '.perforce#common#get_kk(join(reopen_depots,'" "'))).outs

	" ログの出力
	call perforce#LogFile(outs)

endfunction "}}}

let s:kind_k_p4_change_reopen = s:kind
unlet s:kind

" ********************************************************************************
" kind - k_p4_change
" ********************************************************************************
let s:kind = { 'name' : 'k_p4_change',
			\ 'default_action' : 'a_p4_change_opened',
			\ 'action_table' : {},
			\ 'parents' : ['k_p4'],
			\ }

" 共通
let s:kind.action_table.delete = {
			\ 'description' : 'チェンジリストの削除' ,
			\ 'is_selectable' : 1,
			\ 'is_quit' : 0,
			\ }
function! s:kind.action_table.delete.func(candidates) "{{{
	let i = 1
	for l:candidate in a:candidates
		let num = l:candidate.action__chnum
		let out = system('p4 change -d '.num)
		let outs = split(out,'\n')
		call perforce#LogFile(outs)
		let i += len(outs)
	endfor
endfunction "}}}

"複数選択可能
let s:kind.action_table.a_p4_change_opened = { 
			\ 'description' : 'ファイルの表示',
			\ 'is_selectable' : 1, 
			\ 'is_quit' : 0,
			\ }
function! s:kind.action_table.a_p4_change_opened.func(candidates) "{{{

	let chnums = []
	for candidate in a:candidates
		" チェンジリストの番号の取得をする
		let chnums += [s:make_new_changes(candidate)]
	endfor

	call unite#start_temporary([insert(chnums,'p4_opened')]) " # 閉じない ? 
endfunction "}}}

let s:kind.action_table.a_p4_change_info = { 
			\ 'description' : 'チェンジリストの情報' ,
			\ 'is_selectable' : 1, 
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

let s:kind.action_table.a_p4_change_submit = {
			\ 'description' : 'サブミット' ,
			\ 'is_selectable' : 1,
			\ }
function! s:kind.action_table.a_p4_change_submit.func(candidates) "{{{

	if perforce#data#get('is_submit_flg') == 0
		call perforce_2#echo_error('safe mode.')
	else
		let chnums = map(copy(a:candidates), "v:val.action__chnum")
		let outs = perforce#pfcmds('submit','',' -c '.join(chnums)).outs
		echo outs
		call perforce#LogFile(outs)
	endif 

endfunction "}}}

let s:kind.action_table.a_p4change_describe = { 
			\ 'description' : '差分の表示',
			\ 'is_selectable' : 1, 
			\ 'is_quit' : 0,
			\ }
function! s:kind.action_table.a_p4change_describe.func(candidates) "{{{
	let chnums = map(copy(a:candidates),"v:val.action__chnum")
	call unite#start_temporary([insert(chnums,'p4_describe')])
endfunction "}}}

let s:kind.action_table.a_p4_matomeDiff = { 
			\ 'description' : '差分のまとめを表示',
			\ 'is_selectable' : 1, 
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
	" ********************************************************************************

	let reopen_depots = a:candidate.action__depots

	"チェンジリストの番号の取得
	let chnum = s:make_new_changes(a:candidate)

	" チェンジリストの変更
	let outs = perforce#pfcmds('reopen','',' -c '.chnum.' '.perforce#common#get_kk(join(reopen_depots,'" "'))).outs

	" ログの出力
	call perforce#LogFile(outs)

endfunction "}}}

let s:kind.action_table.a_p4_change_rename = {
			\  'description' : '名前の変更' ,
			\ 'is_quit' : 0,
			\ }
function! s:get_chname_from_change(str) "{{{
	let str = a:str
	let str = substitute(str, '.\{-}''', '', '')
	let str = substitute(str, '''$', '', '')
	return str
endfunction "}}}
function! s:kind.action_table.a_p4_change_rename.func(candidate) "{{{
	let chnum = a:candidate.action__chnum
	let chname = s:get_chname_from_change(a:candidate.word)
	let chname = input(chname.'-> ', chname)

	" 入力がない場合は、実行しない
	if chname =~ ""
		let outs = perforce#pfChange(chname,chnum)
		call perforce#LogFile(outs)
	endif
endfunction "}}}

let s:kind_k_p4_change = s:kind
unlet s:kind

" ********************************************************************************
" チェンジリストの番号の取得をする ( new の場合は、新規作成 )
" @param[in]	candidate	unite のあれ	
" @retval       chnum		番号
" ********************************************************************************
function! s:make_new_changes(candidate) "{{{

	let chnum = a:candidate.action__chnum

	if chnum == 'new'
		let chname = a:candidate.action__chname

		" チェンジリストの作成
		let outs = perforce#pfChange(chname)

		"チェンジリストの新規作成の結果から番号を取得する
		let chnum = perforce#get_ChangeNum_from_changes(outs[0])
	endif

	return chnum
endfunction "}}}


let &cpo = s:save_cpo
unlet s:save_cpo

