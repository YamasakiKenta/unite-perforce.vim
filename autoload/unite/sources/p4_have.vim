let s:_file  = expand("<sfile>")
let s:_debug = vital#of('unite-perforce.vim').import("Mind.Debug")
let s:p4_have_cache = {}

function! s:get_datas_from_p4_have(str, reset_flg) "{{{
	" 空白の場合は、スペースを使用する
	let str = a:str
	"if str == ''
		"let str = ' '
	"endif 

	let port   = perforce#get_PFPORT()
	let client = perforce#get_PFCLIENTNAME()
	let key    = port.'_'.client.'_'.str

	let data_ds = {}
	if !has_key(s:p4_have_cache, key) || a:reset_flg == 0
		echo 'loading...'
		let datas = perforce#pfcmds_with_clients_from_data('have', '', str)
		let s:p4_have_cache[key] = s:get_candidates_from_pfhave(deepcopy(datas))
		echo 'finish !!'
	else
		echo 'cache load!'
	endif

	return s:p4_have_cache[key]
endfunction "}}}
function! s:get_candidates_from_pfhave(datas) "{{{
	let candidates = []
	for data in a:datas
		let client = data.client
		call extend(candidates, map( data.outs, "{
					\ 'word' : client.' : '.perforce#get_depot_from_have(v:val),
					\ 'kind' : 'k_depot',
					\ 'action__depot'  : perforce#get_depot_from_have(v:val),
					\ 'action__client' : client,
					\ }"))
	endfor
	return candidates
endfunction "}}}

function! unite#sources#p4_have#define()
	return [s:souce_p4have, s:souce_p4have_reset]
endfunction

let s:source = {
			\ 'name' : 'p4_have',
			\ 'description' : '所有するファイル',
			\ }
"********************************************************************************
"@param[in]	args		perforceから検索するファイル名
"********************************************************************************
function! s:source.gather_candidates(args, context) "{{{
	return s:get_datas_from_p4_have(join(a:args), 0)
endfunction "}}}
let s:souce_p4have = deepcopy(s:source)

let s:source = {
			\ 'name' : 'p4_have_reset',
			\ 'description' : '所有するファイル ( キャッシュを削除する ) ',
			\ }
"********************************************************************************
"@param[in]	args		perforceから検索するファイル名
"********************************************************************************
function! s:source.gather_candidates(args, context) "{{{
	return s:get_datas_from_p4_have(join(a:args), 1)
endfunction "}}}
let s:souce_p4have_reset = deepcopy(s:source)

