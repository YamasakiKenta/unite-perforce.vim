let s:save_cpo = &cpo
set cpo&vim

function! perforce_2#complate_have(A,L,P) "{{{
	"********************************************************************************
	" 補完 : perforce 上に存在するファイルを表示する
	"********************************************************************************
	let outs = split(system('p4 have //.../'.a:A.'...'), "\n")
	return map( copy(outs), "
				\ matchstr(v:val, '.*/\\zs.\\{-}\\ze\\#')
				\ ")
endfunction
"}}}
function! perforce_2#echo_error(message) "{{{
	echohl WarningMsg 
	echo a:message 
	echohl None
endfunction
"}}}
function! perforce_2#show(str) "{{{
	" ********************************************************************************
	" @par  必ず別windows を表示する
	" ********************************************************************************
	call perforce#util#log_file('p4show', 1, a:str)
endfunction
"}}}

function! s:get_args(default_key, args) "{{{
	" [2013-06-07 01:47]
	" ********************************************************************************
	" @par 辞書型に変換する
	"
	" @param[in]     a:default_key
	"  - リスト型の場合の場合に設定したいキー
	"
	" @param[in]     args
	"  - 変換する変数
	"
	" @return        data_ds
	" ********************************************************************************
	if len(a:args) == 0
		let data_ds = [{}]
	elseif type({}) == type(a:args[0])
		let data_ds = a:args
	else
		let data_ds = map(deepcopy(a:args), "{ a:default_key : v:val }")
	endif
	return data_ds
endfunction
"}}}
function! perforce_2#get_data_client(type, key, args) "{{{
	" [2013-06-07 01:47]
	" ********************************************************************************
	" @return        [{a:key : 0, 'use_port_clients' : ['']}]
	" ********************************************************************************
	let data_ds = s:get_args(a:key, a:args)

	let rtn_ds = []
	for data_d in data_ds
		let tmp_clients      = exists("data_d.client") ? [data_d.client] : []
		let key_data         = exists('data_d[a:key]') ? a:type.''.data_d[a:key] : ''
		let use_ports        = call('perforce#data#get_use_ports'        , tmp_clients)
		let use_port_clients = call('perforce#data#get_use_port_clients' , tmp_clients)

		call add(rtn_ds, {
					\ a:key              : key_data,
					\ 'use_ports'        : use_ports,
					\ 'use_port_clients' : use_port_clients,
					\ })
	endfor
	return rtn_ds
endfunction
"}}}
"
function! perforce_2#extend_dicts(key, ...) "{{{
	let rtns = []
	for dicts in a:000
		for dict in dicts
			call extend(rtns, dict[a:key])
		endfor
	endfor
	return rtns
endfunction
"}}}

function! perforce_2#system(cmd)
	return system(a:cmd)
endfunction

if exists('s:save_cpo')
	let &cpo = s:save_cpo
	unlet s:save_cpo
else
	set cpo&
endif
