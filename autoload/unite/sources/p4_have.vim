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
	let candidates = []

	let port_clients = perforce#get#clients#get_use_port_clients()

	for port_client in port_clients
		if !exists('s:p4_have_cache[port_client]') || a:reset_flg == 1
			let datas = perforce#cmd#clients([port_client], 'p4 have '.str)
			let s:p4_have_cache[port_client] = s:get_candidates_from_pfhave(deepcopy(datas))
		endif

		call extend(candidates, s:p4_have_cache[port_client])
	endfor

	return candidates
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

if exists('s:save_cpo')
	let &cpo = s:save_cpo
	unlet s:save_cpo
else
	set cpo&
endif
