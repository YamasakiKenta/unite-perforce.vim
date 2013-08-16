let s:save_cpo = &cpo
set cpo&vim

function! s:_map_diff() "{{{
	map <buffer> <A-up>    [c
	map <buffer> <A-down>  ]c
	map <buffer> <A-left>  :diffget<CR>:<C-u>diffupdate<CR>|"
	map <buffer> <A-right> :diffget<CR>:<C-u>diffupdate<CR>|"
	map <buffer> <tab>     :<C-u>call _map_diff_tab()<CR>|"
	map <buffer> <F5>      :<C-u>diffupdate<CR>|"
endfunction
"}}}
function! s:_map_diff_reset() "{{{
	map <buffer> <A-up>    <A-up>
	map <buffer> <A-down>  <A-down>
	map <buffer> <A-left>  <A-left>
	map <buffer> <A-right> <A-right>
endfunction
"}}}
function! s:open_files(files) "{{{
	let files_ = a:files

	" 複数のファイルを別タグで開く
	exe 'tabe' files_[0]
	
	for file_ in files_[1:]
		exe 'sp' file_
	endfor
endfunction
"}}}
function! s:open_bufnrs(bufnrs) "{{{
	let bufnrs = a:bufnrs
	tabe
	" 最初の画面の更新
	exe 'b' bufnrs[0]

	" 2画面目からは、分割する
	for bufnr in bufnrs[1:]
		exe 'sb' bufnr
	endfor	
endfunction
"}}}
function! s:copy_wins() "{{{
	let bufnrs = []
	windo let bufnrs += [bufnr("%")]
	call s:open_bufnrs(bufnrs)
endfunction
"}}}
function! s:open_lines(datas) "{{{
	let datas = a:datas
	tabe

	" 最初の画面の更新
	call append(0, datas[0])
	call cursor(1,1)

	" 2画面目からは、分割する
	for lines in datas[1:]
		new
		call append(0, lines)
		call cursor(1,1)
	endfor	
endfunction
"}}}
function! s:tab_diff_start() "{{{
			call s:copy_wins()
			windo diffthis
			windo call s:_map_diff()
endfunction
"}}}
function! s:tab_diff_end() "{{{
			diffoff!
			windo call s:_map_diff_reset()
			tabc
endfunction
"}}}
function! s:tab_diff_orig() "{{{
	call s:copy_wins()
	only
	DiffOrig
	windo call s:_map_diff()
endfunction
"}}}

let &cpo = s:save_cpo
unlet s:save_cpo
