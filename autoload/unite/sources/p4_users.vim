function! unite#sources#p4_users#define()
	return s:source
endfunction


let s:source = {
			\ 'name' : 'p4_users',
			\ 'description' : 'ƒ†[ƒU[‚ÌØ‚è‘Ö‚¦',
			\ }
function! s:get_UserName_from_users(str) "{{{
	return substitute(a:str,'\(.\{-}\) <.*','\1','')
endfunction "}}}
function! s:source.gather_candidates(args, context) "{{{
	let datas = perforce#pfcmds('users','').outs
	let candidates = map( datas, "{
				\ 'word' : v:val,
				\ 'kind' : 'k_p4_users',
				\ 'action__user' : s:get_UserName_from_users(v:val),
				\ }")
	return candidates
endfunction "}}}
