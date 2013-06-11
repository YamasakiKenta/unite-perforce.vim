let s:save_cpo = &cpo
set cpo&vim

function! unite#kinds#k_p4_filelog#define()
	return s:kind_filelog
endfunction

function! s:revision_num(str) "{{{
	return matchstr(a:str, '#\zs\d*')
endfunction 
"}}}
function! s:get_revnum_from_annotate(str) "{{{
	return matchstr(a:str,'\d\+')
endfunction 
"}}}
function! s:get_chnum_from_annotate_ai(str) "{{{
	let low  = substitute(a:str, '\(\d\+\)-\(\d\+\):.*', '\1', '')
	let high = substitute(a:str, '\(\d\+\)-\(\d\+\):.*', '\2', '')

	return {
				\ 'low' : low,
				\ 'high' : high,
				\ }
endfunction 
"}}}
function! s:p4_print(candidates) "{{{
	for candidate in deepcopy(a:candidates)
		let client = candidate.action__client
		let name   = candidate.action__path

		if candidate.action__cmd == 'filelog'
			let revnum = s:revision_num(candidate.action__out)
			let file_numstr = '\#'.revnum
			let numstr      =  '#'.revnum
		elseif candidate.action__cmd == 'annotate'
			let revnum = s:get_revnum_from_annotate(candidate.action__out)
			let file_numstr = '\#'.revnum
			let numstr      =  '#'.revnum
		elseif  candidate.action__cmd == 'describe'
			let revnum = candidate.action__revnum
			let file_numstr = '\#'.revnum
			let numstr      =  '#'.revnum
		endif

		if candidate.action__cmd == 'annotate -ai'
			let chnum = s:get_chnum_from_annotate_ai(candidate.action__out).low
			let file_numstr =  '@'.chnum
			let numstr      =  '@'.chnum
		endif

		" ファイルを出力する
		let cmd = 'p4 '.client.'print '. perforce#get_kk(name.''.numstr)
		call unite#print_message(cmd)
		echo cmd
		let strs = split(system(cmd), "\n")

		let file = fnamemodify(name,':t').''.file_numstr

		call perforce#util#LogFile(file, 0, strs) 
	endfor
endfunction
"}}}


let s:kind_filelog = {
			\ 'name' : 'k_p4_filelog',
			\ 'default_action' : 'a_p4_print',
			\ 'action_table' : {},
			\ 'parents' : ['k_p4'],
			\ }

let s:kind_filelog.action_table.a_p4_print = {
			\ 'description' : 'ファイルの表示',
			\ 'is_selectable' : 1, 
			\ }
function! s:kind_filelog.action_table.a_p4_print.func(candidates) "{{{
	return s:p4_print(a:candidates)
endfunction
"}}}

let s:kind_filelog.action_table.preview = {
			\ 'description' : 'preview' , 
			\ 'is_quit' : 0, 
			\ }
function! s:kind_filelog.action_table.preview.func(candidate) "{{{
endfunction
"}}}

	call unite#define_kind(s:kind_filelog)


if exists('s:save_cpo')
	let &cpo = s:save_cpo
	unlet s:save_cpo
endif
