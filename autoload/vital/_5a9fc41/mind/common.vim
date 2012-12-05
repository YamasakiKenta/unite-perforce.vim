let s:save_cpo = &cpo
set cpo&vim

function! s:_len_compara(i1, i2) "{{{
	let l1 = len(a:i1)
	let l2 = len(a:i2)
	"return l1 == l2 ? 0 : l1 > l2 ? 1 : -1
	return l1 == l2 ? 0 : l1 < l2 ? 1 : -1
endfunction
"}}}

function! s:get_list(tmp) "{{{
	return (type(a:tmp) == type([])) ? a:tmp : [a:tmp]
endfunction "}}}
function! s:set_dict_extend(dict1, dict2) "{{{
	" 同じキーがある場合は、リストで結合して返す
	
	" 大きい方をdict1 に設定する
	"let [dict1, dict2] = ( len(a:dict1) > len(a:dict2) ) ? [a:dict1, a:dict2] : [a:dict2, a:dict1]
	let [dict1, dict2] = [a:dict1, a:dict2]

	" a:dict1 を優先させる
	let dict_new = dict1
	for key in keys(dict2)
		let dict_new[key] = exists('dict_new[key]') ? extend(s:get_list(a:dict1[key]), s:get_list(a:dict2[key])) : dict2[key]
	endfor

	return dict_new
endfunction
"}}}
function! s:get_fname_key(file_d, fname_full) "{{{
	let file_d    = a:file_d
	let fname_tmp  = substitute(a:fname_full, '\\', '\/', 'g')

	while len(fname_tmp) && !exists('file_d[fname_tmp]')
		let fname_tmp  = matchstr(fname_tmp, '.\{-}[\/\\]\zs.*')
	endwhile
	return fname_tmp
endfunction
"}}}
function! s:get_len_sort(lists) "{{{
	return sort(a:lists, "s:_len_compara")
endfunction
"}}}
function! s:save(name, dict) "{{{
	let lines = [
				\ 'if exists("g:tmp") | unlet g:tmp | endif',
				\ 'let g:tmp = '.string(dict),
				\ ]
	call writefile(lines, a:name)
endfunction
"}}}
function! s:load(name, default) "{{{
	if filereadable(a:name)
		exe 'so '.a:name
	endif

	return get(g:, 'tmp', a:default)
endfunction
"}}}
function! s:get_pathSrash(path) "{{{
	return substitute(a:path,'\','/','g') " # / マークに統一
endfunction "}}}

let &cpo = s:save_cpo
unlet s:save_cpo
