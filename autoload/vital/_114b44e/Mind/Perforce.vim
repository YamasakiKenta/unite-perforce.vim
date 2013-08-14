let s:save_cpo = &cpo
set cpo+=vim

function! s:get_client_root(...) "{{{
	if get(a:, '1', 0) != 0 || !exists('g:get_client_root_cache')
		" ¸”s‚Ìˆ×‚ÉA‰Šú‰»‚·‚é
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
function! s:get_client_root_from_client(client) "{{{
	let outs = filter(split(system('p4 '.a:client.' client -o'),"\n"), "v:val =~ '^Root:'")
	let rtn_d = {
				\ 'root'   : matchstr(outs[0], '^Root:\t\zs.*'),
				\ 'client' : matchstr(substitute(a:client, '\s\+', ' ', 'g'), '^\s*\zs\S.\{-}\ze\s*$')
				\ }
	return rtn_d
endfunction
"}}}

let &cpo = s:save_cpo
unlet s:save_cpo

