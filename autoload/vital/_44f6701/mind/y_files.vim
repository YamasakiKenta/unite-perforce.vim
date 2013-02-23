let s:save_cpo = &cpo
set cpo&vim

function! s:get_files(...)
	if get(a:, 1, "") == ""
		let files_ = [expand("%:p")]
	else
		let files_ = a:000
	endif
	return files_
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
