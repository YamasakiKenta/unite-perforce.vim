let s:save_cpo = &cpo
set cpo&vim

function! s:get_chname_from_change(str) "{{{
	let str = a:str
	let str = substitute(str, '.\{-}''', '', '')
	let str = substitute(str, '''$', '', '')
	return str
endfunction
"}}}

function! unite#kinds#k_p4_change_pending#define()
	return s:kind_k_p4_change_pending
endfunction

let s:kind_k_p4_change_pending = { 
			\ 'name'           : 'k_p4_change_pending',
			\ 'default_action' : 'a_p4_change_opened',
			\ 'action_table'   : {},
			\ 'parents'        : ['k_p4'],
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
					\ 'chnum'  : pf_changes#make_new_changes(candidate),
					\ 'client' : candidate.action__client,
					\ }
		call add(data_ds, data_d)
	endfor

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

let s:kind_k_p4_change_pending.action_table.a_p4_change_rename = {
			\  'description' : '名前の変更' ,
			\ }
function! s:kind_k_p4_change_pending.action_table.a_p4_change_rename.func(candidate) "{{{
	let chnum = a:candidate.action__chnum
	let chname = s:get_chname_from_change(a:candidate.word)
	let chname = input(chname.'-> ', chname)
endfunction
"}}}

call unite#define_kind(s:kind_k_p4_change_pending)

if exists('s:save_cpo')
	let &cpo = s:save_cpo
	unlet s:save_cpo
endif
