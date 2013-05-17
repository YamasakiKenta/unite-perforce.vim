let s:save_cpo = &cpo
set cpo&vim

function! s:init() "{{{
	if exists('s:init_flg')
		return
	else
		let s:init_flg = 1
	endif

	echo "load ..."
	let file_ = expand('~/.vim-unite-perforce')

	call s:perforce_init(file_)
	call s:perforce_add       ( 'g:unite_perforce_clients'                       ,'perforce clients'             , 'list_ex'       , {'nums' : [0,1], 'items' : ['-p localhost:1819', '-p localhost:2013']}) 
	call s:perforce_add       ( 'g:unite_perforce_diff_dw'                       ,'�󔒂𖳎�����'               , 'bool'          , 1)
	call s:perforce_add       ( 'g:unite_perforce_user_changes_only'             ,'���[�U�[���Ńt�B���^'         , 'bool'          , 1) 
	call s:perforce_add       ( 'g:unite_perforce_client_changes_only'           ,'�N���C�A���g�Ńt�B���^'       , 'bool'          , 1) 
	call s:perforce_add       ( 'g:unite_perforce_filters'                       ,'���O���X�g'                   , 'list_ex'       , {'nums' : [],    'items' : ['tag', 'snip']})
	call s:perforce_add       ( 'g:unite_perforce_show_max'                      ,'�t�@�C�����̐���'             , 'select'        , {'num'  : 0,     'items' : [0, 5, 10],                   'consts' : [0]})
	call s:perforce_add       ( 'g:unite_perforce_is_out_echo_flg'               ,'���s���ʂ��o�͂���'           , 'select'        , {'num'  : 0,     'items' : ['none', 'echo', 'log'],      'consts' : [-1]})
	call s:perforce_add       ( 'g:unite_perforce_show_cmd'                      ,'p4 �R�}���h��\������'        , 'select'        , {'num'  : 0,     'items' : ['none', 'echo', 'stop'],     'consts' : [-1]}) 
	call s:perforce_add       ( 'g:unite_perforce_diff_tool'                     ,'Diff �Ŏg�p����c�[��'        , 'select'        , {'num'  : 0,     'items' : ['vimdiff', 'WinMergeU'],     'consts' : [0]}) 
	call s:perforce_add       ( 'g:unite_perforce_is_submit_flg'                 ,'�T�u�~�b�g������'             , 'bool'          , 0) 
	call s:perforce_load()

	" �ݒ�l�Ŏ�ނ�I�ʂ���
	" bool -> 1 or 0
	" list_ex -> type(nums) = type([])
	" select  -> type(nums) = type(0)
	" const   -> const([])

	echo 'end...'

endfunction
"}}}

function! s:perforce_add(...) 
	return call('unite_setting_ex_3#add', extend(['g:unite_pf_data'] , a:000))
endfunction
function! s:perforce_init(...) 
	return call('unite_setting_ex_3#init', extend(['g:unite_pf_data'] , a:000))
endfunction
function! s:perforce_load(...) 
	return call('unite_setting_ex_3#load', extend(['g:unite_pf_data'] , a:000))
endfunction
function! perforce#data#get(valname, ...)
	call s:init()
	return unite_setting_ex_3#get('g:unite_pf_data', a:valname)
endfunction
function! perforce#data#setting() 
	call s:init()
	call unite#start([['settings_ex', 'g:unite_pf_data']])
endfunction


let &cpo = s:save_cpo
unlet s:save_cpo
