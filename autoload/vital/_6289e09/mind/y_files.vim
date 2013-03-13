let s:save_cpo = &cpo
set cpo&vim

function! s:get_files(...) "{{{
	return get(a:, 1, "") == "" ? [expand("%:p")] : a:000
endfunction
"}}}

let &cpo = s:save_cpo
unlet s:save_cpo
