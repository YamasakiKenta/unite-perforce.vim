let s:save_cpo = &cpo
set cpo&vim

function! s:get_chname_from_change(candidate, chnum, port_client) "{{{
	let cmd  = 'p4 '.a:port_client.' change -o '.a:chnum
	echo cmd
	let outs = split(system(cmd), "\n")

	let strs = []
	let description_flg = 0
	for out in outs
		if description_flg == 1
			if out =~ '^\t'
				let str = matchstr(out, '^\t\zs.*')
				call add(strs, str)
			else
				let description_flg = 0
				break
			endif
		elseif out =~ '^Description:'
			let description_flg = 1
		endif
	endfor

	return join(strs, "\n")
endfunction
"}}}
function! s:get_port_client(candidate) "{{{
	let out    = a:candidate.action__out
	let tmp = a:candidate.action__client

	if tmp =~ '-c'
		let port_client = tmp
	else
		let client = matchstr(out, '@\zs\S*')
		let port_client = tmp.' -c '.client
	endif

	return port_client
endfunction
"}}}
function! s:get_chnum(candidate) "{{{
	if exists('a:candidate.action__chnum') 
		let rtn = a:candidate.action__chnum
	else
		let rtn = matchstr(a:candidate.action__out, '.*change \zs\d*')
	endif
	return rtn
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
let s:kind_k_p4_change_pending.action_table.change_list_delete = {
			\ 'description' : 'チェンジリストの削除' ,
			\ 'is_selectable' : 1,
			\ }
function! s:kind_k_p4_change_pending.action_table.change_list_delete.func(candidates) "{{{
	let outs = []
	for candidate in a:candidates
		let chnum       = s:get_chnum(candidate)
		let port_client = s:get_port_client(candidate)
		let cmd = 'p4 '.port_client.' change -d '.chnum
		call extend(outs, split(system(cmd),'\n'))
	endfor
	call perforce#log_file(outs)
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
		let port_client = pf_changes#get_port_client(candidate)
		let data_d= {
					\ 'chnum'  : s:get_chnum(candidate),
					\ 'client' : port_client,
					\ }
		call add(data_ds, data_d)
	endfor

	call unite#start_temporary([insert(data_ds, 'p4_opened')]) " # 閉じない ? 
endfunction
"}}}

let s:kind_k_p4_change_pending.action_table.a_p4_change_info = { 
			\ 'description' : 'チェンジリストの情報' ,
			\ 'is_selectable' : 1, 
			\ }
function! s:kind_k_p4_change_pending.action_table.a_p4_change_info.func(candidates) "{{{
	let outs = []
	for candidate in a:candidates
		let chnum = s:get_chnum(candidate)
		let outs += split(system('P4 change -o '.chnum),'\n')
	endfor
	call perforce#log_file(outs)
endfunction
"}}}

let s:kind_k_p4_change_pending.action_table.a_p4_change_submit = {
			\ 'description' : 'サブミット' ,
			\ 'is_selectable' : 1,
			\ }
function! s:kind_k_p4_change_pending.action_table.a_p4_change_submit.func(candidates) "{{{

	if perforce#data#get('g:unite_perforce_is_submit_flg') == 0
		echoe 'safe mode.'
		call input("Push Any Keys...") 
	else
		let outs = []
		for candidate in a:candidates
			let port_client = s:get_port_client(candidate)
			let chnum = s:get_chnum(candidate)
			let cmd = 'p4 '.port_client.' submit -c '.chnum
			call unite#print_message(cmd)
			let outs = extend(outs, split(system(cmd), "\n"))
		endfor

		call perforce#log_file(outs)
	endif 

endfunction
"}}}

let s:kind_k_p4_change_pending.action_table.delete = { 
			\ 'description' : 'describe ( not delete )',
			\ 'is_selectable' : 1, 
			\ 'is_quit' : 0,
			\ }
function! s:kind_k_p4_change_pending.action_table.delete.func(candidates) "{{{
	let data_ds = []
	for candidate in a:candidates
		" チェンジリストの番号の取得をする
		let port_client = pf_changes#get_port_client(candidate)
		let data_d= {
					\ 'chnum'  : s:get_chnum(candidate),
					\ 'client' : port_client,
					\ }
		call add(data_ds, data_d)
	endfor
 	call unite#start_temporary([insert(data_ds,'p4_describe')])
endfunction
"}}}

let s:kind_k_p4_change_pending.action_table.a_p4_matomeDiff = { 
			\ 'description' : '差分のまとめを表示',
			\ 'is_selectable' : 1, 
			\ }
function! s:kind_k_p4_change_pending.action_table.a_p4_matomeDiff.func(candidates) "{{{
	for candidate in a:candidates
		let chnum = s:get_chnum(candidate)
		call perforce#matomeDiffs(chnum)
	endfor
endfunction
"}}}

let s:kind_k_p4_change_pending.action_table.edit = {
			\  'description' : '名前の変更' ,
			\ }
function! s:kind_k_p4_change_pending.action_table.edit.func(candidate) "{{{
	let chnum       = s:get_chnum(a:candidate)
	let port_client = pf_changes#get_port_client(a:candidate)
	let chname = s:get_chname_from_change(a:candidate, chnum, port_client)
	let chname = input(chname.'-> ', chname)
	if len(chname) > 0
		echo ' '
		let strs = split(chname, '\\n')
		call pf_changes#make(strs, port_client, chnum)
	endif
endfunction
"}}}

call unite#define_kind(s:kind_k_p4_change_pending)

if exists('s:save_cpo')
	let &cpo = s:save_cpo
	unlet s:save_cpo
endif
