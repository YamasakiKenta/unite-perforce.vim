function! unite#sources#p4_help#define()
	return s:source
endfunction

let s:source = {
			\ 'name' : 'p4_help',
			\ 'description' : 'ヘルプを表示',
			\ }
function! s:get_pfcmd_from_help(str) "{{{
	return substitute(a:str,'\t\(\w\+\) .*','\1','')
endfunction "}}}
function! s:source.gather_candidates(args, context) "{{{
	let datas = perforce#cmds('help commands')
	unlet datas[0:1]
	let candidates = map( datas, "{
				\ 'word' : substitute(v:val,'\t','',''),
				\ 'kind' : 'k_p4_help',
				\ 'action__cmd' : <SID>get_pfcmd_from_help(v:val),
				\ }")
	return candidates
endfunction "}}}
