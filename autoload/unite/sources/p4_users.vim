let s:save_cpo = &cpo
set cpo&vim
setl enc=utf8


function! unite#sources#p4_users#define()
	return s:source
endfunction


let s:source = {
			\ 'name' : 'p4_users',
			\ 'description' : 'ユーザーの切り替え',
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

let &cpo = s:save_cpo
unlet s:save_cpo

