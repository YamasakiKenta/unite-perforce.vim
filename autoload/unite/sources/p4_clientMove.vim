function! unite#sources#p4_clientMove#define()
	return s:source
endfunction

let s:source = {
			\ 'name' : 'p4_clientMove',
			\ 'description' : '����̃t�H���_����t�@�C�����r����',
			\ }
function! s:source.gather_candidates(args, context) "{{{
	let rtns = map( g:merges, "{
				\ 'word' : v:val.file1.' - '.v:val.file2,
				\ 'kind' : 'k_p4_clientMove',
				\ 'action__file1' : v:val.file1,
				\ 'action__file2' : v:val.file2,
				\ }")

	unlet g:merges

	return rtns
endfunction "}}}
