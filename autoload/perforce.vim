let s:save_cpo = &cpo
set cpo&vim

function! s:get_path_from_where(str) "{{{
	return matchstr(a:str, '.\{-}\zs\w*:.*\ze\n.*')
endfunction
"}}}
function! s:is_p4_have_from_have(str) "{{{

	if a:str =~ '- file(s) not on client.'
		let flg = 0
	else
		let flg = 1
	endif

	return flg

endfunction
"}}}

function! perforce#get_tmp_file() "{{{
	let g:perforce_tmp_dir  = get(g:, 'perforce_tmp_dir', '~/.perforce/' )
	let fname               = g:perforce_tmp_dir.'/tmpfile'

	if !isdirectory(g:perforce_tmp_dir)
		call mkdir(g:perforce_tmp_dir)
	endif

	return fname
endfunction
"}}}
function! perforce#get_dd(str) "{{{
	return len(a:str) ? '//...'.perforce#common#get_kk(a:str).'...' : ''
endfunction
"}}}
function! perforce#LogFile(str) "{{{
	" ********************************************************************************
	" ���ʂ̏o�͂��s��
	" @param[in]	str		�\�����镶��
	" ********************************************************************************

	let cmd_ = perforce#data#get('g:unite_perforce_is_out_echo_flg', 'common')
	echo 'perforce#LogFile >>>>'
	if cmd_ == 'echo'
		let strs = (type(a:str) == type([])) ? a:str :[a:str]

		for str in strs
			echo str
		endfor

	elseif cmd_ == 'log'
		call perforce#common#LogFile('p4log', 0, a:str)
	endif
	echo 'perforce#LogFile <<<<'


endfunction
"}}}
function! perforce#init() "{{{

	" �N���C�A���g�f�[�^�̓ǂݍ���
	call perforce#get#PFCLIENTPATH()

	" �ݒ�̎擾
	call perforce#data#init()
endfunction
"}}}
function! perforce#matomeDiffs(...) "{{{
	" new file �p�ɂ����ŏ�����
	let datas = []

	echo 'perforce#matomeDiffs -> ' string(a:000)
	for chnum in a:000
		" �f�[�^�̎擾 {{{
		let outs = perforce#cmd#base('describe -ds','',chnum).outs

		" ��ƒ��̃t�@�C��
		if outs[0] =~ '\*pending\*' || chnum == 'default'
			let files = perforce#cmd#base('opened','','-c '.chnum).outs
			call map(files, "perforce#get#depot#from_opened(v:val)")

			let outs = []
			for file in files 
				let list_tmps = perforce#cmd#base('diff -ds','',file).outs

				for list_tmp in list_tmps
					if list_tmp =~ '- file(s) not opened for edit.'
						let file_tmp = substitute(file, '.*[\/]','','')
						let path = perforce#get#path#from_depot(file)
						let datas += [{'files' : file_tmp, 'adds' : len(readfile(path)), 'changeds' : 0, 'deleteds' : 0, }]
					else
						let outs += [list_tmp]
					endif
				endfor
			endfor


		endif

		let find = ' \(\d\+\) chunks \(\|\(\d\+\) / \)\(\d\+\) lines'
		for out in outs
			if out =~ "===="
				let datas += [{'files' : substitute(out,'.*/\(.\{-}\)#.*','\1',''), 'adds' : 0, 'changeds' : 0, 'deleteds' : 0, }]
			elseif out =~ 'add'.find
				let datas[-1].adds = substitute(out,'add'.find,'\4','')
			elseif out =~ 'deleted'.find
				let datas[-1].deleteds = substitute(out,'deleted'.find,'\4','')
			elseif out =~ 'changed'.find
				let a = substitute(out,'changed'.find,'\3','')
				let b = substitute(out,'changed'.find,'\4','')
				let datas[-1].changeds = a > b ? a : b
			endif
		endfor
	endfor
	"}}}
	"
	"�f�[�^�̏o�� {{{
	let outs = []
	for data in datas 
		let outs += [data["files"]."\t\t".data["adds"]."\t".data["deleteds"]."\t".data["changeds"]]
	endfor

	call perforce#common#LogFile('p4log', 0, outs)
	"}}}
endfunction
"}}}
function! perforce#pfFind(...) "{{{
	if a:0 == 0
		let str  = input('Find : ')
	else
		let str = a:1
	endif 
	if str !=# ""
		call unite#start([insert(map(split(str),"perforce#get_dd(v:val)"),'p4_have')])
	endif
endfunction
"}}}
function! perforce#unite_args(source) "{{{
	"********************************************************************
	" @par          ���݂̃t�@�C������ Unite �Ɉ����ɓn���܂��B
	" @param[in]	source	�R�}���h
	"********************************************************************

		" �X�y�[�X�΍�
		let file_ = expand("%:p")
		let file_ = substitute(file_ , '\\' , '\/'  , 'g')
		let file_ = substitute(file_ , ':'  , '\\:' , 'g')
		let file_ = substitute(file_ , ' '  , '\\ ' , 'g')

		let cmd = 'Unite '.a:source.':'.file_
		exe cmd

endfunction
"}}}

function! s:is_p4_have(str) "{{{
	" ********************************************************************************
	" �N���C�A���g�Ƀt�@�C�������邩���ׂ�
	" @param[in]	str				�t�@�C���� , have �̕Ԃ�l
	" @retval       flg		TRUE 	���݂���
	" @retval       flg		FLASE 	���݂��Ȃ�
	" ********************************************************************************
	let str = system('p4 have '.perforce#common#get_kk(a:str))
	return s:is_p4_have_from_have(str)
endfunction
"}}}
function! perforce#is_p4_haves(files) "{{{
	" ********************************************************************************
	" �N���C�A���g�Ƀt�@�C�������邩���ׂ�
	" @param[in]	files[] = '' - file name
	"
	" @return rtns_d
	" .true[]  = '' - have file name 
	" .false[] = '' - not have file name
	" ********************************************************************************
	let rtns_d = {
				\ 'true'  : [],
				\ 'false' : [],
				\ }

	for file_ in a:files
		let type = ( s:is_p4_have(file_) == 1 ) ? 'true' : 'false'
		call add(rtns_d[type], file_)
	endfor

	return rtns_d
endfunction
"}}}
function! perforce#is_p4_haves_client2(files) "{{{
	" ********************************************************************************
	" �N���C�A���g�Ƀt�@�C�������邩���ׂ�
	" @param[in]	files[] = '' - file name
	"
	" @return rtns_d
	" true.{client}[]    = '' -     have file name 
	" false.{client}[]   = '' - not have file name
	"
	" @par  2013/05/05
	" ********************************************************************************
	"
	let clients = perforce#get#clients()
	echo "perforce#is_p4_haves_client2 ->" clients
	let rtn_client_d = {}

	let rtns_d = {
				\ 'true'  : {},
				\ 'false' : {},
				\ }
	for client in clients

		let rtns_d.true[client]  = []
		let rtns_d.false[client] = []

		for file_ in a:files
			let str = system('p4 '.client.' have '.perforce#common#get_kk(file_))
			if s:is_p4_have_from_have(str) == 1
				let type = 'true'
			else
				let type = 'false'
			endif
			call add(rtns_d[type][client], file_)
		endfor

	endfor

	return rtns_d

endfunction
"}}}

let &cpo = s:save_cpo
unlet s:save_cpo

