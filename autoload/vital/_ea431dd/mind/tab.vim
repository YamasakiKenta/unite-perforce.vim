let s:save_cpo = &cpo
set cpo&vim

function! s:open_files(files) "{{{
	let files_ = a:files

	" 複数のファイルを別タグで開く
	exe 'tabe' files_[0]
	
	for file_ in files_[1:]
		exe 'sp' file_
	endfor
endfunction "}}}
function! s:open_bufnrs(bufnrs) "{{{
	let bufnrs = a:bufnrs
	tabe
	" 最初の画面の更新
	exe 'b' bufnrs[0]

	" 2画面目からは、分割する
	for bufnr in bufnrs[1:]
		exe 'sb' bufnr
	endfor	
endfunction "}}}
function! s:copy_wins() "{{{
	let bufnrs = []
	windo let bufnrs += [bufnr("%")]
	call s:open_bufrnrs(bufnrs)
endfunction "}}}
function! s:open_lines(datas) "{{{
	let datas = a:datas
	tabe

	" 最初の画面の更新
	exe 'b' datas[0]

	" 2画面目からは、分割する
	for lines in datas[1:]
		sp
		call append(0, lines)
	endfor	
endfunction "}}}

let &cpo = s:save_cpo
unlet s:save_cpo
