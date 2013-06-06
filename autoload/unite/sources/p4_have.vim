let s:save_cpo = &cpo
set cpo&vim

let s:p4_have_cache = {}

function! s:get_depot_from_have(str) 
	return matchstr(a:str,'.\{-}\ze#\d\+ - .*')
endfunction
function! s:get_candidates_from_pfhave(datas) "{{{
	let candidates = []
	for data in a:datas
		let client = data.client
		call extend(candidates, map( data.outs, "{
					\ 'word' : client.' : '.s:get_depot_from_have(v:val),
					\ 'kind' : 'k_depot',
					\ 'action__depot'  : s:get_depot_from_have(v:val),
					\ 'action__client' : client,
					\ }"))
	endfor
	return candidates
endfunction
"}}}
function! s:get_datas_from_p4_have(str, reset_flg) "{{{
	" 空白の場合は、スペースを使用する
	let str = a:str

	let port   = perforce#get#PFPORT()
	let client = perforce#get#PFCLIENTNAME()
	let key    = port.'_'.client.'_'.str

	let data_ds = {}
	if !has_key(s:p4_have_cache, key) || a:reset_flg == 1
		echo 'loading...'
		let datas = perforce#cmd#new('have', '', str)
		let s:p4_have_cache[key] = s:get_candidates_from_pfhave(deepcopy(datas))
		echo 'finish !!'
	else
		echo 'cache load!'
	endif

	return s:p4_have_cache[key]
endfunction
"}}}

function! unite#sources#p4_have#define()
	return [
				\ s:souce_p4have,
				\ s:souce_p4have_reset
				\ ]
endfunction

let s:souce_p4have = {
			\ 'name' : 'p4_have',
			\ 'description' : '所有するファイル',
			\ }
function! s:souce_p4have.gather_candidates(args, context) "{{{
	"********************************************************************************
	"@param[in]	args		perforceから検索するファイル名
	"********************************************************************************
	return s:get_datas_from_p4_have(join(a:args), 0)
endfunction
"}}}

let s:souce_p4have_reset = {
			\ 'name' : 'p4_have_reset',
			\ 'description' : '所有するファイル ( キャッシュを削除する ) ',
			\ }
function! s:souce_p4have_reset.gather_candidates(args, context) "{{{
	"********************************************************************************
	"@param[in]	args		perforceから検索するファイル名
	"********************************************************************************
	return s:get_datas_from_p4_have(join(a:args), 1)
endfunction
"}}}

let &cpo = s:save_cpo
unlet s:save_cpo

