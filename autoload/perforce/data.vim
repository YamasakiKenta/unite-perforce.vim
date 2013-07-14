let s:save_cpo = &cpo
set cpo&vim

function! s:init() "{{{
	if s:have_unite_setting() == 0
		return
	endif

	if exists('s:init_flg')
		return
	else
		let s:init_flg = 1
	endif

	echom "load ..."

	call s:perforce_init()

	call s:perforce_add( 'g:unite_perforce_ports_clients', {'nums' : [0,1], 'items' : ['auto', '-p localhost:1819', '-p localhost:2013'], 'consts' : [0] }) 
	call s:perforce_add( 'g:unite_perforce_clients'      , {'nums' : [0],   'items' : ['none', 'default', 'port_clients'], 'consts' : [-1] })
	call s:perforce_add( 'g:unite_perforce_filters'      , {'nums' : [0,1], 'items' : ['tag', 'snip']})
	call s:perforce_add( 'g:unite_perforce_show_max'     , {'nums' : [0],   'items' : [0, 5, 10],                   'consts' : [0]})
	call s:perforce_add( 'g:unite_perforce_diff_tool'    , {'nums' : [0],   'items' : ['vimdiff', 'WinMergeU'],     'consts' : [0]}) 
	call s:perforce_add( 'g:unite_perforce_username'     , {'nums' : [0,1], 'items' : ['user']}) 
	call s:perforce_add( 'g:unite_perforce_is_submit_flg', 0) 
	call s:perforce_add( 'g:pf_clients_template'         , {}) 
	call s:perforce_add( 'g:pf_var'                      , '') 
	call s:perforce_add( 'g:perforce_merge_default_path' , {'nums' : [0], 'items' : ['c:\tmp']})
	call s:perforce_add( 'g:perforce_tmp_dir'            , {'nums' : [0], 'items' : ["~/vimtmp"]})

	call s:perforce_load()

endfunction
"}}}

function! s:have_unite_setting() "{{{
	try
		return unite_setting_ex#version()
	catch
		echom 'not have unite_setting.vim...'
		return 0
	endtry
endfunction
"}}}

function! s:perforce_add(...) 
	return call('unite_setting_ex#data#add', extend(['g:unite_pf_data'] , a:000))
endfunction
function! s:perforce_init(...) 
	return call('unite_setting_ex#data#init', extend(['g:unite_pf_data'] , a:000))
endfunction
function! s:perforce_load(...) 
	return call('unite_setting_ex#data#load', extend(['g:unite_pf_data'] , a:000))
endfunction

function! perforce#data#get(valname) "{{{
	if s:have_unite_setting() == 0
		exe 'let tmp = '.a:valname
		return tmp
	else
		call s:init()
		return unite_setting_ex#data#get('g:unite_pf_data', a:valname)
	endif
endfunction
"}}}
function! perforce#data#setting()  "{{{
	if s:have_unite_setting() == 0
		return
	else
		call s:init()
		call unite#start([['settings_ex', 'g:unite_pf_data']])
	endif
endfunction
"}}}
"
" ˆø” ‚ÉŽg—p‚·‚éê‡‚Ì - ‚È‚Ç‚ðÝ’è‚·‚é
function! perforce#data#get_users() "{{{
	let users = perforce#data#get('g:unite_perforce_username')

	call map(users, "' -u '.v:val.' '")

	if len(users) == 0
		"let user = perforce#get#PFUSER()
		"let users = [user]
		let users = ['']
	endif

	return users
endfunction
"}}}
function! perforce#data#get_max() "{{{
	let max = perforce#data#get('g:unite_perforce_show_max')

	if max > 0 
		let max = '-m '.max.' '
	else
		let max = ''
	endif

	return max
endfunction
"}}}

function! perforce#data#get_clients(...) 
	return call('perforce#get#clients#get_clients', a:000)
endfunction
function! perforce#data#get_port_clients() 
	return call('perforce#get#clients#get_port_clients', a:000)
endfunction
function! perforce#data#get_ports(...) 
	return call('perforce#get#clients#get_ports', a:000)
endfunction
function! perforce#data#get_use_port_clients(...) 
	return call('perforce#get#clients#get_use_port_clients', a:000)
endfunction
function! perforce#data#get_use_ports(...) 
	return call('perforce#get#clients#get_use_ports', a:000)
endfunction

if exists('s:save_cpo')
	let &cpo = s:save_cpo
	unlet s:save_cpo
endif
