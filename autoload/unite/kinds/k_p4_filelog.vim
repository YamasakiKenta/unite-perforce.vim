function! unite#kinds#k_p4_filelog#define()
	return s:kind
endfunction

" ********************************************************************************
" kind - k_p4_filelog
" ********************************************************************************
let s:kind = {
			\ 'name' : 'k_p4_filelog',
			\ 'default_action' : 'a_p4_print',
			\ 'action_table' : {},
			\ 'parents' : ['k_p4'],
			\ }

let s:kind.action_table.a_p4_print = {
			\ 'is_selectable' : 1, 
			\ 'description' : 'ファイルの表示',
			\ }
function! s:kind.action_table.a_p4_print.func(candidates) "{{{
	for l:candidate in deepcopy(a:candidates)

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
		let strs = perforce#pfcmds('print','','-q '.perforce#Get_kk(name.''.numstr))
		let file = fnamemodify(name,':t').file_numstr

		call perforce#LogFile1(file, 0, strs) 

		" データの出力
		exe 'setf' filetype_old

	endfor
endfunction "}}}

let s:kind.action_table.preview = {
			\ 'description' : 'preview' , 
			\ 'is_quit' : 0, 
			\ }
function! s:kind.action_table.preview.func(candidate) "{{{
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
	let strs = perforce#pfcmds('print','','-q '.perforce#Get_kk(name.''.numstr))
	let file = fnamemodify(name,':t').file_numstr

	call perforce#LogFile1(file, 0, strs) 

	" データの出力
	"exe 'setf' filetype_old
	wincmd p

endfunction "}}}
