let s:save_cpo = &cpo
set cpo+=vim

function! s:get_client_root(...) "{{{
	if get(a:, '1', 0) != 0 || !exists('g:get_client_root_cache')
		" 失敗時の為に、初期化する
		let g:get_client_root_cache = ""
		let lines = split(system('p4 info'), "\n")
		let word = '^Client root: '
		for line in lines 
			if line =~ word
				let g:get_client_root_cache = matchstr(line, word.'\zs.*')
				break
			endif
		endfor
	endif
	return g:get_client_root_cache
endfunction
"}}}
"
let &cpo = s:save_cpo
unlet s:save_cpo
