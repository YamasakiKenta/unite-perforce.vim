let s:save_cpo = &cpo
set cpo&vim

let s:V = vital#of('unite-perforce.vim')

function! unite#kinds#k_p4_filelog#define()
	return s:kind_filelog
endfunction

functio! s:p4_print(candidates) "{{{
	let filetype_old = &filetype

	for l:candidate in deepcopy(a:candidates)

		let name = perforce#get_path_from_depot(candidate.action__depot)

		" 表示するバージョンを取得する
		if exists('candidate.action__revnum')
			let file_numstr = '\#'.candidate.action__revnum
			let numstr      =  '#'.candidate.action__revnum
		elseif exists('candidate.action__chnum')
			let file_numstr =  '@'.candidate.action__chnum
			let numstr      =  '@'.candidate.action__chnum
		endif

		" ファイルを出力する
		let strs = perforce#pfcmds('print','','-q '.perforce#common#get_kk(name.''.numstr)).outs
		let file = fnamemodify(name,':t').file_numstr

		call perforce#common#LogFile(file, 0, strs) 
		call append(0, strs)

		" データの出力
		exe 'setf' filetype_old

	endfor
endfunction "}}}
" ********************************************************************************
" kind - k_p4_filelog
" ********************************************************************************
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
endfunction "}}}

let s:kind_filelog.action_table.a_p4_print_diff = {
			\ 'description' : 'ファイルの表示 ( ひとつ前のファイルと一緒 )',
			\ }
function! s:kind_filelog.action_table.a_p4_print_diff.func(candidates) "{{{
	let candidates = [copy(a:candidates), copy(a:candidates)]
	let candidates[1].action__revnum = candidates[1].action__revnum - 1
	echo candidates
	call input("")

	return s:p4_print(candidates)
endfunction "}}}

let s:kind_filelog.action_table.preview = {
			\ 'description' : 'preview' , 
			\ 'is_quit' : 0, 
			\ }
function! s:kind_filelog.action_table.preview.func(candidate) "{{{
	let l:candidate = a:candidate

	let name = perforce#get_path_from_depot(candidate.action__depot)

	let filetype_old = &filetype

	" 表示するバージョンを取得する
	if exists('candidate.action__revnum')
		let file_numstr = '\#'.candidate.action__revnum
		let numstr      =  '#'.candidate.action__revnum
	elseif exists('candidate.action__chnum')
		let file_numstr =  '@'.candidate.action__chnum
		let numstr      =  '@'.candidate.action__chnum
	endif

	" ファイルを出力する
	let strs = perforce#pfcmds('print','','-q '.perforce#common#get_kk(name.''.numstr)).outs
	let file = fnamemodify(name,':t').file_numstr

	call perforce#common#LogFile(file, 0, strs) 

	" データの出力
	"exe 'setf' filetype_old
	wincmd p

endfunction "}}}

if 1
	call unite#define_kind(s:kind_filelog)
endif

let &cpo = s:save_cpo
unlet s:save_cpo

