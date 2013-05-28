let s:save_cpo = &cpo
set cpo&vim

let s:V = vital#of('unite-perforce.vim')

function! unite#kinds#k_p4_filelog#define()
	return s:kind_filelog
endfunction

functio! s:p4_print(candidates) "{{{
	let filetype_old = &filetype

	for l:candidate in deepcopy(a:candidates)

		let name = perforce#get#path#from_depot(candidate.action__depot)

		let revnum = s:revision_num(candidate.action__out)
		let file_numstr = '\#'.revnum
		let numstr      =  '#'.revnum

		if exists('candidate.action__chnum')
			let file_numstr =  '@'.candidate.action__chnum.low
			let numstr      =  '@'.candidate.action__chnum.low
		endif

		" ファイルを出力する
		let strs = perforce#cmd#base('print','','-q '.perforce#get_kk(name.''.numstr)).outs
		let file = fnamemodify(name,':t').file_numstr

		call perforce#util#LogFile(file, 0, strs) 

		" データの出力
		exe 'setf' filetype_old

	endfor
endfunction
"}}}
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
endfunction
"}}}

let s:kind_filelog.action_table.preview = {
			\ 'description' : 'preview' , 
			\ 'is_quit' : 0, 
			\ }
function! s:kind_filelog.action_table.preview.func(candidate) "{{{
	let l:candidate = a:candidate

	let name = perforce#get#path#from_depot(candidate.action__depot)

	let filetype_old = &filetype
	let revnum = s:revision_num(candidate.action__out)
	let file_numstr = '\#'.revnum
	let numstr      =  '#'.revnum

	" 表示するバージョンを取得する
	if exists('candidate.action__chnum')
		echo 'USE CHSNGE'
		let @" = 's:kind_filelog.action_table.preview.func'
		call input("")
		let file_numstr =  '@'.candidate.action__chnum
		let numstr      =  '@'.candidate.action__chnum
	endif

	" ファイルを出力する
	let strs = perforce#cmd#base('print','','-q '.perforce#get_kk(name.''.numstr)).outs
	let file = fnamemodify(name,':t').file_numstr

	call perforce#util#LogFile(file, 0, strs) 

	" データの出力
	"exe 'setf' filetype_old
	wincmd p

endfunction
"}}}

if 1
	call unite#define_kind(s:kind_filelog)
endif

function! s:revision_num(str) "{{{
	return matchstr(a:str, '#\zs\d*')
endfunction 
"}}}


if exists('s:save_cpo')
	let &cpo = s:save_cpo
	unlet s:save_cpo
endif
