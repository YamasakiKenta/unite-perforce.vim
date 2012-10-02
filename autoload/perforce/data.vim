let s:pf_settings_orders  = []
let g:pf_settings         = {}
let s:pf_settings_default = {}

"@ sub
function! s:data_load(file) "{{{
	" ********************************************************************************
	" �ݒ�t�@�C���̓ǂݍ���
	" param[in]		file		�ݒ�t�@�C����
	" ********************************************************************************


	" �t�@�C����������Ȃ��ꍇ�͏I��
	if !filereadable(a:file)
		echo 'Error - not fine '.a:file
		return
	endif

	exe 'let tmp_dicts = '.join(readfile(a:file))

	" ���݂���l�̂ݓo�^����
	for type in keys(tmp_dicts)
		for kind in keys(tmp_dicts[type])
			call perforce#data#set_orig( type, kind, tmp_dicts[type][kind])
		endfor
	endfor

endfunction "}}}
function! s:set_pf_settings_default(type, description, kind_type, kind_val ) "{{{
	" ********************************************************************************
	" pf_settings ��ǉ����܂�
	" ********************************************************************************
	" �\�����ɒǉ�
	let s:pf_settings_orders += [a:type]

	" �����l��ǉ�
	let s:pf_settings_default[a:type] = {
				\ 'common'      : a:kind_val,
				\ 'type'        : a:kind_type,
				\ 'description' : a:description,
				\ }

	let g:pf_settings[a:type] = {
				\ 'common'      : a:kind_val,
				\ 'type'        : a:kind_type,
				\ 'description' : a:description,
				\ }

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
		let rtns = copy(nums)
		call filter(rtns, "exists('a:datas[v:val]')")
		call map(rtns, "a:datas[v:val]")

	endif

	return rtns

endfunction "}}}
"@ main
function! perforce#data#init() "{{{
	" �ݒ�ϐ��̏�����
	call s:set_pf_settings_default ( 'is_submit_flg'            , '�T�u�~�b�g������'             , 'bool'   , 1                          )
	call s:set_pf_settings_default ( 'g_changes_only'           , '�t�B���^'                     , 'title'  , -1                         )
	call s:set_pf_settings_default ( 'user_changes_only'        , '���[�U�[���Ńt�B���^'         , 'bool'   , 1                          )
	call s:set_pf_settings_default ( 'client_changes_only'      , '�N���C�A���g�Ńt�B���^'       , 'bool'   , 1                          )
	call s:set_pf_settings_default ( 'filters_flg'              , '���O���X�g���g�p����'         , 'bool'   , 1                          )
	call s:set_pf_settings_default ( 'filters'                  , '���O���X�g'                   , 'strs' , [-1, 'tag', 'snip']          )
	call s:set_pf_settings_default ( 'g_show'                   , '�t�@�C����'                   , 'title'  , -1                         )
	call s:set_pf_settings_default ( 'show_max_flg'             , '�t�@�C�����̐���'             , 'bool'   , 0                          )
	call s:set_pf_settings_default ( 'show_max'                 , '�t�@�C����'                   , 'strs'   , [1, 5, 10]                 )
	call s:set_pf_settings_default ( 'g_is_out'                 , '���s����'                     , 'title'  , -1                         )
	call s:set_pf_settings_default ( 'is_out_flg'               , '���s���ʂ��o�͂���'           , 'bool'   , 1                          )
	call s:set_pf_settings_default ( 'is_out_echo_flg'          , '���s���ʂ��o�͂���[echo]'     , 'bool'   , 1                          )
	call s:set_pf_settings_default ( 'show_cmd_flg'             , 'p4 �R�}���h��\������'        , 'bool'   , 1                          )
	call s:set_pf_settings_default ( 'show_cmd_stop_flg'        , 'p4 �R�}���h��\������[stop]'  , 'bool'   , 1                          )
	call s:set_pf_settings_default ( 'g_diff'                   , 'Diff'                         , 'title'  , -1                         )
	call s:set_pf_settings_default ( 'is_vimdiff_flg'           , 'vimdiff ���g�p����'           , 'bool'   , 0                          )
	call s:set_pf_settings_default ( 'diff_tool'                , 'Diff �Ŏg�p����c�[��'        , 'strs' , [1, 'WinMergeU']             )
	call s:set_pf_settings_default ( 'g_ClientMove'             , 'ClientMove'                   , 'title'  , -1                         )
	call s:set_pf_settings_default ( 'ClientMove_recursive_flg' , 'ClientMove�ōċA���������邩' , 'bool'   , 0                          )
	call s:set_pf_settings_default ( 'ClientMove_defoult_root'  , 'ClientMove�̏����t�H���_'     , 'strs' , [1, 'c:\tmp', 'c:\p4tmp']    )
	call s:set_pf_settings_default ( 'g_other'                  , '���̑�'                       , 'title'  , -1                         )
	call s:set_pf_settings_default ( 'ports'                    , 'perforce port'                , 'strs' , [1, 'localhost:1818']        )
	call s:set_pf_settings_default ( 'users'                    , 'perforce user'                , 'strs' , [1, 'yamasaki']              )
	call s:set_pf_settings_default ( 'clients'                  , 'perforce client'              , 'strs' , [1, 'main']                  )

	" �ݒ��ǂݍ���
	call s:data_load($PFDATA)

