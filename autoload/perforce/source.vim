let s:save_cpo = &cpo
set cpo&vim

function! s:get_args(default_key, args) "{{{
	" [2013-06-07 01:47]
	" ********************************************************************************
	" @par �����^�ɕϊ�����
	"
	" @param[in]     a:default_key
	"  - ���X�g�^�̏ꍇ�̏ꍇ�ɐݒ肵�����L�[
	"
	" @param[in]     args
	"  - �ϊ�����ϐ�
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
function! perforce#source#get_data_client(type, key, args) "{{{
	" [2013-06-07 01:47]
	" ********************************************************************************
	" @return        [{a:key : 0, 'use_port_clients' : ['']}]
	" ********************************************************************************
	let data_ds = s:get_args(a:key, a:args)

	let rtn_ds = []
	for data_d in data_ds
		let tmp_clients      = exists("data_d.client") ? [data_d.client] : []
		let key_data         = exists('data_d[a:key]') ? a:type.''.data_d[a:key] : ''
		let use_ports        = call('perforce#get#clients#get_use_ports'        , tmp_clients)
		let use_port_clients = call('perforce#get#clients#get_use_port_clients' , tmp_clients)

		call add(rtn_ds, {
					\ a:key              : key_data,
					\ 'use_ports'        : use_ports,
					\ 'use_port_clients' : use_port_clients,
					\ })
	endfor
	return rtn_ds
endfunction
"}}}

if exists('s:save_cpo')
	let &cpo = s:save_cpo
	unlet s:save_cpo
else
	set cpo&
endif
