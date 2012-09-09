let s:save_data_type = 1 " �V����
function! s:set_pf_settings(type, description, kind_val ) "{{{
	" ********************************************************************************
	" pf_settings ��ǉ����܂�
	" ********************************************************************************
	" �\�����ɒǉ�
	let s:pf_settings_orders += [a:type]

	let g:pf_settings[a:type] = {
				\ 'common' : a:kind_val,
				\ 'description' : a:description,
				\ }

endfunction "}}}
function! s:data_load(file) "{{{
	" ********************************************************************************
	" �ݒ�t�@�C���̓ǂݍ���
	" param[in]		file		�ݒ�t�@�C����
	" ********************************************************************************

	" �t�@�C����������Ȃ��ꍇ�͏I��
	if filereadable(a:file) == 0
		echo 'Error - not fine '.a:file
		return
	endif

	if s:save_data_type == 0
		" �t�@�C����ǂݍ���
		let datas = readfile(a:file.'_1')

		" �f�[�^��ݒ肷��
		for data in datas
			let tmp = split(data,"\t")
			exe 'let g:pf_settings["'.join(tmp[0:-2],'"]["').'"] = '.tmp[-1]

			" �^���ς�邽�߁A���������K�v
		endfor
	else
		exe 'let g:pf_settings = '.join(readfile(a:file.'_2'))
	endif

endfunction "}}}
function! s:get_pf_settings_from_lists(datas) "{{{
	" ********************************************************************************
	" BIT ���Z�ɂ���āA�f�[�^���擾����
	" @param[in]	datas	{ bit, ������, ... } 
	" @retval   	rtns 	���X�g��Ԃ�
	" ********************************************************************************

	if a:datas[0] < 0
		" �S���Ԃ�
		let rtns = a:datas[1:]
	else
		" �L���ȃ��X�g�̎擾 ( ��ڂ́A�t���O�������Ă��邽�߃X�L�b�v���� )
		let nums = perforce#common#bit#get_nums_form_bit(a:datas[0]*2)

		" �L���Ȉ����̂ݕԂ�
		let rtns = map(copy(nums), 'a:datas[v:val]')

	endif

	return rtns

endfunction "}}}
"@ main
function! perforce#data#init() "{{{
	" ********************************************************************************
	" �ݒ�ϐ��̏�����
	" ********************************************************************************

	if exists('g:pf_settings')
		return
	else
		" init
		let g:pf_settings = {}
		let s:pf_settings_orders = []

		" ���ёւ��p�̕ϐ��̍쐬
		call s:set_pf_settings ( 'is_submit_flg'            , '�T�u�~�b�g������'            , 1                         ) 
		call s:set_pf_settings ( 'g_changes_only'           , '�t�B���^'                    , -1                        ) 
		call s:set_pf_settings ( 'user_changes_only'        , '���[�U�[���Ńt�B���^'        , 1                         ) 
		call s:set_pf_settings ( 'client_changes_only'      , '�N���C�A���g�Ńt�B���^'      , 1                         ) 
		call s:set_pf_settings ( 'filters_flg'              , '���O���X�g���g�p����'        , 1                         )
		call s:set_pf_settings ( 'filters'                  , '���O���X�g'                  , [-1,'tag','snip']         ) 
		call s:set_pf_settings ( 'g_show'                   , '�t�@�C����'                  , -1                        ) 
		call s:set_pf_settings ( 'show_max_flg'             , '�t�@�C�����̐���'            , 0                         ) 
		call s:set_pf_settings ( 'show_max'                 , '�t�@�C����'                  , [1,5,10]                  ) 
		call s:set_pf_settings ( 'g_is_out'                 , '���s����'                    , -1                        ) 
		call s:set_pf_settings ( 'is_out_flg'               , '���s���ʂ��o�͂���'          , 1                         ) 
		call s:set_pf_settings ( 'is_out_echo_flg'          , '���s���ʂ��o�͂���[echo]'    , 1                         ) 
		call s:set_pf_settings ( 'show_cmd_flg'             , 'p4 �R�}���h��\������'       , 1                         ) 
		call s:set_pf_settings ( 'show_cmd_stop_flg'        , 'p4 �R�}���h��\������(stop)' , 1                         ) 
		call s:set_pf_settings ( 'g_diff'                   , 'Diff'                        , -1                        ) 
		call s:set_pf_settings ( 'is_vimdiff_flg'           , 'vimdiff ���g�p����'          , 0                         ) 
		call s:set_pf_settings ( 'diff_tool'                , 'Diff �Ŏg�p����c�[��'       , [1,'WinMergeU']           ) 
		call s:set_pf_settings ( 'g_ClientMove'             , 'ClientMove'                  , -1                        ) 
		call s:set_pf_settings ( 'ClientMove_recursive_flg' , 'ClientMove�ōċA���������邩', 0                         ) 
		call s:set_pf_settings ( 'ClientMove_defoult_root'  , 'ClientMove�̏����t�H���_'    , [1,'c:\tmp','c:\p4tmp']   ) 
		call s:set_pf_settings ( 'g_other'                  , '���̑�'                      , -1                        ) 
		call s:set_pf_settings ( 'ports'                    , 'perforce port'               , [1,'localhost:1818']      ) 

		" �ݒ��ǂݍ���
		call s:data_load($PFDATA)

		" �N���C�A���g�f�[�^�̓ǂݍ���
		call perforce#get_client_data_from_info()

	endif