endfunction "}}}
function! perforce#data#save(file) "{{{
	" ********************************************************************************
	" �ݒ�t�@�C����ۑ�����
	" param[in]		file		�ݒ�t�@�C����
	" ********************************************************************************

		call writefile([string(g:pf_settings)], a:file)

endfunction "}}}
"@ get
function! perforce#data#get(type, ...) "{{{
	" ********************************************************************************
	" �ݒ�f�[�^���擾����
	" @param[in]	type		pf_settings �̐ݒ�̎��
	" @param[in]	kind		common �Ȃ�, source �̎��
	" @retval		rtns 		�擾�f�[�^
	" ********************************************************************************
	
	if a:0 > 0 
		let kind = a:1
	else
		let kind = 'common'
	endif

	" �ݒ肪�Ȃ��ꍇ�́A���ʂ��Ăяo��
	let kind = perforce#data#get_kind(a:type, kind)

	if !exists("g:pf_settings[a:type][kind]")
		let g:pf_settings[a:type][kind] = s:pf_settings_default[a:type][kind]
	endif

	let val = g:pf_settings[a:type][kind]

	if type(val) == type([])
		" ���X�g�̏ꍇ�́A�����Ŏ擾����
		let rtns = s:get_pf_settings_from_lists(val)
	else
		let rtns = val
	endif


	return rtns
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
function! perforce#data#get_bits(type, kind) "{{{
	let tmp_data_d = perforce#data#get_orig(a:type, a:kind)

	" bit �̕ϊ�
	let tmp_num = tmp_data_d[0]
	let bits = []
	let num  = 1
	while ( tmp_num > 0 )
		call add(bits,  tmp_num % 2 ? num : 0)
		let tmp_num = tmp_num / 2
		let num = num * 2
	endwhile

	return bits

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

	return g:pf_settings[a:type][kind]

endfunction "}}}
"@ set
function! perforce#data#set(type, kind, val) "{{{
	let g:pf_settings[a:type][a:kind] = a:val
endfunction "}}}
function! perforce#data#set_orig(type, kind, val) "{{{
	"********************************************************************************
	" �l�����̂܂ܑ������
	" param[in]  str 		type 	
	" param[in]  str 		kind	
	" param[out] void* 	val 	
	"********************************************************************************
	if exists("g:pf_settings[a:type][a:kind]")
		let g:pf_settings[a:type][a:kind] = a:val
	endif
endfunction "}}}
function! perforce#data#set_bits(type, kind, val) "{{{
	" ********************************************************************************
	" �g�p����ӏ��̃t���O�𗧂Ă����̂�������
	" ********************************************************************************
	exe 'let sum = '.join(a:val, '+')
	call perforce#data#set_bits_orig(a:type, a:kind, sum)
endfunction "}}}
function! perforce#data#set_bits_orig(type, kind, val) "{{{
"********************************************************************************
" bits �����̂܂ܑ������
"********************************************************************************
	let g:pf_settings[a:type][a:kind][0] = a:val
endfunction "}}}
"@ delete
function! perforce#data#delete(type, kind, nums) "{{{
"********************************************************************************
" ��������ԍ����͂����Ă���z��ϐ���������
"********************************************************************************
	let type = a:type
	let kind = a:kind
	let nums = a:nums

	" ���ёւ�
	call sort(nums)

	" �ԍ��̎擾
	let datas = perforce#data#get_orig(type, kind)
	
	" �X�V
	let kind = perforce#data#get_kind(type, kind)

	" �I��ԍ��̎擾
	let bits = perforce#data#get_bits(type, kind)

	" �폜
	let cnt = 0
	let bitnum = 1
	for num in nums
		" �ԍ��̍X�V
		let tmp_num = num - cnt
		if exists('datas[tmp_num]')
			unlet datas[tmp_num]
		endif
		if exists('bits[tmp_num]')
			unlet bits[tmp_num]
		endif
		let cnt    = cnt + 1
		let bitnum = bitnum * 2
	endfor

	" �I��ԍ��̍Đݒ�
	call perforce#data#set_bits(type, kind, bits)

	" �ݒ�
	call perforce#data#set(type, kind, datas)

endfunction "}}}
