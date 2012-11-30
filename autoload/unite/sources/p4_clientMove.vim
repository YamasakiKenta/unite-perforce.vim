let s:save_cpo = &cpo
set cpo&vim


function! unite#sources#p4_clientMove#define()
	return s:source
endfunction

let s:source = {
			\ 'name' : 'p4_clientMove',
			\ 'description' : '特定のフォルダからファイルを比較する',
			\ }
function! s:source.gather_candidates(args, context) "{{{
	return map( a:args, "{
				\ 'word' : v:val.file1.' - '.v:val.file2,
				\ 'kind' : 'k_p4_clientMove',
				\ 'action__file1' : v:val.file1,
				\ 'action__file2' : v:val.file2,
				\ }")
endfunction "}}}

let &cpo = s:save_cpo
unlet s:save_cpo