endfunction "}}}
function! perforce#data#set(type, kind, val) "{{{
	let g:pf_settings[a:type][a:kind] = a:val
endfunction "}}}
function! perforce#data#delete(type, kind, val) "{{{
	let g:pf_settings[a:type][a:kind] = a:val
endfunction "}}}
function! perforce#data#set_list(type, kind, val) "{{{
	let g:pf_settings[a:type][a:kind][0] = a:val
endfunction "}}}
function! perforce#data#get_orig(type, kind) "{{{
	" ********************************************************************************
	" �ݒ�f�[�^���擾����
	" @param[in]	type		pf_settings �̐ݒ�̎��
	" @param[in]	kind		common �Ȃ�, source �̎��
	" @retval		rtns 		�擾�f�[�^
	" ********************************************************************************
	" �ݒ肪�Ȃ��ꍇ�́A���ʂ��Ăяo��
	let kind = perforce#data#get_kind(a:type, a:kind)

	let val = g:pf_settings[a:type][kind]

	let valtype = type(val)

	let rtns = {
				\ 'datas' : val,
				\ 'kind' : kind,
				\ }

	return rtns
endfunction "}}}
function! perforce#data#get(type, kind) "{{{
	" ********************************************************************************
	" �ݒ�f�[�^���擾����
	" @param[in]	type		pf_settings �̐ݒ�̎��
	" @param[in]	kind		common �Ȃ�, source �̎��
	" @retval		rtns 		�擾�f�[�^
	" ********************************************************************************
	" �ݒ肪�Ȃ��ꍇ�́A���ʂ��Ăяo��
	let kind = perforce#data#get_kind(a:type, a:kind)

	let val = g:pf_settings[a:type][kind]

	let valtype = type(val)

	let rtns = {}
	if valtype == 3
		" ���X�g�̏ꍇ�́A�����Ŏ擾����
		let rtns.datas = s:get_pf_settings_from_lists(val)
	else
		let rtns.datas = val
	endif

	let rtns.kind = kind

	return rtns
endfunction "}}}
function! perforce#data#save(file) "{{{
	" ********************************************************************************
	" �ݒ�t�@�C����ۑ�����
	" param[in]		file		�ݒ�t�@�C����
	" ********************************************************************************

	if s:save_data_type == 0
		let datas = []

		for type in keys(g:pf_settings)
			for val in keys(g:pf_settings[type])
				if val != 'description'
					let datas += [type."\t".val."\t".string(g:pf_settings[type][val])."\r"]
				endif
			endfor
		endfor


		" ��������
		call writefile(datas, a:file.'_1')
	else
		call writefile([string(g:pf_settings)], a:file.'_2')
	endif

endfunction "}}}
function! perforce#data#get_orders() "{{{
	"********************************************************************************
	" unite �ŕ\������f�[�^
	"********************************************************************************
	return s:pf_settings_orders
endfunction "}}}
function! perforce#data#get_kind(type, kind) "{{{
	if exists('g:pf_settings[a:type][a:kind]')
		let kind = a:kind
	else
		let kind = 'common'
	endif

	return kind
endfunction "}}}
