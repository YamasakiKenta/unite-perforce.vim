function! unite#sources#p4_filelog#define()
	return s:source
endfunction

let s:source = { 
			\ 'name' : 'p4_filelog',
			\ 'description' : 'π',
			\ }
function! s:getRevisionNum(str) "{{{
	return substitute(copy(a:str), '.\{-}#\(\d\+\).*', '\1','g')
endfunction "}}}
function! s:source.gather_candidates(args, context) "{{{
	" ********************************************************************************
	" t@CΜππ\¦·ι
	" @param[in]	arg		\¦·ιπΜdepot
	" ********************************************************************************
	let candidates = []

	for arg in a:args 
		let lines = perforce#cmds('filelog '.okazu#Get_kk(arg))
		let candidates += map(lines, "{ 
					\ 'word' : v:val,
					\ 'kind' : 'k_p4_filelog', 
					\ 'action__revnum' : <SID>getRevisionNum(v:val),
					\ 'action__depot' : arg,
					\ }")
	endfor
	
	return candidates
endfunction "}}}
