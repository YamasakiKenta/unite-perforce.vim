let s:save_cpo = &cpo
set cpo&vim

function! unite#kinds#k_p4_change#define()
	return [ 
				\ s:kind_k_p4_change_pending,
				\ s:kind_k_p4_change_reopen,
				\ ]
endfunction

" ********************************************************************************
" kind - k_p4_change_reopen
" ********************************************************************************
let s:kind_k_p4_change_reopen = {
			\ 'name' : 'k_p4_change_reopen',
			\ 'default_action' : 'a_p4_change_reopen',
			\ 'action_table' : {},
			\ 'parents' : ['k_p4'],
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
	let client        = a:candidate.action__client

	"チェンジリストの番号の取得
	let chnum = s:make_new_changes(a:candidate)

	" チェンジリストの変更
	let cmd = 'p4  '.client.' reopen -c '.chnum.' "'.join(reopen_depots,'" "').'"'
	call unite#print_message(cmd)
	let outs = split(system(cmd), "\n")

	" ログの出力
	call perforce#LogFile(outs)

endfunction
"}}}

" ********************************************************************************
" kind - k_p4_change_pending
" ********************************************************************************
let s:kind_k_p4_change_pending = { 
			\ 'name' : 'k_p4_change_pending',
			\ 'default_action' : 'a_p4_change_opened',
			\ 'action_table' : {},
			\ 'parents' : ['k_p4'],
			\ }

" 共通
let s:kind_k_p4_change_pending.action_table.delete = {
			\ 'description' : 'チェンジリストの削除' ,
			\ 'is_selectable' : 1,
			\ }
function! s:kind_k_p4_change_pending.action_table.delete.func(candidates) "{{{
	let i = 1
	for l:candidate in a:candidates
		let num    = l:candidate.action__chnum
		let client = l:candidate.action__client
		let out    = system('p4 '.client.' change -d '.num)
		let outs   = split(out,'\n')
		call perforce#LogFile(outs)
		let i += len(outs)
	endfor
endfunction
"}}}

"複数選択可能
let s:kind_k_p4_change_pending.action_table.a_p4_change_opened = { 
			\ 'description' : 'ファイルの表示',
			\ 'is_selectable' : 1, 
			\ 'is_quit' : 0,
			\ }
function! s:kind_k_p4_change_pending.action_table.a_p4_change_opened.func(candidates) "{{{

	let data_ds = []
	for candidate in a:candidates
		" チェンジリストの番号の取得をする
		let data_d= {
					\ 'chnum'  : s:make_new_changes(candidate),
					\ 'client' : candidate.action__client,
					\ }
		call add(data_ds, data_d)
	endfor

	" echo data_d

	echo 's:kind_k_p4_change_pending.action_table.a_p4_change_opened.func - ' string(data_ds)

	call unite#start_temporary([insert(data_ds, 'p4_opened')]) " # 閉じない ? 
endfunction
"}}}

let s:kind_k_p4_change_pending.action_table.a_p4_change_info = { 
			\ 'description' : 'チェンジリストの情報' ,
			\ 'is_selectable' : 1, 
			\ }
function! s:kind_k_p4_change_pending.action_table.a_p4_change_info.func(candidates) "{{{
	let outs = []
	for l:candidate in a:candidates
		let chnum = l:candidate.action__chnum
		let outs += split(system('P4 change -o '.chnum),'\n')
	endfor
	call perforce#LogFile(outs)
endfunction
"}}}

let s:kind_k_p4_change_pending.action_table.a_p4_change_submit = {
			\ 'description' : 'サブミット' ,
			\ 'is_selectable' : 1,
			\ }
function! s:kind_k_p4_change_pending.action_table.a_p4_change_submit.func(candidates) "{{{

	if perforce#data#get('g:unite_perforce_is_submit_flg') == 0
		call perforce_2#echo_error('safe mode.')
		call input("Push Any Keys...") 
	else
		let chnums = map(copy(a:candidates), "v:val.action__chnum")
		let tmp_ds = perforce#cmd#new('submit','',' -c '.join(chnums))
		let outs = []
		for tmp_d in tmp_ds
			call add(outs, tmp_d.cmd)
			call extend(outs, tmp_d.outs)
		endfor

		call perforce_2#common_action_out(outs)
	endif 

endfunction
"}}}

let s:kind_k_p4_change_pending.action_table.a_p4change_describe = { 
			\ 'description' : '差分の表示',
			\ 'is_selectable' : 1, 
			\ 'is_quit' : 0,
			\ }
function! s:kind_k_p4_change_pending.action_table.a_p4change_describe.func(candidates) "{{{
	let chnums = map(copy(a:candidates),"v:val.action__chnum")
 	call unite#start_temporary([insert(chnums,'p4_describe')])
endfunction
"}}}

let s:kind_k_p4_change_pending.action_table.a_p4_matomeDiff = { 
			\ 'description' : '差分のまとめを表示',
			\ 'is_selectable' : 1, 
			\ }
function! s:kind_k_p4_change_pending.action_table.a_p4_matomeDiff.func(candidates) "{{{
	for l:candidate in a:candidates
		let chnum = l:candidate.action__chnum
		call perforce#matomeDiffs(chnum)
	endfor
endfunction
"}}}
"
let s:kind_k_p4_change_pending.action_table.a_p4_change_reopen = {
			\ 'description' : 'チェンジリストの変更' ,
			\ } 
function! s:kind_k_p4_change_pending.action_table.a_p4_change_reopen.func(candidate) "{{{
	" ********************************************************************************
	" チェンジリストの変更
	" action から実行した場合は、選択したファイルを変更する。
	" source から実行した場合は、開いたファイルを変更する。
	" ********************************************************************************

	let reopen_depots = a:candidate.action__depots

	"チェンジリストの番号の取得
	let chnum = s:make_new_changes(a:candidate)

	" チェンジリストの変更
	let outs = perforce#cmd#base('reopen','',' -c '.chnum.' '.perforce#get_kk(join(reopen_depots,'" "'))).outs

	" ログの出力
	call perforce#LogFile(outs)

endfunction
"}}}

let s:kind_k_p4_change_pending.action_table.a_p4_change_rename = {
			\  'description' : '名前の変更' ,
			\ }
function! s:get_chname_from_change(str) "{{{
	let str = a:str
	let str = substitute(str, '.\{-}''', '', '')
	let str = substitute(str, '''$', '', '')
	return str
endfunction
"}}}
function! s:kind_k_p4_change_pending.action_table.a_p4_change_rename.func(candidate) "{{{
	let chnum = a:candidate.action__chnum
	let chname = s:get_chname_from_change(a:candidate.word)
	let chname = input(chname.'-> ', chname)

	" 入力がない場合は、実行しない
	if chname =~ ""
		let outs = s:pfChange(chname,chnum)
		call perforce#LogFile(outs)
	endif
endfunction
"}}}

if 1
	call unite#define_kind(s:kind_k_p4_change_pending)
	call unite#define_kind(s:kind_k_p4_change_reopen)
endif

"=== SUB ===
function! s:pfChange(str,...) "{{{
	"********************************************************************************
	" チェンジリストの作成
	" @param[in]	str		チェンジリストのコメント
	" @param[in]	...		編集するチェンジリスト番号
	"********************************************************************************
	"
	"チェンジ番号のセット ( 引数があるか )
	let chnum     = get(a:,'1','')

	"ChangeListの設定データを一時保存する
	let tmp = system('p4 change -o '.chnum)                          

	"コメントの編集
	let tmp = substitute(tmp,'\nDescription:\zs\_.*\ze\(\nFiles:\)\?','\t'.a:str.'\n','') 

	" 新規作成の場合は、ファイルを含まない
	if chnum == "" | let tmp = substitute(tmp,'\nFiles:\zs\_.*','','') | endif

	"一時ファイルの書き出し
	call writefile(split(tmp,'\n'),perforce#get_tmp_file())

	" チェンジリストの作成
	" ★ client に対応する
	let out = split(system('more '.perforce#get_kk(perforce#get_tmp_file()).' | p4 '.a:client.'change -i', '\n'))

	return out

endfunction
"}}}
function! s:make_new_changes(candidate) "{{{
" ********************************************************************************
" チェンジリストの番号の取得をする ( new の場合は、新規作成 )
" @param[in]	candidate	unite のあれ	
" @retval       chnum		番号
" ********************************************************************************

	let chnum = a:candidate.action__chnum

	if chnum == 'new'
		let chname = a:candidate.action__chname

		" チェンジリストの作成
		let outs = s:pfChange(chname)

		"チェンジリストの新規作成の結果から番号を取得する
		let chnum = outs[1]
	endif

	return chnum
endfunction
"}}}

let &cpo = s:save_cpo
unlet s:save_cpo

